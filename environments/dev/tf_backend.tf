# tf_backend.tf

terraform {
  backend "s3" {
    bucket         = "BUCKETNAME-ue1"
    key            = "BUCKETNAME-ue1/PROJECTNAME/dev/tf.state"
    region         = "us-east-1"
    dynamodb_table = "BUCKETNAME-ue1-PROJECTNAME-dev"
  }
}
