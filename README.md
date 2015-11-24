# cbuildsystem
Containerised Build System

There are the following things needed to get it to work:
    
* Contents of **cbuild-secrets** repository copied into this directory

* shared_src needs cloned into it: **buildsystem.git** and **dev-metadata.git**

* docker-sw-gerrit/gits needs **-- Standard Permissions --.git** *(Have fun copying that!)* **All-Projects.git** and **All-Users.git** plus **any gits you want available** within the cbuildsystem

* docker-sw-gerrit-postgres needs a copy of the **live dbdump** saved as docker-sw-gerrit-postgres/gerrit_backup.sql

* docker-jenkins-master/chroot.d & docker-jenkins-child/chroot.d need the **chroot config's** for any projects you wish to use

* docker-jenkins-master/chroot & docker-jenkins-child/chroot need the **chroots matching above**

* Copy in **/srv/build/logs** from buildfs to shared_mnt_build/logs \**not essential, build will still succeed without this but project-logger wont work\**

* docker-sw-bugzilla-postgres needs a copy of **live dbdump** saved as
docker-sw-bugzilla-postgres/bugs_backup.sql

* Lastly you will need to copy (or generate via genesis) the relevant **jobs to match your git(s) & project(s)** into your mounted jenkins/jobs location

#### To bring up the Containers 
With the above steps completed, run ./mkbuildsystem.sh.
You can supply this script with some options.

| Option | Result |
| :------ | :------ |
| -d (0 or 1) | Dev mode ON/OFF, disables IRC & mail on jenkins |
| -f (defaults file) | Point container_functions.sh at a non-standard defaults file |

This will create some folders on host as per the defaults file used by the Containers

* **PG_GERRIT_DATA** - Stores Postgresql Database used by Gerrit
* **GERRIT_DATA** - Stores Gerrit's home directory. (Not including .git's)
* **JENKINS_DATA** - Stores Jenkins jobs only (including build history)
* **BUILDSYSTEM_DATA** - Stores a shared /usr/src/buildsystem/ between containers
* **REPO_DATA** - Stores a shared /usr/src/repository/ between containers
* **HOME_BUILD_DATA** - Stores a shared /home/build/ between containers
* **DEVMETADATA_DATA** - Stores a shared /usr/src/dev-metadata/ between containers
* **MNTBUILD_DATA** - Stores a shared /mnt/build between containers
* **APTLY_DATA** - Stores a shared /usr/src/aptly between containers
* **GERRIT_GIT_DATA** - Stores Gerrit's /usr/src/gerrit directory
* **PG_BUGZILLA_DATA** - Stores Postgresql Database used by Bugzilla
* **SRV_CHROOT_DATA** - Stores Chroots used by Gerrit/Jenkins Nodes

#### To remove the Containers
Run ./rmbuildsystem.sh
If your data locations are anywhere non standard, or you're using a file other than defaults.sh use -f <file to use> as above.
