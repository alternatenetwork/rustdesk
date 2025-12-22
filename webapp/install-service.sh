#!/bin/bash

# ANTConnect Configuration Server Installation Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root (use sudo)${NC}"
    exit 1
fi

echo -e "${GREEN}ANTConnect Configuration Server Installation${NC}"
echo "============================================="

# Create installation directory
echo -e "\n${YELLOW}Creating installation directory...${NC}"
mkdir -p /opt/webapp

# Check if JAR file exists
if [ ! -f "target/custom-config-server-1.0.0.jar" ]; then
    echo -e "${RED}JAR file not found. Please build the project first with: mvn clean package${NC}"
    exit 1
fi

# Copy JAR file
echo -e "${YELLOW}Copying application files...${NC}"
cp target/custom-config-server-1.0.0.jar /opt/webapp/

# Set permissions (root owns everything)
echo -e "${YELLOW}Setting permissions...${NC}"
chown -R root:root /opt/webapp
chmod 755 /opt/webapp
chmod 644 /opt/webapp/*.jar

# Copy systemd service file
echo -e "${YELLOW}Installing systemd service...${NC}"
cp antconnect-config.service /etc/systemd/system/

# Reload systemd
systemctl daemon-reload

# Enable and start service
echo -e "${YELLOW}Enabling and starting service...${NC}"
systemctl enable antconnect-config.service
systemctl start antconnect-config.service

# Check service status
sleep 2
if systemctl is-active --quiet antconnect-config.service; then
    echo -e "\n${GREEN}✓ Service installed and started successfully!${NC}"
    echo -e "\nService status:"
    systemctl status antconnect-config.service --no-pager
    echo -e "\n${GREEN}The server is now running on port 8080${NC}"
    echo -e "You can access it at: http://localhost:8080/custom.txt"
else
    echo -e "\n${RED}✗ Service failed to start${NC}"
    echo -e "Check logs with: journalctl -u antconnect-config.service -n 50"
    exit 1
fi

echo -e "\n${GREEN}Installation complete!${NC}"
echo -e "\nUseful commands:"
echo -e "  View logs:         ${YELLOW}journalctl -u antconnect-config -f${NC}"
echo -e "  Restart service:   ${YELLOW}sudo systemctl restart antconnect-config${NC}"
echo -e "  Stop service:      ${YELLOW}sudo systemctl stop antconnect-config${NC}"
echo -e "  Check status:      ${YELLOW}sudo systemctl status antconnect-config${NC}"