
import lists
import unittest

import cirru_parser/types
import cirru_parser/lexer
import cirru_parser/helpers

test "Lex nodes equality":
  check (@[genLexToken("a")] == @[genLexToken("a")])
  check (@[genLexToken("a")] != @[genLexToken("b")])
  check (@[genLexControl(controlIndent)] == @[genLexControl(controlIndent)])
  check (@[genLexToken("a")] != @[genLexControl(controlIndent)])

test "Lex code":
  check (lexCode("a b").toSeq == @[genLexToken("a"), genLexToken("b")])
  check (lexCode("a \"b\"").toSeq == @[genLexToken("a"), genLexToken("b")])
  check (lexCode("a \"b c\"").toSeq == @[genLexToken("a"), genLexToken("b c")])
  check (lexCode("a\n  b").toSeq == @[genLexToken("a"), genLexControl(controlIndent), genLexToken("b")])
  check (lexCode("a (b c)").toSeq == @[genLexToken("a"), genLexControl(controlParenOpen),
                                            genLexToken("b"), genLexToken("c"), genLexControl(controlParenClose)])
  check (lexCode("a\n  \"b\"").toSeq == @[genLexToken("a"), genLexControl(controlIndent), genLexToken("b")])
