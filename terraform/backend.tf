terraform {
  backend "s3" {
    bucket = "terraform-state-demonstration"
    key    = "development/notifications"
    region = "us-east-1"
  }
}