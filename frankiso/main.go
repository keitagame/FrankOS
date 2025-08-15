package main

import (
  "log"
  "os/exec"
)

func main() {
  cmd := exec.Command("bash", "build.sh")
  cmd.Stdout = cmd.Stderr
  if err := cmd.Run(); err != nil {
    log.Fatal(err)
  }
}
