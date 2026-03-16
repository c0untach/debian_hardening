#!/usr/bin/env bash
set -euo pipefail

echo "[*] Setting default umask to 027 in /etc/profile (if not present)"
if ! grep -q "umask 027" /etc/profile; then
  echo "umask 027" >> /etc/profile
fi

PWQ="/etc/security/pwquality.conf"
if [ -f "${PWQ}" ]; then
  echo "[*] Updating ${PWQ}"
  sed -i 's/^minlen.*/minlen = 14/' "${PWQ}" || true
  sed -i 's/^dcredit.*/dcredit = -1/' "${PWQ}" || echo "dcredit = -1" >> "${PWQ}"
  sed -i 's/^ucredit.*/ucredit = -1/' "${PWQ}" || echo "ucredit = -1" >> "${PWQ}"
  sed -i 's/^ocredit.*/ocredit = -1/' "${PWQ}" || echo "ocredit = -1" >> "${PWQ}"
  sed -i 's/^lcredit.*/lcredit = -1/' "${PWQ}" || echo "lcredit = -1" >> "${PWQ}"
fi

echo "[*] Locking some common system accounts if they exist"
for user in games ftp nobody; do
  if id "${user}" &>/dev/null; then
    usermod -L "${user}" || true
  fi
done

echo "[*] To disable interactive shells for service accounts, run:"
echo "    usermod -s /usr/sbin/nologin <service-account>"
