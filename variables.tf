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
  description = "Kubernetes version for the cluster control plane."
  type        = string
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
  description = "Whether the Kubernetes API endpoint is assigned a public IP."
  type        = bool
  default     = false
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
}

variable "services_cidr" {
  description = "CIDR block from which service ClusterIPs are allocated."
  type        = string
  default     = "10.96.0.0/16"
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
