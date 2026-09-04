# 🔐 Secure AWS Environment with IAM Governance

A hands-on AWS security and identity management project demonstrating **IAM governance, least privilege, controlled resource access, MFA, IAM roles, S3 security, and access validation using AWS CLI and the AWS Management Console**.

The project simulates a real-world organization where different teams require different levels of access to AWS resources. Permissions are intentionally restricted according to job responsibilities, and both **successful and denied actions** are tested to verify that the security model works as intended.

---

## 📌 Project Overview

In this project, I designed and implemented a secure AWS IAM environment for multiple organizational roles:

* 👨‍💻 **Developers**
* 🔍 **Auditors**
* 📤 **Uploaders**
* 💰 **Finance**

The environment uses:

* IAM Groups
* IAM Users
* Customer-managed IAM policies
* AWS managed policies
* MFA
* EC2 IAM Roles
* S3 permissions
* Resource tagging
* Least-privilege access
* AWS CLI
* AWS Management Console
* Permission testing and validation

The project also demonstrates the difference between **allowed actions and explicitly denied actions**, providing evidence that permissions were tested rather than simply configured.

---

# 🎯 Project Objectives

The main objectives of this project were to:

1. Implement centralized IAM governance.
2. Apply the principle of least privilege.
3. Separate permissions according to organizational roles.
4. Restrict developers to approved EC2 and S3 operations.
5. Provide read-only access to auditors.
6. Restrict uploaders to specific S3 locations.
7. Provide finance users with billing-related access.
8. Configure MFA for IAM users.
9. Use IAM roles instead of long-term credentials for EC2 workloads.
10. Validate both successful and denied operations.
11. Verify that unauthorized users cannot perform restricted actions.
12. Clean up temporary AWS resources after testing.

---

# 🏗️ AWS Architecture

The environment follows a role-based IAM access model:

```text
                         AWS ACCOUNT
                              │
                              │
                     ┌────────▼────────┐
                     │   IAM GOVERNANCE │
                     └────────┬────────┘
                              │
          ┌───────────────────┼───────────────────┐
          │                   │                   │
          ▼                   ▼                   ▼
   Developers             Auditors            Uploaders
          │                   │                   │
          │                   │                   │
          ▼                   ▼                   ▼
       EC2/S3             Read Only          S3 Backups
          │
          │
          └──────────────┐
                         │
                         ▼
                  Production EC2
                         │
                         │ IAM Role
                         ▼
                    Amazon S3


                         ┌──────────────┐
                         │    Finance   │
                         └──────┬───────┘
                                │
                                ▼
                         Billing Access
```

---

# ☁️ AWS Services Used

| Service                    | Purpose                                   |
| -------------------------- | ----------------------------------------- |
| **IAM**                    | Identity and access management            |
| **EC2**                    | Compute resources used for access testing |
| **S3**                     | Object storage and permission testing     |
| **AWS STS**                | Identity verification                     |
| **CloudShell / AWS CLI**   | Command-line administration and testing   |
| **AWS Management Console** | Configuration verification                |

---

# 🔐 IAM Governance Model

The project uses a role-based permission structure.

| Group        | Purpose                          | Access Model            |
| ------------ | -------------------------------- | ----------------------- |
| `Developers` | Application/EC2 operations       | Limited EC2 + S3 access |
| `Auditors`   | Security and resource inspection | Read-only               |
| `Uploaders`  | Backup/file uploads              | Restricted S3 access    |
| `Finance`    | Financial administration         | Billing-related access  |

This separation prevents every user from receiving unnecessary administrative permissions.

---

# 👨‍💻 Developer Access

The Developer role is designed around the principle of least privilege.

Developers can perform approved EC2 operations and limited S3 operations but cannot perform destructive operations such as deleting protected objects or terminating EC2 instances.

### Developer security objectives

* View EC2 resources
* Start approved EC2 instances
* Stop approved EC2 instances
* Access approved S3 resources
* Prevent unauthorized EC2 termination
* Prevent unauthorized S3 deletion

### Evidence

**Developer policy**

![Developer Policy](screenshots/06-developer-policy.png)

**Policy attached**

![Policy Attached](screenshots/10-policy-attached.png)

---

# 📤 Uploader Access

The Uploader role is designed for users who need to upload files to an approved S3 location without receiving broad S3 administrative permissions.

The policy restricts access to the intended backup area.

