resource "google_compute_autoscaler" "autoscaler" {
  name   = var.autoscaler_name
  zone   = var.zone_primary
  target = google_compute_instance_group_manager.instance-group-manager.id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }
}

resource "google_compute_instance_template" "instance-template" {
  name           = var.autoscaler_name
  machine_type   = var.compute_machine_type
  can_ip_forward = false

  tags = ["foo", "bar"]

  disk {
    source_image = data.google_compute_image.debian_9.id
  }

  network_interface {
    network = "default"
  }

  metadata = {
    foo = "bar"
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

resource "google_compute_target_pool" "target-pool" {
  name = var.autoscaler_name
}

resource "google_compute_instance_group_manager" "instance-group-manager" {
  name = var.autoscaler_name
  zone = var.zone_primary

  version {
    instance_template  = google_compute_instance_template.instance-template.id
    name               = "primary"
  }

  target_pools       = [google_compute_target_pool.target-pool.id]
  base_instance_name = "base-instance"
}

data "google_compute_image" "debian_9" {
  family  = "debian-11"
  project = "debian-cloud"
}
