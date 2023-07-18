variable "region" {
  type    = string
  default = "us-east-1"
}

variable "ami" {
  type    = string
  default = "ami-053b0d53c279acc90"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"

}

# Specify 3 availability zones
variable "availability_zone" {
  type = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# Specify 6 CIDR blocks that would be assigned to subnets within our VPC CIDR block ("10.0.0.0/16")
variable "cidr_blocks" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

# Specify the password for the RDS
variable "db_password" {
  description = "RDS root user password"
  type        = string
  default     = "password"
  sensitive   = true
}

# Specify the pem key for the EC2
variable "key_name" {
  type    = string
  default = "rid"
}
