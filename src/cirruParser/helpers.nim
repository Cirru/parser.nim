
import json
import strutils
import cirruParser/types
import math

proc createCirruString*(x: string): CirruNode =
  return CirruNode(kind: cirruString, text: x)

proc toCirru*(xs: JsonNode): CirruNode =
  case xs.kind:
    of JArray:
      var b: seq[CirruNode]
      for k, v in xs.elems:
        b.add toCirru(v)
      return CirruNode(kind: cirruSeq, list: b)
    of JString:
      return CirruNode(kind: cirruString, text: xs.str)
    else:
      echo xs
      raiseParseException("Unknown type in JSON", 1, 0)

proc genLexToken*(text: string): LexNode =
  return LexNode(kind: lexToken, text: text)

proc genLexControl*(operator: ControlOperator): LexNode =
  return LexNode(kind: lexControl, operator: operator)

proc formatParserFailure*(code, msg, filename: string, line, column: int): string =
  let lines = splitLines(code)
  let linenoLenth = ($line).len
  var previousLine = ""
  if line > 1:
    previousLine = align($(line-1), linenoLenth) & " | " & lines[line - 2] & "\n"
  let failureLine = align($line, linenoLenth) & " | " & lines[line - 1]
  let spaces = align($line, linenoLenth) & " | " & '-'.repeat(max(0, column - 1)).join("")
  return "At " & filename & ":" & $line & ":" & $column & "\n" & $previousLine & failureLine & "\n" & spaces & "^ " & msg
