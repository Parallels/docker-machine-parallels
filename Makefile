# Initialize version flag
GO_LDFLAGS := -X $(shell go list ./).GitCommit=$(shell git rev-parse --short HEAD 2>/dev/null)

default: build

bin/docker-machine-driver-parallels:
	go build -ldflags "$(GO_LDFLAGS)" \
	-o ./bin/docker-machine-driver-parallels ./bin

build: clean bin/docker-machine-driver-parallels

clean:
	$(RM) bin/docker-machine-driver-parallels

install: bin/docker-machine-driver-parallels
	cp -f ./bin/docker-machine-driver-parallels $(GOPATH)/bin/

test-acceptance:
	test/integration/run-bats.sh test/integration/bats/

.PHONY: clean build install test-acceptance
