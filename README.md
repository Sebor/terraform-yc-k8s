# K8S

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.0 |
| <a name="requirement_yandex"></a> [yandex](#requirement\_yandex) | >= 0.75 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | >= 0.75 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [yandex_iam_service_account.cluster](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/iam_service_account) | resource |
| [yandex_iam_service_account.cluster_node](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/iam_service_account) | resource |
| [yandex_kms_symmetric_key.this](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kms_symmetric_key) | resource |
| [yandex_kubernetes_cluster.this](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) | resource |
| [yandex_kubernetes_node_group.node_groups](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group) | resource |
| [yandex_resourcemanager_folder_iam_member.cluster](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_resourcemanager_folder_iam_member.cluster_node](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_description"></a> [cluster\_description](#input\_cluster\_description) | A description of the Kubernetes cluster | `string` | `"Kubernetes cluster managed by terraform"` | no |
| <a name="input_cluster_folder_id"></a> [cluster\_folder\_id](#input\_cluster\_folder\_id) | The ID of the folder that the Kubernetes cluster belongs to | `string` | n/a | yes |
| <a name="input_cluster_ipv4_range"></a> [cluster\_ipv4\_range](#input\_cluster\_ipv4\_range) | CIDR block. IP range for allocating pod addresses. It should not overlap with<br>any subnet in the network the Kubernetes cluster located in. Static routes will<br>be set up for this CIDR blocks in node subnets. | `string` | `null` | no |
| <a name="input_cluster_kms_key_create"></a> [cluster\_kms\_key\_create](#input\_cluster\_kms\_key\_create) | Should module create KMS key | `bool` | `false` | no |
| <a name="input_cluster_kms_key_id"></a> [cluster\_kms\_key\_id](#input\_cluster\_kms\_key\_id) | KMS key ID to encrypt kubernetes secrets | `string` | `null` | no |
| <a name="input_cluster_master_auto_upgrade"></a> [cluster\_master\_auto\_upgrade](#input\_cluster\_master\_auto\_upgrade) | Boolean flag that specifies if master can be upgraded automatically | `bool` | `false` | no |
| <a name="input_cluster_master_locations"></a> [cluster\_master\_locations](#input\_cluster\_master\_locations) | List of locations where cluster will be created. If list contains only one<br>location, will be created zonal cluster, if more than one -- regional | <pre>list(object({<br>    zone      = string<br>    subnet_id = string<br>  }))</pre> | n/a | yes |
| <a name="input_cluster_master_maintenance_windows"></a> [cluster\_master\_maintenance\_windows](#input\_cluster\_master\_maintenance\_windows) | List of structures that specifies maintenance windows,<br>  when auto update for master is allowed.<br>  Example:<pre>master_maintenance_windows = [<br>    {<br>      start_time = "23:00"<br>      duration   = "3h"<br>    }<br>  ]</pre> | `list(map(string))` | `[]` | no |
| <a name="input_cluster_master_public_ip"></a> [cluster\_master\_public\_ip](#input\_cluster\_master\_public\_ip) | Boolean flag. When true, Kubernetes master will have visible ipv4 address | `bool` | `false` | no |
| <a name="input_cluster_master_region"></a> [cluster\_master\_region](#input\_cluster\_master\_region) | Name of region where cluster will be created. Required for regional cluster,<br>not used for zonal cluster | `string` | `"ru-central1"` | no |
| <a name="input_cluster_master_security_group_ids"></a> [cluster\_master\_security\_group\_ids](#input\_cluster\_master\_security\_group\_ids) | List of security group IDs to be assigned to cluster | `list(string)` | `[]` | no |
| <a name="input_cluster_master_version"></a> [cluster\_master\_version](#input\_cluster\_master\_version) | Version of Kubernetes that will be used for master | `string` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Kubernetes cluster name and name prefix for cluster resources | `string` | n/a | yes |
| <a name="input_cluster_network_policy_provider"></a> [cluster\_network\_policy\_provider](#input\_cluster\_network\_policy\_provider) | Network policy provider for the cluster. Possible values: CALICO | `string` | `null` | no |
| <a name="input_cluster_node_ipv4_cidr_mask_size"></a> [cluster\_node\_ipv4\_cidr\_mask\_size](#input\_cluster\_node\_ipv4\_cidr\_mask\_size) | Size of the masks that are assigned to each node in the cluster. Effectively<br>limits maximum number of pods for each node. | `number` | `null` | no |
| <a name="input_cluster_node_service_account_id"></a> [cluster\_node\_service\_account\_id](#input\_cluster\_node\_service\_account\_id) | ID of service account to be used by the worker nodes of the Kubernetes<br>cluster to access Container Registry or to push node logs and metrics. | `string` | `null` | no |
| <a name="input_cluster_release_channel"></a> [cluster\_release\_channel](#input\_cluster\_release\_channel) | Cluster release channel | `string` | `"STABLE"` | no |
| <a name="input_cluster_service_account_id"></a> [cluster\_service\_account\_id](#input\_cluster\_service\_account\_id) | ID of existing service account to be used for provisioning Compute Cloud<br>and VPC resources for Kubernetes cluster. Selected service account should have<br>edit role on the folder where the Kubernetes cluster will be located and on the<br>folder where selected network resides. | `string` | `null` | no |
| <a name="input_cluster_service_ipv4_range"></a> [cluster\_service\_ipv4\_range](#input\_cluster\_service\_ipv4\_range) | CIDR block. IP range Kubernetes service Kubernetes cluster IP addresses<br>will be allocated from. It should not overlap with any subnet in the network<br>the Kubernetes cluster located in. | `string` | `null` | no |
| <a name="input_cluster_vpc_id"></a> [cluster\_vpc\_id](#input\_cluster\_vpc\_id) | The ID of the cluster network. | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | A set of key/value label pairs to assign to the Kubernetes cluster resources | `map(any)` | `{}` | no |
| <a name="input_node_groups"></a> [node\_groups](#input\_node\_groups) | Parameters of Kubernetes node groups.<br>  Example:<pre>node_groups = {<br>    public = {<br>      security_group_ids = [dependency.network.outputs.vpc_sg_id]<br>      nat                = true<br>    }<br>    private = {}<br>  }</pre> | `any` | `{}` | no |
| <a name="input_node_groups_default_locations"></a> [node\_groups\_default\_locations](#input\_node\_groups\_default\_locations) | Default locations of Kubernetes node groups.<br>If ommited, master\_locations will be used. | <pre>list(object({<br>    subnet_id = string<br>    zone      = string<br>  }))</pre> | `null` | no |
| <a name="input_node_groups_default_ssh_keys"></a> [node\_groups\_default\_ssh\_keys](#input\_node\_groups\_default\_ssh\_keys) | Map containing SSH keys to install on all Kubernetes node servers by default. | `map(list(string))` | `{}` | no |
| <a name="input_node_groups_locations"></a> [node\_groups\_locations](#input\_node\_groups\_locations) | Locations of Kubernetes node groups.<br>Use it to override default locations of certain node groups.<br>Example:<pre>node_groups_locations = {<br>  public  = dependency.network.outputs.public_subnet_ids<br>  private = dependency.network.outputs.private_subnet_ids<br>}</pre> | <pre>map(list(object({<br>    subnet_id = string<br>    zone      = string<br>  })))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | PEM-encoded public certificate that is the root of trust for<br>the Kubernetes cluster |
| <a name="output_cluster_ca_certificate_base64"></a> [cluster\_ca\_certificate\_base64](#output\_cluster\_ca\_certificate\_base64) | Base64 encoded public certificate that is the root of trust for<br>the Kubernetes cluster |
| <a name="output_cluster_external_v4_endpoint"></a> [cluster\_external\_v4\_endpoint](#output\_cluster\_external\_v4\_endpoint) | An IPv4 external network address that is assigned to the master |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | ID of a new Kubernetes cluster |
| <a name="output_cluster_internal_v4_endpoint"></a> [cluster\_internal\_v4\_endpoint](#output\_cluster\_internal\_v4\_endpoint) | An IPv4 internal network address that is assigned to the master |
| <a name="output_cluster_kms_key_id"></a> [cluster\_kms\_key\_id](#output\_cluster\_kms\_key\_id) | ID of a KMS cluster key |
| <a name="output_cluster_node_service_account_id"></a> [cluster\_node\_service\_account\_id](#output\_cluster\_node\_service\_account\_id) | ID of service account to be used by the worker nodes of the Kubernetes cluster<br>to access Container Registry or to push node logs and metrics |
| <a name="output_cluster_service_account_id"></a> [cluster\_service\_account\_id](#output\_cluster\_service\_account\_id) | ID of service account used for provisioning Compute Cloud and VPC resources<br>for Kubernetes cluster |
<!-- END_TF_DOCS -->
