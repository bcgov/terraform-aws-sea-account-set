

variable "account_email_domain" {
  type        = string
  description = "The domain to use as the suffix for the email accounts associated with the accounts created by the module. Don't change unless you know what you are doing. In other words, don't change."
}

variable "account_email_prefix" {
  type        = string
  description = "The prefix to use for the email accounts associated with the accounts created by the module. Don't change unless you know what you are doing. In other words, don't change."
}

variable "project" {
  description = "List of projects that product teams' workloads run within."
  type = object({
    identifier = string
    name       = string
    tags       = map(string)
    accounts = list(object({
      name               = string
      environment        = string
      enterprise_support = optional(string, null)
    }))
  })
}

variable "org_admin_role_name" {
  description = "The role name that will be created/set as the default cross-account admin role for accounts within an organization."
  type        = string
  default     = "OrganizationAccountAccessRole"
}

variable "close_on_deletion" {
  description = "true means that the account will be closed when it is deleted.  false means that the account be removed from the aws org when it is deleted."
  type        = bool
  default     = false
}

variable "master_account_id" {
  type        = string
  description = "Master Account Id"
}
