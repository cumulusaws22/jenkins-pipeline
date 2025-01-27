resource "aws_security_group_rule" "_" {
  security_group_id        = var.security_group_id
  description              = var.description
  type                     = var.type
  from_port                = var.from_port
  to_port                  = var.to_port
  protocol                 = var.protocol
  cidr_blocks              = var.cidr_blocks
  source_security_group_id = var.source_security_group_id
  prefix_list_ids          = var.prefix_list_ids
  self                     = var.self
}