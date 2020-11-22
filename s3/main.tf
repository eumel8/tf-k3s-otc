resource "opentelekomcloud_obs_bucket" "s3" {
  bucket     = var.bucket_name
  acl        = "private"
  versioning = true
}
