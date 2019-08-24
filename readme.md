A bash (.sh) script to be run from an AWS ec2 instance to assume an IAM role

Corresponding terraform config provided to build the IAM roles, including:
- Implicit role - assigned directly to an ec2 instance, has few permissions
- Assumed role - assumed via the above bash script, has higher permissions

More info at: https://www.kylermiddleton.com/2019/08/aws-iam-assuming-iam-role-from-ec2.html
