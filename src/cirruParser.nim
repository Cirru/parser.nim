
# thanks to https://forum.nim-lang.org/t/4233
type
  CirruNodeKind* = enum
    cirruString,
    cirruSeq

  CirruNode* = object
    case kind*: CirruNodeKind
    of cirruString: text*: string
    of cirruSeq: list*: seq[CirruNode]

proc createCirruSeq*(): seq[CirruNode] =
  var a: seq[CirruNode]
  let n1 = CirruNode(kind: cirruString, text: "n1")
  var b: seq[CirruNode]
  let n2 = CirruNode(kind: cirruSeq, list: b)
  a.add n1
  a.add n2
  return a

proc createCirruString*(x: string): CirruNode =
  return CirruNode(kind: cirruString, text: x)

proc sameNodes*(x, y: CirruNode): bool =
  ## compare if two nodes equal
  if (x.kind == y.kind):
    if (x.kind == cirruString):
      return x.text == y.text
    else:
      if (x.list.len == y.list.len):
        for k, v in x.list:
          if (sameNodes(v, y.list[k])):
            continue
          else:
            return false
        return true
      else:
        return false
  else:
    return false
