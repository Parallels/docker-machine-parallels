default: build

build:
	go build -i -o docker-machine-driver-parallels ./bin

clean:
	$(RM) docker-machine-driver-parallels

install: build
	cp -r ./docker-machine-driver-parallels /usr/local/bin/

.PHONY: install
