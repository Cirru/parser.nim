
import unittest
import cirruParser/types
import cirruParser/lexer
import cirruParser/helpers
import cirruParser

test "Line number results":
  echo lexCode("a\n  b")

  echo()

  let code = "a \""
  try:
    echo lexCode(code)
  except CirruParseError as e:
    echo formatParserFailure(code, e.msg, "tmp", e.line, e.column)

  echo()

  let code2 = "a\n b"
  try:
    echo lexCode(code2)
  except CirruParseError as e:
    echo formatParserFailure(code2, e.msg, "tmp", e.line, e.column)

  echo()

  let code3 = "a b c d e ) f"
  try:
    echo parseCirru(code3)
  except CirruParseError as e:
    echo formatParserFailure(code3, e.msg, "tmp", e.line, e.column)

  echo()
