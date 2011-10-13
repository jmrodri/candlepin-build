#!/bin/sh

#
# This script will take the output of build-fedora.sh, and the tito
# built epel rpms, and create a repo tree that can be rsync'd to
# repos.fedorapeople.org
#

# Read in user defined variables
if [ -f $HOME/.candlepinrc ] ; then
    source $HOME/.candlepinrc
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
    ver=$1
    epelver=$2
    package=$3
    mkdir -p /tmp/repo/$package/$ver/epel-${epelver}Server/{i386,SRPMS,x86_64}
    cd /tmp/repo/$package/$ver/epel-${epelver}Server
    brew download-build --latestfrom candlepin-1-rhel$epelver-candidate candlepin
    brew download-build --latestfrom candlepin-1-rhel$epelver-candidate candlepin-deps
    cp candlepin*src.rpm SRPMS/
    cp candlepin*.rpm i386/
    cp candlepin*.rpm x86_64/
    rm -f i386/candlepin*src.rpm
    rm -f x86_64/candlepin*src.rpm
    rm -f candlepin*.rpm
    create_repo epel i386
    create_repo epel x86_64
    create_repo epel SRPMS
}

function prep_fedora_repo {
    ver=$1
    fedoraver=$2
    package=$3
    mkdir -p /tmp/repo/$package/$ver/fedora-$fedoraver/{i386,SRPMS,x86_64}
    cp /tmp/repo-fedora-$fedoraver-x86_64/$package/*src.rpm /tmp/repo/$package/$ver/fedora-$fedoraver/SRPMS/
    cp /tmp/repo-fedora-$fedoraver-x86_64/$package/* /tmp/repo/$package/$ver/fedora-$fedoraver/i386/
    cp /tmp/repo-fedora-$fedoraver-x86_64/$package/* /tmp/repo/$package/$ver/fedora-$fedoraver/x86_64/
    rm -f /tmp/repo/$package/$ver/fedora-$fedoraver/i386/*src.rpm
    rm -f /tmp/repo/$package/$ver/fedora-$fedoraver/x86_64/*src.rpm
    cd /tmp/repo/$package/$ver/fedora-$fedoraver/
    create_repo fedora i386
    create_repo fedora x86_64
    create_repo fedora SRPMS
}

rm -rf /tmp/candlepin/$1/

CPVERSION=`rpm -q --qf '%{version}\n' --specfile $CPDIR/proxy/candlepin.spec | head -1`
TSVERSION=`rpm -q --qf '%{version}\n' --specfile $TSDIR/thumbslug.spec | head -1`

prep_epel_repo $CPVERSION 5 candlepin
prep_epel_repo $CPVERSION 6 candlepin
prep_fedora_repo $CPVERSION 14 candlepin
prep_fedora_repo $CPVERSION 15 candlepin
prep_fedora_repo $TSVERSION 14 thumbslug
prep_fedora_repo $TSVERSION 15 thumbslug
