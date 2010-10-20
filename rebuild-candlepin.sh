#!/bin/sh
if [ "$1" == "" ] ; then
   echo "specify a version as the first arg"
   exit
fi

rm -rf /tmp/candlepin
mkdir -p /tmp/candlepin
cp /tmp/candlepin-build/noarch/candlepin-*$1*.rpm /tmp/candlepin/
cd /tmp/candlepin/
createrepo --checksum sha -d .
rsync -avz --delete --no-p --no-g /tmp/candlepin/ dept.rhndev.redhat.com:/var/www/dept/yum/candlepin/
