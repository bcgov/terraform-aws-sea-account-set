

variable account_email_domain {
	type = string
	description = "The domain to use as the suffix for the email accounts associated with the accounts created by the module. Don't change unless you know what you are doing. In other words, don't change."
}

variable account_email_prefix {
	type = string
	description = "The prefix to use for the email accounts associated with the accounts created by the module. Don't change unless you know what you are doing. In other words, don't change."
}


//project = {
//		identifier = "2xcrjw"
//		name = "Virtual Clinic"
//		accounts = [
//			{
//				name = "Tools"
//				environment = "tools"
//			},
//			{
//				name = "Dev"
//				environment = "dev"
//			},
//			{
//				name = "Test"
//				environment = "test"
//			},
//			{
//				name = "Prod"
//				environment = "prod"
//			}
//		]
//	}


variable "project" {
	description = "List of projects that product teams' workloads run within."
	type = object({
		identifier = string
		name = string
		accounts = list(object({
			name = string
			environment = string
		}))
	})
}
