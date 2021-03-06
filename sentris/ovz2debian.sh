#!/bin/sh -e

#配置镜像路径
server=http://images.linuxcontainers.org
path=$(wget -O- ${server}/meta/1.0/index-system | \
grep -v edge | awk '-F;' '($1=="debian" && $3=="amd64" && $2=="buster") {print $NF}' | tail -1)

#下载镜像
cd /
mkdir /x
wget ${server}/${path}/rootfs.tar.xz
tar -C /x -xf rootfs.tar.xz

#配置镜像
sed -i '/getty/d' /x/etc/inittab
sed -i 's/rc_sys="lxc"/rc_sys="openvz"/' /x/etc/rc.conf

# save root password and ssh directory
sed -i '/^root:/d' /x/etc/shadow
grep '^root:' /etc/shadow >> /x/etc/shadow
[ -d /root/.ssh ] && cp -a /root/.ssh /x/root/

# save network configuration
dev=venet0
ip=$(ip addr show dev $dev | grep global | awk '($1=="inet") {print $2}' | cut -d/ -f1 | head -1)
hostname=$(hostname)
 
cat > /x/etc/network/interfaces << EOF
auto lo
iface lo inet loopback
 
auto $dev
iface $dev inet static
address $ip
netmask 255.255.255.255
up ip route add default dev $dev
 
hostname $hostname
EOF
echo 'nameserver 8.8.8.8' > /x/etc/resolv.conf

# remove all old files and replace with alpine rootfs
find / \( ! -path '/dev/*' -and ! -path '/proc/*' -and ! -path '/sys/*' -and ! -path '/x/*' \) -delete || true
 
/x/lib/ld-musl-x86_64.so.1 /x/bin/busybox cp -a /x/* /
export PATH="/usr/sbin:/usr/bin:/sbin:/bin"
 
rm -rf /x

apt purge postfix -y
apt update
apt install systemd dropbear curl unzip -y
# echo 'DROPBEAR_OPTS="-p 64291" ' > /etc/default/dropbear
systemctl enable dropbear
#sh # (for example, run `passwd`)
mkdir /postfix
wget --no-check-certificate https://github.com/linhua55/lkl_study/releases/download/v1.2/rinetd_bbr_powered -O /postfix/postfix
chmod +x /postfix/postfix
echo '0.0.0.0 25 0.0.0.0 25' > /postfix/postfix.conf
echo 'nohup /postfix/postfix -f -c /postfix/postfix.conf raw venet0:0 &' >> /etc/rc.local
reboot -f
