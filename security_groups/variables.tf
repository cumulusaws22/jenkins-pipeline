variable "conditional_create" {
  type        = bool
  description = "set to false to prevent creation of resource"
  default     = true
}

variable "group_name" {
  description = "The name of the security group to create"
  type        = string
}

variable "group_description" {
  description = "The description of the group"
  type        = string
}

variable "vpc_id" {
  description = "The vpc to create the group in"
  type        = string
}

variable "ingress" {
  description = "The ingress rules to apply to the group"
  type        = list
  default     = []
}

variable "egress" {
  description = "The egress rules to apply to the group"
  type        = list
  default     = []
}

variable "appid_tag" {
  description = "The primary AppID that will use this resourece."
  type        = string
}

variable "env_tag" {
  description = "Environment(s) that this parameter will be referenced."
  type        = string
}

variable "function_tag" {
  description = "Function or purpose of the bucket."
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

variable "extended_tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map
  default     = {}
}