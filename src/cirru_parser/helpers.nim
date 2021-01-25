
import json
import lists
import strutils
import sequtils
import options

import ./types

proc createCirruToken*(x: string): CirruNode =
  return CirruNode(kind: cirruToken, token: x)

proc toCirru*(xs: JsonNode): CirruNode =
  case xs.kind:
    of JArray:
      var b: DoublyLinkedList[CirruNode]
      for k, v in xs.elems:
        b.append toCirru(v)
      return CirruNode(kind: cirruList, list: b)
    of JString:
      return CirruNode(kind: cirruToken, token: xs.str)
    else:
      echo xs
      raiseParseException("Unknown type in JSON", 1, 0)

proc toJson*(xs: CirruNode): JsonNode =
  case xs.kind:
  of cirruToken:
    return JsonNode(kind: JString, str: xs.token)
  of cirruList:
    return JsonNode(kind: JArray, elems: xs.list.toSeq.map(toJson))

proc genLexToken*(x: string): LexNode =
  return LexNode(kind: lexToken, token: x)

proc genLexOperator*(operator: ControlOperator): LexNode =
  return LexNode(kind: lexOperator, operator: operator)

proc formatParserFailure*(code, msg, filename: string, line, column: int): string =
  let lines = splitLines(code)
  let linenoLenth = ($line).len
  var previousLine = ""
  if line > 1:
    previousLine = align($(line-1), linenoLenth) & " | " & lines[line - 2] & "\n"
  let failureLine = align($line, linenoLenth) & " | " & lines[line - 1]
  let spaces = align($line, linenoLenth) & " | " & '-'.repeat(max(0, column - 1)).join("")
  return "At " & filename & ":" & $line & ":" & $column & "\n" & $previousLine & failureLine & "\n" & spaces & "^ " & msg

iterator items*(xs: CirruNode): CirruNode =
  if xs.kind == cirruToken:
    raise newException(ValueError, "Cannot create iterator on a cirru string")
  for child in xs.list:
    yield child

proc `[]`*(xs: CirruNode, fromTo: HSlice[int, int]): seq[CirruNode] =
  if xs.kind == cirruToken:
    raise newException(ValueError, "Cannot create iterator on a cirru string")

  let fromA = fromTo.a
  let toB = fromTo.b
  let size = toB - fromA + 1
  newSeq(result, size)
  for idx in 0..<size:
    result[idx] = xs[fromA + idx].get

proc `[]`*(xs: CirruNode, fromTo: HSlice[int, BackwardsIndex]): seq[CirruNode] =
  if xs.kind == cirruToken:
    raise newException(ValueError, "Cannot create iterator on a cirru string")

  let fromA = fromTo.a
  let toB =  xs.len - fromTo.b.int
  xs[fromA .. toB]
