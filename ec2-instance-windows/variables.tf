variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  description = "EC2 Instance Type."
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "The ami to build the instance from. Windows 2016 is the default."
  type        = string
  default     = ""
}

variable "ssm_agent_rpm_url" {
  description = "URL to download the ssm agent rpm."
  type        = string
  default     = "https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm"
}

variable "iam_role" {
  description = "IAM role to use"
  type        = string
  default     = "iam-role-profile"
}

variable "keyName" {
  description = "Name of the key to be attached to the instance."
  type        = string
}

variable "name_tag" {
  description = "Name for the instance."
  type        = string
}

variable "os_tag" {
  description = "Operating system. I.E. windows"
  type        = string
}

variable "appid_tag" {
  description = "Identifier for the application using the instance."
  type        = string
}

variable "env_tag" {
  description = "Environment(s) that this parameter will be referenced."
  type        = string
}

variable "patchgroup_tag" {
  description = "ScanOnly or Automatic"
  type        = string
  default     = "Automatic"
}

variable "hostname_tag" {
  description = "For Windows: If hostname_tag is not set, the hostname will default to W + first four account id + first 10 instance-id number ignoring first 2 char - Total 15 chars"
  type        = string
  default     = "false"
}

variable "platform_tag" {
  description = "The platform running on the instance. I.E. windows."
  type        = string
}

variable "awsaccount_tag" {
  description = "Account Name"
  type        = string
}

variable "createdby_tag" {
  description = "e-number@lpsvcs.com"
  type        = string
}

variable "function_tag" {
  description = "Function or purpose of the instance."
  type        = string
  default     = ""
}

variable "subnet_name" {
  description = "The name of the subnet to attach the instance to. Defaults to Private subnet 1A."
  type        = string
  default     = "Private subnet 1A"
}

variable "vpc_id" {
  description = "(Optional) The Id of the VPC."
  type        = string
  default     = ""
}

variable "bootstrap_windows" {
  description = "true or false choice to execute the SSM Automation document for windows."
  type        = string
  default     = "false"
}

variable "ec2_root_volume_size" {
  type        = string
  default     = "30"
  description = "The volume size for the root volume in GiB"
}

variable "ec2_root_volume_type" {
  type        = string
  default     = "gp2"
  description = "The type of data storage: standard, gp2, io1"
}

variable "ec2_root_volume_delete_on_termination" {
  default     = true
  description = "Delete the root volume on instance termination."
}

variable "default_security_group_id" {
  description = "The Id of the security group to attach to this instance. Use this or vpc_security_group_ids but not both."
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "The security groups to attach to this instance. Use this or default_security_group_id but not both."
  type        = list(string)
  default     = null
}

variable "ec2_server_count" {
  type        = number
  default     = 1
  description = "The number of servers to create"
}

variable "ec2_automation_document_name" {
  type        = string
  default     = "DMT-LaunchWindows"
  description = "The name of the automation document to invoke on creation"
}

variable "extended_tags" {
  type        = map(string)
  default     = {}
  description = "Key value map for additional user supplied tags"
}

variable "ec2_data_volume_size" {
  type        = number
  default     = 30
  description = "The volume size for the data volume in GiB"
}

variable "attach_elb" {
  type        = string
  default     = false
  description = "(Optional) Indicates if the EC2 instances should be automatically attached to an elb."
}

variable "elb_id" {
  type        = string
  default     = ""
  description = "(Optional) The elb id which will have the EC2 instances attached."
}

variable "subnet_id" {
  type        = string
  default     = ""
  description = "(Optional) The subnet id which will have the EC2 instances attached."
}

variable "lb_target_group_id" {
  description = "The target group id"
  default     = []
}

variable "lb_target_port" {
  description = "The port number to attach to"
  default     = []
}

variable "private_ip" {
  description = "Private IP address to associate with the instance."
  type        = string
  default     = null
}

variable "private_ips" {
  description = "A list of private IP address to associate with the instance in a VPC. Should match the number of instances."
  type        = list(string)
  default     = []
}

variable "division_tag" {
  type        = string
  description = "Examples: Corp, OT, DNA, etc"
  default  = "OT"
}

variable "application_segment_tag" {
  type        = string
  description = "Examples: Empower, Compass, DecisionSelect, HOps, TIO, etc"
}

