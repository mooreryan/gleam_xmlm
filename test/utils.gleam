import gleam/string

pub fn ok_exn(result: Result(a, b)) -> a {
  case result {
    Ok(x) -> x
    Error(x) -> panic as { "ERROR: " <> string.inspect(x) }
  }
}

pub fn err_exn(result: Result(a, b)) -> b {
  case result {
    Ok(x) -> panic as { "OK: " <> string.inspect(x) }
    Error(x) -> x
  }
}

pub fn ignore(_: a) -> Nil {
  Nil
}
