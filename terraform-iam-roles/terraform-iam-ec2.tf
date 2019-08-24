##
# Terraform to build IAM policies, roles, trusts
##

# Define terraform provider
terraform {}

# Download any stable version in AWS provider of 2.19.0 or higher in 2.19 train
provider "aws" {
  region              = "us-east-1"
  version             = "~> 2.20.0"
}

# Creates an IAM role for local ec2 builder to connect as
resource "aws_iam_role" "ado_iam_implicit_role" {
  name = "AzureDevOpsImplicitIamRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  lifecycle {
    prevent_destroy = true
  }
}

# Create IAM policy to give implicit role permission to assume broad IAM Role
resource "aws_iam_policy" "ado_iam_role_permit_sts_assume" {
  name = "AzureDevOpsPolicyPermitStsAssume"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "${aws_iam_role.ado_iam_assumed_role.arn}"
    }
  ]
}
EOF

  lifecycle {
    prevent_destroy = true
  }
}

# Attach IAM assume role to policy
resource "aws_iam_role_policy_attachment" "ado_iam_attach_implicit_role_to_sts_assume_policy" {
  role       = "${aws_iam_role.ado_iam_implicit_role.name}"
  policy_arn = "${aws_iam_policy.ado_iam_role_permit_sts_assume.arn}"
  lifecycle {
    prevent_destroy = true
  }
}

# Create IAM instance profile so ec2 can associate to it
resource "aws_iam_instance_profile" "ado_iam_role_implicit_instance_profile" {
  name = "AzureDevOpsImplicitIamRole"
  role = "${aws_iam_role.ado_iam_implicit_role.name}"
}

# Create IAM role for ADO builder to assume
resource "aws_iam_role" "ado_iam_assumed_role" {
  name = "AzureDevOpsAssumedIamRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.ado_iam_implicit_role.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  lifecycle {
    prevent_destroy = true
  }
}

# Create broad IAM policy ADO to use to build, modify resources
resource "aws_iam_policy" "ado_iam_assumed_policy" {
  name = "AzureDevOpsAssumedIamPolicy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAllPermissions",
      "Effect": "Allow",
      "Action": [
        "*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
  lifecycle {
    prevent_destroy = true
  }
}

# Attach IAM assume role to policy
resource "aws_iam_role_policy_attachment" "ado_iam_attach_assumed_role_to_permissions_policy" {
  role       = "${aws_iam_role.ado_iam_assumed_role.name}"
  policy_arn = "${aws_iam_policy.ado_iam_assumed_policy.arn}"
  lifecycle {
    prevent_destroy = true
  }
}
