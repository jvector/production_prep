## cbuildsystem - docker-sw-lighttpd

### About this image

This very simple image is based from the official debian:jessie image, onto which we install lighttpd and do a small amount of config.

We enable the cgi, dir-listing and accesslog modules.

Once built and running this container simple acts as a file server, for whichever directory you have provided it at build time and mounted at run time.

e.g. To serve /foo/bar directory provide
`--build-arg SERVER_ROOT=/foo/bar` when building, and `-v /local/dir:/foo/bar` when running.

We run this image multiple times by simply mounting different files into each. One to display internal_repository and one for the merged_repository.

### Build example

```
docker build \
    -t <image-name> \
    --build-arg SERVER_ROOT=/container/serve/dir \
    /path/to/Dockerfile
```

###### Notes
You **must** provide build argument **SERVER_ROOT**
* **SERVER_ROOT** is the directory to be set as server root in the lighttpd config.

### Run example
```
docker run \
    --name <container-name> \
    -p 6789:80 \
    -v /local/dir:/container/serve/dir \
    --net=<custom-docker-network> \
    -d <image-name>
```
###### Notes
* Make sure the mounted volume matches the SERVER_ROOT provided when you build the image, or the file server will simply serve the contents of SERVER_ROOT, which would likely be empty.
* Lighttpd runs on internal port 80, but this can be mapped to any port you wish on host.

### Extras
