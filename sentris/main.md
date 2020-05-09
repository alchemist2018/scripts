# ovz2alpine

wget --no-check-certificate https://raw.githubusercontent.com/alchemist2018/scripts/master/sentris/ovz2alpine.sh

chmod +x ovz2alpine.sh

./ovz2alpine.sh


# setupRay2alpine

apk add --no-cache wget

wget https://raw.githubusercontent.com/alchemist2018/scripts/master/sentris/setupRay2alpine.sh

chmod +x setupRay2alpine.sh

./setupRay2alpine.sh


# alpineReinstall

apk add --no-cache wget

wget https://raw.githubusercontent.com/alchemist2018/scripts/master/sentris/alpineReinstall.sh

chmod +x alpineReinstall.sh

./alpineReinstall.sh

# setup Ray to Ovz

cd /

mkdir v2ray

cd v2ray

wget --no-check-certificate https://github.com/v2ray/v2ray-core/releases/download/v4.23.1/v2ray-linux-64.zip

apt-get update

apt-get install unzip

unzip -j "/v2ray/v2ray-linux-64.zip" "v2ray" "v2ctl" -d "/v2ray"

rm -rf /v2ray/v2ray-linux-64.zip

wget --no-check-certificate https://raw.githubusercontent.com/alchemist2018/scripts/master/Configfile/ray/server_config.json

vi /etc/ssh/sshd_config

vi /etc/rc.local

nohup /v2ray/v2ray -config=/v2ray/server_config.json &
