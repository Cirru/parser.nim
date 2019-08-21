
import unittest
import json

import cirruParser
import cirruParser/types
import cirruParser/helpers
import cirruParser/lexer

test "nodes comparing":
  let a1 = CirruNode(kind: cirruString, text: "a")
  let a2 = CirruNode(kind: cirruString, text: "a")

  check cirruNodesEqual(a1, a2)

  let a3 = CirruNode(kind: cirruString, text: "b")
  check cirruNodesEqual(a1, a3) == false

  let b0: seq[CirruNode] = @[]
  let b1 = CirruNode(kind: cirruSeq, list: b0)
  let b2 = CirruNode(kind: cirruSeq, list: b0)
  check cirruNodesEqual(b1, b2)

  check cirruNodesEqual(a1, b1) == false

test "Cirru from JSON":

  let jsonNodeOfC = JsonNode(kind: JString, str: "c")
  let nodeOfC = CirruNode(kind: cirruString, text: "c")
  check cirruNodesEqual(createCirruNodeFromJson(jsonNodeOfC), nodeOfC)

  let jsonEmpty = %* []
  let nodeOfEmpty = CirruNode(kind: cirruSeq, list: @[])
  check cirruNodesEqual(createCirruNodeFromJson(jsonEmpty), nodeOfEmpty)

  let jsonArray = %* ["a"]
  let nodeOfArray = CirruNode(kind: cirruSeq, list: @[CirruNode(kind: cirruString, text: "a")])
  check cirruNodesEqual(createCirruNodeFromJson(jsonArray), nodeOfArray)

  let jsonNested = %* [[]]
  let nodeOfNested = CirruNode(kind: cirruSeq, list: @[CirruNode(kind: cirruSeq, list: @[])])
  check cirruNodesEqual(createCirruNodeFromJson(jsonNested), nodeOfNested)
