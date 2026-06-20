# Dynamic Blocks

Within top-level block constructs like resources, expressions can usually be used only when assigning a value to an argument using `name = expression` form. This covers many uses, but some resource types include repeatable nested blocks in their arguments, which typically represent separate objects that are related to (or embedded within ) the containing object.

for example, when we crate a security group we have ingress rules those are always a literal blocks
```terraform
resource "aws_security_group" "this" {
  name = "EC2 security group"
  description = "allows SSH, HTTP ingress"
  
  ingress {
    # the ingress block is always a literal block
  }
}
```

We can dynamically contract the literal blocks like `ingress` using a special `dynamic` block type, which is supported inside `resource`, `data`, `provider` and `provisioner` blocks

```terraform
resource "aws_security_group" "this" {
  name        = "Sample-SG"
  description = "The security group allows, inbound SSH (22) & HTTP (80) and outbound traffic"

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value["from_port"]
      to_port     = ingress.value["to_port"]
      protocol    = ingress.value["protocol"]
      cidr_blocks = ingress.value["cidr_blocks"]
    }
  }
}
```

A dynamic block acts much like a `for expression`, but produces nested blocks instead of a complex typed value. It iterates over a given complex value, and generates a nested block for each element of that complex value.
- The label of the dynamic block ("ingress" in the above example) specifies what kind of nested block to generate.
- The `for_each` argument provides the complex value to iterate over
- The `iterator` argument (optional) sets the name of the temporary variable that represents the current element of the complex value. If omitted, the name of the variable defaults to the label of the `dynamic` block ("ingress" in the above example)
- The `labels` argument (optional) is a list of strings that specifies the block labels, in order, to use for each generated block. You can use the temporary iterator variable in this value.
- The nested `content` block defines the body of each generated block. You can use the temporary iterator variable inside this block.

Since the `for_each` argument accepts any collection or structural value, you can use a `for` expression or splat expression to transform an existing collection.

The iterator object has two attributes
- `key` is the map key or list element index for the current element. If the `for_each` expression produces a set value then `key` is identical to `value` and should not be used.
- `value` is the value of the current element

A `dynamic` block can only generate arguments that belong to the resource type, data source, provider or provisioner being configured. It is not possible to generate meta-argument blocks such as `lifecycle` and `provisioner` blocks, since Terraform must process these before it is safe to evaluate expressions.

The `for_each` value must be a collection with one element per desired nested block. If you need to declare resource instances based on the nested data structure or combination of elements from multiple data structures you can use Terraform expressions and functions to derive a suitable value. 