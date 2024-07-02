import gleam/pair
import gleam/result
import gleeunit/should
import simplifile
import xmlm

pub fn count_start_tags__test() {
  let assert Ok(xml) = simplifile.read_bits("test/examples/circles.svg")

  xmlm.from_bit_array(xml)
  |> xmlm.fold_signals(0, fn(count, signal) {
    case signal {
      xmlm.ElementStart(_) -> count + 1
      xmlm.Dtd(_) | xmlm.ElementEnd | xmlm.Data(_) -> count
    }
  })
  |> result.map(pair.first)
  |> should.equal(Ok(6))
}
