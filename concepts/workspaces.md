# Terraform Workspaces

## What is a Terraform Workspace?
- Terraform workspaces let you manage multiple deployments of the same configuration. 
- When you create cloud resources using Terraform's configuration language, they are created in the default workspace.
- Workspaces are handy tool for testing configurations, offering flexibility in resource allocation, regional deployments, multiple-account deployments, and more.
- Terraform stores information about all managed resources in a state file. It is important to store this file in a secured location. Every Terraform run is associated with a state file for validation and reference.
- Any modification to the Terraform configuration, Whether planned or applied, are validated against the state file first, and the result is updated back to it.
- If you are not using a workspace, all of this already happens in the default workspace. Workspaces help you isolate independent deployments of the same Terraform configuration while using the same state file.

## Terraform environment and Terraform Workspace
- A Terraform environment typically refers to the overall infrastructure setup, including all the configurations and resources that define it.
- A Workspace on the other hand, is a named state file that enables you to manage multiple isolated instances of the same infrastructure configuration.
- By keeping state files separate, workspaces he;p prevent conflicts and simplify the management of distinct deployments.

## How to use Terraform workspaces
- The `terraform workspace` command manages multiple state environments within a single configuration, allowing teams to maintain separate infrastructure state for stages like development, staging and production.

```bash
$ terraform workspace --help
Usage: terraform [global options] workspace

  new, list, show, select and delete Terraform workspaces.

Subcommands:
    delete    Delete a workspace
    list      List Workspaces
    new       Create a new workspace
    select    Select a workspace
    show      Show the name of the current workspace
```

## 1. Create an EC2 instance

The below terraform configuration will used to create an EC2 instance using the latest ubuntu-24 ami

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}


resource "aws_instance" "ubuntu" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  tags = {
    Name = var.name_tag
  }
}

```

## 2. Apply the terraform configuration

```bash
$ terraform apply -auto-approve
data.aws_ami.ubuntu: Reading...
data.aws_ami.ubuntu: Read complete after 1s [id=ami-0fc0d6e8d70ab2d42]

