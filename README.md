# cbuildsystem
Containerised Build System

There are the following things needed to get it to work:
    
    cbuild-secrets merged in
    
    shared_src needs cloned into it: buildsystem.git and dev-metadata.git
    
    docker-sw-gerrit/gits needs All-Projects.git and All-Users.git plus any
    gits you want available within the cbuildsystem

    docker-sw-gerrit-postgres needs a copy of the live dbdump saved as 
    docker-sw-gerrit-postgres/gerrit_backup.sql    

    docker-jenkins-master/chroot.d & docker-jenkins-child/chroot.d need
    the chroot config's for any projects you wish to use
    
    docker-jenkins-master/chroot & docker-jenkins-child/chroot need the chroots
    matching above
    
    Lastly you will need to copy (or generate via genesis) the relevant jobs
    to match your git(s) & project(s) into your mounted jenkins/jobs location
