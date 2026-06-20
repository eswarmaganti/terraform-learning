# Terraform Lifecycle meta-argument

Terraform performs the following operations when you apply a configuration:
1. Creates resources defined in the configuration that re not associated with a real infrastructure object in the state.
2. Destroys resource that exist in the state but not in the configuration
3. Updates in-place resources whose arguments have changes
4. Destroys and re-creates resources whose arguments have changed but that Terraform cannot update in-place because of remote API limitations.
5. Invokes actions that are configured to run during an apply operation,

The `lifecycle` block accepts a rule that customizes how Terraform performs the lifecycle stages for each resource. Support for each `lifecycle` rule varies across Terraform configuration blocks. 

## State
Except for `create_before_destroy`, Terraform does not explicitly record a resource's `lifecycle` rule to state. As a result, Terraform destroys the actual infrastructure during an apply operation if you remove the resource's configuration, even if `prevent_destroy` is enabled. 

Terraform records the results of `precondition` and `postcondition` checks to state, but not the content of the blocks.


## Usage
All `lifecycle` settings affect how Terraform constructs and traverses the dependency graph. As a result, only literal values can be used because the processing happens too early for arbitrary expression evaluation.

Support for each lifecycle rule varies across Terraform configuration blocks. Depending upon the block you are configuring, you may be able to use one or more of the following rules.

### `action_trigger`
`action_trigger` directs Terraform to automatically invoke actions based on the conditions you specify. The `action_trigger` rule is a block that supports the following arguments

**Arguments**

- `events`: Required list of lifecycle events to invoke the action. You can declare the following events:
  - `before_create`: Invokes the specified actions before Terraform creates the resource
  - `after_create`: Invokes the specified actions after Terraform creates the resource.
  - `before_update`: Invokes the specified actions before updating the infrastructure to match the configuration.
  - `after_update`: Invokes the specified actions after updating the infrastructure to match the configuration.
- `condition`: Optional expression that must evaluate to `true` to invoke the action
- `actions`: Specifies an ordered list of actions to trigger when the `events` and `condition` arguments are met.

> You can use `action_trigger` in `resource` blocks

### `create_before_destroy`
By default, when Terraform must change a resource argument that cannot be updated in-place due to remote API limitations, Terraform destroys the existing object and then create a new replacement object with the new configured arguments. Use the `create_before_destroy` rule to instruct Terraform to create a replacement resource before destroying the current resource,

This is an opt-in behaviour because many remote object types have unique name requirements or other constraints that must be accommodated for both a new and an old object to exist concurrently. Some resource types offer special options to append a random suffix onto each object name to avoid collisions.

** `create_before_destroy` and resource dependencies**
Terraform propagates and applies `create_before_destory` behaviour to all resource dependencies. For example:
- `create_before_destroy` is enabled on resource `A` but not on resource `B`.
- Because resource `A` is dependent on resource `B`, Terraform enables `create_before_destory` for resource `B` implicitly by default and stores it to the state file.

As a result, you cannot override `create_before_destroy` to `false` on resource `B` because that would imply dependency cycles in the graph.

When the resource contains a provisioner that runs during the `destroy` operation settings `create_before_destroy` to `true` also prevents the provisioner from running.

> You can use `create_before_destroy` in `resource` blocks


### `prevent_destory`
When `prevent_destroy` is set to `true`, Terraform rejects plans that would destroy the infrastructure objects associated with the resource and returns an error. The argument must be present in the configuration. This rule doesn't prevent Terraform from destroying a resource if you remove its configuration.

Use this rule as protection against accidental replacing objects that may be costly to reproduce, such as database instances. Enabling `prevent_destroy`, however, makes certain configuration changes impossible to apply and prevents the `terraform destroy` command from operating once such objects are created. 

You can use `prevent_destroy` in `resource` blocks

### `ignore_changes`
By default, Terraform detects any difference in the current settings of a real infrastructure object and plans to update the remote objects to match configuration. Use the `ignore_changes` argument when a resource is created with references to data that may change in the future, but should not affect the resource after its creation.

In some rare cases, a remote object's settings are modified by processes outside of Terraform, which Terraform attempts to resolve on the next run. To let Terraform share management responsibilities of a single object with a separate process, the `ignore_changes` meta-argument specifies resource attributes that Terraform should ignore when planning updates to the associated remote object. 

