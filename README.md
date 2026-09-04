# 🔐 Secure AWS Environment with IAM Governance

A hands-on AWS Identity and Access Management (IAM) project demonstrating **least-privilege access, role-based permissions, policy governance, resource-level controls, access validation, and security testing** using the AWS Management Console and AWS CLI.

This project simulates a small production AWS environment with separate teams — **Developers, Auditors, Uploaders, and Finance** — each receiving only the permissions required for their responsibilities.

---

## 📌 Project Overview

The goal of this project is to design and implement a secure AWS IAM environment following real-world cloud security principles.

Instead of giving users broad administrative permissions, access is separated according to job responsibilities.

### IAM Structure

| Team             | IAM Group    | Purpose                                               |
| ---------------- | ------------ | ----------------------------------------------------- |
| 👨‍💻 Developers | `Developers` | Manage approved EC2 resources                         |
| 🔎 Auditors      | `Auditors`   | Read-only access for auditing                         |
| 📤 Uploaders     | `Uploaders`  | Upload files to an approved S3 location               |
| 💰 Finance       | `Finance`    | Access billing information without EC2 administration |

The environment also includes an EC2 IAM role that allows an EC2 instance to access approved S3 resources without storing long-term AWS credentials on the server.

---

# 🎯 Project Objectives

This project focuses on implementing the following AWS security practices:

* 🔐 Principle of Least Privilege
* 👥 Role-Based Access Control (RBAC)
* 🛡️ IAM group-based permission management
* 📜 Custom IAM policies
* 🚫 Explicit access restrictions
* 🏷️ Resource/tag-based authorization
* 🪣 S3 prefix-level access control
* 🖥️ EC2 permission boundaries through IAM policies
* 🔄 IAM roles for AWS workloads
* 🔑 Avoiding long-term credentials on EC2
* 🧪 Positive and negative permission testing
* 🔍 IAM configuration validation
* 🧹 Secure resource cleanup
* 💻 AWS CLI automation using Bash

---

# 🏗️ Architecture

```text
                         AWS Account
                              │
                              │
                    ┌─────────▼─────────┐
                    │       IAM         │
                    │ Governance Layer  │
                    └─────────┬─────────┘
                              │
          ┌───────────────────┼───────────────────┐
          │                   │                   │
          ▼                   ▼                   ▼
   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
   │ Developers  │     │  Auditors   │     │  Uploaders  │
   │    Group    │     │    Group    │     │    Group    │
   └──────┬──────┘     └──────┬──────┘     └──────┬──────┘
          │                   │                   │
          ▼                   ▼                   ▼
   EC2 permissions       Read-only access     S3 upload
   based on tags         for auditing         to approved
                                              prefix
                             
                    ┌─────────────────┐
                    │     Finance     │
                    │      Group      │
                    └────────┬────────┘
                             │
                             ▼
                    Billing information
                    without EC2 access


                    EC2 Workload
                         │
                         ▼
                ┌──────────────────┐
                │ EC2ProjectRole   │
                └────────┬─────────┘
                         │
                         ▼
                   Amazon S3
                Read-only access
```

---

# 🧩 AWS Services Used

| Service            | Purpose                                        |
| ------------------ | ---------------------------------------------- |
| **AWS IAM**        | Identity and access management                 |
| **Amazon EC2**     | Compute resources used for permission testing  |
| **Amazon S3**      | Storage and object-level authorization testing |
| **AWS CloudShell** | AWS CLI execution environment                  |
| **AWS STS**        | Identity verification                          |
| **AWS Billing**    | Finance permission validation                  |
| **AWS CLI**        | Automation and validation                      |
| **Bash**           | IAM deployment and cleanup scripts             |

---

# 👥 IAM Governance Model

The project follows a group-based access model.

```text
                    IAM Users
                       │
        ┌──────────────┼──────────────┐
        │              │              │
        ▼              ▼              ▼
   Developers      Auditors       Uploaders
        │              │              │
        ▼              ▼              ▼
   EC2 access      Read-only       S3 upload
   controls        auditing        controls

                    Finance
                       │
                       ▼
                 Billing access
                 EC2 restricted
```

Users receive permissions through their **IAM groups** rather than attaching individual policies unnecessarily.

This makes permissions easier to manage, audit, and revoke.

---

# 🔐 Least-Privilege Design

The project intentionally avoids giving every user administrator-level permissions.

For example:

### Developer

Developers can perform approved EC2 operations on designated resources but cannot freely manage every EC2 resource in the account.

### Auditor

Auditors receive read-only permissions and are prevented from performing administrative actions such as starting or stopping EC2 instances.

### Uploader

Uploaders can upload objects to the approved S3 location while access outside the permitted prefix is denied.

### Finance

Finance users can access billing-related information but are restricted from performing EC2 administrative operations.

This demonstrates the difference between:

```text
❌ Administrator Access
```

and:

```text
✅ Job-specific Least-Privilege Access
```

---

# 📜 IAM Policies

The repository contains custom IAM policies used during the project.

