# Audit 1 - auditd - syslog LOG_LOCAL3

sudo apt-get -o DPkg::Lock::Timeout=300 update
sudo apt-get -o DPkg::Lock::Timeout=300 -y install auditd
sudo service auditd stop

sed -i -e '/^active/s/=.*/= yes/' /etc/audit/plugins.d/syslog.conf
sed -i -e '/^args/s/=.*/= LOG_INFO LOG_LOCAL3/' /etc/audit/plugins.d/syslog.conf

cat <<'\EOF' >> /etc/audit/rules.d/audit.rules
# Ignore errors
## e.g. caused by users or files not found in the local environment
-i
# Self Auditing ---------------------------------------------------------------
## Audit the audit logs
### Successful and unsuccessful attempts to read information from the audit records
-w /var/log/audit/ -p wra -k auditlog
## Auditd configuration
### Modifications to audit configuration that occur while the audit collection functions are operating
-w /etc/audit/ -p wa -k auditconfig
## Monitor for use of audit management tools
-w /sbin/auditctl -p x -k audittools
-w /sbin/auditd -p x -k audittools
-w /sbin/augenrules -p x -k audittools
-w /sbin/aureport -p x -k audittools
-w /sbin/ausearch -p x -k audittools
-w /sbin/autrace -p x -k audittools
-w /usr/sbin/auditd -p x -k audittools
-w /usr/sbin/augenrules -p x -k audittools
## Access to all audit trails
-a always,exit -F path=/usr/sbin/ausearch -F perm=x -k audittools
-a always,exit -F path=/usr/sbin/aureport -F perm=x -k audittools
-a always,exit -F path=/usr/sbin/aulast -F perm=x -k audittools
-a always,exit -F path=/usr/sbin/aulastlogin -F perm=x -k audittools
-a always,exit -F path=/usr/sbin/auvirt -F perm=x -k audittools
# Filters ---------------------------------------------------------------------
### We put these early because audit is a first match wins system.
## Ignore SELinux AVC records
-a always,exclude -F msgtype=AVC
## Ignore current working directory records
-a always,exclude -F msgtype=CWD
## Cron jobs fill the logs with stuff we normally don't want (works with SELinux)
-a never,user -F subj_type=crond_t
-a never,exit -F subj_type=crond_t
## This is not very interesting and wastes a lot of space if the server is public facing
-a always,exclude -F msgtype=CRYPTO_KEY_USER
## Open VM Tools
-a exit,never -F arch=b64 -S all -F exe=/usr/bin/vmtoolsd
## High Volume Event Filter (especially on Linux Workstations)
-a never,exit -F arch=b64 -F dir=/dev/shm -k sharedmemaccess
-a never,exit -F arch=b64 -F dir=/var/lock/lvm -k locklvm
## FileBeat
-a never,exit -F arch=b64 -F path=/opt/filebeat -k filebeat
## More information on how to filter events
### https://access.redhat.com/solutions/2482221
# Rules -----------------------------------------------------------------------
## Kernel parameters
-w /etc/sysctl.conf -p wa -k sysctl
-w /etc/sysctl.d -p wa -k sysctl
## Kernel module loading and unloading
-a always,exit -F perm=x -F auid!=-1 -F path=/sbin/insmod -k modules
-a always,exit -F perm=x -F auid!=-1 -F path=/sbin/modprobe -k modules
-a always,exit -F perm=x -F auid!=-1 -F path=/sbin/rmmod -k modules
-a always,exit -F arch=b64 -S finit_module -S init_module -S delete_module -F auid!=-1 -k modules
## Modprobe configuration
-w /etc/modprobe.conf -p wa -k modprobe
-w /etc/modprobe.d -p wa -k modprobe
## KExec usage (all actions)
-a always,exit -F arch=b64 -S kexec_load -k KEXEC
## Special files
-a always,exit -F arch=b64 -S mknod -S mknodat -k specialfiles
## Mount operations (only attributable)
-a always,exit -F arch=b64 -S mount -S umount2 -F auid!=-1 -k mount
### NFS mount
-a always,exit -F path=/sbin/mount.nfs -F perm=x -F auid>=500 -F auid!=4294967295 -k T1078_Valid_Accounts
-a always,exit -F path=/usr/sbin/mount.nfs -F perm=x -F auid>=500 -F auid!=4294967295 -k T1078_Valid_Accounts
## Change swap (only attributable)
-a always,exit -F arch=b64 -S swapon -S swapoff -F auid!=-1 -k swap
## Time
-a always,exit -F arch=b64 -F uid!=ntp -S adjtimex -S settimeofday -S clock_settime -k time
### Local time zone
-w /etc/localtime -p wa -k localtime
## Stunnel
-w /usr/sbin/stunnel -p x -k stunnel
-w /usr/bin/stunnel -p x -k stunnel
## Cron configuration & scheduled jobs
-w /etc/cron.allow -p wa -k cron
-w /etc/cron.deny -p wa -k cron
-w /etc/cron.d/ -p wa -k cron
-w /etc/cron.daily/ -p wa -k cron
-w /etc/cron.hourly/ -p wa -k cron
-w /etc/cron.monthly/ -p wa -k cron
-w /etc/cron.weekly/ -p wa -k cron
-w /etc/crontab -p wa -k cron
-w /var/spool/cron/ -p wa -k cron
## User, group, password databases
-w /etc/group -p wa -k etcgroup
-w /etc/passwd -p wa -k etcpasswd
-w /etc/gshadow -k etcgroup
-w /etc/shadow -k etcpasswd
-w /etc/security/opasswd -k opasswd
## Sudoers file changes
-w /etc/sudoers -p wa -k actions
-w /etc/sudoers.d/ -p wa -k actions
## Passwd
-w /usr/bin/passwd -p x -k passwd_modification
## Tools to change group identifiers
-w /usr/sbin/groupadd -p x -k group_modification
-w /usr/sbin/groupmod -p x -k group_modification
-w /usr/sbin/addgroup -p x -k group_modification
-w /usr/sbin/useradd -p x -k user_modification
-w /usr/sbin/userdel -p x -k user_modification
-w /usr/sbin/usermod -p x -k user_modification
-w /usr/sbin/adduser -p x -k user_modification
## Login configuration and information
-w /etc/login.defs -p wa -k login
-w /etc/securetty -p wa -k login
-w /var/log/faillog -p wa -k login
-w /var/log/lastlog -p wa -k login
-w /var/log/tallylog -p wa -k login
## Network Environment
### Changes to hostname
-a always,exit -F arch=b64 -S sethostname -S setdomainname -k network_modifications
### Detect Remote Shell Use
-a always,exit -F arch=b64 -F exe=/bin/bash -F success=1 -S connect -k "remote_shell"
-a always,exit -F arch=b64 -F exe=/usr/bin/bash -F success=1 -S connect -k "remote_shell"
### Successful IPv4 Connections
-a always,exit -F arch=b64 -S connect -F a2=16 -F success=1 -F key=network_connect_4
### Successful IPv6 Connections
-a always,exit -F arch=b64 -S connect -F a2=28 -F success=1 -F key=network_connect_6
### Changes to other files
-w /etc/hosts -p wa -k network_modifications
-w /etc/sysconfig/network -p wa -k network_modifications
-w /etc/sysconfig/network-scripts -p w -k network_modifications
-w /etc/network/ -p wa -k network
-a always,exit -F dir=/etc/NetworkManager/ -F perm=wa -k network_modifications
### Changes to issue
-w /etc/issue -p wa -k etcissue
-w /etc/issue.net -p wa -k etcissue
## System startup scripts
-w /etc/inittab -p wa -k init
-w /etc/init.d/ -p wa -k init
-w /etc/init/ -p wa -k init
## Library search paths
-w /etc/ld.so.conf -p wa -k libpath
-w /etc/ld.so.conf.d -p wa -k libpath
## Systemwide library preloads (LD_PRELOAD)
-w /etc/ld.so.preload -p wa -k systemwide_preloads
## Pam configuration
-w /etc/pam.d/ -p wa -k pam
-w /etc/security/limits.conf -p wa  -k pam
-w /etc/security/limits.d -p wa  -k pam
-w /etc/security/pam_env.conf -p wa -k pam
-w /etc/security/namespace.conf -p wa -k pam
-w /etc/security/namespace.d -p wa -k pam
-w /etc/security/namespace.init -p wa -k pam
## Mail configuration
-w /etc/aliases -p wa -k mail
-w /etc/postfix/ -p wa -k mail
-w /etc/exim4/ -p wa -k mail
## SSH configuration
-w /etc/ssh/sshd_config -k sshd
-w /etc/ssh/sshd_config.d -k sshd
## root ssh key tampering
-w /root/.ssh -p wa -k rootkey
# Systemd
-w /bin/systemctl -p x -k systemd
-w /etc/systemd/ -p wa -k systemd
-w /usr/lib/systemd -p wa -k systemd
## https://systemd.network/systemd.generator.html
-w /etc/systemd/system-generators/ -p wa -k systemd_generator
-w /usr/local/lib/systemd/system-generators/ -p wa -k systemd_generator
-w /usr/lib/systemd/system-generators -p wa -k systemd_generator
-w /etc/systemd/user-generators/ -p wa -k systemd_generator
-w /usr/local/lib/systemd/user-generators/ -p wa -k systemd_generator
-w /lib/systemd/system-generators/ -p wa -k systemd_generator
## SELinux events that modify the system's Mandatory Access Controls (MAC)
-w /etc/selinux/ -p wa -k mac_policy
## Critical elements access failures
-a always,exit -F arch=b64 -S open -F dir=/etc -F success=0 -k unauthedfileaccess
-a always,exit -F arch=b64 -S open -F dir=/bin -F success=0 -k unauthedfileaccess
-a always,exit -F arch=b64 -S open -F dir=/sbin -F success=0 -k unauthedfileaccess
-a always,exit -F arch=b64 -S open -F dir=/usr/bin -F success=0 -k unauthedfileaccess
-a always,exit -F arch=b64 -S open -F dir=/usr/sbin -F success=0 -k unauthedfileaccess
-a always,exit -F arch=b64 -S open -F dir=/var -F success=0 -k unauthedfileaccess
-a always,exit -F arch=b64 -S open -F dir=/home -F success=0 -k unauthedfileaccess
-a always,exit -F arch=b64 -S open -F dir=/srv -F success=0 -k unauthedfileaccess
## Process ID change (switching accounts) applications
-w /bin/su -p x -k priv_esc
-w /usr/bin/sudo -p x -k priv_esc
## Power state
-w /sbin/shutdown -p x -k power
-w /sbin/poweroff -p x -k power
-w /sbin/reboot -p x -k power
-w /sbin/halt -p x -k power
## Session initiation information
-w /var/run/utmp -p wa -k session
-w /var/log/btmp -p wa -k session
-w /var/log/wtmp -p wa -k session
## Discretionary Access Control (DAC) modifications
-a always,exit -F arch=b64 -S chmod  -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S chown -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S fchmod -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S fchmodat -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S fchown -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S fchownat -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S fremovexattr -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S fsetxattr -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S lchown -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S lremovexattr -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S lsetxattr -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S removexattr -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S setxattr -F auid>=1000 -F auid!=-1 -k perm_mod
# Special Rules ---------------------------------------------------------------
## Reconnaissance
-w /usr/bin/whoami -p x -k recon
-w /usr/bin/id -p x -k recon
-w /bin/hostname -p x -k recon
-w /bin/uname -p x -k recon
-w /etc/issue -p r -k recon
-w /etc/hostname -p r -k recon
## Suspicious activity
-w /usr/bin/wget -p x -k susp_activity
-w /usr/bin/curl -p x -k susp_activity
-w /usr/bin/base64 -p x -k susp_activity
-w /bin/nc -p x -k susp_activity
-w /bin/netcat -p x -k susp_activity
-w /usr/bin/ncat -p x -k susp_activity
-w /usr/bin/ss -p x -k susp_activity
-w /usr/bin/netstat -p x -k susp_activity
-w /usr/bin/ssh -p x -k susp_activity
-w /usr/bin/scp -p x -k susp_activity
-w /usr/bin/sftp -p x -k susp_activity
-w /usr/bin/ftp -p x -k susp_activity
-w /usr/bin/socat -p x -k susp_activity
-w /usr/bin/wireshark -p x -k susp_activity
-w /usr/bin/tshark -p x -k susp_activity
-w /usr/bin/rawshark -p x -k susp_activity
-w /usr/bin/rdesktop -p x -k susp_activity
-w /usr/local/bin/rdesktop -p x -k susp_activity
-w /usr/bin/wlfreerdp -p x -k susp_activity
-w /usr/bin/xfreerdp -p x -k susp_activity
-w /usr/local/bin/xfreerdp -p x -k susp_activity
-w /usr/bin/nmap -p x -k susp_activity
## T1002 Data Compressed
-w /usr/bin/zip -p x -k Data_Compressed
-w /usr/bin/gzip -p x -k Data_Compressed
-w /usr/bin/tar -p x -k Data_Compressed
-w /usr/bin/bzip2 -p x -k Data_Compressed
-w /usr/bin/lzip -p x -k Data_Compressed
-w /usr/local/bin/lzip -p x -k Data_Compressed
-w /usr/bin/lz4 -p x -k Data_Compressed
-w /usr/local/bin/lz4 -p x -k Data_Compressed
-w /usr/bin/lzop -p x -k Data_Compressed
-w /usr/local/bin/lzop -p x -k Data_Compressed
-w /usr/bin/plzip -p x -k Data_Compressed
-w /usr/local/bin/plzip -p x -k Data_Compressed
-w /usr/bin/pbzip2 -p x -k Data_Compressed
-w /usr/local/bin/pbzip2 -p x -k Data_Compressed
-w /usr/bin/lbzip2 -p x -k Data_Compressed
-w /usr/local/bin/lbzip2 -p x -k Data_Compressed
-w /usr/bin/pixz -p x -k Data_Compressed
-w /usr/local/bin/pixz -p x -k Data_Compressed
-w /usr/bin/pigz -p x -k Data_Compressed
-w /usr/local/bin/pigz -p x -k Data_Compressed
-w /usr/bin/unpigz -p x -k Data_Compressed
-w /usr/local/bin/unpigz -p x -k Data_Compressed
-w /usr/bin/zstd -p x -k Data_Compressed
-w /usr/local/bin/zstd -p x -k Data_Compressed
## Added to catch netcat on Ubuntu
-w /bin/nc.openbsd -p x -k susp_activity
-w /bin/nc.traditional -p x -k susp_activity
## Sbin suspicious activity
-w /sbin/iptables -p x -k sbin_susp
-w /sbin/ip6tables -p x -k sbin_susp
-w /sbin/ifconfig -p x -k sbin_susp
-w /usr/sbin/arptables -p x -k sbin_susp
-w /usr/sbin/ebtables -p x -k sbin_susp
-w /sbin/xtables-nft-multi -p x -k sbin_susp
-w /usr/sbin/nft -p x -k sbin_susp
-w /usr/sbin/tcpdump -p x -k sbin_susp
-w /usr/sbin/traceroute -p x -k sbin_susp
-w /usr/sbin/ufw -p x -k sbin_susp
## dbus-send invocation
### may indicate privilege escalation CVE-2021-3560
-w /usr/bin/dbus-send -p x -k dbus_send
-w /usr/bin/gdbus -p x -k gdubs_call
## pkexec invocation
### may indicate privilege escalation CVE-2021-4034
-w /usr/bin/pkexec -p x -k pkexec
## Suspicious shells
-w /bin/ash -p x -k susp_shell
-w /bin/csh -p x -k susp_shell
-w /bin/fish -p x -k susp_shell
-w /bin/tcsh -p x -k susp_shell
-w /bin/tclsh -p x -k susp_shell
-w /bin/xonsh -p x -k susp_shell
-w /usr/local/bin/xonsh -p x -k susp_shell
-w /bin/open -p x -k susp_shell
-w /bin/rbash -p x -k susp_shell
### https://github.com/tmux/tmux
-w /bin/tmux -p x -k susp_shell
-w /usr/local/bin/tmux -p x -k susp_shell
## Shell/profile configurations
-w /etc/profile.d/ -p wa -k shell_profiles
-w /etc/profile -p wa -k shell_profiles
-w /etc/shells -p wa -k shell_profiles
-w /etc/bashrc -p wa -k shell_profiles
-w /etc/csh.cshrc -p wa -k shell_profiles
-w /etc/csh.login -p wa -k shell_profiles
-w /etc/fish/ -p wa -k shell_profiles
-w /etc/zsh/ -p wa -k shell_profiles
### https://github.com/xxh/xxh
-w /usr/local/bin/xxh.bash -p x -k susp_shell
-w /usr/local/bin/xxh.xsh -p x -k susp_shell
-w /usr/local/bin/xxh.zsh -p x -k susp_shell
## Injection
### These rules watch for code injection by the ptrace facility.
### This could indicate someone trying to do something bad or just debugging
-a always,exit -F arch=b64 -S ptrace -F a0=0x4 -k code_injection
-a always,exit -F arch=b64 -S ptrace -F a0=0x5 -k data_injection
-a always,exit -F arch=b64 -S ptrace -F a0=0x6 -k register_injection
-a always,exit -F arch=b64 -S ptrace -k tracing
## Anonymous File Creation
### These rules watch the use of memfd_create
### "memfd_create" creates anonymous file and returns a file descriptor to access it
### When combined with "fexecve" can be used to stealthily run binaries in memory without touching disk
-a always,exit -F arch=b64 -S memfd_create -F key=anon_file_create
## Privilege Abuse
### The purpose of this rule is to detect when an admin may be abusing power by looking in user's home dir.
-a always,exit -F dir=/home -F uid=0 -F auid>=1000 -F auid!=-1 -C auid!=obj_uid -k power_abuse
# Socket Creations
# will catch both IPv4 and IPv6
-a always,exit -F arch=b32 -S socket -F a0=2  -k network_socket_created
-a always,exit -F arch=b64 -S socket -F a0=2  -k network_socket_created
-a always,exit -F arch=b32 -S socket -F a0=10 -k network_socket_created
-a always,exit -F arch=b64 -S socket -F a0=10 -k network_socket_created
# Software Management ---------------------------------------------------------
# DPKG / APT-GET (Debian/Ubuntu)
-w /usr/bin/dpkg -p x -k software_mgmt
-w /usr/bin/apt -p x -k software_mgmt
-w /usr/bin/apt-add-repository -p x -k software_mgmt
-w /usr/bin/apt-get -p x -k software_mgmt
-w /usr/bin/aptitude -p x -k software_mgmt
-w /usr/bin/wajig -p x -k software_mgmt
-w /usr/bin/snap -p x -k software_mgmt
# Python
-w /usr/bin/python3 -p x -k python3_mgmt
-w /usr/local/bin/python3 -p x -k python3_mgmt
# Comprehensive Perl Archive Network (CPAN) (CPAN installs)
## T1072 third party software
## https://www.cpan.org
-w /usr/bin/cpan -p x -k third_party_software_mgmt
   
