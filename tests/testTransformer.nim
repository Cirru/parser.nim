
import json
import unittest
import cirruParser/types
import cirruParser/helpers
import cirruParser/transformer

test "transform dollars":
  let a1 = %* ["a"]
  check (resolveDollar(jsonToCirru(a1)) == jsonToCirru(a1))

  let a2 = %* ["a", "$"]
  let b2 = %* ["a", []]
  check (resolveDollar(jsonToCirru(a2)) == jsonToCirru(b2))

  let a3 = %* ["a", "$", "b"]
  let b3 = %* ["a", ["b"]]
  check (resolveDollar(jsonToCirru(a3)) == jsonToCirru(b3))

  let a4 = %* ["a", "$", "$", "b"]
  let b4 = %* ["a", [["b"]]]
  check (resolveDollar(jsonToCirru(a4)) == jsonToCirru(b4))

test "transform commas":
  let a1 = %* ["a"]
  check (resolveComma(jsonToCirru(a1)) == jsonToCirru(a1))

  let a2 = %* ["a", [",", "b"]]
  let b2 = %* ["a", "b"]
  check (resolveComma(jsonToCirru(a2)) == jsonToCirru(b2))

  let a3 = %* ["a", [",", "b", [",", "c"]]]
  let b3 = %* ["a", "b", "c"]
  check (resolveComma(jsonToCirru(a3)) == jsonToCirru(b3))
