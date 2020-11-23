#!/bin/sh -e

#配置镜像路径
server=http://images.linuxcontainers.org
path=$(wget -O- ${server}/meta/1.0/index-system | \
grep -v edge | awk '-F;' '($1=="alpine" && $3=="amd64" && $2!="3.9") {print $NF}' | tail -1)

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
echo 'nameserver 1.1.1.1' > /x/etc/resolv.conf

# remove all old files and replace with alpine rootfs
find / \( ! -path '/dev/*' -and ! -path '/proc/*' -and ! -path '/sys/*' -and ! -path '/x/*' \) -delete || true
 
/x/lib/ld-musl-x86_64.so.1 /x/bin/busybox cp -a /x/* /
export PATH="/usr/sbin:/usr/bin:/sbin:/bin"
 
rm -rf /x
 
apk update
apk del wget
apk add dropbear iptables grep wget
echo 'DROPBEAR_OPTS="-p 64291" ' > /etc/conf.d/dropbear
# apk add --no-cache --virtual .build-deps ca-certificates curl

mkdir -m 777 /v2ray 
wget -O /v2ray/v2ray.zip https://github.com/v2fly/v2ray-core/releases/download/v4.32.1/v2ray-linux-64.zip
unzip /v2ray/v2ray.zip -d /v2ray/
rm -rf /v2ray/v2ray.zip 
rm -rf /v2ray/config.json
rm -rf /v2ray/geoip.dat
rm -rf /v2ray/geosite.dat 
wget -O /v2ray/config.json https://raw.githubusercontent.com/alchemist2018/scripts/master/Configfile/ray/server_config.json
# apk del .build-deps

mkdir -m 777 /rinetd
wget "https://github.com/linhua55/lkl_study/releases/download/v1.2/rinetd_bbr_powered" -O /rinetd/rinetd
chmod +x /rinetd/rinetd
echo -e '0.0.0.0 143 0.0.0.0 143\n0.0.0.0 25 0.0.0.0 25' > /rinetd/rinetd.conf

mkdir -m 777 /ss
wget -O /ss/ss.gz https://dl.lamp.sh/shadowsocks/shadowsocks-server-linux64-1.2.2.gz
gzip -d /ss/ss.gz
chmod +x /ss/ss

echo -e 'nohup /rinetd/rinetd -f -c /rinetd/rinetd.conf raw venet0 &\nnohup /ss/ss -p 143 -m rc4-md5 -k W@28No &\nnohup /v2ray/v2ray &' > /etc/local.d/v2ray.start
chmod +x /etc/local.d/v2ray.start

rc-update add local
rc-update add dropbear default
rc-update add mdev sysinit
rc-update add devfs sysinit
#sh # (for example, run `passwd`)

sync
reboot -f
