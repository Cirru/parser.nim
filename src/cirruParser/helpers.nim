
import json
import cirruParser/types

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

proc genLexToken*(text: string): LexNode =
  return LexNode(kind: lexToken, text: text)

proc genLexControl*(operator: ControlOperator): LexNode =
  return LexNode(kind: lexControl, operator: operator)