Terraform used the selected providers to generate the following
execution plan. Resource actions are indicated with the following
symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.ubuntu will be created
  + resource "aws_instance" "ubuntu" {
      + ami                                  = "ami-0fc0d6e8d70ab2d42"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + disable_api_stop                     = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + enable_primary_ipv6                  = (known after apply)
      + force_destroy                        = false
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + host_resource_group_arn              = (known after apply)
      + iam_instance_profile                 = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_lifecycle                   = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t3.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = (known after apply)
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_group_id                   = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + region                               = "us-east-1"
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + spot_instance_request_id             = (known after apply)
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "EC2"
        }
      + tags_all                             = {
          + "Name" = "EC2"
        }
      + tenancy                              = (known after apply)
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification (known after apply)

      + cpu_options (known after apply)

      + ebs_block_device (known after apply)

      + enclave_options (known after apply)

      + ephemeral_block_device (known after apply)

      + instance_market_options (known after apply)

      + maintenance_options (known after apply)

      + metadata_options (known after apply)

      + network_interface (known after apply)

      + primary_network_interface (known after apply)

      + private_dns_name_options (known after apply)

      + root_block_device (known after apply)

      + secondary_network_interface (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
aws_instance.ubuntu: Creating...
aws_instance.ubuntu: Still creating... [00m10s elapsed]
aws_instance.ubuntu: Creation complete after 17s [id=i-00c6910b4dae0cc74]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

## 3. View the Terraform workspace details
use the `terraform workspace` commandline to view the available workspaces post the successful terraform apply.

```
# used to show the current workspace
(base) Eswars-MacBook-Air:terraform-workspace eswarmaganti$ terraform workspace show
default

# used to list the available workspaces 
(base) Eswars-MacBook-Air:terraform-workspace eswarmaganti$ terraform workspace list
* default

```

## 4. Create a new workspace
We will create a new workspace which will use the same terraform configuration to create the resources

```bash
(base) Eswars-MacBook-Air:terraform-workspace eswarmaganti$ terraform workspace new test
Created and switched to workspace "test"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.

(base) Eswars-MacBook-Air:terraform-workspace eswarmaganti$ terraform workspace show
test

(base) Eswars-MacBook-Air:terraform-workspace eswarmaganti$ terraform workspace list
  default
* test
```

## Terraform Workspaces with Remote Backend
- When we create a new workspace, Terraform creates a corresponding new state file in the same remote backend that is configured initially. The backend being used should also be able to support the workspaces.
- When we look at the contents of the Terraform state S3 bucket, apart form our default `terraform.tfstate` file, we can see that a new directory named "env:/" is created, with another directory with the name of our workspace. A new terraform state file is maintained at this location.

```bash
$ aws s3 ls s3://terraform-s3-backend-9ulqtzat --recursive
2026-05-18 16:36:51        181 env:/test/terraform.tfstate
2026-05-18 16:36:33       9330 terraform.tfstate
```

- Looking at the size of the state files, the default state file is considerable larger than that of the `test` workspace specific state file.
- This shows that a new state file is created, but it does not hold any information from the default state file. This is how terraform creates an isolated environment and maintains its state file differently.
- The `terraform plan` does not specify the workspace information it uses during planning, so be very cautious when applying these changes, as using the wrong workspace may break the existing working environment.


## How to delete Terraform workspace
- To delete the workspace, first select a different workspace. In our case, we go back to the `default` workspace and run the delete command. Terraform does not let us delete the currently selected workspace.

```bash
(base) Eswars-MacBook-Air:terraform-workspace eswarmaganti$ terraform workspace list
  default
* test

(base) Eswars-MacBook-Air:terraform-workspace eswarmaganti$ terraform workspace select default
Switched to workspace "default".

(base) Eswars-MacBook-Air:terraform-workspace eswarmaganti$ terraform workspace delete test
Releasing state lock. This may take a few moments...
Deleted workspace "test"!
```

when we list the files in out s3 bucket, we could see the test workspace state file is deleted

```bash
(base) Eswars-MacBook-Air:terraform-learning eswarmaganti$ aws s3 ls s3://terraform-s3-backend-9ulqtzat --recursive
2026-05-18 16:36:33       9330 terraform.tfstate
```
- If you attempt to delete a workspace where certain resources are being managed by Terraform, it will not let you delete that workspace, suggesting using the `-force` option instead.

```bash
(base) Eswars-MacBook-Air:terraform-workspace eswarmaganti$ terraform workspace delete test
Releasing state lock. This may take a few moments...
╷
│ Error: Workspace is not empty
│ 
│ Workspace "test" is currently tracking the following resource instances:
│   - aws_instance.ubuntu
│ 
│ Deleting this workspace would cause Terraform to lose track of any associated remote objects, which
│ would then require you to delete them manually outside of Terraform. You should destroy these objects
│ with Terraform before deleting the workspace.
│ 
│ If you want to delete this workspace anyway, and have Terraform forget about these managed objects,
│ use the -force option to disable this safety check.
╵
```

- Using the `-force` option may not be a good idea as we will lose track of all the resources being managed by Terraform. A better option would be to select that workspace, run the destroy command, and then attempt to delete the workspace again.
- >Note: the `default` workspace cannot be deleted

## How to manage variables with Terraform workspaces
- managing variables with Terraform workspaces is essential when you need different configurations for different environments, like dev, test, stage and prod.
- First you need to declare the variables as you would normally do for any Terraform configuration. Providing values to these variables can be done easily by using tfvars files.
- For each environment, you can declare a tfvars file like

```bash
vars_dev.tfvars
vars_test.tfvars
vars_stage.tfvars
vars_prod.tfvars
```
- Based on the workspace you are on, you will run an apply like:
```bash
$ terraform apply -var-file=vars_dev.tfvars -auto-approve
```

## Terraform Workspace Interpolation
- Terraform provides an interpolation sequence to reference the value of the currently selected workspace, as shown below
- > `${terraform.workspace}`
- Let's use this to set our name tags according to the respective workspace being selected.

```hcl
resource "aws_instance" "ubuntu" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  tags = {
    Name = format("%s-%s", var.name_tag, terraform.workspace)
  }
}
```

- The same Name tag is applied to the EC2 Instances
```bash
$ aws ec2 describe-instances --query "Reservations[*].Instances[*].[Tags[?Key=='Name'].Value]"  --output text
EC2-default
EC2
EC2-test
```

## Environment Specific resource configuration using Terraform workspaces
- In the below example, we have used the workspace interpolation sequence to determine the number of EC2 instances to create based on the selected workspace. If the default workspace is selected, the given configuration would create three instances, and for all other workspaces, it would just create a single instance.

```hcl
resource "aws_instance" "ubuntu" {
  count         = terraform.workspace == "default" ? 3 : 1
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  tags = {
    Name = format("%s-%s-%s", var.name_tag, terraform.workspace, count.index)
  }
}
```

- After the terraform apply in `default` workspace three ec2 instances are crated

```bash
Plan: 2 to add, 1 to change, 0 to destroy.
aws_instance.ubuntu[2]: Creating...
aws_instance.ubuntu[1]: Creating...
aws_instance.ubuntu[0]: Modifying... [id=i-00bd5b701cbe867c2]
aws_instance.ubuntu[0]: Modifications complete after 5s [id=i-00bd5b701cbe867c2]
aws_instance.ubuntu[2]: Still creating... [00m10s elapsed]
aws_instance.ubuntu[1]: Still creating... [00m10s elapsed]
aws_instance.ubuntu[1]: Creation complete after 17s [id=i-036e672c7c7ccf4eb]
aws_instance.ubuntu[2]: Creation complete after 17s [id=i-07dc17039fa270eab]
Releasing state lock. This may take a few moments...

Apply complete! Resources: 2 added, 1 changed, 0 destroyed.
```