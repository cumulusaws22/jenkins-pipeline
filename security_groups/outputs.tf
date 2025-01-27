output "id" {
  value       = length(aws_security_group.group) > 0 ? aws_security_group.group[0].id : null
  description = "The ID of the security group"
}

output "arn" {
  value       = length(aws_security_group.group) > 0 ? aws_security_group.group[0].arn : null
  description = "The ARN of the security group"
}

output "name" {
  value       = length(aws_security_group.group) > 0 ? aws_security_group.group[0].name : null
  description = "Role Name"
}

output "vpc_id" {
  value       = length(aws_security_group.group) > 0 ? aws_security_group.group[0].vpc_id : null
  description = "The VPC ID."
}

output "description" {
  value       = length(aws_security_group.group) > 0 ? aws_security_group.group[0].description : null
  description = "The description of the security group"
}

output "ingress" {
  value       = length(aws_security_group.group) > 0 ? aws_security_group.group[0].ingress : null
  description = "The ingress rules. See above for more."
}

output "egress" {
  value       = length(aws_security_group.group) > 0 ? aws_security_group.group[0].egress : null
  description = "The egress rules. See above for more."
}