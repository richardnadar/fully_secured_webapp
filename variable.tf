variable "access_key" {
    type = string
    default = "your_access_key"
}
variable "secret_key" {
    type = string
    default = "your_secret_key"
}

variable "instance_count" {
  description = "Number of instances to launch"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = "t2.micro"
}

variable "wordpress_ami" {
    type = string
    description = "AMI ID of WordPress"
    default = "ami-000cbce3e1b899ebd"
}

variable "mysql_ami" {
    type = string
    description = "AMI ID of MySQL"
    default = "ami-0019ac6129392a0f2"
}

variable "key_name" {
    type = string
    description = "Key Name For Instance"
    // default = "hadoopkey"
}