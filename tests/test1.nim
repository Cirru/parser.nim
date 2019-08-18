
import unittest
import json

import cirruParser
import typetraits

# test "read line":
#   let dataCode = readFile("tests/data/line.json")
#   let sourceCode = readFile("tests/cirru/line.cirru")
  # echo parseJson(dataCode)
  # echo sourceCode
  # check (dataCode != "")

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

test "Lex nodes equality":
  check lexNodesEqual(@[LexNode(kind: lexToken, text: "a")], @[LexNode(kind: lexToken, text: "a")])
  check lexNodesEqual(@[LexNode(kind: lexToken, text: "a")], @[LexNode(kind: lexToken, text: "b")]) == false
  check lexNodesEqual(@[LexNode(kind: lexControl, operator: controlIndent)],
                      @[LexNode(kind: lexControl, operator: controlIndent)])
  check lexNodesEqual(@[LexNode(kind: lexToken, text: "a")],
                      @[LexNode(kind: lexControl, operator: controlIndent)]) == false

test "Lex code":
  echo lexCode("a b")
  echo lexCode("a \"b\"")
  echo lexCode("a \"b c\"")
  echo lexCode("a\n  b")
  echo lexCode("a (b c)")
  echo lexCode("a\n  \"b\"")

test "Lex indentation":
  echo lexCode(readFile("tests/cirru/comma.cirru"))
