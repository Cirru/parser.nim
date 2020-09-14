# Package

version       = "0.1.3"
author        = "jiyinyiyong"
description   = "Parser for Cirru syntax"
license       = "MIT"
srcDir        = "src"

# Dependencies

requires "nim >= 0.20.0"

# Tasks

task t, "Runs the test suite":
  exec "nim c --hints:off -r tests/iterator"
