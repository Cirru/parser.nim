
import json
import unittest
import cirruParser/types
import cirruParser/helpers
import cirruParser/transformer

test "transform dollars":
  let a1 = %* ["a"]
  check cirruNodesEqual(resolveDollar(createCirruNodeFromJson(a1)),
                        createCirruNodeFromJson(a1))

  let a2 = %* ["a", "$"]
  let b2 = %* ["a", []]
  check cirruNodesEqual(resolveDollar(createCirruNodeFromJson(a2)),
                        createCirruNodeFromJson(b2))

  let a3 = %* ["a", "$", "b"]
  let b3 = %* ["a", ["b"]]
  check cirruNodesEqual(resolveDollar(createCirruNodeFromJson(a3)),
                        createCirruNodeFromJson(b3))

  let a4 = %* ["a", "$", "$", "b"]
  let b4 = %* ["a", [["b"]]]
  check cirruNodesEqual(resolveDollar(createCirruNodeFromJson(a4)),
                        createCirruNodeFromJson(b4))

test "transform commas":
  let a1 = %* ["a"]
  check cirruNodesEqual(resolveComma(createCirruNodeFromJson(a1)),
                        createCirruNodeFromJson(a1))

  let a2 = %* ["a", [",", "b"]]
  let b2 = %* ["a", "b"]
  check cirruNodesEqual(resolveComma(createCirruNodeFromJson(a2)),
                        createCirruNodeFromJson(b2))

  let a3 = %* ["a", [",", "b", [",", "c"]]]
  let b3 = %* ["a", "b", "c"]
  check cirruNodesEqual(resolveComma(createCirruNodeFromJson(a3)),
                        createCirruNodeFromJson(b3))
