data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  aws_partition = data.aws_partition.current.partition
  region        = data.aws_region.current.name
  account_id    = data.aws_caller_identity.current.account_id
}
