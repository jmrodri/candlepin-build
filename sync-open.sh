#!/bin/sh

#
# This script will take the output of build-fedora.sh, and the tito
# built epel rpms, and create a repo tree that can be rsync'd to
# repos.fedorapeople.org
#

if [ "$1" == "" ]; then
    echo "Supply a Candlepin version i.e. 0.3, 0.4."
    exit 1;
fi

function create_repo {
    pushd $2
    if [ "$1" == "epel" ] ; then
        /usr/bin/createrepo --checksum sha -d .
    else
        /usr/bin/createrepo -d .
    fi
    popd
}

function prep_epel_repo {
    cpver=$1
    epelver=$2
    mkdir -p /tmp/candlepin/$cpver/epel-${epelver}Server/{i386,SRPMS,x86_64}
    cd /tmp/candlepin/$cpver/epel-${epelver}Server
    brew download-build --latestfrom candlepin-1-rhel$epelver-candidate candlepin
    brew download-build --latestfrom candlepin-1-rhel$epelver-candidate candlepin-deps
    mv candlepin*src.rpm SRPMS/
    cp candlepin*.rpm i386/
    cp candlepin*.rpm x86_64/
    rm -f candlepin*.rpm
    create_repo epel i386
    create_repo epel x86_64
    create_repo epel SRPMS
}

function prep_fedora_repo {
    cpver=$1
    fedoraver=$2
    mkdir -p /tmp/candlepin/$cpver/fedora-$fedoraver/{i386,SRPMS,x86_64}
    mv /tmp/repo-fedora-$fedoraver-x86_64/candlepin/*src.rpm /tmp/candlepin/$cpver/fedora-$fedoraver/SRPMS/
    cp /tmp/repo-fedora-$fedoraver-x86_64/candlepin/* /tmp/candlepin/$cpver/fedora-$fedoraver/i386/
    cp /tmp/repo-fedora-$fedoraver-x86_64/candlepin/* /tmp/candlepin/$cpver/fedora-$fedoraver/x86_64/
    cd /tmp/candlepin/$cpver/fedora-$fedoraver/
    create_repo fedora i386
    create_repo fedora x86_64
    create_repo fedora SRPMS
}

rm -rf /tmp/candlepin/$1/

prep_epel_repo $1 5
prep_epel_repo $1 6
prep_fedora_repo $1 13
prep_fedora_repo $1 14
prep_fedora_repo $1 15

#rsync -avz --delete --no-p --no-g /tmp/candlepin/$1/RHEL/ dept.rhndev.redhat.com:/var/www/dept/yum/candlepin/$1/RHEL/
