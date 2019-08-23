
Nim Cirru Parser
---

> Parser for Cirru Syntax.

```nim
import cirruParser

# parse code
parseCirru "a b"
```

which returns:

```nim
(kind: cirruSeq, list: @[(kind: cirruSeq, list: @[(kind: cirruString, text: "a"), (kind: cirruString, text: "b")])])  : CirruNode
```

Browse [types.nim](src/cirruParser/types.nim) for definitions.

### License

MIT
