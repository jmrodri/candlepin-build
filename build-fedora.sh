#!/bin/sh

build() {
    PACKAGE=$1
    DEPSDIR=$2
    PKGDIR=$3
    DEPSVERSION=`rpm -q --qf '%{version}-%{release}\n' --specfile $DEPSDIR/$PACKAGE-deps.spec | head -1`
    VERSION=`rpm -q --qf '%{version}-%{release}\n' --specfile $PKGDIR/$PACKAGE.spec | head -1`

    pushd $DEPSDIR
    tito build --srpm
    popd
    pushd $PKGDIR
    tito build --srpm
    popd

    #for i in fedora-14-x86_64 fedora-15-x86_64 fedora-16-x86_64
    for i in fedora-16-x86_64
    do
        rm -rf /tmp/repo-$i/$PACKAGE/
        rm -rf $BASEDIR/$i/
        mkdir -p /tmp/repo-$i/$PACKAGE/
        mock -r $i --resultdir=$BASEDIR/$i/ --rebuild $BASEDIR/$PACKAGE-deps-$DEPSVERSION.src.rpm
        mock -r $i --init
        mock -r $i --install $BASEDIR/$i/$PACKAGE-deps-*.noarch.rpm
        mock -r $i --resultdir=$BASEDIR/$i/ --rebuild --no-clean $BASEDIR/$PACKAGE-$VERSION.src.rpm
        # can't use $VERSION when copying rpms since the dist changes
        cp $BASEDIR/$i/$PACKAGE-*.src.rpm /tmp/repo-$i/$PACKAGE/
        cp $BASEDIR/$i/$PACKAGE*.noarch.rpm /tmp/repo-$i/$PACKAGE/
    done
}

buildCandlepin() {
    if [ -z $CPDEPSDIR ] ; then
        echo "CPDEPSDIR not set, where is candlepin-deps src tree?"
        exit 1
    fi

    if [ -z $CPDIR ] ; then
        echo "CPDIR not set, where is candlepin src tree?"
        exit 1
    fi
    build 'candlepin' $CPDEPSDIR $CPDIR'/proxy'
}

buildThumbslug() {
    if [ -z $TSDEPSDIR ] ; then
        echo "TSDEPSDIR not set, where is thumbslug-deps src tree?"
        exit 1
    fi

    if [ -z $TSDIR ] ; then
        echo "TSDIR not set, where is thumbslug src tree?"
        exit 1
    fi
    build 'thumbslug' $TSDEPSDIR $TSDIR
}

printBasedir() {
    echo $BASEDIR
}

########################################################################
#
# MAIN
#
########################################################################

# Read in user defined variables
if [ -f $HOME/.candlepinrc ] ; then
    source $HOME/.candlepinrc
fi

# verify our configs are setup correctly
if [ -z $BASEDIR ] ; then
    echo "BASEDIR not set, please tell me where to build"
    exit 1
fi

if [ "$1" == "candlepin" ] ; then
    buildCandlepin
elif [ "$1" == "thumbslug" ] ; then
    buildThumbslug
else
    echo "Please supply a package name: candlepin or thumbslug."
    exit 1
fi
