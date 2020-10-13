
import nimprof
import cirru_parser
import times

# let file = "/Users/chen/repo/cirru/calcit-runner.nim/example/compact.cirru"
# let file = "/Users/chen/repo/cirru/calcit-editor/calcit.cirru"
# let file = "/Users/chen/repo/cirru/bisection-key/calcit.cirru"
let file = "/Users/chen/repo/mvc-works/calcit-workflow/calcit.cirru"

let t1 = now()
echo "start"
discard parseCirru(readFile(file))
echo "finish"

let t2 = now()
echo "Cost: ", t2 - t1
