# outputs.tf

# Kubeconfig generation for the created EKS cluster

output "kubeconfig" {
  description = "Kubeconfig file content for accessing the EKS cluster"
  value = <<EOT
apiVersion: v1
kind: Config
clusters:
- cluster:
    server: ${module.eks.cluster_endpoint}
    certificate-authority-data: ${module.eks.cluster_certificate_authority_data}
  name: ${module.eks.cluster_name}
contexts:
- context:
    cluster: ${module.eks.cluster_name}
    user: aws
  name: ${module.eks.cluster_name}
current-context: ${module.eks.cluster_name}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws
      args:
        - eks
        - get-token
        - --cluster-name
        - ${module.eks.cluster_name}
        - --region
        - ${var.aws_region}
EOT
  sensitive = true
}

# Convenience command output
output "kubeconfig_command" {
  description = "Command to export kubeconfig"
  value = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
}

