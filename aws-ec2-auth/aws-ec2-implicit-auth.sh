# Bash script to be used in Azure DevOps release pipeline for ec2 build nodes
#  to get authentication from local VPC

# Clean variables
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
unset ACCOUNT_ID

# Call for ACCOUNT_ID
curl -s http://169.254.169.254/latest/meta-data/identity-credentials/ec2/info | jq -r '.AccountId' | awk '{print "export", "ACCOUNT_ID="$0}' > variables

# Call for INSTANCE_ID
curl -s http://169.254.169.254/latest/meta-data/instance-id | awk '{print "export", "INSTANCE_ID="$0}' >> variables

# Read account ID variables into global
. ./variables

# Assume role
aws sts assume-role --role-arn arn:aws:iam::$ACCOUNT_ID:role/AzureDevOpsAssumedIamRole --role-session-name "BuilderHostname=$INSTANCE_ID" > mysession.json

# Extract values from session, write to disk
jq -r '.Credentials.AccessKeyId' mysession.json | awk '{print "export", "AWS_ACCESS_KEY_ID="$0}' > variables
jq -r '.Credentials.SecretAccessKey' mysession.json | awk '{print "export", "AWS_SECRET_ACCESS_KEY="$0}' >> variables
jq -r '.Credentials.SessionToken' mysession.json | awk '{print "export", "AWS_SESSION_TOKEN="$0}' >> variables

# Read variables into global
. ./variables

# Delete variables file on disk
rm variables