### Uploader objectives

* Upload files to the approved `backups/` location
* Read approved objects where required
* Prevent uploads outside the permitted location

### Evidence

**Uploader policy**

![Uploader Policy](screenshots/13-uploader-policy.png)

**Successful upload**

![Uploader Success](screenshots/39-uploader-success.png)

**Unauthorized upload denied**

![Uploader Denied](screenshots/40-uploader-denied.png)

---

# 🔍 Auditor Access

Auditors receive read-only access so they can inspect AWS resources without modifying or deleting them.

The project uses AWS's read-only permission model for the Auditor role.

### Auditor security objectives

* Inspect AWS resources
* Review configuration
* Prevent resource modification
* Prevent EC2 start/stop operations

### Evidence

**Auditor unauthorized EC2 action**

![Auditor Start Denied](screenshots/38-auditor-start-denied.png)

The denied operation demonstrates that read-only access does not provide permission to modify EC2 resources.

---

# 💰 Finance Access

The Finance role is separated from technical infrastructure administration.

Finance users receive billing-related access rather than permissions to manage EC2 infrastructure.

### Finance security objectives

* View billing-related information
* Prevent infrastructure administration
* Prevent EC2 operations

### Evidence

**Billing policy**

![Billing Policy](screenshots/17-billing-policy.png)

**Finance billing access**

![Finance Billing](screenshots/41-finance-billing.png)

**Finance EC2 access denied**

![Finance EC2 Denied](screenshots/42-finance-ec2-denied.png)

---

# 👥 IAM Users and Group Membership

IAM users were created and assigned to the appropriate organizational groups.

This demonstrates centralized access management through group-based permissions rather than attaching unrelated permissions individually to every user.

### Evidence

**Users created**

![Users Created](screenshots/19-users-created.png)

**Group membership**

![Group Membership](screenshots/21-group-membership.png)

---

# 🔑 MFA Security

Multi-Factor Authentication was configured as an additional security control for IAM identities.

MFA provides an additional authentication factor beyond the user's password.

### Evidence

![MFA Configuration](screenshots/23-mfa.png)

> ⚠️ Sensitive MFA information, QR codes, secrets, and credentials should never be committed to a public GitHub repository.

---

# 🖥️ EC2 Environment

Two EC2 instances were used to validate access-control behavior:

* **Production**
* **Development**

The environments were deliberately separated so that IAM policies could be tested against different resource conditions.

### Production EC2

![Production EC2](screenshots/24-production-ec2.png)

### Development EC2

![Development EC2](screenshots/25-development-ec2.png)

---

# 🪣 Amazon S3 Environment

An S3 bucket was used to demonstrate controlled object access and IAM role-based access.

The S3 environment was also used to test whether users could perform actions outside their assigned permissions.

### Evidence

![S3 Environment](screenshots/26-s3.png)

---

# 🛡️ EC2 IAM Role

Instead of storing long-term AWS access keys on the EC2 instance, an IAM role was configured for the EC2 workload.

This follows AWS security best practices by allowing applications running on EC2 to obtain temporary credentials through the instance role.

### Trust Policy

![EC2 Role Trust Policy](screenshots/27-ec2-role-trust.png)

### Role Permissions

![EC2 Role Permissions](screenshots/28-ec2-role-permissions.png)

This design avoids the need to place permanent AWS access keys directly on the EC2 instance.

---

# 🧪 EC2 Identity Verification

The EC2 instance was tested using AWS STS to verify the AWS identity being assumed by the workload.

![STS From EC2](screenshots/30-sts-from-ec2.png)

This confirms which IAM role/identity the EC2 environment is using.

---

# 🪣 S3 Access From EC2

The EC2 role was then tested against Amazon S3.

![S3 Access From EC2](screenshots/31-s3-access-from-ec2.png)

This demonstrates role-based access between an EC2 workload and S3.

---

# 🧪 Permission Testing

A major part of this project was not only creating policies but **testing the actual permissions**.

The following scenarios were tested.

---

## ✅ Production EC2 — Start Allowed

The Developer user successfully started the Production EC2 instance.

![Production Start Success](screenshots/33-production-start-success.png)

**Expected result:** `Success`

---

## ✅ Production EC2 — Stop Allowed

The Developer user successfully stopped the Production EC2 instance.

![Production Stop Success](screenshots/34-production-stop-success.png)

**Expected result:** `Success`

