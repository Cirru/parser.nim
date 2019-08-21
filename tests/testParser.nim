
import json
import unittest
import cirruParser
import cirruParser/types
import cirruParser/helpers
import cirruParser/lexer
import typetraits

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
