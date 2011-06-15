#!/bin/sh

if [ "$1" == "" ]; then
    echo "Supply a Candlepin version i.e. 0.3, 0.4."
    exit 1;
fi

function preprepo {
    cpver=$1
    fedoraver=$2
    mkdir -p /tmp/candlepin/$cpver/Fedora/$fedoraver/
    cp /tmp/cp-fedora-$fedoraver-x86_64/* /tmp/candlepin/$cpver/Fedora/$fedoraver/
    cd /tmp/candlepin/$cpver/Fedora/$fedoraver/
    createrepo -d .
}

rm -rf /tmp/candlepin/$1/Fedora/

preprepo $1 13

preprepo $1 14

preprepo $1 15

rsync -avz --delete --no-p --no-g /tmp/candlepin/$1/Fedora/ dept.rhndev.redhat.com:/var/www/dept/yum/candlepin/$1/Fedora/
