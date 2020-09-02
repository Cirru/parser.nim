
import json
import unittest
import cirruParser
import cirruParser/types
import cirruParser/helpers

test "Parse parens":
  var a1 = @[
    genLexToken("a"),
    genLexToken("b"),
    genLexControl(controlParenClose),
  ]
  let b1 = %* ["a", "b"]
  check (CirruNode(kind: cirruSeq, list: digestParsingParens(a1)) == jsonToCirru(b1))
  var a2 = @[
    genLexToken("a"),
    genLexControl(controlParenOpen),
    genLexToken("b"),
    genLexControl(controlParenClose),
    genLexControl(controlParenClose),
  ]
  let b2 = %* ["a", ["b"]]
  check (CirruNode(kind: cirruSeq, list: digestParsingParens(a2)) == jsonToCirru(b2))

test "Parse indentation":
  var a1 = @[
    genLexToken("a"),
    genLexControl(controlOutdent),
  ]
  let b1 = %* ["a"]
  check (CirruNode(kind: cirruSeq, list: digestParsingIndentation(a1)) == jsonToCirru(b1))

  var a2 = @[
    genLexToken("a"),
    genLexControl(controlIndent),
    genLexToken("b"),
    genLexControl(controlOutdent),
    genLexControl(controlOutdent),
  ]
  let b2 = %* ["a", ["b"]]
  check (CirruNode(kind: cirruSeq, list: digestParsingIndentation(a2)) == jsonToCirru(b2))

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
  check (CirruNode(kind: cirruSeq, list: digestParsingIndentation(a3)) == jsonToCirru(b3))


test "Parse simple program":
  let a1 = %* [["a"], ["b"]]
  check (parseCirru("a\nb") == jsonToCirru(a1))

  let a2 = %* [["a"], ["b", ["c"]]]
  check (parseCirru("a\nb\n  c") == jsonToCirru(a2))

  let a3 = %* [["a", ["b"]], ["c"]]
  check (parseCirru("a\n  b\nc") == jsonToCirru(a3))

test "Parse empty program":
  check (parseCirru("") == CirruNode(kind: cirruSeq, list: @[]))

test "Converts to JSON":
  check (cirruToJson(parseCirru("a $ b $ c")) == %* [["a", ["b", ["c"]]]])