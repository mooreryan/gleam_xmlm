import gleam/list
import gleam/pair
import gleam/result
import gleam/set
import gleam/string
import simplifile
import xmlm

// TODO: probably would just be easier to take a list of which tests are
// supposed to pass and which are supposed to fail.

const test_file_prefix = "test/test_files/xmlconf/oasis/"

const generated_test_name = "test/xmlconf/oasis/oasis_test.gleam"

// NOTE: sometimes a test that by the spec should fail, but seems like it should
// pass because it is exercising some behavior that our parser is not concered
// with, actually will fail.  This is often because it is failing for some other
// reason than the one envisioned by the author of the test.  Whether that
// should be a bug or not, we will not treat.
fn tests_that_should_actually_pass(id, sections) {
  let ignore_these =
    set.from_list([
      // 2.3 Common Syntactic Constructs
      // [9] {EntityValue}
      // [12] {PubidLiteral}
      // [13] {PubidChar}
      "[9]", "[12]", "[13]",
      // 2.6 Processing Instructions
      // [16] {PI}
      "[16]",
      // 2.8
      // [29] {markupdecl}
      // [30] {extSubset}
      // [31] {extSubsetDecl}
      "[29]", "[30]", "[31]",
      // TODO: explain
      "3.2", "3.2.1", "3.2.2", "4.2", "4.2.1", "4.2.2",
      // 3.3 Attribute-List Declarations
      // [52] {AttlistDecl}
      // [53] {AttDef}
      "3.3", "[52]", "[53]",
      // 3.3.1 Attribute Types -- Enumerated Attribute Types
      // [54] {AttType}
      // [55] {StringType}
      // [56] {TokenizedType}
      // [57] {EnumeratedType}
      // [58] {NotationType}
      // [59] {Enumeration}
      "3.3.1", "[54]", "[55]", "[56]", "[57]", "[58]", "[59]",
      // 3.3.2 Attribute Defaults (DTD stuff)
      "3.3.2",
      // 3.4 Conditional Sections (DTD stuff)
      "3.4",
      // XML 1.0 {PEReference} (parameter-entity reference)
      "[69]",
    ])

  // Some of the tests that are in sections that should be ignored, actually
  // exercise some behavior that is not specified by the test or the section.
  // These will need to NOT be ignored.
  let keep_these_ids =
    [
      "o-p49fail1", "o-p50fail1",
      // 2.6 [16] "xml" is an invalid PITarget
      "o-p16fail1",
      // 2.6 [16] a PITarget must be present
      "o-p16fail2",
      // 2.3 [9] quote types must match
      "o-p09fail4", "o-p09fail5",
    ]
    |> list.map(clean_id)
    |> set.from_list

  // And some tests are in sections that are included in the parser, but for
  // whatever reason we do not check. (Eg well-formedness constraints like
  // unique attribute names. )
  //
  // the name is misleading because some invalid ones are in here too..but our
  // thing isn't a validating parser but sometimes they still fail
  let not_wf_but_should_pass_anyway_in_this_parser =
    [
      // [44] {EmptyElemTag} [WFC: Unique Att Spec] Duplicate attribute name is illegal
      "o-p44fail5",
      // 2.9 [32] initial S is required (TODO I actually think this is probably
      // a bug in our parser)
      "o-p32fail3",
      // 2.1 [1] only one document element (OCaml Xmlm allows this but it is
      // deprecated--will need to be fixed in this parser as well TODO)
      "o-p01fail3",
    ]
    |> list.map(clean_id)
    |> set.from_list

  let in_ignored_section = !set.is_disjoint(ignore_these, sections)
  let not_special_id = !set.contains(keep_these_ids, id)

  set.contains(not_wf_but_should_pass_anyway_in_this_parser, id)
  || { in_ignored_section && not_special_id }
}

fn spec_passing_tests_that_should_fail(id) {
  // TODO: these should probably be made into specific tests
  let should_fail_whatever_the_spec_says =
    [
      // 2.3 [5] various valid Name constructions (this parser matches Xmlm, but
      // both I think have a bug here TODO)
      "o-p05pass1",
      //2.3 [4] TODO this one is also probably a bug in both  (names with all
      // valid ASCII characters, and one from each other class in NameChar).  It
      // is `invalid` but these aren't validating parser.  So they should pass.
      "o-p04pass1",
      // 4.1 [68] this one is tricky because we don't parse entity references in
      // the DTD, so for this reason our parser fails with an unknown entity
      // reference error , whereas a spec compliant one would pass.
      //
      // o-p43pass1 fails for the same reason (unknown entity ref error)
      "o-p68pass1", "o-p43pass1",
    ]
    |> list.map(clean_id)
    |> set.from_list

  set.contains(should_fail_whatever_the_spec_says, id)
}

pub fn main() {
  run()
}

type TestCaseType {
  Valid
  Invalid
  NotWf
  Err
}

