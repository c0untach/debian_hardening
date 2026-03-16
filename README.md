# debian_hardening

---

# **High‑Security Debian 11/12/13 Hardening Standard (Paranoid‑Mode, Safe Version)**  
*Manual commands, mixed BIOS/UEFI, systemd-based, non-destructive*

This guide integrates:

- Debian Security Manual  
- CIS Debian Benchmarks  
- NSA Linux Hardening  
- NIST 800‑53  
- Kernel Self‑Protection Project  
- Real-world defensive practices  

It is structured for real-world implementation.

---

# **1. System Inventory and Baseline**

A hardened system begins with a complete understanding of what is installed, running, and exposed.

### Enumerate all systemd units
```
systemctl list-unit-files
systemctl list-units --all
```

### Enumerate all enabled services
```
systemctl list-unit-files --state=enabled
```

### Enumerate all listening ports
```
ss -tulpen
```

### Enumerate all cron jobs
```
crontab -l
ls -al /etc/cron.*
ls -al /etc/systemd/system/*.timer
```

### Enumerate all kernel modules
```
lsmod
```

### Enumerate all SUID/SGID binaries
```
find / -xdev -perm -4000 -type f 2>/dev/null
find / -xdev -perm -2000 -type f 2>/dev/null
```

### Enumerate world-writable files and directories
```
find / -xdev -type f -perm -0002 2>/dev/null
find / -xdev -type d -perm -0002 2>/dev/null
```

### Enumerate all installed packages
```
dpkg -l
```

### Enumerate all user accounts
```
awk -F: '{print $1, $3, $7}' /etc/passwd
```

### Enumerate all groups
```
getent group
```

---

# **2. Service Minimization**

Debian installs many optional services depending on the task selection. Disable everything not explicitly required.

### Disable a service
```
systemctl disable --now <service>
```

### Disable socket-activated services
```
systemctl list-sockets
systemctl disable --now <socket>
```

### Disable timers
```
systemctl list-timers
systemctl disable --now <timer>
```

### Disable path-activated units
```
systemctl list-unit-files --type=path
systemctl disable --now <path-unit>
```

### Disable automount units
```
systemctl list-unit-files --type=automount
systemctl disable --now <unit>
```

### Common safe-to-disable services on Debian
- `avahi-daemon`
- `cups`
- `bluetooth`
- `rpcbind`
- `nfs-*`
- `exim4` (default MTA)
- `ModemManager`
- `wpa_supplicant` (if wired-only)
- `pppd`
- `triggerhappy`
- `udisks2` (servers)
- `geoclue` (desktop only)

---

# **3. Network Hardening**

### Firewall deny-by-default (Debian uses nftables or ufw)

#### nftables (recommended)
```
apt install nftables
systemctl enable --now nftables
```

Default deny:
```
table inet filter {
    chain input {
        type filter hook input priority 0;
        policy drop;
        ct state established,related accept
        iif lo accept
        tcp dport ssh accept
    }
}
```

Apply:
```
nft -f /etc/nftables.conf
```

#### ufw alternative
```
apt install ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw enable
```

---

### Disable IPv6 (if not needed)
```
cat <<EOF >/etc/sysctl.d/disable-ipv6.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOF

sysctl --system
```

### Disable IPv6 autoconfiguration
```
echo "net.ipv6.conf.all.autoconf = 0" >> /etc/sysctl.d/network.conf
```

### Disable IPv6 router advertisements
```
echo "net.ipv6.conf.all.accept_ra = 0" >> /etc/sysctl.d/network.conf
```

### Disable multicast
```
echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >> /etc/sysctl.d/network.conf
```

### Disable source routing
```
echo "net.ipv4.conf.all.accept_source_route = 0" >> /etc/sysctl.d/network.conf
```

### Disable ICMP redirects
```
echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.d/network.conf
```

### Disable sending redirects
```
echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.d/network.conf
```

### Enforce reverse path filtering
```
echo "net.ipv4.conf.all.rp_filter = 1" >> /etc/sysctl.d/network.conf
```

### Disable TCP timestamps
```
echo "net.ipv4.tcp_timestamps = 0" >> /etc/sysctl.d/network.conf
```

### Disable TCP SACK (optional)
```
echo "net.ipv4.tcp_sack = 0" >> /etc/sysctl.d/network.conf
```

### Disable IPv4 forwarding
```
echo "net.ipv4.ip_forward = 0" >> /etc/sysctl.d/network.conf
```

---

# **4. SSH Hardening**

Edit `/etc/ssh/sshd_config`:

### Disable password authentication
```
PasswordAuthentication no
ChallengeResponseAuthentication no
KbdInteractiveAuthentication no
```

### Disable agent forwarding
```
AllowAgentForwarding no
```

### Disable TCP forwarding
```
AllowTcpForwarding no
```

