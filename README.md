# terraform-oci-container-engine

Terraform module that manages an [Oracle Cloud Infrastructure](https://www.oracle.com/cloud/)
Container Engine for Kubernetes (OKE) cluster control plane. It configures the API
endpoint subnet, service load-balancer subnets and the pod/service CIDR ranges. Node
pools are managed separately.

## Usage

```hcl
module "cluster" {
  source = "github.com/moveeeax/terraform-oci-container-engine"

  compartment_id     = var.compartment_id
  name               = "prod-oke"
  vcn_id             = var.vcn_id
  kubernetes_version = "v1.33.1"
  cluster_type       = "ENHANCED_CLUSTER"

  # Private API endpoint (the default), restricted to the NSG's source ranges.
  is_public_ip_enabled  = false
  endpoint_subnet_id    = var.endpoint_subnet_id
  endpoint_nsg_ids      = [var.endpoint_nsg_id]
  service_lb_subnet_ids = [var.lb_subnet_id]

  # Envelope-encrypt Kubernetes secrets in etcd with your own Vault key.
  kms_key_id = var.vault_key_id

  freeform_tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

A runnable example lives in [`examples/basic`](examples/basic).

## Security notes

- **The API endpoint is private by default.** `is_public_ip_enabled` defaults to `false`.
  If you set it to `true`, the module *requires* `endpoint_nsg_ids` to be non-empty —
  a public Kubernetes API endpoint with no network security group attached is reachable
  from the whole internet. Attaching NSGs is worthwhile for private endpoints too: they,
  not the subnet's security lists alone, are what scopes access to the control plane.
- **Secrets at rest.** Set `kms_key_id` to an OCI Vault key to envelope-encrypt Kubernetes
  secrets in etcd. OKE only accepts this at cluster creation, so changing it later replaces
  the cluster.
- **Image verification.** Set `image_signing_kms_key_ids` to require that images carry a
  signature from one of those Vault keys before OKE will pull them. Left empty, no image
  policy is created and the cluster's existing (disabled) policy is untouched.
- **Pod security.** OKE's `admission_controller_options.is_pod_security_policy_enabled`
  knob is intentionally not exposed: PodSecurityPolicy was removed from Kubernetes in 1.25.
  Use [Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/)
  namespace labels, applied in-cluster, instead.
- **Node pools are out of scope.** This module manages only the control plane, so node
  placement, image and boot-volume encryption are the responsibility of whatever manages
  your node pools. Put worker nodes in private subnets.
- **Pick a supported Kubernetes version.** `kubernetes_version` has no default on purpose —
  a pinned default silently rots out of support. Check `oci ce cluster-options get
  --cluster-option-id all` for what OKE currently offers.

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.5   |
| oci       | >= 5.0   |

Running the module's own test suite (`terraform test`) additionally needs Terraform
>= 1.7 for `mock_provider`. The tests run fully offline against the mocked provider —
no OCI credentials, no API calls:

```sh
terraform init -backend=false
terraform test
```

## Inputs

| Name                    | Description                                                      | Type           | Default              | Required |
|-------------------------|------------------------------------------------------------------|----------------|----------------------|:--------:|
| `compartment_id`        | OCID of the compartment in which to create the cluster.          | `string`       | n/a                  |   yes    |
| `name`                  | Human-readable name for the cluster.                             | `string`       | n/a                  |   yes    |
| `vcn_id`                | OCID of the VCN the cluster is deployed into.                    | `string`       | n/a                  |   yes    |
| `kubernetes_version`    | Kubernetes version for the control plane, as `vMAJOR.MINOR.PATCH`. | `string`     | n/a                  |   yes    |
| `cluster_type`          | Cluster type (`BASIC_CLUSTER` or `ENHANCED_CLUSTER`).           | `string`       | `"ENHANCED_CLUSTER"` |    no    |
| `endpoint_subnet_id`    | OCID of the subnet hosting the Kubernetes API endpoint.          | `string`       | n/a                  |   yes    |
| `is_public_ip_enabled`  | Whether the API endpoint has a public IP. Requires `endpoint_nsg_ids` when true. | `bool` | `false`      |    no    |
| `endpoint_nsg_ids`      | NSG OCIDs restricting access to the Kubernetes API endpoint.     | `list(string)` | `[]`                 |    no    |
| `kms_key_id`            | Vault key OCID used to envelope-encrypt Kubernetes secrets in etcd. | `string`    | `null`               |    no    |
| `image_signing_kms_key_ids` | Vault key OCIDs whose signatures images must carry; non-empty enables the image policy. | `list(string)` | `[]` | no |
| `service_lb_subnet_ids` | Subnet OCIDs for Kubernetes service load balancers.              | `list(string)` | `[]`                 |    no    |
| `pods_cidr`             | CIDR block from which pod IPs are allocated.                     | `string`       | `"10.244.0.0/16"`    |    no    |
| `services_cidr`         | CIDR block from which service ClusterIPs are allocated.          | `string`       | `"10.96.0.0/16"`     |    no    |
| `freeform_tags`         | Free-form tags applied to the cluster.                           | `map(string)`  | `{}`                 |    no    |
| `defined_tags`          | Defined tags applied to the cluster, keyed `namespace.key`.      | `map(string)`  | `{}`                 |    no    |

## Outputs

| Name                 | Description                                    |
|----------------------|------------------------------------------------|
| `id`                 | OCID of the cluster.                           |
| `name`               | Name of the cluster.                           |
| `kubernetes_version` | Kubernetes version of the control plane.       |
| `endpoints`          | Kubernetes API server endpoints.               |
| `state`              | Lifecycle state of the cluster.                |

## License

[MIT](LICENSE)
