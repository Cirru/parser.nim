
import lists
import options

type
  CirruNodeKind* = enum
    cirruToken,
    cirruList

  CirruNode* = object
    line*: int
    column*: int
    case kind*: CirruNodeKind
    of cirruToken:
      token*: string
    of cirruList:
      list*: DoublyLinkedList[CirruNode]

  LexNodeKind* = enum
    lexToken,
    lexOperator

  ControlOperator* = enum
    controlParenOpen,
    controlParenClose,
    controlIndent,
    controlOutdent

  LexNode* = object
    line*: int
    column*: int
    case kind*: LexNodeKind
    of lexToken: token*: string
    of lexOperator: operator*: ControlOperator

  LexState* = enum
    lexStateToken,
    lexStateSpace,
    lexStateString,
    lexStateEscape,
    lexStateIndent

  CirruParseError* = ref object of ValueError
    line*: int
    column*: int

proc raiseParseException*(msg: string, line, column: int) =
  var e: CirruParseError
  new(e)
  e.msg = msg
  e.line = line
  e.column = column
  raise e

proc raiseParseExceptionAtNode*(msg: string, node: LexNode) =
  raiseParseException(msg, node.line, node.column)

proc isToken*(x: CirruNode): bool =
  x.kind == cirruToken

proc isList*(x: CirruNode): bool =
  x.kind == cirruList

proc toSeq*[T](xs: DoublyLinkedList[T]): seq[T] =
  var ys: seq[T]
  for x in xs:
    ys.add x
  return ys

proc toLinkedList*[T](xs: seq[T]): DoublyLinkedList[T] =
  var ys: DoublyLinkedList[T]
  for x in xs:
    ys.append x
  return ys

proc `[]`*(xs: CirruNode, idx: int): Option[CirruNode] =
  if xs.kind == cirruToken:
    raise newException(ValueError, "Cannot index on cirru string")

  var i = 0
  for item in xs.list:
    if i == idx:
      return some(item)
    i = i + 1
  return none(CirruNode)

proc len*(xs: CirruNode): int =
  if xs.kind == cirruToken:
    return xs.token.len
  else:
    var i = 0
    for item in xs.list:
      i = i + 1
    return i

# TODO need linked list for performance
proc cirruNodesEqual(x, y: CirruNode): bool =
  ## compare if two nodes equal
  if x.kind == y.kind:
    if x.isToken():
      return x.token == y.token
    else:
      if x.len == y.len:
        var k = 0
        for v in x.list:
          let vy = y[k]
          if vy.isNone:
            return false
          if cirruNodesEqual(v, y[k].get):
            discard
          else:
            return false
          k = k + 1
        return true
      else:
        return false
  else:
    return false

proc `==`*(x, y: CirruNode): bool =
  # overload equality function
  return cirruNodesEqual(x, y)

proc `!=`*(x, y: CirruNode): bool =
  # overload equality function
  return not cirruNodesEqual(x, y)

proc isEmpty*(xs: CirruNode): bool =
  case xs.kind
  of cirruToken:
    raise newException(ValueError, "Cannot call isEmpty on text CirruNode")
  of cirruList:
    return xs.list.head.isNil

proc first*(xs: CirruNode): Option[CirruNode] =
  case xs.kind
  of cirruToken:
    raise newException(ValueError, "Cannot call first on text CirruNode")
  of cirruList:
    if xs.isEmpty:
      return none(CirruNode)
    else:
      return some(xs.list.head.value)

proc copyFrom*[T](xs: DoublyLinkedList[T], n: int): DoublyLinkedList[T] =
  var ys: DoublyLinkedList[T]
  var idx = 0
  for x in xs:
    if idx >= n:
      ys.append x
    idx = idx + 1
  return ys

proc restInLinkedList*(xs: CirruNode): DoublyLinkedList[CirruNode] =
  case xs.kind
  of cirruToken:
    raise newException(ValueError, "Cannot call rest on text CirruNode")
  of cirruList:
    if xs.isEmpty:
      raise newException(ValueError, "Cannot call rest on empty CirruNode")
    else:
      xs.list.copyFrom(1)

proc rest*(xs: CirruNode): CirruNode =
  case xs.kind
  of cirruToken:
    raise newException(ValueError, "Cannot call rest on text CirruNode")
  of cirruList:
    if xs.isEmpty:
      raise newException(ValueError, "Cannot call rest on empty CirruNode")
    else:
      return CirruNode(kind: cirruList, list: xs.list.copyFrom(1))

# TODO n
proc lexNodesEqual(xs, ys: seq[LexNode]): bool =
  if xs.len != ys.len:
    return false

  if xs.len == 0:
    return true

  for k, v in xs:
    let xi = v
    let yi = ys[k]
    if xi.kind != yi.kind:
      return false
    case xi.kind:
    of lexOperator:
      if xi.operator != yi.operator:
        return false
    of lexToken:
      if xi.token != yi.token:
        return false

  return true

proc `==`*(x, y: seq[LexNode]): bool =
  return lexNodesEqual(x, y)

proc `==`*(x, y: DoublyLinkedList[LexNode]): bool =
  return lexNodesEqual(x.toSeq, y.toSeq)
