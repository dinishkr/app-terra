locals {
  # Common tags to be assigned to all resources
  common_tags = {
    env = "${var.environment}"
    cloud  = "${var.cloud}"
  }
}