# cbuildsystem
Containerised Build System

#### To bring up the Containers
**Prerequisites**
* Docker 1.9+ is installed
* You need access to the SmoothwallBuildUser GitHub account which has access to the Smoothwall private repo's ***or*** you need a copy of the build user's id_rsa from buildfs:/home/build/.ssh

**Steps**
* **First:** Either copy the build user's id_rsa from buildfs:/home/build/.ssh and add the following to your ~/.ssh/config
```
Host github.com
 IdentityFile /path/to/build/users/ssh/id_rsa
```
or generate a key, and add it to the SmoothwallBuildUser's GitHub SSH keys.

* **Then:** Clone this repository into a directory on the host. *e.g. `git clone git@github.com:Smoothwall/cbuild-secrets.git /root/docker/cbuildsystem`*
* At this point examine the contents of the file `defaults.sh`, if required either change `$BUILD_HOME` here or define and export in the root users `.bashrc` before continuing.
* `cd` into that directory and run `./prepare.sh`, creating cbuildsystem-merged.
    * `cd` into the newly created cbuildsystem-merged.
    * Begin by running `./build.sh`, which will build all the images from the Dockerfiles
    * If you have existing running containers (type `docker ps -a` to show) then you will need to run `./stop.sh` followed by `./remove.sh` now.
    * Next run `./run.sh`, which will bring up all of the containers. You can supply this script with some options. *note: this can take 20mins+*

| Option | Result |
| :------ | :------ |
| -d (0 or 1) | Dev mode ON/OFF, disables IRC & mail on jenkins and changes some links to localhost, defaults to 0 if not provided. |
| -f (defaults file) | Point container_functions.sh at a non-standard defaults file, defaults to using defaults.sh if not provided |

#### Importing Data
* Once all the containers are initialized you will have an empty buildsystem. If you do not have existing data in the $BUILD_HOME directories you will need to run `import.sh`.
* `import.sh` requires an argument, the options are 'jenkins', 'gerrit', 'singlehost' or 'dev'.
    * **jenkins** - Not yet fully implemented, aiming to be used to get the relevant data used by a Jenkins-only Buildwhale
    * **gerrit** - Not yet fully implemented, aiming to be used to get the relevant data used by a Gerrit-only Buildwhale
    * **singlehost** - Grab a copy of all data from \*.metal.* buildsystem to create an replication of live including all its data. *note: 300GB+ data being moved around*
    * **dev** - Populate your $BUILD_HOME with a small subset of data, a couple gits and chroot's, enough to be used as a local test buildsystem. *note: needs sotonfs mounted as /global*

##### On a Buildwhale
* Run the steps above, resulting in an empty buildsystem being created.
* Verify that $BUILD_HOME is where you expected it to be, and that the partition it is on has sufficient space.
* Generate a ssh-key and add that to .metal.Gerrit/Jenkins against user victor (FIXME)
* Run `/import.sh singlehost` and wait.
* Data will be rsync'd from Live, and when finished the containers reloaded. *note: reloading them will take a further 20mins+*

##### On a local dev workstation
* Run the steps above, resulting in an empty buildsystem being created.
* Verify that $BUILD_HOME is where you expected it to be.
* Run `/import.sh dev` and wait.
* A small subset of data will be rsync'd from sotonfs, and when finished the containers reloaded.

#### To remove the Containers
Run ./stop.sh and then ./remove.sh.
The data stored in $BUILD_HOME is left untouched by these scripts, so that it can persist. If you wont need any of this again and want to reclaim space, `rm -rf` your $BUILD_HOME directory.

#### File stores
The cbuildsystem Containers create/use some directories on the host as per the defaults file, these are.

* **APTLY_DEBIANIZER_DATA** - Stores a shared /usr/src/aptly-debianizer between containers
* **APTLY_S3_DATA** - Stores a shared /usr/src/aptly-s3 between containers
* **BUILDSYSTEM_DATA** - Stores a shared /usr/src/buildsystem/ between containers
* **DEVMETADATA_DATA** - Stores a shared /usr/src/dev-metadata/ between containers
* **GERRIT_GIT_DATA** - Stores Gerrit's /usr/src/gerrit directory
* **HOME_BUILD_DATA** - Stores a shared /home/build/ between containers
* **JENKINS_DATA** - Stores Jenkins home directory (including jobs/views/build history)
* **MNTBUILD_DATA** - Stores a shared /mnt/build between containers
* **PG_BUGZILLA_DATA** - Stores Postgresql Database used by Bugzilla
* **PG_GERRIT_DATA** - Stores Postgresql Database used by Gerrit
* **REPO_DATA** - Stores a shared /usr/src/repository/ between containers
* **SRV_CHROOT_DATA** - Stores Chroots used by Gerrit/Jenkins Nodes
* **ETC_SCHROOT_CHROOT** - Stores Chroot configs used by Gerrit/Jenkins Nodes

Eventually these will be stored on Buildfs and only exist on local dev copies.

#### Updating
The easiest way is to wipe out the /root/docker directory and do the steps above again. The data that the containers use is untouched by the stop and remove scripts so when you bring up a new updated version providing you haven't broken things they should just work. 

This will take the full 20mins+ so if you have a particularly minor change, or your changes only affect one/two containers you can `source container_functions.sh` and manually invoke the functions needed to stop_container, rm_container, build_container, run_container. Sometimes this way things can get out of sync, in which case it is recommended to just start again from scratch.

*Note: If you re-clone cbuildsystem make sure to point defaults.sh at the same place to use the existing data*

#### Debugging

##### Build Errors
Output of the `docker build` commands ran during `./build.sh` is directed to the file `build.log`, if your build fails you will execution will fail and the error will be returned. You can look at `build.log` for further information on progress / execution steps before it failed, although usually the error returned via the Docker build daemon is usually enough.

#### Container logs
Docker syphons the output of a containers running process (which due to the nature of containers, is the most important thing they run). As a result, you may not find log's where you expect them within the container. If you want to view logs use `docker logs <container-name>` (with the optional `-f` after logs to follow this).

This log info persists even if the container bombs out and stops running, but is lost when you `docker rm <container-name>`

#### Logging into Containers
To get a shell on a running container, use `docker exec -it <container-name> bash`.
