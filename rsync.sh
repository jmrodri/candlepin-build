#!/usr/bin/env bash
fasLogin=
repoLocalDir=/tmp/candlepin/0.4/
repoName=candlepin
repoOwner=candlepin
declare -a branch=(fedora-14 fedora-15 epel-5 epel-6)
declare -a rpmdir=(i386 x86_64 SRPMS)
declare -a rsyncParam=(-avtz --delete)

cd $repoLocalDir
for dir2 in "${branch[@]}"
do
    echo -e "\033[31mUpdate $dir2 repos:\033[0m"
    cd $dir2
    for dir3 in "${rpmdir[@]}"
    do
        echo -e "\033[34m\t* $dir3:\033[0m"
        cd $dir3
        createrepo ./
        rsync "${rsyncParam[@]}" ./* $fasLogin@fedorapeople.org:/srv/repos/$repoOwner/$repoName/$dir2/$dir3
        cd ..
    done
    cd ..
done
cd ..
