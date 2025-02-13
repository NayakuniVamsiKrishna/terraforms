# main.tf

resource "aws_s3_bucket" "campaigns-data-resource_fraMshbmm94dxGRa" {
  bucket = "campaigns-data-resource"
}

resource "aws_s3_bucket_public_access_block" "campaigns-data-resource_fraMshbmm94dxGRa" {
  bucket                  = aws_s3_bucket.campaigns-data-resource_fraMshbmm94dxGRa.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "campaigns-data-resource_fraMshbmm94dxGRa" {
  bucket = aws_s3_bucket.campaigns-data-resource_fraMshbmm94dxGRa.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "campaigns-data-resource_fraMshbmm94dxGRa" {
  bucket = aws_s3_bucket.campaigns-data-resource_fraMshbmm94dxGRa.id

  versioning_configuration {
    status = "Disabled"
  }
}
