
import cirruParser/types

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

    if indentationChange %% 2 != 0:
      raise newException(CirruParseError, "odd indentation of {indentationChange} $indentationChange")
    let level = indentationChange / 2
    # echo "indentation:", level
    if level > 0:
      for i in 1..level.int:
        pieces.add LexNode(kind: lexControl, operator: controlIndent)
    elif level < 0:
      for i in 1..(-level.int):
        pieces.add LexNode(kind: lexControl, operator: controlOutdent)
    else:
      if pieces.len > 0:
        pieces.add LexNode(kind: lexControl, operator: controlOutdent)
        pieces.add LexNode(kind: lexControl, operator: controlIndent)

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
        raise newException(CirruParseError, "Unexpected ) in line head")
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
        if buffer.len > 0:
          digestBuffer()
        pieces.add LexNode(kind: lexControl, operator: controlParenOpen)
        lexingState = lexStateSpace
      of ')':
        pieces.add LexNode(kind: lexControl, operator: controlParenClose)
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
        if buffer.len > 0:
          digestBuffer()
        pieces.add LexNode(kind: lexControl, operator: controlParenOpen)
        lexingState = lexStateSpace
      of ')':
        digestBuffer()
        pieces.add LexNode(kind: lexControl, operator: controlParenClose)
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
