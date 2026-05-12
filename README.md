# ptb_bot_test_upproaches
This repository contains tests for different approaches for Python Telegram Bots

- Create virtual environment
```
python -m venv .venv
```
- Activate a Python virtual environment
```
.venv\Scripts\activate
```
- Install Dependencies: 
```
pip install -r bot/requirements.txt
```

## Branch `implement_ec2_deployment` describes deployment the bot to EC2 with docker
### Add to GitHub Secrets
Go to your repo → Settings → Secrets and variables → Actions → New repository secret
```aiignore
Name:  TELEGRAM_TOKEN_PROD

Name:  TELEGRAM_TOKEN_UAT

Key: EC2_SSH_KEY_UAT 
Description: Private SSH key for UAT EC2

Key: EC2_SSH_KEY_PROD 
Description: Private SSH key for Prod EC2
```

## How\Where to get
### *TELEGRAM_TOKEN_** 
Open Telegram → message @BotFather → and follow

### *EC2_SSH_KEY_** 
Run `ssh-keygen -t ed25519 -C "github-actions"` on your local machine. 
The private key goes into GitHub Secrets. The public key goes into `~/.ssh/authorized_keys` on the EC2 instance

### *AWS_ACCESS_KEY_ID + AWS_SECRET_ACCESS_KEY*
AWS Console → IAM → Users → your user → Security credentials → Create access key → 
choose "CI/CD" use case → copy both values immediately (secret shown once only)

### *EC2_HOST_UAT / EC2_HOST_PROD*
AWS Console → EC2 → Instances → select your instance → copy Public IPv4 address or Public DNS

### *AWS_REGION*
The region your EC2 lives in, e.g. us-east-1, eu-west-1

### *ECR_REGISTRY*
AWS Console → ECR → your repository → copy the URI prefix, e.g. 123456789.dkr.ecr.eu-west-1.amazonaws.com

## EC2 Setup (one-time)
- SSH into each EC2 instance and run:
```
# Prevent reading from `.env`
chmod 600 /home/ec2-user/bot/.env

# Install Docker
sudo yum update -y
sudo yum install -y docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user

# Install Docker Compose v2
sudo mkdir -p /usr/local/lib/docker/cli-plugins
sudo curl -SL https://github.com/docker/compose/releases/latest/download/\
docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Install AWS CLI (for ECR login in deploy.sh)
sudo yum install -y awscli

# Create bot directory
mkdir -p /home/ec2-user/bot/scripts

# Create the log directory on EC2 (one-time)
mkdir -p /home/ec2-user/bot/logs
mkdir -p /home/ec2-user/bot/logs-uat
```
- Attach an IAM Instance Role to the EC2 with this policy:
```aiignore
{
  "Effect": "Allow",
  "Action": [
    "ecr:GetAuthorizationToken",
    "ecr:BatchGetImage",
    "ecr:GetDownloadUrlForLayer"
  ],
  "Resource": "*"
}
```