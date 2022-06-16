variable "cluster_name" {
  type        = string
  description = "Kubernetes cluster name and name prefix for cluster resources"
}

variable "cluster_description" {
  type        = string
  default     = "Kubernetes cluster managed by terraform"
  description = "A description of the Kubernetes cluster"
}

variable "cluster_folder_id" {
  type        = string
  description = "The ID of the folder that the Kubernetes cluster belongs to"
}

variable "cluster_release_channel" {
  type        = string
  default     = "STABLE"
  description = "Cluster release channel"

  validation {
    condition     = contains(["STABLE", "REGULAR", "RAPID"], var.cluster_release_channel)
    error_message = "Release Channel must be 'STABLE', 'REGULAR' or 'RAPID'."
  }
}

variable "cluster_vpc_id" {
  type        = string
  description = "The ID of the cluster network."
}

variable "cluster_network_policy_provider" {
  type        = string
  default     = null
  description = "Network policy provider for the cluster. Possible values: CALICO"

  validation {
    condition     = var.cluster_network_policy_provider == null || var.cluster_network_policy_provider == "CALICO"
    error_message = "Provider must be 'CALICO'."
  }
}

variable "cluster_ipv4_range" {
  type        = string
  default     = null
  description = <<-EOF
  CIDR block. IP range for allocating pod addresses. It should not overlap with
  any subnet in the network the Kubernetes cluster located in. Static routes will
  be set up for this CIDR blocks in node subnets.
  EOF
}

variable "cluster_service_ipv4_range" {
  type        = string
  default     = null
  description = <<-EOF
  CIDR block. IP range Kubernetes service Kubernetes cluster IP addresses
  will be allocated from. It should not overlap with any subnet in the network
  the Kubernetes cluster located in.
  EOF
}

variable "cluster_node_ipv4_cidr_mask_size" {
  type        = number
  default     = null
  description = <<-EOF
  Size of the masks that are assigned to each node in the cluster. Effectively
  limits maximum number of pods for each node.
  EOF
}

variable "cluster_service_account_id" {
  type        = string
  default     = null
  description = <<-EOF
  ID of existing service account to be used for provisioning Compute Cloud
  and VPC resources for Kubernetes cluster. Selected service account should have
  edit role on the folder where the Kubernetes cluster will be located and on the
  folder where selected network resides.
  EOF
}

variable "cluster_node_service_account_id" {
  type        = string
  default     = null
  description = <<-EOF
  ID of service account to be used by the worker nodes of the Kubernetes
  cluster to access Container Registry or to push node logs and metrics.
  EOF
}

variable "cluster_master_version" {
  type        = string
  default     = null
  description = "Version of Kubernetes that will be used for master"
}

variable "cluster_master_public_ip" {
  type        = bool
  default     = false
  description = "Boolean flag. When true, Kubernetes master will have visible ipv4 address"
}

variable "cluster_master_security_group_ids" {
  type        = list(string)
  default     = []
  description = "List of security group IDs to be assigned to cluster"
}

variable "cluster_master_auto_upgrade" {
  type        = bool
  default     = false
  description = "Boolean flag that specifies if master can be upgraded automatically"
}

variable "cluster_master_maintenance_windows" {
  type        = list(map(string))
  default     = []
  description = <<EOF
  List of structures that specifies maintenance windows,
  when auto update for master is allowed.
  Example:
  ```
  master_maintenance_windows = [
    {
      start_time = "23:00"
      duration   = "3h"
    }
  ]
  ```
  EOF
}

variable "cluster_kms_key_create" {
  type        = bool
  default     = false
  description = "Should module create KMS key"
}

variable "cluster_kms_key_id" {
  type        = string
  default     = null
  description = "KMS key ID to encrypt kubernetes secrets"
}

variable "labels" {
  type        = map(any)
  default     = {}
  description = "A set of key/value label pairs to assign to the Kubernetes cluster resources"
}

variable "cluster_master_region" {
  type        = string
  default     = "ru-central1"
  description = <<-EOF
  Name of region where cluster will be created. Required for regional cluster,
  not used for zonal cluster
  EOF
}

variable "cluster_master_locations" {
  type = list(object({
    zone      = string
    subnet_id = string
  }))
  description = <<-EOF
  List of locations where cluster will be created. If list contains only one
  location, will be created zonal cluster, if more than one -- regional
  EOF
}

variable "node_groups" {
  type        = any
  default     = {}
  description = <<EOF
  Parameters of Kubernetes node groups.
  Example:
  ```
    node_groups = {
    public = {
      security_group_ids = [dependency.network.outputs.vpc_sg_id]
      nat                = true
    }
    private = {}
  }
  ```
  EOF
}

variable "node_groups_default_ssh_keys" {
  type        = map(list(string))
  default     = {}
  description = <<-EOF
  Map containing SSH keys to install on all Kubernetes node servers by default.
  EOF
}

variable "node_groups_default_locations" {
  type = list(object({
    subnet_id = string
    zone      = string
  }))
  default     = null
  description = <<-EOF
  Default locations of Kubernetes node groups.
  If ommited, master_locations will be used.
  EOF
}

variable "node_groups_locations" {
  type = map(list(object({
    subnet_id = string
    zone      = string
  })))
  default     = {}
  description = <<-EOF
  Locations of Kubernetes node groups.
  Use it to override default locations of certain node groups.
  Example:
  ```
    node_groups_locations = {
    public  = dependency.network.outputs.public_subnet_ids
    private = dependency.network.outputs.private_subnet_ids
  }
  ```
  EOF
}
