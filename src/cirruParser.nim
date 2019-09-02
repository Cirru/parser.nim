import strutils
import json
import cirruParser/types
import cirruParser/lexer
import cirruParser/transformer

export CirruNode, CirruNodeKind, isSeq, isToken, `==`, `!=`

proc digestParsingParens*(tokens: var seq[LexNode]): seq[CirruNode] =
  var exprs: seq[CirruNode]

  while tokens.len > 0:
    let cursor = tokens[0]
    case cursor.kind
    of lexToken:
      exprs.add CirruNode(kind: cirruString, text: cursor.text)
      tokens.delete 0
      continue
    of lexControl:
      case cursor.operator
      of controlParenOpen:
        tokens.delete 0
        let children = digestParsingParens(tokens)
        exprs.add CirruNode(kind: cirruSeq, list: children)
        continue
      of controlParenClose:
        tokens.delete 0
        return exprs
      of controlIndent:
        raiseParseException("Should not have indentation before paren close", 0, 0)
      of controlOutdent:
        raiseParseException("Should not have outdentation before paren close", 0, 0)

  raiseParseException("Unexpected EOF parin paren", 0, 0)

proc digestParsingIndentation*(tokens: var seq[LexNode]): seq[CirruNode] =
  var exprs: seq[CirruNode]

  while tokens.len > 0:
    let cursor = tokens[0]
    case cursor.kind
    of lexToken:
      exprs.add CirruNode(kind: cirruString, text: cursor.text)
      tokens.delete 0
      continue
    of lexControl:
      case cursor.operator
      of controlParenOpen:
        tokens.delete 0
        let children = digestParsingParens(tokens)
        exprs.add CirruNode(kind: cirruSeq, list: children)
        continue
      of controlParenClose:
        raiseParseException("Unexpected paren close after indentation", 0, 0)

      of controlIndent:
        tokens.delete 0
        let children = digestParsingIndentation(tokens)
        exprs.add CirruNode(kind: cirruSeq, list: children)
        continue
      of controlOutdent:
        tokens.delete 0
        return exprs

  return exprs

proc parseCirru*(code: string): CirruNode =
  var tokens = lexCode(code)
  var lines: seq[CirruNode]

  # echo "tokens: ", tokens

  if tokens.len == 0:
    raiseParseException("Empty nodes", 0, 0)

  let firstExpr = digestParsingIndentation(tokens)
  lines.add CirruNode(kind: cirruSeq, list: firstExpr)

  while tokens.len > 0:
    if tokens[0].kind == lexControl and tokens[0].operator == controlIndent:
      tokens.delete 0
      let children = digestParsingIndentation(tokens)
      lines.add CirruNode(kind: cirruSeq, list: children)
    else:
      echo tokens
      raiseParseException("Unexpected tokens sequence!", 0, 0)

  return resolveComma(resolveDollar(CirruNode(kind: cirruSeq, list: lines)))
