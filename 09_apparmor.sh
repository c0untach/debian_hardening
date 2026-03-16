#!/usr/bin/env bash
set -euo pipefail

echo "[*] Ensuring AppArmor is installed and enabled"
apt update
apt install -y apparmor apparmor-utils

systemctl enable --now apparmor

echo "[*] Current AppArmor status:"
aa-status || true

echo "[*] Enforcing all loaded profiles"
aa-enforce /etc/apparmor.d/* || true

echo "[*] For custom profiles, use: aa-genprof /path/to/binary"
