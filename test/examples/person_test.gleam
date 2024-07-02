import birdie
import gleam/option.{type Option, None, Some}
import gleam/string
import xmlm.{
  type Input, type Tag, Data, Dtd, ElementEnd, ElementStart, Name, Tag,
}

pub fn person_with_all_fields__test() {
  let input =
    "<person>
      <first>Juan</first>
      <last>Delgado-Molina</last>
      <middle>C</middle>
    </person>"
    |> xmlm.from_string
    |> xmlm.with_stripping(True)

  let assert Ok(input) = accept_dtd(input)

  let assert Ok(#(person, input)) = input_person(input)

  person_to_string(person)
  |> birdie.snap("person_test.person_with_all_fields__test")

  let assert Ok(#(True, _input)) = xmlm.eoi(input)
}

pub fn person_with_some_fields__test() {
  let input =
    "<person>
      <last>Delgado-Molina</last>
    </person>"
    |> xmlm.from_string
    |> xmlm.with_stripping(True)

  let assert Ok(input) = accept_dtd(input)

  let assert Ok(#(person, input)) = input_person(input)

  person_to_string(person)
  |> birdie.snap("person_test.person_with_some_fields__test")

  let assert Ok(#(True, _input)) = xmlm.eoi(input)
}

pub fn person_with_no_fields__test() {
  let input =
    "<person>
    </person>"
    |> xmlm.from_string
    |> xmlm.with_stripping(True)

  let assert Ok(input) = accept_dtd(input)

  let assert Ok(#(person, input)) = input_person(input)

  person_to_string(person)
  |> birdie.snap("person_test.person_with_no_fields__test")

  let assert Ok(#(True, _input)) = xmlm.eoi(input)
}

/// `input_person(input)` inputs a `Person` or returns an error.
/// 
/// *Note!* Caller does not need to eat the corresponding `ElementEnd` signal.
///
fn input_person(input: Input) -> Result(#(Person, Input), String) {
  do_input_person(input, default_person())
}

// In this case we will assume that first, middle, and last are all optional and
// can appear in any order.
fn do_input_person(
  input: Input,
  person: Person,
) -> Result(#(Person, Input), String) {
  case xmlm.signal(input) {
    Error(e) -> Error(xmlm.input_error_to_string(e))

    Ok(#(ElementStart(Tag(Name("", "person"), _)), input)) ->
      do_input_person(input, person)

    Ok(#(ElementStart(Tag(Name("", "first"), _)), input)) -> {
      case input_basic_element(input) {
        Error(e) -> Error(e)
        Ok(#(BasicElement(_, data), input)) -> {
          do_input_person(input, Person(..person, first: Some(data)))
        }
      }
    }

    Ok(#(ElementStart(Tag(Name("", "middle"), _)), input)) -> {
      case input_basic_element(input) {
        Error(e) -> Error(e)
        Ok(#(BasicElement(_, data), input)) -> {
          do_input_person(input, Person(..person, middle: Some(data)))
        }
      }
    }

    Ok(#(ElementStart(Tag(Name("", "last"), _)), input)) -> {
      case input_basic_element(input) {
        Error(e) -> Error(e)
        Ok(#(BasicElement(_, data), input)) -> {
          do_input_person(input, Person(..person, last: Some(data)))
        }
      }
    }

    // Because the `input_basic_element` eats the `ElementEnd` signal of the
    // element that was parsed, if we see an `ElementEnd` signal at this level,
    // then we are done.
    Ok(#(ElementEnd, input)) -> Ok(#(person, input))

    Ok(#(signal, _)) ->
      Error(
        "do_input_person: unexpected signal: " <> xmlm.signal_to_string(signal),
      )
  }
}

/// Represents a "basic" element of the form `<tag>data</tag>`.
/// 
type BasicElement {
  BasicElement(tag: Tag, data: String)
}

fn default_basic_element() -> BasicElement {
  BasicElement(tag: Tag(Name("", ""), []), data: "")
}

/// `input_basic_element(input)` inputs a `BasicElement` or an error if the form 
/// is not something like this:  `<tag>lots of data</tag>`
/// 
/// *Note!* Caller does not need to eat the corresponding `ElementEnd` signal.
/// 
fn input_basic_element(input: Input) -> Result(#(BasicElement, Input), String) {
  do_input_basic_element(input, default_basic_element())
}

/// For an alternate way of parsing a single element, see 
/// `test/examples/pubmed_article_set_test.input_element`.
/// 
fn do_input_basic_element(
  input: Input,
  basic_element: BasicElement,
) -> Result(#(BasicElement, Input), String) {
  case xmlm.signal(input) {
    Error(e) -> Error(xmlm.input_error_to_string(e))

    Ok(#(ElementStart(tag), input)) ->
      do_input_basic_element(input, BasicElement(..basic_element, tag: tag))

    Ok(#(Data(data), input)) ->
      do_input_basic_element(input, BasicElement(..basic_element, data: data))

    Ok(#(ElementEnd, input)) -> Ok(#(basic_element, input))

    Ok(#(Dtd(_), _)) -> Error("do_input_basic_element: unexpected Dtd")
  }
}

type Person {
  Person(first: Option(String), middle: Option(String), last: Option(String))
}

fn optional_string_to_string(s) {
  case s {
    None -> "()"
    Some(s) -> "(" <> string.inspect(s) <> ")"
  }
}

fn person_to_string(person: Person) -> String {
  "(person\n"
  <> " (first "
  <> optional_string_to_string(person.first)
  <> ")\n (middle "
  <> optional_string_to_string(person.middle)
  <> ")\n (last "
  <> optional_string_to_string(person.last)
  <> "))"
}

fn default_person() {
  Person(None, None, None)
}

/// `accept_dtd(input)` inputs the `Dtd` if it is the next `Signal`, or returns 
/// an error if any other `Signal` is encountered.
/// 
/// *Note!* `Dtd` signals don't have corresponding `ElementEnd` signals, so the 
/// caller need not address it. 
/// 
fn accept_dtd(input: Input) -> Result(Input, String) {
  case xmlm.signal(input) {
    Error(e) -> Error(xmlm.input_error_to_string(e))
    Ok(#(xmlm.Dtd(_), input)) -> Ok(input)
    Ok(#(signal, _)) ->
      Error(
        "parse error -- expected Dtd signal, found " <> string.inspect(signal),
      )
  }
}
