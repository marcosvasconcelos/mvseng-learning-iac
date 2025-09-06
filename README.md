# mvseng-learning-iac

![Terraform CI](https://github.com/marcosvasconcelos/mvseng-learning-iac/actions/workflows/terraform-ci.yml/badge.svg)

## Overview

Infrastructure as Code learning repository with examples and labs using Terraform on AWS.

## Repository Structure

```
mvseng-learning-iac/
├── .gitignore
├── LICENSE
├── README.md
├── base_tools/
│   ├── cleanup.sh
│   ├── create-keypair.sh
│   ├── install.sh
│   └── requirements.txt
├── modules/
│   └── aws/
│       ├── ec2_instance/
│       │   ├── main.tf
│       │   ├── outputs.tf
│       │   └── variables.tf
│       └── s3_bucket/
│           ├── main.tf
│           ├── outputs.tf
│           └── variables.tf
├── providers/
│   └── aws/
│       ├── .terraform/
│       ├── .terraform.lock.hcl
│       ├── backend.tf
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       ├── terraform.tfvars.example
│       ├── terraform.tfstate
│       └── terraform.tfstate.backup
└── tests/
    ├── balancer_test.sh
    ├── check_tg_healthy.py
    └── test_laboratory.sh
```

### Directory Descriptions

| Directory | Purpose |
|-----------|---------|
| base_tools/ | Utility scripts for setup and maintenance |
| modules/ | Reusable Terraform components |
| providers/ | Cloud provider configurations |
| tests/ | Testing and validation tools |

### Important Files

| File | Purpose | Git Tracking |
|------|---------|--------------|
| terraform.tfvars | Configuration values | Not tracked |
| terraform.tfstate | Current infrastructure state | Not tracked |
| .terraform/ | Provider plugins and modules cache | Not tracked |
| terraform.tfvars.example | Template for configuration | Tracked |

## Current Lab: High Availability Web Application

### Architecture Overview

- Multi-AZ deployment (two public subnets)
- Application Load Balancer
- Target group with health checks
- Security groups for ALB, HTTP, and SSH
- VPC with Internet access

### Infrastructure Components

| Component | Count | Notes |
|-----------|-------|-------|
| VPC | 1 | 10.0.0.0/16 |
| Public Subnets | 2 | 10.0.1.0/24, 10.0.2.0/24 |
| EC2 Instances | 2 | t2.micro with Nginx |
| Application Load Balancer | 1 | Internet-facing |
| Target Group | 1 | HTTP health check |
| Security Groups | 3 | ALB, HTTP, SSH |
| Internet Gateway | 1 | Egress/ingress to Internet |

## Quick Start

### Prerequisites

Required tools:

| Tool | Version | Purpose |
|------|---------|---------|
| AWS CLI | >= 2.0 | AWS service interaction |
| Terraform | >= 1.0 | Infrastructure provisioning |
| Git | >= 2.0 | Version control |
| SSH Client | Any | EC2 access |

#### Linux (Ubuntu/Debian)

```bash
sudo apt update
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
sudo apt install git
```

#### macOS (Homebrew)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install awscli terraform git
```

#### Windows (Chocolatey)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
choco install awscli terraform git
```

#### AWS Account

- Active AWS account with billing enabled
- Permissions to create EC2, VPC, subnets, security groups, ALB, target groups
- Region access (default us-east-1 or adjust variables)
- Service limits for the above resources

#### Verification

```bash
aws --version
terraform --version
git --version
aws sts get-caller-identity
```

## Steps

### 1. Clone the repository

```bash
git clone https://github.com/marcosvasconcelos/mvseng-learning-iac.git
cd mvseng-learning-iac
```

### 2. Configure AWS credentials

```bash
aws configure --profile mvseng-learning-tf
# or environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### 3. Create AWS key pair

```bash
./base_tools/create-keypair.sh
```

### 4. Configure Terraform variables

```bash
cd providers/aws
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars as needed
```

### 5. Deploy infrastructure

```bash
terraform init
terraform plan
terraform apply
```

### 6. Outputs

- Load balancer DNS
- Instance IP addresses
- Availability Zones

## Cleanup

### Quick cleanup

```bash
./base_tools/cleanup.sh
```

### Complete cleanup

```bash
cd providers/aws
terraform destroy
```

## Learning Modules

- Basic infrastructure (VPC, single EC2, security groups)
- High availability (multi-AZ, load balancer, target group)
- Advanced patterns (Auto Scaling, RDS, CloudFront)

## Utility Scripts

```bash
./base_tools/create-keypair.sh   # Create AWS key pair if not present
./base_tools/cleanup.sh          # Clean up security groups and instances
./tests/balancer_test.sh         # Test load balancer
./tests/check_tg_healthy.py      # Check target group health
```

## Contributing

Suggestions and fixes are welcome.

## CI/CD

- GitHub Actions runs Terraform checks on every push/PR to `main`.
- What it does:
    - terraform fmt -check -recursive (repo root)
    - terraform init -backend=false (in `providers/aws`)
    - terraform validate (in `providers/aws`)
- No cloud credentials are required; the backend is disabled for validation.

## Support

- Open an issue in this repository
- See Terraform and AWS documentation

## License

MIT License. See `LICENSE`.