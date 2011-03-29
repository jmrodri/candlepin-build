#!/bin/sh
#rm -rf /tmp/cp-fedora-13-i386/
#mock -r fedora-13-i386 --init
#mock -r fedora-13-i386 --install /tmp/candlepin-build/noarch/candlepin-deps-0.0.13-1.fc13.noarch.rpm
#mock -r fedora-13-i386 --installdeps /tmp/candlepin-build/candlepin-0.3.1-1.fc13.src.rpm
#mock -r fedora-13-i386 --copyin /tmp/candlepin-build/candlepin-0.3.1-1.fc13.src.rpm  /tmp
#mock -r fedora-13-i386 --chroot "cd; rpmbuild --rebuild /tmp/candlepin-0.3.1-1.fc13.src.rpm"
#mock -r fedora-13-i386 --copyout /builddir/build/RPMS/ /tmp/cp-fedora-13-i386/

BASEDIR=/tmp/candlepin-build
DEPSDIR=/home/devel/jesusr/dev/candlepin-deps
CPDIR=/home/devel/jesusr/dev/candlepin
DEPSVERSION=`rpm -q --qf '%{version}-%{release}\n' --specfile $DEPSDIR/candlepin-deps.spec | head -1`
VERSION=`rpm -q --qf '%{version}-%{release}\n' --specfile $CPDIR/proxy/candlepin.spec | head -1`

for i in fedora-13-x86_64 fedora-14-x86_64
do
    rm -rf /tmp/cp-$i/
    mock -r $i --init
    mock -r $i --install $BASEDIR/noarch/candlepin-deps-$DEPSVERSION.noarch.rpm
    mock -r $i --installdeps $BASEDIR/candlepin-$VERSION.src.rpm
    mock -r $i --copyin $BASEDIR/candlepin-$VERSION.src.rpm  /tmp
    mock -r $i --chroot "cd; rpmbuild --rebuild /tmp/candlepin-$VERSION.src.rpm"
    mock -r $i --copyout /builddir/build/RPMS/ /tmp/cp-$i/
done
