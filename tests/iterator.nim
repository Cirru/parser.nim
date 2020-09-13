
import json
import unittest

import cirruParser
import cirruParser/helpers

test "Try iterator":
  let data = (%* ["1", "2", "3"]).toCirru
  var count = 0
  for item in data:
    count += 1
  check count == 3

  check data[0] == (%* "1").toCirru
  check data.len == 3
