#!/bin/bash
# EC2 Deployment Script for Emotion Legacy Backend
# This script automates the deployment process on AWS EC2

set -e

echo "========================================="
echo "Emotion Legacy - EC2 Deployment Script"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running on Ubuntu
if [ ! -f /etc/os-release ]; then
    echo -e "${RED}Error: This script is designed for Ubuntu/Debian systems${NC}"
    exit 1
fi

echo -e "${GREEN}Step 1: Updating system packages...${NC}"
sudo apt-get update
sudo apt-get upgrade -y
echo ""

echo -e "${GREEN}Step 2: Installing basic utilities...${NC}"
sudo apt-get install -y git curl wget vim htop unzip
echo ""

echo -e "${GREEN}Step 3: Installing Docker...${NC}"
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    sudo systemctl enable docker
    sudo systemctl start docker
    echo -e "${GREEN}Docker installed successfully${NC}"
else
    echo -e "${YELLOW}Docker already installed${NC}"
fi
echo ""

echo -e "${GREEN}Step 4: Installing Docker Compose...${NC}"
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}Docker Compose installed successfully${NC}"
else
    echo -e "${YELLOW}Docker Compose already installed${NC}"
fi
echo ""

# Verify Docker installation
docker --version
docker-compose --version
echo ""

echo -e "${GREEN}Step 5: Setting up project directory...${NC}"
PROJECT_DIR="/opt/emotion-backend"

# Check if directory exists
if [ -d "$PROJECT_DIR" ]; then
    echo -e "${YELLOW}Project directory already exists at $PROJECT_DIR${NC}"
    read -p "Do you want to remove it and start fresh? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo rm -rf $PROJECT_DIR
        echo -e "${GREEN}Removed existing directory${NC}"
    fi
fi

# Create and set ownership
sudo mkdir -p $PROJECT_DIR
sudo chown $USER:$USER $PROJECT_DIR
cd $PROJECT_DIR
echo ""

echo -e "${GREEN}Step 6: Cloning repository...${NC}"
echo "Please enter the repository URL:"
echo "Example: https://github.com/cuxle/selfImprove.git"
read -p "Repository URL: " REPO_URL

if [ -z "$REPO_URL" ]; then
    echo -e "${RED}Error: Repository URL cannot be empty${NC}"
    exit 1
fi

git clone $REPO_URL .
cd backend
echo ""

echo -e "${GREEN}Step 7: Configuring environment...${NC}"

if [ ! -f .env ]; then
    cp .env.example .env
    echo -e "${YELLOW}Created .env file from .env.example${NC}"
    echo ""
    
    # Generate a secure SECRET_KEY
    SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(32))" 2>/dev/null || openssl rand -base64 32)
    
    # Get server's public IP
    PUBLIC_IP=$(curl -s http://checkip.amazonaws.com/)
    
    # Update .env file
    sed -i "s/your-secret-key-change-this-in-production/$SECRET_KEY/" .env
    sed -i "s/DEBUG=True/DEBUG=False/" .env
    
    echo -e "${GREEN}Generated secure SECRET_KEY${NC}"
    echo -e "${GREEN}Server Public IP: $PUBLIC_IP${NC}"
    echo ""
    echo -e "${YELLOW}IMPORTANT: Please edit .env file and configure:${NC}"
    echo "1. MYSQL_ROOT_PASSWORD - Set a strong database password"
    echo "2. DATABASE_URL - Update with your MySQL password"
    echo "3. ALLOWED_ORIGINS - Add your domain or IP"
    echo ""
    echo "Press Enter to edit .env file now, or Ctrl+C to exit and edit manually later"
    read -p ""
    nano .env
else
    echo -e "${YELLOW}.env file already exists${NC}"
fi
echo ""

echo -e "${GREEN}Step 8: Building and starting services...${NC}"
docker-compose up -d --build
echo ""

echo -e "${GREEN}Step 9: Waiting for services to start...${NC}"
sleep 10

# Check if containers are running
if docker-compose ps | grep -q "Up"; then
    echo -e "${GREEN}Containers are running!${NC}"
else
    echo -e "${RED}Error: Containers failed to start${NC}"
    echo "Check logs with: docker-compose logs"
    exit 1
fi
echo ""

echo -e "${GREEN}Step 10: Initializing database...${NC}"
docker exec -it emotion_api python -c "from app.config.database import Base, engine; Base.metadata.create_all(bind=engine)" || true
echo ""

echo -e "${GREEN}Step 11: Testing API...${NC}"
sleep 5
if curl -s http://localhost:8000/health | grep -q "healthy"; then
    echo -e "${GREEN}API is responding correctly!${NC}"
else
    echo -e "${YELLOW}Warning: API health check failed. Check logs with: docker-compose logs api${NC}"
fi
echo ""

# Get public IP
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com/)

echo ""
echo "========================================="
echo -e "${GREEN}Deployment Complete!${NC}"
echo "========================================="
echo ""
echo "Your backend is now running at:"
echo "  - Local: http://localhost:8000"
echo "  - Public: http://$PUBLIC_IP:8000"
echo ""
echo "API Documentation:"
echo "  - Swagger UI: http://$PUBLIC_IP:8000/docs"
echo "  - ReDoc: http://$PUBLIC_IP:8000/redoc"
echo ""
echo "Useful commands:"
echo "  docker-compose ps              # View running containers"
echo "  docker-compose logs -f         # View logs"
echo "  docker-compose restart         # Restart services"
echo "  docker-compose down            # Stop services"
echo "  docker-compose up -d --build   # Rebuild and restart"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Configure your domain name to point to: $PUBLIC_IP"
echo "2. Set up SSL certificate using certbot"
echo "3. Update your Flutter app API URL to: http://$PUBLIC_IP:8000"
echo "4. Set up database backups"
echo ""
echo "For detailed instructions, see EC2_DEPLOYMENT.md"
echo ""
echo -e "${YELLOW}IMPORTANT: If you made changes to the Docker group, you may need to log out and back in${NC}"
echo ""
