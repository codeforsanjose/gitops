# Enable AWS EKS Container Insights
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-metrics.html


# resource "kubectl_manifest" "amazon-cloudwatch-namespace" {
#   yaml_body = <<-YAML
#     ---
#     apiVersion: v1
#     kind: Namespace
#     metadata:
#       name: amazon-cloudwatch
#     labels:
#       name: amazon-cloudwatch
#   YAML
# }

# resource "kubectl_manifest" "amazon-cloudwatch-service-account" {
#   yaml_body = <<-YAML
#     ---
#     apiVersion: v1
#     kind: ServiceAccount
#     metadata:
#       name: cloudwatch-agent
#       namespace: amazon-cloudwatch
#   YAML
# }

# resource "kubectl_manifest" "amazon-cloudwatch-rbac" {
#   yaml_body = <<-YAML
#     ---
#     kind: ClusterRole
#     apiVersion: rbac.authorization.k8s.io/v1
#     metadata:
#       name: cloudwatch-agent-role
#     rules:
#       - apiGroups: [""]
#         resources: ["pods", "nodes", "endpoints"]
#         verbs: ["list", "watch"]
#       - apiGroups: ["apps"]
#         resources: ["replicasets"]
#         verbs: ["list", "watch"]
#       - apiGroups: ["batch"]
#         resources: ["jobs"]
#         verbs: ["list", "watch"]
#       - apiGroups: [""]
#         resources: ["nodes/proxy"]
#         verbs: ["get"]
#       - apiGroups: [""]
#         resources: ["nodes/stats", "configmaps", "events"]
#         verbs: ["create"]
#       - apiGroups: [""]
#         resources: ["configmaps"]
#         resourceNames: ["cwagent-clusterleader"]
#         verbs: ["get","update"]
#   YAML
# }

# resource "kubectl_manifest" "amazon-cloudwatch-role-binding" {
#   yaml_body = <<-YAML
#     ---
#     kind: ClusterRoleBinding
#     apiVersion: rbac.authorization.k8s.io/v1
#     metadata:
#       name: cloudwatch-agent-role-binding
#     subjects:
#       - kind: ServiceAccount
#         name: cloudwatch-agent
#         namespace: amazon-cloudwatch
#     roleRef:
#       kind: ClusterRole
#       name: cloudwatch-agent-role
#       apiGroup: rbac.authorization.k8s.io
#   YAML
# }

# resource "kubectl_manifest" "amazon-cloudwatch-config-map" {
#   yaml_body = <<-YAML
#     ---
#     apiVersion: v1
#     data:
#       cwagentconfig.json: |
#         {
#           "logs": {
#             "metrics_collected": {
#               "kubernetes": {
#                 "cluster_name": "${module.eks.cluster_name}",
#                 "metrics_collection_interval": 30
#               }
#             },
#             "force_flush_interval": 5
#           }
#         }
#     kind: ConfigMap
#     metadata:
#       name: cwagentconfig
#       namespace: amazon-cloudwatch
#   YAML
# }

# resource "kubectl_manifest" "amazon-cloudwatch-daemonset" {
#   yaml_body = <<-YAML
#     ---
#     apiVersion: apps/v1
#     kind: DaemonSet
#     metadata:
#       name: cloudwatch-agent
#       namespace: amazon-cloudwatch
#     spec:
#       selector:
#         matchLabels:
#           name: cloudwatch-agent
#       template:
#         metadata:
#           labels:
#             name: cloudwatch-agent
#         spec:
#           containers:
#             - name: cloudwatch-agent
#               image: public.ecr.aws/cloudwatch-agent/cloudwatch-agent:1.247359.1b252618
#               ports:
#                - containerPort: 8125
#                  hostPort: 8125
#                  protocol: UDP
#               resources:
#                 limits:
#                   cpu:  200m
#                   memory: 200Mi
#                 requests:
#                   cpu: 200m
#                   memory: 200Mi
#               # Please don't change below envs
#               env:
#                 - name: HOST_IP
#                   valueFrom:
#                     fieldRef:
#                       fieldPath: status.hostIP
#                 - name: HOST_NAME
#                   valueFrom:
#                     fieldRef:
#                       fieldPath: spec.nodeName
#                 - name: K8S_NAMESPACE
#                   valueFrom:
#                     fieldRef:
#                       fieldPath: metadata.namespace
#                 - name: CI_VERSION
#                   value: "k8s/1.3.15"
#               # Please don't change the mountPath
#               volumeMounts:
#                 - name: cwagentconfig
#                   mountPath: /etc/cwagentconfig
#                 - name: rootfs
#                   mountPath: /rootfs
#                   readOnly: true
#                 - name: dockersock
#                   mountPath: /var/run/docker.sock
#                   readOnly: true
#                 - name: varlibdocker
#                   mountPath: /var/lib/docker
#                   readOnly: true
#                 - name: containerdsock
#                   mountPath: /run/containerd/containerd.sock
#                   readOnly: true
#                 - name: sys
#                   mountPath: /sys
#                   readOnly: true
#                 - name: devdisk
#                   mountPath: /dev/disk
#                   readOnly: true
#           nodeSelector:
#             kubernetes.io/os: linux
#           volumes:
#             - name: cwagentconfig
#               configMap:
#                 name: cwagentconfig
#             - name: rootfs
#               hostPath:
#                 path: /
#             - name: dockersock
#               hostPath:
#                 path: /var/run/docker.sock
#             - name: varlibdocker
#               hostPath:
#                 path: /var/lib/docker
#             - name: containerdsock
#               hostPath:
#                 path: /run/containerd/containerd.sock
#             - name: sys
#               hostPath:
#                 path: /sys
#             - name: devdisk
#               hostPath:
#                 path: /dev/disk/
#           terminationGracePeriodSeconds: 60
#           serviceAccountName: cloudwatch-agent
#   YAML
# }
