module "dmt_brokerdigital_rhel_changehostname" {
  source = "git::terraform-aws-dmt-ssm-document"

  appid_tag      = var.appid_tag
  awsaccount_tag = var.awsaccount_tag
  createdby_tag  = var.createdby_tag
  env_tag        = var.env_tag
  function_tag   = "Command to change the hostname on brokerdigital EC2s"

  ContentFilename = "regional/ssm-documents/shared/DMT-BrokerDigital-RHEL-ChangeHostName.json"
  DocumentName    = "DMT-BrokerDigital-RHEL-ChangeHostName"
  DocumentType    = "Command"
  target_type     = var.target_type
}
