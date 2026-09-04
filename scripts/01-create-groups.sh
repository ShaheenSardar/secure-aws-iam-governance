#!/bin/bash

set -e

echo "Creating IAM groups..."

aws iam create-group --group-name Developers
aws iam create-group --group-name Auditors
aws iam create-group --group-name Uploaders
aws iam create-group --group-name Finance

echo ""
echo "IAM groups created successfully."

aws iam list-groups \
  --query 'Groups[?GroupName==`Developers` || GroupName==`Auditors` || GroupName==`Uploaders` || GroupName==`Finance`].[GroupName,Arn]' \
  --output table