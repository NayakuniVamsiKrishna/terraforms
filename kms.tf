resource "aws_kms_key" "logs_key" {
  # key does not have rotation enabled
  description = "315040492946-acme-dev-logs bucket key"

  deletion_window_in_days = 7
}

resource "aws_kms_alias" "logs_key_alias" {
  name          = "alias/315040492946-acme-dev-logs-bucket-key"
  target_key_id = "${aws_kms_key.logs_key.key_id}"
}
