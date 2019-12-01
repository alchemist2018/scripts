# ovz2alpine

apk add --no-cache curl

curl -L -H "Cache-Control: no-cache" https://raw.githubusercontent.com/alchemist2018/scripts/master/sentris/ovz2alpine.sh

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