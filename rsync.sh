#!/usr/bin/env bash
fasLogin=jmrodri
#repoLocalDir=(/tmp/repo/candlepin/0.4/ /tmp/repo/thumbslug/0.0/)
#repoNames=(candlepin thumbslug)
repoOwner=candlepin
#declare -a branch=(fedora-14 fedora-15 epel-5Server epel-6Server)
#declare -a branch=(epel-5Server epel-6Server)
#declare -a branch=(fedora-14 fedora-15)
#declare -a rpmdir=(i386 x86_64 SRPMS)
#declare -a rsyncParam=(-avtz --delete)

#for d in "${repoLocalDir[@]}"
#do
#    echo $d
#    cd $d
#    for dir2 in "${branch[@]}"
#    do
#        echo -e "\033[31mUpdate $dir2 repos:\033[0m"
#        cd $dir2
#        for dir3 in "${rpmdir[@]}"
#        do
#            echo -e "\033[34m\t* $dir3:\033[0m"
#            cd $dir3
#            #createrepo ./
#            #rsync "${rsyncParam[@]}" ./* $fasLogin@fedorapeople.org:/srv/repos/$repoOwner/$repoName/$dir2/$dir3
#            echo rsync "${rsyncParam[@]}" ./* $fasLogin@fedorapeople.org:/srv/repos/$repoOwner/$repoName/$dir2/$dir3
#            cd ..
#        done
#        cd ..
#    done
#    cd ..
#done

rsync -avtz --delete /tmp/repo/candlepin/0.4/ $fasLogin@fedorapeople.org:/srv/repos/$repoOwner/candlepin/
rsync -avtz --delete /tmp/repo/thumbslug/0.0/ $fasLogin@fedorapeople.org:/srv/repos/$repoOwner/thumbslug/
