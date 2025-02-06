output "name" {
  value       = aws_ssm_document.doc.name
  description = "The name of the Systems Manager document."
}

output "document_format" {
  value       = aws_ssm_document.doc.document_format
  description = "Returns the document in the specified format. The document format can be either JSON or YAML. JSON is the default format."
}

output "arn" {
  value       = aws_ssm_document.doc.arn
  description = "The ARN of the document."
}

output "document_type" {
  value       = aws_ssm_document.doc.document_type
  description = "The type of the document."
}

output "content" {
  value       = aws_ssm_document.doc.content
  description = "The contents of the document."
}
