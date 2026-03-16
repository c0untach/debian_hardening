#!/usr/bin/env bash
set -euo pipefail

SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP="/etc/ssh/sshd_config.bak.$(date +%s)"

echo "[*] Backing up ${SSHD_CONFIG} to ${BACKUP}"
cp "${SSHD_CONFIG}" "${BACKUP}"

echo "[*] Appending hardening settings to ${SSHD_CONFIG}"
cat >> "${SSHD_CONFIG}" <<'EOF'

# Hardening block (added by 04_ssh_hardening.sh)
PasswordAuthentication no
ChallengeResponseAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
AllowAgentForwarding no
AllowTcpForwarding no
X11Forwarding no
PermitUserEnvironment no
Compression no
MaxAuthTries 3
LoginGraceTime 20
# Adjust this to your actual admin user(s)
# AllowUsers adminuser

Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com
KexAlgorithms curve25519-sha256
EOF

echo "[*] SSH config updated. Review ${SSHD_CONFIG} and then run: systemctl restart sshd"
