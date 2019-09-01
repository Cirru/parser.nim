
import cirruParser/types

proc lexCode*(code: string): seq[LexNode] =
  var pieces: seq[LexNode]
  var lexingState = lexStateIndent
  var buffer = ""
  var indentation = 0
  var previousIndentation = 0

  proc digestBuffer(): void =
    if buffer.len > 0:
      pieces.add LexNode(kind: lexToken, text: buffer)
      buffer = ""

  proc digestIdentation(): void =
    let indentationChange = indentation - previousIndentation

    # echo "handle indentation: ", indentation, " _ ", previousIndentation

    if indentationChange %% 2 != 0:
      raiseParseException("odd indentation of {indentationChange} $indentationChange", 0, 0)
    let level = indentationChange / 2
    # echo "indentation:", level
    if level > 0:
      for i in 1..level.int:
        pieces.add LexNode(kind: lexControl, operator: controlIndent)
    elif level < 0:
      for i in 1..(-level.int):
        pieces.add LexNode(kind: lexControl, operator: controlOutdent)
      # special logic to generate extra newline ops
      pieces.add LexNode(kind: lexControl, operator: controlOutdent)
      pieces.add LexNode(kind: lexControl, operator: controlIndent)

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
        raiseParseException("tab is not supported in Cirru", 0, 0)
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
        raiseParseException("Unexpected ) in line head", 0, 0)
      else:
        digestIdentation()
        buffer = $c
        lexingState = lexStateToken
    of lexStateEscape:
      buffer.add c
      lexingState = lexStateString
    of lexStateString:
      case c
      of '\\':
        lexingState = lexStateEscape
      of '"':
        lexingState = lexStateSpace
        # special case, add even if token is empty
        pieces.add LexNode(kind: lexToken, text: buffer)
        buffer = ""
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
    raiseParseException("EOF at escape", 0, 0)
  of lexStateString:
    raiseParseException("EOF at string", 0, 0)
  else:
    discard "ok"

  return pieces
