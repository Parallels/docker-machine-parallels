# Docker Machine Parallels Driver

### PREVIEW
This is a pre-release version of Parallels Driver for Docker Machine.
Work is still in progress.

This is a plugin for Docker Machine, wich is gonna be compatible with Docker
Machine v0.5.0.
Refer to this PR for more details: https://github.com/docker/machine/pull/1902

## Build

```bash
$ go get -d github.com/Parallels/docker-machine-parallels
$ cd $GOPATH/github.com/Parallels/docker-machine-parallels
$ make
```

The binary will appear in the working directory. Just make it available on the `$PATH`

## Authors

* Mikhail Zholobov ([@legal90](https://github.com/legal90))
* Rickard von Essen ([@rickard-von-essen](https://github.com/rickard-von-essen))
