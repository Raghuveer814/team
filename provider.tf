


provider "google" {
  project = "terraformcloudshell"
  region  = "europe-west1"
  zone = "${var.zone_primary}"
}
