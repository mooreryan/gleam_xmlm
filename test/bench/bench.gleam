import birl.{type Time}
import birl/duration
import gleam/float
import gleam/int
import gleam/io
import gleam/list

fn now() {
  birl.now()
}

fn time_it(prev_timestamp: Time) -> #(Time, Int) {
  let timestamp = now()

  let duration =
    birl.difference(timestamp, prev_timestamp)
    |> duration.blur_to(duration.MicroSecond)

  #(timestamp, duration)
}

fn do_run(
  msg: String,
  i: Int,
  ts: Time,
  f: fn() -> a,
  durations: List(Int),
) -> List(Int) {
  case i >= 0 {
    True -> {
      let _ = f()
      let #(ts, duration) = time_it(ts)
      do_run(msg, i - 1, ts, f, [duration, ..durations])
    }
    False -> list.reverse(durations)
  }
}

pub fn run(
  msg msg: String,
  times times: Int,
  burn burn: Int,
  f f: fn() -> a,
) -> Nil {
  let durations = do_run(msg, times, now(), f, []) |> list.drop(burn)

  durations
  |> list.each(fn(duration) {
    io.println_error(msg <> "|" <> int.to_string(duration))
  })

  io.println_error(
    "# mean " <> msg <> " : " <> float.to_string(mean(durations)),
  )

  Nil
}

fn mean(l: List(Int)) -> Float {
  int.to_float(list.fold(l, 0, fn(a, b) { a + b }))
  /. int.to_float(list.length(l))
}
