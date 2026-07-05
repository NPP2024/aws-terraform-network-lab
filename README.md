# AWS Network Lab with Terraform

In this lab you will build a small but realistic AWS network with Terraform: a VPC, a public and a private subnet, and one EC2 instance in each. You will then prove the design works by connecting to the private instance through the public one.

You do not need to write any Terraform to get it running. Follow the steps below, watch it deploy, and verify it. The learning tasks come after, in `ASSIGNMENT.md`.

## What you are building

```
                          Internet
                             |
                     [ Internet Gateway ]
                             |
        VPC 10.0.0.0/16      |
   +-------------------------+--------------------------+
   |                         |                          |
   |   PUBLIC SUBNET 10.0.1.0/24        PRIVATE SUBNET 10.0.2.0/24
   |   +-------------------+             +-------------------+
   |   |  Bastion EC2      |             |  Private EC2      |
   |   |  public IP        |             |  no public IP     |
   |   |  SSH from your IP |  --SSH-->   |  SSH from bastion |
   |   +-------------------+             +---------+---------+
   |          |                                    |
   |   [ NAT Gateway ] <-------- outbound only -----+
   +-------------------------+--------------------------+
```

Key ideas: the public subnet routes to the internet through the Internet Gateway; the private subnet has no inbound internet access but reaches out through the NAT Gateway; and the private instance can only be reached by first landing on the bastion.

## Prerequisites

1. An AWS account you can create resources in.
2. The AWS CLI installed and configured with credentials: run `aws configure` and confirm with `aws sts get-caller-identity`.
3. Terraform 1.5 or newer: check with `terraform version`.
4. An SSH client (built in on macOS, Linux, and modern Windows).

## Step 1: Get the code and set your IP

From inside this project folder:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Find your public IP and put it in `terraform.tfvars` as a `/32` CIDR:

```bash
curl ifconfig.me
```

If that prints `203.0.113.4`, then your line in `terraform.tfvars` becomes:

```hcl
my_ip_cidr = "203.0.113.4/32"
```

This is the only value you must set. It ensures SSH is open to you and no one else.

## Step 2: Initialize

```bash
terraform init
```

This downloads the AWS, TLS, and local providers. You should see "Terraform has been successfully initialized."

## Step 3: Preview the plan

```bash
terraform plan
```

Read the summary at the bottom. You should see it plans to add roughly 15 resources: the VPC, two subnets, an Internet Gateway, a NAT Gateway and its Elastic IP, two route tables and their associations, two security groups, a key pair, and two EC2 instances.

## Step 4: Apply

```bash
terraform apply
```

Type `yes` when prompted. This takes a few minutes, mostly waiting on the NAT Gateway. When it finishes, Terraform prints your outputs, including two ready-to-use SSH commands.

## Step 5: Verify it works

First, connect to the bastion in the public subnet. Copy the `ssh_to_bastion` output value, or run:

```bash
terraform output -raw ssh_to_bastion
```

Paste the command it prints. Accept the host key prompt with `yes`. You are now on the public instance.

While on the bastion, confirm it has internet access:

```bash
curl -s https://checkip.amazonaws.com
```

Type `exit` to return to your own machine. Now reach the private instance by jumping through the bastion:

```bash
terraform output -raw ssh_to_private
```

Paste that command. It uses SSH `-J` (ProxyJump) to hop through the bastion automatically. Once on the private instance, prove it can reach the internet outbound through the NAT Gateway even though it has no public IP:

```bash
curl -s https://checkip.amazonaws.com   # returns the NAT gateway's IP
sudo dnf -y update --refresh            # works only because NAT provides egress
```

If both SSH connections succeed and the private instance can reach the internet, your network is correct.

## Step 6: Clean up (important)

The NAT Gateway and Elastic IP cost money for as long as they exist. When you are done, destroy everything:

```bash
terraform destroy
```

Type `yes`. Confirm in the AWS console that the resources are gone.

## Troubleshooting

- SSH to the bastion times out: your public IP probably changed (home IPs rotate). Re-run `curl ifconfig.me`, update `my_ip_cidr` in `terraform.tfvars`, and run `terraform apply` again.
- "Permission denied (publickey)": make sure you are using `ec2-user` (the default user on Amazon Linux 2023) and the generated `.pem` file.
- Cannot SSH to the private instance directly: that is expected. It has no public IP and only accepts SSH from the bastion. Use the `ssh_to_private` (ProxyJump) command.
- `terraform apply` fails on credentials: re-run `aws configure` and `aws sts get-caller-identity`.

When you are comfortable with the deploy-verify-destroy loop, open `ASSIGNMENT.md` for the learning tasks.
