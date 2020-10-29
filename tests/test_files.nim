
import unittest
import json
import cirru_parser
import cirru_parser/types
import cirru_parser/helpers

test "Read line":
  let dataCode = readFile("tests/data/line.json")
  let sourceCode = readFile("tests/cirru/line.cirru")
  check (toCirru(parseJson(dataCode)) == parseCirru(sourceCode))

test "Read spaces":
  let dataCode = readFile("tests/data/spaces.json")
  let sourceCode = readFile("tests/cirru/spaces.cirru")
  check (toCirru(parseJson(dataCode)) == parseCirru(sourceCode))

test "Read quote":
  let dataCode = readFile("tests/data/quote.json")
  let sourceCode = readFile("tests/cirru/quote.cirru")
  check (toCirru(parseJson(dataCode)) == parseCirru(sourceCode))

test "Read parentheses":
  let dataCode = readFile("tests/data/parentheses.json")
  let sourceCode = readFile("tests/cirru/parentheses.cirru")
  check (toCirru(parseJson(dataCode)) == parseCirru(sourceCode))

test "Read folding":
  let dataCode = readFile("tests/data/folding.json")
  let sourceCode = readFile("tests/cirru/folding.cirru")
  check (toCirru(parseJson(dataCode)) == parseCirru(sourceCode))

test "Read indent":
  let dataCode = readFile("tests/data/indent.json")
  let sourceCode = readFile("tests/cirru/indent.cirru")
  check (toCirru(parseJson(dataCode)) == parseCirru(sourceCode))

test "Read comma":
  let dataCode = readFile("tests/data/comma.json")
  let sourceCode = readFile("tests/cirru/comma.cirru")
  check (toCirru(parseJson(dataCode)) == parseCirru(sourceCode))

test "Read unfolding":
  let dataCode = readFile("tests/data/unfolding.json")
  let sourceCode = readFile("tests/cirru/unfolding.cirru")
  check (toCirru(parseJson(dataCode)) == parseCirru(sourceCode))

test "Read demo":
  let dataCode = readFile("tests/data/demo.json")
  let sourceCode = readFile("tests/cirru/demo.cirru")
  check (toCirru(parseJson(dataCode)) == parseCirru(sourceCode))

test "Read html":
  let dataCode = readFile("tests/data/html.json")
  let sourceCode = readFile("tests/cirru/html.cirru")
  check (toCirru(parseJson(dataCode)) == parseCirru(sourceCode))
