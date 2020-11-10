terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "3.11.0"
		}
	}
}


module "lz_info" {
	source = "github.com/BCDevOps/terraform-aws-sea-organization-info"
}

locals {
	ous_by_name = {for ou in module.lz_info.workload_ous : lower(ou.name) => ou }
}


resource "aws_organizations_account" "project_accounts" {
	for_each = { for account in var.project.accounts : account.environment => account }
	role_name = var.org_admin_role_name
	name  = "${var.project.identifier}-${each.key}"
	email = "${var.account_email_prefix}-${var.project.identifier}-${each.key}@${var.account_email_domain}"
	parent_id = local.ous_by_name[each.key].id
	tags = {
		Project = var.project.name
		Environment = each.key
	}
}


