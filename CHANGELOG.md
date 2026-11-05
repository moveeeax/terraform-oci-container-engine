# Changelog

All notable changes to this project are documented in this file. The format is based
on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres
to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - Unreleased

### Changed

- Raise the minimum `oracle/oci` provider version from `>= 5.0` to `>= 9.0`.
- README usage, the example and the test inputs use Kubernetes `v1.36.4`, a version OKE
  currently supports. The previous `v1.33.1` is past its OKE end-of-life date.
- README usage pins the module source to `?ref=v1.1.0`.
- CI: `actions/checkout` v7, `opentofu/setup-opentofu` v2, `terraform-linters/setup-tflint`
  v6 with TFLint pinned to `v0.65.0`; the workflow token is limited to `contents: read`.
- LICENSE copyright year corrected to 2026.

### Added

- Dependabot configuration for GitHub Actions and Terraform, checked weekly.
- This changelog.

## [1.0.0] - 2026-07-26

### Added

- Module managing an OKE cluster control plane: API endpoint subnet, service
  load-balancer subnets, pod and service CIDR ranges.
- `endpoint_nsg_ids`, wired to `endpoint_config.nsg_ids`, to restrict access to the
  Kubernetes API endpoint.
- A precondition that refuses `is_public_ip_enabled = true` unless at least one NSG is
  supplied. The API endpoint stays private by default.
- `kms_key_id` for envelope encryption of Kubernetes secrets in etcd.
- `image_signing_kms_key_ids`, which enables the cluster image policy only when keys are
  supplied.
- Validation of `kubernetes_version` format and of the pod and service CIDRs.
- Offline test suite (`mock_provider`) and CI running `tofu fmt`, `validate`, `test` and
  TFLint.

[1.1.0]: https://github.com/moveeeax/terraform-oci-container-engine/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/moveeeax/terraform-oci-container-engine/releases/tag/v1.0.0
