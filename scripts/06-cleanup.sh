#!/bin/bash

set -e

echo "======================================"
echo " IAM LAB CLEANUP"
echo "======================================"

POLICY_1="arn:aws:iam::YOUR_ACCOUNT_ID:policy/DevProjectPolicy"
POLICY_2="arn:aws:iam::YOUR_ACCOUNT_ID:policy/UploaderPolicy"

echo ""
echo "1. Removing users from groups..."

aws iam remove-user-from-group --user-name dev-user1 --group-name Developers || true
aws iam remove-user-from-group --user-name auditor-user1 --group-name Auditors || true
aws iam remove-user-from-group --user-name uploader-user1 --group-name Uploaders || true
aws iam remove-user-from-group --user-name finance-user1 --group-name Finance || true

echo ""
echo "2. Deleting lab users..."

aws iam delete-user --user-name dev-user1 || true
aws iam delete-user --user-name auditor-user1 || true
aws iam delete-user --user-name uploader-user1 || true
aws iam delete-user --user-name finance-user1 || true

echo ""
echo "3. Detaching custom policies..."

aws iam detach-group-policy \
  --group-name Developers \
  --policy-arn "$POLICY_1" || true

aws iam detach-group-policy \
  --group-name Uploaders \
  --policy-arn "$POLICY_2" || true

echo ""
echo "4. Deleting custom policy versions..."

for VERSION in $(aws iam list-policy-versions \
  --policy-arn "$POLICY_1" \
  --query 'Versions[?IsDefaultVersion==`false`].VersionId' \
  --output text 2>/dev/null || true)
do
    aws iam delete-policy-version \
      --policy-arn "$POLICY_1" \
      --version-id "$VERSION"
done

echo ""
echo "5. Deleting custom policies..."

aws iam delete-policy \
  --policy-arn "$POLICY_1" || true

aws iam delete-policy \
  --policy-arn "$POLICY_2" || true

echo ""
echo "6. Deleting IAM groups..."

aws iam delete-group --group-name Developers || true
aws iam delete-group --group-name Auditors || true
aws iam delete-group --group-name Uploaders || true
aws iam delete-group --group-name Finance || true

echo ""
echo "7. Removing EC2 role from instance profile..."

aws iam remove-role-from-instance-profile \
  --instance-profile-name EC2ProjectRole \
  --role-name EC2ProjectRole || true

echo ""
echo "8. Deleting instance profile..."

aws iam delete-instance-profile \
  --instance-profile-name EC2ProjectRole || true

echo ""
echo "9. Detaching role policy..."

aws iam detach-role-policy \
  --role-name EC2ProjectRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess || true

echo ""
echo "10. Deleting EC2 role..."

aws iam delete-role \
  --role-name EC2ProjectRole || true

echo ""
echo "======================================"
echo " IAM LAB CLEANUP COMPLETED"
echo "======================================"