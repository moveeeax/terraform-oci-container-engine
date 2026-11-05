provider "oci" {}

module "cluster" {
  source = "../.."

  compartment_id     = var.compartment_id
  name               = "example-oke"
  vcn_id             = var.vcn_id
  kubernetes_version = var.kubernetes_version
  cluster_type       = "ENHANCED_CLUSTER"

  # Private API endpoint (the module default), further restricted to the source
  # ranges in the supplied network security group.
  is_public_ip_enabled  = false
  endpoint_subnet_id    = var.endpoint_subnet_id
  endpoint_nsg_ids      = [var.endpoint_nsg_id]
  service_lb_subnet_ids = [var.lb_subnet_id]

  freeform_tags = {
    Environment = "sandbox"
    ManagedBy   = "terraform"
  }
}

variable "compartment_id" {
  description = "Compartment OCID to deploy the example cluster into."
  type        = string
}

variable "vcn_id" {
  description = "OCID of the VCN for the example cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the example cluster (e.g. v1.36.4). Use a version OKE still supports."
  type        = string
}

variable "endpoint_subnet_id" {
  description = "OCID of the subnet hosting the Kubernetes API endpoint."
  type        = string
}

variable "endpoint_nsg_id" {
  description = "OCID of the network security group that restricts access to the Kubernetes API endpoint."
  type        = string
}

variable "lb_subnet_id" {
  description = "OCID of the subnet used for service load balancers."
  type        = string
}

output "cluster_id" {
  value = module.cluster.id
}
