
# TODO, better to use Cirru as script

fs = require 'fs'

exportsCode = '\nexports.parseCirru = parseCirru;\n'

libFile = 'js-lib/index.js'

fs.appendFileSync libFile, exportsCode

console.log "Added code for exporting parseCirru"
