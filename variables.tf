variable "compartment_id" {
  description = "OCID of the compartment in which to create the cluster."
  type        = string
}

variable "name" {
  description = "Human-readable name for the cluster."
  type        = string
}

variable "vcn_id" {
  description = "OCID of the VCN the cluster is deployed into."
  type        = string
}

variable "kubernetes_version" {
  description = <<-EOT
    Kubernetes version for the cluster control plane, in `vMAJOR.MINOR.PATCH` form
    (for example `v1.33.1`). There is deliberately no default: pick a version that
    OKE currently supports (`oci ce cluster-options get --cluster-option-id all`)
    rather than inheriting a pinned one that has gone out of support.
  EOT
  type        = string

  validation {
    condition     = can(regex("^v[0-9]+\\.[0-9]+\\.[0-9]+$", var.kubernetes_version))
    error_message = "kubernetes_version must look like v1.33.1 (leading 'v', three dot-separated numbers)."
  }
}

variable "cluster_type" {
  description = "Type of cluster (BASIC_CLUSTER or ENHANCED_CLUSTER)."
  type        = string
  default     = "ENHANCED_CLUSTER"

  validation {
    condition     = contains(["BASIC_CLUSTER", "ENHANCED_CLUSTER"], var.cluster_type)
    error_message = "cluster_type must be BASIC_CLUSTER or ENHANCED_CLUSTER."
  }
}

variable "endpoint_subnet_id" {
  description = "OCID of the subnet hosting the Kubernetes API endpoint."
  type        = string
}

variable "is_public_ip_enabled" {
  description = <<-EOT
    Whether the Kubernetes API endpoint is assigned a public IP. Defaults to false
    (private endpoint). When set to true, `endpoint_nsg_ids` must be non-empty —
    a public endpoint with no NSG attached is reachable from the whole internet.
  EOT
  type        = bool
  default     = false
}

variable "endpoint_nsg_ids" {
  description = <<-EOT
    OCIDs of network security groups applied to the Kubernetes API endpoint. This is
    the control that restricts who may reach the API server; supply the NSG(s) holding
    your operator/CI source ranges. Required when `is_public_ip_enabled` is true.
  EOT
  type        = list(string)
  default     = []
}

variable "kms_key_id" {
  description = <<-EOT
    OCID of an OCI Vault key used to envelope-encrypt Kubernetes secrets in etcd.
    Null (the default) leaves secrets under Oracle-managed encryption. Can only be
    set at cluster creation time; changing it forces a new cluster.
  EOT
  type        = string
  default     = null
}

variable "image_signing_kms_key_ids" {
  description = <<-EOT
    OCIDs of OCI Vault keys whose signatures must be present on container images before
    OKE will pull them. Supplying one or more keys enables the cluster image policy;
    an empty list (the default) leaves image verification off.
  EOT
  type        = list(string)
  default     = []
}

variable "service_lb_subnet_ids" {
  description = "List of subnet OCIDs used for load balancers created by Kubernetes services."
  type        = list(string)
  default     = []
}

variable "pods_cidr" {
  description = "CIDR block from which pod IPs are allocated."
  type        = string
  default     = "10.244.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.pods_cidr))
    error_message = "pods_cidr must be a valid IPv4 CIDR block, e.g. 10.244.0.0/16."
  }
}

variable "services_cidr" {
  description = "CIDR block from which service ClusterIPs are allocated."
  type        = string
  default     = "10.96.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.services_cidr))
    error_message = "services_cidr must be a valid IPv4 CIDR block, e.g. 10.96.0.0/16."
  }
}

variable "freeform_tags" {
  description = "Free-form tags applied to the cluster."
  type        = map(string)
  default     = {}
}

variable "defined_tags" {
  description = "Defined tags applied to the cluster, keyed as \"namespace.key\"."
  type        = map(string)
  default     = {}
}
