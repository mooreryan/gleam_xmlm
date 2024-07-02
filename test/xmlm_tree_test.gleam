import birdie
import gleam/list
import gleam/result
import gleam/string
import simplifile
import utils
import xmlm

type Tree {
  Element(xmlm.Tag, List(Tree))
  Data(String)
}

fn tree_to_string(tree: Tree) -> String {
  do_tree_to_string(tree, 0)
}

fn do_tree_to_string(tree: Tree, level: Int) -> String {
  let inner = case tree {
    Element(tag, trees) ->
      "El("
      <> tag_to_string(tag)
      <> ", ["
      <> trees_to_string(trees, level + 1)
      <> "]"
      <> ")"
    Data(data) -> "Data(" <> string.inspect(data) <> ")"
  }

  "(" <> inner <> ")"
}

fn tag_to_string(tag: xmlm.Tag) {
  case tag.attributes {
    [] -> "Tag(" <> name_to_string(tag.name) <> ")"
    _ ->
      "Tag("
      <> name_to_string(tag.name)
      <> ", "
      <> attributes_to_string(tag.attributes)
      <> ")"
  }
}

fn name_to_string(name: xmlm.Name) -> String {
  let xmlm.Name(prefix, local) = name
  case prefix {
    "" -> string.inspect(local)
    prefix -> string.inspect(prefix <> ":" <> local)
  }
}

fn attribute_to_string(attribute: xmlm.Attribute) -> String {
  "At("
  <> name_to_string(attribute.name)
  <> ", "
  <> string.inspect(attribute.value)
  <> ")"
}

fn attributes_to_string(attributes: List(xmlm.Attribute)) -> String {
  case attributes {
    [] -> "[]"
    attributes ->
      "[" <> string.join(list.map(attributes, attribute_to_string), ", ") <> "]"
  }
}

fn trees_to_string(trees: List(Tree), level: Int) -> String {
  let indent = string.repeat("    ", level)

  list.map(trees, fn(tree) { "\n" <> indent <> do_tree_to_string(tree, level) })
  |> string.join("")
}

fn read_tree(input: xmlm.Input) -> Result(Tree, xmlm.InputError) {
  use #(_dtd, tree, _input) <- result.try(xmlm.document_tree(
    input,
    Element,
    Data,
  ))

  Ok(tree)
}

pub fn read_tree__test() {
  simplifile.read_bits("test/test_files/nested.xml")
  |> utils.ok_exn
  |> xmlm.from_bit_array
  |> xmlm.with_stripping(True)
  |> read_tree
  |> utils.ok_exn
  |> tree_to_string
  |> birdie.snap("xmlm_tree_test.read_tree__test")
}

pub fn read_tree__with_namespaces__test() {
  simplifile.read_bits("test/test_files/nested_with_namespaces.xml")
  |> utils.ok_exn
  |> xmlm.from_bit_array
  |> xmlm.with_stripping(True)
  |> read_tree
  |> utils.ok_exn
  |> tree_to_string
  |> birdie.snap("xmlm_tree_test.read_tree__with_namespaces__test")
}
