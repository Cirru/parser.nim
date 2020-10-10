# Package

version       = "0.2.1"
author        = "jiyinyiyong"
description   = "Parser for Cirru syntax"
license       = "MIT"
srcDir        = "src"

# Dependencies

requires "nim >= 0.20.0"

# Tasks

task t, "Runs the test suite":
  # exec "nim c --hints:off -r tests/test_iterator"
  # exec "nim c --hints:off -r tests/test_parser"
  # exec "nim c --hints:off -r tests/test_lexer"
  exec "nim c --hints:off -r tests/test_types"

task perf, "try large file":
  exec "nim compile --verbosity:0 --profiler:on --stackTrace:on --hints:off -r tests/parse_cost"
