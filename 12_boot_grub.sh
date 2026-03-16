#!/usr/bin/env bash
set -euo pipefail

echo "[*] Generating GRUB PBKDF2 password hash"
echo "    Run: grub-mkpasswd-pbkdf2"
echo "    Then add to /etc/grub.d/40_custom, e.g.:"
echo '    set superusers="root"'
echo '    password_pbkdf2 root <hash>'
echo
echo "[*] Disabling GRUB recovery entries in /etc/default/grub"
if grep -q "^GRUB_DISABLE_RECOVERY" /etc/default/grub; then
  sed -i 's/^GRUB_DISABLE_RECOVERY.*/GRUB_DISABLE_RECOVERY=true/' /etc/default/grub
else
  echo 'GRUB_DISABLE_RECOVERY=true' >> /etc/default/grub
fi

echo "[*] After editing GRUB configs, run: update-grub"
