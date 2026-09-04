#!/bin/bash

set -e

echo "Creating EC2 IAM role..."

cat > ec2-trust-policy.json <<'EOF'
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

# Create IAM role
aws iam create-role \
  --role-name EC2ProjectRole \
  --assume-role-policy-document file://ec2-trust-policy.json

echo "EC2ProjectRole created."

# Attach S3 read-only permissions to the role
aws iam attach-role-policy \
  --role-name EC2ProjectRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

echo "AmazonS3ReadOnlyAccess attached."

# Create instance profile
aws iam create-instance-profile \
  --instance-profile-name EC2ProjectRole

echo "Instance profile created."

# Add role to instance profile
aws iam add-role-to-instance-profile \
  --instance-profile-name EC2ProjectRole \
  --role-name EC2ProjectRole

echo "Role added to instance profile."

echo ""
echo "EC2 IAM role setup completed."

echo ""
echo "Role:"
aws iam get-role \
  --role-name EC2ProjectRole \
  --query 'Role.[RoleName,Arn]' \
  --output table

echo ""
echo "Instance Profile:"
aws iam get-instance-profile \
  --instance-profile-name EC2ProjectRole \
  --query 'InstanceProfile.[InstanceProfileName,Arn]' \
  --output table