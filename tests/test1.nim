
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

proc genLexToken(text: string): LexNode =
  return LexNode(kind: lexToken, text: text)

proc genLexControl(operator: ControlOperator): LexNode =
  return LexNode(kind: lexControl, operator: operator)

test "Lex nodes equality":
  check lexNodesEqual(@[genLexToken("a")], @[genLexToken("a")])
  check lexNodesEqual(@[genLexToken("a")], @[genLexToken("b")]) == false
  check lexNodesEqual(@[genLexControl(controlIndent)],
                      @[genLexControl(controlIndent)])
  check lexNodesEqual(@[genLexToken("a")],
                      @[genLexControl(controlIndent)]) == false

test "Lex code":
  check lexNodesEqual(lexCode("a b"), @[genLexToken("a"), genLexToken("b")])
  check lexNodesEqual(lexCode("a \"b\""), @[genLexToken("a"), genLexToken("b")])
  check lexNodesEqual(lexCode("a \"b c\""), @[genLexToken("a"), genLexToken("b c")])
  check lexNodesEqual(lexCode("a\n  b"), @[genLexToken("a"), genLexControl(controlIndent), genLexToken("b")])
  check lexNodesEqual(lexCode("a (b c)"), @[genLexToken("a"), genLexControl(controlParenOpen),
                                            genLexToken("b"), genLexToken("c"), genLexControl(controlParenClose)])
  check lexNodesEqual(lexCode("a\n  \"b\""), @[genLexToken("a"), genLexControl(controlIndent), genLexToken("b")])

# test "Lex indentation":
#   echo lexCode(readFile("tests/cirru/comma.cirru"))

test "Parse parens":
  var a1 = @[
    genLexToken("a"),
    genLexToken("b"),
    genLexControl(controlParenClose),
  ]
  let b1 = %* ["a", "b"]
  check cirruNodesEqual(CirruNode(kind: cirruSeq, list: digestParsingParens(a1)),
                        createCirruNodeFromJson(b1))
  var a2 = @[
    genLexToken("a"),
    genLexControl(controlParenOpen),
    genLexToken("b"),
    genLexControl(controlParenClose),
    genLexControl(controlParenClose),
  ]
  let b2 = %* ["a", ["b"]]
  check cirruNodesEqual(CirruNode(kind: cirruSeq, list: digestParsingParens(a2)),
                        createCirruNodeFromJson(b2))

test "Parse indentation":
  var a1 = @[
    genLexToken("a"),
    genLexControl(controlOutdent),
  ]
  let b1 = %* ["a"]
  check cirruNodesEqual(CirruNode(kind: cirruSeq, list: digestParsingIndentation(a1)),
                        createCirruNodeFromJson(b1))

  var a2 = @[
    genLexToken("a"),
    genLexControl(controlIndent),
    genLexToken("b"),
    genLexControl(controlOutdent),
    genLexControl(controlOutdent),
  ]
  let b2 = %* ["a", ["b"]]
  check cirruNodesEqual(CirruNode(kind: cirruSeq, list: digestParsingIndentation(a2)),
                        createCirruNodeFromJson(b2))

  var a3 = @[
    genLexToken("a"),
    genLexControl(controlIndent),
    genLexToken("b"),
    genLexControl(controlOutdent),
    genLexControl(controlIndent),
    genLexToken("c"),
    genLexControl(controlOutdent),
    genLexControl(controlOutdent),
  ]
  let b3 = %* ["a", ["b"], ["c"]]
  check cirruNodesEqual(CirruNode(kind: cirruSeq, list: digestParsingIndentation(a3)),
                        createCirruNodeFromJson(b3))


test "Parse code":
  echo parseCode("a")
