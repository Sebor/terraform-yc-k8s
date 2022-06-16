output "cluster_external_v4_endpoint" {
  value       = yandex_kubernetes_cluster.this.master[0].external_v4_endpoint
  description = "An IPv4 external network address that is assigned to the master"
}

output "cluster_internal_v4_endpoint" {
  value       = yandex_kubernetes_cluster.this.master[0].internal_v4_endpoint
  description = "An IPv4 internal network address that is assigned to the master"
}

output "cluster_ca_certificate" {
  value       = yandex_kubernetes_cluster.this.master[0].cluster_ca_certificate
  description = <<-EOF
  PEM-encoded public certificate that is the root of trust for
  the Kubernetes cluster
  EOF
}

output "cluster_id" {
  value       = yandex_kubernetes_cluster.this.id
  description = "ID of a new Kubernetes cluster"
}

output "cluster_service_account_id" {
  value       = var.cluster_service_account_id != null ? var.cluster_service_account_id : yandex_iam_service_account.cluster.0.id
  description = <<-EOF
  ID of service account used for provisioning Compute Cloud and VPC resources
  for Kubernetes cluster
  EOF
}

output "cluster_node_service_account_id" {
  value       = var.cluster_node_service_account_id != null ? var.cluster_node_service_account_id : yandex_iam_service_account.cluster_node.0.id
  description = <<-EOF
  ID of service account to be used by the worker nodes of the Kubernetes cluster
  to access Container Registry or to push node logs and metrics
  EOF
}

output "cluster_kms_key_id" {
  value       = var.cluster_kms_key_create ? yandex_kms_symmetric_key.this.0.id : var.cluster_kms_key_id
  description = "ID of a KMS cluster key"
}

output "cluster_ca_certificate_base64" {
  value       = base64encode(yandex_kubernetes_cluster.this.master[0].cluster_ca_certificate)
  description = <<-EOF
  Base64 encoded public certificate that is the root of trust for
  the Kubernetes cluster
  EOF
}
