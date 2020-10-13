import json
import deques

import cirru_parser/types
import cirru_parser/helpers
import cirru_parser/lexer
import cirru_parser/transformer

export CirruNode, CirruNodeKind, isSeq, isToken, `==`, `!=`, CirruParseError, formatParserFailure
export toCirru, toJson, items, `[]`, len, first, isEmpty, rest, restInLinkedList

proc digestParsingParens*(tokens: var Deque[LexNode]): Deque[CirruNode] =
  var exprs: Deque[CirruNode]

  var lastToken: LexNode
  lastToken.line = 1 # line number starts from 1

  while tokens.len > 0:
    let cursor = tokens[0]

    # recorded for generating error messages
    lastToken = cursor

    case cursor.kind
    of lexToken:
      exprs.addLast CirruNode(kind: cirruString, text: cursor.text, line: cursor.line, column: cursor.column)
      tokens.popFirst()
      continue
    of lexControl:
      case cursor.operator
      of controlParenOpen:
        tokens.popFirst()
        let children = digestParsingParens(tokens)
        exprs.addLast CirruNode(kind: cirruSeq, list: children, line: cursor.line, column: cursor.column)
        continue
      of controlParenClose:
        tokens.popFirst()
        return exprs
      of controlIndent:
        raiseParseExceptionAtNode("Should not have indentation before paren close", cursor)
      of controlOutdent:
        raiseParseExceptionAtNode("Should not have outdentation before paren close", cursor)

  raiseParseExceptionAtNode("Unexpected EOF in paren", lastToken)

proc digestParsingIndentation*(tokens: var Deque[LexNode]): Deque[CirruNode] =
  var exprs: Deque[CirruNode]

  while tokens.len > 0:
    let cursor = tokens[0]
    case cursor.kind
    of lexToken:
      exprs.addLast CirruNode(kind: cirruString, text: cursor.text, line: cursor.line, column: cursor.column)
      tokens.popFirst()
      continue
    of lexControl:
      case cursor.operator
      of controlParenOpen:
        tokens.popFirst()
        if tokens.len == 0:
          raiseParseExceptionAtNode("Wrong open paren here", cursor)
        let children = digestParsingParens(tokens)
        exprs.addLast CirruNode(kind: cirruSeq, list: children, line: cursor.line, column: cursor.column)
        continue
      of controlParenClose:
        raiseParseExceptionAtNode("Unexpected paren close inside a line", cursor)

      of controlIndent:
        tokens.popFirst()
        let children = digestParsingIndentation(tokens)
        exprs.addLast CirruNode(kind: cirruSeq, list: children, line: cursor.line, column: cursor.column)
        continue
      of controlOutdent:
        tokens.popFirst()
        return exprs

  return exprs

proc parseCirru*(code: string): CirruNode {.exportc.} =
  var tokens = lexCode(code)
  var lines: Deque[CirruNode]

  # echo "tokens: ", tokens

  if tokens.len == 0:
    return CirruNode(kind: cirruSeq, list: initDeque[CirruNode](), line: 1, column: 0)

  let r0 = tokens[0]
  let firstExpr = digestParsingIndentation(tokens)
  lines.addLast CirruNode(kind: cirruSeq, list: firstExpr, line: r0.line, column: r0.column)

  while tokens.len > 0:
    let r0 = tokens[0]
    if r0.kind == lexControl and r0.operator == controlIndent:
      tokens.popFirst()
      let children = digestParsingIndentation(tokens)
      lines.addLast CirruNode(kind: cirruSeq, list: children, line: r0.line, column: r0.column)
    else:
      echo tokens
      raiseParseExceptionAtNode("Unexpected tokens sequence!", r0)

  return resolveComma(resolveDollar(CirruNode(kind: cirruSeq, list: lines, line: 1, column: 0)))
