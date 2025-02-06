resource "aws_ssm_document" "doc" {
  name            = var.DocumentName
  document_format = var.DocumentFormat
  document_type   = var.DocumentType
  target_type     = var.target_type
  content         = file(var.ContentFilename)

  tags = merge(
    {
      Name       = var.DocumentName
      appid      = var.appid_tag
      env        = var.env_tag
      awsaccount = var.awsaccount_tag
      function   = var.function_tag
      createdby  = var.createdby_tag
  }, var.extended_tags)
}
