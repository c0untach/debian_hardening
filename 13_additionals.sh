#!/usr/bin/env bash
set -euo pipefail

echo "[*] Updating package lists"
apt update

###############################################################################
# 1. Install Lynis-recommended security tools
###############################################################################

echo "[*] Installing AIDE (file integrity monitoring)"
apt install -y aide
echo "[*] Initializing AIDE database (this may take a while)"
aideinit || true
if [ -f /var/lib/aide/aide.db.new ]; then
  mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
fi

echo "[*] Installing Fail2ban (intrusion prevention)"
apt install -y fail2ban
systemctl enable --now fail2ban

echo "[*] Installing Rkhunter (rootkit detection)"
apt install -y rkhunter
rkhunter --update || true

echo "[*] Installing Chkrootkit (additional rootkit scanner)"
apt install -y chkrootkit

echo "[*] Installing Sysstat (system accounting)"
apt install -y sysstat
systemctl enable --now sysstat

echo "[*] Installing Acct (process accounting)"
apt install -y acct
systemctl enable --now acct

echo "[*] Installing Chrony (time synchronization)"
apt install -y chrony
systemctl enable --now chrony

echo "[*] Ensuring Rsyslog is installed"
apt install -y rsyslog
systemctl enable --now rsyslog

echo "[*] Ensuring Logrotate is installed"
apt install -y logrotate

###############################################################################
# 2. Remove world-writable files (Lynis check)
###############################################################################

echo "[*] Removing world-writable permissions from files"
find / -xdev -type f -perm -0002 -exec chmod o-w {} \; 2>/dev/null || true

echo "[*] Removing world-writable permissions from directories"
find / -xdev -type d -perm -0002 -exec chmod o-w {} \; 2>/dev/null || true

###############################################################################
# 3. Remove unnecessary SUID/SGID binaries (Lynis check)
###############################################################################

remove_suid() {
  local bin="$1"
  if [ -f "$bin" ]; then
    echo "[*] Removing SUID bit from $bin"
    chmod u-s "$bin" || true
  fi
}

remove_suid /usr/bin/at
remove_suid /usr/bin/newgrp
remove_suid /usr/bin/chfn
remove_suid /usr/bin/chsh
remove_suid /usr/bin/passwd
remove_suid /usr/bin/gpasswd

###############################################################################
# 4. Update Rkhunter database (Lynis check)
###############################################################################

echo "[*] Running rkhunter --propupd to update baseline"
rkhunter --propupd || true

###############################################################################
# 5. Final message
###############################################################################

echo
echo "[+] Additional Lynis-friendly hardening complete."
echo "[+] Run Lynis again to see score improvements:"
echo "    lynis audit system"
echo
