
import nimprof
import cirru_parser

# let file = "/Users/chen/repo/cirru/calcit-runner.nim/example/compact.cirru"
let file = "/Users/chen/repo/cirru/calcit-editor/calcit.cirru"
# let file = "/Users/chen/repo/cirru/bisection-key/calcit.cirru"

echo "start"
discard parseCirru(readFile(file))
echo "finish"
