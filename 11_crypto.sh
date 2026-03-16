#!/usr/bin/env bash
set -euo pipefail

OPENSSL_CONF="/etc/ssl/openssl.cnf"
BACKUP="/etc/ssl/openssl.cnf.bak.$(date +%s)"

if [ -f "${OPENSSL_CONF}" ]; then
  echo "[*] Backing up ${OPENSSL_CONF} to ${BACKUP}"
  cp "${OPENSSL_CONF}" "${BACKUP}"
fi

echo "[*] Ensuring SECLEVEL=2 in ${OPENSSL_CONF}"
if ! grep -q "SECLEVEL" "${OPENSSL_CONF}"; then
  cat <<'EOF' >> "${OPENSSL_CONF}"

# Hardening block
[system_default_sect]
CipherString = DEFAULT:@SECLEVEL=2
EOF
fi

echo "[*] For per-service TLS hardening, adjust configs of nginx, apache, etc."
