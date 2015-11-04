package main

import (
	"github.com/Parallels/docker-machine-parallels"
	"github.com/docker/machine/libmachine/drivers/plugin"
)

func main() {
	plugin.RegisterDriver(parallels.NewDriver("", ""))
}
