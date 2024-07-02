import argv
import bench/bench
import simplifile
import xmlm

@target(erlang)
const times = 200

@target(erlang)
const burn = 100

@target(javascript)
const times = 50

@target(javascript)
const burn = 10

pub fn main() {
  let assert [filename] = argv.load().arguments
  let assert Ok(xml) = simplifile.read(filename)

  let input = xmlm.from_string(xml) |> xmlm.with_encoding(xmlm.Utf8)

  fn() { xmlm.signals(input) }
  |> bench.run(msg: "xmlm.signals", times: times, burn: burn)

  fn() { count_start_signals(input) }
  |> bench.run(msg: "count_start_signals", times: times, burn: burn)
}

fn count_start_signals(input) {
  xmlm.fold_signals(input, 0, fn(count, signal) {
    case signal {
      xmlm.ElementStart(_) -> count + 1
      _ -> count
    }
  })
}
