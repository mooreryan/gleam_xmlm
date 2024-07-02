import birdie
import gleam/dict
import gleam/list
import gleam/result
import gleam/string
import simplifile
import xmlm

pub fn circles_svg__test() {
  let assert Ok(data) = simplifile.read_bits("test/examples/circles.svg")

  let input =
    xmlm.from_bit_array(data)
    |> xmlm.with_stripping(True)
    |> xmlm.with_encoding(xmlm.Utf8)

  let assert Ok(#(svg, _input)) = input_svg_document(input)

  svg |> svg_to_string |> birdie.snap("circles_svg.circles_svg__test")
}

// For this example, we will assume that that are no other SVG elements or
// attributes we are interested in.
type Svg {
  Svg(List(Svg))
  Style(ty: String, data: String)
  Container(style: String, children: List(Svg))
  Circle(cx: String, cy: String, r: String, style: String)
}

/// Convert an `svg` to a string representation.
fn svg_to_string(svg: Svg) -> String {
  do_svg_to_string(svg, 0)
}

fn do_svg_to_string(svg: Svg, level: Int) -> String {
  let indent = string.pad_left("", to: level, with: "  ")
  case svg {
    Svg(svgs) ->
      indent
      <> "(svg\n"
      <> { list.map(svgs, do_svg_to_string(_, level + 1)) |> string.join("\n") }
      <> ")"
    Style(ty, data) ->
      indent
      <> "(style "
      <> string.inspect(ty)
      <> " "
      <> string.inspect(data)
      <> ")"
    Container(style, children) ->
      indent
      <> "(container "
      <> string.inspect(style)
      <> "\n"
      <> {
        list.map(children, do_svg_to_string(_, level + 1)) |> string.join("\n")
      }
      <> ")"
    Circle(cx, cy, r, style) -> {
      let data =
        [cx, cy, r, style] |> list.map(string.inspect) |> string.join(" ")
      indent <> "(circle " <> data <> ")"
    }
  }
}

fn input_svg_document(input: xmlm.Input) -> Result(#(Svg, xmlm.Input), String) {
  use input <- result.try(accept_dtd(input))
  input_svg(input)
}

// We are going to ignore the namespace in the SVG tag.
fn input_svg(input: xmlm.Input) -> Result(#(Svg, xmlm.Input), String) {
  case xmlm.signal(input) {
    Ok(#(
      xmlm.ElementStart(xmlm.Tag(
        // Note how we must account for the namespace here!
        xmlm.Name("http://www.w3.org/2000/svg", "svg"),
        attributes: _,
      )),
      input,
    )) -> {
      use #(style, input) <- result.try(input_style(input))
      use #(container, input) <- result.try(input_container(input))
      use input <- result.map(accept_element_end(input))
      #(Svg([style, container]), input)
    }
    Ok(#(signal, _)) ->
      Error(
        "expected ElementStart with tag 'svg', but got "
        <> string.inspect(signal),
      )
    Error(e) -> Error(xmlm.input_error_to_string(e))
  }
}

fn input_circle(input: xmlm.Input) -> Result(#(Svg, xmlm.Input), String) {
  // You could use `peek` if you needed to "backtrack" and recover from errors,
  // but we won't here.
  case xmlm.signal(input) {
    Ok(#(
      xmlm.ElementStart(xmlm.Tag(
        // Note how we must account for the namespace here!
        xmlm.Name("http://www.w3.org/2000/svg", "circle"),
        attributes,
      )),
      input,
    )) -> {
      let attributes =
        list.fold(attributes, dict.new(), fn(dict, attribute) {
          let xmlm.Name(_, name) = attribute.name
          dict.insert(dict, name, attribute.value)
        })

      // You might prefer a error handling strategy to report all errors rather
      // than only the first.
      use cx <- result.try(
        dict.get(attributes, "cx") |> result.replace_error("missing cx"),
      )
      use cy <- result.try(
        dict.get(attributes, "cy") |> result.replace_error("missing cy"),
      )
      use r <- result.try(
        dict.get(attributes, "r") |> result.replace_error("missing r"),
      )
      use style <- result.try(
        dict.get(attributes, "style") |> result.replace_error("missing style"),
      )

      let circle = Circle(cx: cx, cy: cy, r: r, style: style)

      use input <- result.map(accept_element_end(input))
      #(circle, input)
    }
    Ok(#(_, _)) -> Error("expected ElementStart with tag 'circle'")
    Error(e) -> Error(xmlm.input_error_to_string(e))
  }
}

fn input_circle_sequence(
  input: xmlm.Input,
) -> Result(#(List(Svg), xmlm.Input), String) {
  do_input_circle_sequence(input, [])
}

fn do_input_circle_sequence(
  input: xmlm.Input,
  circles: List(Svg),
) -> Result(#(List(Svg), xmlm.Input), String) {
  case xmlm.peek(input) {
    Ok(#(xmlm.ElementStart(_), input)) -> {
      // We will just let the `input_circle` function sort out any errors about
      // unexpected tags.
      case input_circle(input) {
        Error(e) -> Error(e)
        Ok(#(circle, input)) ->
          do_input_circle_sequence(input, [circle, ..circles])
      }
    }

    Ok(#(xmlm.ElementEnd, input)) -> {
      // The individual `input_circle` functions eat the circle's end tag, so
      // when you see an ElementEnd here, then that is end of the tag that
      // encloses the sequence, and so, it marks the end of the current
      // sequence.
      Ok(#(list.reverse(circles), input))
    }

    Ok(#(_, _)) -> Error("expected either ElementStart or ElementEnd")
    Error(e) -> Error(xmlm.input_error_to_string(e))
  }
}

fn input_container(input: xmlm.Input) -> Result(#(Svg, xmlm.Input), String) {
  case xmlm.signal(input) {
    Error(e) -> Error(xmlm.input_error_to_string(e))

    Ok(#(
      xmlm.ElementStart(xmlm.Tag(
        // Note how we must account for the namespace here!
        xmlm.Name("http://www.w3.org/2000/svg", "g"),
        attributes: [
          // Since there is only one expected attribute, we can pattern match to
          // get it.
          //
          // Note that the namespace does NOT apply to attributes automatically.
          xmlm.Attribute(xmlm.Name("", "style"), style_value),
        ],
      )),
      input,
    )) -> {
      use #(circles, input) <- result.try(input_circle_sequence(input))
      use input <- result.map(accept_element_end(input))
      #(Container(style_value, circles), input)
    }

    Ok(#(signal, _)) ->
      Error(
        "expected ElementStart with local name 'g', but got "
        <> xmlm.signal_to_string(signal),
      )
  }
}

fn input_style(input: xmlm.Input) -> Result(#(Svg, xmlm.Input), String) {
  case xmlm.signal(input) {
    Ok(#(
      xmlm.ElementStart(xmlm.Tag(
        // Note how we must account for the namespace here!
        xmlm.Name("http://www.w3.org/2000/svg", "style"),
        attributes: // But not on the attribute!
        [xmlm.Attribute(xmlm.Name("", "type"), style_type)],
      )),
      input,
    )) -> {
      use #(data, input) <- result.try(input_data(input))
      use input <- result.map(accept_element_end(input))
      #(Style(ty: style_type, data: data), input)
    }
    Error(e) -> Error(xmlm.input_error_to_string(e))
    Ok(#(signal, _)) ->
      Error(
        "expected ElementStart with local name 'style', but got "
        <> xmlm.signal_to_string(signal),
      )
  }
}

fn input_data(input: xmlm.Input) -> Result(#(String, xmlm.Input), String) {
  case xmlm.signal(input) {
    Ok(#(xmlm.Data(data), input)) -> Ok(#(data, input))
    Error(e) -> Error(xmlm.input_error_to_string(e))
    Ok(_) -> Error("expected Data signal")
  }
}

// You could imagine writing an accept function that worked with a specified
// signal or tag, but for this example, we only need one to accept the Dtd.
fn accept_dtd(input: xmlm.Input) -> Result(xmlm.Input, String) {
  case xmlm.signal(input) {
    Ok(#(xmlm.Dtd(_), input)) -> Ok(input)
    Ok(#(_, _)) -> Error("expected Dtd signal")
    Error(e) -> Error(xmlm.input_error_to_string(e))
  }
}

fn accept_element_end(input: xmlm.Input) -> Result(xmlm.Input, String) {
  case xmlm.signal(input) {
    Ok(#(xmlm.ElementEnd, input)) -> Ok(input)
    Ok(#(_, _)) -> Error("expected ElementEnd signal")
    Error(e) -> Error(xmlm.input_error_to_string(e))
  }
}
