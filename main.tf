module "lz_info" {
  source = "github.com/BCDevOps/terraform-aws-sea-organization-info?ref=v0.0.7"
}

locals {
  ous_by_name = { for ou in module.lz_info.workload_ous : lower(ou.name) => ou }
  entp_support_accounts = {
    for account in var.project.accounts : account.environment => {
      id                 = aws_organizations_account.project_accounts[account.environment].id,
      enterprise_support = account["enterprise_support"]
    } if account["enterprise_support"] != null
  }

  project_tags = lookup(var.project, "tags", {})
}

resource "aws_organizations_account" "project_accounts" {
  for_each  = { for account in var.project.accounts : account.environment => account }
  role_name = var.org_admin_role_name
  name      = "${var.project.identifier}-${each.key}"
  email     = "${var.account_email_prefix}-${var.project.identifier}-${each.key}@${var.account_email_domain}"
  parent_id = local.ous_by_name[each.key].id
  tags = merge({
    Project     = var.project.name
    Environment = each.key
    SSC_CBRID   = var.SSC_CBRID
  }, local.project_tags)

  close_on_deletion = var.close_on_deletion

  // necessary so we can import accounts into state if necessary.  without it, TF will "think" it needs to recreate the resource.  @see associated warning in AWS TF provider docs at https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account
  lifecycle {
    ignore_changes = [role_name, email]
  }
}

resource "null_resource" "enterprise_support" {
  for_each = local.entp_support_accounts
  triggers = {
    enterprise_support = each.value.enterprise_support
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
    temp_aws_config="temp_aws_config_${each.value.id}"
    temp_org_role="temp_org_role_${each.value.id}"
    trap 'rm -f "./$${temp_aws_config}"; rm -f "./$${temp_org_role}"' EXIT
    case_subject_enable="Please enable AWS Enterprise on ramp support on my account ${each.value.id}"
    case_subject_disable="Please disable AWS Enterprise on ramp support on my account ${each.value.id}"
    enterprise_support="${(self.triggers.enterprise_support)}"
    assume_org_role=$(aws sts assume-role --role-arn arn:aws:iam::${var.master_account_id}:role/AWSCloudFormationStackSetExecutionRole --role-session-name AWSCLI-Session)
    echo -e "[profile org_role]\naws_access_key_id = $(echo $assume_org_role | jq -r .Credentials.AccessKeyId)\naws_secret_access_key = $(echo $assume_org_role | jq -r .Credentials.SecretAccessKey)\naws_session_token = $(echo $assume_org_role | jq -r .Credentials.SessionToken)" > $${temp_org_role}

    if [ "${self.triggers.enterprise_support}" == "true" ]; then
        case_exists=$(AWS_CONFIG_FILE=./$${temp_org_role} aws support describe-cases --profile org_role --language en --region us-east-1 --query "cases[?subject=='$case_subject_enable']")
        # If the case exists, case_exists will not be an empty array
        if [ "$case_exists" != "[]" ]; then
          echo "A case to enable AWS Enterprise on ramp support on account ${each.value.id} already exists."            
        else
            # Assuming role
            if ! assume_role=$(aws sts assume-role --role-arn arn:aws:iam::${each.value.id}:role/AWSCloudFormationStackSetExecutionRole --role-session-name AWSCLI-Session); then
                echo "Failed to assume role AWSCloudFormationStackSetExecutionRole on account ${each.value.id}"                
            fi

            # Create a temporary AWS credentials configuration file
            echo -e "[profile temp]\naws_access_key_id = $(echo $assume_role | jq -r .Credentials.AccessKeyId)\naws_secret_access_key = $(echo $assume_role | jq -r .Credentials.SecretAccessKey)\naws_session_token = $(echo $assume_role | jq -r .Credentials.SessionToken)" > $${temp_aws_config}

            # Run the describe-services command to check if support is enabled
            if AWS_CONFIG_FILE=./$${temp_aws_config} aws support describe-services --profile temp --service-code-list "general-info" --region us-east-1 > /dev/null 2>&1; then
                echo "Support is already enabled for the account ${each.value.id}"
            else
                # Create a new support case as support is not enabled
                AWS_CONFIG_FILE=./$${temp_org_role} aws support create-case --profile org_role --subject "$case_subject_enable" --service-code "customer-account" --severity-code "normal" --category-code "other-account-issues" --communication-body "Please enable AWS Enterprise on ramp support on my account ${each.value.id}" --language "en" --cc-email-addresses "cloud.pathfinder@gov.bc.ca" --region us-east-1
                echo "Created a new case to enable AWS Enterprise on ramp support on account ${each.value.id}"
            fi
        fi
    elif [ "${self.triggers.enterprise_support}" == "false" ]; then
        case_exists=$(AWS_CONFIG_FILE=./$${temp_org_role} aws support describe-cases --profile org_role --language en --region us-east-1 --query "cases[?subject=='$case_subject_disable']")
        # If the case exists, case_exists will not be an empty array
        if [ "$case_exists" != "[]" ]; then
            echo "A case to disable AWS Enterprise on ramp support on account ${each.value.id} already exists."            
        else
            # Assuming role
            if ! assume_role=$(aws sts assume-role --role-arn arn:aws:iam::${each.value.id}:role/AWSCloudFormationStackSetExecutionRole --role-session-name AWSCLI-Session); then
                echo "Failed to assume role AWSCloudFormationStackSetExecutionRole on account ${each.value.id}"
            fi
            # Create a temporary AWS credentials configuration file
            echo -e "[profile temp]\naws_access_key_id = $(echo $assume_role | jq -r .Credentials.AccessKeyId)\naws_secret_access_key = $(echo $assume_role | jq -r .Credentials.SecretAccessKey)\naws_session_token = $(echo $assume_role | jq -r .Credentials.SessionToken)" > $${temp_aws_config}

            # Run the describe-services command to check if support is enabled
            if AWS_CONFIG_FILE=./$${temp_aws_config} aws support describe-services --profile temp --service-code-list "general-info" --region us-east-1 > /dev/null 2>&1; then
                echo "Support is enabled for the account ${each.value.id} opening a case to disable support"
                AWS_CONFIG_FILE=./$${temp_org_role} aws support create-case --profile org_role --subject "$case_subject_disable" --service-code "customer-account" --severity-code "normal" --category-code "other-account-issues" --communication-body "Please disable AWS Enterprise on ramp support on my account ${each.value.id}" --language "en" --cc-email-addresses "cloud.pathfinder@gov.bc.ca" --region us-east-1
                echo "Created a new case to disable AWS Enterprise on ramp support on account ${each.value.id}"
                
            else
                # since the command failed, support is already disabled
                echo "support is already disabled for account ${each.value.id}"
            fi
        fi
    else
        echo "Invalid support status. Please provide either 'true' or 'false'."
        exit 1
    fi
    EOT
  }

  depends_on = [aws_organizations_account.project_accounts]
}
