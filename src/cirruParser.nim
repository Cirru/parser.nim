import strutils
import json
import cirruParser/types
import cirruParser/lexer

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
        raise newException(CirruParseError, "Should not have indentation before paren close")
      of controlOutdent:
        raise newException(CirruParseError, "Should not have outdentation before paren close")

  raise newException(CirruParseError, "Unexpected EOF parin paren")

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
        raise newException(CirruParseError, "Unexpected paren close after indentation")
      of controlIndent:
        tokens.delete 0
        let children = digestParsingIndentation(tokens)
        exprs.add CirruNode(kind: cirruSeq, list: children)
        continue
      of controlOutdent:
        tokens.delete 0
        return exprs

  return exprs

proc parseCode*(code: string): CirruNode =
  let tokens = lexCode(code)
  var tree = CirruNode(kind: cirruSeq, list: @[])
  var exprBuffer = CirruNode(kind: cirruSeq, list: @[])

  while tokens.len > 0:
    break

  return tree