fn test_case_type_from_string(string: String) -> TestCaseType {
  case string {
    "valid" -> Valid
    "invalid" -> Invalid
    "not-wf" -> NotWf
    "error" -> Err
    bad -> panic as { "bad test_case_type string: " <> bad }
  }
}

type TestCase {
  TestCase(
    ty: TestCaseType,
    id: String,
    sections: set.Set(String),
    file_name: String,
  )
}

fn test_case_default() {
  TestCase(Err, "", set.new(), "")
}

fn test_case_function_name(test_case: TestCase) -> String {
  test_case.id <> "__test"
}

fn test_case_to_function_string(test_case: TestCase) -> String {
  let name = test_case_function_name(test_case)

  let input_signals = "data |> xmlm.from_bit_array |> xmlm.signals"

  // I.e., is this test exercising a section of the spec that we ignore? If so,
  // any failures coming from that section should be passes.
  let should_really_pass =
    tests_that_should_actually_pass(test_case.id, test_case.sections)

  let should_really_fail = spec_passing_tests_that_should_fail(test_case.id)

  // Override if necessary
  let should_really_pass = case should_really_fail {
    True -> False
    False -> should_really_pass
  }

  let assertion = case should_really_fail {
    True -> " |> should.be_error"
    False ->
      case test_case.ty, should_really_pass {
        // Invalid is here because our parser is not a validating parser.
        Valid, _ | Invalid, _ | Err, _ | NotWf, True -> " |> should.be_ok"
        NotWf, False -> " |> should.be_error"
      }
  }

  // let assertion = case test_case.ty, should_really_pass {
  //   // Invalid is here because our parser is not a validating parser.
  //   Valid, _ | Invalid, _ | Err, _ | NotWf, True -> " |> should.be_ok"
  //   NotWf, False -> " |> should.be_error"
  // }
  let input_signals = input_signals <> assertion

  let read_file =
    "let assert Ok(data) = simplifile.read_bits(\""
    <> test_case.file_name
    <> "\")"

  let body_lines = ["  " <> read_file, " " <> input_signals]

  let test_body = body_lines |> string.join("\n")

  let fun_string = fn(body) {
    "pub fn " <> name <> "() {\n" <> body <> "\n}\n\n"
  }

  fun_string(test_body)
}

fn test_case_from_attributes(attributes: List(xmlm.Attribute)) -> TestCase {
  list.fold(attributes, test_case_default(), fn(test_case, attribute) {
    case attribute.name {
      xmlm.Name("", "TYPE") ->
        TestCase(..test_case, ty: test_case_type_from_string(attribute.value))

      xmlm.Name("", "ID") ->
        TestCase(..test_case, id: clean_id(attribute.value))

      xmlm.Name("", "SECTIONS") -> {
        let sections = attribute.value |> string.split(on: " ") |> set.from_list

        TestCase(..test_case, sections: sections)
      }

      xmlm.Name("", "URI") -> {
        let file_name = test_file_prefix <> attribute.value

        case simplifile.is_file(file_name) {
          Ok(True) -> Nil
          Ok(False) -> panic as { "not file: " <> file_name }
          Error(err) ->
            panic as {
                "error checking file: "
                <> string.inspect(err)
                <> " -- "
                <> file_name
              }
        }

        TestCase(..test_case, file_name: file_name)
      }

      _ -> test_case
    }
  })
}

fn run() -> Nil {
  let assert Ok(file_data) =
    simplifile.read_bits("test/test_files/xmlconf/oasis/oasis.xml")

  let handle_signal = fn(test_cases, signal) {
    case signal {
      xmlm.ElementStart(xmlm.Tag(name, attributes)) ->
        case name.local {
          "TESTCASES" -> test_cases
          "TEST" -> {
            [test_case_from_attributes(attributes), ..test_cases]
          }
          _ -> panic as "unexpected local name"
        }
      xmlm.Dtd(_) | xmlm.Data(_) | xmlm.ElementEnd -> test_cases
    }
  }

  let assert Ok(test_cases) =
    file_data
    |> xmlm.from_bit_array
    |> xmlm.with_encoding(xmlm.Utf8)
    |> xmlm.fold_signals([], handle_signal)
    |> result.map(pair.first)
    |> result.map(list.reverse)

  let test_functions =
    test_cases
    |> list.map(test_case_to_function_string)
    |> string.join("")

  let imports = "import gleeunit/should\nimport simplifile\nimport xmlm\n\n"

  let module_comment =
    "//// Generated by `gleam run -m xmlconf/oasis/gen`.  Please edit with care!\n////\n////\n"

  let test_file_body = module_comment <> imports <> test_functions
  let assert Ok(Nil) =
    simplifile.write(to: generated_test_name, contents: test_file_body)

  Nil
}

// =============================================================================
// Utils
// =============================================================================

fn clean_id(id: String) -> String {
  id |> string.replace(each: "-", with: "_")
}
