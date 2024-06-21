variable "availability_zones" {
  type    = list(string)
  default = ["us-west-2a", "us-west-2b", "us-west-2c"] #need to update AZ according to the country
}

variable "subnet_names" {
  #type    = list(string)
  default = [] #should update the name accordingly
}

variable "instance_names" {
  type    = list(string)
  default = []
}


variable "region" {
  description = "region which we are working"
  default     = "us-west-2"
}


# key pair - Location to the SSH Key generate using openssl or ssh-keygen or AWS KeyPair
# variable "ssh_pubkey_file" {
#   description = "Path to an SSH public key"
#   default     = "~/.ssh/private-key.pub"
# }

# variable "vpc_security_group_ids" {
#   description = "for security groups"
#   default = []
# }