### Disable X11 forwarding
```
X11Forwarding no
```

### Enforce strong ciphers
```
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com
KexAlgorithms curve25519-sha256
```

### Limit login attempts
```
MaxAuthTries 3
LoginGraceTime 20
```

### Restrict users
```
AllowUsers <your-admin-user>
```

### Disable root login
```
PermitRootLogin no
```

### Disable SSH environment variables
```
PermitUserEnvironment no
```

### Disable SSH compression
```
Compression no
```

Restart SSH:
```
systemctl restart sshd
```

---

# **5. Kernel Hardening (sysctl)**

Create `/etc/sysctl.d/hardening.conf`:

```
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

net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_sack = 0
```

Apply:
```
sysctl --system
```

---

# **6. Kernel Hardening (Static)**

### Disable unprivileged user namespaces
```
echo "kernel.unprivileged_userns_clone = 0" >> /etc/sysctl.d/kernel.conf
```

### Disable BPF JIT
```
echo "net.core.bpf_jit_enable = 0" >> /etc/sysctl.d/kernel.conf
```

### Disable dangerous filesystems  
Create `/etc/modprobe.d/blacklist.conf`:

```
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
```

### Disable FireWire/Thunderbolt kernel modules
```
install firewire-core /bin/false
install thunderbolt /bin/false
```

### Disable USB storage (optional)
```
install usb-storage /bin/false
```

---

# **7. Filesystem Hardening**

### Disable core dumps
```
echo "* hard core 0" >> /etc/security/limits.conf
```

### Disable kernel core dumps
```
echo "kernel.core_uses_pid = 1" >> /etc/sysctl.d/kernel.conf
echo "fs.suid_dumpable = 0" >> /etc/sysctl.d/kernel.conf
```

### Enforce noexec on /tmp and /var/tmp
Edit `/etc/fstab`:
```
tmpfs /tmp tmpfs defaults,noexec,nosuid,nodev 0 0
/tmp /var/tmp none bind 0 0
```

### Enforce nodev on /home
```
/home ext4 defaults,nodev 0 2
```

### Enforce nosuid on /var
```
/var ext4 defaults,nosuid 0 2
```

### Enforce noexec on /var/log
```
/var/log ext4 defaults,noexec,nosuid,nodev 0 2
```

---

# **8. Access Control**

### Disable unused shells
```
chsh -s /usr/sbin/nologin <user>
```

### Lock system accounts
```
for user in games ftp nobody; do usermod -L $user; done
```

### Enforce umask
Edit `/etc/profile`:
```
umask 027
```

### Password policy
Edit `/etc/security/pwquality.conf`:
```
minlen = 14
dcredit = -1
ucredit = -1
ocredit = -1
lcredit = -1
```

### Disable interactive login for service accounts
```
usermod -s /usr/sbin/nologin <service-account>
```

---

# **9. Mandatory Access Control (AppArmor)**  
*(Debian uses AppArmor by default)*

### Ensure AppArmor is enabled
```
aa-status
```

### Enforce all profiles
```
aa-enforce /etc/apparmor.d/*
```

### Reload profiles
```
systemctl reload apparmor
```

### Create custom profiles (example)
```
aa-genprof /usr/bin/nginx
```

AppArmor provides strong process isolation.

---

# **10. Logging and Auditing**

### Enable auditd
```
apt install auditd audispd-plugins
systemctl enable --now auditd
```

### Enable persistent journaling
```
mkdir -p /var/log/journal
systemctl restart systemd-journald
```

### Add audit rules
```
-w /etc/passwd -p wa -k passwd_changes
-w /etc/shadow -p wa -k shadow_changes
-w /etc/sudoers -p wa -k sudoers_changes
-w /sbin/modprobe -p x -k module_load
```

---

# **11. Cryptographic Hardening**

### Enforce strong crypto via OpenSSL
Edit `/etc/ssl/openssl.cnf`:

```
CipherString = DEFAULT:@SECLEVEL=2
```

### Disable weak algorithms in SSH
(Already done in SSH section)

### Disable TLS 1.0/1.1 system-wide
```
update-crypto-policies --set FUTURE
```

*(Debian 12+ supports this natively; Debian 11 uses package-specific configs.)*

---

# **12. Boot Chain Integrity**

### Set GRUB password
```
grub-mkpasswd-pbkdf2
```

### Add to `/etc/grub.d/40_custom`:
```
set superusers="root"
password_pbkdf2 root <hash>
```

### Disable GRUB editing
Edit `/etc/default/grub`:
```
GRUB_DISABLE_RECOVERY=true
```

Rebuild:
```
update-grub
```

---

# **13. Monitoring and Maintenance**

### Monthly
- Apply updates  
- Review logs  
- Review auditd alerts  
- Verify AppArmor denials  

### Quarterly
- Review firewall rules  
- Review user accounts  
- Review sudoers  

---
