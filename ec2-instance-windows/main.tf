data "aws_caller_identity" "current" {}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

/*data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.selected.id
}*/

/*data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.selected.id

  tags = {
    Workload = "YES"
  }

}*/

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  tags = {
    Workload = "YES"
  }
}

data "aws_ami" "windows_2022" {
  owners      = ["amazon", "microsoft"]
  most_recent = true
  filter {
    name   = "is-public"
    values = ["true"]
  }
  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base*"] #["Windows_Server-2016-English-Full-Base*"]
  }
}

# check env for spectrum arg
locals {
  spectrumEnv            = data.aws_caller_identity.current.account_id
  vpc_security_group_ids = coalesce(var.vpc_security_group_ids, [var.default_security_group_id])
}

/*resource "null_resource" "unjoin_domain" {
  count = var.bootstrap_windows != "false" ? 1 : 0
  provisioner "local-exec" {
    when    = destroy
    command = "aws ssm send-command --instance-ids ${aws_instance.ec2[count.index].id} --document-name BKI-Windows-Unjoin-Domain --region ${var.aws_region}"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "sleep 60"
  }
}*/

resource "aws_instance" "ec2" {
  count                   = var.ec2_server_count
  ami                     = var.ami_id != null && var.ami_id != "" ? var.ami_id : data.aws_ami.windows_2022.id
  instance_type           = var.instance_type
  subnet_id               = var.subnet_id != null && var.subnet_id != "" ? var.subnet_id : element(tolist(data.aws_subnets.private.ids), count.index)
  vpc_security_group_ids  = local.vpc_security_group_ids
  iam_instance_profile    = var.iam_role
  key_name                = var.keyName
  private_ip              = length(var.private_ips) > 0 ? element(var.private_ips, count.index) : var.private_ip
  tenancy                 = var.tenancy
  disable_api_termination = var.disable_api_termination

  metadata_options {
    http_endpoint               = var.http_endpoint
    http_tokens                 = var.http_tokens
    http_put_response_hop_limit = var.http_put_response_hop_limit
  }

  root_block_device {
    volume_size           = var.ec2_root_volume_size
    volume_type           = var.ec2_root_volume_type
    delete_on_termination = var.ec2_root_volume_delete_on_termination
    encrypted             = true
  }

  lifecycle {
    # Don't allow Terraform to update volume tags, because if it does, it will
    # erase tags on volumes attached by aws_volume_attachment.
    ignore_changes = [
      volume_tags,
      ami,
      tags["map-migrated"],
      tags["map-migrated-app"]
    ]
  }

  volume_tags = {
    Name = "${var.hostname_tag}${var.ec2_server_count > 1 ? count.index + 1 : ""}-root-volume"
  }

  tags = merge(
    {
      Name               = "${var.name_tag}${var.ec2_server_count > 1 ? count.index + 1 : ""}"
      appid              = var.appid_tag
      env                = var.env_tag
      awsaccount         = var.awsaccount_tag
      createdby          = var.createdby_tag
      platform           = var.platform_tag
      os                 = var.os_tag
      "Patch Group"      = var.patchgroup_tag
      hostname           = "${var.hostname_tag}${var.ec2_server_count > 1 ? count.index + 1 : ""}"
      function           = var.function_tag
      Division           = var.division_tag
      ApplicationSegment = var.application_segment_tag
    }
  , var.extended_tags)

  #Override the hostname already set to instance id when user passes in a hostname
  #If no hostname provided set Hostname tag to W + first four account id + first 10 instance-id number ignoring first 2 char - Total 15 chars
  /*provisioner "local-exec" {
    command = <<EOT
    aws ec2 create-tags --region ${var.aws_region} --resources ${self.id} --tags Key=hostname,Value=${var.hostname_tag != "false" ? join("", ["${var.hostname_tag}${var.ec2_server_count > 1 ? count.index + 1 : ""}"]) : join("", ["W", substr(data.aws_caller_identity.current.account_id, 0, 4), substr(self.id, 2, 10)])}
    EOT
  }*/
}

