
import unittest
import json

import cirruParser

test "can add":
  check add(10,0) == 10

test "read line":
  let dataCode = readFile("tests/data/line.json")
  let sourceCode = readFile("tests/cirru/line.cirru")
  echo parseJson(dataCode)
  echo sourceCode
  check (dataCode == "")