variable "notes_tag" {
  type        = string
  description = "location of your support document"
}

variable "cpu_critical_alarm_actions" {
  type    = list(any)
  default = []
}

variable "cpu_critical_ok_actions" {
  type    = list(any)
  default = []
}

variable "cpu_critical_evaluation_periods" {
  type    = number
  default = 1
}

variable "cpu_critical_threshold" {
  type    = number
  default = 90
}

variable "cpu_critical_period" {
  type    = number
  default = 900
}

variable "cpu_warning_alarm_actions" {
  type    = list(any)
  default = []
}

variable "cpu_warning_ok_actions" {
  type    = list(any)
  default = []
}

variable "cpu_warning_evaluation_periods" {
  type    = number
  default = 1
}

variable "cpu_warning_threshold" {
  type    = number
  default = 85
}

variable "cpu_warning_period" {
  type    = number
  default = 900
}

variable "memory_critical_alarm_actions" {
  type    = list(any)
  default = []
}

variable "memory_critical_ok_actions" {
  type    = list(any)
  default = []
}

variable "memory_critical_evaluation_periods" {
  type    = number
  default = 2
}

variable "memory_critical_threshold" {
  type    = number
  default = 90
}

variable "memory_critical_period" {
  type    = number
  default = 900
}

variable "memory_warning_alarm_actions" {
  type    = list(any)
  default = []
}

variable "memory_warning_ok_actions" {
  type    = list(any)
  default = []
}

variable "memory_warning_evaluation_periods" {
  type    = number
  default = 1
}

variable "memory_warning_threshold" {
  type    = number
  default = 85
}

variable "memory_warning_period" {
  type    = number
  default = 900
}

variable "system_status_critical_alarm_actions" {
  type    = list(any)
  default = []
}

variable "system_status_critical_ok_actions" {
  type    = list(any)
  default = []
}

variable "system_status_critical_evaluation_periods" {
  type    = number
  default = 2
}

variable "system_status_critical_threshold" {
  type    = number
  default = 1
}

variable "system_status_critical_period" {
  type    = number
  default = 60
}

variable "instance_status_critical_alarm_actions" {
  type    = list(any)
  default = []
}

variable "instance_status_critical_ok_actions" {
  type    = list(any)
  default = []
}

variable "instance_status_critical_evaluation_periods" {
  type    = number
  default = 3
}

variable "instance_status_critical_threshold" {
  type    = number
  default = 0
}

variable "instance_status_critical_period" {
  type    = number
  default = 60
}

variable "diskspace_warning_alarm_actions" {
  type    = list(any)
  default = []
}

variable "diskspace_warning_ok_actions" {
  type    = list(any)
  default = []
}

variable "diskspace_warning_evaluation_periods" {
  type    = number
  default = 1
}

variable "diskspace_warning_threshold" {
  type    = number
  default = 10
}

variable "diskspace_warning_period" {
  type    = number
  default = 300
}

variable "diskspace_critical_alarm_actions" {
  type    = list(any)
  default = []
}

variable "diskspace_critical_ok_actions" {
  type    = list(any)
  default = []
}

variable "diskspace_critical_evaluation_periods" {
  type    = number
  default = 1
}

variable "diskspace_critical_threshold" {
  type    = number
  default = 5
}

variable "diskspace_critical_period" {
  type    = number
  default = 300
}

variable "cpu_critical_alarm_enabled" {
  type    = bool
  default = true
}

variable "cpu_warning_alarm_enabled" {
  type    = bool
  default = true
}

variable "memory_critical_alarm_enabled" {
  type    = bool
  default = true
}

variable "memory_warning_alarm_enabled" {
  type    = bool
  default = true
}

variable "system_status_critical_alarm_enabled" {
  type    = bool
  default = true
}

variable "instance_status_critical_alarm_enabled" {
  type    = bool
  default = true
}

variable "diskspace_critical_alarm_enabled" {
  type    = bool
  default = true
}

variable "diskspace_warning_alarm_enabled" {
  type    = bool
  default = true
}

variable "cpu_critical_alarm_to_spectrum" {
  type    = bool
  default = true
}

variable "cpu_warning_alarm_to_spectrum" {
  type    = bool
  default = true
}

variable "memory_critical_alarm_to_spectrum" {
  type    = bool
  default = true
}

