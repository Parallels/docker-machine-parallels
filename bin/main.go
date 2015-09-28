package main

import (
	parallels "github.com/Parallels/docker-machine-parallels"
	"github.com/docker/machine/libmachine/drivers/plugin"
)

func main() {
	plugin.RegisterDriver(new(parallels.Driver))
}
