
variable "subscription_id" {
  description = "Id of the subscription"
  type        = string
}
variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}
variable "resource_location_name" {
  type = string
}

variable "app_service_plan_name" {
  type = string
}
variable "app_service_plan_os" {
  type = string
}
variable "app_service_plan_sku" {
  type = string
}

variable "app_service_name" {
  type = string
}
variable "app_service_stack_dotnet_version" { type = string }
variable "sql_server_name" { type = string }
variable "sql_server_version" { type = string }
variable "sql_admin_login" { type = string }
variable "sql_admin_password" { type = string }
variable "sql_database_name" { type = string }
variable "sql_database_collation" { type = string }
variable "sql_database_license_type" { type = string }
variable "sql_database_sku" { type = string }
variable "sql_database_storage_account_type" { type = string }

variable "firewall_rule_name" { type = string }
variable "firewall_rule_start_ip" { type = string }
variable "firewall_rule_end_ip" { type = string }

variable "repo_URL" { type = string }
variable "repo_branch" { type = string }

