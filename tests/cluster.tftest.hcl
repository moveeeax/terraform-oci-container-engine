# Requires Terraform >= 1.7 for `mock_provider` — a test-only requirement, which is
# why the module's own required_version stays at >= 1.5. Runs entirely offline: the
# OCI provider is mocked, so no credentials and no API calls are involved.

mock_provider "oci" {}

variables {
  compartment_id     = "ocid1.compartment.oc1..aaaaaaaaexamplecompartment"
  name               = "unit-test-oke"
  vcn_id             = "ocid1.vcn.oc1..aaaaaaaaexamplevcn"
  kubernetes_version = "v1.36.4"
  endpoint_subnet_id = "ocid1.subnet.oc1..aaaaaaaaexampleendpointsubnet"
}

run "defaults_keep_the_control_plane_private" {
  assert {
    condition     = oci_containerengine_cluster.this.endpoint_config[0].is_public_ip_enabled == false
    error_message = "The Kubernetes API endpoint must default to private (no public IP)."
  }
}

run "defaults_leave_optional_security_features_unset" {
  # kms_key_id is deliberately not asserted here: it is Optional+Computed in the OCI
  # schema, so the mock provider invents a value for it. Its wiring is covered by
  # run "kms_key_is_passed_through" below.
  assert {
    condition     = length(oci_containerengine_cluster.this.image_policy_config) == 0
    error_message = "No image_policy_config block should be emitted when no signing keys are supplied."
  }
}

run "public_endpoint_without_nsgs_is_rejected" {
  command = plan

  variables {
    is_public_ip_enabled = true
  }

  expect_failures = [oci_containerengine_cluster.this]
}

run "public_endpoint_with_nsgs_is_allowed" {
  variables {
    is_public_ip_enabled = true
    endpoint_nsg_ids     = ["ocid1.networksecuritygroup.oc1..aaaaaaaaexamplensg"]
  }

  assert {
    condition     = toset(oci_containerengine_cluster.this.endpoint_config[0].nsg_ids) == toset(["ocid1.networksecuritygroup.oc1..aaaaaaaaexamplensg"])
    error_message = "endpoint_nsg_ids must be passed through to endpoint_config.nsg_ids."
  }
}

run "signing_keys_enable_the_image_policy" {
  variables {
    image_signing_kms_key_ids = [
      "ocid1.key.oc1..aaaaaaaaexamplekeyone",
      "ocid1.key.oc1..aaaaaaaaexamplekeytwo",
    ]
  }

  assert {
    condition     = oci_containerengine_cluster.this.image_policy_config[0].is_policy_enabled
    error_message = "Supplying signing keys must enable the cluster image policy."
  }

  assert {
    condition     = length(oci_containerengine_cluster.this.image_policy_config[0].key_details) == 2
    error_message = "Every supplied signing key must become a key_details entry."
  }
}

run "kms_key_is_passed_through" {
  variables {
    kms_key_id = "ocid1.key.oc1..aaaaaaaaexampleetcdkey"
  }

  assert {
    condition     = oci_containerengine_cluster.this.kms_key_id == "ocid1.key.oc1..aaaaaaaaexampleetcdkey"
    error_message = "kms_key_id must reach the cluster resource so etcd secrets are envelope-encrypted."
  }
}

run "rejects_unsupported_cluster_type" {
  command = plan

  variables {
    cluster_type = "SUPER_CLUSTER"
  }

  expect_failures = [var.cluster_type]
}

run "rejects_malformed_kubernetes_version" {
  command = plan

  variables {
    kubernetes_version = "1.33"
  }

  expect_failures = [var.kubernetes_version]
}

run "rejects_malformed_pods_cidr" {
  command = plan

  variables {
    pods_cidr = "10.244.0.0/nope"
  }

  expect_failures = [var.pods_cidr]
}
