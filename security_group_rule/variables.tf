variable "security_group_id" {
  description = "The security group to apply this rule to"
  type        = string
}

variable "description" {
  description = "Description of the rule"
  type        = string
  default     = null
}

variable "type" {
  description = "The type of rule being created, either `ingress` or `egress`"
  type        = string
}

variable "from_port" {
  description = "Lowest port in range"
  type        = number
}

variable "to_port" {
  description = "Highest port in range"
  type        = number
}

variable "protocol" {
  description = "The protocol: `tcp`, `udp`, or `all`"
  type        = string
}

variable "cidr_blocks" {
  description = "List of CIDR blocks. Cannot be specified with `source_security_group_id` or `prefix_list_ids`."
  type        = list(string)
  default     = null
}

variable "source_security_group_id" {
  description = "Security group to allow access to/from. Cannot be specified with `cidr_blocks` or `prefix_list_ids`."
  type        = string
  default     = null
}

variable "prefix_list_ids" {
  description = "Security group to allow access to/from VPC endpoints. Cannot be specified with `cidr_blocks` or `source_security_group_id`."
  type        = list(string)
  default     = null
}

variable "self" {
  description = "If true, the security group itself will be added as a source"
  type        = bool
  default     = null
}
