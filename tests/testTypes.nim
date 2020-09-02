
import unittest
import json

import cirruParser
import cirruParser/types
import cirruParser/helpers

test "nodes comparing":
  let a1 = CirruNode(kind: cirruString, text: "a")
  let a2 = CirruNode(kind: cirruString, text: "a")

  check (a1 == a2)

  let a3 = CirruNode(kind: cirruString, text: "b")
  check (a1 != a3)

  let b0: seq[CirruNode] = @[]
  let b1 = CirruNode(kind: cirruSeq, list: b0)
  let b2 = CirruNode(kind: cirruSeq, list: b0)
  check (b1 == b2)

  check (a1 != b1)

test "Cirru from JSON":

  let jsonNodeOfC = JsonNode(kind: JString, str: "c")
  let nodeOfC = CirruNode(kind: cirruString, text: "c")
  check (jsonToCirru(jsonNodeOfC) == nodeOfC)

  let jsonEmpty = %* []
  let nodeOfEmpty = CirruNode(kind: cirruSeq, list: @[])
  check (jsonToCirru(jsonEmpty) == nodeOfEmpty)

  let jsonArray = %* ["a"]
  let nodeOfArray = CirruNode(kind: cirruSeq, list: @[CirruNode(kind: cirruString, text: "a")])
  check (jsonToCirru(jsonArray) == nodeOfArray)

  let jsonNested = %* [[]]
  let nodeOfNested = CirruNode(kind: cirruSeq, list: @[CirruNode(kind: cirruSeq, list: @[])])
  check (jsonToCirru(jsonNested) == nodeOfNested)
