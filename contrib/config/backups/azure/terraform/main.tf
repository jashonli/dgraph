variable "resource_group_name" {}
variable "storage_account_name" {}
variable "storage_container_name" { default = "dgraph-backups" }

## Create Resource Group, Storage Account Name, and Container
module "dgraph_backups" {
  source                 = "git::https://github.com/darkn3rd/simple-azure-blob.git?ref=v0.1"
  resource_group_name    = var.resource_group_name
  create_resource_group  = true
  storage_account_name   = var.storage_account_name
  create_storage_account = true
  storage_container_name = var.storage_container_name
}


## Create Docker and Helm Chart Values

#####################################################################
# Locals
#####################################################################

locals {
  minio_vars = {
    accessKey  = module.dgraph_backups.AccountName
    secretKey  = module.dgraph_backups.AccountKey
  }

  # minio_config  = templatefile("${path.module}/templates/values.minio_config.yaml.tmpl", local.minio_vars)
  # minio_secrets = templatefile("${path.module}/templates/values.minio_secrets.yaml.tmpl", local.minio_vars)
  minio_env     = templatefile("${path.module}/templates/minio.env.tmpl", local.minio_vars)
}

#####################################################################
# File Resources
#####################################################################
resource "local_file" "minio_env" {
  content         = local.minio_env
  filename        = "${path.module}/../minio.env"
  file_permission = "0644"
}
