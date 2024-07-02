import argv
import bench/bench
import gleam/bit_array
import gleam/io
import gleam/list
import gleam/string
import simplifile
import xmlm

@target(erlang)
const times = 50

@target(erlang)
const burn = 10

@target(javascript)
const times = 10

@target(javascript)
const burn = 5

pub fn main() {
  let assert [filename] = argv.load().arguments
  let assert Ok(xml) = simplifile.read(filename)

  let input = xmlm.from_string(xml) |> xmlm.with_encoding(xmlm.UsAscii)

  let xml_bits = bit_array.from_string(xml)

  let xml_code_points =
    string.to_utf_codepoints(xml) |> list.map(string.utf_codepoint_to_int)

  {
    use <- bench.run("to_utf_codepoints", times: times, burn: burn)
    string.to_utf_codepoints(xml) |> list.map(string.utf_codepoint_to_int)
  }

  {
    use <- bench.run("iter_bits", times: times, burn: burn)
    iter_bits(xml_bits)
  }

  {
    use <- bench.run("iter_int_list", times: times, burn: burn)
    iter_int_list(xml_code_points)
  }

  {
    use <- bench.run("iter_graphemes", times: times, burn: burn)
    iter_grahpemes(xml)
  }

  {
    use <- bench.run("signals", times: times, burn: burn)
    xmlm.signals(input)
  }

  // yo

  io.println_error(
    "########################################################################### okay!",
  )
  io.println_error(
    "########################################################################### okay!",
  )
  io.println_error(
    "########################################################################### okay!",
  )

  {
    use <- bench.run("to_utf_codepoints", times: times, burn: burn)
    string.to_utf_codepoints(xml) |> list.map(string.utf_codepoint_to_int)
  }

  {
    use <- bench.run("iter_bits", times: times, burn: burn)
    iter_bits(xml_bits)
  }

  {
    use <- bench.run("iter_int_list", times: times, burn: burn)
    iter_int_list(xml_code_points)
  }

  {
    use <- bench.run("iter_graphemes", times: times, burn: burn)
    iter_grahpemes(xml)
  }

  {
    use <- bench.run("signals", times: times, burn: burn)
    xmlm.signals(input)
  }
}

fn iter_grahpemes(data: String) -> Nil {
  case string.pop_grapheme(data) {
    Ok(#(_, rest)) -> iter_grahpemes(rest)
    Error(Nil) -> Nil
  }
}

fn iter_bits(data: BitArray) {
  case data {
    <<_:size(8), rest:bytes>> -> iter_bits(rest)
    _ -> Nil
  }
}

fn iter_int_list(ints: List(Int)) {
  case ints {
    [] -> Nil
    [_, ..ints] -> iter_int_list(ints)
  }
}
