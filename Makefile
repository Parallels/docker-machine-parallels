# Support go1.5 vendoring (let us avoid messing with GOPATH or using godep)
export GO15VENDOREXPERIMENT = 1

GODEP_BIN := $(GOPATH)/bin/godep
GODEP := $(shell [ -x $(GODEP_BIN) ] && echo $(GODEP_BIN) || echo '')

default: build

bin/docker-machine-driver-parallels:
	go build -i -o ./bin/docker-machine-driver-parallels ./bin

build: clean bin/docker-machine-driver-parallels

clean:
	$(RM) bin/docker-machine-driver-parallels

install: bin/docker-machine-driver-parallels
	cp -f ./bin/docker-machine-driver-parallels $(GOPATH)/bin/

test-acceptance:
	test/integration/run-bats.sh test/integration/bats/

dep-save:
	$(if $(GODEP), , \
		$(error Please install godep: go get github.com/tools/godep))
	$(GODEP) save $(shell go list ./... | grep -v vendor/)

dep-restore:
	$(if $(GODEP), , \
		$(error Please install godep: go get github.com/tools/godep))
	$(GODEP) restore -v

.PHONY: clean build dep-save dep-restore install test-acceptance
