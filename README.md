# mvseng-learning-iac

## 🚀 MVSEng Infrastructure as Code Learning Repository

Welcome to the **MVSEng Infrastructure as Code (IaC) Learning Repository**! This repository contains practical examples, labs, and educational materials for learning Infrastructure as Code using various tools and cloud providers.

## 📚 What You'll Learn

- **Terraform fundamentals** - Infrastructure provisioning and management
- **AWS Cloud Services** - EC2, VPC, Load Balancers, Security Groups
- **Infrastructure best practices** - Modular design, security, and scalability
- **High Availability architectures** - Multi-AZ deployments and load balancing
- **Cloud automation** - Scripting and automated deployments

## 🏗️ Repository Structure

```
mvseng-learning-iac/
├── .gitignore                 # Git ignore patterns for sensitive files
├── LICENSE                    # Project license
├── README.md                  # This documentation file
├── base_tools/                # Utility scripts and tools
│   ├── cleanup.sh             # General cleanup script
│   ├── create-keypair.sh      # AWS key pair creation
│   ├── install.sh             # Tool installation script
│   └── requirements.txt       # Python dependencies
├── modules/                   # Reusable Terraform modules
│   └── aws/
│       ├── ec2_instance/      # EC2 instance module
│       │   ├── main.tf        # EC2 resource definitions
│       │   ├── outputs.tf     # Module outputs (IPs, IDs, etc.)
│       │   └── variables.tf   # Module input variables
│       └── s3_bucket/         # S3 bucket module
│           ├── main.tf        # S3 resource definitions
│           ├── outputs.tf     # S3 bucket outputs
│           └── variables.tf   # S3 input variables
├── providers/                 # Cloud provider configurations
│   └── aws/                   # AWS infrastructure
│       ├── .terraform/        # Terraform provider cache (auto-generated)
│       ├── .terraform.lock.hcl # Provider version lock file
│       ├── backend.tf         # Terraform backend configuration
│       ├── main.tf            # Main infrastructure definition
│       ├── variables.tf       # Variable definitions
│       ├── terraform.tfvars   # Actual variable values (sensitive)
│       ├── terraform.tfvars.example # Example variable template
│       ├── terraform.tfstate  # Terraform state file (local backend)
│       └── terraform.tfstate.backup # State backup file
└── tests/                     # Testing and validation scripts
    ├── balancer_test.sh       # Load balancer functionality tests
    ├── check_tg_healthy.py    # Target group health check script
    └── test_laboratory.sh     # Complete lab environment tests
```

### 📁 Directory Descriptions

