
import unittest
import cirruParser/types
import cirruParser/lexer
import cirruParser/helpers

test "Lex nodes equality":
  check (@[genLexToken("a")] == @[genLexToken("a")])
  check (@[genLexToken("a")] != @[genLexToken("b")])
  check (@[genLexControl(controlIndent)] == @[genLexControl(controlIndent)])
  check (@[genLexToken("a")] != @[genLexControl(controlIndent)])

test "Lex code":
  check (lexCode("a b") == @[genLexToken("a"), genLexToken("b")])
  check (lexCode("a \"b\"") == @[genLexToken("a"), genLexToken("b")])
  check (lexCode("a \"b c\"") == @[genLexToken("a"), genLexToken("b c")])
  check (lexCode("a\n  b") == @[genLexToken("a"), genLexControl(controlIndent), genLexToken("b")])
  check (lexCode("a (b c)") == @[genLexToken("a"), genLexControl(controlParenOpen),
                                            genLexToken("b"), genLexToken("c"), genLexControl(controlParenClose)])
  check (lexCode("a\n  \"b\"") == @[genLexToken("a"), genLexControl(controlIndent), genLexToken("b")])
