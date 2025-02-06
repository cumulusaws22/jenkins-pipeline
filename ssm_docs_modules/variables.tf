variable "DocumentName" {
  description = "Name of the document that will show up in SSM"
  type        = string
}

variable "DocumentType" {
  description = "Specify one of the following document types: Command, Policy, Automation or Session"
  type        = string
}

variable "DocumentFormat" {
  description = "The format of the document. Valid document types include: JSON and YAML."
  type        = string
  default     = "JSON"
}

variable "ContentFilename" {
  description = "Name of the local file being loaded to SSM"
  type        = string
}

variable "appid_tag" {
  description = "The primary AppID that will use this resourece."
  type        = string
}

variable "env_tag" {
  description = "Environment(s) that this document will be referenced."
  type        = string
}

variable "awsaccount_tag" {
  description = "Account Name"
  type        = string
}

variable "function_tag" {
  description = "Function or purpose of the document."
  type        = string
}

variable "createdby_tag" {
  description = "e-number@lpsvcs.com"
  type        = string
}

variable "extended_tags" {
  type        = map(string)
  default     = {}
  description = "Key value map for additional user supplied tags"
}

variable "target_type" {
  description = "The target type which defines the kinds of resources the document can run on. For example, /AWS::EC2::Instance"
  type        = string
  default = "/"
}