## `DevProjectPolicy.json`

Controls developer access to approved EC2 resources.

The policy demonstrates restrictions based on AWS resource attributes/tags rather than granting unrestricted EC2 administration.

---

## `UploaderPolicy.json`

Controls S3 access for the Uploaders group.

The policy is designed to demonstrate controlled access to an approved S3 location/prefix while preventing unauthorized access outside the permitted scope.

---

## `EC2S3AccessPolicy.json`

Defines permissions used by the EC2 workload for accessing Amazon S3.

The project uses an IAM role so that the EC2 workload can obtain temporary credentials through AWS rather than requiring static access keys to be stored on the instance.

---

# 🖥️ EC2 IAM Role

The project creates an IAM role:

```text
EC2ProjectRole
```

with an EC2 trust relationship.

### Trust Relationship

```text
EC2
 │
 │ AssumeRole
 ▼
EC2ProjectRole
 │
 ▼
S3 Permissions
```

This follows the AWS recommended pattern of assigning permissions to workloads through **IAM roles**.

The EC2 instance does not need a hard-coded access key and secret key inside application files or scripts.

---

# 🧪 Permission Testing

A major part of this project is validating that permissions work as designed.

Testing includes both:

### ✅ Positive Tests

Actions that **should succeed**.

Examples:

```text
Developer → Describe EC2
Developer → Start approved production EC2
Developer → Stop approved production EC2
Uploader → Upload to approved S3 prefix
EC2 Role → Access permitted S3 resources
Finance → Access billing information
```

### ❌ Negative Tests

Actions that **should be denied**.

Examples:

```text
Developer → Start unauthorized development EC2
Developer → Delete protected S3 object
Auditor → Start EC2
Uploader → Access unauthorized S3 prefix
Finance → Perform EC2 administrative operation
```

Expected denial:

```text
AccessDenied
```

These negative tests are especially important because they demonstrate that the security controls are actually enforcing the intended boundaries.

---

# 📸 Evidence & Screenshots

The `screenshorts/` directory contains evidence collected during implementation and testing.

The screenshots document:

* AWS account verification
* AWS region configuration
* IAM group creation
* IAM policy creation
* Policy attachment
* IAM users
* Group memberships
* MFA status
* EC2 resources
* S3 resources
* EC2 IAM role
* Trust policy
* Role permissions
* STS verification
* Developer permission tests
* Auditor denial tests
* Uploader restriction tests
* Finance restriction tests
* AWS resource cleanup
* Final verification

These screenshots provide visual evidence that the configuration and permission tests were performed.

---

# 📁 Repository Structure

```text
secure-aws-iam-governance/
│
├── README.md
│
├── policies/
│   ├── DevProjectPolicy.json
│   ├── EC2S3AccessPolicy.json
│   └── UploaderPolicy.json
│
├── scripts/
│   ├── 01-create-groups.sh
│   ├── 02-create-policies.sh
│   ├── 03-create-users.sh
│   ├── 04-create-role.sh
│   ├── 05-validation-tests.sh
│   └── 06-cleanup.sh
│
├── trust-policies/
│   └── ec2-trust-policy.json
│
└── screenshorts/
    ├── 01-aws-account-verification-cli.png
    ├── 02-aws-region-cli.png
    ├── ...
    └── 44-final-cleanup-verification.png
```

---

# ⚙️ Automation Scripts

The project includes Bash scripts for repeatable IAM deployment and validation.

## 01 — Create Groups

```bash
./scripts/01-create-groups.sh
```

Creates:

```text
Developers
Auditors
Uploaders
Finance
```

---

## 02 — Create Policies

```bash
./scripts/02-create-policies.sh
```

Creates the custom IAM policies required by the project.

---

## 03 — Create Users

```bash
./scripts/03-create-users.sh
```

Creates test IAM users and assigns them to their appropriate groups.

---

## 04 — Create EC2 Role

```bash
./scripts/04-create-role.sh
```

Creates:

```text
EC2ProjectRole
```

and configures the EC2 trust relationship and instance profile.

---

## 05 — Validation Tests

```bash
./scripts/05-validation-tests.sh
```

Validates:

* IAM groups
* IAM users
* Group memberships
* Attached policies
* IAM role
* Instance profile
* Custom policies

---

## 06 — Cleanup

```bash
./scripts/06-cleanup.sh
```

Removes the temporary IAM resources created for the lab.

The cleanup script is designed to remove only the resources associated with this project rather than unrelated AWS infrastructure.

---

# 🔍 Validation Approach

The project uses a combination of:

```text
AWS Console
     +
AWS CLI
     +
Positive Tests
     +
Negative Tests
     +
Screenshot Evidence
```

This provides multiple ways to verify the IAM configuration.

---

# 💻 Example AWS CLI Validation

Verify the current AWS identity:

```bash
aws sts get-caller-identity
```

List IAM groups:

```bash
aws iam list-groups
```

List IAM users:

```bash
aws iam list-users
```

Check a user's group membership:

