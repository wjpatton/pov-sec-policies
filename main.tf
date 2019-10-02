terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "hashicorp-v2"
  }
}

variable "tfe_token" {}

variable "tfe_hostname" {
  description = "The domain where your TFE is hosted."
  default     = "app.terraform.io"
}

variable "tfe_organization" {
  description = "The TFE organization to apply your changes to."
  default     = "example_corp"
}

provider "tfe" {
  hostname = "${var.tfe_hostname}"
  token    = "${var.tfe_token}"
  version  = "~> 0.6"
}

data "tfe_workspace_ids" "all" {
  names        = ["*"]
  organization = "${var.tfe_organization}"
}

locals {
  workspaces = "${data.tfe_workspace_ids.all.external_ids}" # map of names to IDs
}

resource "tfe_policy_set" "global" {
  name         = "global"
  description  = "Policies that are be enforced on ALL infrastructure."
  organization = "${var.tfe_organization}"
  global       = true

  policy_ids = [
    "${tfe_sentinel_policy.allowed-working-hours.id}",
    "${tfe_sentinel_policy.aws-vpc-must-be-pmr-approved.id}",
    "${tfe_sentinel_policy.limit-proposed-monthly-cost.id}",
  ]
}

# PMR Policy:

resource "tfe_sentinel_policy" "aws-vpc-must-be-pmr-approved" {
  name         = "aws-vpc-must-be-pmr-approved"
  description  = "Limit AWS VPC creation to pre-approved modules"
  organization = "${var.tfe_organization}"
  policy       = "${file("./aws-vpc-must-be-pmr-approved.sentinel")}"
  enforce_mode = "hard-mandatory"
}

# General management policy:
resource "tfe_sentinel_policy" "allowed-working-hours" {
  name         = "allowed-working-hours"
  description  = "Only allow TF applies during specific working hours"
  organization = "${var.tfe_organization}"
  policy       = "${file("./working-hours.sentinel")}"
  enforce_mode = "soft-mandatory"
}

# Cost Estimation policy:

resource "tfe_sentinel_policy" "limit-proposed-monthly-cost" {
  name         = "limit-proposed-monthly-cost.sentinel"
  description  = "Limit Proposed Monthly Cost"
  organization = "${var.tfe_organization}"
  policy       = "${file("./limit-proposed-monthly-cost.sentinel")}"
  enforce_mode = "soft-mandatory"
}