# Special Software 
## T1081 Credentials In Files
-w /usr/bin/grep -p x -k string_search
-w /usr/bin/egrep -p x -k string_search
-w /usr/bin/ugrep -p x -k string_search
## Kubernetes
-w /usr/local/bin/helmfile -k kubernetes
-w /usr/local/bin/k9s -k kubernetes
-w /usr/bin/kubectl -k kubernetes
-w /usr/local/bin/kubelogin -k kubernetes
-w /usr/local/bin/kustomize -k kubernetes
# High Volume Events ----------------------------------------------------------
## Disable these rules if they create too many events in your environment
## Common Shells
-w /bin/bash -p x -k susp_shell
-w /bin/dash -p x -k susp_shell
-w /bin/busybox -p x -k susp_shell
-w /bin/zsh -p x -k susp_shell
-w /bin/sh -p x -k susp_shell
-w /bin/ksh -p x -k susp_shell
## Root command executions
-a always,exit -F arch=b64 -F euid=0 -F auid>=1000 -F auid!=-1 -S execve -k rootcmd
## File Deletion Events by User
-a always,exit -F arch=b64 -S rmdir -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=-1 -k delete
## File Access
### Unauthorized Access (unsuccessful)
-a always,exit -F arch=b64 -S creat -S open -S openat -S open_by_handle_at -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=-1 -k file_access
-a always,exit -F arch=b64 -S creat -S open -S openat -S open_by_handle_at -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=-1 -k file_access
### Unsuccessful Creation
-a always,exit -F arch=b64 -S mkdir,creat,link,symlink,mknod,mknodat,linkat,symlinkat -F exit=-EACCES -k file_creation
-a always,exit -F arch=b64 -S mkdir,link,symlink,mkdirat -F exit=-EPERM -k file_creation
### Unsuccessful Modification
-a always,exit -F arch=b64 -S rename -S renameat -S truncate -S chmod -S setxattr -S lsetxattr -S removexattr -S lremovexattr -F exit=-EACCES -k file_modification
-a always,exit -F arch=b64 -S rename -S renameat -S truncate -S chmod -S setxattr -S lsetxattr -S removexattr -S lremovexattr -F exit=-EPERM -k file_modification
## 32bit API Exploitation
### If you are on a 64 bit platform, everything _should_ be running
### in 64 bit mode. This rule will detect any use of the 32 bit syscalls
### because this might be a sign of someone exploiting a hole in the 32
### bit API.
-a always,exit -F arch=b32 -S all -k 32bit_api
# For PCI DSS
## Special case for systemd-run. It is not audit aware, specifically watch it
-a always,exit -F path=/usr/bin/systemd-run -F perm=x -F auid!=unset -F key=maybe-escalation
## Special case for pkexec. It is not audit aware, specifically watch it
-a always,exit -F path=/usr/bin/pkexec -F perm=x -F key=maybe-escalation
## Watch for configuration changes to privilege escalation.
-a always,exit -F path=/etc/sudoers -F perm=wa -F key=10.2.2-priv-config-changes
-a always,exit -F dir=/etc/sudoers.d/ -F perm=wa -F key=10.2.2-priv-config-changes
## 10.2.3 Access to all audit trails.
-a always,exit -F dir=/var/log/audit/ -F perm=r -F auid>=1000 -F auid!=unset -F key=10.2.3-access-audit-trail
-a always,exit -F path=/usr/sbin/ausearch -F perm=x -F key=10.2.3-access-audit-trail
-a always,exit -F path=/usr/sbin/aureport -F perm=x -F key=10.2.3-access-audit-trail
-a always,exit -F path=/usr/sbin/aulast -F perm=x -F key=10.2.3-access-audit-trail
-a always,exit -F path=/usr/sbin/aulastlogin -F perm=x -F key=10.2.3-access-audit-trail
## 10.2.5.b All elevation of privileges is logged
-a always,exit -F arch=b64 -S setuid -F a0=0 -F exe=/usr/bin/su -F key=10.2.5.b-elevated-privs-session
-a always,exit -F arch=b32 -S setuid -F a0=0 -F exe=/usr/bin/su -F key=10.2.5.b-elevated-privs-session
-a always,exit -F arch=b64 -S setresuid -F a0=0 -F exe=/usr/bin/sudo -F key=10.2.5.b-elevated-privs-session
-a always,exit -F arch=b32 -S setresuid -F a0=0 -F exe=/usr/bin/sudo -F key=10.2.5.b-elevated-privs-session
-a always,exit -F arch=b64 -S execve -C uid!=euid -F euid=0 -F key=10.2.5.b-elevated-privs-setuid
-a always,exit -F arch=b32 -S execve -C uid!=euid -F euid=0 -F key=10.2.5.b-elevated-privs-setuid
## 10.2.5.c All changes, additions, or deletions to any account are logged
## This is implicitly covered by shadow-utils. We will place some rules
## in case someone tries to hand edit the trusted databases
-a always,exit -F path=/etc/group -F perm=wa -F key=10.2.5.c-accounts
-a always,exit -F path=/etc/passwd -F perm=wa -F key=10.2.5.c-accounts
-a always,exit -F path=/etc/gshadow -F perm=wa -F key=10.2.5.c-accounts
-a always,exit -F path=/etc/shadow -F perm=wa -F key=10.2.5.c-accounts
-a always,exit -F path=/etc/security/opasswd -F perm=wa -F key=10.2.5.c-accounts
## 10.4.2b Time data is protected.
## We will place rules to check time synchronization
-a always,exit -F arch=b32 -S adjtimex,settimeofday,stime -F key=10.4.2b-time-change
-a always,exit -F arch=b64 -S adjtimex,settimeofday -F key=10.4.2b-time-change
-a always,exit -F arch=b32 -S clock_settime -F a0=0x0 -F key=10.4.2b-time-change
-a always,exit -F arch=b64 -S clock_settime -F a0=0x0 -F key=10.4.2b-time-change
-w /etc/localtime -p wa -k 10.4.2b-time-change
## 10.5.5 Use file-integrity monitoring or change-detection software on logs
-a always,exit -F dir=/var/log/audit/ -F perm=wa -F key=10.5.5-modification-audit

## Log user commands
-a always,exit -F arch=b32 -S execve -k auditcmd
-a always,exit -F arch=b64 -S execve -k auditcmd

# Make The Configuration Immutable --------------------------------------------
##-e 2
\EOF

# Start auditd
sudo service auditd start