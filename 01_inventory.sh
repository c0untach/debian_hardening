#!/usr/bin/env bash
set -euo pipefail

echo "[*] Systemd units:"
systemctl list-unit-files

echo "[*] Enabled services:"
systemctl list-unit-files --state=enabled

echo "[*] Listening ports:"
ss -tulpen

echo "[*] Cron jobs:"
crontab -l || true
ls -al /etc/cron.* || true

echo "[*] Timers:"
systemctl list-timers || true

echo "[*] Kernel modules:"
lsmod

echo "[*] SUID/SGID binaries:"
find / -xdev -perm -4000 -type f 2>/dev/null
find / -xdev -perm -2000 -type f 2>/dev/null

echo "[*] World-writable files:"
find / -xdev -type f -perm -0002 2>/dev/null

echo "[*] World-writable directories:"
find / -xdev -type d -perm -0002 2>/dev/null

echo "[*] Installed packages:"
dpkg -l

echo "[*] Users:"
awk -F: '{print $1, $3, $7}' /etc/passwd

echo "[*] Groups:"
getent group
