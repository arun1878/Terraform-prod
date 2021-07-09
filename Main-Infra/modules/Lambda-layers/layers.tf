data "aws_s3_bucket_object" "s3bucket" {
  bucket = var.bucket_name
  key    = var.s3_bucket_key
}

resource "aws_lambda_layer_version" "lambda_layer" {
  s3_bucket     = data.aws_s3_bucket_object.s3bucket.bucket
  s3_key        = data.aws_s3_bucket_object.s3bucket.key
  s3_object_version = data.aws_s3_bucket_object.s3bucket.version_id
  layer_name = var.layer_name
  compatible_runtimes = [var.runtime]
}