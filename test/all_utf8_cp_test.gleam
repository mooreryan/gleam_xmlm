import gleam/bit_array
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleeunit/should
import simplifile
import utils.{ignore, ok_exn}
import xmlm

pub fn uchar_utf8__test() {
  let n = 54_620
  let assert Ok(cp) = string.utf_codepoint(n)
  string.from_utf_codepoints([cp])
  |> bit_array.from_string
  |> xmlm.input_stream_from_bit_array
  |> xmlm.uchar_utf8
  |> should.equal(Ok(#(n, [])))

  let assert Ok(#(n, _)) = xmlm.uchar_utf8([237, 149, 156])
  should.equal(n, 54_620)

  let assert Ok(#(n, _)) = xmlm.uchar_utf8([0xED, 0x95, 0x9C])
  should.equal(n, 54_620)
}

pub fn uchar_utf8_multiple_unicode_chars__test() {
  let bita = [0x00, 0x7E, 0xC2, 0x84, 0xC2, 0x8A]

  let assert Ok(#(n, bita)) = xmlm.uchar_utf8(bita)
  should.equal(n, 0)

  let assert Ok(#(n, bita)) = xmlm.uchar_utf8(bita)
  should.equal(n, 126)

  let assert Ok(#(n, bita)) = xmlm.uchar_utf8(bita)
  should.equal(n, 132)

  let assert Ok(#(n, bita)) = xmlm.uchar_utf8(bita)
  should.equal(n, 138)

  let assert Error(xmlm.UnicodeLexerEoi) = xmlm.uchar_utf8(bita)

  let assert Error(xmlm.UnicodeLexerEoi) = xmlm.uchar_utf8(bita)

  Nil
}

type ParseResult {
  ParseOk
  ParseError
}

fn parse_result_new(parse_result: String) -> Result(ParseResult, String) {
  case parse_result {
    "ok" -> Ok(ParseOk)
    "error" -> Ok(ParseError)
    _ -> Error("Imopossible")
  }
}

fn read_lines(file: String) -> List(String) {
  simplifile.read(file)
  |> ok_exn
  |> string.split(on: "\n")
}

fn do_all_cp_check(filename: String) {
  let lines = read_lines(filename)

  use line <- list.each(lines)

  case string.split(line, on: "\t") {
    [dec_number, parse_result, hex_number] -> {
      let result = {
        use dec_number <- result.try(
          int.parse(dec_number)
          |> result.replace_error("int.parse failed: " <> dec_number),
        )

        use parse_result <- result.try(parse_result_new(parse_result))

        use hex_number <- result.try(
          bit_array.base16_decode(hex_number)
          |> result.replace_error(
            "bit_array.base16_decode failed: " <> hex_number,
          ),
        )

        Ok(#(dec_number, parse_result, hex_number))
      }

      case result {
        Ok(#(dec_number, ParseOk, hex_number)) -> {
          let expected = Ok(#(dec_number, []))
          xmlm.uchar_utf8(xmlm.input_stream_from_bit_array(hex_number))
          |> should.equal(expected)
          |> ignore
        }
        Ok(#(_, ParseError, hex_number)) ->
          xmlm.uchar_utf8(xmlm.input_stream_from_bit_array(hex_number))
          |> should.equal(Error(xmlm.UnicodeLexerMalformed))
        Error(msg) ->
          panic as { "something bad happened in the test file: " <> msg }
      }
    }
    _ -> Nil
  }
}

// Test generators do not work on the javascript target, so just write them all
// out.
//
// These are broken up into small parts so they don't time out on Erlang (and
// run in parallel), but also so they don't separate implemntations for JS and
// Erlang (i.e., using generators for Erlang and normal tests for JS).

pub fn two_million_ints_00__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.00.tsv")
}

pub fn two_million_ints_01__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.01.tsv")
}

pub fn two_million_ints_02__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.02.tsv")
}

pub fn two_million_ints_03__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.03.tsv")
}

pub fn two_million_ints_04__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.04.tsv")
}

pub fn two_million_ints_05__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.05.tsv")
}

pub fn two_million_ints_06__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.06.tsv")
}

pub fn two_million_ints_07__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.07.tsv")
}

pub fn two_million_ints_08__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.08.tsv")
}

pub fn two_million_ints_09__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.09.tsv")
}

pub fn two_million_ints_10__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.10.tsv")
}

pub fn two_million_ints_11__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.11.tsv")
}

pub fn two_million_ints_12__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.12.tsv")
}

pub fn two_million_ints_13__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.13.tsv")
}

pub fn two_million_ints_14__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.14.tsv")
}

pub fn two_million_ints_15__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.15.tsv")
}

pub fn two_million_ints_16__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.16.tsv")
}

pub fn two_million_ints_17__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.17.tsv")
}

pub fn two_million_ints_18__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.18.tsv")
}

pub fn two_million_ints_19__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.19.tsv")
}

pub fn two_million_ints_20__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.20.tsv")
}

pub fn two_million_ints_21__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.21.tsv")
}

pub fn two_million_ints_22__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.22.tsv")
}

pub fn two_million_ints_23__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.23.tsv")
}

pub fn two_million_ints_24__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.24.tsv")
}

pub fn two_million_ints_25__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.25.tsv")
}

pub fn two_million_ints_26__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.26.tsv")
}

pub fn two_million_ints_27__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.27.tsv")
}

pub fn two_million_ints_28__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.28.tsv")
}

pub fn two_million_ints_29__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.29.tsv")
}

pub fn two_million_ints_30__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.30.tsv")
}

pub fn two_million_ints_31__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.31.tsv")
}

pub fn two_million_ints_32__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.32.tsv")
}

pub fn two_million_ints_33__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.33.tsv")
}

pub fn two_million_ints_34__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.34.tsv")
}

pub fn two_million_ints_35__test() {
  do_all_cp_check("test/test_files/utf8/0_to_2_million.35.tsv")
}
