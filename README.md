# Terraform AWS VPC with EC2 & Apache

This project provisions a complete **AWS infrastructure using Terraform**, including a VPC, public subnet, internet gateway, route table, security group, Elastic IP, and an EC2 instance running **Apache Web Server**.

---

## 🏗 Architecture Overview

The infrastructure created by this project includes:

- Custom VPC (`10.0.0.0/16`)
- Public Subnet (`10.0.1.0/24`)
- Internet Gateway
- Route Table with internet access
- Security Group allowing:
  - SSH (22)
  - HTTP (80)
  - HTTPS (443)
- Network Interface (ENI)
- Elastic IP
- EC2 instance (Ubuntu) with Apache installed

---

## 📂 Project Structure
├── main.tf
├── .gitignore
└── README.md


---

## ⚙️ Prerequisites

Before running this project, make sure you have:

- AWS Account
- AWS CLI installed and configured
- Terraform installed (v1.x recommended)
- An existing EC2 Key Pair in AWS (same region)

---

## 🔐 AWS Credentials Setup (IMPORTANT)

**Do NOT hardcode AWS credentials.**

Configure credentials using AWS CLI:

```bash
aws configure

🌐 Access the Web Server

After deployment:

Copy the Elastic IP from Terraform output or AWS console

Open browser:

http://<ELASTIC-IP>


You should see:

Your very first web server

🧹 Cleanup (Destroy Resources)

To avoid AWS charges:

terraform destroy

