import json

# thanks to https://forum.nim-lang.org/t/4233
type
  CirruNodeKind* = enum
    cirruString,
    cirruSeq

  CirruNode* = object
    case kind*: CirruNodeKind
    of cirruString: text*: string
    of cirruSeq: list*: seq[CirruNode]

type
  LexNodeKind* = enum
    lexToken,
    lexControl

  ControlOperator* = enum
    controlParenOpen,
    contorlParenClose,
    controlIndent,
    controlOutdent

  LexNode* = object
    case kind*: LexNodeKind
    of lexToken: text*: string
    of lexControl: operator*: ControlOperator

proc createCirruString*(x: string): CirruNode =
  return CirruNode(kind: cirruString, text: x)

proc createCirruNodeFromJson*(xs: JsonNode): CirruNode =
  case xs.kind:
    of JArray:
      var b: seq[CirruNode]
      for k, v in xs.elems:
        b.add createCirruNodeFromJson(v)
      return CirruNode(kind: cirruSeq, list: b)
    of JString:
      return CirruNode(kind: cirruString, text: xs.str)
    else:
      echo xs
      raise newException(OSError, "Unknown type in JSON")

proc cirruNodesEqual*(x, y: CirruNode): bool =
  ## compare if two nodes equal
  if (x.kind == y.kind):
    if (x.kind == cirruString):
      return x.text == y.text
    else:
      if (x.list.len == y.list.len):
        for k, v in x.list:
          if (cirruNodesEqual(v, y.list[k])):
            continue
          else:
            return false
        return true
      else:
        return false
  else:
    return false

proc lexNodesEqual*(xs, ys: seq[LexNode]): bool =
  if (xs.len != ys.len):
    return false

  if (xs.len == 0):
    return true

  for k, v in xs:
    let xi = v
    let yi = ys[k]
    if (xi.kind != yi.kind):
      return false
    case xi.kind:
    of lexControl:
      if (xi.operator != yi.operator):
        return false
    of lexToken:
      if (xi.text != yi.text):
        return false

  return true

proc lexCode*(code: string): seq[LexNode] =
  var pieces: seq[LexNode]

  return pieces
