import birdie
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import simplifile
import xmlm

pub fn websites__test() {
  let assert Ok(data) = simplifile.read_bits("test/examples/websites.xml")

  let input =
    xmlm.from_bit_array(data)
    |> xmlm.with_stripping(True)
    |> xmlm.with_encoding(xmlm.Utf8)

  let assert Ok(#(websites, _input)) = input_website_document(input)

  websites |> websites_to_string |> birdie.snap("websites.websites__test")
}

fn input_website_document(
  input: xmlm.Input,
) -> Result(#(List(Website), xmlm.Input), String) {
  use input <- result.try(accept(input, xmlm.Dtd(None)))
  input_websites(input)
}

// =============================================================================
// Category
// =============================================================================

type Category {
  Education
  Information
  Programming
  Other
}

fn category_to_string(category: Category) -> String {
  let category = case category {
    Education -> "education"
    Information -> "information"
    Programming -> "programming"
    Other -> "other"
  }

  "(category " <> category <> ")"
}

fn new_category(category: String) -> Category {
  case category {
    "Education" -> Education
    "Information" -> Information
    "Programming" -> Programming
    _ -> Other
  }
}

// =============================================================================
// Review
// =============================================================================

type Review {
  Review(rating: Int, comment: String)
}

fn review_to_string(review: Review, level: Int) -> String {
  indent(level)
  <> "(review (rating "
  <> int.to_string(review.rating)
  <> ") (comment "
  <> string.inspect(review.comment)
  <> "))"
}

fn new_review(rating: Int, comment: String) -> Result(Review, String) {
  case rating {
    n if 1 <= n && n <= 5 -> Ok(Review(n, comment))
    _ -> Error("rating must be between 1 and 5")
  }
}

fn input_review(input: xmlm.Input) -> Result(#(Review, xmlm.Input), String) {
  use input <- result.try(accept(input, xmlm.ElementStart(tag("review"))))
  use #(rating, input) <- result.try(input_element(input, "rating"))
  use rating <- result.try(
    int.parse(rating) |> result.replace_error("int.parse failed"),
  )
  use #(comment, input) <- result.try(input_element(input, "comment"))
  use input <- result.try(accept(input, xmlm.ElementEnd))
  use review <- result.try(new_review(rating, comment))
  Ok(#(review, input))
}

fn input_reviews(
  input: xmlm.Input,
) -> Result(#(List(Review), xmlm.Input), String) {
  use #(signal, input) <- result.try(
    xmlm.peek(input) |> result.map_error(xmlm.input_error_to_string),
  )

  case signal {
    xmlm.ElementStart(xmlm.Tag(xmlm.Name("", "reviews"), attributes: [])) -> {
      use input <- result.try(accept(input, xmlm.ElementStart(tag("reviews"))))
      use #(reviews, input) <- result.try(input_sequence(input, input_review))
      use input <- result.map(accept(input, xmlm.ElementEnd))
      #(reviews, input)
    }
    _ -> Ok(#([], input))
  }
}

// =============================================================================
// Website
// =============================================================================

type Website {
  Website(
    url: String,
    name: String,
    category: Category,
    description: Option(String),
    reviews: List(Review),
  )
}

fn website_to_string(website: Website, level: Int) -> String {
  let url_to_string = fn(url) { "(url " <> string.inspect(url) <> ")" }
  let name_to_string = fn(name) { "(name " <> string.inspect(name) <> ")" }
  let description_to_string = fn(description) {
    case description {
      None -> "(description ())"
      Some(desc) -> "(description (" <> string.inspect(desc) <> "))"
    }
  }
  let reviews_to_string = fn(reviews) {
    case reviews {
      [] -> "(reviews ())"
      _ ->
        "(reviews\n"
        <> list.map(reviews, review_to_string(_, level + 2))
        |> string.join("\n")
        <> ")"
    }
  }
  case website {
    Website(url, name, category, description, reviews) ->
      indent(level)
      <> "(website\n"
      <> indent(level + 1)
      <> url_to_string(url)
      <> "\n"
      <> indent(level + 1)
      <> name_to_string(name)
      <> "\n"
      <> indent(level + 1)
      <> category_to_string(category)
      <> "\n"
      <> indent(level + 1)
      <> description_to_string(description)
      <> "\n"
      <> indent(level + 1)
      <> reviews_to_string(reviews)
      <> ")"
  }
}

fn websites_to_string(websites: List(Website)) -> String {
  "(websites\n"
  <> { list.map(websites, website_to_string(_, 1)) |> string.join("\n") }
  <> ")"
}

fn input_website(input: xmlm.Input) -> Result(#(Website, xmlm.Input), String) {
  use input <- result.try(accept(input, xmlm.ElementStart(tag("website"))))
  use #(url, input) <- result.try(input_element(input, "url"))
  use #(name, input) <- result.try(input_element(input, "name"))
  use #(category, input) <- result.try(input_element(input, "category"))
  use #(description, input) <- result.try(input_optional_element(
    input,
    "description",
  ))
  use #(reviews, input) <- result.try(input_reviews(input))
  use input <- result.map(accept(input, xmlm.ElementEnd))

  let website =
    Website(
      url: url,
      name: name,
      category: new_category(category),
      description: description,
      reviews: reviews,
    )

  #(website, input)
}

