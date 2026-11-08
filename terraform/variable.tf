variable "bucket_name" {
  description = "Globally unique S3 bucket name for this example"
  type        = string
  validation {
    condition      = length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
    error_message  = "bucket_name must be between 3 and 63 characters."
  }
}
