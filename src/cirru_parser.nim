import json
import lists

import cirru_parser/types
import cirru_parser/helpers
import cirru_parser/lexer
import cirru_parser/transformer

export CirruNode, CirruNodeKind, isSeq, isToken, `==`, `!=`, CirruParseError, formatParserFailure
export toCirru, toJson, items, `[]`, len

proc digestParsingParens*(tokens: var DoublyLinkedList[LexNode]): DoublyLinkedList[CirruNode] =
  var exprs: DoublyLinkedList[CirruNode]

  var lastToken: LexNode
  lastToken.line = 1 # line number starts from 1

  while tokens.head.isNil.not:
    let cursor = tokens.head.value

    # recorded for generating error messages
    lastToken = cursor

    case cursor.kind
    of lexToken:
      exprs.append CirruNode(kind: cirruString, text: cursor.text, line: cursor.line, column: cursor.column)
      tokens.remove tokens.head
      continue
    of lexControl:
      case cursor.operator
      of controlParenOpen:
        tokens.remove tokens.head
        let children = digestParsingParens(tokens)
        exprs.append CirruNode(kind: cirruSeq, list: children, line: cursor.line, column: cursor.column)
        continue
      of controlParenClose:
        tokens.remove tokens.head
        return exprs
      of controlIndent:
        raiseParseExceptionAtNode("Should not have indentation before paren close", cursor)
      of controlOutdent:
        raiseParseExceptionAtNode("Should not have outdentation before paren close", cursor)

  raiseParseExceptionAtNode("Unexpected EOF in paren", lastToken)

proc digestParsingIndentation*(tokens: var DoublyLinkedList[LexNode]): DoublyLinkedList[CirruNode] =
  var exprs: DoublyLinkedList[CirruNode]

  while tokens.head.isNil.not:
    let cursor = tokens.head.value
    case cursor.kind
    of lexToken:
      exprs.append CirruNode(kind: cirruString, text: cursor.text, line: cursor.line, column: cursor.column)
      tokens.remove tokens.head
      continue
    of lexControl:
      case cursor.operator
      of controlParenOpen:
        tokens.remove tokens.head
        if tokens.head.isNil:
          raiseParseExceptionAtNode("Wrong open paren here", cursor)
        let children = digestParsingParens(tokens)
        exprs.append CirruNode(kind: cirruSeq, list: children, line: cursor.line, column: cursor.column)
        continue
      of controlParenClose:
        raiseParseExceptionAtNode("Unexpected paren close inside a line", cursor)

      of controlIndent:
        tokens.remove tokens.head
        let children = digestParsingIndentation(tokens)
        exprs.append CirruNode(kind: cirruSeq, list: children, line: cursor.line, column: cursor.column)
        continue
      of controlOutdent:
        tokens.remove tokens.head
        return exprs

  return exprs

proc parseCirru*(code: string): CirruNode {.exportc.} =
  var tokens = lexCode(code)
  var lines: DoublyLinkedList[CirruNode]

  # echo "tokens: ", tokens

  if tokens.head.isNil:
    return CirruNode(kind: cirruSeq, list: initDoublyLinkedList[CirruNode](), line: 1, column: 0)

  let r0 = tokens.head.value
  let firstExpr = digestParsingIndentation(tokens)
  lines.append CirruNode(kind: cirruSeq, list: firstExpr, line: r0.line, column: r0.column)

  while tokens.head.isNil.not:
    let r0 = tokens.head.value
    if r0.kind == lexControl and r0.operator == controlIndent:
      tokens.remove tokens.head
      let children = digestParsingIndentation(tokens)
      lines.append CirruNode(kind: cirruSeq, list: children, line: r0.line, column: r0.column)
    else:
      echo tokens
      raiseParseExceptionAtNode("Unexpected tokens sequence!", r0)

  return resolveComma(resolveDollar(CirruNode(kind: cirruSeq, list: lines, line: 1, column: 0)))
