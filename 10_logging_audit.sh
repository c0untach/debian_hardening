#!/usr/bin/env bash
set -euo pipefail

echo "[*] Installing auditd"
apt update
apt install -y auditd audispd-plugins

systemctl enable --now auditd

AUDIT_RULES="/etc/audit/rules.d/99-hardening.rules"

echo "[*] Writing audit rules to ${AUDIT_RULES}"
cat > "${AUDIT_RULES}" <<'EOF'
-w /etc/passwd -p wa -k passwd_changes
-w /etc/shadow -p wa -k shadow_changes
-w /etc/sudoers -p wa -k sudoers_changes
-w /sbin/modprobe -p x -k module_load
EOF

echo "[*] Reloading audit rules"
augenrules --load || true

echo "[*] Enabling persistent journald"
mkdir -p /var/log/journal
systemctl restart systemd-journald
