
Nim Cirru Parser
---

> Parser for Cirru Syntax.

```bash
nimble install cirru-parser
```

```nim
import cirruParser

# parse code
parseCirru "a b"
```

which returns:

```nim
(kind: cirruSeq, list: @[(kind: cirruSeq, list: @[(kind: cirruString, text: "a"), (kind: cirruString, text: "b")])])  : CirruNode
```

`CirruNode` is the type of exprssions and tokens parsed from Cirru code. Browse [types.nim](src/cirruParser/types.nim) for definitions.

A quick way to create Cirru nodes is creating nodes from JSON via `toCirru` function:

```nim
let a4 = %* ["a", "$", "$", "b"]
toCirru(a4)
```

To compare Cirru nodes, use `==`. Notice that this overloaded `==` only checks types and values. Nodes are equal even they contain different line or column fields.

To format errors, use:

```nim
formatParserFailure(code, error.msg, "filename", error.line, error.column)
```

Browse [`tests/`](tests/) you will find examples of all public APIs.

### License

MIT
