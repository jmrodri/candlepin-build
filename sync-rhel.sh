#!/bin/sh

if [ "$1" == "" ]; then
    echo "Supply a Candlepin version i.e. 0.3, 0.4."
    exit 1;
fi

function preprepo {
    cpver=$1
    rhelver=$2
    mkdir -p /tmp/repo/internal/candlepin/$cpver/RHEL/$rhelver/
    cd /tmp/repo/internal/candlepin/$cpver/RHEL/$rhelver
    brew download-build --latestfrom se-rhel-6-candidate candlepin
    brew download-build --latestfrom se-rhel-6-candidate candlepin-deps
    rm -f candlepin*src.rpm
    createrepo --checksum sha -d .
}

rm -rf /tmp/repo/internal/candlepin/$1/RHEL/

preprepo $1 5

preprepo $1 6

rsync -avz --delete --no-p --no-g /tmp/repo/internal/candlepin/$1/RHEL/ dept.rhndev.redhat.com:/var/www/dept/yum/candlepin/$1/RHEL/
