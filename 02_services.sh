#!/usr/bin/env bash
set -euo pipefail

disable_if_exists() {
  local unit="$1"
  if systemctl list-unit-files | grep -q "^${unit}"; then
    echo "[*] Disabling ${unit}"
    systemctl disable --now "${unit}" || true
  fi
}

# Common noisy/unneeded services (adjust to your environment)
for svc in \
  avahi-daemon \
  cups \
  bluetooth \
  rpcbind \
  exim4 \
  ModemManager \
  wpa_supplicant \
  triggerhappy \
  geoclue \
  nfs-server \
  nfs-kernel-server \
  nfs-common \
  udisks2 \
; do
  disable_if_exists "${svc}.service"
done

echo "[*] Socket-activated units:"
systemctl list-sockets

echo "[*] Timers:"
systemctl list-timers
