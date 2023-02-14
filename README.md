
# <application_license_badge>
<!--- [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](./LICENSE) --->

# BC Gov Terraform Template

This repo provides a starting point for users who want to create valid Terraform modules stored in GitHub.  

## Third-Party Products/Libraries used and the licenses they are covered by
<!--- product/library and path to the LICENSE --->
<!--- Example: <library_name> - [![GitHub](<shield_icon_link>)](<path_to_library_LICENSE>) --->

## Project Status

- [x] Development
- [ ] Production/Maintenance

# Documentation

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lz_info"></a> [lz\_info](#module\_lz\_info) | github.com/BCDevOps/terraform-aws-sea-organization-info | v0.0.7 |

## Resources

| Name | Type |
|------|------|
| [aws_organizations_account.project_accounts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_email_domain"></a> [account\_email\_domain](#input\_account\_email\_domain) | The domain to use as the suffix for the email accounts associated with the accounts created by the module. Don't change unless you know what you are doing. In other words, don't change. | `string` | n/a | yes |
| <a name="input_account_email_prefix"></a> [account\_email\_prefix](#input\_account\_email\_prefix) | The prefix to use for the email accounts associated with the accounts created by the module. Don't change unless you know what you are doing. In other words, don't change. | `string` | n/a | yes |
| <a name="input_close_on_deletion"></a> [close\_on\_deletion](#input\_close\_on\_deletion) | true means that the account will be closed when it is deleted.  false means that the account be removed from the aws org when it is deleted. | `bool` | `false` | no |
| <a name="input_org_admin_role_name"></a> [org\_admin\_role\_name](#input\_org\_admin\_role\_name) | The role name that will be created/set as the default cross-account admin role for accounts within an organization. | `string` | `"OrganizationAccountAccessRole"` | no |
| <a name="input_project"></a> [project](#input\_project) | List of projects that product teams' workloads run within. | <pre>object({<br>    identifier = string<br>    name       = string<br>    tags       = map(string)<br>    accounts = list(object({<br>      name        = string<br>      environment = string<br>    }))<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_project_accounts"></a> [project\_accounts](#output\_project\_accounts) | n/a |
<!-- END_TF_DOCS -->

## Getting Started
<!--- setup env vars, secrets, instructions... --->

## Getting Help or Reporting an Issue
<!--- Example below, modify accordingly --->
To report bugs/issues/feature requests, please file an [issue](../../issues).


## How to Contribute
<!--- Example below, modify accordingly --->
If you would like to contribute, please see our [CONTRIBUTING](./CONTRIBUTING.md) guidelines.

Please note that this project is released with a [Contributor Code of Conduct](./CODE_OF_CONDUCT.md). 
By participating in this project you agree to abide by its terms.


## License
<!--- Example below, modify accordingly --->
    Copyright 2018 Province of British Columbia

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
