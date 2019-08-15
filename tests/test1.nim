
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

test "creates Cirru seq":
  let a = createCirruSeq()
  echo a
  check a.len == 2

test "nodes comparing":
  let a1 = CirruNode(kind: cirruString, text: "a")
  let a2 = CirruNode(kind: cirruString, text: "a")

  check sameNodes(a1, a2)

  let a3 = CirruNode(kind: cirruString, text: "b")
  check sameNodes(a1, a3) == false

  let b0: seq[CirruNode] = @[]
  let b1 = CirruNode(kind: cirruSeq, list: b0)
  let b2 = CirruNode(kind: cirruSeq, list: b0)
  check sameNodes(b1, b2)

  check sameNodes(a1, b1) == false