```bash
aws iam list-groups-for-user --user-name USERNAME
```

List policies attached to a group:

```bash
aws iam list-attached-group-policies --group-name Developers
```

Check an IAM role:

```bash
aws iam get-role --role-name EC2ProjectRole
```

These commands were used to validate the deployed IAM configuration.

---

# 🛡️ Security Principles Demonstrated

## 1. Principle of Least Privilege

Users receive only the permissions required for their responsibilities.

## 2. Role-Based Access Control

Permissions are organized around teams and responsibilities.

## 3. Separation of Duties

Developer, audit, upload, and finance responsibilities are separated.

## 4. Workload Identity

EC2 uses an IAM role instead of storing long-term credentials.

## 5. Explicit Authorization Boundaries

Policies restrict access to specific resources, tags, or S3 prefixes where applicable.

## 6. Continuous Validation

Both allowed and denied operations are tested.

## 7. Secure Cleanup

Temporary IAM resources are removed after testing.

---

# 🚨 Security Considerations

This repository is intended as a **learning and portfolio project**.

Before deploying similar configurations in production:

* Review every IAM policy carefully.
* Avoid using wildcard permissions unless required.
* Enable MFA for human users where appropriate.
* Prefer IAM roles and temporary credentials over long-term access keys.
* Use AWS CloudTrail for API activity monitoring.
* Consider AWS Organizations and Service Control Policies for multi-account environments.
* Use IAM Access Analyzer to identify unintended access.
* Review permissions regularly.
* Never commit AWS access keys, secret keys, passwords, or other credentials to GitHub.

> **No AWS secret access keys or passwords should be stored in this repository.**

---

# 🧹 Cleanup

After completing the tests, the temporary IAM resources created specifically for this lab were removed.

Cleanup includes resources such as:

```text
Test IAM users
Test IAM groups
Custom IAM policies
EC2ProjectRole
Instance profile
```

AWS-managed policies and unrelated existing AWS resources are not deleted by the cleanup process.

---

# 📚 What I Learned

Through this project, I gained hands-on experience with:

* AWS IAM architecture
* IAM users and groups
* IAM policies
* IAM roles
* Trust policies
* Instance profiles
* EC2 permissions
* S3 permissions
* Resource-level authorization
* Tag-based authorization
* S3 prefix-based access
* AWS STS
* AWS CLI
* Bash automation
* Permission troubleshooting
* AccessDenied analysis
* Positive and negative security testing
* IAM governance
* Secure resource cleanup

Most importantly, the project helped me understand that **AWS security is not simply about giving users access — it is about controlling exactly what they can and cannot do.**

---

# 🎓 Skills Demonstrated

### AWS

`IAM` `EC2` `S3` `STS` `CloudShell` `Billing`

### Security

`Least Privilege` `RBAC` `IAM Governance` `Access Control` `Trust Policies`

### Automation

`AWS CLI` `Bash` `Shell Scripting`

### Operations

`Validation` `Troubleshooting` `Permission Testing` `Resource Cleanup`

---

# 🚀 Future Improvements

Possible future enhancements include:

* Add AWS CloudTrail monitoring
* Add IAM Access Analyzer
* Add AWS Config rules
* Add automated policy validation
* Add CI/CD validation for IAM JSON policies
* Add Terraform infrastructure-as-code
* Add automated security checks
* Add centralized logging
* Add AWS Organizations/SCP governance
* Add automated IAM compliance reporting

---

# 📊 Project Outcome

The final environment demonstrates a controlled AWS IAM architecture where:

```text
                ┌────────────────────────┐
                │     AWS IAM Governance │
                └────────────┬───────────┘
                             │
       ┌─────────────────────┼─────────────────────┐
       │                     │                     │
       ▼                     ▼                     ▼
   Developers            Auditors              Uploaders
       │                     │                     │
       ▼                     ▼                     ▼
  Controlled EC2        Read-only access      Controlled S3
       │
       │
       ▼
   EC2 IAM Role
       │
       ▼
      S3

                    Finance
                       │
                       ▼
                Billing Access
                EC2 Restricted
```

The project successfully demonstrates how **IAM can be used to enforce organizational security boundaries and least-privilege access across different AWS teams and workloads.**

---

# 👩‍💻 Author

**Shaheen Sardar**

BS Information Technology | AWS Cloud & Infrastructure

GitHub: [ShaheenSardar](https://github.com/ShaheenSardar)

---

# ⭐ Project Highlights

* 🔐 Least-privilege IAM architecture
* 👥 Four role-based teams
* 📜 Custom IAM policies
* 🖥️ EC2 workload IAM role
* 🪣 Controlled S3 access
* 🚫 Tested denied operations
* ✅ Tested successful operations
* 💻 AWS CLI automation
* 🐚 Bash scripting
* 🧪 Security validation
* 🧹 Automated cleanup
* 📸 40+ implementation and testing screenshots

---

## ⭐ If you find this project useful

Feel free to explore the repository, review the IAM policies, inspect the automation scripts, and examine the testing evidence.
