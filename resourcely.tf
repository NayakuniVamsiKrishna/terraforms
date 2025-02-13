resource "terraform_data" "resourcely_metadata" {
  input = {
     // this is not module version. this is resourcely schema version.
     version = 1
     modules = file(".terraform/modules/modules.json")
  }
}
