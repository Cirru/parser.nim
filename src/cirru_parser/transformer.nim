
import lists

import ./types
import ./helpers

proc resolveDollar*(expr: CirruNode): CirruNode =
  case expr.kind
  of cirruString:
    return expr
  of cirruSeq:
    var buffer: DoublyLinkedList[CirruNode]
    var k = 0
    for child in expr.list:
      case child.kind
      of cirruString:
        if child.text == "$":
          let following = resolveDollar(CirruNode(kind: cirruSeq, list: expr.list.copyFrom(k+1), line: child.line, column: child.column))
          case following.kind
          of cirruSeq:
            buffer.append CirruNode(kind: cirruSeq, list: following.list, line: child.line, column: child.column)
            break
          of cirruString:
            raiseParseException("Should not return cirruString", following.line, following.column)
        else:
          buffer.append child
      of cirruSeq:
        buffer.append resolveDollar(child)
      k += 1
    return CirruNode(kind: cirruSeq, list: buffer, line: expr.line, column: expr.column)

proc resolveComma*(expr: CirruNode): CirruNode =
  case expr.kind
  of cirruString:
    return expr
  of cirruSeq:
    var buffer: DoublyLinkedList[CirruNode]
    for child in expr.list:
      case child.kind
      of cirruString:
        buffer.append child
      of cirruSeq:
        if child.list.head.isNil.not and child.list.head.value.kind == cirruString and child.list.head.value.text == ",":
          let resolvedChild = resolveComma(child)
          for x in resolvedChild.list.copyFrom(1):
            buffer.append resolveComma(x)
        else:
          buffer.append resolveComma(child)
    return CirruNode(kind: cirruSeq, list: buffer, line: expr.line, column: expr.column)
