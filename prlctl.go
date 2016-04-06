package parallels

import (
	"bytes"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"regexp"
	"strings"

	"github.com/docker/machine/libmachine/log"
)

// TODO check these
var (
	reVMNameUUID       = regexp.MustCompile(`"(.+)" {([0-9a-f-]+)}`)
	reVMInfoLine       = regexp.MustCompile(`(?:"(.+)"|(.+))=(?:"(.*)"|(.*))`)
	reColonLine        = regexp.MustCompile(`(.+):\s+(.*)`)
	reMachineNotFound  = regexp.MustCompile(`Failed to get VM config: The virtual machine could not be found..*`)
	reMajorVersion     = regexp.MustCompile(`prlctl version (\d+)\.\d+\.\d+.*`)
	reParallelsEdition = regexp.MustCompile(`edition="(.+)"`)
)

var (
	ErrMachineExist        = errors.New("machine already exists")
	ErrMachineNotExist     = errors.New("machine does not exist")
	ErrPrlctlNotFound      = errors.New("prlctl not found")
	ErrPrlsrvctlNotFound   = errors.New("prlsrvctl not found")
	ErrPrldisktoolNotFound = errors.New("prl_disk_tool not found")
	prlctlCmd              = "prlctl"
	prlsrvctlCmd           = "prlsrvctl"
	prldisktoolCmd         = "prl_disk_tool"
)

func runCmd(cmdName string, args []string, notFound error) error {
	cmd := exec.Command(cmdName, args...)
	if os.Getenv("DEBUG") != "" {
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
	}
	log.Debugf("executing: %v %v", cmdName, strings.Join(args, " "))
	if err := cmd.Run(); err != nil {
		if ee, ok := err.(*exec.Error); ok && ee.Err == exec.ErrNotFound {
			return notFound
		}
		return fmt.Errorf("%v %v failed: %v", cmdName, strings.Join(args, " "), err)
	}
	return nil
}

func runCmdOut(cmdName string, args []string, notFound error) (string, error) {
	cmd := exec.Command(cmdName, args...)
	if os.Getenv("DEBUG") != "" {
		cmd.Stderr = os.Stderr
	}
	log.Debugf("executing: %v %v", cmdName, strings.Join(args, " "))

	b, err := cmd.Output()
	if err != nil {
		if ee, ok := err.(*exec.Error); ok && ee.Err == exec.ErrNotFound {
			err = notFound
		}
	}
	return string(b), err
}

func runCmdOutErr(cmdName string, args []string, notFound error) (string, string, error) {
	cmd := exec.Command(cmdName, args...)
	log.Debugf("executing: %v %v", cmdName, strings.Join(args, " "))
	var stdout bytes.Buffer
	var stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	err := cmd.Run()
	if err != nil {
		if ee, ok := err.(*exec.Error); ok && ee.Err == exec.ErrNotFound {
			err = notFound
		}
	}
	return stdout.String(), stderr.String(), err
}

func prlctl(args ...string) error {
	return runCmd(prlctlCmd, args, ErrPrlctlNotFound)
}

func prlctlOut(args ...string) (string, error) {
	return runCmdOut(prlctlCmd, args, ErrPrlctlNotFound)
}

func prlctlOutErr(args ...string) (string, string, error) {
	return runCmdOutErr(prlctlCmd, args, ErrPrlctlNotFound)
}

func prlsrvctl(args ...string) error {
	return runCmd(prlsrvctlCmd, args, ErrPrlsrvctlNotFound)
}

func prlsrvctlOut(args ...string) (string, error) {
	return runCmdOut(prlsrvctlCmd, args, ErrPrlsrvctlNotFound)
}

func prlsrvctlOutErr(args ...string) (string, string, error) {
	return runCmdOutErr(prlsrvctlCmd, args, ErrPrlsrvctlNotFound)
}

func prldisktool(args ...string) error {
	return runCmd(prldisktoolCmd, args, ErrPrldisktoolNotFound)
}
