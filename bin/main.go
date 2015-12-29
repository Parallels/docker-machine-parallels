package main

import (
	"os"
	"path"

	"github.com/Parallels/docker-machine-parallels"
	"github.com/codegangsta/cli"
	"github.com/docker/machine/libmachine/drivers/plugin"
)

var appHelpTemplate = `This is a Docker Machine plugin for Parallels Desktop.
Plugin binaries are not intended to be invoked directly.
Please use this plugin through the main 'docker-machine' binary.

Version: {{.Version}}{{if or .Author .Email}}

Author:{{if .Author}}
  {{.Author}}{{if .Email}} - <{{.Email}}>{{end}}{{else}}
  {{.Email}}{{end}}{{end}}
{{if .Flags}}
Options:
  {{range .Flags}}{{.}}
  {{end}}{{end}}
Commands:
  {{range .Commands}}{{.Name}}{{with .ShortName}}, {{.}}{{end}}{{ "\t" }}{{.Usage}}
  {{end}}
`

func main() {
	cli.AppHelpTemplate = appHelpTemplate
	app := cli.NewApp()
	app.Name = path.Base(os.Args[0])
	app.Usage = "This is a Docker Machine plugin binary. Please use it through the main 'docker-machine' binary."
	app.Author = "Parallels IP Holdings GmbH"
	app.Email = "https://github.com/Parallels/docker-machine-parallels/"
	app.Version = parallels.FullVersion()
	app.Action = func(c *cli.Context) {
		plugin.RegisterDriver(parallels.NewDriver("", ""))
	}

	app.Run(os.Args)
}
