/*
 * outputs.tf
 * author: evan kirkiles
 * created on Sun Mar 05 2023
 * 2023 the nobot space, 
 */

output "db_password" {
  value     = module.db.db_instance_password
  sensitive = true
}

output "jatos_eip_public_dns" {
  value = aws_eip.main.public_dns
}

output "jatos_url" {
  value = var.ssl_enabled ? "https://${var.ssl_domain_name}" : "http://${aws_eip.main.public_dns}"
}