| Directory | Purpose | Contents |
|-----------|---------|----------|
| **base_tools/** | Utility scripts for setup and maintenance | Installation, cleanup, and configuration scripts |
| **modules/** | Reusable Terraform components | Modular infrastructure definitions for different AWS services |
| **providers/** | Cloud provider specific configurations | Complete infrastructure deployments per cloud provider |
| **tests/** | Testing and validation tools | Scripts to verify infrastructure functionality and health |

### 🔒 Important Files

| File | Purpose | Git Tracking |
|------|---------|--------------|
| `terraform.tfvars` | Contains sensitive configuration values | ❌ **Not tracked** (in .gitignore) |
| `terraform.tfstate` | Current infrastructure state | ❌ **Not tracked** (contains sensitive data) |
| `.terraform/` | Provider plugins and modules cache | ❌ **Not tracked** (auto-generated) |
| `terraform.tfvars.example` | Template for configuration | ✅ **Tracked** (safe template) |

## 🎯 Current Lab: High Availability Web Application

### Architecture Overview

The current lab demonstrates a **production-ready, highly available web application** with the following components:

- **🌍 Multi-AZ Deployment**: Instances spread across 2 Availability Zones
- **⚖️ Application Load Balancer**: Distributes traffic across instances
- **🎯 Target Groups**: Health monitoring and traffic routing
- **🛡️ Security Groups**: Network security and access control
- **🌐 VPC & Networking**: Custom virtual network with public subnets

### Infrastructure Components

| Component | Count | Description |
|-----------|-------|-------------|
| VPC | 1 | Custom virtual private cloud (10.0.0.0/16) |
| Public Subnets | 2 | One per AZ (10.0.1.0/24, 10.0.2.0/24) |
| EC2 Instances | 2 | t2.micro with Nginx web servers |
| Application Load Balancer | 1 | Internet-facing, multi-AZ |
| Target Group | 1 | Health-monitored instance group |
| Security Groups | 3 | ALB, HTTP, and SSH access control |
| Internet Gateway | 1 | Internet connectivity |

## 🚀 Quick Start

### Prerequisites

Before starting this lab, ensure you have the following tools installed and configured:

#### Required Tools

| Tool | Version | Purpose | Installation |
|------|---------|---------|--------------|
| **AWS CLI** | >= 2.0 | AWS service interaction | [Install Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) |
| **Terraform** | >= 1.0 | Infrastructure provisioning | [Install Guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) |
| **Git** | >= 2.0 | Version control | [Install Guide](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) |
| **SSH Client** | Any | EC2 instance access | Built-in on Linux/Mac, [PuTTY](https://putty.org/) for Windows |

#### Quick Installation Commands

**Ubuntu/Debian:**
```bash
# Update package list
sudo apt update

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Install Git (if not already installed)
sudo apt install git
```

**macOS (using Homebrew):**
```bash
# Install Homebrew if not installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install tools
brew install awscli terraform git
```

**Windows (using Chocolatey):**
```powershell
# Install Chocolatey if not installed
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install tools
choco install awscli terraform git
```

#### AWS Account Requirements

- **AWS Account**: Active AWS account with billing enabled
- **IAM Permissions**: User with permissions to create:
  - EC2 instances and security groups
  - VPC, subnets, and networking components
  - Application Load Balancers and Target Groups
  - IAM roles (for advanced labs)
- **AWS Regions**: Access to us-east-1 (or modify variables for your preferred region)
- **Service Limits**: Ensure you have available:
  - EC2 instances (2x t2.micro)
  - VPC resources (1 VPC, 2 subnets)
  - Load Balancer (1 Application Load Balancer)

#### Verification Commands

After installation, verify your setup:

```bash
# Check AWS CLI
aws --version
# Expected: aws-cli/2.x.x or higher

# Check Terraform
terraform --version
# Expected: Terraform v1.x.x or higher

# Check Git
git --version
# Expected: git version 2.x.x or higher

# Test AWS credentials (after configuration)
aws sts get-caller-identity
# Should return your AWS account information
```

### 1. Clone the Repository

```bash
git clone https://github.com/marcosvasconcelos/mvseng-learning-iac.git
cd mvseng-learning-iac
```

### 2. Configure AWS Credentials

```bash
# Option 1: Configure AWS Profile
aws configure --profile mvseng-learning-tf

# Option 2: Export environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### 3. Create AWS Key Pair

```bash
# Run the automated key pair creation script
./create-keypair.sh
```

### 4. Configure Terraform Variables

```bash
cd providers/aws
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your configuration
```

### 5. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the deployment plan
terraform plan

# Deploy the infrastructure
terraform apply
```

### 6. Access Your Application

After deployment, you'll receive outputs including:
- **Load Balancer DNS**: Your application's public URL
- **Instance IPs**: Individual server IP addresses
- **Availability Zones**: AZs being used

## 🧹 Cleanup

### Quick Cleanup
```bash
# Clean up existing resources before redeploying
./cleanup-sg.sh
```

### Complete Cleanup
```bash
cd providers/aws
terraform destroy
```

## 📖 Learning Modules

### Module 1: Basic Infrastructure
- VPC and networking setup
- Single EC2 instance deployment
- Security group configuration

### Module 2: High Availability
- Multi-AZ deployments
- Load balancer implementation
- Target group configuration

### Module 3: Advanced Patterns
- Auto Scaling Groups
- RDS databases
- CloudFront distributions

## 🛠️ Utility Scripts

### Key Pair Management
```bash
./create-keypair.sh          # Create AWS key pair if not exists
```

### Environment Cleanup
```bash
./cleanup-sg.sh              # Clean up security groups and instances
```

### Health Checks
```bash
./tests/balancer_test.sh      # Test load balancer functionality
./tests/check_tg_healthy.py   # Check target group health
```

## 🎓 Learning Objectives

After completing this lab, you will understand:

- ✅ **Infrastructure as Code principles** using Terraform
- ✅ **AWS networking concepts** (VPC, subnets, routing)
- ✅ **High availability design patterns** and multi-AZ deployments
- ✅ **Load balancing strategies** and health monitoring
- ✅ **Security best practices** for cloud infrastructure
- ✅ **Modular infrastructure design** and code reusability
- ✅ **Infrastructure testing** and validation techniques

## 🤝 Contributing

This is a learning repository. Feel free to:
- Fork and experiment with the code
- Submit improvements or bug fixes
- Share additional learning resources
- Create new lab scenarios

## 📞 Support

For questions or support:
- Create an issue in this repository
- Review the Terraform documentation
- Check AWS documentation for service-specific details

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Happy Learning!** 🎉

*This repository is part of the MVSEng learning initiative to master Infrastructure as Code and cloud technologies.*