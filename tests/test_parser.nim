
import json
import lists
import unittest
import cirru_parser
import cirru_parser/types
import cirru_parser/helpers

test "Parse parens":
  var a1 = @[
    genLexToken("a"),
    genLexToken("b"),
    genLexOperator(controlParenClose),
  ].toLinkedList
  let b1 = %* ["a", "b"]
  check (CirruNode(kind: cirruList, list: digestParsingParens(a1)) == toCirru(b1))
  var a2 = @[
    genLexToken("a"),
    genLexOperator(controlParenOpen),
    genLexToken("b"),
    genLexOperator(controlParenClose),
    genLexOperator(controlParenClose),
  ].toLinkedList
  let b2 = %* ["a", ["b"]]
  check (CirruNode(kind: cirruList, list: digestParsingParens(a2)) == toCirru(b2))

test "Parse indentation":
  var a1 = @[
    genLexToken("a"),
    genLexOperator(controlOutdent),
  ].toLinkedList
  let b1 = %* ["a"]
  check (CirruNode(kind: cirruList, list: digestParsingIndentation(a1)) == toCirru(b1))

  var a2 = @[
    genLexToken("a"),
    genLexOperator(controlIndent),
    genLexToken("b"),
    genLexOperator(controlOutdent),
    genLexOperator(controlOutdent),
  ].toLinkedList
  let b2 = %* ["a", ["b"]]
  check (CirruNode(kind: cirruList, list: digestParsingIndentation(a2)) == toCirru(b2))

  var a3 = @[
    genLexToken("a"),
    genLexOperator(controlIndent),
    genLexToken("b"),
    genLexOperator(controlOutdent),
    genLexOperator(controlIndent),
    genLexToken("c"),
    genLexOperator(controlOutdent),
    genLexOperator(controlOutdent),
  ].toLinkedList
  let b3 = %* ["a", ["b"], ["c"]]
  check (CirruNode(kind: cirruList, list: digestParsingIndentation(a3)) == toCirru(b3))


test "Parse simple program":
  let a1 = %* [["a"], ["b"]]
  check (parseCirru("a\nb") == toCirru(a1))

  let a2 = %* [["a"], ["b", ["c"]]]
  check (parseCirru("a\nb\n  c") == toCirru(a2))

  let a3 = %* [["a", ["b"]], ["c"]]
  check (parseCirru("a\n  b\nc") == toCirru(a3))

test "Parse empty program":
  check (parseCirru("") == CirruNode(kind: cirruList, list: initDoublyLinkedList[CirruNode]()))

test "Converts to JSON":
  check (toJson(parseCirru("a $ b $ c")) == %* [["a", ["b", ["c"]]]])