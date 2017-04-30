variable "region" {
	default = "us-central1"
}

variable "public_key_path" {
  description = "Path to the public part of SSH key"
}

variable "private_key_path" {
  description = "Path to the private part of SSH key"
}

variable "account_file_path" {
	description = "Path to the JSON file used to describe your account credentials"
}