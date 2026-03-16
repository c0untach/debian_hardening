#!/usr/bin/env bash
set -euo pipefail

SYSCTL_DIR="/etc/sysctl.d"
NETWORK_CONF="${SYSCTL_DIR}/99-network-hardening.conf"
IPV6_CONF="${SYSCTL_DIR}/99-disable-ipv6.conf"

mkdir -p "${SYSCTL_DIR}"

echo "[*] Writing IPv4/stack hardening to ${NETWORK_CONF}"
cat > "${NETWORK_CONF}" <<'EOF'
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_sack = 0
net.ipv4.ip_forward = 0
EOF

echo "[*] Writing IPv6 disable (if desired) to ${IPV6_CONF}"
cat > "${IPV6_CONF}" <<'EOF'
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.all.autoconf = 0
net.ipv6.conf.default.autoconf = 0
net.ipv6.conf.all.accept_ra = 0
net.ipv6.conf.default.accept_ra = 0
EOF

echo "[*] Applying sysctl settings"
sysctl --system
