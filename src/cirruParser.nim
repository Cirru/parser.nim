
# thanks to https://forum.nim-lang.org/t/4233
type
  CirruNodeKind = enum
    cirruString,
    cirruSeq

  CirruNode = object
    case kind: CirruNodeKind
    of cirruString: text: string
    of cirruSeq: list: seq[CirruNode]

proc add*(x, y: int): int =
  ## Adds two files together.
  return x + y

proc createCirruSeq*(): seq[CirruNode] =
  var a: seq[CirruNode]
  let n1 = CirruNode(kind: cirruString, text: "n1")
  var b: seq[CirruNode]
  let n2 = CirruNode(kind: cirruSeq, list: b)
  a.add n1
  a.add n2
  return a
