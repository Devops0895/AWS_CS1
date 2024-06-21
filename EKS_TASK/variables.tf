variable "availability_zones" {
  type    = list(string)
  default = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "s3_bucket_name" {
  default = "ekss3ucket102989"
}

variable "sns_name" {
  default = "EKS-SNS"
}

variable "email_address" {
  default = "abc@gmail.com"
}

variable "sqs_name" {
  default = "my-queue"
}

# variable "env" {
#   default = "dev"
# }