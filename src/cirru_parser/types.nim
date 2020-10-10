
import lists

type
  CirruNodeKind* = enum
    cirruString,
    cirruSeq

  CirruNode* = object
    line*: int
    column*: int
    case kind*: CirruNodeKind
    of cirruString:
      text*: string
    of cirruSeq:
      list*: DoublyLinkedList[CirruNode]

  LexNodeKind* = enum
    lexToken,
    lexControl

  ControlOperator* = enum
    controlParenOpen,
    controlParenClose,
    controlIndent,
    controlOutdent

  LexNode* = object
    line*: int
    column*: int
    case kind*: LexNodeKind
    of lexToken: text*: string
    of lexControl: operator*: ControlOperator

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
  x.kind == cirruString

proc isSeq*(x: CirruNode): bool =
  x.kind == cirruSeq

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

# TODO need linked list for performance
proc cirruNodesEqual(x, y: CirruNode): bool =
  ## compare if two nodes equal
  if x.kind == y.kind:
    if x.isToken():
      return x.text == y.text
    else:
      if x.list.toSeq.len == y.list.toSeq.len:
        for k, v in x.list.toSeq:
          if cirruNodesEqual(v, y.list.toSeq[k]):
            continue
          else:
            return false
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
    of lexControl:
      if xi.operator != yi.operator:
        return false
    of lexToken:
      if xi.text != yi.text:
        return false

  return true

proc `==`*(x, y: seq[LexNode]): bool =
  return lexNodesEqual(x, y)

proc `==`*(x, y: DoublyLinkedList[LexNode]): bool =
  return lexNodesEqual(x.toSeq, y.toSeq)
