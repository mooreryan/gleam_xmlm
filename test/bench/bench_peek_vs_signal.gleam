import argv
import bench/bench
import simplifile
import xmlm

@target(erlang)
const times = 500

@target(erlang)
const burn = 250

@target(javascript)
const times = 200

@target(javascript)
const burn = 100

const bench_function_iterations = 10_000

pub fn main() {
  // The size of the file shouldn't effect the results of this test.
  let assert [filename] = argv.load().arguments
  let assert Ok(xml) = simplifile.read(filename)

  let input = xmlm.from_string(xml) |> xmlm.with_encoding(xmlm.Utf8)

  // Eat the first Dtd
  let assert Ok(#(xmlm.Dtd(_), input)) = xmlm.signal(input)

  fn() { peek_then_signal(input) }
  |> bench.run(msg: "peek_then_signal_1", times: times, burn: burn)

  fn() { peek_only(input) }
  |> bench.run(msg: "peek_only_1", times: times, burn: burn)

  fn() { signal_only(input) }
  |> bench.run(msg: "signal_only_1", times: times, burn: burn)

  fn() { peek_then_signal(input) }
  |> bench.run(msg: "peek_then_signal_2", times: times, burn: burn)

  fn() { peek_only(input) }
  |> bench.run(msg: "peek_only_2", times: times, burn: burn)

  fn() { signal_only(input) }
  |> bench.run(msg: "signal_only_2", times: times, burn: burn)
}

fn peek_then_signal(input) {
  do_peek_then_signal(input, bench_function_iterations)
}

fn do_peek_then_signal(input, i) {
  case i <= 0 {
    True -> Nil
    False -> {
      case xmlm.peek(input) {
        Error(_) -> Nil
        Ok(#(xmlm.Dtd(_), _)) -> Nil
        Ok(#(xmlm.ElementStart(_), input)) -> {
          // Simulate signaling, like you may do in real code.
          let _ = xmlm.signal(input)
          Nil
        }
        Ok(#(xmlm.ElementEnd, _)) -> Nil
        Ok(#(xmlm.Data(_), _)) -> Nil
      }

      do_peek_then_signal(input, i - 1)
    }
  }
}

fn peek_only(input) {
  do_peek_only(input, bench_function_iterations)
}

fn do_peek_only(input, i) {
  case i <= 0 {
    True -> Nil
    False -> {
      case xmlm.peek(input) {
        Error(_) -> Nil
        Ok(#(xmlm.Dtd(_), _)) -> Nil
        Ok(#(xmlm.ElementStart(_), _)) -> Nil
        Ok(#(xmlm.ElementEnd, _)) -> Nil
        Ok(#(xmlm.Data(_), _)) -> Nil
      }

      do_peek_only(input, i - 1)
    }
  }
}

fn signal_only(input) {
  do_signal_only(input, bench_function_iterations)
}

fn do_signal_only(input, i) {
  case i <= 0 {
    True -> Nil
    False -> {
      case xmlm.signal(input) {
        Error(_) -> Nil
        Ok(#(xmlm.Dtd(_), _)) -> Nil
        Ok(#(xmlm.ElementStart(_), _)) -> Nil
        Ok(#(xmlm.ElementEnd, _)) -> Nil
        Ok(#(xmlm.Data(_), _)) -> Nil
      }

      do_signal_only(input, i - 1)
    }
  }
}
