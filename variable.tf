variable "aws_region" {
  type = string 
  default = "ap-southeast-2"
}
variable "ami_id" {
  default = "ami-0b8d527345fdace59" # Amazon Linux 2 example
}

variable "instance_type" {
  default = "t2.micro"
}
