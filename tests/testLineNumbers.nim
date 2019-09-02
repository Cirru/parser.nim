
import unittest
import cirruParser/types
import cirruParser/lexer
import cirruParser/helpers

test "Line number results":
  echo lexCode("a\n  b")
  try:
    echo lexCode("a \"")
  except CirruParseError as e:
    echo e.msg
    echo e.line, ":", e.column
