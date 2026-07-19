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
  kubernetes_version = "v1.29.1"
  cluster_type       = "ENHANCED_CLUSTER"

  endpoint_subnet_id    = var.endpoint_subnet_id
  service_lb_subnet_ids = [var.lb_subnet_id]

  freeform_tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

A runnable example lives in [`examples/basic`](examples/basic).

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.5   |
| oci       | >= 5.0   |

## Inputs

| Name                    | Description                                                      | Type           | Default              | Required |
|-------------------------|------------------------------------------------------------------|----------------|----------------------|:--------:|
| `compartment_id`        | OCID of the compartment in which to create the cluster.          | `string`       | n/a                  |   yes    |
| `name`                  | Human-readable name for the cluster.                             | `string`       | n/a                  |   yes    |
| `vcn_id`                | OCID of the VCN the cluster is deployed into.                    | `string`       | n/a                  |   yes    |
| `kubernetes_version`    | Kubernetes version for the control plane.                        | `string`       | n/a                  |   yes    |
| `cluster_type`          | Cluster type (`BASIC_CLUSTER` or `ENHANCED_CLUSTER`).           | `string`       | `"ENHANCED_CLUSTER"` |    no    |
| `endpoint_subnet_id`    | OCID of the subnet hosting the Kubernetes API endpoint.          | `string`       | n/a                  |   yes    |
| `is_public_ip_enabled`  | Whether the API endpoint has a public IP.                        | `bool`         | `false`              |    no    |
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
