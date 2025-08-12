# README: WordPress AMI Builder with Ansible on WSL (Windows Subsystem for Linux)

This guide walks you through the complete setup and usage steps to build a custom WordPress-ready Amazon Machine Image (AMI) using Ansible, from a Windows machine running WSL. It covers installing dependencies, configuring access to AWS, preparing Ansible, and running the automation workflow.

***

## Overview

This project automates:

- Launching an EC2 instance with base OS
- Installing Apache, PHP, and WordPress software
- Preparing the instance for AMI creation without embedding environment-specific secrets
- Creating a reusable WordPress-ready AMI
- Cleaning up the build instance

***

## Prerequisites

- Windows 10/11 with WSL (Ubuntu preferred)
- AWS account with permissions to launch EC2 instances and create AMIs
- An existing EC2 key pair in your AWS region for SSH access

***

## Step-by-Step Setup Guide

### 1. Install WSL

Open PowerShell as Administrator and run:

```bash
wsl --install
```

Restart your computer if prompted. When done, launch Ubuntu or your installed Linux distro from the Start Menu.

***

### 2. Update Linux Packages

In your WSL terminal, run:

```bash
sudo apt update && sudo apt upgrade -y
```

***

### 3. Create and Activate a Python Virtual Environment

Install Python and venv if missing:

```bash
sudo apt install -y python3 python3-venv python3-pip
```

Create and activate a virtual environment:

```bash
python3 -m venv aws-cli-venv
source aws-cli-venv/bin/activate
```

***

### 4. Install AWS CLI v2 inside WSL

Run the following commands in WSL:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

Verify installation:

```bash
aws --version
```

***

### 5. Configure AWS CLI with Credentials

Configure your AWS access keys and default region:

```bash
aws configure
```

Enter your IAM user's **Access Key ID**, **Secret Access Key**, region (e.g., `us-east-1`), and output format (`json`).

*Note:* Create IAM users with **programmatic access** in AWS IAM console and use prudent security policies.

***

### 6. Install Ansible and Required Python Packages

Install Ansible and AWS SDK packages within the virtual environment:

```bash
pip install --upgrade pip
pip install ansible boto3 botocore
ansible-galaxy collection install amazon.aws
```

Confirm Ansible version:

```bash
ansible --version
```

***

### 7. Setup SSH Key Access

- Download your AWS EC2 **private key** `.pem` file when creating your key pair in the AWS console.
- Copy the `.pem` file into `~/.ssh/` in your WSL environment (create the directory if missing):

```bash
mkdir -p ~/.ssh
cp /mnt/c/Users/YourWindowsUser/Downloads/your-key.pem ~/.ssh/
chmod 600 ~/.ssh/your-key.pem
```

- Test SSH connectivity (replace IP and username accordingly):

```bash
ssh -i ~/.ssh/your-key.pem ec2-user@your-ec2-instance-public-ip
```

***

### 8. Clone or Prepare Your Ansible Project

Place your project files, including:

- `inventory.ini`
- `vars.yml` (fill in your AWS region, key_name, ssh_private_key, ami_base, etc.)
- `create_ami.yml`
- `roles/configure_wordpress_environment/` (with `tasks/main.yml` and `templates/wp-config.php.j2`)

Navigate to the project directory:

```bash
cd /path/to/your/ansible/project
```

***

### 9. Set Environment Variable for Ansible Python Interpreter (Optional but Recommended)

If you face Python interpreter issues on remote hosts during playbook runs, export:

```bash
export ANSIBLE_PYTHON_INTERPRETER=/usr/bin/python3
```

***

### 10. Run the Playbook

Execute the main playbook:

```bash
ansible-playbook -i inventory.ini create_ami.yml
```

This will:

- Launch a build EC2 instance with basic bootstrapping
- Configure WordPress dependencies and download WordPress
- Create a custom AMI from this configured instance
- Terminate the build instance after AMI creation

***
