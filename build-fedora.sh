# Read in user defined variables
if [ -f $HOME/.candlepinrc ] ; then
    source $HOME/.candlepinrc
fi

# verify our configs are setup correctly
if [ -z $BASEDIR ] ; then
    echo "BASEDIR not set, please tell me where to build"
    exit 1
fi

if [ -z $DEPSDIR ] ; then
    echo "DEPSDIR not set, where is candlepin-deps src tree?"
    exit 1
fi

if [ -z $CPDIR ] ; then
    echo "CPDIR not set, where is candlepin src tree?"
    exit 1
fi

DEPSVERSION=`rpm -q --qf '%{version}-%{release}\n' --specfile $DEPSDIR/candlepin-deps.spec | head -1`
VERSION=`rpm -q --qf '%{version}-%{release}\n' --specfile $CPDIR/proxy/candlepin.spec | head -1`

pushd $DEPSDIR
tito build --rpm
popd
pushd $CPDIR/proxy
tito build --srpm
popd

for i in fedora-13-x86_64 fedora-14-x86_64 fedora-15-x86_64
do
    rm -rf /tmp/cp-$i/
    mock -r $i --init
    mock -r $i --install $BASEDIR/noarch/candlepin-deps-$DEPSVERSION.noarch.rpm
    mock -r $i --installdeps $BASEDIR/candlepin-$VERSION.src.rpm
    mock -r $i --copyin $BASEDIR/candlepin-$VERSION.src.rpm  /tmp
    mock -r $i --chroot "cd; rpmbuild --rebuild /tmp/candlepin-$VERSION.src.rpm"
    mock -r $i --copyout /builddir/build/RPMS/ /tmp/cp-$i/
done
