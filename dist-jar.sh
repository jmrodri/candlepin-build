#!/bin/bash
#
# Copyright (c) 2011 Red Hat, Inc.
#
# Authors: Jesus M. Rodriguez <jesusr@redhat.com>
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.
#


MyDir=$(cd $(dirname $0) && pwd)

# Config data:
MAIL_TO=candlepin@fedorahosted.org
# what rsh to use
RCPCMD="rsync -avP -e ssh"
# the @ at the end is needed if not empty
REMOTE_USER=jmrodri@

# dir to stage RPMs when pushing from the repo
STAGE_DIR=$(mktemp -d /tmp/rhn-distjar-stage-XXXXXXXX)
rm -rf $STAGE_DIR
mkdir -p $STAGE_DIR

# where do we transfer the packages to on the remote
DESTDIR=/home/fedora/jmrodri/public_html/ivy/candlepin/

distUsage(){
    cat <<EOF
This program can be used to install individual jar files or
jars contained in RPMs on the remote machines, usually using
ssh and scp
Usage:
$(basename $0) --host <hostname>  package...
Additional options
   --host <HOST>      add HOST to the list of machines
     --devel          alias for development maven hosts
   --user USER        Use USER as the remote user [$REMOTE_USER]
   --destdir DIR      destination directory [$DESTDIR]
   --mailto EMAIL     send email to [$MAIL_TO]
   --help             this help screen
EOF
}

# quick sanity check for having arguments
if [ $# -lt 1 ] ; then
    distUsage
    exit 1
fi

# Copy packages on the remote system
distCopy() {
    if [ -z "$1" ] ; then
	echo "ERROR: asked to copy files, but no hostname provided"
	exit -3
    fi
    _HOST=$1
    _DEST=$_HOST:$DESTDIR
    # copy the files
    echo
    echo "Copying $(echo $JARS | wc -w) packages onto $_DEST..."
    echo "*** $RCPCMD -> $REMOTE_USER$_DEST"
    for p in $JARS ; do echo -e "\t$p" ; done
    #$RCPCMD $JARS $REMOTE_USER$_DEST 2>&1
}

cleanup() {
    #echo "cleanup"
    rm -rf $STAGE_DIR
}

PACKAGES=
JARS=
HOSTS=

while [ -n "$1" ] ; do
    arg=$1
    case $arg in
	--help | -h )
	    distUsage
	    exit 0
	    ;;

	--host )
	    shift
	    HOSTS="$HOSTS $1"
	    ;;
	--devel )
	    HOSTS="fedorapeople.org"
	    ;;
	--destdir )
	    shift
	    DESTDIR=$1
	    ;;
	--mailto )
	    shift
	    MAIL_TO=$(echo $1)
	    ;;
	--user )
	    shift
	    REMOTE_USER="$1@"
	    ;;
	*.rpm )
	    PACKAGES="$PACKAGES $arg"
	    ;;

	*.jar )
	    JARS="$JARS $arg"
	    ;;

	* )
            # Check if it's a link file
            if [ ! -s "$arg" ]; then
                echo "Invalid argument $arg passed: not an rpm or link file" >&2
                exit -1
            fi
            # Try to read the first line
            filename=$(head -n 1 $arg)
            REPO_PACKAGES="$REPO_PACKAGES $filename"
	    ;;
    esac
    shift
done

if [ -n "$REPO_PACKAGES" ]; then
    if ! repo-ng/repo-tool --get $REPO_PACKAGES --flatten --dir $STAGE_DIR; then
	echo "One or more errors occured fetching packages from the repository."
	exit 1
    fi

    PACKAGES="$PACKAGES $(find $STAGE_DIR -type f -name '*.rpm')"
fi

extractJars() {
   if [ -z "$1" ] ; then
      echo "ERROR: asked to extract jars, but no rpm was given."
      exit -3
   fi
   _PKG=$1
   _RPM_NAME=`rpm -qp --queryformat "%{NAME}\n" $_PKG`
   rpm2cpio $_PKG > $STAGE_DIR/$_RPM_NAME.cpio
   pushd $STAGE_DIR > /dev/null
   cpio -ivd ./*.jar < $_RPM_NAME.cpio > /dev/null 2>&1
   popd > /dev/null
   JARS="$JARS $(find -L $STAGE_DIR -type f -name '*.jar')"
}

extractRepoInfo() {
   if [ -z "$1" ] ; then
      echo "ERROR: asked to extract jars, but no rpm was given."
      exit -3
   fi
   _PKG=$1
   _RPM_NAME=`rpm -qp --queryformat "%{NAME}\n" $_PKG`
   rpm2cpio $_PKG > $STAGE_DIR/$_RPM_NAME.cpio
   pushd $STAGE_DIR > /dev/null
   cpio -ivd ./*maven* < $_RPM_NAME.cpio > /dev/null 2>&1
   popd > /dev/null
   REPOFILES="$REPOFILES $(find -L $STAGE_DIR -type f -name $_RPM_NAME)"
}


if [ -z "$HOSTS" ] ; then
    echo "No hosts to distribute packages to" 1>&2
    cleanup
    exit -2
fi

# we have rpms that need extracting
if [ -n "$PACKAGES" ]; then
    echo "Extracting jar files from rpms"
    for p in $PACKAGES ; do extractJars $p ; done
fi

# sanity checks
if [ -z "$PACKAGES" ] ; then
    if [ -z "$JARS" ] ; then
        echo "No packages or jars given to copy" 1>&2
        cleanup
        exit -2
    fi
fi

TMPLOG=$(/bin/mktemp /tmp/dist-jar-log.XXXXXX)
trap 'rm -fv $TMPLOG $STAGE_DIR' EXIT

for h in $HOSTS ; do
    {
    echo
    echo "START: Working on $(echo $h | tr '[:lower:]' '[:upper:]')..."
    } >> $TMPLOG
    distCopy    $h 2>&1 | tee -a $TMPLOG
done

mail -s "JAR INSTALL on $HOSTS" $MAIL_TO <<EOF
HOSTNAME:   $(hostname)
USERNAME:   $(who am i)
${RELEASE:+BUILDROOT:  $BuildRoot} $(echo)
HOSTS UPDATED:
    $(for h in $HOSTS ; do echo -e "\t$h" ; done)
PACKAGES USED:
    $(for p in $PACKAGES ; do echo -e "\t$p" ; done)
JAR LIST:
    $(for p in $JARS; do echo -e "\t$p" ; done)

The following action log was generated:
$(cat $TMPLOG)
EOF

rm -f $TMPLOG
#cleanup
echo "DONE."
