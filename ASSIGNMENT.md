# Assignment: AWS Networking with Terraform

**Estimated time:** 3 to 5 hours. **Work:** individual. **Submit:** your modified repo plus a short reflection.

You have a working network from the README. Now the goal is to understand *why* it works and to extend it like an engineer would. There are three parts: deploy and verify, explain the design, then build the extensions yourself.

## Learning objectives

By the end you should be able to:

1. Describe how a VPC, subnets, an Internet Gateway, and a NAT Gateway fit together.
2. Explain the difference between a public and a private subnet in terms of routing, not just naming.
3. Use security groups to control access between tiers, including referencing one security group from another.
4. Reason about least-privilege network access (the bastion pattern) and cost.
5. Parameterize and scale Terraform using variables, and `count` or `for_each`.

## Part 0: Complete the To-Dos in the  `network.tf` and `security.tf`

## Part A: Deploy and verify

Follow the README to `init`, `plan`, `apply`, verify both SSH paths, and finally `destroy`. In your submission, include the output of `terraform output` from a successful apply (redact nothing except your own IP if you prefer).

## Part B: Explain the design (short answers)

Answer these in a file called `ANSWERS.md`. Point to specific resources in the `.tf` files where relevant.

1. What single routing difference makes the public subnet public and the private subnet private? Name the exact resources involved.
2. The NAT Gateway lives in the public subnet, not the private one. Why does it have to?
3. The private security group allows SSH using `security_groups` rather than `cidr_blocks`. What does that achieve that a CIDR rule could not do as cleanly?
4. Why is `my_ip_cidr` a required variable with no default, and what would be the risk of defaulting it to `0.0.0.0/0`?
5. The private instance has no public IP, yet `sudo dnf update` works on it. Trace the path a packet takes from the private instance to the internet and back.

## Part C: Extensions (build these)

This extension is a real change to the Terraform. Commit each as its own change with a clear message.

**C1. Add a web server and test reachability.** Use `user_data` to install and start a simple web server on the private instance, then reach it from the bastion using its private IP. Confirm it is not reachable from your laptop directly.

## Submission

1. Your repository with the extension commits.
2. `ANSWERS.md` (Part B and any extension discussion).
3. `REFLECTION.md` (half a page): what surprised you, what was hardest, and one thing you would add before running this in production.

## Rules

- Never open SSH (port 22) to `0.0.0.0/0`. Any submission that does loses marks.
- Always `terraform destroy` when you stop working. Leaving a NAT Gateway running costs real money.
- Keep secrets out of git: never commit `terraform.tfvars`, the `.pem` file, or state.
