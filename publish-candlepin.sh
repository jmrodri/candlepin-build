#!/bin/sh
#if [ "$1" == "" ] ; then
#   echo "specify a version as the first arg"
#   exit
#fi

rm -rf /tmp/candlepin
mkdir -p /tmp/candlepin
cd /tmp/candlepin/
brew download-build --latestfrom candlepin-1-rhel5-candidate candlepin
rm -f candlepin*src.rpm
createrepo --checksum sha -d .
echo 'rsync -avz --delete --no-p --no-g /tmp/candlepin/ dept.rhndev.redhat.com:/var/www/dept/yum/candlepin/'
#rsync -avz --delete --no-p --no-g /tmp/candlepin/ dept.rhndev.redhat.com:/var/www/dept/yum/candlepin/
