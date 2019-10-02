Setup
Log into TFE
Log into your TFE or pTFE environment and choose the organization you are working in
Create a workspace
Create a workspace called "sentinel_policies"

Configure VCS to point to your forked copy of the Producer-Repo, (default branch)

For the sentinel_policies workspace click on Settings > General >

TERRAFORM WORKING DIRECTORY set it to sentinel this will link to the sentinel sub directory in the parent repo
Configure the following Terraform variables for the workspace:

tfe_token
tfe_organization
tfe_hostname <app.terraform.io> or your pTFE host name
Configure the following Environment variables for the workspace:

CONFIRM_DESTROY < 1 >
IF YOU ARE A pTFE user PERFORM THIS STEP
In the root of the sentinel directory find the main.tf file
Modify main.tf
If you are using pTFE modify this stanza to include your hostname and organization
terraform {
  backend "remote" {
    hostname     = "<your_pTFE_hostname>"
    organization = "<your_org_name>"    
  }
} 
This demo is has some hardcoded values to reference workspaces pre-created via the Producer Consumer demo creation
While still in the main.tf Verify that you are using the workspace names the Producer demo repo set, find these sections to update with your workspace names
resource "tfe_policy_set" "production" {
  name         = "production"
  description  = "Policies that should be enforced on production infrastructure."
  organization = "${var.tfe_organization}"

  policy_ids = [
    "${tfe_sentinel_policy.aws-restrict-instance-type-prod.id}",
  ]

  workspace_external_ids = [
    "${local.workspaces["ExampleTeam-production"]}", 
  ]
}
The above stanza is used by the TFE provider to create a Sentinel policy set, in this case called "production"
The section workspace_external_ids = is used to add workspaces to the policy set that will be governed by the policies
Now we want to hardcode the name of the production workspace you created in the Producer Consumer demo build out
workspace_external_ids = [
    "${local.workspaces["ExampleTeam-production"]}",
  ]
Repeat this hardcode step for the resource "tfe_policy_set" "development"
workspace_external_ids = [
    "${local.workspaces["ExampleTeam-development"]}",
  ]
Repeat this hardcode step for the resource "tfe_policy_set" "development"
workspace_external_ids = [
    "${local.workspaces["ExampleTeam-staging"]}",
  ]
Repeat this hardcode step for the resource "tfe_policy_set" "sentinel"
workspace_external_ids = [
    "${local.workspaces["sentinel_policies"]}",
  ]
Commit the changes to the main.tf
Test the deployment of sentinel policies
When you committed the changes to the main.tf in the previous steps that would have kicked off a plan in your sentinel_policies workspace, or your workspace my still be sitting at the initial setup screen for the workspace
Note that commiting changes to the sentinel directory will also trigger plans on the Producer workspace but should not detect any infrastructure changes.
Queue a manual run of the sentinel_policies workspace
If you get a successful plan you are in good shape, now apply the run
Go to the Org Settings for TFE, click on Policies and Policy Sets links to review the sentinel policies created and the policiy sets
If you didn't get a successful apply verify the hardcoded values in the sentinel/main.tf file.
Now that you know the sentinel_policies workspace is functional clean up by running a destroy
In the sentinel_policies workspace click on Settings > Destruction and Deletion > Queue destroy Plan
You will demo the workspace VCS run later in your demo