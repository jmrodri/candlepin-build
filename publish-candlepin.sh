#!/bin/sh

rm -rf /tmp/candlepin
mkdir -p /tmp/candlepin
cd /tmp/candlepin/
brew download-build --latestfrom candlepin-1-rhel5-candidate candlepin
rm -f candlepin*src.rpm
createrepo --checksum sha -d .
rsync -avz --delete --no-p --no-g /tmp/candlepin/ dept.rhndev.redhat.com:/var/www/dept/yum/candlepin/$1
#rsync -avz --no-p --no-g /tmp/candlepin/ dept.rhndev.redhat.com:/var/www/dept/yum/candlepin/$1