Terraform considers the arguments corresponding to the given attributes names when planning a `create` operation, but are ignored when planning an `update` operation. The arguments are the relative address of the attribute in the resource. You  can reference map and list elements using index notation, such as `tags["name"] and `list[0]`

In the following example, Terraform ignores changes to `tags` so that a management agent can update them based on a rule set managed elsewhere:

```terraform
resource "aws_instance" "this" {
  # ...
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
```

Instead of a list of items, you can use the `all` keyword to instruct Terraform to ignore all attributes. As a result, Terraform can create and destroy the remote objects but will never propose updates to it.

Terraform only ignores attributes defines by the resource type. You can't apply `ignore_changes` to itself or to any other meta-arguments

> You can use `ignore_changes` in `resource` blocks


### `replace_triggered_by`
Terraform replaces the resource when any of the referenced resources or specified attributes change. Supply a list of expressions that reference managed resources, instances, or instance attributes.

When used in a resource that uses `count` or `for_each`, you can use `count.index` or `each.key` in the expression to reference specific instances of other resources that are configured with the same count or collection.

References trigger replacement in the following conditions:
- If the reference is to a resource with multiple instances, a plan to update or replace any instance triggers a replacement.
- If the reference is to a single resource instance, a plan to update or replace that instance triggers a replacement.
- If the reference is to a single attribute of a resource instance, any change to the attribute value triggers a replacement.

You can only reference managed resources in `replace_triggered_by` expressions. This lets you modify these expressions without forcing replacement. In the following example, Terraform replaces `aws_appautoscaling_target` each time this instance of `aws_ec2_service` is replaced.

```terraform
resource "aws_appautoscaling_target" "ec2_target" {
  # ....
  lifecycle {
    replace_triggered_by = [
      aws_ecs_service.svc.id
    ]
  }
}
```

`replace_triggered_by` allows only resource addresses because the decision is based on the planned actions for all the given resources. Plain values, such as local values or input variables, do not have planned actions of their own, but you can treat them with a resource-like lifecycle by using them with `terraform data` resource

> You can use `replace_triggered_by` in `resource` blocks


### `precondition`
Specifies a condition that terraform evaluates before creating the resource. The following arguments in the `precondition` block are required.

- **`condition`**: Expression that must return `true` for Terraform to proceed with an operation. You can refer to any other object in the same configuration scope unless the reference creates a cyclic dependency.
- **`error_message`**: Message that Terraform prints to the console if the `condition` returns `false`.

Terraform evaluates `precondition` blocks before evaluating the resource's configuration arguments. The `precondition` can take precedence over argument evaluation errors.

Terraform evaluates precondition blocks after evaluating `count` and `for_each` meta-arguments. As a result. Terraform can evaluate the `precondition` separately for each instance and makes the `each.key` and `count.index` objects available in the conditions.

You can include a `precondition` and `postcondition` block in the same resource. Do not add `precondition` blocks to a `resource` block and `data` block that represent the same object in the same configuration. Doing so may cause Terraform to ignore changes to the `data` block that result from changes in the `resource` block.

> You can use `precondition` in the following Terraform configuration blocks
> `data`
> `ephemeral`
> `resource`


### `postcondition`
Specifies a condition that Terraform evaluates after creating the resource. The following arguments in the `precondition` block are required.

**Arguments**:
- `condition`: Expression that must return `true` for Terraform to perform operations on downstream resources. You can refer to any other object in the same configuration scope unless the reference creates a cycli dependency.
- `error_message`: Message that Terraform prints to the console if the `condition` returns `false`.

Terraform evaluates `postcondition` blocks after planning and applying changes to the data source. Postcondition failures prevent changes to other resources that depend on the failing resource.

You can include a `postcondition` and `precondition` blocks in the same resource. Do not add `postcondition` blocks to a `resource` block and a `data` block that represent the same object in the same configuration. Doing so may cause Terraform to ignore changes to the `data` blocks that result from rhe changes in the `resource` block.

> You can use `postcondition` in the following Terraform blocks:
> `data`
> `ephemeral`
> `resource`


### `destroy`
Set to `false` to remove a resource from state without destroying the actual infrastructure. You can only use this rule in `removed` block.

```terraform
removed {
  lifecycle {
    destroy = false
  }
}
```

By default, Terraform removes the resource from state and destroys the actual resource. Set `destroy` to `false` to remove the resource from state without destroying the actual resource. This allows you to hand off management responsibilities to another tool or team after using Terraform for the initial provisioning.