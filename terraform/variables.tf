variable "region" {
  type        = string
  description = "AWS region"
  default     = "ap-northeast-2"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "AZs to use (exactly 2개)"
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "tags" {
  type = map(string)
  default = {
    Project = "historynet"
    Managed = "terraform"
  }
}

variable "key_name" {
  type        = string
  description = "Existing EC2 key pair name"
  default     = "historykey"
}

# 인스턴스 타입
variable "bastion_instance_type" {
  type        = string
  default     = "t3.micro"
  description = "Bastion instance type"
}

variable "web_instance_type" {
  type        = string
  default     = "t3.micro"
  description = "Web instance type"
}

variable "was_instance_type" {
  type        = string
  default     = "t3.micro"
  description = "WAS instance type"
}
