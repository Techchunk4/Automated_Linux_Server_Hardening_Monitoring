#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# 🛡️ Linux Server Hardening Script (CIS Benchmark + Best Practices)
# Author: Your Name
# Date: $(date +%Y-%m-%d)
# Version: 1.0.0
# ------------------------------------------------------------------------------

set -eo pipefail  # Exit on error, pipefail enabled

# Configuration
LOG_FILE="/var/log/hardening-$(date +%Y%m%d).log"
BACKUP_DIR="/etc/backup-$(date +%Y%m%d)"
SSH_PORT="22"  # Customize if using non-standard port

# Colors for logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ------------------------------------------------------------------------------
# 🔒 INITIAL SETUP
# ------------------------------------------------------------------------------

# Validate root privileges
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}[ERROR] This script must be run as root${NC}" >&2
    exit 1
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"
echo -e "${YELLOW}[INFO] Backups stored in: $BACKUP_DIR${NC}"

# Initialize log file
exec > >(tee -a "$LOG_FILE") 2>&1
echo -e "\n$(date) - Starting system hardening" >> "$LOG_FILE"

# ------------------------------------------------------------------------------
# 🚀 MAIN HARDENING FUNCTIONS
# ------------------------------------------------------------------------------

disable_unused_services() {
    echo -e "${YELLOW}[TASK] Disabling unnecessary services...${NC}"
    local services=("cups" "avahi-daemon" "rpcbind" "nfs-kernel-server")
    
    for svc in "${services[@]}"; do
        if systemctl is-active --quiet "$svc"; then
            systemctl stop "$svc"
            systemctl disable "$svc"
            echo -e "${GREEN}[OK] Stopped & disabled: $svc${NC}"
        else
            echo -e "[SKIP] $svc not active"
        fi
    done
}

harden_ssh() {
    echo -e "${YELLOW}[TASK] Hardening SSH configuration...${NC}"
    local ssh_config="/etc/ssh/sshd_config"
    cp "$ssh_config" "$BACKUP_DIR/sshd_config.bak"
    
    # CIS Benchmark SSH rules
    declare -A ssh_settings=(
        ["Protocol"]="2"
        ["PermitRootLogin"]="no"
        ["X11Forwarding"]="no"
        ["MaxAuthTries"]="4"
        ["ClientAliveInterval"]="300"
        ["PasswordAuthentication"]="no"
    )
    
    for key in "${!ssh_settings[@]}"; do
        if grep -q "^$key" "$ssh_config"; then
            sed -i "s/^$key.*/$key ${ssh_settings[$key]}/" "$ssh_config"
        else
            echo "$key ${ssh_settings[$key]}" >> "$ssh_config"
        fi
    done
    
    # Restart SSH carefully (with fallback)
    if sshd -t; then
        systemctl restart sshd
        echo -e "${GREEN}[OK] SSH hardened and restarted${NC}"
    else
        echo -e "${RED}[ERROR] SSH config test failed. Reverting...${NC}"
        cp "$BACKUP_DIR/sshd_config.bak" "$ssh_config"
        exit 1
    fi
}

configure_firewall() {
    echo -e "${YELLOW}[TASK] Configuring UFW firewall...${NC}"
    
    if ! command -v ufw &> /dev/null; then
        apt-get install ufw -y || yum install ufw -y
    fi
    
    ufw --force reset
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow "$SSH_PORT"
    ufw allow 80/tcp   # HTTP
    ufw allow 443/tcp  # HTTPS
    ufw --force enable
    
    systemctl enable ufw
    echo -e "${GREEN}[OK] UFW configured with default deny policy${NC}"
}

secure_shared_memory() {
    echo -e "${YELLOW}[TASK] Securing shared memory...${NC}"
    
    if ! grep -q "tmpfs /run/shm tmpfs" /etc/fstab; then
        echo "tmpfs /run/shm tmpfs defaults,noexec,nosuid,nodev 0 0" >> /etc/fstab
        mount -o remount /run/shm
        echo -e "${GREEN}[OK] /run/shm secured with noexec,nosuid,nodev${NC}"
    else
        echo -e "[SKIP] /run/shm already secured"
    fi
}

set_file_permissions() {
    echo -e "${YELLOW}[TASK] Setting strict file permissions...${NC}"
    
    chmod 644 /etc/passwd
    chmod 600 /etc/shadow
    chmod 644 /etc/group
    chown root:root /etc/passwd /etc/shadow /etc/group
    
    echo -e "${GREEN}[OK] Critical file permissions updated${NC}"
}

disable_ipv6() {
    echo -e "${YELLOW}[TASK] Disabling IPv6 (if not needed)...${NC}"
    
    if [[ $(ip a | grep -c inet6) -eq 0 ]]; then
        cat >> /etc/sysctl.conf <<- EOF
        # IPv6 disabled by hardening script
        net.ipv6.conf.all.disable_ipv6 = 1
        net.ipv6.conf.default.disable_ipv6 = 1
        EOF
        
        sysctl -p
        echo -e "${GREEN}[OK] IPv6 disabled${NC}"
    else
        echo -e "[SKIP] IPv6 is in use (not disabled)"
    fi
}

# ------------------------------------------------------------------------------
# 🏁 EXECUTION & VALIDATION
# ------------------------------------------------------------------------------

main() {
    echo -e "\n${YELLOW}=== LINUX HARDENING SCRIPT ===${NC}"
    
    disable_unused_services
    harden_ssh
    configure_firewall
    secure_shared_memory
    set_file_permissions
    disable_ipv6
    
    echo -e "\n${GREEN}✅ Hardening completed at $(date)${NC}"
    echo -e "Review logs: ${YELLOW}$LOG_FILE${NC}"
    echo -e "Backups: ${YELLOW}$BACKUP_DIR${NC}"
}

main "$@"