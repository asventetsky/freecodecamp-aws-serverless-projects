# Automatically find the root terragrunt.hcl and inherit its
# configuration
include {
  path = find_in_parent_folders()
}
