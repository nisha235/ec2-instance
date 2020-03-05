# **Udacity Bertelsmann Cloud Challenge Scholarship**

## **This repository contains all the iaac we wrote in lesson 19-22 using Terraform.**

### **Note:-**

There is one Creds.tf file missing in the repo.
Below is the structure for the same.

## **Creds.tf**

variable "aws_access_key" {
default = "<value>"
}

variable "aws_secret_key" {
default = "<value>"
}

variable "aws_region" {
default = "us-west-2"
}

## **To execute the below Iaac**

**1) Install terraform.**

    https://learn.hashicorp.com/terraform/getting-started/install.html
**2) Initialise it**

    terraform init
**3) See the plan**

    terraform plan
    
**4) Apply the plan**

    terraform apply

## **Reference:-**

For terraform :- https://www.terraform.io/intro/index.html


