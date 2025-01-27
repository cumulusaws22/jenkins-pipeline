resource "aws_security_group" "group" {
  count = var.conditional_create ? 1 : 0

  name        = var.group_name
  description = var.group_description
  vpc_id      = var.vpc_id
  dynamic "ingress" {
    for_each = var.ingress
    content {
      cidr_blocks      = lookup(ingress.value, "cidr_blocks", null)
      ipv6_cidr_blocks = lookup(ingress.value, "ipv6_cidr_blocks", null)
      prefix_list_ids  = lookup(ingress.value, "prefix_list_ids", null)
      from_port        = lookup(ingress.value, "from_port", null)
      protocol         = lookup(ingress.value, "protocol", null)
      security_groups  = lookup(ingress.value, "security_groups", null)
      self             = lookup(ingress.value, "self", null)
      to_port          = lookup(ingress.value, "to_port", null)
      description      = lookup(ingress.value, "description", null)
    }
  }
  dynamic "egress" {
    for_each = var.egress
    content {
      cidr_blocks      = lookup(egress.value, "cidr_blocks", null)
      ipv6_cidr_blocks = lookup(egress.value, "ipv6_cidr_blocks", null)
      prefix_list_ids  = lookup(egress.value, "prefix_list_ids", null)
      from_port        = lookup(egress.value, "from_port", null)
      protocol         = lookup(egress.value, "protocol", null)
      security_groups  = lookup(egress.value, "security_groups", null)
      self             = lookup(egress.value, "self", null)
      to_port          = lookup(egress.value, "to_port", null)
      description      = lookup(egress.value, "description", null)
    }
  }
  tags = merge(
    var.extended_tags,
    {
      Name       = lower(var.group_name)
      appid      = var.appid_tag
      env        = var.env_tag
      function   = var.function_tag
      awsaccount = var.awsaccount_tag
      createdby  = var.createdby_tag
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}
