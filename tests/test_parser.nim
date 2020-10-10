
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
    genLexControl(controlParenClose),
  ].toLinkedList
  let b1 = %* ["a", "b"]
  check (CirruNode(kind: cirruSeq, list: digestParsingParens(a1)) == toCirru(b1))
  var a2 = @[
    genLexToken("a"),
    genLexControl(controlParenOpen),
    genLexToken("b"),
    genLexControl(controlParenClose),
    genLexControl(controlParenClose),
  ].toLinkedList
  let b2 = %* ["a", ["b"]]
  check (CirruNode(kind: cirruSeq, list: digestParsingParens(a2)) == toCirru(b2))

test "Parse indentation":
  var a1 = @[
    genLexToken("a"),
    genLexControl(controlOutdent),
  ].toLinkedList
  let b1 = %* ["a"]
  check (CirruNode(kind: cirruSeq, list: digestParsingIndentation(a1)) == toCirru(b1))

  var a2 = @[
    genLexToken("a"),
    genLexControl(controlIndent),
    genLexToken("b"),
    genLexControl(controlOutdent),
    genLexControl(controlOutdent),
  ].toLinkedList
  let b2 = %* ["a", ["b"]]
  check (CirruNode(kind: cirruSeq, list: digestParsingIndentation(a2)) == toCirru(b2))

  var a3 = @[
    genLexToken("a"),
    genLexControl(controlIndent),
    genLexToken("b"),
    genLexControl(controlOutdent),
    genLexControl(controlIndent),
    genLexToken("c"),
    genLexControl(controlOutdent),
    genLexControl(controlOutdent),
  ].toLinkedList
  let b3 = %* ["a", ["b"], ["c"]]
  check (CirruNode(kind: cirruSeq, list: digestParsingIndentation(a3)) == toCirru(b3))


test "Parse simple program":
  let a1 = %* [["a"], ["b"]]
  check (parseCirru("a\nb") == toCirru(a1))

  let a2 = %* [["a"], ["b", ["c"]]]
  check (parseCirru("a\nb\n  c") == toCirru(a2))

  let a3 = %* [["a", ["b"]], ["c"]]
  check (parseCirru("a\n  b\nc") == toCirru(a3))

test "Parse empty program":
  check (parseCirru("") == CirruNode(kind: cirruSeq, list: initDoublyLinkedList[CirruNode]()))

test "Converts to JSON":
  check (toJson(parseCirru("a $ b $ c")) == %* [["a", ["b", ["c"]]]])