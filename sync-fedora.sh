#!/bin/sh

if [ "$1" == "" ]; then
    echo "Supply a Candlepin version."
    exit 1;
fi

rm -rf /tmp/candlepin/$1/Fedora/
mkdir -p /tmp/candlepin/$1/Fedora/13/
cp /tmp/cp-fedora-13-x86_64/* /tmp/candlepin/$1/Fedora/13/
cd /tmp/candlepin/$1/Fedora/13/
createrepo -d .

mkdir -p /tmp/candlepin/$1/Fedora/14/
cp /tmp/cp-fedora-14-x86_64/* /tmp/candlepin/$1/Fedora/14/
cd /tmp/candlepin/$1/Fedora/14/
createrepo -d .

rsync -avz --delete --no-p --no-g /tmp/candlepin/$1/Fedora/ dept.rhndev.redhat.com:/var/www/dept/yum/candlepin/$1/Fedora/
#mkdir -p /tmp/dept/yum/candlepin/$1/Fedora/
#rsync -avz --delete --no-p --no-g /tmp/candlepin/$1/Fedora/ /tmp/dept/yum/candlepin/$1/Fedora/
