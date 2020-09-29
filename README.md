
Nim Cirru Parser
---

> Parser for Cirru Syntax.

```bash
nimble install cirru-parser
```

```nim
import cirru_parser

# parse code
parseCirru "a b"
```

which returns:

```nim
(kind: cirruSeq, list: @[(kind: cirruSeq, list: @[(kind: cirruString, text: "a"), (kind: cirruString, text: "b")])])  : CirruNode
```

`CirruNode` is the type of exprssions and tokens parsed from Cirru code. Browse [types.nim](src/cirru_parser/types.nim) for definitions.

```nim
type
  CirruNodeKind* = enum
    cirruString,
    cirruSeq

  CirruNode* = object
    line*: int
    column*: int
    case kind*: CirruNodeKind
    of cirruString:
      text*: string
    of cirruSeq:
      list*: seq[CirruNode]
```

A quick way to create Cirru nodes is creating nodes from JSON via `toCirru` function:

```nim
let a4 = %* ["a", "$", "$", "b"]
let a5 = toCirru(a4)

toJson(a5) # converts back
```

To compare Cirru nodes, use `==`. Notice that this overloaded `==` only checks types and values. Nodes are equal even they contain different line or column fields.

To format errors, use:

```nim
formatParserFailure(code, error.msg, "filename", error.line, error.column)
```

Browse [`tests/`](tests/) you will find examples of all public APIs.

### JavaScript library

Since Nim can be compiled to JavaScript, this library is also published on npm:

![](https://img.shields.io/npm/v/@cirru/parser.nim.svg?style=flat-square)

```bash
yarn add @cirru/parser.nim
```

Nim strings is different from JavaScript string. To call this library, convert string to `number[]` first:

```coffee
a = require '@cirru/parser.nim'
code = 'a b'
codes = code.split('').map (x) -> x.charCodeAt(0)
cirru.parseCirru codes
```

For return value `"b"`, it's also represented in `number[]`:

```js
{
  "line": 1,
  "column": 3,
  "kind": 0,
  "text": [
    98
  ],
  "list": null
}
```

### License

MIT
