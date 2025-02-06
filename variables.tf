variable "vpc_id" {}
variable "aws_region" {}
variable "env_tag" {}
variable "server_function" {}
variable "server_farm" {}
variable "location_tag" {}
variable "appid_tag" {}
variable "awsaccount_tag" {}
variable "createdby_tag" {default = "Terraform"}
variable "notes_tag" {}
variable "application_segment_tag" {}
variable "spectrum_env_tag" {}
variable "ec2_lane" {}
variable "ec2_os_tag" {}
variable "ec2_platform_tag" {}
variable "ec2_server_count" {}
variable "ec2_instance_type" {}
variable "ec2_keyName" {}
variable "ec2_iam_instance_profile" {}
variable "ec2_root_volume_size" {}
variable "ec2_data_volume_size" {}
variable "ebs_volume_type" {}
variable "ec2_root_volume_type" {}
variable "patchgroup_tag" {}
variable "disable_api_termination" {}
variable "http_tokens" {}
variable "public_domain" {}
variable "private_domain" {}
variable "domain" {}
