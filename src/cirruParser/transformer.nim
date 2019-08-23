
import cirruParser/types

proc resolveDollar*(expr: CirruNode): CirruNode =
  case expr.kind
  of cirruString:
    return expr
  of cirruSeq:
    var buffer: seq[CirruNode]
    for k, child in expr.list:
      case child.kind
      of cirruString:
        if child.text == "$":
          let following = resolveDollar(CirruNode(kind: cirruSeq, list: expr.list[(k+1)..^1]))
          case following.kind
          of cirruSeq:
            buffer.add CirruNode(kind: cirruSeq, list: following.list)
            break
          of cirruString:
            raise newException(CirruParseError, "Should not return cirruString")
        else:
          buffer.add child
      of cirruSeq:
        buffer.add resolveDollar(child)
    return CirruNode(kind: cirruSeq, list: buffer)

proc resolveComma*(expr: CirruNode): CirruNode =
  case expr.kind
  of cirruString:
    return expr
  of cirruSeq:
    var buffer: seq[CirruNode]
    for i, child in expr.list:
      case child.kind
      of cirruString:
        buffer.add child
      of cirruSeq:
        if child.list.len > 0 and child.list[0].kind == cirruString and child.list[0].text == ",":
          let resolvedChild = resolveComma(child)
          for j, x in resolvedChild.list[1..^1]:
            buffer.add resolveComma(x)
        else:
          buffer.add resolveComma(child)
    return CirruNode(kind: cirruSeq, list: buffer)
