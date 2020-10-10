
import json
import lists
import strutils
import sequtils

import ./types

proc createCirruString*(x: string): CirruNode =
  return CirruNode(kind: cirruString, text: x)

proc toCirru*(xs: JsonNode): CirruNode =
  case xs.kind:
    of JArray:
      var b: seq[CirruNode]
      for k, v in xs.elems:
        b.add toCirru(v)
      return CirruNode(kind: cirruSeq, list: b.toLinkedList)
    of JString:
      return CirruNode(kind: cirruString, text: xs.str)
    else:
      echo xs
      raiseParseException("Unknown type in JSON", 1, 0)

proc toJson*(xs: CirruNode): JsonNode =
  case xs.kind:
  of cirruString:
    return JsonNode(kind: JString, str: xs.text)
  of cirruSeq:
    return JsonNode(kind: JArray, elems: xs.list.toSeq.map(toJson))

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

iterator items*(xs: CirruNode): CirruNode =
  if xs.kind == cirruString:
    raise newException(ValueError, "Cannot create iterator on a cirru string")
  for child in xs.list:
    yield child

proc `[]`*(xs: CirruNode, idx: int): CirruNode =
  if xs.kind == cirruString:
    raise newException(ValueError, "Cannot index on cirru string")

  xs.list.toSeq[idx]

proc `[]`*(xs: CirruNode, fromTo: HSlice[int, int]): seq[CirruNode] =
  if xs.kind == cirruString:
    raise newException(ValueError, "Cannot create iterator on a cirru string")

  let fromA = fromTo.a
  let toB = fromTo.b
  let size = toB - fromA + 1
  newSeq(result, size)
  for idx in 0..<size:
    result[idx] = xs[fromA + idx]

proc len*(xs: CirruNode): int =
  if xs.kind == cirruString:
    xs.text.len
  else:
    xs.list.toSeq.len

proc `[]`*(xs: CirruNode, fromTo: HSlice[int, BackwardsIndex]): seq[CirruNode] =
  if xs.kind == cirruString:
    raise newException(ValueError, "Cannot create iterator on a cirru string")

  let fromA = fromTo.a
  let toB =  xs.len - fromTo.b.int
  xs[fromA .. toB]

proc copyFrom*[T](xs: DoublyLinkedList[T], n: int): DoublyLinkedList[T] =
  var ys: DoublyLinkedList[T]
  var idx = 0
  for x in xs:
    if idx >= n:
      ys.append x
    idx = idx + 1
  return ys
