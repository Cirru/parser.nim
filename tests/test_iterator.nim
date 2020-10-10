
import json
import unittest
import options

import cirru_parser
import cirru_parser/helpers

test "Try iterator":
  let data = (%* ["1", "2", "3"]).toCirru
  var count = 0
  for item in data:
    count += 1
  check count == 3

  check data[0].get == (%* "1").toCirru
  check data.len == 3

test "Slice":
  let a0 = @[0,1,2,3,4,5,6]
  let data = (%* ["0", "1", "2", "3", "4", "5", "6"]).toCirru

  check a0[0..1].len == data[0..1].len
  check a0[1..1].len == data[1..1].len
  check a0[1..2].len == data[1..2].len

  check a0[0..<1].len == data[0..<1].len
  check a0[0..<2].len == data[0..<2].len

  check a0[0..^1].len == data[0..^1].len
  check a0[1..^1].len == data[1..^1].len
  check a0[1..^2].len == data[1..^2].len

test "first and rest":
  let data = (%* ["0", "1", "2", "3"]).toCirru
  let restData = (%* ["1", "2", "3"]).toCirru
  let zeroData = (%* []).toCirru

  check zeroData.isEmpty
  check data.isEmpty == false
  check data.first().get == toCirru(%* "0")
  check data.rest() == restData
