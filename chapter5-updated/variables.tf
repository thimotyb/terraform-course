variable "location" {
  type    = string
  default = "westus2"
}

variable "namespace" {
  type    = string
  default = "ballroominaction"
}

variable "subscription_id" {
  type        = string
  default     = null
  description = "ID della subscription Azure. Se null usa ARM_SUBSCRIPTION_ID."
}
