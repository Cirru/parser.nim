
cirru = require '../js-lib'

# Nim may use cstring(also $x for converting back) for compatible string data
# in here we use list of number to represent string

code = 'a b'
codes = code.split('').map (x) -> x.charCodeAt(0)
console.log JSON.stringify (cirru.parseCirru codes), null, 2
