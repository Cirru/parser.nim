
import json
import unittest
import cirruParser/types
import cirruParser/helpers
import cirruParser/transformer

test "transform dollars":
  let a1 = %* ["a"]
  check (resolveDollar(toCirru(a1)) == toCirru(a1))

  let a2 = %* ["a", "$"]
  let b2 = %* ["a", []]
  check (resolveDollar(toCirru(a2)) == toCirru(b2))

  let a3 = %* ["a", "$", "b"]
  let b3 = %* ["a", ["b"]]
  check (resolveDollar(toCirru(a3)) == toCirru(b3))

  let a4 = %* ["a", "$", "$", "b"]
  let b4 = %* ["a", [["b"]]]
  check (resolveDollar(toCirru(a4)) == toCirru(b4))

test "transform commas":
  let a1 = %* ["a"]
  check (resolveComma(toCirru(a1)) == toCirru(a1))

  let a2 = %* ["a", [",", "b"]]
  let b2 = %* ["a", "b"]
  check (resolveComma(toCirru(a2)) == toCirru(b2))

  let a3 = %* ["a", [",", "b", [",", "c"]]]
  let b3 = %* ["a", "b", "c"]
  check (resolveComma(toCirru(a3)) == toCirru(b3))
