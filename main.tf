locals {
  master_regions = length(var.cluster_master_locations) > 1 ? [{
    region    = var.cluster_master_region
    locations = var.cluster_master_locations
  }] : []

  cluster_master_locations = length(var.cluster_master_locations) > 1 ? [] : var.cluster_master_locations

  common_ssh_keys_metadata = length(var.node_groups_default_ssh_keys) > 0 ? {
    ssh-keys = join("\n", flatten([
      for username, ssh_keys in var.node_groups_default_ssh_keys : [
        for ssh_key in ssh_keys
        : "${username}:${ssh_key}"
      ]
    ]))
  } : {}

  node_groups_default_locations = coalesce(var.node_groups_default_locations, var.cluster_master_locations)
}

### Cluster master section
resource "yandex_iam_service_account" "cluster" {
  count = var.cluster_service_account_id == null ? 1 : 0

  name = "${var.cluster_name}-cluster-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "cluster" {
  count = var.cluster_service_account_id == null ? 1 : 0

  folder_id = var.cluster_folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.cluster.0.id}"
}

resource "yandex_iam_service_account" "cluster_node" {
  count = var.cluster_node_service_account_id == null ? 1 : 0

  name = "${var.cluster_name}-cluster-node-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "cluster_node" {
  count = var.cluster_node_service_account_id == null ? 1 : 0

  folder_id = var.cluster_folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.cluster_node.0.id}"
}

resource "yandex_kms_symmetric_key" "this" {
  count = var.cluster_kms_key_create && var.cluster_kms_key_id == null ? 1 : 0

  name        = "${var.cluster_name}-symetric-key"
  description = "KMS for key for ${var.cluster_name}"

  labels = var.labels
}

resource "yandex_kubernetes_cluster" "this" {
  name        = var.cluster_name
  description = var.cluster_description
  folder_id   = var.cluster_folder_id

  release_channel         = var.cluster_release_channel
  network_id              = var.cluster_vpc_id
  network_policy_provider = var.cluster_network_policy_provider

  cluster_ipv4_range       = var.cluster_ipv4_range
  service_ipv4_range       = var.cluster_service_ipv4_range
  node_ipv4_cidr_mask_size = var.cluster_node_ipv4_cidr_mask_size

  service_account_id      = var.cluster_service_account_id != null ? var.cluster_service_account_id : yandex_iam_service_account.cluster.0.id
  node_service_account_id = var.cluster_node_service_account_id != null ? var.cluster_node_service_account_id : yandex_iam_service_account.cluster_node.0.id

  master {
    version            = var.cluster_master_version
    public_ip          = var.cluster_master_public_ip
    security_group_ids = var.cluster_master_security_group_ids

    maintenance_policy {
      auto_upgrade = var.cluster_master_auto_upgrade

      dynamic "maintenance_window" {
        for_each = var.cluster_master_maintenance_windows

        content {
          day        = lookup(maintenance_window.value, "day", null)
          start_time = maintenance_window.value["start_time"]
          duration   = maintenance_window.value["duration"]
        }
      }
    }

    dynamic "zonal" {
      for_each = local.cluster_master_locations

      content {
        zone      = zonal.value["zone"]
        subnet_id = zonal.value["subnet_id"]
      }
    }

    dynamic "regional" {
      for_each = local.master_regions

      content {
        region = regional.value["region"]

        dynamic "location" {
          for_each = regional.value["locations"]

          content {
            zone      = location.value["zone"]
            subnet_id = location.value["subnet_id"]
          }
        }
      }
    }
  }

  dynamic "kms_provider" {
    for_each = var.cluster_kms_key_id == null && var.cluster_kms_key_create ? try([yandex_kms_symmetric_key.this.0.id], []) : [var.cluster_kms_key_id]

    content {
      key_id = kms_provider.value
    }
  }

  labels = var.labels

  depends_on = [
    yandex_resourcemanager_folder_iam_member.cluster,
    yandex_resourcemanager_folder_iam_member.cluster_node
  ]
}

### Node group section
resource "yandex_kubernetes_node_group" "node_groups" {
  for_each = var.node_groups

  cluster_id  = yandex_kubernetes_cluster.this.id
  name        = each.key
  description = lookup(each.value, "description", null)
  labels      = lookup(each.value, "labels", var.labels)
  version     = lookup(each.value, "version", var.cluster_master_version)

  node_labels            = lookup(each.value, "node_labels", null)
  node_taints            = lookup(each.value, "node_taints", null)
  allowed_unsafe_sysctls = lookup(each.value, "allowed_unsafe_sysctls", null)

  instance_template {
    platform_id = lookup(each.value, "platform_id", "standard-v3")
    metadata    = merge(local.common_ssh_keys_metadata, lookup(each.value, "metadata", {}))

    resources {
      cores         = lookup(each.value, "cores", 2)
      core_fraction = lookup(each.value, "core_fraction", 100)
      memory        = lookup(each.value, "memory", 2)
    }

    boot_disk {
      type = lookup(each.value, "boot_disk_type", "network-hdd")
      size = lookup(each.value, "boot_disk_size", 64)
    }

    scheduling_policy {
      preemptible = lookup(each.value, "preemptible", false)
    }

    container_runtime {
      type = lookup(each.value, "container_runtime_type", "containerd")
    }

    network_interface {
      subnet_ids         = [for location in lookup(var.node_groups_locations, each.key, local.node_groups_default_locations) : location.subnet_id]
      nat                = lookup(each.value, "nat", null)
      security_group_ids = lookup(each.value, "security_group_ids", null)
    }
  }

  scale_policy {
    dynamic "fixed_scale" {
      for_each = flatten([lookup(each.value, "fixed_scale", can(each.value["auto_scale"]) ? [] : [{ size = 1 }])])

      content {
        size = fixed_scale.value.size
      }
    }

    dynamic "auto_scale" {
      for_each = flatten([lookup(each.value, "auto_scale", [])])

      content {
        min     = auto_scale.value.min
        max     = auto_scale.value.max
        initial = auto_scale.value.initial
      }
    }
  }

  allocation_policy {
    dynamic "location" {
      for_each = lookup(var.node_groups_locations, each.key, local.node_groups_default_locations)

      content {
        zone = location.value.zone
      }
    }
  }

  maintenance_policy {
    auto_repair  = lookup(each.value, "auto_repair", true)
    auto_upgrade = lookup(each.value, "auto_upgrade", true)

    dynamic "maintenance_window" {
      for_each = lookup(each.value, "maintenance_windows", [])

      content {
        day        = lookup(maintenance_window.value, "day", null)
        start_time = maintenance_window.value["start_time"]
        duration   = maintenance_window.value["duration"]
      }
    }
  }
}
