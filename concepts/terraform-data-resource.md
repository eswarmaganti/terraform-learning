# terraform_data resource


The `terraform_data` resource type implements the standard resource lifecycle, but does not directly take any other actions. You can use the `terraform_data` resource without requiring or configuring a provider. It is always available through built-in provider with the source address `terraform.io/builtin/terraform`

The `terraform_data` resource is useful for string values which need to follow a manage resource lifecycle, and for triggering provisioners when there is no other logical managed resource in which to place them.


**Arguments**
- `input`: Specifies a value to store in the instance state. Terraform prints the values in the `output` attribute after running `terraform apply`. This is optional.
- `triggers_replace`: Specifies a value to store in the instance state. Terraform replaces the resource when the value changes. This is optional

**Attributes**:
- `id`: A string value unique to the resource instance.
- `output`: he computed value derived from the `input` argument. In plans where `output` is unknown, Terraform returns the same type of value used in the `input` argument.

## Examples

The following examples implement common patterns for using the `terraform_data` resource type:

### Provide data for the `replace_triggered_by` argument
The `replace_triggered_by` argument directive is one of the arguments you can add to the `lifecycle` meta-argument. You must specify resource address to use this argument because forcing replacement is based on the planned operations for all og the mentioned resources.

Plain data values, such as `local` values and `input` values, aren't valid in `replace_triggered_by`. Because `terraform_data` resources plan an action each time the `input` value changes, you can use this resource type to indirectly specify a plain value to trigger replacement.

```terraform
variable "revision"{
  default = 1
}

resource "terraform_data" "replacement" {
  input = var.revision
}

resource "aws_instance" "this" {
  # ...
  lifecycle {
    replace_triggered_by = [terraform_data.replacement]
  }
}

```

### Enable arbitrary operations
In the following example, the `terraform_data` resourcee serves as a container for arbitrary operations taken by the `provisioner "local-exec"` block.

```terraform
resource "aws_instance" "web" {
  
}

resource "aws_instance" "db" {
  
}

resource "terraform_data" "bootstrap" {
  triggers_replace = [
    aws_instance.web.id, 
    aws_instance.db.id
  ]
  
  provisioner "local-exec" {
    command = "bootstrap-hosts.sh"
  }
}
```