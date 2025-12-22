#!/bin/bash

# ANTConnect Configuration Server Uninstallation Script

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

echo -e "${GREEN}ANTConnect Configuration Server Uninstallation${NC}"
echo "==============================================="

# Stop service if running
if systemctl is-active --quiet antconnect-config.service; then
    echo -e "\n${YELLOW}Stopping service...${NC}"
    systemctl stop antconnect-config.service
fi

# Disable service
if systemctl is-enabled --quiet antconnect-config.service 2>/dev/null; then
    echo -e "${YELLOW}Disabling service...${NC}"
    systemctl disable antconnect-config.service
fi

# Remove service file
echo -e "${YELLOW}Removing service file...${NC}"
rm -f /etc/systemd/system/antconnect-config.service

# Reload systemd
systemctl daemon-reload

# Remove installation directory
if [ -d "/opt/webapp" ]; then
    echo -e "${YELLOW}Removing installation directory...${NC}"
    rm -rf /opt/webapp
fi

echo -e "\n${GREEN}✓ Uninstallation complete!${NC}"