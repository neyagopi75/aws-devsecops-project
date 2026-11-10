variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "aws-devsecops-eks"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_id" {
  description = "Existing VPC ID"
  type        = string
  default     = "vpc-0ff8c5869719e2e79"
}

variable "subnet_ids" {
  description = "Existing public subnet IDs for EKS"
  type        = list(string)
  default = [
    "subnet-0d3bb8ebab4a346a1",
    "subnet-019a4148ef04e05ef"
  ]
}

variable "node_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
  default     = "m7i-flex.large"
}

variable "desired_nodes" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "min_nodes" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 2
}

variable "max_nodes" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 2
}