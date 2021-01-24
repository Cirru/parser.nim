
import unittest
import lists
import json

import cirru_parser
import cirru_parser/types
import cirru_parser/helpers

test "nodes comparing":
  let a1 = CirruNode(kind: cirruToken, token: "a")
  let a2 = CirruNode(kind: cirruToken, token: "a")

  check (a1 == a2)

  let a3 = CirruNode(kind: cirruToken, token: "b")
  check (a1 != a3)

  let b0 = initDoublyLinkedList[CirruNode]()
  let b1 = CirruNode(kind: cirruList, list: b0)
  let b2 = CirruNode(kind: cirruList, list: b0)
  check (b1 == b2)

  check (a1 != b1)

test "Cirru from JSON":

  let jsonNodeOfC = JsonNode(kind: JString, str: "c")
  let nodeOfC = CirruNode(kind: cirruToken, token: "c")
  check (toCirru(jsonNodeOfC) == nodeOfC)

  let jsonEmpty = %* []
  let nodeOfEmpty = CirruNode(kind: cirruList, list: initDoublyLinkedList[CirruNode]())
  check (toCirru(jsonEmpty) == nodeOfEmpty)

  let jsonArray = %* ["a"]
  let nodeOfArray = CirruNode(kind: cirruList, list: @[CirruNode(kind: cirruToken, token: "a")].toLinkedList)
  check (toCirru(jsonArray) == nodeOfArray)

  let jsonNested = %* [[]]
  let nodeOfNested = CirruNode(kind: cirruList, list: @[CirruNode(kind: cirruList, list: initDoublyLinkedList[CirruNode]())].toLinkedList)
  check (toCirru(jsonNested) == nodeOfNested)