---

## ❌ Development EC2 — Start Denied

The Developer attempted to start the Development EC2 instance.

![Development Start Denied](screenshots/35-development-start-denied.png)

**Expected result:** `AccessDenied`

This verifies that the developer does not have unrestricted EC2 start permissions.

---

## ❌ S3 Delete — Denied

The Developer attempted a restricted S3 deletion operation.

![S3 Delete Denied](screenshots/36-s3-delete-denied.png)

**Expected result:** `AccessDenied`

This demonstrates protection against unauthorized destructive S3 operations.

---

## ❌ Auditor — EC2 Start Denied

The Auditor attempted to start an EC2 instance.

![Auditor Start Denied](screenshots/38-auditor-start-denied.png)

**Expected result:** `AccessDenied`

This confirms that read-only access does not provide EC2 modification privileges.

---

## ❌ Finance — EC2 Access Denied

The Finance user attempted an EC2 operation.

![Finance EC2 Denied](screenshots/42-finance-ec2-denied.png)

**Expected result:** `AccessDenied`

This verifies separation between financial access and infrastructure administration.

---

# 📊 Access-Control Validation

| Test                                        | Expected Result |
| ------------------------------------------- | --------------- |
| Developer → Start Production EC2            | ✅ Allowed       |
| Developer → Stop Production EC2             | ✅ Allowed       |
| Developer → Start Development EC2           | ❌ Denied        |
| Developer → Delete S3 object                | ❌ Denied        |
| Auditor → Start EC2                         | ❌ Denied        |
| Uploader → Upload to approved location      | ✅ Allowed       |
| Uploader → Upload outside approved location | ❌ Denied        |
| Finance → Billing information               | ✅ Allowed       |
| Finance → EC2 operation                     | ❌ Denied        |
| EC2 Role → S3                               | ✅ Allowed       |

The testing phase demonstrates that the IAM configuration was validated through actual AWS API operations rather than relying solely on policy configuration.

---

# 🔎 AWS Account Verification

The AWS environment was initially verified using AWS STS.

![Account Verification](screenshots/01-account-verification.png)

This establishes the active AWS identity before performing IAM administration.

---

# 👥 IAM Groups Created

The required IAM groups were created for organizational separation.

![Groups Created](screenshots/03-groups-created.png)

---

# 🧹 Cleanup

After testing, temporary resources and test configurations were cleaned up.

![Cleanup](screenshots/43-cleanup.png)

A final verification was performed to confirm the cleanup.

![Final Verification](screenshots/44-final-verification.png)

Cleanup is an important part of cloud security and cost management because unused resources and identities should not remain active after testing.

---

# 📸 Project Evidence

The repository contains evidence collected during both AWS CLI administration and AWS Management Console verification.

|  # | Evidence                   |
| -: | -------------------------- |
| 01 | AWS account verification   |
| 03 | IAM groups created         |
| 06 | Developer policy           |
| 10 | Policy attached            |
| 13 | Uploader policy            |
| 17 | Billing policy             |
| 19 | IAM users created          |
| 21 | Group membership           |
| 23 | MFA                        |
| 24 | Production EC2             |
| 25 | Development EC2            |
| 26 | S3 environment             |
| 27 | EC2 role trust policy      |
| 28 | EC2 role permissions       |
| 30 | STS identity from EC2      |
| 31 | S3 access from EC2         |
| 33 | Production start — SUCCESS |
| 34 | Production stop — SUCCESS  |
| 35 | Development start — DENIED |
| 36 | S3 delete — DENIED         |
| 38 | Auditor start — DENIED     |
| 39 | Uploader — SUCCESS         |
| 40 | Uploader — DENIED          |
| 41 | Finance billing            |
| 42 | Finance EC2 — DENIED       |
| 43 | Cleanup                    |
| 44 | Final verification         |

---

# 🛠️ Tools & Technologies

* Amazon Web Services (AWS)
* AWS Identity and Access Management (IAM)
* Amazon EC2
* Amazon S3
* AWS Security Token Service (STS)
* AWS CloudShell
* AWS CLI
* Bash
* Git
* GitHub
* JSON

---

# 📂 Repository Structure

