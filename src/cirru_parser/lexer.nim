
import lists
import strutils
import strformat

import ./types

proc lexCode*(code: string): DoublyLinkedList[LexNode] =
  var pieces = initDoublyLinkedList[LexNode]()
  var lexingState = lexStateIndent
  var buffer = ""
  var indentation = 0
  var previousIndentation = 0
  var line = 1
  var column = 0

  proc digestBuffer(): void =
    if buffer.len > 0:
      pieces.append LexNode(kind: lexToken, token: buffer, line: line, column: column)
      buffer = ""

  proc digestIdentation(): void =
    let indentationChange = indentation - previousIndentation

    # echo "handle indentation: ", indentation, " _ ", previousIndentation

    if indentationChange %% 2 != 0:
      raiseParseException(fmt("odd indentation of {indentationChange}"), line, column)
    let level = indentationChange / 2
    # echo "indentation:", level
    if level > 0:
      for i in 1..level.int:
        pieces.append LexNode(kind: lexOperator, operator: controlIndent, line: line, column: column)
    elif level < 0:
      for i in 1..(-level.int):
        pieces.append LexNode(kind: lexOperator, operator: controlOutdent, line: line, column: column)
      # special logic to generate extra newline ops
      pieces.append LexNode(kind: lexOperator, operator: controlOutdent, line: line, column: column)
      pieces.append LexNode(kind: lexOperator, operator: controlIndent, line: line, column: column)

    else:
      if pieces.head.isNil.not:
        pieces.append LexNode(kind: lexOperator, operator: controlOutdent, line: line, column: column)
        pieces.append LexNode(kind: lexOperator, operator: controlIndent, line: line, column: column)

    previousIndentation = indentation
    # echo "previousIndentation: ", previousIndentation
    indentation = 0

  for c in code:

    # echo escape($c), "\t", lexingState, "\t", escape(buffer)
    if c == '\n':
      line = line + 1
      column = 0
    else:
      column = column + 1
    # echo "tracing ", escape($c), line, " ", column

    case lexingState
    of lexStateIndent:
      case c
      of '\t':
        raiseParseException("tab is not supported in Cirru", line, column)
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
        pieces.append LexNode(kind: lexOperator, operator: controlParenOpen, line: line, column: column)
        lexingState = lexStateSpace
      of ')':
        raiseParseException("Unexpected ) in line head", line, column)
      else:
        digestIdentation()
        buffer = $c
        lexingState = lexStateToken
    of lexStateEscape:
      case c
      of 'n':
        buffer.add '\n'
      of 't':
        buffer.add '\t'
      else:
        buffer.add c
      lexingState = lexStateString
    of lexStateString:
      case c
      of '\\':
        lexingState = lexStateEscape
      of '"':
        lexingState = lexStateSpace
        # special case, add even if token is empty
        pieces.append LexNode(kind: lexToken, token: buffer, line: line, column: column)
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
        if buffer.strip().len > 0:
          digestBuffer()
        pieces.append LexNode(kind: lexOperator, operator: controlParenOpen, line: line, column: column)
        lexingState = lexStateSpace
      of ')':
        pieces.append LexNode(kind: lexOperator, operator: controlParenClose, line: line, column: column)
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
        pieces.append LexNode(kind: lexOperator, operator: controlParenOpen, line: line, column: column)
        lexingState = lexStateSpace
      of ')':
        digestBuffer()
        pieces.append LexNode(kind: lexOperator, operator: controlParenClose, line: line, column: column)
        lexingState = lexStateSpace
      of '\n':
        digestBuffer()
        lexingState = lexStateIndent
      else:
        buffer.add c

  case lexingState
  of lexStateToken:
    pieces.append LexNode(kind: lexToken, token: buffer, line: line, column: column)
  of lexStateEscape:
    raiseParseException("EOF at escape", line, column)
  of lexStateString:
    raiseParseException("EOF at string", line, column)
  else:
    discard "ok"

  return pieces
