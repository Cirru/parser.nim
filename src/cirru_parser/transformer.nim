
import deques

import ./types

proc resolveDollar*(expr: CirruNode): CirruNode =
  case expr.kind
  of cirruString:
    return expr
  of cirruSeq:

    # try to skip some children
    var hasDollar = false
    var hasList = false
    for child in expr.list:
      case child.kind
      of cirruString:
        if child.text == "$":
          hasDollar = true
          break
      of cirruSeq:
        hasList = true
        break
    if not hasDollar and not hasList:
      return expr

    var buffer: Deque[CirruNode]
    var k = 0
    for child in expr.list:
      case child.kind
      of cirruString:
        if child.text == "$":
          let following = resolveDollar(CirruNode(kind: cirruSeq, list: expr.list.copyFrom(k+1), line: child.line, column: child.column))
          case following.kind
          of cirruSeq:
            buffer.addLast CirruNode(kind: cirruSeq, list: following.list, line: child.line, column: child.column)
            break
          of cirruString:
            raiseParseException("Should not return cirruString", following.line, following.column)
        else:
          buffer.addLast child
      of cirruSeq:
        buffer.addLast resolveDollar(child)
      k += 1
    return CirruNode(kind: cirruSeq, list: buffer, line: expr.line, column: expr.column)

proc resolveComma*(expr: CirruNode): CirruNode =
  case expr.kind
  of cirruString:
    return expr
  of cirruSeq:

    # try to skip some children
    var hasList = false
    for child in expr.list:
      case child.kind
      of cirruString:
        discard
      of cirruSeq:
        hasList = true
        break
    if not hasList:
      return expr

    var buffer: Deque[CirruNode]
    for child in expr.list:
      case child.kind
      of cirruString:
        buffer.addLast child
      of cirruSeq:
        if child.list.len > 0 and child.list[0].kind == cirruString and child.list[0].text == ",":
          let resolvedChild = resolveComma(child)
          for x in resolvedChild.list.copyFrom(1):
            buffer.addLast resolveComma(x)
        else:
          buffer.addLast resolveComma(child)
    return CirruNode(kind: cirruSeq, list: buffer, line: expr.line, column: expr.column)
