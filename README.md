# cbuildsystem

Containerised Build System Based on use of Docker images to set up the build environment.

Currently it relies on the use of public images for the following:
* debian jessie as core Linux Distribution for all of the containers
* postgresql 9.4
* jenkins 1.609.3
* gerrit latest
* nginx 1.9
* redis 3.0.5
* postfix


#### Requirements
Before setting up the build env it's necessary to setup the following:
* Docker 1.9+
* permissions set so docker can be run without the sudo
* access to the following SmoothWall github repos:
	* cbuildsystem
	* cbuild-secrets
* your public key is added to the github


#### Development
In order to setup dev env on your local you'll need to do the following:
* fork off the Smoothwall master repo: https://github.com/Smoothwall/cbuildsystem

* clone the fork of the repo:

	```
	git clone git@github.com:[YOUR GITHUB ACCOUNT]/cbuildsystem.git /path/to/your/local/repos/cbuildsystem
	```

* Currently all development happens on the gerrit-containerhost branch. So this needs to be checked out:

	```
	git checkout gerrit-containerhost
	```

* Set you BUILD_HOME path:

	```
	export BUILD_HOME=your/build/output/path
	```
	for convenience you might add it to you rc file.

* go to the folder with fresh checkout of the build project:

	```
	cd /path/to/your/local/repos/cbuildsystem
	```
	and run the prepare script:

	```
	./prepare.sh
	```
	The above script will clone the git repo containing the cbuild-secrets:

	```
	git@github.com:Smoothwall/cbuild-secrets.git
	```
	Currently will pull from the ```gerrit-containerhost``` branch and will copy it as well as the cbuild system into the folder ```cbuildsystem-merged```. This folder will be located on the same level as you repos.

* when done got to the merged folder:
	
	```
	cd ../cbuildsystem-merged
	```

* run build script:

	```
	./build.sh
	```
	This script will complete the following actions:
	* copy the content of the shared folder into jenkins and gerrit locations
	* copy the ```.gnupg``` file
	* copy the apt-keys into the the jenkins children, master and gerrit locations
	* copy the ```common_jenkins``` folder into jenkins children and master locations
	* copy the shared_db_conf content into gerrit and bugzilla locations
	* Run build process of the containers:
		* postgresql for gerrit and gerrit
		* jenkins
		* buildfs
		* internal_repo
		* merged_repo
		* reverse_proxy

	On a fresh machine build step takes ~40 mins, as it has to pull generic docker images and install the required dependencies.

* After build has completed it's time to run the containers. Before you do that make sure you're not running any of the containers. In order to do that run:
	```
	docker ps -a
	```

	If you have containers listed run 
	```
	./stop && ./remove.sh
	```
	This will stop running containers and remove them. Now you can proceed with running the new containers.
	```
	./run.sh
	```
	This will start all of the following:
	* postgresql for gerrit
	* jenkins
	* gerrit
	* redis
	* postfix
	* buildfs
	* insternal_repo
	* merged_repo
	* reverse_proxy

	This may be run with the following options.

	| Option | Result |
	| :------ | :------ |
	| -d (0 or 1) | Dev mode ON/OFF, disables IRC & mail on jenkins and changes some links to localhost, defaults to 0 if not provided. |
	| -f (defaults file) | Point container_functions.sh at a non-standard defaults file, defaults to using defaults.sh if not provided |

	Run process take upwards of 20 min, so it's a good time to get a coffee...

* Once all the containers are initialized you will have an empty buildsystem. If you do not have existing data in the $BUILD_HOME directories you will need to run:
	```
	./import.sh
	```
	It requires an argument, the options are 'jenkins', 'gerrit', 'singlehost' or 'dev'.
    * **jenkins** - Not yet fully implemented, aiming to be used to get the relevant data used by a Jenkins-only Buildwhale
    * **gerrit** - Not yet fully implemented, aiming to be used to get the relevant data used by a Gerrit-only Buildwhale
    * **singlehost** - Grab a copy of all data from \*.metal.* buildsystem to create an replication of live including all its data. *note: 300GB+ data being moved around*
    * **dev** - Populate your $BUILD_HOME with a small subset of data, a couple gits and chroot's, enough to be used as a local test buildsystem. *note: needs sotonfs mounted as /global*
	

#### On a Buildwhale (Production)
* Run the steps above, resulting in an empty buildsystem being created.
* Verify that $BUILD_HOME is where you expected it to be, and that the partition it is on has sufficient space.
* Generate a ssh-key and add that to .metal.Gerrit/Jenkins against user victor (FIXME)
* Run `/import.sh singlehost` and wait.
* Data will be rsync'd from Live, and when finished the containers reloaded. *note: reloading them will take a further 20mins+*

#### To remove the Containers
Run 
```
./stop.sh && ./remove.sh.
```

The data stored in $BUILD_HOME is left untouched by these scripts, so that it can persist. If you wont need any of this again and want to reclaim space, `rm -rf` your $BUILD_HOME directory.

#### File stores
The cbuildsystem Containers create/use some directories on the host as per the defaults file, these are.

* **APTLY_DEBIANIZER_DATA** - Stores a shared /usr/src/aptly-debianizer between containers
* **APTLY_DEBIANIZER-SERVE_DATA** - Stores a shared /usr/src/aptly-debianizer-serve between containers
* **APTLY_S3_DATA** - Stores a shared /usr/src/aptly-s3 between containers
* **BUILDSYSTEM_DATA** - Stores a shared /usr/src/buildsystem/ between containers
* **DEVMETADATA_DATA** - Stores a shared /usr/src/dev-metadata/ between containers
* **GERRIT_GIT_DATA** - Stores Gerrit's /usr/src/gerrit directory
* **HOME_BUILD_DATA** - Stores a shared /home/build/ between containers
* **VAR_GERRIT_SSH_DATA** - Stores a persistant /var/gerrit/.ssh for the gerrit-container
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

This will take the full 20mins+ so if you have a particularly minor change, or your changes only affect one/two containers you can 
```
source container_functions.sh
``` 
and manually invoke the functions needed to stop_container, rm_container, build_container, run_container. Sometimes this way things can get out of sync, in which case it is recommended to just start again from scratch.

*Note: If you re-clone cbuildsystem make sure to point defaults.sh at the same place to use the existing data*

#### Debugging

##### Build Errors
Output of the `docker build` commands ran during `./build.sh` is directed to the file `build.log`, if your build fails you will execution will fail and the error will be returned. You can look at `build.log` for further information on progress / execution steps before it failed, although usually the error returned via the Docker build daemon is usually enough.

#### Container logs
Docker syphons the output of a containers running process (which due to the nature of containers, is the most important thing they run). As a result, you may not find log's where you expect them within the container. If you want to view logs use 
```
docker logs <container-name>
```
(with the optional `-f` after logs to follow this).

This log info persists even if the container bombs out and stops running, but is lost when you 
```
docker rm <container-name>
```

#### Logging into Containers
To get a shell on a running container, use 
```
docker exec -it <container-name> bash
```
where
```-i ``` stands for interactive and
```-t ``` will allocate pseudo TTY shell.
