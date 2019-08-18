import strutils
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

  LexNodeKind* = enum
    lexToken,
    lexControl

  ControlOperator* = enum
    controlParenOpen,
    contorlParenClose,
    controlIndent,
    controlOutdent,
    controlNewline

  LexNode* = object
    case kind*: LexNodeKind
    of lexToken: text*: string
    of lexControl: operator*: ControlOperator

  LexState = enum
    lexStateToken,
    lexStateSpace,
    lexStateString,
    lexStateEscape,
    lexStateIndent

  CirruParseError* = object of Exception

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
      raise newException(CirruParseError, "Unknown type in JSON")

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
  var lexingState = lexStateIndent
  var buffer = ""
  var indentation = 0
  var previousIndentation = 0

  proc digestBuffer(): void =
    pieces.add LexNode(kind: lexToken, text: buffer)
    buffer = ""

  proc digestIdentation(): void =
    let indentationChange = indentation - previousIndentation

    # echo "handle indentation: ", indentation, " _ ", previousIndentation

    if (indentationChange %% 2 != 0):
      raise newException(CirruParseError, "odd indentation of {indentationChange} $indentationChange")
    let level = indentationChange / 2
    # echo "indentation:", level
    if (level > 0):
      for i in 1..level.int:
        pieces.add LexNode(kind: lexControl, operator: controlIndent)
    elif (level < 0):
      for i in 1..(-level.int):
        pieces.add LexNode(kind: lexControl, operator: controlOutdent)
    else:
      pieces.add LexNode(kind: lexControl, operator: controlNewline)

    previousIndentation = indentation
    # echo "previousIndentation: ", previousIndentation
    indentation = 0

  for c in code:

    # echo escape($c), "\t", lexingState, "\t", escape(buffer)

    case lexingState
    of lexStateIndent:
      case c
      of '\t':
        raise newException(CirruParseError, "tab is not supported in Cirru")
      of ' ':
        buffer.add(' ')
        indentation += 1
      of '\n':
        indentation = 0
      of '"':
        digestIdentation()
        buffer = ""
        lexingState = lexStateString
      of '(':
        digestIdentation()
        pieces.add LexNode(kind: lexControl, operator: controlParenOpen)
        lexingState = lexStateSpace
      of ')':
        raise newException(CirruParseError, "Unexpeced ) in line head")
      else:
        digestIdentation()
        buffer = $c
        lexingState = lexStateToken
    of lexStateEscape:
      buffer.add c
    of lexStateString:
      case c
      of '\\':
        lexingState = lexStateSpace
      of '"':
        lexingState = lexStateSpace
        digestBuffer()
      else:
        buffer.add c
    of lexStateSpace:
      case c
      of ' ':
        discard "still space"
      of '"':
        buffer = ""
        lexingState = lexStateString
      of '\n':
        lexingState = lexStateIndent
      of '(':
        if (buffer.len > 0):
          digestBuffer()
        pieces.add LexNode(kind: lexControl, operator: controlParenOpen)
        lexingState = lexStateSpace
      of ')':
        pieces.add LexNode(kind: lexControl, operator: contorlParenClose)
        digestBuffer()
        lexingState = lexStateSpace
      else:
        buffer = $c
        lexingState = lexStateToken
    of lexStateToken:
      case c
      of ' ':
        digestBuffer()
        lexingState = lexStateSpace
      of '(':
        if (buffer.len > 0):
          digestBuffer()
        pieces.add LexNode(kind: lexControl, operator: controlParenOpen)
        lexingState = lexStateSpace
      of ')':
        digestBuffer()
        pieces.add LexNode(kind: lexControl, operator: contorlParenClose)
        lexingState = lexStateSpace
      of '\n':
        digestBuffer()
        lexingState = lexStateIndent
      else:
        buffer.add c

  case lexingState
  of lexStateToken:
    pieces.add LexNode(kind: lexToken, text: buffer)
  of lexStateEscape:
    raise newException(CirruParseError, "EOF at escape")
  of lexStateString:
    raise newException(CirruParseError, "EOF at string")
  else:
    discard "ok"

  return pieces
