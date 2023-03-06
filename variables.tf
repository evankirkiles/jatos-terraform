/*
 * variables.tf
 * author: evan kirkiles
 * created on Thu Feb 23 2023
 * 2023 experimount 
 */


/* ---------------------------- TERRAFORM CONFIG ---------------------------- */

variable "prefix" {
  description = "A prefix to apply to all resources created"
  type        = string
  default     = "myapp"
}

variable "aws_region" {
  description = "The region in which the app will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "aws_availability_zone" {
  description = "A specific availability zone in the region to deploy to."
  type        = string
  default     = "us-east-1a"
}

/* --------------------------------- ROUTING -------------------------------- */

variable "ssl_enabled" {
  description = "When true, uses HTTPS configuration in nginx to provide SSL termination. Requires ssl_domain_name and ssl_register_email."
  type        = bool
  default     = false
}

variable "ssl_domain_name" {
  description = "Domain name which should have an A record rewriting to the EC2 instance's public EIP (IPv4 address), if ssl_emnabled is true."
  type        = string
  default     = "localhost"
}

variable "ssl_register_email" {
  description = "Email to register the LetsEncrypt SSL certificate under, if ssl_enabled is true."
  type        = string
  default     = ""
}
# validation on above two variables
locals {
  if_domain_name_given    = var.ssl_enabled && var.ssl_domain_name == "localhost" ? tonumber("SSL requires providing a domain name.") : 1
  if_register_email_given = var.ssl_enabled && var.ssl_register_email == "" ? tonumber("SSL requires a registration email.") : 1
}

/* -------------------------------- DB CONFIG ------------------------------- */

variable "db_username" {
  description = "Username for the Postgres instance"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "Instance class of the RDS instance for storing user data."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_size_gb" {
  description = "Size of the RDS t3 micro instance for study assets, in GiB"
  type        = number
  default     = 15
}

/* ----------------------------- STORAGE CONFIG ----------------------------- */

variable "ebs_study_assets_size" {
  description = "Size of the EBS Volume for study assets, in GiB"
  type        = number
  default     = 10
}

variable "ebs_result_uploads_size" {
  description = "Size of the EBS Volume for result uploads, in GiB"
  type        = number
  default     = 10
}

/* ------------------------------ JATOS CONFIG ------------------------------ */

variable "result_uploads_enabled" {
  description = "Enable study result file uploads? (Allocates EBS volume)"
  type        = bool
  default     = true
}