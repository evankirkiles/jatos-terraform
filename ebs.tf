/*
 * ebs.tf
 * author: evan kirkiles
 * created on Sun Mar 05 2023
 * 2023 the nobot space, 
 */

/* ------------------------------ Study Assets ------------------------------ */

# EBS volume for Study Assets (HTML and CSS files)
resource "aws_ebs_volume" "study_assets" {
  availability_zone = var.aws_availability_zone
  size              = var.ebs_study_assets_size
}

# Attach the EBS volume to the JATOS EC2 instance
resource "aws_volume_attachment" "study_assets" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.study_assets.id
  instance_id = aws_instance.main.id
}

/* ----------------------------- Result Uploads ----------------------------- */

# EBS volume for Result Uploads (files provided by subjects)
resource "aws_ebs_volume" "result_uploads" {
  availability_zone = var.aws_availability_zone
  size              = var.ebs_result_uploads_size
  count             = var.result_uploads_enabled ? 1 : 0
}

# Attach the EBS volume to the JATOS EC2 instance
resource "aws_volume_attachment" "result_uploads" {
  device_name = "/dev/sdi"
  volume_id   = aws_ebs_volume.result_uploads[0].id
  instance_id = aws_instance.main.id
  count       = var.result_uploads_enabled ? 1 : 0
}
