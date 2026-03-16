#!/usr/bin/env bash
set -euo pipefail

SYSCTL_DIR="/etc/sysctl.d"
KERNEL_CONF="${SYSCTL_DIR}/99-kernel-hardening.conf"

mkdir -p "${SYSCTL_DIR}"

echo "[*] Writing kernel hardening to ${KERNEL_CONF}"
cat > "${KERNEL_CONF}" <<'EOF'
kernel.kptr_restrict = 2
kernel.dmesg_restrict = 1
kernel.kexec_load_disabled = 1
kernel.yama.ptrace_scope = 2
kernel.unprivileged_bpf_disabled = 1
kernel.sysrq = 0
kernel.core_uses_pid = 1

fs.suid_dumpable = 0
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
fs.protected_fifos = 2
fs.protected_regular = 2
EOF

echo "[*] Applying sysctl settings"
sysctl --system