# volume attachments (ddrive)
# not created if var.ec2_data_volume_snapshot_id == "none"
resource "aws_volume_attachment" "ebs_att" {
  count       = var.ec2_data_volume_size > 0 ? var.ec2_server_count : 0
  device_name = "/dev/sda2"
  volume_id   = aws_ebs_volume.ebs_vol[count.index].id
  instance_id = aws_instance.ec2[count.index].id
}

# volumes
# not created if var.ec2_data_volume_snapshot_id == "none"
resource "aws_ebs_volume" "ebs_vol" {
  count             = var.ec2_data_volume_size > 0 ? var.ec2_server_count : 0
  encrypted         = true
  availability_zone = aws_instance.ec2[count.index].availability_zone
  size              = var.ec2_data_volume_size
  tags = {
    Name     = "${var.hostname_tag}${var.ec2_server_count > 1 ? count.index + 1 : ""}-data-drive"
    Snapshot = var.Snapshot
  }
}

resource "aws_elb_attachment" "elb_attachment" {
  count    = var.attach_elb != "false" ? var.ec2_server_count : 0
  elb      = var.elb_id
  instance = aws_instance.ec2[count.index].id
}

################# update 4/7/2021 ##########################
resource "aws_ebs_volume" "addl" {
  count             = var.ebs_volume_count > 0 ? "${var.ec2_server_count * var.ebs_volume_count}" : 0
  availability_zone = aws_instance.ec2.*.availability_zone[floor(count.index / var.ebs_volume_count)]
  size              = var.ebs_volume_size[count.index % var.ebs_volume_count]
  type              = var.ebs_volume_type
  encrypted         = true
  kms_key_id        = var.kms_key_id
  iops              = (var.ebs_volume_type == "io1" || var.ebs_volume_type == "io2" || var.ebs_volume_type == "gp3") ? var.ebs_volume_iops : "0"
  tags = {
    Name     = "${var.hostname_tag}-addl-data-drive${count.index % var.ebs_volume_count}"
    Snapshot = var.Snapshot
  }
}

resource "aws_volume_attachment" "addl" {
  count       = var.ebs_volume_count > 0 ? "${var.ec2_server_count * var.ebs_volume_count}" : 0
  device_name = var.ebs_device_name[count.index % var.ebs_volume_count]
  volume_id   = aws_ebs_volume.addl.*.id[count.index]
  instance_id = aws_instance.ec2.*.id[floor(count.index / var.ebs_volume_count)]
}
################# update 4/7/2021 ##########################

locals {
  attachments = setproduct(var.lb_target_group_id, aws_instance.ec2[*].id)
}

resource "aws_lb_target_group_attachment" "lb_tg_attachment" {
  count = length(local.attachments)

  target_group_arn = local.attachments[count.index][0]
  target_id        = local.attachments[count.index][1]
  port             = var.lb_target_port[index(var.lb_target_group_id, local.attachments[count.index][0])]
}

/*resource "null_resource" "bootstrap_windows" {
  count = var.bootstrap_windows != "false" ? var.ec2_server_count : 0
  triggers = {
    ec2_ids = join(",", aws_instance.ec2.*.id)
  }
  provisioner "local-exec" {
    command = "sleep 60"
  }
  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.ec2[count.index].id} --region ${var.aws_region}"
  }
  provisioner "local-exec" {
    command = "sleep 30"
  }

  provisioner "local-exec" {
    command = "aws ssm start-automation-execution --parameters instanceIds=${aws_instance.ec2[count.index].id} --document-name ${var.ec2_automation_document_name} --region ${var.aws_region}"
  }
  depends_on = ["aws_instance.ec2"]

}*/

