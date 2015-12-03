#!/bin/bash
# Copyright Smoothwall Ltd 2015

# Create a new buildsystem on a container host.
# Assumes the containers are built and in the registry already.
# Based on https://github.com/openfrontier/gerrit-docker/blob/master/createGerrit.sh

### Default values
# Source the defaults file, or the provided file
if [ -z $DEFAULTS_FILE ]; then
    echo "sourcing defaults.sh"
    source defaults.sh
else
	echo "sourcing $DEFAULTS_FILE"
	source $DEFAULTS_FILE
fi

# defaults to dev unless you've set -d 0
if [ $DEV -eq 1 ]; then
    HOST=localhost
    GERRIT_WEBURL=http://$HOST:8080
fi

# Set as Host -> localhost if workstation only.
HOST=${HOST:-10.50.18.161}

# Docker Network
DOCKER_NETWORK=${DOCKER_NETWORK:-buildsystem}

# PostgreSQL Gerrit
PG_GERRIT_IMAGE=${PG_GERRIT_IMAGE:-sw/gerrit-postgres}
PG_GERRIT_NAME=${PG_GERRIT_NAME:-pg-gerrit-container}
PG_GERRIT_DATA=${PG_GERRIT_DATA:-/var/lib/containers/${PG_GERRIT_IMAGE}}

# Redis
REDIS_IMAGE=redis:3.0.5
REDIS_NAME=${REDIS_NAME:-redis-container}
REDIS_DATA=${REDIS_DATA:-/var/lib/containers/${REDIS_IMAGE}}

