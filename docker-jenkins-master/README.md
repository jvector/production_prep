Dockerized Jenkins Master node.

Full build instructions can be seen in the Dockerfile. 

Contents of /config_files gets put in /var/jenkins_home/
			/scripts gets put in /
			/plugins go in /var/jenkins_home/plugins/
			/shared_src goes in /usr/src/
				(At make time, shared_src is copied in from one directory up)

The contents of .ssh are created and configured when you run mkbuildsystem.sh,
if you wish to run this without using mkbuildsystem copy the steps within to
generate keys which match.

If you want to add a plugin, download the jpi/hpi and put it inside /pluginjars/,
if you need this pinned to a specific version touch a .pinned into /plugins/

Ensure that all files / scripts in the scripts folder are executable, the Dockefile
copies them as is and won't error if they don't run.