resource "aws_cloudwatch_metric_alarm" "cpu_critical" {
  count               = var.cpu_critical_alarm_enabled == true ? var.ec2_server_count : 0
  alarm_name          = "dmt-cw-cpuAlarmCritical-${data.aws_caller_identity.current.account_id}-${aws_instance.ec2[count.index].id}"
  alarm_description   = "Host Server: ${var.name_tag}${var.ec2_server_count > 1 ? count.index + 1 : ""} - High CPU Usage ${var.cpu_critical_threshold} percent over ${var.cpu_critical_period} secs"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.cpu_critical_evaluation_periods
  threshold           = var.cpu_critical_threshold
  period              = var.cpu_critical_period

  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"
  statistic   = "Average"

  dimensions = {
    InstanceId = aws_instance.ec2[count.index].id
  }

  alarm_actions = var.cpu_critical_alarm_to_spectrum == true ? concat([
    "arn:aws:sns:${var.aws_region}:${local.spectrumEnv}:dmt-spectrum-custom-alarm-metadata"
  ], var.cpu_critical_alarm_actions) : var.cpu_critical_alarm_actions

  ok_actions = var.cpu_critical_ok_to_spectrum == true ? concat([
    "arn:aws:sns:${var.aws_region}:${local.spectrumEnv}:dmt-spectrum-custom-alarm-metadata"
  ], var.cpu_critical_ok_actions) : var.cpu_critical_ok_actions

  tags = {
    Name               = "dmt-cw-cpuAlarmCritical-${data.aws_caller_identity.current.account_id}-${aws_instance.ec2[count.index].id}"
    appid              = var.appid_tag
    env                = var.env_tag
    awsaccount         = var.awsaccount_tag
    createdby          = var.createdby_tag
    function           = "High CPU Usage greater than ${var.cpu_critical_threshold} percent over ${var.cpu_critical_period} secs"
    Severity           = "Critical"
    Division           = var.division_tag
    ApplicationSegment = var.application_segment_tag
    Environment        = var.spectrum_env_tag
    Notes              = var.notes_tag
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_warning" {
  count               = var.cpu_warning_alarm_enabled == true ? var.ec2_server_count : 0
  alarm_name          = "dmt-cw-cpuAlarmWarning-${data.aws_caller_identity.current.account_id}-${aws_instance.ec2[count.index].id}"
  alarm_description   = "Host Server: ${var.name_tag}${var.ec2_server_count > 1 ? count.index + 1 : ""} - High CPU Usage ${var.cpu_warning_threshold} percent over ${var.cpu_warning_period} secs"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.cpu_warning_evaluation_periods
  threshold           = var.cpu_warning_threshold
  period              = var.cpu_warning_period

  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"
  statistic   = "Average"

  dimensions = {
    InstanceId = aws_instance.ec2[count.index].id
  }

  alarm_actions = var.cpu_warning_alarm_to_spectrum == true ? concat([
    "arn:aws:sns:${var.aws_region}:${local.spectrumEnv}:dmt-spectrum-custom-alarm-metadata"
  ], var.cpu_warning_alarm_actions) : var.cpu_warning_alarm_actions

  ok_actions = var.cpu_warning_ok_to_spectrum == true ? concat([
    "arn:aws:sns:${var.aws_region}:${local.spectrumEnv}:dmt-spectrum-custom-alarm-metadata"
  ], var.cpu_warning_ok_actions) : var.cpu_warning_ok_actions

  tags = {
    Name               = "dmt-cw-cpuAlarmWarning-${data.aws_caller_identity.current.account_id}-${aws_instance.ec2[count.index].id}"
    appid              = var.appid_tag
    env                = var.env_tag
    awsaccount         = var.awsaccount_tag
    createdby          = var.createdby_tag
    function           = "High CPU Usage greater than ${var.cpu_warning_threshold} percent over ${var.cpu_warning_period} secs"
    Severity           = var.severity_tag_warning
    Division           = var.division_tag
    ApplicationSegment = var.application_segment_tag
    Environment        = var.spectrum_env_tag
    Notes              = var.notes_tag
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_critical" {
  count               = var.memory_critical_alarm_enabled == true ? var.ec2_server_count : 0
  alarm_name          = "dmt-cw-memoryAlarmCritical-${data.aws_caller_identity.current.account_id}-${aws_instance.ec2[count.index].id}"
  alarm_description   = "Host Server: ${var.name_tag}${var.ec2_server_count > 1 ? count.index + 1 : ""} - High Memory Usage ${var.memory_critical_threshold} percent over ${var.memory_critical_period} secs"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.memory_critical_evaluation_periods
  threshold           = var.memory_critical_threshold
  period              = var.memory_critical_period

  namespace   = "CloudWatchAgent"
  metric_name = "MemoryUsed"
  statistic   = "Average"

  dimensions = {
    InstanceId = aws_instance.ec2[count.index].id
    objectname = "Memory"
  }

  alarm_actions = var.memory_critical_alarm_to_spectrum == true ? concat([
    "arn:aws:sns:${var.aws_region}:${local.spectrumEnv}:dmt-spectrum-custom-alarm-metadata"
  ], var.memory_critical_alarm_actions) : var.memory_critical_alarm_actions

  ok_actions = var.memory_critical_ok_to_spectrum == true ? concat([
    "arn:aws:sns:${var.aws_region}:${local.spectrumEnv}:dmt-spectrum-custom-alarm-metadata"
  ], var.memory_critical_ok_actions) : var.memory_critical_ok_actions

  tags = {
    Name               = "dmt-cw-memoryAlarmCritical-${data.aws_caller_identity.current.account_id}-${aws_instance.ec2[count.index].id}"
    appid              = var.appid_tag
    env                = var.env_tag
    awsaccount         = var.awsaccount_tag
    createdby          = var.createdby_tag
    function           = "High Memory Usage greater than ${var.memory_critical_threshold} percent over ${var.memory_critical_period} secs"
    Severity           = "Critical"
    Division           = var.division_tag
    ApplicationSegment = var.application_segment_tag
    Environment        = var.spectrum_env_tag
    Notes              = var.notes_tag
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_warning" {
  count               = var.memory_warning_alarm_enabled == true ? var.ec2_server_count : 0
  alarm_name          = "dmt-cw-memoryAlarmWarning-${data.aws_caller_identity.current.account_id}-${aws_instance.ec2[count.index].id}"
  alarm_description   = "Host Server: ${var.name_tag}${var.ec2_server_count > 1 ? count.index + 1 : ""} - High Memory Usage ${var.memory_warning_threshold} percent over ${var.memory_warning_period} secs"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.memory_warning_evaluation_periods
  threshold           = var.memory_warning_threshold
  period              = var.memory_warning_period

  namespace   = "CloudWatchAgent"
  metric_name = "MemoryUsed"
  statistic   = "Average"

  dimensions = {
    InstanceId = aws_instance.ec2[count.index].id
    objectname = "Memory"
  }

  alarm_actions = var.memory_warning_alarm_to_spectrum == true ? concat([
    "arn:aws:sns:${var.aws_region}:${local.spectrumEnv}:dmt-spectrum-custom-alarm-metadata"
  ], var.memory_warning_alarm_actions) : var.memory_warning_alarm_actions

  ok_actions = var.memory_warning_ok_to_spectrum == true ? concat([
    "arn:aws:sns:${var.aws_region}:${local.spectrumEnv}:dmt-spectrum-custom-alarm-metadata"
  ], var.memory_warning_ok_actions) : var.memory_warning_ok_actions

  tags = {
    Name               = "dmt-cw-memoryAlarmWarning-${data.aws_caller_identity.current.account_id}-${aws_instance.ec2[count.index].id}"
    appid              = var.appid_tag
    env                = var.env_tag
    awsaccount         = var.awsaccount_tag
    createdby          = var.createdby_tag
    function           = "High Memory Usage greater than ${var.memory_warning_threshold} percent over ${var.memory_warning_period} secs"
    Severity           = var.severity_tag_warning
    Division           = var.division_tag
    ApplicationSegment = var.application_segment_tag
    Environment        = var.spectrum_env_tag
    Notes              = var.notes_tag
  }
}

resource "aws_cloudwatch_metric_alarm" "system_status_critical" {
  count               = var.system_status_critical_alarm_enabled == true ? var.ec2_server_count : 0
  alarm_name          = "dmt-cw-systemStatusAlarmCritical-${data.aws_caller_identity.current.account_id}-${aws_instance.ec2[count.index].id}"
  alarm_description   = "Host Server: ${var.name_tag}${var.ec2_server_count > 1 ? count.index + 1 : ""} - instance recovery process has been triggered because of failed System Status Check"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.system_status_critical_evaluation_periods
  threshold           = var.system_status_critical_threshold
  period              = var.system_status_critical_period

  namespace   = "AWS/EC2"
  metric_name = "StatusCheckFailed_System"
  statistic   = "Minimum"

  dimensions = {
    InstanceId = aws_instance.ec2[count.index].id
  }

  alarm_actions = var.system_status_critical_alarm_to_spectrum == true ? concat([
    "arn:aws:sns:${var.aws_region}:${local.spectrumEnv}:dmt-spectrum-custom-alarm-metadata"
  ], var.system_status_critical_alarm_actions) : var.system_status_critical_alarm_actions

  ok_actions = var.system_status_critical_ok_to_spectrum == true ? concat([
    "arn:aws:sns:${var.aws_region}:${local.spectrumEnv}:dmt-spectrum-custom-alarm-metadata"
  ], var.system_status_critical_ok_actions) : var.system_status_critical_ok_actions

  tags = {
    Name               = "dmt-cw-instanceStatusAlarmCritical-${data.aws_caller_identity.current.account_id}-${aws_instance.ec2[count.index].id}"
    appid              = var.appid_tag
    env                = var.env_tag
    awsaccount         = var.awsaccount_tag
    createdby          = var.createdby_tag
    function           = "instance recovery process has been triggered because of failed System Status Check"
    Severity           = "Critical"
    Division           = var.division_tag
    ApplicationSegment = var.application_segment_tag
    Environment        = var.spectrum_env_tag
    Notes              = var.notes_tag
  }
}

resource "aws_cloudwatch_metric_alarm" "instance_status_critical" {
  count               = var.instance_status_critical_alarm_enabled == true ? var.ec2_server_count : 0
  alarm_name          = "dmt-cw-instanceStatusAlarmCritical-${data.aws_caller_identity.current.account_id}-${aws_instance.ec2[count.index].id}"
  alarm_description   = "Host Server: ${var.name_tag}${var.ec2_server_count > 1 ? count.index + 1 : ""} - Instance Status Check Failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.instance_status_critical_evaluation_periods
  threshold           = var.instance_status_critical_threshold
  period              = var.instance_status_critical_period

  namespace   = "AWS/EC2"
  metric_name = "StatusCheckFailed_Instance"
  statistic   = "Minimum"

  dimensions = {
    InstanceId = aws_instance.ec2[count.index].id
  }

  alarm_actions = var.instance_status_critical_alarm_to_spectrum == true ? concat([
    "arn:aws:sns:${var.aws_region}:${local.spectrumEnv}:dmt-spectrum-custom-alarm-metadata"
  ], var.instance_status_critical_alarm_actions) : var.instance_status_critical_alarm_actions

  ok_actions = var.instance_status_critical_ok_to_spectrum == true ? concat([
    "arn:aws:sns:${var.aws_region}:${local.spectrumEnv}:dmt-spectrum-custom-alarm-metadata"
  ], var.instance_status_critical_ok_actions) : var.instance_status_critical_ok_actions

  tags = {
    Name               = "dmt-cw-instanceStatusAlarmCritical-${data.aws_caller_identity.current.account_id}-${aws_instance.ec2[count.index].id}"
    appid              = var.appid_tag
    env                = var.env_tag
    awsaccount         = var.awsaccount_tag
    createdby          = var.createdby_tag
    function           = "Instance Status Check Failed"
    Severity           = "Critical"
    Division           = var.division_tag
    ApplicationSegment = var.application_segment_tag
    Environment        = var.spectrum_env_tag
    Notes              = var.notes_tag
  }
}

resource "aws_cloudwatch_metric_alarm" "diskspace_warning" {
  count               = var.diskspace_warning_alarm_enabled == true ? var.ec2_server_count : 0
  alarm_name          = "dmt-cw-diskSpaceWarning-${data.aws_caller_identity.current.account_id}-${aws_instance.ec2[count.index].id}"
  alarm_description   = "Host Server: ${var.name_tag}${var.ec2_server_count > 1 ? count.index + 1 : ""} - Less than ${var.diskspace_warning_threshold} percent of C Drive space available."
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.diskspace_warning_evaluation_periods
  threshold           = var.diskspace_warning_threshold
  period              = var.diskspace_warning_period


  namespace   = "CloudWatchAgent"
  metric_name = "FreeDiskSpace"
  statistic   = "Average"

  dimensions = {
    InstanceId = aws_instance.ec2[count.index].id
    instance   = "C:"
    objectname = "LogicalDisk"
  }

  alarm_actions = var.diskspace_warning_alarm_to_spectrum == true ? concat([
    "arn:aws:sns:${var.aws_region}:${local.spectrumEnv}:dmt-spectrum-custom-alarm-metadata"
  ], var.diskspace_warning_alarm_actions) : var.diskspace_warning_alarm_actions

  ok_actions = var.diskspace_warning_alarm_to_spectrum == true ? concat([
    "arn:aws:sns:${var.aws_region}:${local.spectrumEnv}:dmt-spectrum-custom-alarm-metadata"
  ], var.diskspace_warning_ok_actions) : var.diskspace_warning_ok_actions

  tags = {
    Name               = "dmt-cw-diskSpaceCritical-${data.aws_caller_identity.current.account_id}-${aws_instance.ec2[count.index].id}"
    appid              = var.appid_tag
    env                = var.env_tag
    awsaccount         = var.awsaccount_tag
    createdby          = var.createdby_tag
    function           = "Less than ${var.diskspace_warning_threshold} percent of C Drive space available"
    Severity           = var.severity_tag_warning
    Division           = var.division_tag
    ApplicationSegment = var.application_segment_tag
    Environment        = var.spectrum_env_tag
    Notes              = var.notes_tag
  }
}

resource "aws_cloudwatch_metric_alarm" "diskspace_critical" {
  count               = var.diskspace_critical_alarm_enabled == true ? var.ec2_server_count : 0
  alarm_name          = "dmt-cw-diskSpaceCritical-${data.aws_caller_identity.current.account_id}-${aws_instance.ec2[count.index].id}"
  alarm_description   = "Host Server: ${var.name_tag}${var.ec2_server_count > 1 ? count.index + 1 : ""} - Less than ${var.diskspace_critical_threshold} percent of C Drive space is available."
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.diskspace_critical_evaluation_periods
  threshold           = var.diskspace_critical_threshold
  period              = var.diskspace_critical_period


  namespace   = "CloudWatchAgent"
  metric_name = "FreeDiskSpace"
  statistic   = "Average"

  dimensions = {
    InstanceId = aws_instance.ec2[count.index].id
    instance   = "C:"
    objectname = "LogicalDisk"
  }

  alarm_actions = var.diskspace_critical_alarm_to_spectrum == true ? concat([
    "arn:aws:sns:${var.aws_region}:${local.spectrumEnv}:dmt-spectrum-custom-alarm-metadata"
  ], var.diskspace_critical_alarm_actions) : var.diskspace_critical_alarm_actions

  ok_actions = var.diskspace_critical_ok_to_spectrum == true ? concat([
    "arn:aws:sns:${var.aws_region}:${local.spectrumEnv}:dmt-spectrum-custom-alarm-metadata"
  ], var.diskspace_critical_ok_actions) : var.diskspace_critical_ok_actions

  tags = {
    Name               = "dmt-cw-diskSpaceCritical-${data.aws_caller_identity.current.account_id}-${aws_instance.ec2[count.index].id}"
    appid              = var.appid_tag
    env                = var.env_tag
    awsaccount         = var.awsaccount_tag
    createdby          = var.createdby_tag
    function           = "Less than ${var.diskspace_critical_threshold} percent of C Drive space is available"
    Severity           = "Critical"
    Division           = var.division_tag
    ApplicationSegment = var.application_segment_tag
    Environment        = var.spectrum_env_tag
    Notes              = var.notes_tag
  }
}
