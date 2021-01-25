
import lists

import ./types

proc resolveDollar*(expr: CirruNode): CirruNode =
  case expr.kind
  of cirruToken:
    return expr
  of cirruList:

    # try to skip some children
    var hasDollar = false
    var hasList = false
    for child in expr.list:
      case child.kind
      of cirruToken:
        if child.token == "$":
          hasDollar = true
          break
      of cirruList:
        hasList = true
        break
    if not hasDollar and not hasList:
      return expr

    var buffer: DoublyLinkedList[CirruNode]
    var k = 0
    for child in expr.list:
      case child.kind
      of cirruToken:
        if child.token == "$":
          let following = resolveDollar(CirruNode(kind: cirruList, list: expr.list.copyFrom(k+1), line: child.line, column: child.column))
          case following.kind
          of cirruList:
            buffer.append CirruNode(kind: cirruList, list: following.list, line: child.line, column: child.column)
            break
          of cirruToken:
            raiseParseException("Should not return cirruToken", following.line, following.column)
        else:
          buffer.append child
      of cirruList:
        buffer.append resolveDollar(child)
      k += 1
    return CirruNode(kind: cirruList, list: buffer, line: expr.line, column: expr.column)

proc resolveComma*(expr: CirruNode): CirruNode =
  case expr.kind
  of cirruToken:
    return expr
  of cirruList:

    # try to skip some children
    var hasList = false
    for child in expr.list:
      case child.kind
      of cirruToken:
        discard
      of cirruList:
        hasList = true
        break
    if not hasList:
      return expr

    var buffer: DoublyLinkedList[CirruNode]
    for child in expr.list:
      case child.kind
      of cirruToken:
        buffer.append child
      of cirruList:
        if child.list.head.isNil.not and child.list.head.value.kind == cirruToken and child.list.head.value.token == ",":
          let resolvedChild = resolveComma(child)
          for x in resolvedChild.list.copyFrom(1):
            buffer.append resolveComma(x)
        else:
          buffer.append resolveComma(child)
    return CirruNode(kind: cirruList, list: buffer, line: expr.line, column: expr.column)
