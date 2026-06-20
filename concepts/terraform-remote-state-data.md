# terraform_remote_state data source

The `terraform_remote_state` data source uses the latest state snapshot from a specified state backend to retrieve the root module output values from sone other Terraform configuration.

You can use the `terraform_remote_state` data source without requiring or configuring a provider. It always available through a built-in provider with the source address `terraform.io/builtin/terraform`. That provider does not include any other resources or data sources.

## Alternative ways to share data between configurations

Sharing data with root module outputs is convenient, but it has drawbacks. Although `terraform_remote_state` only exposes output values, its user must have access to the entire state snapshot, which often includes some sensitive information.

When possible, we recommend explicitly publishing data for external consumption to a separate location instead of accessing it via remote state. This lets you apply different across controls for shared information and state snapshots.

A key advantage of using a separate explicit configuration store instead of `terraform_remote_state` is that the data can potentially also be ready by systems other than Terraform, such as configuration management or scheduler systems within your compute instances. For that reason, we recommend selecting a configuration store that your other infrastructure could potentially make use of. For example

- If you wish to share IP addresses and hostnames, you could publish them as normal DNS `A`, `AAAA`, `CNAME`, `SRV` records in a private DNS Zone and then configure your other infrastructure to refer to that zone so you can find infrastructure objects via your system's built-in DNS resolver.
- If you use HashiCorp Consul then publishing data to the Consul key/value store or Consul service catalog can make that data also accessible via Consul Template or the HashiCorp Nomad `template` stanza.
- If you use Kubernetes then you can make ConfigMaps available to your Pods.

Some of the data stores listed above are specifically designed for storing small configuration values, while others are generic blob storage systems. For those generic systems, you can use the `jsonencode` and the `jsondecode` function respectively to store and retrieve structured data.

## Example Usage (`remote` backend)

```terraform
data "terrafrom_remote_state" "vpc" {
  backend = "remote"
  
  config = {
    organization = "hashicorp"
    workspaces = {
      name = "vpc-prod"
    }
  }
}
```

## Example usage (`local` backend)
```terraform
data "terraform_remote_state" "vpc" {
  backend = "local"
  
  config = {
    path = "..."
  }
}

resource "aws_instance" "this" {
  subnet_id = data.terraform_remote_state.vpc.outputs.subnet_id
  # ...
}
```

## Argument Reference
The following arguments are supported
- `backend`: (required) the remote backend to use.
- `workspace`: (optional) The terraform workspace to use, if the backend supports workspaces.
- `config`: (optional) The configuration of the remote backend. Although this argument is listed as optional, most backends require some configuration.
- `defaults`: (optional) Default values for outputs, in case the state file is empty or lacks a required output.


## Attributes Reference
In addition to the above, the following attributes are exported
- `outputs`: an object containing every root-level output in the remote state


> Only the root-level output values from the remote state snapshot are exposed
> for use elasewhere in your module. Resource data and output values from nested modules are not accessible

> If you wish yo make a nested output accessible as a root module output value, 
> you must explicityly configure a passthrough in the root module.