#!/bin/bash

echo "======================================"
echo " IAM GOVERNANCE VALIDATION TESTS"
echo "======================================"

echo ""
echo "1. Checking IAM Groups"
aws iam list-groups \
  --query 'Groups[].[GroupName,Arn]' \
  --output table

echo ""
echo "2. Checking IAM Users"
aws iam list-users \
  --query 'Users[].[UserName,Arn]' \
  --output table

echo ""
echo "3. Checking Group Memberships"

for GROUP in Developers Auditors Uploaders Finance
do
    echo ""
    echo "Group: $GROUP"

    aws iam get-group \
      --group-name "$GROUP" \
      --query 'Users[].[UserName]' \
      --output table
done

echo ""
echo "4. Checking Group Policies"

for GROUP in Developers Auditors Uploaders Finance
do
    echo ""
    echo "Policies attached to: $GROUP"

    aws iam list-attached-group-policies \
      --group-name "$GROUP" \
      --query 'AttachedPolicies[].[PolicyName,PolicyArn]' \
      --output table
done

echo ""
echo "5. Checking EC2 Role"

aws iam get-role \
  --role-name EC2ProjectRole \
  --query 'Role.[RoleName,Arn]' \
  --output table

echo ""
echo "6. Checking Instance Profile"

aws iam get-instance-profile \
  --instance-profile-name EC2ProjectRole \
  --query 'InstanceProfile.[InstanceProfileName,Arn]' \
  --output table

echo ""
echo "7. Checking Custom Policies"

aws iam list-policies \
  --scope Local \
  --query 'Policies[?PolicyName==`DevProjectPolicy` || PolicyName==`UploaderPolicy`].[PolicyName,Arn]' \
  --output table

echo ""
echo "======================================"
echo " VALIDATION COMPLETED"
echo "======================================"