# Gerrit
GERRIT_IMAGE=${GERRIT_IMAGE:-sw/gerrit}
GERRIT_WEBURL=${GERRIT_WEBURL:-http://gerrit.container.soton.smoothwall.net}
GERRIT_NAME=${GERRIT_NAME:-gerrit-container}

# Jenkins
    # Images
JENKINS_MASTER_IMAGE=${JENKINS_MASTER_IMAGE:-sw/jenkins-master}
JENKINS_CHILD_IMAGE=${JENKINS_CHILD_IMAGE:-sw/jenkins-child}
    # Names
JENKINS_MASTER_NAME=${JENKINS_MASTER_NAME:-jenmaster-container}
JENKINS_CHILD1_NAME=${JENKINS_CHILD1_NAME:-jenchild1-container}
JENKINS_CHILD2_NAME=${JENKINS_CHILD2_NAME:-jenchild2-container}
    # Data
JENKINS_DATA=${JENKINS_DATA:-/var/lib/containers/${JENKINS_MASTER_IMAGE}}
SYSADMINMAIL=${SYSADMINMAIL:-maintenance@smoothwall.net}

# Bugzilla
BUGZILLA_IMAGE=${BUGZILLA_IMAGE:-sw/bugzilla}
BUGZILLA_NAME=${BUGZILLA_NAME:-bugzilla-container}
ADMIN_EMAIL=${ADMIN_MAIL:-buildturbo@smoothwall.net}

# PostgreSQL Bugzilla
PG_BUGZILLA_IMAGE=${PG_BUGZILLA_IMAGE:-sw/bugzilla-postgres}
PG_BUGZILLA_NAME=${PG_BUGZILLA_NAME:-pg-bugzilla-container}
PG_BUGZILLA_DATA=${PG_BUGZILLA_DATA:-/var/lib/containers/${PG_BUGZILLA_IMAGE}}

# Buildfs / Lighttpd File server
BUILDFS_IMAGE=${BUILDFS_IMAGE:-sw/lighttpd/buildfs}
BUILDFS_NAME=${BUILDFS_NAME:-buildfs-web-container}

# URL for Internal Repository / Lighttpd File server
INTERNAL_REPO_IMAGE=${INTERNAL_REPO_IMAGE:-sw/lighttpd/internal_repo}
INTERNAL_REPO_NAME=${INTERNAL_REPO_NAME:-internal-repo-container}

MERGED_REPO_IMAGE=${MERGED_REPO_IMAGE:-sw/lighttpd/merged_repo}
MERGED_REPO_NAME=${MERGED_REPO_NAME:-merged-repo-container}

# Reverse proxy container
REVERSE_PROXY_IMAGE=${REVERSE_PROXY_IMAGE:-sw/reverse-proxy}
REVERSE_PROXY_NAME=${REVERSE_PROXY_NAME:-reverse-proxy-container}

########### Urls on buildfs, which we will probably run in a dedicated
########### container

BUILDLOGS_URL=${BUILDLOGS_URL:-http://$HOST:6789/logs}

GERRIT2_USER_UID=${GERRIT2_USER_UID:-1000}
BUILD_USER_UID=${BUILD_USER_UID:-1001}
POSTGRES_USER_UID=${POSTGRES_USER_UID:-999}

function wait {
    #$1 is container NAME
    #$2 is string to wait for
    echo "Waiting for $1 to become ready..."
    while [ -z "$(docker logs $1 2>&1 | grep "$2")" ]; do
        sleep 30
        echo "(still waiting)"
    done
    echo "$1 is ready."
}

function fail {
    echo "$@ returning... $?" >&2 && exit 2
}

# Precursor function to generate ssh keys for jenkins master->child
function distribute_keys {
    chmod 600 shared_home/build/.ssh/id_rsa

    #FIXME: This is probably already done in live.
    # Copy jenkins' key into SQL template
    # sed -e "s:@BUILD_SSH_KEY@:$(cat shared_home/build/.ssh/id_rsa.pub):" \
    # docker-sw-gerrit/jenkins_user.sql.master > docker-sw-gerrit/jenkins_user.sql

    # Give the same key to Gerrit2
    mkdir -p docker-sw-gerrit/.ssh
    cp shared_home/build/.ssh/id_rsa.pub docker-sw-gerrit/.ssh/id_rsa.pub
    cp shared_home/build/.ssh/id_rsa docker-sw-gerrit/.ssh/id_rsa

    # Add this key to build users authorized_keys
    cp docker-sw-gerrit/.ssh/id_rsa.pub shared_home/build/.ssh/authorized_keys
    
    cp shared_home/build/ssh_conf shared_home/build/.ssh/config
}

function create_docker_network {
    docker network create -d bridge ${DOCKER_NETWORK}
}

function rm_docker_network {
    docker network rm ${DOCKER_NETWORK}
}

function build_jenkins_master {
    # Master
    docker build -t ${JENKINS_MASTER_IMAGE} docker-jenkins-master || \
           fail "Building image ${JENKINS_MASTER_IMAGE} failed"
}

function build_jenkins {
# Assuming to build children -> master at the same time, maybe change
    # Child
    docker build -t ${JENKINS_CHILD_IMAGE} docker-jenkins-child || \
           fail "Building image ${JENKINS_CHILD_IMAGE} failed"
    # Master
    build_jenkins_master
}

function run_jenkins {
    echo "Waking up child nodes.."
    run_jenchild $JENKINS_CHILD1_NAME
    run_jenchild $JENKINS_CHILD2_NAME

    wait $JENKINS_CHILD1_NAME "Starting Jenkins Child"
    wait $JENKINS_CHILD2_NAME "Starting Jenkins Child"

    # Jenkins Master
    docker run \
        --name ${JENKINS_MASTER_NAME} \
        --privileged \
        -v ${JENKINS_DATA}:/var/jenkins_home/jobs \
        -v ${BUILDSYSTEM_DATA}:/usr/src/buildsystem \
        -v ${DEVMETADATA_DATA}:/usr/src/dev-metadata \
        -v ${REPO_DATA}:/usr/src/repository \
        -v ${HOME_BUILD_DATA}:/home \
        -v ${MNTBUILD_DATA}:/mnt/build \
        -v ${APTLY_DEBIANIZER_DATA}:/usr/src/aptly-debianizer \
        -v ${APTLY_S3_DATA}:/usr/src/aptly-s3 \
        -v ${SRV_CHROOT_DATA}:/srv/chroot \
        -v ${ETC_SCHROOT_CHROOTD}:/etc/schroot/chroot.d \
        -p 9000:8080 \
        -p 49999:49999 \
        -p 50000:50000 \
        -e "SYSADMINMAIL=${SYSADMINMAIL}" \
        -e "GERRIT_NAME=${GERRIT_NAME}" \
        -e "DEV=${DEV}" \
        -e "JENCHILD1_HOSTNAME=${JENKINS_CHILD1_NAME}" \
        -e "JENCHILD2_HOSTNAME=${JENKINS_CHILD2_NAME}" \
        -e "JENCHILD1_EXECUTORS=2" \
        -e "JENCHILD2_EXECUTORS=2" \
        -e "BUILDLOGS_URL=${BUILDLOGS_URL}" \
        -e "HOST=${HOST}" \
        --net=${DOCKER_NETWORK} \
        -d ${JENKINS_MASTER_IMAGE}

    wait $JENKINS_MASTER_NAME "setting agent port for jnlp... done"
}


function run_jenchild {
    CHILD_NAME=$1
    docker run \
    --name=${CHILD_NAME} \
    --privileged \
    -v ${BUILDSYSTEM_DATA}:/usr/src/buildsystem \
    -v ${DEVMETADATA_DATA}:/usr/src/dev-metadata \
    -v ${REPO_DATA}:/usr/src/repository \
    -v ${HOME_BUILD_DATA}:/home \
    -v ${MNTBUILD_DATA}:/mnt/build \
    -v ${APTLY_DEBIANIZER_DATA}:/usr/src/aptly-debianizer \
    -v ${APTLY_S3_DATA}:/usr/src/aptly-s3 \
    -v ${SRV_CHROOT_DATA}:/srv/chroot \
    -v ${ETC_SCHROOT_CHROOTD}:/etc/schroot/chroot.d \
    --net=${DOCKER_NETWORK} \
    -d ${JENKINS_CHILD_IMAGE}
}

function start_jenkins {
    docker start ${JENKINS_MASTER_NAME}
    docker start ${JENKINS_CHILD1_NAME}
    docker start ${JENKINS_CHILD2_NAME}
}

function stop_jenkins {
    # Stop
    docker stop ${JENKINS_MASTER_NAME}
    docker stop ${JENKINS_CHILD1_NAME}
    docker stop ${JENKINS_CHILD2_NAME}
}

function rm_jenkins {
# Assuming to remove children -> master at the same time, maybe change
    # Remove
    docker rm -v ${JENKINS_MASTER_NAME}
    docker rm -v ${JENKINS_CHILD1_NAME}
    docker rm -v ${JENKINS_CHILD2_NAME}
    # Delete data
#    sudo rm -rf ${JENKINS_DATA}
}

### PostgreSQL Gerrit
function build_pg_gerrit {
  docker build -t ${PG_GERRIT_IMAGE} docker-sw-gerrit-postgres || \
         fail "Building image ${PG_GERRIT_IMAGE} failed"
}

function run_pg_gerrit {
  echo "Starting PostgreSQL Gerrit..."
  
  # Kept in secrets git
  source docker-sw-gerrit/pg-gerrit-password.sh
  
  docker run \
    --name ${PG_GERRIT_NAME} \
    -p 5432:5432 \
    -v ${PG_GERRIT_DATA}:/var/lib/postgresql/data \
    -e POSTGRES_USER=gerrit2 \
    -e POSTGRES_PASSWORD=$PGPASSWORD \
    -e POSTGRES_DB=reviewdb \
    --net=${DOCKER_NETWORK} \
    -d ${PG_GERRIT_IMAGE}

  wait $PG_GERRIT_NAME "Future log output will appear in directory"
}

function start_pg_gerrit {
    docker start ${PG_GERRIT_NAME}
}

function stop_pg_gerrit {
    docker stop ${PG_GERRIT_NAME}
}
function rm_pg_gerrit {
  docker rm -v ${PG_GERRIT_NAME}
  # sudo rm -rf ${PG_GERRIT_DATA}
}

### Redis
# Redis does not have a build step, we can use the official image as is, we don't
# need to configure or import any data.

function run_redis {
    echo "Starting Redis ..."
    docker run \
        --name ${REDIS_NAME} \
        -p 6379:6379 \
        --net=${DOCKER_NETWORK} \
        -d ${REDIS_IMAGE}

    wait $REDIS_NAME "ready to accept connections on port 6379"
}

function start_redis {
    docker start ${REDIS_NAME}
}

function stop_redis {
    docker stop ${REDIS_NAME}
}

function rm_redis {
    docker rm -v ${REDIS_NAME}
}

### Gerrit (+extras)

function build_gerrit {
    docker build -t ${GERRIT_IMAGE} docker-sw-gerrit || \
           fail "Building image ${GERRIT_IMAGE} failed"
}

function run_gerrit {
  echo "Starting Gerrit ..."
    # -v ${GERRIT_DATA}:/var/gerrit/review_site \
  docker run \
    --name ${GERRIT_NAME} \
    --privileged \
    -v ${BUILDSYSTEM_DATA}:/usr/src/buildsystem \
    -v ${DEVMETADATA_DATA}:/usr/src/dev-metadata \
    -v ${REPO_DATA}:/usr/src/repository \
    -v ${HOME_BUILD_DATA}:/home \
    -v ${MNTBUILD_DATA}:/mnt/build \
    -v ${APTLY_DEBIANIZER_DATA}:/usr/src/aptly-debianizer \
    -v ${APTLY_S3_DATA}:/usr/src/aptly-s3 \
    -v ${GERRIT_GIT_DATA}:/usr/src/gerrit \
    -v ${SRV_CHROOT_DATA}:/srv/chroot \
    -v ${ETC_SCHROOT_CHROOTD}:/etc/schroot/chroot.d \
    -p 29418:29418 \
    -p 8080:8080 \
	-p 8081:80 \
    -p 222:22 \
    -e WEBURL=${GERRIT_WEBURL} \
    -e DATABASE_HOSTNAME=${PG_GERRIT_NAME} \
    -e REDIS_HOSTNAME=${REDIS_NAME} \
    -e HOST=${HOST} \
    --net=${DOCKER_NETWORK} \
    -d ${GERRIT_IMAGE}

  wait $GERRIT_NAME "Daemon : Gerrit Code Review"

  #https://code.google.com/p/gerrit/issues/detail?id=1305
  # Got problems with init? See above ...

}

function start_gerrit {
    docker start ${GERRIT_NAME}
}

function stop_gerrit {
    docker stop ${GERRIT_NAME}
}

function rm_gerrit {
  docker rm -v ${GERRIT_NAME}
  # sudo rm -rf ${GERRIT_DATA}
}

### PostgreSQL Bugzilla
function build_pg_bugzilla {
    docker build -t ${PG_BUGZILLA_IMAGE} docker-sw-bugzilla-postgres || \
           fail "Building image ${PG_BUGZILLA_IMAGE} failed"
}

function run_pg_bugzilla {
    echo "Starting PostgreSQL Bugzilla ..."

    # Kept in secrets git
    source shared_bugzilla/bugzilla-pg-password.sh

    docker run \
        --name ${PG_BUGZILLA_NAME} \
        -p 5433:5432 \
        -v ${PG_BUGZILLA_DATA}:/var/lib/postgresql/data \
        -e POSTGRES_USER=bugs \
        -e POSTGRES_PASSWORD=$DB_PASS \
        -e POSTGRES_DB=bugs \
        --net=${DOCKER_NETWORK} \
        -d ${PG_BUGZILLA_IMAGE}

    wait $PG_BUGZILLA_NAME "PostgreSQL init process complete; ready for start up"
}

function start_pg_bugzilla {
    docker start ${PG_BUGZILLA_NAME}
}

function stop_pg_bugzilla {
    docker stop ${PG_BUGZILLA_NAME}
}

function rm_pg_bugzilla {
  docker rm -v ${PG_BUGZILLA_NAME}
  # sudo rm -rf ${PG_BUGZILLA_DATA}
}

function build_bugzilla {
    docker build -t ${BUGZILLA_IMAGE} docker-sw-bugzilla || \
            fail "Building image ${BUGZILLA_IMAGE} failed"
}

function run_bugzilla {
    echo "Starting Bugzilla..."
    docker run \
        --name ${BUGZILLA_NAME} \
        -p 8888:80 \
        -e DB_HOST=${PG_BUGZILLA_NAME} \
        --net=${DOCKER_NETWORK} \
		-e ADMIN_EMAIL=${ADMIN_EMAIL} \
        -d ${BUGZILLA_IMAGE}

    # FIXME: If we ever set a fully qualified domain name this needs to be changed.
    wait $BUGZILLA_NAME "directive globally to suppress this message"
}

function start_bugzilla {
    docker start ${BUGZILLA_NAME}
}

function stop_bugzilla {
    docker stop ${BUGZILLA_NAME}
}

function rm_bugzilla {
    docker rm ${BUGZILLA_NAME}
}

function build_buildfs {
    docker build \
        -t ${BUILDFS_IMAGE} \
        --build-arg SERVER_ROOT=/mnt/build \
        docker-sw-lighttpd || \
    fail "Building image ${BUILDFS_IMAGE} failed"
}

function run_buildfs {
    echo "Starting Buildfs..."
    docker run \
        --name ${BUILDFS_NAME} \
        -p 6789:80 \
        -v ${MNTBUILD_DATA}:/mnt/build \
        --net=${DOCKER_NETWORK} \
        -d ${BUILDFS_IMAGE}
    echo "Buildfs container ${BUILDFS_NAME} running."
}

function start_buildfs {
    docker start ${BUILDFS_NAME}
}

function stop_buildfs {
    docker stop ${BUILDFS_NAME}
}

function rm_buildfs {
    docker rm -v ${BUILDFS_NAME}
}

function build_internal_repo {
    docker build \
        -t ${INTERNAL_REPO_IMAGE} \
        --build-arg SERVER_ROOT=/mnt/repository \
        docker-sw-lighttpd || \
    fail "Building image ${INTERNAL_REPO_IMAGE} failed"
}

function run_internal_repo {
    echo "Starting Internal Repository.."
    docker run \
        --name ${INTERNAL_REPO_NAME} \
        -p 9876:80 \
        -v ${REPO_DATA}:/mnt/repository/smoothwall \
        --net=${DOCKER_NETWORK} \
        -d ${INTERNAL_REPO_IMAGE}
    echo "Internal repository container ${INTERNAL_REPO_NAME} running."
}

function start_internal_repo {
    docker start ${INTERNAL_REPO_NAME}
}

function stop_internal_repo {
    docker stop ${INTERNAL_REPO_NAME}
}

function rm_internal_repo {
    docker rm -v ${INTERNAL_REPO_NAME}
}

function build_merged_repo {
    docker build \
        -t ${MERGED_REPO_IMAGE} \
        --build-arg SERVER_ROOT=/mnt/aptly-debianizer \
        docker-sw-lighttpd || \
    fail "Building image ${MERGED_REPO_IMAGE} failed"
}

function run_merged_repo {
    echo "Starting Merged Repository.."
    docker run \
        --name ${MERGED_REPO_NAME} \
        -v ${APTLY_DEBIANIZER_DATA}:/mnt/aptly-debianizer \
        --net=${DOCKER_NETWORK} \
        -d ${MERGED_REPO_IMAGE}
    echo "Merged repository container ${MERGED_REPO_NAME} running."
}

function start_merged_repo {
    docker start ${MERGED_REPO_NAME}
}

function stop_merged_repo {
    docker stop ${MERGED_REPO_NAME}
}

function rm_merged_repo {
    docker rm -v ${MERGED_REPO_NAME}
}


function build_reverse_proxy {
    docker build \
        -t ${REVERSE_PROXY_NAME} \
        docker-sw-reverse-proxy || \
    fail "Building image ${REVERSE_PROXY_NAME} failed"
}

function run_reverse_proxy {
    echo "Starting reverse proxy..."
    docker run \
        --name ${REVERSE_PROXY_NAME} \
        -p 80:80 \
        --net=${DOCKER_NETWORK} \
        -d ${REVERSE_PROXY_NAME}
    echo "Reverse proxy started"
}

function start_reverse_proxy {
    docker start ${REVERSE_PROXY_NAME}
}

function stop_reverse_proxy {
    docker stop ${REVERSE_PROXY_NAME}
}

function rm_reverse_proxy {
    docker rm ${REVERSE_PROXY_NAME}
}

# This function is to prevent needing to run the Docker build's from a higher context.
# It allows multiple images to share files, without needing duplicate copies.
function copy_shared {
    for DEST in docker-jenkins-child \
                docker-jenkins-master \
                docker-sw-gerrit \
                ;
    do
        cp -ar shared $DEST/
    done
}

function rm_shared_copies {
    for DEST in docker-jenkins-child \
                docker-jenkins-master \
                docker-sw-gerrit \
                ;
    do
        rm -rf $DEST/shared
    done
}

# Copy our apt-keys (cbuild-secrets.git) into build context for each container
function copy_apt-keys {
    for DEST in docker-jenkins-master \
                docker-sw-gerrit \
                docker-jenkins-child \
                ;
    do
        cp -ar apt-keys $DEST/apt-keys
    done 
}

# Remove local copies of apt-keys from container build context's
function rm_apt-keys {
    for DEST in docker-jenkins-master \
                docker-sw-gerrit \
                docker-jenkins-child \
                ;
    do
        rm -rf $DEST/apt-keys
    done 
}

# Copy our gpg keys (cbuild-secrets.git) into shared_home ready to be shipped
# into mounted fs for /home/build
function copy_gnupg {
    cp -ar .gnupg shared_home/build/.gnupg
}

# Remove copy of gpg keys from shared_home
function rm_gnupg {
    rm -rf shared_home/build/.gnupg
}

# Copy common_jenkins into the build context of master & children
function copy_common_jenkins {
    for DEST in docker-jenkins-master \
                docker-jenkins-child \
                ;
    do
        cp -ar common_jenkins/* $DEST
    done
}

# Remove local copy of common_jenkins from master & children's build context
function rm_common_jenkins {
    for FILE in common_jenkins/*
    do
        rm -rf docker-jenkins-master/$FILE
        rm -rf docker-jenkins-child/$FILE
    done
}

# Copy shared_bugzilla into the build context of bugzilla and pg-bugzilla
function copy_shared_bugzilla {
    for DEST in docker-sw-bugzilla \
                docker-sw-bugzilla-postgres \
                ;
    do
        cp -ar shared_bugzilla/* $DEST
    done
}

# Remove local copy of shared_bugzilla from bugzilla & pg-bugzilla's build context
function rm_shared_bugzilla {
    for FILE in shared_bugzilla/*
    do
        rm -rf docker-sw-bugzilla/$FILE
        rm -rf docker-sw-bugzilla-postgres/$FILE
    done
}

# Copy shared_db_conf to the database containers, pg-gerrit and pg-bugzilla
function copy_shared_db_conf {
    for DEST in docker-sw-gerrit-postgres \
                docker-sw-bugzilla-postgres \
                ;
    do
        cp -ar shared_db_conf/* $DEST
    done
}

# Remove local copy of shared_db_conf from pg-gerrit and pg-bugzilla
function rm_shared_db_conf {
    for FILE in shared_db_conf/*
    do
        rm -rf docker-sw-gerrit-postgres/$FILE
        rm -rf docker-sw-bugzilla-postgres/$FILE
    done
}

# FIXME: Will be removed when all is on BUILDFS and has correct permissions/exists already
function make_mount_directories {
    for i in \
        $APTLY_DEBIANIZER_DATA \
        $APTLY_S3_DATA \
        $BUILDSYSTEM_DATA \
        $DEVMETADATA_DATA \
        $GERRIT_GIT_DATA \
        $HOME_BUILD_DATA \
        $JENKINS_DATA \
        $MNTBUILD_DATA \
        $PG_BUGZILLA_DATA \
        $PG_GERRIT_DATA \
        $REPO_DATA \
        $SRV_CHROOT_DATA \
        $ETC_SCHROOT_CHROOTD \
        ; do
            mkdir -p $i
    done
}

# FIXME: Will be removed when all is on BUILDFS and has correct permissions/exists already
# This needs to be ran twice currently. The empty directories need to have the correct permissions
# and then once data is imported into them, so do their contents
function change_permissions_of_mounts {
    # Chown everything to build
    sudo chown -R $BUILD_USER_UID:$BUILD_USER_UID $BUILD_HOME
    # Then rechown those which need to be other.
    # chroot's in srv-chroot & chroot config's in etc-schroot need to be root
    sudo chown -R 0:0 $ETC_SCHROOT_CHROOTD $SRV_CHROOT_DATA
    # And git's need to be owned by Gerrit2
    sudo chown -R $GERRIT2_USER_UID:$GERRIT2_USER_UID $GERRIT_GIT_DATA
    # And postgres needs to be postgres User
    sudo chown -R $POSTGRES_USER_UID:$POSTGRES_USER_UID $PG_GERRIT_DATA $PG_BUGZILLA_DATA
}