fn input_websites(
  input: xmlm.Input,
) -> Result(#(List(Website), xmlm.Input), String) {
  use input <- result.try(accept(input, xmlm.ElementStart(tag("websites"))))
  use #(websites, input) <- result.try(input_sequence(input, input_website))
  use input <- result.map(accept(input, xmlm.ElementEnd))
  #(websites, input)
}

// =============================================================================
// xmlm utilities
// =============================================================================

fn tag(name: String) -> xmlm.Tag {
  xmlm.Tag(xmlm.Name("", name), attributes: [])
}

/// Accept a given signal and move on or return an error.
fn accept(
  input: xmlm.Input,
  expected_signal: xmlm.Signal,
) -> Result(xmlm.Input, String) {
  use #(signal, input) <- result.try(
    xmlm.signal(input) |> result.map_error(xmlm.input_error_to_string),
  )
  case signal == expected_signal {
    True -> Ok(input)
    False ->
      Error(
        "parse error -- expected "
        <> string.inspect(expected_signal)
        <> ", found "
        <> string.inspect(signal),
      )
  }
}

fn input_element(
  input: xmlm.Input,
  name: String,
) -> Result(#(String, xmlm.Input), String) {
  use input <- result.try(accept(input, xmlm.ElementStart(tag(name))))

  use #(signal, input) <- result.try(
    xmlm.peek(input) |> result.map_error(xmlm.input_error_to_string),
  )

  use #(data, input) <- result.try(case signal {
    xmlm.Data(data) -> {
      use #(_, input) <- result.try(
        xmlm.signal(input) |> result.map_error(xmlm.input_error_to_string),
      )
      Ok(#(data, input))
    }
    xmlm.ElementEnd -> Ok(#("", input))
    _ -> Error("parse error")
  })

  use input <- result.map(accept(input, xmlm.ElementEnd))
  #(data, input)
}

fn input_optional_element(
  input: xmlm.Input,
  name: String,
) -> Result(#(Option(String), xmlm.Input), String) {
  use #(signal, input) <- result.try(
    xmlm.peek(input) |> result.map_error(xmlm.input_error_to_string),
  )
  case signal {
    xmlm.ElementStart(xmlm.Tag(xmlm.Name("", found_name), attributes: []))
      if found_name == name
    -> {
      use #(data, input) <- result.map(input_element(input, name))
      #(Some(data), input)
    }
    _ -> Ok(#(None, input))
  }
}

fn input_sequence(
  input: xmlm.Input,
  element_callback: fn(xmlm.Input) -> Result(#(a, xmlm.Input), String),
) -> Result(#(List(a), xmlm.Input), String) {
  do_input_sequence(input, element_callback, [])
}

// We don't use `use` or the other callbacks here as we don't want to overflow
// the stack on the JavaScript target.
fn do_input_sequence(
  input: xmlm.Input,
  element_callback: fn(xmlm.Input) -> Result(#(a, xmlm.Input), String),
  acc: List(a),
) -> Result(#(List(a), xmlm.Input), String) {
  case xmlm.peek(input) {
    Error(e) -> Error(xmlm.input_error_to_string(e))
    Ok(#(xmlm.ElementStart(_), input)) -> {
      case element_callback(input) {
        Error(e) -> Error(e)
        Ok(#(a, input)) ->
          do_input_sequence(input, element_callback, [a, ..acc])
      }
    }
    Ok(#(xmlm.ElementEnd, input)) -> Ok(#(list.reverse(acc), input))
    Ok(#(_, _)) -> Error("expected either ElementStart or ElementEnd")
  }
}

fn indent(level: Int) -> String {
  string.pad_start("", to: level, with: "  ")
}
