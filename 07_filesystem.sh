#!/usr/bin/env bash
set -euo pipefail

FSTAB="/etc/fstab"
BACKUP="/etc/fstab.bak.$(date +%s)"

echo "[*] Backing up ${FSTAB} to ${BACKUP}"
cp "${FSTAB}" "${BACKUP}"

echo "[*] Appending example hardened mounts to ${FSTAB}"
cat <<'EOF' >> "${FSTAB"
# Hardening block (review and adjust devices/FS types!)
# tmpfs /tmp tmpfs defaults,noexec,nosuid,nodev 0 0
# /tmp /var/tmp none bind 0 0
# /home ext4 defaults,nodev 0 2
# /var ext4 defaults,nosuid 0 2
# /var/log ext4 defaults,noexec,nosuid,nodev 0 2
EOF

echo "[*] fstab updated with commented examples. Edit ${FSTAB} and uncomment only what matches your layout."
