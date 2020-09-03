import json
import cirruParser/types
import cirruParser/helpers
import cirruParser/lexer
import cirruParser/transformer

export CirruNode, CirruNodeKind, isSeq, isToken, `==`, `!=`, CirruParseError, formatParserFailure
export toCirru, toJson

proc digestParsingParens*(tokens: var seq[LexNode]): seq[CirruNode] =
  var exprs: seq[CirruNode]

  var lastToken: LexNode
  lastToken.line = 1 # line number starts from 1

  while tokens.len > 0:
    let cursor = tokens[0]

    # recorded for generating error messages
    lastToken = cursor

    case cursor.kind
    of lexToken:
      exprs.add CirruNode(kind: cirruString, text: cursor.text, line: cursor.line, column: cursor.column)
      tokens.delete 0
      continue
    of lexControl:
      case cursor.operator
      of controlParenOpen:
        tokens.delete 0
        let children = digestParsingParens(tokens)
        exprs.add CirruNode(kind: cirruSeq, list: children, line: cursor.line, column: cursor.column)
        continue
      of controlParenClose:
        tokens.delete 0
        return exprs
      of controlIndent:
        raiseParseExceptionAtNode("Should not have indentation before paren close", cursor)
      of controlOutdent:
        raiseParseExceptionAtNode("Should not have outdentation before paren close", cursor)

  raiseParseExceptionAtNode("Unexpected EOF in paren", lastToken)

proc digestParsingIndentation*(tokens: var seq[LexNode]): seq[CirruNode] =
  var exprs: seq[CirruNode]

  while tokens.len > 0:
    let cursor = tokens[0]
    case cursor.kind
    of lexToken:
      exprs.add CirruNode(kind: cirruString, text: cursor.text, line: cursor.line, column: cursor.column)
      tokens.delete 0
      continue
    of lexControl:
      case cursor.operator
      of controlParenOpen:
        tokens.delete 0
        if tokens.len == 0:
          raiseParseExceptionAtNode("Wrong open paren here", cursor)
        let children = digestParsingParens(tokens)
        exprs.add CirruNode(kind: cirruSeq, list: children, line: cursor.line, column: cursor.column)
        continue
      of controlParenClose:
        raiseParseExceptionAtNode("Unexpected paren close inside a line", cursor)

      of controlIndent:
        tokens.delete 0
        let children = digestParsingIndentation(tokens)
        exprs.add CirruNode(kind: cirruSeq, list: children, line: cursor.line, column: cursor.column)
        continue
      of controlOutdent:
        tokens.delete 0
        return exprs

  return exprs

proc parseCirru*(code: string): CirruNode {.exportc.} =
  var tokens = lexCode(code)
  var lines: seq[CirruNode]

  # echo "tokens: ", tokens

  if tokens.len == 0:
    return CirruNode(kind: cirruSeq, list: @[], line: 1, column: 0)

  let r0 = tokens[0]
  let firstExpr = digestParsingIndentation(tokens)
  lines.add CirruNode(kind: cirruSeq, list: firstExpr, line: r0.line, column: r0.column)

  while tokens.len > 0:
    if tokens[0].kind == lexControl and tokens[0].operator == controlIndent:
      let r0 = tokens[0]
      tokens.delete 0
      let children = digestParsingIndentation(tokens)
      lines.add CirruNode(kind: cirruSeq, list: children, line: r0.line, column: r0.column)
    else:
      echo tokens
      raiseParseExceptionAtNode("Unexpected tokens sequence!", tokens[0])

  return resolveComma(resolveDollar(CirruNode(kind: cirruSeq, list: lines, line: 1, column: 0)))
