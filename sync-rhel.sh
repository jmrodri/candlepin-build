#!/bin/sh

if [ "$1" == "" ]; then
    echo "Supply a Candlepin version i.e. 0.3, 0.4."
    exit 1;
fi

rm -rf /tmp/candlepin/$1/RHEL/

mkdir -p /tmp/candlepin/$1/RHEL/5/
cd /tmp/candlepin/$1/RHEL/5
brew download-build --latestfrom candlepin-1-rhel5-candidate candlepin
rm -f candlepin*src.rpm
createrepo --checksum sha -d .

mkdir -p /tmp/candlepin/$1/RHEL/6/
cd /tmp/candlepin/$1/RHEL/6
brew download-build --latestfrom candlepin-1-rhel6-candidate candlepin
rm -f candlepin*src.rpm
createrepo --checksum sha -d .

rsync -avz --delete --no-p --no-g /tmp/candlepin/$1/RHEL/ dept.rhndev.redhat.com:/var/www/dept/yum/candlepin/$1/RHEL/
#mkdir -p /tmp/dept/yum/candlepin/$1/RHEL/
#rsync -avz --delete --no-p --no-g /tmp/candlepin/$1/RHEL/ /tmp/dept/yum/candlepin/$1/RHEL/
