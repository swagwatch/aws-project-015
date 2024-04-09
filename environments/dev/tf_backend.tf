# tf_backend.tf

terraform {
  backend "s3" {
    bucket         = "swagwatch-ue1"
    key            = "swatch-ue1/aws-project-007/dev/tf.state"
    region         = "us-east-1"
    dynamodb_table = "swagwatch-ue1-aws-project-007-dev"
  }
}