```text
secure-aws-iam-governance/
│
├── README.md
│
├── policies/
│   ├── DevProjectPolicy.json
│   ├── UploaderPolicy.json
│   └── EC2S3AccessPolicy.json
│
├── trust-policies/
│   └── ec2-trust-policy.json
│
├── scripts/
│   ├── 01-create-groups.sh
│   ├── 02-create-policies.sh
│   ├── 03-create-users.sh
│   ├── 04-create-role.sh
│   ├── 05-validation-tests.sh
│   └── 06-cleanup.sh
│
└── screenshots/
    ├── 01-account-verification.png
    ├── 03-groups-created.png
    ├── 06-developer-policy.png
    ├── 10-policy-attached.png
    ├── 13-uploader-policy.png
    ├── 17-billing-policy.png
    ├── 19-users-created.png
    ├── 21-group-membership.png
    ├── 23-mfa.png
    ├── 24-production-ec2.png
    ├── 25-development-ec2.png
    ├── 26-s3.png
    ├── 27-ec2-role-trust.png
    ├── 28-ec2-role-permissions.png
    ├── 30-sts-from-ec2.png
    ├── 31-s3-access-from-ec2.png
    ├── 33-production-start-success.png
    ├── 34-production-stop-success.png
    ├── 35-development-start-denied.png
    ├── 36-s3-delete-denied.png
    ├── 38-auditor-start-denied.png
    ├── 39-uploader-success.png
    ├── 40-uploader-denied.png
    ├── 41-finance-billing.png
    ├── 42-finance-ec2-denied.png
    ├── 43-cleanup.png
    └── 44-final-verification.png
```

---

# 🔐 Security Principles Demonstrated

This project demonstrates several important AWS security concepts.

### 1. Least Privilege

Users receive only the permissions required for their responsibilities.

### 2. Role-Based Access Control

Permissions are organized around job functions such as Developer, Auditor, Uploader, and Finance.

### 3. Separation of Duties

Technical infrastructure access is separated from auditing and financial access.

### 4. MFA

Additional authentication protection is applied to IAM identities.

### 5. Temporary Credentials

EC2 accesses AWS resources through an IAM role rather than hard-coded long-term credentials.

### 6. Explicit Permission Testing

Both successful and unsuccessful actions were tested to verify the effectiveness of the security configuration.

### 7. Resource-Level Restrictions

Where supported, permissions are restricted according to resource characteristics such as environment tagging or S3 object prefixes.

---

# 🧠 Key Learning Outcomes

Through this project, I strengthened my practical understanding of:

* IAM users and groups
* IAM policies
* AWS managed policies
* Customer-managed policies
* IAM roles
* Trust policies
* S3 permissions
* EC2 permissions
* AWS STS
* MFA
* Least privilege
* Role-based access control
* AccessDenied troubleshooting
* AWS CLI administration
* AWS Console verification
* Cloud security fundamentals
* Resource-based access restrictions
* Security validation and testing

---

# 🚀 Future Improvements

Possible future improvements include:

* Implementing AWS CloudTrail for API auditing
* Adding AWS Config compliance rules
* Creating automated IAM policy validation
* Adding infrastructure deployment with Terraform
* Integrating security checks into CI/CD
* Implementing automated detection of overly permissive IAM policies
* Adding AWS Security Hub
* Automating IAM access reviews
* Adding CloudWatch monitoring and alerts

---

# 🏆 Project Result

The project successfully demonstrates a controlled AWS environment where users receive **different permissions based on their organizational responsibilities**.

The access-testing phase verified both:

* ✅ Authorized operations
* ❌ Unauthorized operations

The project also demonstrates a security-focused approach to AWS administration by combining **IAM governance, least privilege, MFA, role-based access, controlled S3 access, EC2 role-based authentication, and practical permission testing**.

---

# 👩‍💻 Author

**Shaheen Sardar**

Cloud / AWS Engineer | AWS Infrastructure & Security Enthusiast

---

# ⭐ Skills Demonstrated

```text
AWS
AWS IAM
AWS EC2
Amazon S3
AWS STS
AWS CLI
CloudShell
Bash
JSON
Cloud Security
IAM Governance
Least Privilege
RBAC
Access Control
Troubleshooting
Git
GitHub
```

---

## 📜 Disclaimer

This project was created as a hands-on AWS learning and portfolio project.

AWS resources may incur charges depending on the services and configurations used. All temporary resources should be reviewed and removed after testing to avoid unnecessary costs.

Sensitive credentials, secrets, access keys, MFA secrets, and other confidential information should never be committed to GitHub.
