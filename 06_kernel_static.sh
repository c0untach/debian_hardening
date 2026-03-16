#!/usr/bin/env bash
set -euo pipefail

SYSCTL_DIR="/etc/sysctl.d"
KERNEL_STATIC_CONF="${SYSCTL_DIR}/99-kernel-static.conf"
MODPROBE_CONF="/etc/modprobe.d/99-hardening-blacklist.conf"

mkdir -p "${SYSCTL_DIR}"

echo "[*] Writing static kernel hardening to ${KERNEL_STATIC_CONF}"
cat > "${KERNEL_STATIC_CONF}" <<'EOF'
kernel.unprivileged_userns_clone = 0
net.core.bpf_jit_enable = 0
EOF

echo "[*] Writing module blacklists to ${MODPROBE_CONF}"
cat > "${MODPROBE_CONF}" <<'EOF'
install cramfs /bin/false
install freevxfs /bin/false
install jffs2 /bin/false
install hfs /bin/false
install hfsplus /bin/false
install udf /bin/false
install dccp /bin/false
install sctp /bin/false
install rds /bin/false
install tipc /bin/false
install firewire-core /bin/false
install thunderbolt /bin/false
# Optional:
# install usb-storage /bin/false
EOF

echo "[*] Applying sysctl settings"
sysctl --system

echo "[*] Module blacklist written. Reboot required for full effect."
