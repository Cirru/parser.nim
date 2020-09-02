
import unittest
import json
import cirruParser
import cirruParser/types
import cirruParser/helpers
import cirruParser/lexer

test "Read parentheses with indent":
  let dataCode = readFile("tests/data/paren-indent.json")
  let sourceCode = readFile("tests/cirru/paren-indent.cirru")
  check (jsonToCirru(parseJson(dataCode)) == parseCirru(sourceCode))

test "Read large indent with commas":
  let dataCode = readFile("tests/data/paren-indent.json")
  let sourceCode = readFile("tests/cirru/paren-indent2.cirru")
  check (jsonToCirru(parseJson(dataCode)) == parseCirru(sourceCode))

test "Read indent twice":
  let dataCode = readFile("tests/data/indent-twice.json")
  let sourceCode = readFile("tests/cirru/indent-twice.cirru")
  check (jsonToCirru(parseJson(dataCode)) == parseCirru(sourceCode))

test "Read let indent":
  let dataCode = readFile("tests/data/let.json")
  let sourceCode = readFile("tests/cirru/let.cirru")
  check (jsonToCirru(parseJson(dataCode)) == parseCirru(sourceCode))
