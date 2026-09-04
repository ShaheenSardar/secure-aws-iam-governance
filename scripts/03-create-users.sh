#!/bin/bash

set -e

echo "Creating IAM users..."

# Create users
aws iam create-user --user-name dev-user1
aws iam create-user --user-name auditor-user1
aws iam create-user --user-name uploader-user1
aws iam create-user --user-name finance-user1

echo "Users created."

# Add users to groups
aws iam add-user-to-group \
  --user-name dev-user1 \
  --group-name Developers

aws iam add-user-to-group \
  --user-name auditor-user1 \
  --group-name Auditors

aws iam add-user-to-group \
  --user-name uploader-user1 \
  --group-name Uploaders

aws iam add-user-to-group \
  --user-name finance-user1 \
  --group-name Finance

echo "Users added to groups."

# Attach custom policies to groups
aws iam attach-group-policy \
  --group-name Developers \
  --policy-arn arn:aws:iam::YOUR_ACCOUNT_ID:policy/DevProjectPolicy

aws iam attach-group-policy \
  --group-name Uploaders \
  --policy-arn arn:aws:iam::YOUR_ACCOUNT_ID:policy/UploaderPolicy

echo ""
echo "IAM users and group memberships configured successfully."

echo ""
echo "Users:"
aws iam list-users \
  --query 'Users[?UserName==`dev-user1` || UserName==`auditor-user1` || UserName==`uploader-user1` || UserName==`finance-user1`].[UserName,Arn]' \
  --output table