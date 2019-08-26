
# thanks to https://forum.nim-lang.org/t/4233
type
  CirruNodeKind* = enum
    cirruString,
    cirruSeq

  CirruNode* = object
    case kind*: CirruNodeKind
    of cirruString: text*: string
    of cirruSeq: list*: seq[CirruNode]

  LexNodeKind* = enum
    lexToken,
    lexControl

  ControlOperator* = enum
    controlParenOpen,
    controlParenClose,
    controlIndent,
    controlOutdent

  LexNode* = object
    case kind*: LexNodeKind
    of lexToken: text*: string
    of lexControl: operator*: ControlOperator

  LexState* = enum
    lexStateToken,
    lexStateSpace,
    lexStateString,
    lexStateEscape,
    lexStateIndent

  CirruParseError* = object of Exception

proc isToken*(x: CirruNode): bool =
  x.kind == cirruString

proc isSeq*(x: CirruNode): bool =
  x.kind == cirruSeq

proc cirruNodesEqual(x, y: CirruNode): bool =
  ## compare if two nodes equal
  if x.kind == y.kind:
    if x.isToken():
      return x.text == y.text
    else:
      if x.list.len == y.list.len:
        for k, v in x.list:
          if cirruNodesEqual(v, y.list[k]):
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
  # overload equality function
  return lexNodesEqual(x, y)

proc `!=`*(x, y: seq[LexNode]): bool =
  # overload equality function
  return not lexNodesEqual(x, y)
