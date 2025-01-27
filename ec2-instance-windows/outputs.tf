output "id_list" {
  description = "ID of EC2 instance created."
  value       = aws_instance.ec2.*.id
}

output "ami_list" {
  description = "The ID of the AMI used to launch the instance."
  value       = aws_instance.ec2.*.ami
}

output "arn_list" {
  description = "The ARN of the instance."
  value       = aws_instance.ec2.*.arn
}

output "availability_zone_list" {
  description = "The availability zone of the Instance."
  value       = aws_instance.ec2.*.availability_zone
}

output "instance_state_list" {
  description = "The state of the instance. One of: pending, running, shutting-down, terminated, stopping, stopped."
  value       = aws_instance.ec2.*.instance_state
}

output "instance_type_list" {
  description = "The type of the Instance."
  value       = aws_instance.ec2.*.instance_type
}

output "private_ip_list" {
  description = "The private IP address assigned to the Instance."
  value       = aws_instance.ec2.*.private_ip
}

output "security_group_list" {
  description = "The associated security groups."
  value       = aws_instance.ec2.*.security_groups
}

output "subnet_id_list" {
  description = "The VPC subnet ID."
  value       = aws_instance.ec2.*.subnet_id
}

output "account_id" {
  description = "The AWS Account ID number of the account that owns or contains the calling entity."
  value       = data.aws_caller_identity.current.account_id
}
