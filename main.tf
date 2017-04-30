// Configure the Google Cloud provider
provider "google" {
  credentials = "${file(var.account_file_path)}"
  project     = "noted-branch-166112"
  region      = "${var.region}"
}

resource "google_compute_http_health_check" "default" {
    name = "tf-www-basic-check"
    request_path = "/"
    check_interval_sec = 1
    healthy_threshold = 1
    unhealthy_threshold = 10
    timeout_sec = 1
}

resource "google_compute_target_pool" "default" {
    name = "tf-www-target-pool"
    instances = ["${google_compute_instance.nginx.*.self_link}"]
    health_checks = ["${google_compute_http_health_check.default.name}"]
}

resource "google_compute_forwarding_rule" "default" {
    name = "tf-www-forwarding-rule"
    target = "${google_compute_target_pool.default.self_link}"
    port_range = "80"
}

resource "google_compute_instance" "nginx" {
  description  = "template description"
  name         = "instance-1"
  machine_type = "f1-micro"
  zone         = "us-central1-c"

  tags = ["www-node"]

  disk {    
    image = "ubuntu-os-cloud/ubuntu-1404-lts"
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP : The Ip address will be available until the instance is alive, 
      // when the stack is destroy and apply again, the public Ip is a new one
    }
  }

  metadata {
    sshKeys = "ubuntu:${file(var.public_key_path)}"
  }

  connection {
    user     = "ubuntu"
    key_file = "${var.private_key_path}"
  }  

  //metadata_startup_script = "echo hi > /test.txt"
  metadata_startup_script = "${file("./bootstrap.sh")}"
}

resource "google_compute_firewall" "default" {
    name    = "tf-www-firewall"
    network = "default"

    allow {
      protocol = "tcp"
      ports    = ["80"]
    }

    source_ranges = ["0.0.0.0/0"]
    target_tags   = ["www-node"]
}

output "nginx_public_ip" {  
  value =
    "${google_compute_instance.nginx.network_interface.0.access_config.0.assigned_nat_ip}"
}

output "server_address" {
    value = "${google_compute_instance.nginx.0.network_interface.0.address}"
}
