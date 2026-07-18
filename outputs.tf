output "id" {
  description = "OCID of the cluster."
  value       = oci_containerengine_cluster.this.id
}

output "name" {
  description = "Name of the cluster."
  value       = oci_containerengine_cluster.this.name
}

output "kubernetes_version" {
  description = "Kubernetes version of the cluster control plane."
  value       = oci_containerengine_cluster.this.kubernetes_version
}

output "endpoints" {
  description = "Kubernetes API server endpoints for the cluster."
  value       = oci_containerengine_cluster.this.endpoints
}

output "state" {
  description = "Lifecycle state of the cluster."
  value       = oci_containerengine_cluster.this.state
}
