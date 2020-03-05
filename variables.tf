variable "environment" {
  type        = string
  description = "The id of the machine image (AMI) to use for the server."
}

variable "VpcCidr" {
  type        = string
  description = "The range of IP in cidr notation"
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "Please enter the IP range (CIDR notation) for the public subnet in the first Availability Zone"
  type        = string
  default     = "10.0.0.0/24"
}

variable "public_subnet_2_cidr" {
  description = "Please enter the IP range (CIDR notation) for the public subnet in the second Availability Zone"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_1_cidr" {
  description = "Please enter the IP range (CIDR notation) for the [private] subnet in the second Availability Zone"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_2_cidr" {
  description = "Please enter the IP range (CIDR notation) for the private subnet in the second Availability Zone"
  type        = string
  default     = "10.0.3.0/24"
}


