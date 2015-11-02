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

# PostgreSQL
PG_GERRIT_IMAGE=${PG_GERRIT_IMAGE:-sw/gerrit-postgres}
PG_GERRIT_NAME=${PG_GERRIT_NAME:-pg-gerrit}
PG_GERRIT_DATA=${PG_GERRIT_DATA:-/var/lib/containers/${PG_GERRIT_IMAGE}}

# Gerrit
GERRIT_IMAGE=${GERRIT_IMAGE:-sw/gerrit}
GERRIT_WEBURL=${GERRIT_WEBURL:-http://localhost:8080}
GERRIT_NAME=${GERRIT_NAME:-gerrit}
GERRIT_DATA=${GERRIT_DATA:-/var/lib/containers/${GERRIT_IMAGE}}

# Jenkins
    # Images
JENKINS_MASTER_IMAGE=${JENKINS_MASTER_IMAGE:-sw/jenkins-master}
JENKINS_CHILD_IMAGE=${JENKINS_CHILD_IMAGE:-sw/jenkins-child}
    # Names
JENKINS_MASTER_NAME=${JENKINS_MASTER_NAME:-jenmaster}
JENKINS_CHILD1_NAME=${JENKINS_CHILD1_NAME:-jenchild1}
JENKINS_CHILD2_NAME=${JENKINS_CHILD2_NAME:-jenchild2}
    # Data
JENKINS_DATA=${JENKINS_DATA:-/var/lib/containers/${JENKINS_MASTER_IMAGE}}
JENKINS_MASTER_HOSTNAME=${JENKINS_MASTER_HOSTNAME:-localhost}
SYSADMINMAIL=${SYSADMINMAIL:-maintenance@smoothwall.net}

function fail {
    echo "$@ returning... $?" >&2 && exit 2
}

# Precursor function to generate ssh keys for jenkins master->child
function generate_keys {
    # Make the key for build user
    ssh-keygen -N "" -f shared_home/build/.ssh/id_rsa -C "Generated_by_DockerFile_for_build_user"

    # Copy jenkins' key into SQL template
    sed -e "s:@BUILD_SSH_KEY@:$(cat shared_home/build/.ssh/id_rsa.pub):" \
    docker-sw-gerrit/jenkins_user.sql.master > docker-sw-gerrit/jenkins_user.sql

    # Give the same key to Gerrit2
    cp shared_home/build/.ssh/id_rsa.pub docker-sw-gerrit/.ssh/id_rsa.pub
    cp shared_home/build/.ssh/id_rsa docker-sw-gerrit/.ssh/id_rsa

    # Add this key to build users authorized_keys
    cp docker-sw-gerrit/.ssh/id_rsa.pub shared_home/build/.ssh/authorized_keys
    
    cp shared_home/build/ssh_conf /shared_home/build/.ssh/config
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

function start_jenkins {
    echo "Waking up child nodes.."
    start_jenchild $JENKINS_CHILD1_NAME
    start_jenchild $JENKINS_CHILD2_NAME

    echo "Waiting for the jenkins child nodes to become ready ..."
	echo "(This should take about 10s)"
	while [ -z "$(docker logs ${JENKINS_CHILD1_NAME} 2>&1 | grep 'Starting Jenkins Child')" ] || \
			  [ -z "$(docker logs ${JENKINS_CHILD2_NAME} 2>&1 | grep 'Starting Jenkins Child')" ]; do
		sleep 1
		echo "(still waiting)"
	done

    # Jenkins Master
    docker run \
        --name ${JENKINS_MASTER_NAME} \
        --link ${JENKINS_CHILD1_NAME}:jenchild1 \
        --link ${JENKINS_CHILD2_NAME}:jenchild2 \
        --privileged \
        -v ${JENKINS_DATA}:/var/jenkins_home/jobs \
        -v ${REPO_DATA}:/usr/src/repository \
        -v ${HOME_BUILD_DATA}:/home \
        -p 9000:8080 \
        -e "SYSADMINMAIL=${SYSADMINMAIL}" \
        -e "GERRIT_NAME=${GERRIT_NAME}" \
        -e "DEV=${DEV}" \
        -d ${JENKINS_MASTER_IMAGE}

    echo "Waiting for the jenkins master to become ready ..."
	echo "(This should take about 60s)"
	while [ -z "$(docker logs ${JENKINS_MASTER_NAME} 2>&1 | grep 'setting agent port for jnlp... done')" ]; do
		sleep 4
		echo "(still waiting)"
	done
}

function start_jenchild {
    CHILD_NAME=$1
    docker run \
    --name=${CHILD_NAME} \
    --privileged \
    -v ${REPO_DATA}:/usr/src/repository \
    -v ${HOME_BUILD_DATA}:/home \
    -d ${JENKINS_CHILD_IMAGE}
}

function rm_jenkins {
# Assuming to remove children -> master at the same time, maybe change
    # Stop
    docker stop ${JENKINS_MASTER_NAME}
    docker stop ${JENKINS_CHILD1_NAME}
    docker stop ${JENKINS_CHILD2_NAME}
    # Remove
    docker rm ${JENKINS_MASTER_NAME}
    docker rm ${JENKINS_CHILD1_NAME}
    docker rm ${JENKINS_CHILD2_NAME}
    # Delete data
#    sudo rm -rf ${JENKINS_DATA}
}

### PostgreSQL
function build_postgres {
  docker build -t ${PG_GERRIT_IMAGE} docker-sw-gerrit-postgres || \
         fail "Building image ${PG_GERRIT_IMAGE} failed"
}

function start_postgres {
  echo "Starting PostgreSQL ..."
  
  # Kept in secrets git
  source docker-sw-gerrit/pg-gerrit-password.sh
  
  docker run \
    --name ${PG_GERRIT_NAME} \
    -p 5432:5432 \
    -v ${PG_GERRIT_DATA}:/var/lib/postgresql/data \
    -e POSTGRES_USER=gerrit2 \
    -e POSTGRES_PASSWORD=$PGPASSWORD \
    -e POSTGRES_DB=reviewdb \
    -d ${PG_GERRIT_IMAGE}

  # This actually only works the first time the container is spun up.
  # When running this up with an existing data directory, it won't
  # work.
  echo "Waiting for the database to become ready ..."
  echo "(This should take about 10s)"
  while [ -z "$(docker logs ${PG_GERRIT_NAME} 2>&1 | grep 'autovacuum launcher started')" ]; do
    sleep 2
    echo "(still waiting)"
  done
sleep 30
  echo "PostgreSQL container ${PG_GERRIT_NAME} running."
}

function rm_postgres {
  docker stop ${PG_GERRIT_NAME}
  docker rm ${PG_GERRIT_NAME}
  sudo rm -rf ${PG_GERRIT_DATA}
}

### Gerrit (+extras)

function build_gerrit {
    docker build -t ${GERRIT_IMAGE} docker-sw-gerrit || \
           fail "Building image ${GERRIT_IMAGE} failed"
}

function start_gerrit {
  echo "Starting Gerrit ..."
  docker run \
    --name ${GERRIT_NAME} \
    --link ${PG_GERRIT_NAME}:db \
    --link ${JENKINS_MASTER_NAME}:jk \
    -v ${GERRIT_DATA}:/var/gerrit/review_site \
    -v ${REPO_DATA}:/usr/src/repository \
    -v ${HOME_BUILD_DATA}:/home \
    -p 29418:29418 \
    -p 8080:8080 \
    -e WEBURL=${GERRIT_WEBURL} \
    -e DATABASE_TYPE=postgresql \
    -d ${GERRIT_IMAGE}

  echo "Waiting for Gerrit to boot ..."
  echo "(This should take about 45s)"
  while [ -z "$(docker logs ${GERRIT_NAME} 2>&1 | grep 'Daemon : Gerrit Code Review')" ]; do
    sleep 8
    echo "(still waiting)"
  done

  echo "Gerrit container ${GERRIT_NAME} running."

  #https://code.google.com/p/gerrit/issues/detail?id=1305
  # Got problems with init? See above ...

}

function rm_gerrit {
  docker stop ${GERRIT_NAME}
  docker rm ${GERRIT_NAME}
  sudo rm -rf ${GERRIT_DATA}
}

# This function is to prevent needing to run the Docker build's from a higher context.
# It allows multiple images to share files, without needing duplicate copies.
function copy_shared {
    for DEST in docker-jenkins-child \
                docker-jenkins-master \
                docker-sw-gerrit \
                ;
    do
        cp -ar shared_buildsystem $DEST/
    done
}

function rm_shared_buildsystem_copies {
    for DEST in docker-jenkins-child \
                docker-jenkins-master \
                docker-sw-gerrit \
                ;
    do
        rm -rf $DEST/shared_buildsystem
    done
}

function copy_into_repo {
    cp -ar shared_repo/repository $REPO_DATA
}

function rm_from_repo {
    sudo rm -rf $REPO_DATA
}

function copy_into_home_build_mount {
    mkdir -p $HOME_BUILD_DATA
    cp -ar shared_home/build $HOME_BUILD_DATA
}

function rm_from_home_build_mount {
    sudo rm -rf $HOME_BUILD_DATA
}

function copy_apt-keys {
    for DEST in docker-jenkins-master \
                docker-sw-gerrit \
                docker-jenkins-child \
                ;
    do
        cp -ar apt-keys $DEST/apt-keys
    done 
}

function rm_apt-keys {
    for DEST in docker-jenkins-master \
                docker-sw-gerrit \
                docker-jenkins-child \
                ;
    do
        rm -rf $DEST/apt-keys
    done 
}

function copy_gnupg {
    cp -ar .gnupg shared_home/build/.gnupg
}

function rm_gnupg {
    rm -rf shared_home/build/.gnupg
}

function copy_shared_jenkins {
    for DEST in docker-jenkins-master \
                docker-jenkins-child \
                ;
    do
        cp -ar shared_jenkins/* $DEST
    done
}

function rm_shared_jenkins {
    for FILE in shared_jenkins/*
    do
        rm -rf docker-jenkins-master/$FILE
        rm -rf docker-jenkins-child/$FILE
    done
}

function genesis_config {
    sed -e "s/@JENKINS_MASTER@/${JENKINS_MASTER_NAME}/" \
    -e "s/@JENCHILD1@/${JENKINS_CHILD1_NAME}/" \
    -e "s/@JENCHILD2@/${JENKINS_CHILD2_NAME}/" \
    -e "s/@GERRIT@/${GERRIT_NAME}/" \
    configuration.json.master \
    > shared_buildsystem/buildsystem/genesis/configuration.json
}
