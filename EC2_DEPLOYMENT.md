# AWS EC2 Deployment Guide

Complete guide to deploy the Emotion Legacy (情绪遗产) backend to AWS EC2.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Launch EC2 Instance](#launch-ec2-instance)
3. [Configure Security Groups](#configure-security-groups)
4. [Connect to EC2](#connect-to-ec2)
5. [Install Dependencies](#install-dependencies)
6. [Deploy with Docker (Recommended)](#deploy-with-docker-recommended)
7. [Alternative: Manual Deployment](#alternative-manual-deployment)
8. [Configure Domain and SSL](#configure-domain-and-ssl)
9. [Monitoring and Maintenance](#monitoring-and-maintenance)
10. [Cost Optimization](#cost-optimization)

---

## Prerequisites

- AWS Account
- Basic terminal/SSH knowledge
- Domain name (optional, for HTTPS)
- SSH key pair (will create during setup)

---

## Launch EC2 Instance

### Step 1: Sign in to AWS Console

1. Go to [AWS Console](https://console.aws.amazon.com/)
2. Navigate to **EC2** service
3. Select your preferred region (e.g., `us-east-1`, `ap-southeast-1`)

### Step 2: Launch Instance

Click **"Launch Instance"** button and configure:

#### Name and Tags
```
Name: emotion-legacy-backend
```

#### Application and OS Images (AMI)
```
AMI: Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
Architecture: 64-bit (x86)
```

#### Instance Type

**For Development/Testing:**
```
t2.micro (1 vCPU, 1 GB RAM) - Free tier eligible
```

**For Production (Recommended):**
```
t3.small (2 vCPU, 2 GB RAM) - ~$15/month
t3.medium (2 vCPU, 4 GB RAM) - ~$30/month
```

**Why t3 over t2?**
- Better baseline performance
- More consistent CPU credits
- Better for Docker workloads

#### Key Pair (Login)

1. Click **"Create new key pair"**
2. Key pair name: `emotion-backend-key`
3. Key pair type: `RSA`
4. Private key file format: `.pem` (for Mac/Linux) or `.ppk` (for Windows/PuTTY)
5. Click **"Create key pair"** - file will download
6. **Important:** Save this file securely! You cannot download it again.

```bash
# Set correct permissions on Mac/Linux
chmod 400 emotion-backend-key.pem
```

#### Network Settings

1. Click **"Edit"** next to Network settings
2. **VPC:** Keep default
3. **Auto-assign public IP:** Enable
4. **Firewall (Security groups):** Create new security group
   - Name: `emotion-backend-sg`
   - Description: `Security group for Emotion Legacy backend`

#### Configure Security Group Rules

Add the following inbound rules:

| Type | Protocol | Port Range | Source | Description |
|------|----------|------------|--------|-------------|
| SSH | TCP | 22 | My IP | SSH access |
| HTTP | TCP | 80 | 0.0.0.0/0 | HTTP access |
| HTTPS | TCP | 443 | 0.0.0.0/0 | HTTPS access |
| Custom TCP | TCP | 8000 | 0.0.0.0/0 | API direct access (optional) |

**Security Note:** 
- For SSH, use "My IP" instead of "Anywhere" for better security
- You can remove port 8000 rule if using Nginx reverse proxy

#### Configure Storage

```
Size: 20 GB (minimum) to 30 GB (recommended)
Volume Type: gp3 (better performance than gp2)
```

#### Advanced Details (Optional)

Scroll down and expand **"Advanced details"**:

**User data** (optional - automates initial setup):
```bash
#!/bin/bash
apt-get update
apt-get upgrade -y
apt-get install -y git curl
```

### Step 3: Launch

1. Review all settings in the **"Summary"** panel
2. Click **"Launch instance"**
3. Wait for instance state to become **"Running"** (2-3 minutes)

### Step 4: Note Important Information

From the instance details page, copy:
- **Public IPv4 address** (e.g., `54.123.45.67`)
- **Public IPv4 DNS** (e.g., `ec2-54-123-45-67.compute-1.amazonaws.com`)

---

## Configure Security Groups

### Add Additional Rules (if needed)

1. Go to **EC2 Dashboard** → **Security Groups**
2. Select `emotion-backend-sg`
3. Click **"Inbound rules"** → **"Edit inbound rules"**
4. Add/modify rules as needed

### Recommended Security Group Configuration

```
SSH (22)      - Your IP only
HTTP (80)     - 0.0.0.0/0
HTTPS (443)   - 0.0.0.0/0
Custom (8000) - 0.0.0.0/0 (or remove if using Nginx)
```

---

## Connect to EC2

### Option 1: SSH from Terminal (Mac/Linux)

```bash
# Navigate to where you saved the key
cd ~/Downloads

# Set permissions
chmod 400 emotion-backend-key.pem

# Connect to EC2
ssh -i emotion-backend-key.pem ubuntu@YOUR_EC2_PUBLIC_IP

# Example:
# ssh -i emotion-backend-key.pem ubuntu@54.123.45.67
```

### Option 2: EC2 Instance Connect (Browser-based)

1. In EC2 console, select your instance
2. Click **"Connect"** button at top
3. Choose **"EC2 Instance Connect"** tab
4. Click **"Connect"** - opens terminal in browser

### Option 3: PuTTY (Windows)

1. Download and install [PuTTY](https://www.putty.org/)
2. Convert `.pem` to `.ppk` using PuTTYgen
3. Use PuTTY to connect with the `.ppk` key

---

## Install Dependencies

### Update System

```bash
# Update package lists
sudo apt-get update

# Upgrade installed packages
sudo apt-get upgrade -y

# Install basic utilities
sudo apt-get install -y git curl wget vim htop unzip
```

### Install Docker

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add current user to docker group
sudo usermod -aG docker ubuntu

# Enable Docker to start on boot
sudo systemctl enable docker

# Start Docker service
sudo systemctl start docker

# Log out and back in for group changes to take effect
exit

# Reconnect to EC2
ssh -i emotion-backend-key.pem ubuntu@YOUR_EC2_PUBLIC_IP

# Verify Docker installation
docker --version
# Should show: Docker version 24.x.x or later
```

### Install Docker Compose

```bash
# Download Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make it executable
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker-compose --version
# Should show: Docker Compose version v2.24.0 or later
```

---

## Deploy with Docker (Recommended)

### Step 1: Clone Repository

```bash
# Create project directory
sudo mkdir -p /opt/emotion-backend
sudo chown ubuntu:ubuntu /opt/emotion-backend
cd /opt/emotion-backend

# Clone from GitHub (replace with your repo URL)
git clone https://github.com/cuxle/selfImprove.git .

# Or clone specific backend directory
git clone https://github.com/cuxle/selfImprove.git
cd selfImprove/backend
```

### Step 2: Configure Environment

```bash
# Navigate to backend directory
cd /opt/emotion-backend/backend

# Create production environment file
cp .env.example .env

# Edit environment variables
nano .env
```

**Edit `.env` file with your settings:**

```bash
# Database Configuration
MYSQL_ROOT_PASSWORD=YourStrongPassword123!
DATABASE_URL=mysql+pymysql://root:YourStrongPassword123!@db:3306/emotion_legacy_db

# JWT Configuration - MUST CHANGE!
SECRET_KEY=your-super-secret-key-min-32-chars-change-this-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440

# Application Configuration
APP_NAME=Emotion Legacy API
DEBUG=False
API_VERSION=v1

# CORS Configuration
ALLOWED_ORIGINS=http://YOUR_EC2_PUBLIC_IP,http://YOUR_DOMAIN.com,https://YOUR_DOMAIN.com

# Optional: WeChat Configuration
# WECHAT_APP_ID=your_wechat_app_id
# WECHAT_APP_SECRET=your_wechat_app_secret
```

**Generate a secure SECRET_KEY:**

```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
# Copy the output and paste it as SECRET_KEY in .env
```

**Save and exit:** Press `Ctrl+X`, then `Y`, then `Enter`

### Step 3: Build and Start Services

```bash
# Build and start all containers
docker-compose up -d --build

# This will:
# 1. Build the FastAPI application container
# 2. Start MySQL database container
# 3. Start Nginx reverse proxy (if configured)
```

### Step 4: Verify Deployment

```bash
# Check running containers
docker-compose ps

# Should see:
# - emotion_api    (running)
# - emotion_db     (running)
# - emotion_nginx  (running, if configured)

# Check logs
docker-compose logs -f

# Check API health
curl http://localhost:8000/health
# Should return: {"status":"healthy"}

# Test from outside
curl http://YOUR_EC2_PUBLIC_IP/health
```

### Step 5: Initialize Database

```bash
# Enter the API container
docker exec -it emotion_api bash

# Initialize database tables
python -c "from app.config.database import Base, engine; Base.metadata.create_all(bind=engine)"

# Exit container
exit
```

### Step 6: Test API Endpoints

```bash
# Check API documentation (if not disabled)
curl http://YOUR_EC2_PUBLIC_IP/docs

# Or open in browser:
# http://YOUR_EC2_PUBLIC_IP/docs
```

---

## Alternative: Manual Deployment

If you prefer not to use Docker:

### Install Python and Dependencies

```bash
# Install Python 3.11
sudo apt-get install -y python3.11 python3.11-venv python3-pip

# Install MySQL
sudo apt-get install -y mysql-server
sudo systemctl start mysql
sudo systemctl enable mysql

# Secure MySQL
sudo mysql_secure_installation

# Create database
sudo mysql -u root -p
```

```sql
CREATE DATABASE emotion_legacy_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'emotion_user'@'localhost' IDENTIFIED BY 'YourStrongPassword123!';
GRANT ALL PRIVILEGES ON emotion_legacy_db.* TO 'emotion_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### Deploy Application

```bash
# Create project directory
sudo mkdir -p /opt/emotion-backend
sudo chown ubuntu:ubuntu /opt/emotion-backend
cd /opt/emotion-backend

# Clone repository
git clone https://github.com/cuxle/selfImprove.git
cd selfImprove/backend

# Create virtual environment
python3.11 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
nano .env
# Update DATABASE_URL to use localhost instead of 'db'
# DATABASE_URL=mysql+pymysql://emotion_user:YourStrongPassword123!@localhost:3306/emotion_legacy_db

# Initialize database
python -c "from app.config.database import Base, engine; Base.metadata.create_all(bind=engine)"

# Test run
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

### Install Process Manager (Supervisor)

```bash
sudo apt-get install -y supervisor

# Create supervisor config
sudo nano /etc/supervisor/conf.d/emotion-api.conf
```

**Add configuration:**

```ini
[program:emotion-api]
command=/opt/emotion-backend/selfImprove/backend/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
directory=/opt/emotion-backend/selfImprove/backend
user=ubuntu
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/var/log/emotion-api.log
environment=PATH="/opt/emotion-backend/selfImprove/backend/venv/bin"
```

**Start service:**

```bash
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start emotion-api
sudo supervisorctl status
```

---

## Configure Domain and SSL

### Step 1: Point Domain to EC2

1. Go to your domain registrar (GoDaddy, Namecheap, etc.)
2. Add an A record:
   ```
   Type: A
   Name: @ (or your subdomain)
   Value: YOUR_EC2_PUBLIC_IP
   TTL: 600
   ```

### Step 2: Install Certbot for SSL

```bash
# Install Certbot
sudo apt-get install -y certbot python3-certbot-nginx

# Install Nginx (if not using Docker Nginx)
sudo apt-get install -y nginx

# Obtain SSL certificate
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Follow the prompts
# Enter your email
# Agree to terms
# Choose to redirect HTTP to HTTPS
```

### Step 3: Configure Nginx (if not using Docker)

```bash
sudo nano /etc/nginx/sites-available/emotion-api
```

**Add configuration:**

```nginx
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    client_max_body_size 50M;
}
```

**Enable and restart:**

```bash
sudo ln -s /etc/nginx/sites-available/emotion-api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### Step 4: Auto-renew SSL Certificate

```bash
# Test auto-renewal
sudo certbot renew --dry-run

# Certbot automatically sets up a cron job for renewal
# Verify it's scheduled
sudo systemctl status certbot.timer
```

---

## Monitoring and Maintenance

### View Logs

```bash
# Docker logs
docker-compose logs -f api

# Manual deployment logs
sudo tail -f /var/log/emotion-api.log

# Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### Resource Monitoring

```bash
# Install htop
sudo apt-get install -y htop

# Monitor resources
htop

# Check disk usage
df -h

# Check memory
free -h

# Check Docker stats
docker stats
```

### Database Backup

```bash
# Create backup script
nano ~/backup.sh
```

```bash
#!/bin/bash
BACKUP_DIR="/home/ubuntu/backups"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR

# For Docker deployment
docker exec emotion_db mysqldump -u root -p'YourStrongPassword123!' emotion_legacy_db > $BACKUP_DIR/emotion_db_$DATE.sql

# Compress backup
gzip $BACKUP_DIR/emotion_db_$DATE.sql

# Keep only last 7 days
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete

echo "Backup completed: $BACKUP_DIR/emotion_db_$DATE.sql.gz"
```

```bash
# Make executable
chmod +x ~/backup.sh

# Test backup
./backup.sh

# Schedule daily backups (2 AM)
crontab -e
# Add: 0 2 * * * /home/ubuntu/backup.sh
```

### Update Application

```bash
# Pull latest code
cd /opt/emotion-backend
git pull

# Docker deployment
docker-compose down
docker-compose up -d --build

# Manual deployment
source venv/bin/activate
pip install -r requirements.txt
sudo supervisorctl restart emotion-api
```

---

## Cost Optimization

### EC2 Instance Types and Pricing

| Instance Type | vCPU | RAM | Price/Month (us-east-1) | Use Case |
|--------------|------|-----|-------------------------|----------|
| t2.micro | 1 | 1 GB | Free tier / $8.50 | Testing |
| t3.small | 2 | 2 GB | ~$15 | Small apps |
| t3.medium | 2 | 4 GB | ~$30 | Production |
| t3a.medium | 2 | 4 GB | ~$27 | Budget option |

**Free Tier Benefits:**
- 750 hours/month of t2.micro for 12 months
- 30 GB EBS storage
- Perfect for learning and testing

### Cost Saving Tips

1. **Use Reserved Instances** - Save up to 72% for 1-3 year commitments
2. **Stop instances when not needed** - No charge for stopped instances (only storage)
3. **Use Elastic IP carefully** - Charged if not attached to running instance
4. **Monitor CloudWatch** - Set billing alerts
5. **Use t3/t3a** - Better price/performance than t2

### Set Up Billing Alert

1. Go to **AWS Billing Console**
2. Click **"Budgets"** → **"Create budget"**
3. Set monthly budget (e.g., $20)
4. Configure email notifications at 80% and 100%

---

## Troubleshooting

### Cannot Connect to EC2

```bash
# Check instance is running
# Check security group allows SSH from your IP
# Verify key file permissions
chmod 400 emotion-backend-key.pem

# Use verbose mode to debug
ssh -v -i emotion-backend-key.pem ubuntu@YOUR_EC2_PUBLIC_IP
```

### API Not Accessible

```bash
# Check if service is running
docker-compose ps
# or
sudo supervisorctl status

# Check if port is listening
sudo netstat -tulpn | grep 8000

# Check security group allows port 80/443/8000
# Check if Docker is running
sudo systemctl status docker
```

### Database Connection Error

```bash
# Check MySQL is running
docker-compose ps db
# or
sudo systemctl status mysql

# Check database exists
docker exec -it emotion_db mysql -u root -p
SHOW DATABASES;

# Check environment variables
cat .env | grep DATABASE
```

### Out of Memory

```bash
# Check memory usage
free -h

# Check Docker memory
docker stats

# Solutions:
# 1. Upgrade to larger instance type
# 2. Add swap space
# 3. Reduce Docker workers in docker-compose.yml
```

---

## Next Steps

1. ✅ Configure domain name
2. ✅ Set up SSL certificate
3. ✅ Configure automatic backups
4. ✅ Set up monitoring
5. ✅ Configure Flutter app to use your API URL
6. ✅ Test all endpoints
7. ✅ Set up CloudWatch logging (optional)
8. ✅ Configure auto-scaling (optional)

---

## Useful Commands Reference

### Docker Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# Restart service
docker-compose restart api

# Rebuild containers
docker-compose up -d --build

# Enter container
docker exec -it emotion_api bash

# View container stats
docker stats
```

### System Management

```bash
# Check service status
sudo systemctl status docker
sudo systemctl status nginx

# Restart services
sudo systemctl restart docker
sudo systemctl restart nginx

# View system logs
sudo journalctl -u docker
sudo journalctl -u nginx
```

### Supervisor Commands (Manual Deployment)

```bash
# Status
sudo supervisorctl status

# Start/Stop/Restart
sudo supervisorctl start emotion-api
sudo supervisorctl stop emotion-api
sudo supervisorctl restart emotion-api

# Reload config
sudo supervisorctl reread
sudo supervisorctl update
```

---

## Support

For issues specific to this project:
- Check [DEVELOPMENT.md](DEVELOPMENT.md) for local development
- Check [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for general deployment
- Create an issue on GitHub

For AWS EC2 issues:
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [AWS Support](https://aws.amazon.com/support/)

---

**Deployment Checklist:**

- [ ] EC2 instance created and running
- [ ] Security groups configured correctly
- [ ] Docker and Docker Compose installed
- [ ] Code cloned to server
- [ ] Environment variables configured
- [ ] Database initialized
- [ ] API responding to health checks
- [ ] Domain configured (if applicable)
- [ ] SSL certificate installed (if applicable)
- [ ] Backups scheduled
- [ ] Monitoring configured
- [ ] Billing alerts set up

**Congratulations! Your backend is now deployed on AWS EC2! 🎉**
