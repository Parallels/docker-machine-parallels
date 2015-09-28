default: build

build:
	go build -i -o docker-machine-parallels ./bin

clean:
	$(RM) docker-machine-parallels

install: build
	cp ./docker-machine-parallels /usr/local/bin/docker-machine-parallels

.PHONY: install
