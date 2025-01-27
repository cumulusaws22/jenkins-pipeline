# Security Group resource creation


## Example resources ##
```
module "lyonsS3" {
  source            = "git::https://dev.azure.com/dmatter/Terraform%20Modules/_git/dmt-security-group?ref=v1.0.0"
  group_name        = "tfmodtestlyonsS3"
  group_description = "testing with ingress and egress"
  vpc_id            = var.vpc_id
  appid_tag         = "san"
  env_tag           = "dev"
  awsaccount_tag    = "testing sg mods"
  createdby_tag     = "e6102428"
  function_tag      = "module testing for ingress/egress"
  ingress = [{
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["10.165.161.0/26"]
  }]
  egress =[ {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }, {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }]
  extended_tags = {
      ATag = "ATagValue"
  }
}

module "no_rules" {
  source            = "git::https://dev.azure.com/dmatter/Terraform%20Modules/_git/dmt-security-group?ref=v1.0.0"
  group_name        = "tfmodtestlyonsS3_no_rules"
  group_description = "testing with no rules"
  vpc_id            = var.vpc_id
  appid_tag         = "san"
  env_tag           = "dev"
  awsaccount_tag    = "testing sg mods"
  createdby_tag     = "e6102428"
  function_tag      = "module testing no rules"
}
```