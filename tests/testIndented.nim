
import unittest
import json
import cirruParser
import cirruParser/types
import cirruParser/helpers
import cirruParser/lexer

test "Read parentheses with indent":
  let dataCode = readFile("tests/data/paren-indent.json")
  let sourceCode = readFile("tests/cirru/paren-indent.cirru")
  check (toCirru(parseJson(dataCode)) == parseCirru(sourceCode))