variable "memory_warning_alarm_to_spectrum" {
  type    = bool
  default = true
}

variable "system_status_critical_alarm_to_spectrum" {
  type    = bool
  default = true
}

variable "instance_status_critical_alarm_to_spectrum" {
  type    = bool
  default = true
}

variable "diskspace_critical_alarm_to_spectrum" {
  type    = bool
  default = true
}

variable "diskspace_warning_alarm_to_spectrum" {
  type    = bool
  default = true
}

variable "cpu_critical_ok_to_spectrum" {
  type    = bool
  default = true
}

variable "cpu_warning_ok_to_spectrum" {
  type    = bool
  default = true
}

variable "memory_critical_ok_to_spectrum" {
  type    = bool
  default = true
}

variable "memory_warning_ok_to_spectrum" {
  type    = bool
  default = true
}

variable "system_status_critical_ok_to_spectrum" {
  type    = bool
  default = true
}

variable "instance_status_critical_ok_to_spectrum" {
  type    = bool
  default = true
}

variable "diskspace_critical_ok_to_spectrum" {
  type    = bool
  default = true
}

variable "diskspace_warning_ok_to_spectrum" {
  type    = bool
  default = true
}

variable "spectrum_env_tag" {
  description = "PROD, PREPROD, or NONPROD. NOTE: PROD or PREPROD for Production Spectrum"
  type        = string
  default     = "NONPROD"
}

variable "severity_tag_warning" {
  description = "The warning severity to attach to the alarms. Minor or Major"
  type        = string
  default     = "Minor"
}

############### Updates 4/7/2021 ##############################
variable "ebs_device_name" {
  type        = list(string)
  description = "Name of the EBS device to mount"
  default     = ["/dev/xvdb", "/dev/xvdc", "/dev/xvdd", "/dev/xvde", "/dev/xvdf", "/dev/xvdg", "/dev/xvdh", "/dev/xvdi", "/dev/xvdj", "/dev/xvdk", "/dev/xvdl", "/dev/xvdm", "/dev/xvdn", "/dev/xvdo", "/dev/xvdp", "/dev/xvdq", "/dev/xvdr", "/dev/xvds", "/dev/xvdt", "/dev/xvdu", "/dev/xvdv", "/dev/xvdw", "/dev/xvdx", "/dev/xvdy", "/dev/xvdz"]
}

variable "ebs_volume_count" {
  type        = number
  description = "Count of EBS volumes that will be attached to the instance"
  default     = 0
}

variable "ebs_volume_size" {
  type        = list(number)
  description = "Size of the EBS volume in gigabytes"
  default     = [10]
}

variable "kms_key_id" {
  type        = string
  default     = null
  description = "KMS key ID used to encrypt EBS volume. When specifying kms_key_id, ebs_volume_encrypted needs to be set to true"
}

variable "ebs_volume_type" {
  type        = string
  default     = "gp2"
  description = "The type of EBS volume. Can be standard, gp2, gp3, io1, io2, sc1 or st1. Default is gp2"
}

variable "tenancy" {
  description = "The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host."
  type        = string
  default     = "default"
}

variable "disable_api_termination" {
  description = "If true, enables EC2 Instance Termination Protection"
  type        = bool
  default     = false
}

variable "ebs_volume_iops" {
  description = "iops - (Optional) Amount of provisioned IOPS. Only valid for volume_type of io1, io2 or gp3."
  type        = number
  default     = 0
}

variable "http_endpoint" {
  description = "(Optional) Whether the metadata service is available. Valid values include enabled or disabled. Defaults to enabled."
  type        = string
  default     = "enabled"
}

variable "http_tokens" {
  description = " (Optional) Whether or not the metadata service requires session tokens, also referred to as Instance Metadata Service Version 2 (IMDSv2). Valid values include optional or required. Defaults to optional."
  type        = string
  default     = "required"
}

variable "http_put_response_hop_limit" {
  description = "(Optional) Desired HTTP PUT response hop limit for instance metadata requests. The larger the number, the further instance metadata requests can travel. Valid values are integer from 1 to 64. Defaults to 1."
  type        = number
  default     = 1
}
variable "Snapshot" {
  description = "Optional attribute to tag ebs volumes that need to be backed up with a DLM policy"
  type        = bool
  default     = false
}


############### Updates 4/7/2021 ##############################