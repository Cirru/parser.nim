
import unittest
import cirruParser/types
import cirruParser/lexer
import cirruParser/helpers

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
