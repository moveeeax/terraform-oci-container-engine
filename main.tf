resource "oci_containerengine_cluster" "this" {
  compartment_id     = var.compartment_id
  name               = var.name
  vcn_id             = var.vcn_id
  kubernetes_version = var.kubernetes_version
  type               = var.cluster_type

  # Envelope-encrypt Kubernetes secrets in etcd with a customer-managed Vault key.
  # Null means OKE falls back to Oracle-managed encryption.
  kms_key_id = var.kms_key_id

  endpoint_config {
    subnet_id            = var.endpoint_subnet_id
    is_public_ip_enabled = var.is_public_ip_enabled

    # Network security groups are the only thing that constrains who can reach the
    # Kubernetes API server. Without them the endpoint is reachable from anything
    # the subnet's security lists allow.
    nsg_ids = var.endpoint_nsg_ids
  }

  # Only emitted when signing keys are supplied, so clusters that do not use
  # signed images keep their existing (disabled) policy untouched.
  dynamic "image_policy_config" {
    for_each = length(var.image_signing_kms_key_ids) > 0 ? [1] : []

    content {
      is_policy_enabled = true

      dynamic "key_details" {
        for_each = var.image_signing_kms_key_ids

        content {
          kms_key_id = key_details.value
        }
      }
    }
  }

  options {
    service_lb_subnet_ids = var.service_lb_subnet_ids

    kubernetes_network_config {
      pods_cidr     = var.pods_cidr
      services_cidr = var.services_cidr
    }
  }

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags

  lifecycle {
    # A public API endpoint with no NSG attached is reachable from the internet.
    # Refuse to build one rather than silently exposing the control plane.
    precondition {
      condition     = !var.is_public_ip_enabled || length(var.endpoint_nsg_ids) > 0
      error_message = "is_public_ip_enabled = true requires at least one NSG in endpoint_nsg_ids to restrict access to the Kubernetes API endpoint."
    }
  }
}
