locals {
  server_name = upper("Y${var.env_tag}${substr(var.aws_region, -1, -1)}${var.ec2_lane}${var.ec2_os_tag}${var.server_function}")
}

module "sg" {
  source = "git::https://dev.azure.com/dmatter/Terraform%20Modules/_git/dmt-security-group?ref=v1.0.0"

  group_name        = lower("${var.server_function}-${var.env_tag}-${var.location_tag}-sg")
  group_description = "${var.server_function} security group"
  vpc_id            = var.vpc_id
  function_tag      = "${var.server_function} security group"
  env_tag           = var.env_tag
  appid_tag         = var.appid_tag
  awsaccount_tag    = var.awsaccount_tag
  createdby_tag     = var.createdby_tag

  egress = local.egress_cidr
}

module "sgr-3389" {
  source            = "git::https://dev.azure.com/dmatter/Terraform%20Modules/_git/dmt-security-group-rule?ref=v1.0.0"
  security_group_id = module.sg.id
  description       = "Network Access"
  type              = "ingress"
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/8"]
}

module "sgr-443" {
  source            = "git::https://dev.azure.com/dmatter/Terraform%20Modules/_git/dmt-security-group-rule?ref=v1.0.0"
  security_group_id = module.sg.id
  description       = "Network Access"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/8"]
}


module "ec2" {
  source                    = "git::https://dev.azure.com/dmatter/Terraform%20Modules/_git/dmt-ec2-instance-windows?ref=v1.0.3"

  vpc_id                    = var.vpc_id
  ec2_server_count          = var.ec2_server_count
  instance_type             = var.ec2_instance_type
  aws_region                = var.aws_region
  function_tag              = var.server_function
  keyName                   = var.ec2_keyName
  iam_role                  = var.ec2_iam_instance_profile
  default_security_group_id = module.sg.id
  name_tag                  = tonumber(var.ec2_server_count) == 1 ? "${local.server_name}1" : local.server_name
  hostname_tag              = tonumber(var.ec2_server_count) == 1 ? "${local.server_name}1" : local.server_name
  ec2_root_volume_size      = var.ec2_root_volume_size
  ec2_data_volume_size      = var.ec2_data_volume_size
  appid_tag                 = var.appid_tag
  awsaccount_tag            = var.awsaccount_tag
  createdby_tag             = var.createdby_tag
  env_tag                   = var.env_tag
  os_tag                    = var.ec2_os_tag
  platform_tag              = var.ec2_platform_tag
  patchgroup_tag            = var.patchgroup_tag
  notes_tag                 = var.notes_tag
  application_segment_tag   = var.application_segment_tag
  spectrum_env_tag          = var.spectrum_env_tag
  disable_api_termination   = var.disable_api_termination
  ec2_root_volume_type      = var.ec2_root_volume_type
  ebs_volume_type           = var.ebs_volume_type
  extended_tags = {
    application = "Empower"
    Domain      = var.domain
    Tier        = "App"
  }
}
