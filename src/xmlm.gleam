//// These docs are a work in progress.  Until they are more complete, check out
//// some of the full examples located in the `test/examples` directory.
//// 
//// *Note!*  Don't forget to work with the `Input` that is returned by any 
//// "inputting" function rather than the original.
//// 
//// Note! If something is marked as being "unspecified", do not depend on it.  
//// It may change at any time without a major version bump.
////

import gleam/bit_array
import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

/// NodeJS Number.MAX_SAFE_INTEGER (ocaml has it as max_int)
const u_eoi = 9_007_199_254_740_991

const u_start_doc = 9_007_199_254_740_990

const u_end_doc = 9_007_199_254_740_989

/// newline 
const u_nl: Int = 0x000A

/// carriage return 
const u_cr: Int = 0x000D

/// space 
const u_space: Int = 0x0020

/// quote 
const u_quot: Int = 0x0022

/// # 
const u_sharp: Int = 0x0023

/// & 
const u_amp: Int = 0x0026

/// ' 
const u_apos: Int = 0x0027

/// - 
const u_minus: Int = 0x002D

/// / 
const u_slash: Int = 0x002F

/// : 
const u_colon: Int = 0x003A

/// ; 
const u_scolon: Int = 0x003B

/// < 
const u_lt: Int = 0x003C

///: Int = 
const u_eq: Int = 0x003D

/// > 
const u_gt: Int = 0x003E

/// ? 
const u_qmark: Int = 0x003F

/// ! 
const u_emark: Int = 0x0021

/// [ 
const u_lbrack: Int = 0x005B

/// ] 
const u_rbrack: Int = 0x005D

/// x 
const u_x: Int = 0x0078

/// BOM 
const u_bom: Int = 0xFEFF

/// 9 
const u_9: Int = 0x0039

/// F 
const u_cap_f: Int = 0x0046

/// D 
const u_cap_d: Int = 0x0044

const s_cdata: String = "CDATA["

const ns_xml: String = "http://www.w3.org/XML/1998/namespace"

const ns_xmlns: String = "http://www.w3.org/2000/xmlns/"

const n_xml: String = "xml"

const n_xmlns: String = "xmlns"

const n_space: String = "space"

const n_version: String = "version"

const n_encoding: String = "encoding"

const n_standalone: String = "standalone"

const v_yes: String = "yes"

const v_no: String = "no"

const v_preserve: String = "preserve"

const v_default: String = "default"

const v_version_1_0: String = "1.0"

const v_version_1_1: String = "1.1"

const v_utf_8: String = "utf-8"

const v_utf_16: String = "utf-16"

const v_utf_16be: String = "utf-16be"

const v_utf_16le: String = "utf-16le"

const v_iso_8859_1: String = "iso-8859-1"

const v_iso_8859_15: String = "iso-8859-15"

const v_us_ascii: String = "us-ascii"

const v_ascii: String = "ascii"

// =============================================================================
// Unicode character lexers 
// =============================================================================

@internal
pub type UnicodeLexerError {
  UnicodeLexerEoi
  UnicodeLexerMalformed
}

fn make_input_uchar(
  uchar_lexer: fn(InputStream) -> Result(#(Int, InputStream), UnicodeLexerError),
) -> fn(Input) -> Result(#(Int, Input), InputError) {
  fn(input: Input) {
    case uchar_lexer(input.stream) {
      Error(e) ->
        Error(input_error_new(
          input,
          internal_input_error_from_unicode_lexer_error(e),
        ))
      Ok(#(uchar, bit_array)) -> {
        let input = Input(..input, stream: bit_array)
        Ok(#(uchar, input))
      }
    }
  }
}

/// Gets the next uchar byte advancing any needed internal state.
fn input_uchar_byte() -> fn(Input) -> Result(#(Int, Input), InputError) {
  make_input_uchar(uchar_byte)
}

fn uchar_byte(
  bit_array: InputStream,
) -> Result(#(Int, InputStream), UnicodeLexerError) {
  case bit_array {
    [byte, ..rest] -> Ok(#(byte, rest))
    [] -> Error(UnicodeLexerEoi)
  }
}

fn input_uchar_iso_8859_1() -> fn(Input) -> Result(#(Int, Input), InputError) {
  make_input_uchar(uchar_iso_8859_1)
}

fn uchar_iso_8859_1(
  bit_array: InputStream,
) -> Result(#(Int, InputStream), UnicodeLexerError) {
  case bit_array {
    [byte, ..rest] -> Ok(#(byte, rest))
    [] -> Error(UnicodeLexerEoi)
  }
}

fn input_uchar_iso_8859_15() -> fn(Input) -> Result(#(Int, Input), InputError) {
  make_input_uchar(uchar_iso_8859_15)
}

// https://www.iana.org/assignments/charset-reg/ISO-8859-15
fn uchar_iso_8859_15(
  bit_array: InputStream,
) -> Result(#(Int, InputStream), UnicodeLexerError) {
  case bit_array {
    // € 
    [0x00A4, ..rest] -> Ok(#(0x20AC, rest))
    // Š 
    [0x00A6, ..rest] -> Ok(#(0x0160, rest))
    // š 
    [0x00A8, ..rest] -> Ok(#(0x0161, rest))
    // Ž 
    [0x00B4, ..rest] -> Ok(#(0x017D, rest))
    // ž 
    [0x00B8, ..rest] -> Ok(#(0x017E, rest))
    // Œ 
    [0x00BC, ..rest] -> Ok(#(0x0152, rest))
    // œ 
    [0x00BD, ..rest] -> Ok(#(0x0153, rest))
    // Ÿ 
    [0x00BE, ..rest] -> Ok(#(0x0178, rest))
    // Other 
    [char, ..rest] -> Ok(#(char, rest))
    // Empty stream
    [] -> Error(UnicodeLexerEoi)
  }
}

fn input_uchar_utf8() -> fn(Input) -> Result(#(Int, Input), InputError) {
  make_input_uchar(uchar_utf8)
}

@internal
pub fn uchar_utf8(bit_array: InputStream) -> Result(
  #(Int, InputStream),
  UnicodeLexerError,
) {
  case bit_array {
    [byte0, ..bit_array] -> {
      case utf8_length(byte0) {
        0 -> Error(UnicodeLexerMalformed)
        1 -> Ok(#(byte0, bit_array))
        2 -> do_uchar_utf8_len2(bit_array, byte0)
        3 -> do_uchar_utf8_len3(bit_array, byte0)
        4 -> do_uchar_utf8_len4(bit_array, byte0)
        _ -> panic as "unreachable"
      }
    }
    [] -> Error(UnicodeLexerEoi)
  }
}

fn do_uchar_utf8_len2(
  bit_array: InputStream,
  byte0: Int,
) -> Result(#(Int, InputStream), UnicodeLexerError) {
  case bit_array {
    [byte1, ..bit_array] -> {
      case byte1 |> most_significant_bytes_are_not_10 {
        True -> Error(UnicodeLexerMalformed)
        False -> {
          let result =
            int.bitwise_and(byte0, 0x1F)
            |> int.bitwise_shift_left(6)
            |> int.bitwise_or(int.bitwise_and(byte1, 0x3F))

          Ok(#(result, bit_array))
        }
      }
    }
    [] -> Error(UnicodeLexerEoi)
  }
}

fn do_uchar_utf8_len3(
  bit_array: InputStream,
  byte0: Int,
) -> Result(#(Int, InputStream), UnicodeLexerError) {
  case bit_array {
    [byte1, byte2, ..bit_array] -> {
      case byte2 |> most_significant_bytes_are_not_10 {
        True -> Error(UnicodeLexerMalformed)
        False -> {
          case byte0 == 0xE0 && { byte1 < 0xA0 || 0xBF < byte1 } {
            True -> Error(UnicodeLexerMalformed)
            False -> {
              case byte0 == 0xED && { byte1 < 0x80 || 0x9F < byte1 } {
                True -> Error(UnicodeLexerMalformed)
                False -> {
                  case byte1 |> most_significant_bytes_are_not_10 {
                    True -> Error(UnicodeLexerMalformed)
                    False -> {
                      let b0 =
                        byte0
                        |> int.bitwise_and(0x0F)
                        |> int.bitwise_shift_left(12)
                      let b1 =
                        byte1
                        |> int.bitwise_and(0x3F)
                        |> int.bitwise_shift_left(6)
                      let b2 = byte2 |> int.bitwise_and(0x3F)

                      let result =
                        b0 |> int.bitwise_or(b1) |> int.bitwise_or(b2)

                      Ok(#(result, bit_array))
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    [] -> Error(UnicodeLexerEoi)
    _ -> Error(UnicodeLexerMalformed)
  }
}

fn do_uchar_utf8_len4(
  bit_array: InputStream,
  byte0: Int,
) -> Result(#(Int, InputStream), UnicodeLexerError) {
  case bit_array {
    [byte1, byte2, byte3, ..bit_array] -> {
      case
        most_significant_bytes_are_not_10(byte3)
        || most_significant_bytes_are_not_10(byte2)
      {
        True -> Error(UnicodeLexerMalformed)
        False -> {
          case byte0 == 0xF0 && { byte1 < 0x90 || 0xBF < byte1 } {
            True -> Error(UnicodeLexerMalformed)
            False -> {
              case byte0 == 0xF4 && { byte1 < 0x80 || 0x8F < byte1 } {
                True -> Error(UnicodeLexerMalformed)
                False -> {
                  case byte1 |> most_significant_bytes_are_not_10 {
                    True -> Error(UnicodeLexerMalformed)
                    False -> {
                      let b0 =
                        byte0
                        |> int.bitwise_and(0x07)
                        |> int.bitwise_shift_left(18)
                      let b1 =
                        byte1
                        |> int.bitwise_and(0x3F)
                        |> int.bitwise_shift_left(12)
                      let b2 =
                        byte2
                        |> int.bitwise_and(0x3F)
                        |> int.bitwise_shift_left(6)
                      let b3 = byte3 |> int.bitwise_and(0x3F)

                      let result =
                        b0
                        |> int.bitwise_or(b1)
                        |> int.bitwise_or(b2)
                        |> int.bitwise_or(b3)

                      Ok(#(result, bit_array))
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    [] -> Error(UnicodeLexerEoi)
    _ -> Error(UnicodeLexerMalformed)
  }
}

/// Are the most significant bits of an 8 bit int NOT `10`?
fn most_significant_bytes_are_not_10(n: Int) -> Bool {
  // this is being used instead of this OCaml code `if b1 lsr 6 != 0b10 then
  // raise Malformed else ()`, since gleam doens't offer the logical shift right
  //
  // NOTE: we could probably use the arithmetic shift as we would only be using
  // positive numbers--might be worth switching.

  int.bitwise_and(n, 0b11000000) != 0b10000000
}

/// A length of 0 indicates failure.
fn utf8_length(unsigned_char: Int) -> Int {
  case unsigned_char {
    n if 0 <= n && n <= 127 -> 1
    n if 128 <= n && n <= 193 -> 0
    n if 194 <= n && n <= 223 -> 2
    n if 224 <= n && n <= 239 -> 3
    n if 240 <= n && n <= 244 -> 4
    _ -> 0
  }
}

fn int16_be(
  stream: InputStream,
) -> Result(#(Int, InputStream), UnicodeLexerError) {
  case stream {
    [byte0, byte1, ..stream] -> {
      let char = byte0 |> int.bitwise_shift_left(8) |> int.bitwise_or(byte1)
      Ok(#(char, stream))
    }
    [] -> Error(UnicodeLexerEoi)
    _ -> Error(UnicodeLexerMalformed)
  }
}

fn int16_le(
  stream: InputStream,
) -> Result(#(Int, InputStream), UnicodeLexerError) {
  case stream {
    [byte0, byte1, ..stream] -> {
      let char = byte1 |> int.bitwise_shift_left(8) |> int.bitwise_or(byte0)
      Ok(#(char, stream))
    }
    [] -> Error(UnicodeLexerEoi)
    _ -> Error(UnicodeLexerMalformed)
  }
}

fn uchar_utf16(
  int16,
) -> fn(InputStream) -> Result(#(Int, InputStream), UnicodeLexerError) {
  fn(stream) {
    case int16(stream) {
      Error(e) -> Error(e)
      Ok(#(char0, stream)) -> {
        case char0 {
          char0 if char0 < 0xD800 || char0 > 0xDFFF -> Ok(#(char0, stream))
          char0 if char0 > 0xDBFF -> Error(UnicodeLexerMalformed)
          char0 -> {
            case int16(stream) {
              Error(e) -> Error(e)
              Ok(#(char1, stream)) -> {
                let char =
                  int.bitwise_or(
                    int.bitwise_shift_left(int.bitwise_and(char0, 0x3FF), 10),
                    int.bitwise_and(char1, 0x3FF),
                  )
                  + 0x10000

                Ok(#(char, stream))
              }
            }
          }
        }
      }
    }
  }
}

fn input_uchar_utf16be() -> fn(Input) -> Result(#(Int, Input), InputError) {
  make_input_uchar(uchar_utf16(int16_be))
}

fn input_uchar_utf16le() -> fn(Input) -> Result(#(Int, Input), InputError) {
  make_input_uchar(uchar_utf16(int16_le))
}

fn input_uchar_ascii() -> fn(Input) -> Result(#(Int, Input), InputError) {
  make_input_uchar(uchar_ascii)
}

fn uchar_ascii(
  bit_array: InputStream,
) -> Result(#(Int, InputStream), UnicodeLexerError) {
  case bit_array {
    [byte, ..rest] if byte <= 127 -> Ok(#(byte, rest))
    [] -> Error(UnicodeLexerEoi)
    _ -> Error(UnicodeLexerMalformed)
  }
}

// =============================================================================
// Basic types and values 
// =============================================================================

/// The type for character encodings
/// 
pub type Encoding {
  Utf8

  /// UTF-16 endianness is determined from the
  /// [BOM](https://www.unicode.org/faq/utf_bom.html#BOM).
  /// 
  Utf16

  /// UTF-16 big-endian
  /// 
  Utf16Be

  /// UTF-16 big-endian
  /// 
  Utf16Le

  Iso8859x1
  Iso8859x15
  UsAscii
}

/// Type for names of attribute and elements.  An empty `uri` represents a
/// name without a namespace, i.e., an unprefixed name that is not under the 
/// scope of a default namespace.
/// 
pub type Name {
  Name(
    // NOTE! Internally the URI is actually still a prefix for much of the code
    // until it is mapped.

    /// The URI of the `Name`.  
    /// 
    /// Note that this likely* will not be the literal value of the prefix 
    /// string before the `:`.  E.g.,
    /// 
    /// ```xml
    /// <a xmlns:snazzy="https://www.example.com/snazzy">
    ///   <snazzy:b />
    /// </a>
    /// ```
    /// 
    /// The `b` tag would look something like this:
    /// 
    /// ```gleam
    /// Tag(
    ///   name: Name(uri: "https://www.example.com/snazzy", local: "b"), 
    ///   attributes: []
    /// )
    /// ```
    /// 
    /// Note how the `uri` is not `"snazzy"`, but 
    /// `"https://www.example.com/snazzy"`.
    /// 
    /// *I say "likely", because you could define a `namespace_callback` that 
    /// maps URIs to themselves rather than a URI.
    /// 
    uri: String,
    /// The non-prefixed (i.e., `local`) part of the `Name`.
    /// 
    local: String,
  )
}

/// Convert `name` into an unspecified string representation.
/// 
pub fn name_to_string(name: Name) -> String {
  let Name(uri, local) = name
  case uri {
    "" -> string.inspect(local)
    uri -> string.inspect(uri <> ":" <> local)
  }
}

/// Type for attributes.
/// 
/// ## Example
/// 
/// In following XML fragment `<fruit color="green">`, the attribute 
/// `color="green"` would look like this: 
/// 
/// ```gleam
/// Attribute(name: Name(uri: "", local: "color"), value: "green")
/// ```
/// 
pub type Attribute {
  Attribute(
    /// The `name` of the `Attribute`
    name: Name,
    /// The `value` of the `Attribute`
    value: String,
  )
}

/// Convert `attribute` into an unspecified string representation.
/// 
pub fn attribute_to_string(attribute: Attribute) -> String {
  "Attribute(name: "
  <> name_to_string(attribute.name)
  <> ", value: "
  <> string.inspect(attribute.value)
  <> ")"
}

/// Convert `attributes` into an unspecified string representation.
/// 
pub fn attributes_to_string(attributes: List(Attribute)) -> String {
  case attributes {
    [] -> "[]"
    attributes ->
      "[" <> string.join(list.map(attributes, attribute_to_string), ", ") <> "]"
  }
}

/// The type for an element tag.
/// 
pub type Tag {
  Tag(
    /// Name of the tag
    /// 
    name: Name,
    /// Attribute list of the tag
    /// 
    attributes: List(Attribute),
  )
}

/// Convert `tag` into an unspecified string representation.
/// 
pub fn tag_to_string(tag: Tag) -> String {
  "Tag(name: "
  <> name_to_string(tag.name)
  <> ", attributes: "
  <> attributes_to_string(tag.attributes)
  <> ")"
}

/// The type for signals
/// 
/// A well-formed sequence of signals belongs to the language of the document 
/// grammar:
/// 
/// ```
/// document := Dtd tree ;
/// tree     := ElementStart child ElementEnd ;
/// child    := ( Data trees ) | trees ;
/// trees    := ( tree child ) | epsilon ;
/// ```
/// 
/// Note the `trees` production` which expresses the fact there there will never 
/// be two consecutive `Data` signals in the children of an element.
/// 
/// The `Input` type and functions that work with it deal only with well-formed 
/// signal sequences, else `Errors` are returned.
/// 
pub type Signal {
  Dtd(Option(String))
  ElementStart(Tag)
  ElementEnd
  Data(String)
}

/// Convert `signal` into an unspecified string representation.
/// 
pub fn signal_to_string(signal: Signal) -> String {
  case signal {
    Dtd(Some(data)) -> "Dtd(" <> data <> ")"
    Dtd(None) -> "Dtd(None)"
    ElementStart(tag) -> "ElementStart(" <> tag_to_string(tag) <> ")"
    ElementEnd -> "ElementEnd"
    Data(data) -> "Data(" <> string.inspect(data) <> ")"
  }
}

/// Convert `signals` into an unspecified string representation.
/// 
pub fn signals_to_string(signals: List(Signal)) -> String {
  string.join(list.map(signals, signal_to_string), "\n")
}

fn signal_start_stream() {
  Data("")
}

// =============================================================================
// Input
// =============================================================================

/// The type for error positions
/// 
type Position {
  Position(line: Int, column: Int)
}

/// Convert `position` into an unspecified string representation.
/// 
fn position_to_string(position: Position) -> String {
  "Position(line: "
  <> int.to_string(position.line)
  <> ", column: "
  <> int.to_string(position.column)
  <> ")"
}

type InternalInputError {
  ExpectedCharSeqs(expected: List(String), actual: String)
  ExpectedRootElement
  IllegalCharRef(String)
  IllegalCharSeq(String)
  MalformedCharStream
  MaxBufferSize
  UnexpectedEoi
  UnknownEncoding(String)
  UnknownEntityRef(String)
  UnknownNsPrefix(String)

  // New
  UnicodeLexerErrorEoi
  UnicodeLexerErrorMalformed
  InvalidArgument(String)
}

fn internal_input_error_from_unicode_lexer_error(
  unicode_lexer_error: UnicodeLexerError,
) -> InternalInputError {
  case unicode_lexer_error {
    UnicodeLexerEoi -> UnicodeLexerErrorEoi
    UnicodeLexerMalformed -> UnicodeLexerErrorMalformed
  }
}

fn internal_error_message(input_error: InternalInputError) -> String {
  let bracket = fn(l, v, r) { l <> v <> r }

  case input_error {
    ExpectedCharSeqs(expected, actual) -> {
      let expected =
        list.fold(expected, "", fn(acc, v) { acc <> bracket("\"", v, "\", ") })

      "expected one of these character sequence: "
      <> expected
      <> "found \""
      <> actual
      <> "\""
    }
    ExpectedRootElement -> "expected root element"
    IllegalCharRef(msg) -> bracket("illegal character reference (#", msg, ")")
    IllegalCharSeq(msg) ->
      bracket("character sequence illegal here (\"", msg, "\")")
    MalformedCharStream -> "malformed character stream"
    MaxBufferSize -> "maximal buffer size exceeded"
    UnexpectedEoi -> "unexpected end of input"
    UnknownEncoding(msg) -> bracket("unknown encoding (", msg, ")")
    UnknownEntityRef(msg) -> bracket("unknown entity reference (", msg, ")")
    UnknownNsPrefix(msg) -> bracket("unknown namespace prefix (", msg, ")")

    // New 
    UnicodeLexerErrorEoi -> "unicode lexer error eoi"
    UnicodeLexerErrorMalformed -> "unicode lexer error malformed"
    InvalidArgument(msg) -> bracket("invalid argument (", msg, ")")
  }
}

// Note: this in an exception in the ocaml code
/// The type of error returned by any "inputing" functions.
/// 
pub opaque type InputError {
  InputError(Position, InternalInputError)
}

fn input_error_new(input: Input, input_error: InternalInputError) -> InputError {
  InputError(Position(line: input.line, column: input.column), input_error)
}

/// Converts the `input_error` into a non-specified human readable format.
/// 
pub fn input_error_to_string(input_error: InputError) -> String {
  let InputError(position, input_error) = input_error
  "ERROR "
  <> position_to_string(position)
  <> " "
  <> internal_error_message(input_error)
}

/// Limits of "things" in the XML
type Limit {
  /// '<' qname
  LimitStartTag(Name)
  /// '</' qname whitespace*
  LimitEndTag(Name)
  /// '<?' qname (processing instruction)
  LimitPi(Name)
  /// '<!--'
  LimitComment
  /// '<![CDATA['
  LimitCData
  /// '<!'
  LimitDtd
  /// Other character
  LimitText
  /// End of input
  LimitEoi
}

/// Stores the XML data.
type InputStream =
  List(Int)

@external(erlang, "xmlm_ffi", "bit_array_to_list")
@external(javascript, "./xmlm_ffi.mjs", "bit_array_to_list")
@internal
pub fn input_stream_from_bit_array(bit_array: BitArray) -> List(Int)

/// The type for input abstractions.
/// 
pub opaque type Input {
  Input(
    /// Expected encoding
    encoding: Option(Encoding),
    /// Whitespace stripping default behaviour
    strip: Bool,
    /// Namespace callback.
    namespace_callback: fn(String) -> Option(String),
    /// Entity reference callback 
    entity_callback: fn(String) -> Option(String),
    /// Unicode character lexer
    uchar: fn(Input) -> Result(#(Int, Input), InputError),
    /// BitArray (this is the data "stream")
    stream: InputStream,
    /// Character lookahead (this is really a unicode codepoint)
    char: Int,
    /// True if last `u` was `\r`
    cr: Bool,
    /// Current line number
    line: Int,
    /// Current column number
    column: Int,
    /// Last parsed limit
    limit: Limit,
    /// Signal lookahead 
    peek: Signal,
    /// True if stripping whitespace
    stripping: Bool,
    /// True if last char was white 
    last_whitespace: Bool,
    /// Stack of qualified el. name, bound prefixes and strip behaviour
    scopes: List(#(Name, List(String), Bool)),
    /// prefix -> uri bindings
    ns: Dict(String, String),
    /// Buffer for names and entity refs
    identifier: Buffer,
    /// Buffer for character and attribute data
    data: Buffer,
  )
}

/// Convert `input` into an unspecified string representation.
/// 
pub fn input_to_string(input: Input) -> String {
  "Input(\n\tencoding: "
  <> string.inspect(input.encoding)
  <> "\n\tstrip: "
  <> string.inspect(input.strip)
  <> "\n\tbit_array: "
  <> string.inspect(input.stream)
  <> "\n\tchar: "
  <> string.inspect(input.char)
  <> "\n\tcr: "
  <> string.inspect(input.cr)
  <> "\n\tline: "
  <> string.inspect(input.line)
  <> "\n\tcolumn: "
  <> string.inspect(input.column)
  <> "\n\tlimit: "
  <> string.inspect(input.limit)
  <> "\n\tpeek: "
  <> string.inspect(input.peek)
  <> "\n\tstripping: "
  <> string.inspect(input.stripping)
  <> "\n\tlast_whitespace: "
  <> string.inspect(input.last_whitespace)
  <> "\n\tscopes: "
  <> string.inspect(input.scopes)
  <> "\n\tns: "
  <> string.inspect(input.ns)
  <> "\n\tidentifier: "
  <> string.inspect(input.identifier)
  <> "\n\tdata: "
  <> string.inspect(input.data)
  <> "\n)"
}

fn error(input: Input, err: InternalInputError) -> Result(a, InputError) {
  Error(InputError(Position(line: input.line, column: input.column), err))
}

fn error_illegal_char(input: Input, uchar: Int) -> Result(a, InputError) {
  error(input, IllegalCharSeq(string_from_char(uchar)))
}

fn error_expected_seqs(
  input: Input,
  expected: List(String),
  actual: String,
) -> Result(a, InputError) {
  error(input, ExpectedCharSeqs(expected, actual))
}

fn error_expected_chars(
  input: Input,
  expected: List(Int),
) -> Result(a, InputError) {
  let expected = list.map(expected, string_from_char)
  error(input, ExpectedCharSeqs(expected, string_from_char(input.char)))
}

/// `xmlm.from_string(source)` returns a new `Input` abstraction from the given
/// `source`.
/// 
pub fn from_string(source: String) -> Input {
  from_bit_array(bit_array.from_string(source))
}

/// `xmlm.from_bit_array(source)` returns a new `Input` abstraction from the 
/// given `source`.
/// 
pub fn from_bit_array(source: BitArray) -> Input {
  let bindings =
    dict.new()
    |> dict.insert("", "")
    |> dict.insert(n_xml, ns_xml)
    |> dict.insert(n_xmlns, ns_xmlns)

  Input(
    encoding: None,
    strip: False,
    namespace_callback: fn(_) { None },
    entity_callback: fn(_) { None },
    uchar: input_uchar_byte(),
    stream: input_stream_from_bit_array(source),
    char: u_start_doc,
    cr: False,
    line: 1,
    column: 0,
    limit: LimitText,
    peek: signal_start_stream(),
    stripping: False,
    last_whitespace: True,
    scopes: [],
    ns: bindings,
    identifier: [],
    data: [],
  )
}

/// xmlm.with_encoding(input) sets the `input` to use the given `encoding`.
/// 
pub fn with_encoding(input: Input, encoding: Encoding) -> Input {
  Input(..input, encoding: Some(encoding))
}

/// `xmlm.with_stripping(input, stripping)` sets the `input` to use the given
/// `stripping`.
/// 
pub fn with_stripping(input: Input, stripping: Bool) -> Input {
  Input(..input, stripping: stripping)
}

/// `xmlm.with_namespace_callback(input, namespace_callback)` sets the `input` 
/// to use the given `namespace_callback` to bind undeclared namespace prefixes.
/// 
/// ## Example
/// 
/// Imagine an XML document something like this, that specifies a namespace.
/// 
/// ```xml
/// <a xmlns:snazzy="https://www.example.com/snazzy">
///   <snazzy:b />
/// </a>
/// ```
/// 
/// This will parse Ok because the namespace is properly declared.  
/// 
/// However, the following XML document would give an error, telling you about 
/// the unknown namespace prefix `snazzy`.
/// 
/// ```xml
/// <a>
///   <snazzy:b />
/// </a>
/// ```
/// 
/// To address this, you may provide a function to bind undeclared namespace 
/// prefixes.
/// 
/// ```gleam
/// xmlm.from_string(xml_data)
/// |> xmlm.with_namespace_callback(fn(prefix) {
///   case prefix {
///     "snazzy" -> Some("https://www.example.com/snazzy")
///     _ -> None
///   }
/// })
/// ```
/// 
/// In this way, the `snazzy` prefix will be bound and no error will occur.
/// 
pub fn with_namespace_callback(
  input: Input,
  namespace_callback: fn(String) -> Option(String),
) -> Input {
  Input(..input, namespace_callback: namespace_callback)
}

/// `xmlm.with_entity_callback(input, namespace_callback)` sets the `input` to 
/// use the given `entity_callback` to resolve non-predefined entity references.
/// 
/// ## Example
/// 
/// Imagine an XML document that looks something like this:
/// 
/// ```xml
/// <p> &apple; &pie; </p>
/// ```
/// 
/// It has non-predifined entity references, and so when parsing, it will give 
/// an error.  To address this, we could use an entity callback function to 
/// resolve these references.
/// 
/// ```gleam
/// xmlm.from_string(xml_data)
/// |> xmlm.with_entity_callback(fn(entity_reference) {
///   case entity_reference {
///     "apple" -> Some("APPLE!")
///     "pie" -> Some("PIE!")
///     _ -> None
///   }
/// })
/// ```
/// 
/// With that entity callback, the parsed `Data` signal would look something 
/// like this:
/// 
/// ```gleam
/// Data("APPLE! PIE!")
/// ```
/// 
pub fn with_entity_callback(
  input: Input,
  entity_callback: fn(String) -> Option(String),
) -> Input {
  Input(..input, entity_callback: entity_callback)
}

fn input_identifier_to_string(input: Input) -> String {
  input.identifier |> buffer_to_string
}

fn input_data_to_string(input: Input) -> String {
  input.data |> buffer_to_string
}

/// Checks if `uchar` is in the inclusive range `[from, to]`.
fn is_in_range(uchar: Int, from low: Int, to high: Int) -> Bool {
  low <= uchar && uchar <= high
}

fn is_whitespace(int: Int) {
  case int {
    0x0020 | 0x0009 | 0x000D | 0x000A -> True
    _ -> False
  }
}

/// XML 1.0 non-terminal: {Char}
fn is_char(uchar: Int) {
  case uchar {
    uchar if 0x0020 <= uchar && uchar <= 0xD7FF -> True
    0x0009 | 0x000A | 0x000D -> True
    uchar if 0xE000 <= uchar && uchar <= 0xFFFD -> True
    uchar if 0x10000 <= uchar && uchar <= 0x10FFFF -> True
    _ -> False
  }
}

fn is_digit(uchar: Int) {
  uchar |> is_in_range(from: 0x0030, to: 0x0039)
}

fn is_hex_digit(uchar: Int) {
  is_in_range(uchar, from: 0x0030, to: 0x0039)
  || is_in_range(uchar, from: 0x0041, to: 0x0046)
  || is_in_range(uchar, from: 0x0061, to: 0x0066)
}

// common to functions below
fn is_common_range(uchar: Int) -> Bool {
  is_in_range(uchar, 0x00C0, 0x00D6)
  || is_in_range(uchar, from: 0x00D8, to: 0x00F6)
  || is_in_range(uchar, from: 0x00F8, to: 0x02FF)
  || is_in_range(uchar, from: 0x0370, to: 0x037D)
  || is_in_range(uchar, from: 0x037F, to: 0x1FFF)
  || is_in_range(uchar, from: 0x200C, to: 0x200D)
  || is_in_range(uchar, from: 0x2070, to: 0x218F)
  || is_in_range(uchar, from: 0x2C00, to: 0x2FEF)
  || is_in_range(uchar, from: 0x3001, to: 0xD7FF)
  || is_in_range(uchar, from: 0xF900, to: 0xFDCF)
  || is_in_range(uchar, from: 0xFDF0, to: 0xFFFD)
  || is_in_range(uchar, from: 0x10000, to: 0xEFFFF)
}

/// XML 1.1 non-terminal: {NameStartChar} - ':'
fn is_name_start_char(uchar: Int) -> Bool {
  // Note: the original has an explicit check for not being whitespace
  !is_whitespace(uchar)
  && {
    // [a-z]
    is_in_range(uchar, from: 0x0061, to: 0x007A)
    // [A-Z]
    || is_in_range(uchar, from: 0x0041, to: 0x005A)
    // '_'
    || uchar == 0x005F
    // common range
    || is_common_range(uchar)
  }
}

/// XML 1.1 non-terminal: {NameChar} - ':'
fn is_name_char(uchar: Int) -> Bool {
  !is_whitespace(uchar)
  && {
    // [a-z]
    is_in_range(uchar, from: 0x0061, to: 0x007A)
    // [A-Z]
    || is_in_range(uchar, from: 0x0041, to: 0x005A)
    // [0-9]
    || is_in_range(uchar, from: 0x0030, to: 0x0039)
    // '_' 
    || uchar == 0x005F
    // '-' 
    || uchar == 0x002D
    // '.'
    || uchar == 0x002E
    // middle dot
    || uchar == 0x00B7
    // common range 
    || is_common_range(uchar)
    || is_in_range(uchar, from: 0x0300, to: 0x036F)
    || is_in_range(uchar, from: 0x203F, to: 0x2040)
  }
}

fn next_char(input: Input) -> Result(Input, InputError) {
  case input.char == u_eoi {
    True -> error(input, UnexpectedEoi)
    False -> {
      let input = case input.char == u_nl {
        True -> Input(..input, line: input.line + 1, column: 1)
        False -> Input(..input, column: input.column + 1)
      }

      case input.uchar(input) {
        Error(e) -> Error(e)
        Ok(#(char, input)) -> {
          let input = Input(..input, char: char)

          case !is_char(input.char) {
            True -> error(input, MalformedCharStream)
            False -> {
              let input = case input.cr && input.char == u_nl {
                False -> Ok(input)
                True -> {
                  case input.uchar(input) {
                    Error(e) -> Error(e)
                    Ok(#(char, input)) -> Ok(Input(..input, char: char))
                  }
                }
              }

              case input {
                Error(e) -> Error(e)
                Ok(input) -> {
                  let input = case input.char == u_cr {
                    True -> Input(..input, cr: True, char: u_nl)
                    False -> Input(..input, cr: False)
                  }
                  Ok(input)
                }
              }
            }
          }
        }
      }
    }
  }
}

fn next_char_eof(input: Input) -> Result(Input, InputError) {
  case next_char(input) {
    // NOTE: original catches End_of_file like this:   
    //   let nextc_eof i = try nextc i with End_of_file -> i.c <- u_eoi
    Error(InputError(_, UnicodeLexerErrorEoi)) ->
      Ok(Input(..input, char: u_eoi))
    Error(_) as e -> e
    Ok(input) -> Ok(input)
  }
}

fn skip_whitespace(input: Input) -> Result(Input, InputError) {
  case !is_whitespace(input.char) {
    True -> Ok(input)
    False -> {
      case next_char(input) {
        Error(e) -> Error(e)
        Ok(input) -> skip_whitespace(input)
      }
    }
  }
}

fn skip_whitespace_eof(input: Input) -> Result(Input, InputError) {
  case is_whitespace(input.char) {
    True -> {
      case next_char_eof(input) {
        Error(e) -> Error(e)
        Ok(input) -> skip_whitespace_eof(input)
      }
    }
    False -> Ok(input)
  }
}

fn accept(input: Input, char: Int) -> Result(Input, InputError) {
  case input.char == char {
    True -> next_char(input)
    False -> error_expected_chars(input, [char])
  }
}

fn clear_identifier(input: Input) -> Input {
  Input(..input, identifier: buffer_clear(input.identifier))
}

fn clear_data(input: Input) -> Input {
  Input(..input, data: buffer_clear(input.data))
}

fn add_char_to_identifier(input: Input, char: Int) -> Input {
  Input(..input, identifier: buffer_add_uchar(input.identifier, char))
}

fn add_char_to_data(input: Input, char: Int) -> Input {
  Input(..input, data: buffer_add_uchar(input.data, char))
}

fn add_char_to_data_strip(input: Input, char: Int) -> Input {
  case is_whitespace(char) {
    True -> Input(..input, last_whitespace: True)
    False -> {
      let input = case input.last_whitespace, input.data {
        _, [] | False, _ -> input
        True, _ -> add_char_to_data(input, u_space)
      }

      let input = Input(..input, last_whitespace: False)

      add_char_to_data(input, char)
    }
  }
}

fn expand_name(input: Input, name: Name) -> Result(Name, InputError) {
  // Here the uri field is still a prefix--that's why we need to map it.
  let Name(prefix, local) = name

  let external_ = fn(prefix) {
    case input.namespace_callback(prefix) {
      None -> error(input, UnknownNsPrefix(prefix))
      Some(uri) -> Ok(uri)
    }
  }

  case dict.get(input.ns, prefix) {
    Ok(uri) -> {
      case !string.is_empty(uri) {
        True -> Ok(Name(uri, local))
        False -> {
          case string.is_empty(prefix) {
            True -> Ok(Name("", local))
            False -> {
              case external_(prefix) {
                Ok(uri) -> Ok(Name(uri, local))
                Error(msg) -> Error(msg)
              }
            }
          }
        }
      }
    }
    Error(Nil) ->
      case external_(prefix) {
        Ok(uri) -> Ok(Name(uri, local))
        Error(msg) -> Error(msg)
      }
  }
}

/// An XML Name, minus the colon (`:`)
/// 
/// XML Namespace 1.1 non-terminal: {NCName}
/// https://www.w3.org/TR/2006/REC-xml-names11-20060816/#NT-NCName
fn parse_ncname(input: Input) -> Result(#(String, Input), InputError) {
  let input = clear_identifier(input)

  case !is_name_start_char(input.char) {
    True -> error_illegal_char(input, input.char)
    False -> {
      let input = add_char_to_identifier(input, input.char)
      case next_char(input) {
        Error(e) -> Error(e)
        Ok(input) -> {
          case parse_ncname__loop(input) {
            Error(e) -> Error(e)
            Ok(input) -> {
              let name = input_identifier_to_string(input)
              Ok(#(name, input))
            }
          }
        }
      }
    }
  }
}

fn parse_ncname__loop(input: Input) {
  case is_name_char(input.char) {
    False -> Ok(input)
    True -> {
      let input = add_char_to_identifier(input, input.char)

      case next_char(input) {
        Error(e) -> Error(e)
        Ok(input) -> parse_ncname__loop(input)
      }
    }
  }
}

/// Qualified name
/// XML Namespace 1.1 non-terminal: {QName}
/// https://www.w3.org/TR/2006/REC-xml-names11-20060816/#NT-QName
fn parse_qname(input: Input) -> Result(#(Name, Input), InputError) {
  case parse_ncname(input) {
    Error(e) -> Error(e)
    Ok(#(name, input)) -> {
      case input.char != u_colon {
        True -> Ok(#(Name("", name), input))
        False -> {
          case next_char(input) {
            Error(e) -> Error(e)
            Ok(input) -> {
              case parse_ncname(input) {
                Error(e) -> Error(e)
                Ok(#(local_name, input)) -> Ok(#(Name(name, local_name), input))
              }
            }
          }
        }
      }
    }
  }
}

/// XML 1.0 non-terminal: {Reference}
fn parse_reference(input: Input) -> Result(#(String, Input), InputError) {
  case next_char(input) {
    Error(e) -> Error(e)
    Ok(input) -> {
      case input.char == u_sharp {
        True -> parse_char_reference(input)
        False -> parse_entity_reference(input, predefined_entities())
      }
    }
  }
}

type LoopDone {
  LoopDoneExited(#(Int, Input))
  LoopDoneByCondition(#(Int, Input))
}

/// XML 1.0 non-terminal: {CharRef}, '&' was eaten.
fn parse_char_reference(input: Input) -> Result(#(String, Input), InputError) {
  let input = clear_identifier(input)
  case next_char(input) {
    Error(e) -> Error(e)
    Ok(input) -> {
      case input.char == u_scolon {
        True -> error(input, IllegalCharRef(""))
        False -> {
          let result = case input.char == u_x {
            False -> parse_char_reference__loop2(input, 0)
            True -> {
              let input = add_char_to_identifier(input, input.char)
              case next_char(input) {
                Error(e) -> Error(e)
                Ok(input) -> {
                  parse_char_reference__loop1(input, 0)
                }
              }
            }
          }

          case result {
            Error(e) -> Error(e)
            Ok(intermediate_result) -> {
              let tup = {
                case intermediate_result {
                  LoopDoneByCondition(#(c, input)) -> Ok(#(c, input))
                  LoopDoneExited(#(_, input)) -> {
                    case parse_char_reference__loop3(input) {
                      Error(e) -> Error(e)
                      Ok(input) -> Ok(#(-1, input))
                    }
                  }
                }
              }

              case tup {
                Error(e) -> Error(e)
                Ok(#(c, input)) -> {
                  case next_char(input) {
                    Error(e) -> Error(e)
                    Ok(input) -> {
                      case is_char(c) {
                        True -> {
                          let input = clear_identifier(input)
                          let input = add_char_to_identifier(input, c)
                          Ok(#(buffer_to_string(input.identifier), input))
                        }
                        False ->
                          error(
                            input,
                            IllegalCharRef(buffer_to_string(input.identifier)),
                          )
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

fn parse_char_reference__loop1(
  input: Input,
  c: Int,
) -> Result(LoopDone, InputError) {
  case input.char == u_scolon {
    True -> Ok(LoopDoneByCondition(#(c, input)))
    False -> {
      let input = add_char_to_identifier(input, input.char)
      case !is_hex_digit(input.char) {
        True -> Ok(LoopDoneExited(#(c, input)))
        False -> {
          let c = {
            c
            * 16
            + {
              case input.char <= u_9 {
                True -> input.char - 48
                False ->
                  case input.char <= u_cap_f {
                    True -> input.char - 55
                    False -> input.char - 87
                  }
              }
            }
          }
          case next_char(input) {
            Error(e) -> Error(e)
            Ok(input) -> parse_char_reference__loop1(input, c)
          }
        }
      }
    }
  }
}

fn parse_char_reference__loop2(
  input: Input,
  c: Int,
) -> Result(LoopDone, InputError) {
  case input.char == u_scolon {
    True -> Ok(LoopDoneByCondition(#(c, input)))
    False -> {
      let input = add_char_to_identifier(input, input.char)
      case !is_digit(input.char) {
        True -> Ok(LoopDoneExited(#(c, input)))
        False -> {
          let c = c * 10 + { input.char - 48 }
          case next_char(input) {
            Error(e) -> Error(e)
            Ok(input) -> parse_char_reference__loop2(input, c)
          }
        }
      }
    }
  }
}

fn parse_char_reference__loop3(input: Input) -> Result(Input, InputError) {
  case input.char == u_scolon {
    True -> Ok(input)
    False -> {
      let input = add_char_to_identifier(input, input.char)
      case next_char(input) {
        Error(e) -> Error(e)
        Ok(input) -> parse_char_reference__loop3(input)
      }
    }
  }
}

fn predefined_entities() -> Dict(String, String) {
  dict.new()
  |> dict.insert("lt", "<")
  |> dict.insert("gt", ">")
  |> dict.insert("amp", "&")
  |> dict.insert("apos", "'")
  |> dict.insert("quot", "\"")
}

/// XML 1.0 non-terminal: {EntityRef}, '&' was eaten.
fn parse_entity_reference(
  input: Input,
  predefined_entities: Dict(String, String),
) -> _ {
  case parse_ncname(input) {
    Error(e) -> Error(e)
    Ok(#(entity, input)) -> {
      case accept(input, u_scolon) {
        Error(e) -> Error(e)
        Ok(input) -> {
          case dict.get(predefined_entities, entity) {
            Ok(replacement) -> Ok(#(replacement, input))
            Error(Nil) ->
              case input.entity_callback(entity) {
                Some(replacement) -> Ok(#(replacement, input))
                None -> error(input, UnknownEntityRef(entity))
              }
          }
        }
      }
    }
  }
}

/// XML 1.0 non-terminals: {S}* {AttValue}
fn parse_attribute_value(input: Input) -> Result(#(String, Input), InputError) {
  use input <- result.try(skip_whitespace(input))

  use <- bool.lazy_guard(
    when: !{ input.char == u_quot || input.char == u_apos },
    return: fn() { error_expected_chars(input, [u_quot, u_apos]) },
  )

  let delim = input.char

  use input <- result.try(next_char(input))

  use input <- result.try(skip_whitespace(input))

  let input = clear_data(input)

  let input = Input(..input, last_whitespace: True)

  use input <- result.try(parse_attribute_value__loop(input, delim))

  use input <- result.try(next_char(input))

  let data = input_data_to_string(input)

  Ok(#(data, input))
}

fn parse_attribute_value__loop(
  input: Input,
  delim: Int,
) -> Result(Input, InputError) {
  case input.char {
    char if char == delim -> Ok(input)
    char if char == u_lt -> error_illegal_char(input, u_lt)
    char if char == u_amp -> {
      // String.iter (addc_data_strip i) (p_reference i).
      case parse_reference(input) {
        Error(e) -> Error(e)
        Ok(#(reference, input)) -> {
          // TODO: going back and forth from string to int list could be fixed
          let input =
            string.to_utf_codepoints(reference)
            |> list.fold(input, fn(input, char) {
              add_char_to_data_strip(input, string.utf_codepoint_to_int(char))
            })
          parse_attribute_value__loop(input, delim)
        }
      }
    }
    _ -> {
      let input = add_char_to_data_strip(input, input.char)

      case next_char(input) {
        Error(e) -> Error(e)
        Ok(input) -> parse_attribute_value__loop(input, delim)
      }
    }
  }
}

/// Returns a list of bound prefixes and attributes
///
/// XML 1.0 non-terminals:  ({S} {Attribute})* {S}?
/// 
/// TODO: currently returns the attributes in reverse 
fn parse_attributes(
  input: Input,
) -> Result(#(List(String), List(Attribute), Input), InputError) {
  parse_attributes__loop(input, [], [])
}

fn parse_attributes__loop(
  input: Input,
  pre_acc: List(String),
  acc: List(Attribute),
) -> Result(#(List(String), List(Attribute), Input), InputError) {
  case is_whitespace(input.char) {
    False -> Ok(#(pre_acc, acc, input))
    True -> {
      case skip_whitespace(input) {
        Error(e) -> Error(e)
        Ok(input) -> {
          case input.char {
            char if char == u_slash || input.char == u_gt ->
              Ok(#(pre_acc, acc, input))
            _ -> {
              parse_attributes__loop__handle_qname_and_value(
                input,
                pre_acc,
                acc,
              )
            }
          }
        }
      }
    }
  }
}

fn parse_attributes__loop__handle_qname_and_value(
  input: Input,
  pre_acc: List(String),
  acc: List(Attribute),
) -> Result(#(List(String), List(Attribute), Input), InputError) {
  case parse_qname(input) {
    Error(e) -> Error(e)
    Ok(#(Name(prefix, local) as name, input)) -> {
      case skip_whitespace(input) {
        Error(e) -> Error(e)
        Ok(input) -> {
          case accept(input, u_eq) {
            Error(e) -> Error(e)
            Ok(input) -> {
              case parse_attribute_value(input) {
                Error(e) -> Error(e)
                Ok(#(attribute_value, input)) -> {
                  let attribute = Attribute(name, value: attribute_value)

                  case string.is_empty(prefix) && { local == n_xmlns } {
                    True -> {
                      // xmlns 
                      let ns = dict.insert(input.ns, "", attribute_value)
                      let input = Input(..input, ns: ns)
                      parse_attributes__loop(input, ["", ..pre_acc], [
                        attribute,
                        ..acc
                      ])
                    }
                    False -> {
                      case prefix == n_xmlns {
                        True -> {
                          // xmlns:local 
                          let ns = dict.insert(input.ns, local, attribute_value)
                          let input = Input(..input, ns: ns)
                          parse_attributes__loop(input, [local, ..pre_acc], [
                            attribute,
                            ..acc
                          ])
                        }
                        False -> {
                          let input =
                            maybe_update_stripping(
                              input,
                              attribute_value: attribute_value,
                              prefix: prefix,
                              local: local,
                            )

                          parse_attributes__loop(input, pre_acc, [
                            attribute,
                            ..acc
                          ])
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

fn maybe_update_stripping(
  input: Input,
  attribute_value attribute_value: String,
  prefix prefix: String,
  local local: String,
) {
  case prefix == n_xml && local == n_space {
    True -> {
      // xml:space
      // ...we may need to change the stripping value!
      case attribute_value {
        attr_val if attr_val == v_preserve -> Input(..input, stripping: False)
        attr_val if attr_val == v_default ->
          Input(..input, stripping: input.strip)
        _ -> input
      }
    }
    False -> input
  }
}

/// Parses a markup limit.
fn parse_limit(input: Input) -> Result(Input, InputError) {
  let result = case input.char == u_eoi {
    True -> Ok(#(LimitEoi, input))
    False -> {
      case input.char != u_lt {
        True -> Ok(#(LimitText, input))
        False -> {
          case next_char(input) {
            Error(e) -> Error(e)
            Ok(input) -> {
              case input.char {
                char if char == u_qmark -> parse_limit__pi(input)
                char if char == u_slash -> parse_limit__end_tag(input)
                char if char == u_emark -> {
                  case next_char(input) {
                    Error(e) -> Error(e)
                    Ok(input) -> {
                      let _ = case input.char {
                        char if char == u_minus -> parse_limit__comment(input)
                        char if char == u_cap_d -> Ok(#(LimitDtd, input))
                        char if char == u_lbrack -> parse_limit__cdata(input)
                        _ -> {
                          error(
                            input,
                            IllegalCharSeq("<!" <> string_from_char(input.char)),
                          )
                        }
                      }
                    }
                  }
                }
                _ -> parse_limit__start_tag(input)
              }
            }
          }
        }
      }
    }
  }

  case result {
    Error(e) -> Error(e)
    Ok(#(limit, input)) -> Ok(Input(..input, limit: limit))
  }
}

fn parse_limit__pi(input: Input) -> Result(#(Limit, Input), InputError) {
  case next_char(input) {
    Error(e) -> Error(e)
    Ok(input) -> {
      case parse_qname(input) {
        Error(e) -> Error(e)
        Ok(#(name, input)) -> Ok(#(LimitPi(name), input))
      }
    }
  }
}

fn parse_limit__end_tag(input: Input) -> Result(#(Limit, Input), InputError) {
  case next_char(input) {
    Error(e) -> Error(e)
    Ok(input) -> {
      case parse_qname(input) {
        Error(e) -> Error(e)
        Ok(#(name, input)) -> {
          case skip_whitespace(input) {
            Error(e) -> Error(e)
            Ok(input) -> Ok(#(LimitEndTag(name), input))
          }
        }
      }
    }
  }
}

fn parse_limit__comment(input: Input) -> Result(#(Limit, Input), InputError) {
  case next_char(input) {
    Error(e) -> Error(e)
    Ok(input) -> {
      case accept(input, u_minus) {
        Error(e) -> Error(e)
        Ok(input) -> {
          Ok(#(LimitComment, input))
        }
      }
    }
  }
}

fn parse_limit__cdata(input: Input) -> Result(#(Limit, Input), InputError) {
  case next_char(input) {
    Error(e) -> Error(e)
    Ok(input) -> {
      let input = clear_identifier(input)

      // Eat the `CDATA[` markup
      case eat_cdata_lbrack(input) {
        Error(e) -> Error(e)
        Ok(input) -> {
          let cdata = input_identifier_to_string(input)

          case cdata == s_cdata {
            True -> Ok(#(LimitCData, input))
            False -> error_expected_seqs(input, [s_cdata], cdata)
          }
        }
      }
    }
  }
}

fn eat_cdata_lbrack(input: Input) {
  let input = add_char_to_identifier(input, input.char)
  use input <- result.try(next_char(input))
  let input = add_char_to_identifier(input, input.char)
  use input <- result.try(next_char(input))
  let input = add_char_to_identifier(input, input.char)
  use input <- result.try(next_char(input))
  let input = add_char_to_identifier(input, input.char)
  use input <- result.try(next_char(input))
  let input = add_char_to_identifier(input, input.char)
  use input <- result.try(next_char(input))
  let input = add_char_to_identifier(input, input.char)
  next_char(input)
}

fn parse_limit__start_tag(input: Input) -> Result(#(Limit, Input), InputError) {
  case parse_qname(input) {
    Error(e) -> Error(e)
    Ok(#(name, input)) -> Ok(#(LimitStartTag(name), input))
  }
}

/// XML 1.0 non-terminal: {Comment}, '<!--' was eaten
fn skip_comment(input: Input) -> Result(Input, InputError) {
  case skip_comment__loop(input) {
    Error(e) -> Error(e)
    Ok(input) -> {
      case next_char(input) {
        Error(e) -> Error(e)
        Ok(input) -> {
          case input.char != u_minus {
            True -> skip_comment(input)
            False -> {
              case next_char(input) {
                Error(e) -> Error(e)
                Ok(input) -> {
                  case input.char != u_gt {
                    True -> error_expected_chars(input, [u_gt])
                    False -> next_char_eof(input)
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

fn skip_comment__loop(input: Input) -> Result(Input, InputError) {
  case input.char != u_minus {
    True ->
      case next_char(input) {
        Error(e) -> Error(e)
        Ok(input) -> skip_comment__loop(input)
      }
    False -> Ok(input)
  }
}

/// XML 1.0 non-terminal: {PI}, '<?' qname was eaten
fn skip_pi(input: Input) -> Result(Input, InputError) {
  case skip_pi__loop(input) {
    Error(e) -> Error(e)
    Ok(input) -> {
      case next_char(input) {
        Error(e) -> Error(e)
        Ok(input) -> {
          case input.char != u_gt {
            True -> skip_pi(input)
            False -> next_char_eof(input)
          }
        }
      }
    }
  }
}

fn skip_pi__loop(input: Input) -> Result(Input, InputError) {
  case input.char != u_qmark {
    True ->
      case next_char(input) {
        Ok(input) -> skip_pi__loop(input)
        Error(_) as e -> e
      }
    False -> Ok(input)
  }
}

/// XML 1.0 non-terminal: {Misc} 
fn skip_misc(
  input: Input,
  allow_xmlpi allow_xmlpi: Bool,
) -> Result(Input, InputError) {
  case input.limit {
    LimitPi(Name(prefix, local)) -> {
      case string.is_empty(prefix) && n_xml == string.lowercase(local) {
        True ->
          case allow_xmlpi {
            True -> Ok(input)
            False -> error(input, IllegalCharSeq(local))
          }
        False -> {
          case skip_pi_then_parse_limit(input) {
            Error(e) -> Error(e)
            Ok(input) -> skip_misc(input, allow_xmlpi)
          }
        }
      }
    }
    LimitComment -> {
      case skip_comment_then_parse_limit(input) {
        Error(e) -> Error(e)
        Ok(input) -> skip_misc(input, allow_xmlpi)
      }
    }
    LimitText ->
      case is_whitespace(input.char) {
        True -> {
          case skip_whitespace_eof_then_parse_limit(input) {
            Error(e) -> Error(e)
            Ok(input) -> skip_misc(input, allow_xmlpi)
          }
        }
        False -> Ok(input)
      }
    LimitCData | LimitDtd | LimitEndTag(_) | LimitEoi | LimitStartTag(_) ->
      Ok(input)
  }
}

/// XML 1.0 non-terminals: {CharData}* ({Reference}{Chardata})*
fn parse_chardata(
  input: Input,
  add_char: fn(Input, Int) -> Input,
) -> Result(Input, InputError) {
  // parse_chardata(input, add_char)
  case input.char == u_lt {
    True -> Ok(input)
    False -> {
      case input.char == u_amp {
        True -> parse_chardata__handle_reference(input, add_char)
        False -> {
          case input.char == u_rbrack {
            True -> parse_chardata__handle_rbrack(input, add_char)
            False -> parse_chardata__handle_non_rbrack(input, add_char)
          }
        }
      }
    }
  }
}

fn parse_chardata__handle_reference(
  input: Input,
  add_char: fn(Input, Int) -> Input,
) -> Result(Input, InputError) {
  // String.iter (addc i) (p_reference i) 
  case parse_reference(input) {
    Error(e) -> Error(e)
    Ok(#(reference, input)) -> {
      // TODO: would be better to not have to go back and forth for
      // this. Maybe do the parse_reference to return the buffer rather
      // than a string.
      let input =
        string.to_utf_codepoints(reference)
        |> list.fold(input, fn(input, char) {
          add_char(input, string.utf_codepoint_to_int(char))
        })

      parse_chardata(input, add_char)
    }
  }
}

fn parse_chardata__handle_non_rbrack(
  input: Input,
  add_char: fn(Input, Int) -> Input,
) -> Result(Input, InputError) {
  let input = add_char(input, input.char)

  case next_char(input) {
    Error(e) -> Error(e)
    Ok(input) -> {
      parse_chardata(input, add_char)
    }
  }
}

fn parse_chardata__handle_rbrack(
  input: Input,
  add_char: fn(Input, Int) -> Input,
) -> Result(Input, InputError) {
  // Now, input.char == u_rbrack

  // Eat a right bracket
  let input = add_char(input, input.char)
  case next_char(input) {
    Error(e) -> Error(e)
    Ok(input) -> {
      // If we don't see another rbracket, then done.
      case input.char != u_rbrack {
        True -> Ok(input)
        False -> {
          // If we do see another rbracket, then eat it.
          let input = add_char(input, input.char)
          case next_char(input) {
            Error(e) -> Error(e)
            Ok(input) -> {
              // Now, we need to eat any other right brackets that
              // directly follow the one we just ate, (with the goal of
              // detecting detects ']'*']]>'). Basically keep going
              // until you don't hit a right bracket. 
              case parse_chardata__loop(input, add_char) {
                Error(e) -> Error(e)
                Ok(input) -> {
                  // Finally, check for `>` which would make a `]]>` which
                  // is illegal here. 
                  case input.char == u_gt {
                    True -> error(input, IllegalCharSeq("]]>"))
                    False -> Ok(input)
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

fn parse_chardata__loop(input: Input, add_char) {
  case input.char == u_rbrack {
    False -> Ok(input)
    True -> {
      let input = add_char(input, input.char)
      case next_char(input) {
        Error(e) -> Error(e)
        Ok(input) -> parse_chardata__loop(input, add_char)
      }
    }
  }
}

/// XML 1.0 non-terminals: {CData} {CDEnd}
fn parse_cdata(
  input: Input,
  add_char: fn(Input, Int) -> Input,
) -> Result(Input, InputError) {
  parse_cdata__loop(input, add_char, Go)
}

type StopOrGo {
  Go
  Stop
}

fn parse_cdata__loop(
  input: Input,
  add_char: fn(Input, Int) -> Input,
  stop_or_go: StopOrGo,
) -> Result(Input, InputError) {
  case stop_or_go == Stop {
    True -> Ok(input)
    False -> {
      case input.char != u_rbrack {
        True -> {
          let input = add_char(input, input.char)
          case next_char(input) {
            Error(e) -> Error(e)
            Ok(input) -> {
              parse_cdata__loop(input, add_char, stop_or_go)
            }
          }
        }
        False -> {
          // input.char == u_rbrack

          case next_char(input) {
            Error(e) -> Error(e)
            Ok(input) -> {
              // Now we need to get through the right brackets.

              case parse_cdata__loop__eat_rbrackets(input, add_char) {
                Error(e) -> Error(e)
                Ok(#(input, go)) -> {
                  case go == Stop {
                    True -> Ok(input)
                    False -> {
                      let input = add_char(input, u_rbrack)
                      parse_cdata__loop(input, add_char, Go)
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

fn parse_cdata__loop__eat_rbrackets(
  input: Input,
  add_char: fn(Input, Int) -> Input,
) -> Result(#(Input, StopOrGo), InputError) {
  case input.char != u_rbrack {
    True -> Ok(#(input, Go))
    False -> {
      case next_char(input) {
        Error(e) -> Error(e)
        Ok(input) -> {
          case input.char == u_gt {
            True -> {
              case next_char(input) {
                Error(e) -> Error(e)
                Ok(input) -> Ok(#(input, Stop))
              }
            }
            False -> {
              let input = add_char(input, u_rbrack)
              parse_cdata__loop__eat_rbrackets(input, add_char)
            }
          }
        }
      }
    }
  }
}

/// XML 1.0 non-terminals: `{Misc}* {doctypedecl} {Misc}*`
fn parse_dtd_signal(input: Input) -> Result(#(Signal, Input), InputError) {
  case skip_misc(input, allow_xmlpi: False) {
    Error(e) -> Error(e)
    Ok(input) -> {
      case input.limit != LimitDtd {
        True -> Ok(#(Dtd(None), input))
        False -> {
          let input = clear_data(input)

          // Add eaten "<!"
          let input = add_char_to_data(input, u_lt)
          let input = add_char_to_data(input, u_emark)

          case parse_dtd_signal__loop(input, nest: 1) {
            Error(e) -> Error(e)
            Ok(input) -> {
              let dtd = buffer_to_string(input.data)

              case parse_limit(input) {
                Error(e) -> Error(e)
                Ok(input) -> {
                  case skip_misc(input, allow_xmlpi: False) {
                    Error(e) -> Error(e)
                    Ok(input) -> Ok(#(Dtd(Some(dtd)), input))
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

// We can have nested tags in here.
fn parse_dtd_signal__loop(
  input: Input,
  nest nest: Int,
) -> Result(Input, InputError) {
  case nest <= 0 {
    True -> Ok(input)
    False -> {
      case input.char == u_lt {
        True -> {
          case next_char(input) {
            Error(e) -> Error(e)
            Ok(input) -> {
              case input.char != u_emark {
                True -> {
                  let input = add_char_to_data(input, u_lt)
                  parse_dtd_signal__loop(input, nest + 1)
                }
                False -> {
                  case next_char(input) {
                    Error(e) -> Error(e)
                    Ok(input) -> {
                      // Comments require care 
                      case input.char != u_minus {
                        True -> {
                          let input = add_char_to_data(input, u_lt)
                          let input = add_char_to_data(input, u_emark)
                          parse_dtd_signal__loop(input, nest + 1)
                        }
                        False -> {
                          case next_char(input) {
                            Error(e) -> Error(e)
                            Ok(input) -> {
                              case input.char != u_minus {
                                True -> {
                                  let input = add_char_to_data(input, u_lt)
                                  let input = add_char_to_data(input, u_emark)
                                  let input = add_char_to_data(input, u_minus)
                                  parse_dtd_signal__loop(input, nest + 1)
                                }
                                False -> {
                                  case next_char_then_skip_comment(input) {
                                    Error(e) -> Error(e)
                                    Ok(input) ->
                                      parse_dtd_signal__loop(input, nest)
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
        False -> {
          case input.char == u_quot || input.char == u_apos {
            True -> {
              let quot_or_apos = input.char
              let input = add_char_to_data(input, quot_or_apos)
              case next_char(input) {
                Error(e) -> Error(e)
                Ok(input) -> {
                  case parse_dtd_signal__loop__loop(input, quot_or_apos) {
                    Error(e) -> Error(e)
                    Ok(input) -> {
                      let input = add_char_to_data(input, quot_or_apos)
                      case next_char(input) {
                        Error(e) -> Error(e)
                        Ok(input) -> {
                          parse_dtd_signal__loop(input, nest)
                        }
                      }
                    }
                  }
                }
              }
            }
            False -> {
              let nest = case input.char == u_gt {
                True -> nest - 1
                False -> nest
              }

              let input = add_char_to_data(input, input.char)
              case next_char(input) {
                Error(e) -> Error(e)
                Ok(input) -> {
                  parse_dtd_signal__loop(input, nest)
                }
              }
            }
          }
        }
      }
    }
  }
}

fn parse_dtd_signal__loop__loop(input: Input, quot_or_apos: Int) -> _ {
  case input.char == quot_or_apos {
    True -> Ok(input)
    False -> {
      let input = add_char_to_data(input, input.char)
      case next_char(input) {
        Error(e) -> Error(e)
        Ok(input) -> parse_dtd_signal__loop__loop(input, quot_or_apos)
      }
    }
  }
}

fn parse_data(input: Input) -> Result(#(String, Input), InputError) {
  let input = clear_data(input)
  let input = Input(..input, last_whitespace: True)

  let add_char = case input.stripping {
    True -> add_char_to_data_strip
    False -> add_char_to_data
  }

  case parse_data__bufferize(input, add_char) {
    Error(e) -> Error(e)
    Ok(input) -> {
      let data = buffer_to_string(input.data)
      Ok(#(data, input))
    }
  }
}

fn parse_data__bufferize(
  input: Input,
  add_char: fn(Input, Int) -> Input,
) -> Result(Input, InputError) {
  case input.limit {
    LimitText -> {
      case parse_chardata(input, add_char) {
        Error(e) -> Error(e)
        Ok(input) -> {
          case parse_limit(input) {
            Error(e) -> Error(e)
            Ok(input) -> {
              parse_data__bufferize(input, add_char)
            }
          }
        }
      }
    }
    LimitCData -> {
      case parse_cdata(input, add_char) {
        Error(e) -> Error(e)
        Ok(input) ->
          case parse_limit(input) {
            Error(e) -> Error(e)
            Ok(input) -> parse_data__bufferize(input, add_char)
          }
      }
    }
    LimitStartTag(_) | LimitEndTag(_) -> Ok(input)
    LimitPi(_) -> {
      case skip_pi(input) {
        Error(e) -> Error(e)
        Ok(input) ->
          case parse_limit(input) {
            Error(e) -> Error(e)
            Ok(input) -> parse_data__bufferize(input, add_char)
          }
      }
    }
    LimitComment -> {
      case skip_comment(input) {
        Error(e) -> Error(e)
        Ok(input) -> {
          case parse_limit(input) {
            Error(e) -> Error(e)
            Ok(input) -> parse_data__bufferize(input, add_char)
          }
        }
      }
    }
    LimitDtd -> error(input, IllegalCharSeq("<!D"))
    LimitEoi -> error(input, UnexpectedEoi)
  }
}

fn parse_element_start_signal(
  input: Input,
  name: Name,
) -> Result(#(Signal, Input), InputError) {
  // save it here, parse_attributes may change it
  let strip = input.stripping

  case parse_attributes(input) {
    Error(e) -> Error(e)
    Ok(#(prefixes, attributes, input)) -> {
      let input =
        Input(..input, scopes: [#(name, prefixes, strip), ..input.scopes])

      let attributes = list.reverse(attributes)

      let result =
        list.fold(attributes, Ok(#([], input)), fn(acc, attribute) {
          case acc {
            Error(e) -> Error(e)
            Ok(#(attributes, input)) -> {
              case expand_attribute(input, attribute) {
                Error(e) -> Error(e)
                Ok(#(expanded_attribute, input)) -> {
                  Ok(#([expanded_attribute, ..attributes], input))
                }
              }
            }
          }
        })

      case result {
        Error(e) -> Error(e)
        Ok(#(expanded_attributes, input)) -> {
          case expand_name(input, name) {
            Error(e) -> Error(e)
            Ok(name) -> {
              let signal = ElementStart(Tag(name, expanded_attributes))
              Ok(#(signal, input))
            }
          }
        }
      }
    }
  }
}

fn expand_attribute(
  input: Input,
  attribute: Attribute,
) -> Result(#(Attribute, Input), InputError) {
  let Name(prefix, local) = attribute.name

  case prefix {
    "" -> {
      case local == n_xmlns {
        True ->
          Ok(#(Attribute(..attribute, name: Name(ns_xmlns, n_xmlns)), input))
        False -> {
          // default namespaces do not influence attributes
          Ok(#(attribute, input))
        }
      }
    }
    _ -> {
      case expand_name(input, attribute.name) {
        Error(e) -> Error(e)
        Ok(name) -> Ok(#(Attribute(..attribute, name: name), input))
      }
    }
  }
}

fn parse_element_end_signal(
  input: Input,
  name: Name,
) -> Result(#(Signal, Input), InputError) {
  case input.scopes {
    [#(name_, prefixes, strip), ..scopes] -> {
      case input.char != u_gt {
        True -> error_expected_chars(input, [u_gt])
        False -> {
          case name != name_ {
            True -> {
              error_expected_seqs(
                input,
                [name_to_string(name_)],
                name_to_string(name),
              )
            }
            False -> {
              let input =
                Input(
                  ..input,
                  scopes: scopes,
                  stripping: strip,
                  ns: list.fold(prefixes, input.ns, fn(dict, prefix) {
                    dict.delete(dict, prefix)
                  }),
                )

              let input = case scopes {
                [] -> Ok(Input(..input, char: u_end_doc))
                _ -> {
                  case next_char(input) {
                    Error(e) -> Error(e)
                    Ok(input) -> parse_limit(input)
                  }
                }
              }

              case input {
                Error(e) -> Error(e)
                Ok(input) -> Ok(#(ElementEnd, input))
              }
            }
          }
        }
      }
    }
    _ -> panic as "impossible"
  }
}

fn parse_signal(input: Input) -> Result(#(Signal, Input), InputError) {
  case input.scopes {
    [] -> parse_signal__empty_scope(input)
    _ -> parse_signal__non_empty_scope(input)
  }
}

fn parse_signal__empty_scope(
  input: Input,
) -> Result(#(Signal, Input), InputError) {
  case input.limit {
    LimitStartTag(name) -> {
      parse_element_start_signal(input, name)
    }
    _ -> error(input, ExpectedRootElement)
  }
}

fn parse_signal__non_empty_scope(
  input: Input,
) -> Result(#(Signal, Input), InputError) {
  let result = case input.peek {
    ElementStart(_) -> {
      // Finish to input start element. 
      case skip_whitespace(input) {
        Error(e) -> Error(e)
        Ok(input) -> {
          case input.char == u_gt {
            True -> accept_then_parse_limit(input, u_gt)
            False -> {
              case input.char == u_slash {
                True -> {
                  let tag = case input.scopes {
                    [#(tag, _, _), ..] -> tag
                    _ -> panic as "impossible"
                  }

                  case next_char(input) {
                    Error(e) -> Error(e)
                    Ok(input) -> {
                      Ok(Input(..input, limit: LimitEndTag(tag)))
                    }
                  }
                }
                False -> error_expected_chars(input, [u_slash, u_gt])
              }
            }
          }
        }
      }
    }
    _ -> Ok(input)
  }

  case result {
    Error(e) -> Error(e)
    Ok(input) -> {
      parse_signal__find(input)
    }
  }
}

fn parse_signal__find(input: Input) -> Result(#(Signal, Input), InputError) {
  case input.limit {
    LimitStartTag(name) -> parse_element_start_signal(input, name)
    LimitEndTag(name) -> parse_element_end_signal(input, name)
    LimitText | LimitCData -> {
      case parse_data(input) {
        Error(e) -> Error(e)
        Ok(#(data, input)) -> {
          case string.is_empty(data) {
            True -> parse_signal__find(input)
            False -> Ok(#(Data(data), input))
          }
        }
      }
    }
    LimitPi(_) -> {
      case skip_pi_then_parse_limit(input) {
        Error(e) -> Error(e)
        Ok(input) -> {
          parse_signal__find(input)
        }
      }
    }
    LimitComment -> {
      case skip_comment_then_parse_limit(input) {
        Error(e) -> Error(e)
        Ok(input) -> {
          parse_signal__find(input)
        }
      }
    }
    LimitDtd -> error(input, IllegalCharSeq("<!D"))
    LimitEoi -> error(input, UnexpectedEoi)
  }
}

/// `eoi(input)` tells if the end of input is reached.
/// 
pub fn eoi(input: Input) -> Result(#(Bool, Input), InputError) {
  use <- bool.guard(when: input.char == u_eoi, return: Ok(#(True, input)))

  use <- bool.guard(
    when: input.char != u_start_doc,
    return: Ok(#(False, input)),
  )

  use <- bool.lazy_guard(when: input.peek != ElementEnd, return: fn() {
    use #(ignore_incoding, input) <- result.try(find_encoding(input))
    use input <- result.try(parse_limit(input))
    use input <- result.try(parse_xml_declaration(
      input,
      ignore_encoding: ignore_incoding,
      ignore_utf16: False,
    ))
    use #(signal, input) <- result.try(parse_dtd_signal(input))
    let input = Input(..input, peek: signal)
    Ok(#(False, input))
  })

  use input <- result.try(next_char_eof(input))
  use input <- result.try(parse_limit(input))
  use <- bool.guard(when: input.char == u_eoi, return: Ok(#(True, input)))
  use input <- result.try(skip_misc(input, allow_xmlpi: True))
  use <- bool.guard(when: input.char == u_eoi, return: Ok(#(True, input)))
  use input <- result.try(parse_xml_declaration(
    input,
    ignore_encoding: False,
    ignore_utf16: True,
  ))
  use #(signal, input) <- result.try(parse_dtd_signal(input))
  let input = Input(..input, peek: signal)
  Ok(#(False, input))
}

fn find_encoding(input: Input) {
  let reset = fn(input: Input, uchar) {
    let input = Input(..input, uchar: uchar, column: 0)
    next_char(input)
  }

  case input.encoding {
    None -> {
      // User doesn't know the encoding. 
      use input <- result.try(next_char(input))
      case input.char {
        0xFE -> {
          // UTF-16BE BOM 
          use input <- result.try(next_char(input))
          use <- bool.lazy_guard(when: input.char != 0xFF, return: fn() {
            error(input, MalformedCharStream)
          })
          use input <- result.try(reset(input, input_uchar_utf16be()))
          Ok(#(True, input))
        }
        0xFF -> {
          // UTF-16LE BOM 
          use input <- result.try(next_char(input))
          use <- bool.lazy_guard(when: input.char != 0xFE, return: fn() {
            error(input, MalformedCharStream)
          })
          use input <- result.try(reset(input, input_uchar_utf16le()))
          Ok(#(True, input))
        }
        0xEF -> {
          // UTF-8 BOM 
          use input <- result.try(next_char(input))
          use <- bool.lazy_guard(when: input.char != 0xBB, return: fn() {
            error(input, MalformedCharStream)
          })
          use input <- result.try(next_char(input))
          use <- bool.lazy_guard(when: input.char != 0xBF, return: fn() {
            error(input, MalformedCharStream)
          })
          use input <- result.try(reset(input, input_uchar_utf8()))
          Ok(#(True, input))
        }
        0x3C | _ -> {
          // UTF-8 or other, try declaration 
          Ok(#(False, Input(..input, uchar: input_uchar_utf8())))
        }
      }
    }
    Some(encoding) -> {
      // User knows encoding 
      use input <- result.try(case encoding {
        UsAscii -> reset(input, input_uchar_ascii())
        Iso8859x1 -> reset(input, input_uchar_iso_8859_1())
        Iso8859x15 -> reset(input, input_uchar_iso_8859_15())
        Utf8 -> {
          use input <- result.try(reset(input, input_uchar_utf8()))
          // Skip BOM if present 
          use <- bool.lazy_guard(when: input.char == u_bom, return: fn() {
            let input = Input(..input, column: 0)
            use input <- result.try(next_char(input))
            Ok(input)
          })
          Ok(input)
        }
        Utf16 -> {
          // Which UTF-16? Look at the BOM. 
          use input <- result.try(next_char(input))
          let byte0 = input.char
          use input <- result.try(next_char(input))
          let byte1 = input.char

          case byte0, byte1 {
            0xFE, 0xFF -> reset(input, input_uchar_utf16be())
            0xFF, 0xFE -> reset(input, input_uchar_utf16le())
            _, _ -> error(input, MalformedCharStream)
          }
        }
        Utf16Be -> {
          use input <- result.try(reset(input, input_uchar_utf16be()))
          // Skip BOM if present 
          use <- bool.lazy_guard(when: input.char == u_bom, return: fn() {
            let input = Input(..input, column: 0)
            use input <- result.try(next_char(input))
            Ok(input)
          })
          Ok(input)
        }
        Utf16Le -> {
          use input <- result.try(reset(input, input_uchar_utf16le()))
          // Skip BOM if present 
          use <- bool.lazy_guard(when: input.char == u_bom, return: fn() {
            let input = Input(..input, column: 0)
            use input <- result.try(next_char(input))
            Ok(input)
          })
          Ok(input)
        }
      })

      Ok(#(True, input))
    }
  }
}

/// XML 1.0 non-terminal: {XMLDecl}?
fn parse_xml_declaration(
  input: Input,
  ignore_encoding ignore_encoding: Bool,
  ignore_utf16 ignore_utf16: Bool,
) -> Result(Input, InputError) {
  let yes_no = [v_yes, v_no]

  let parse_val = fn(input: Input) {
    use input <- result.try(skip_whitespace(input))
    use input <- result.try(accept(input, u_eq))
    use input <- result.try(skip_whitespace(input))
    parse_attribute_value(input)
  }

  let parse_val_expected = fn(input: Input, expected) -> Result(
    Input,
    InputError,
  ) {
    use #(val, input) <- result.try(parse_val(input))
    case list.find(in: expected, one_that: fn(expected) { val == expected }) {
      Error(Nil) -> error_expected_seqs(input, expected, val)
      Ok(_) -> Ok(input)
    }
  }

  case input.limit {
    LimitPi(Name(uri, local)) -> {
      use <- bool.guard(
        when: !{ string.is_empty(uri) && { local == n_xml } },
        return: Ok(input),
      )

      use input <- result.try(skip_whitespace(input))
      use #(v, input) <- result.try(parse_ncname(input))

      use <- bool.lazy_guard(when: v != n_version, return: fn() {
        error_expected_seqs(input, [n_version], v)
      })

      use input <- result.try(
        parse_val_expected(input, [v_version_1_0, v_version_1_1]),
      )

      use input <- result.try(skip_whitespace(input))

      use input <- result.try({
        case input.char != u_qmark {
          True -> {
            use #(name, input) <- result.try(parse_ncname(input))

            use input <- result.try({
              // 
              case name == n_encoding {
                True -> {
                  use #(encoding, input) <- result.try(parse_val(input))
                  let encoding = string.lowercase(encoding)

                  use input <- result.try({
                    use <- bool.guard(when: ignore_encoding, return: Ok(input))
                    use <- bool.guard(
                      when: encoding == v_utf_8,
                      return: Ok(Input(..input, uchar: input_uchar_utf8())),
                    )
                    use <- bool.guard(
                      when: encoding == v_utf_16be,
                      return: Ok(Input(..input, uchar: input_uchar_utf16be())),
                    )
                    use <- bool.guard(
                      when: encoding == v_utf_16le,
                      return: Ok(Input(..input, uchar: input_uchar_utf16le())),
                    )
                    use <- bool.guard(
                      when: encoding == v_iso_8859_1,
                      return: Ok(
                        Input(..input, uchar: input_uchar_iso_8859_1()),
                      ),
                    )
                    use <- bool.guard(
                      when: encoding == v_iso_8859_15,
                      return: Ok(
                        Input(..input, uchar: input_uchar_iso_8859_15()),
                      ),
                    )
                    use <- bool.guard(
                      when: encoding == v_us_ascii,
                      return: Ok(Input(..input, uchar: input_uchar_ascii())),
                    )
                    use <- bool.guard(
                      when: encoding == v_ascii,
                      return: Ok(Input(..input, uchar: input_uchar_ascii())),
                    )
                    use <- bool.lazy_guard(
                      when: encoding == v_utf_16,
                      return: fn() {
                        case ignore_utf16 {
                          True -> Ok(input)
                          // A BOM should have been found.
                          False -> error(input, MalformedCharStream)
                        }
                      },
                    )
                    error(input, UnknownEncoding(encoding))
                  })

                  use input <- result.try(skip_whitespace(input))
                  use <- bool.guard(
                    when: input.char == u_qmark,
                    return: Ok(input),
                  )
                  use #(name, input) <- result.try(parse_ncname(input))
                  case name == n_standalone {
                    True -> parse_val_expected(input, yes_no)
                    False ->
                      error_expected_seqs(input, [n_standalone, "?>"], name)
                  }
                }
                False ->
                  case name == n_standalone {
                    True -> parse_val_expected(input, yes_no)
                    False ->
                      error_expected_seqs(
                        input,
                        [n_encoding, n_standalone, "?>"],
                        name,
                      )
                  }
              }
            })

            Ok(input)
          }
          False -> Ok(input)
        }
      })

      use input <- result.try(skip_whitespace(input))
      use input <- result.try(accept(input, u_qmark))
      use input <- result.try(accept(input, u_gt))
      parse_limit(input)
    }
    _ -> Ok(input)
  }
}

/// `xmlm.peek(input)` is the same as `xmlm.signal(input)` except that
/// the signal is not removed from the sequence.
/// 
pub fn peek(input: Input) -> Result(#(Signal, Input), InputError) {
  case eoi(input) {
    Error(e) -> Error(e)
    Ok(#(True, input)) -> error(input, UnexpectedEoi)
    Ok(#(False, input)) -> Ok(#(input.peek, input))
  }
}

/// `xmlm.signal(input)` inputs a `Signal`.  
/// 
/// Repeatedly invoking the function / with the same input abstraction will
/// either generate a well-formed sequence apple shton / of signals or raise an
/// error. Additionally, no two consecutive Data signals / can appear in the
/// sequence, and their strings will always be non-empty.
/// 
/// Note: after a well-formed sequence has been input, another sequence can be
/// input.  This behavior is **deprecated**.
/// 
pub fn signal(input: Input) -> Result(#(Signal, Input), InputError) {
  // Note: this guard is for the document sequences. document sequences will
  // eventually be removed.
  case input.char == u_end_doc {
    True -> {
      let input = Input(..input, char: u_start_doc)
      Ok(#(input.peek, input))
    }
    False -> {
      case peek(input) {
        Error(e) -> Error(e)
        Ok(#(signal, input)) -> {
          case parse_signal(input) {
            Error(e) -> Error(e)
            Ok(#(peeked_signal, input)) -> {
              let input = Input(..input, peek: peeked_signal)
              Ok(#(signal, input))
            }
          }
        }
      }
    }
  }
}

/// Return a list of all `Signals` in the given `input`.
/// 
pub fn signals(input) -> Result(#(List(Signal), Input), InputError) {
  do_input_signals(input, [])
}

fn do_input_signals(
  input: Input,
  acc: List(Signal),
) -> Result(#(List(Signal), Input), InputError) {
  // NOTE: don't change these to use `result.try` and `bool.guard` as it can
  // overflow the max call stack size on JavaScript target.
  case eoi(input) {
    Error(e) -> Error(e)
    Ok(#(True, input)) -> Ok(#(list.reverse(acc), input))
    Ok(#(False, input)) ->
      case signal(input) {
        Ok(#(signal, input)) -> do_input_signals(input, [signal, ..acc])
        // Lexers shouldn't hit EOI if eoi is false. If they do it's some
        // error.
        Error(InputError(position, UnicodeLexerErrorEoi)) ->
          Error(InputError(position, UnexpectedEoi))
        Error(e) -> Error(e)
      }
  }
}

/// `xmlm.fold_signals(over: input, from: acc, with: f)` reduces the `Signals` 
/// of the `input` to a single value starting with `acc` by calling the given 
/// function `f` on each `Signal` in the `input`.
/// 
pub fn fold_signals(
  over input: Input,
  from acc: acc,
  with f: fn(acc, Signal) -> acc,
) -> Result(#(acc, Input), InputError) {
  case eoi(input) {
    Error(e) -> Error(e)
    Ok(#(True, input)) -> Ok(#(acc, input))
    Ok(#(False, input)) -> {
      case signal(input) {
        Ok(#(signal, input)) -> {
          fold_signals(input, f(acc, signal), f)
        }
        Error(InputError(position, UnicodeLexerErrorEoi)) ->
          Error(InputError(position, UnexpectedEoi))
        Error(e) -> Error(e)
      }
    }
  }
}

/// `xmlm.tree(input, element_callback, data_callback)` inputs signals in 
/// different ways depending on the next signal.
/// 
/// If the next signal is a...
/// 
/// - `Data` signal, `tree` inputs the signal and invokes `data_callback` with 
///   the character data of the signal.
/// - `ElementStart` signal, `tree` inputs the sequence of signals until its 
///   matching `ElementEnd` and envokes `element_callback` and `data_callback` 
///   as follows:
///   - `element_callback` is called on each `ElementEnd` signal with the 
///     corresponding `ElementStart` tag and the result of the callback 
///     invocation for the element's children.
///   - `data_callback` is called on each `Data` signal with the character data.  
///     This function won't be called twice consecutively or with the empty 
///     string.
/// - Other signals, returns an error.
/// 
/// See [document_tree](#document_tree) for getting the entire document as a 
/// tree. 
///
pub fn tree(
  input: Input,
  element_callback element_callback: fn(Tag, List(a)) -> a,
  data_callback data_callback: fn(String) -> a,
) -> Result(#(a, Input), InputError) {
  case signal(input) {
    Error(e) -> Error(e)
    Ok(#(signal, input)) -> {
      case signal {
        Data(data) -> Ok(#(data_callback(data), input))
        ElementStart(tag) ->
          tree__loop(
            input,
            [tag, ..[]],
            [[], ..[]],
            element_callback,
            data_callback,
          )
        Dtd(_) | ElementEnd ->
          error(input, InvalidArgument("input signal not ElementStart or Data"))
      }
    }
  }
}

fn tree__loop(
  input: Input,
  tags: List(Tag),
  context: List(List(a)),
  element_callback: fn(Tag, List(a)) -> a,
  data_callback: fn(String) -> a,
) -> Result(#(a, Input), InputError) {
  case signal(input) {
    Error(e) -> Error(e)
    Ok(#(signal, input)) -> {
      case signal {
        ElementStart(tag) ->
          tree__loop(
            input,
            [tag, ..tags],
            [[], ..context],
            element_callback,
            data_callback,
          )
        ElementEnd ->
          case tags, context {
            [tag, ..tags_], [children, ..context_] -> {
              let element = element_callback(tag, list.reverse(children))
              case context_ {
                [parent, ..context__] ->
                  tree__loop(
                    input,
                    tags_,
                    [[element, ..parent], ..context__],
                    element_callback,
                    data_callback,
                  )
                [] -> Ok(#(element, input))
              }
            }
            _, _ -> panic as "impossible"
          }
        Data(data) ->
          case context {
            [children, ..context_] -> {
              let more_context = [data_callback(data), ..children]
              tree__loop(
                input,
                tags,
                [more_context, ..context_],
                element_callback,
                data_callback,
              )
            }
            [] -> panic as "impossible"
          }
        Dtd(_) -> panic as "impossible"
      }
    }
  }
}

/// `xmlm.document_tree(input, element_callback, data_callback)` reads a 
/// complete, well-formed sequence of signals.
/// 
/// See [tree](#tree) for getting a tree produced by a single `Signal`. 
///
pub fn document_tree(
  input: Input,
  element_callback element_callback: fn(Tag, List(a)) -> a,
  data_callback data_callback: fn(String) -> a,
) -> Result(#(Option(String), a, Input), InputError) {
  case signal(input) {
    Error(e) -> Error(e)
    Ok(#(signal, input)) -> {
      case signal {
        Dtd(data) -> {
          case tree(input, element_callback, data_callback) {
            Error(e) -> Error(e)
            Ok(#(a, input)) -> {
              Ok(#(data, a, input))
            }
          }
        }
        _ -> error(input, InvalidArgument("input signal not Dtd"))
      }
    }
  }
}

// =============================================================================
// Buffers
// =============================================================================

type Buffer =
  List(Int)

fn buffer_new() -> Buffer {
  []
}

/// UTF-8 encode a uchar in the buffer. Assumes that `uchar` is a valid
/// codepoint.
/// 
fn buffer_add_uchar(buffer: Buffer, uchar: Int) -> Buffer {
  case uchar <= 0x007F {
    True -> [uchar, ..buffer]
    False -> {
      // Note!  These are arithmetic shift right, but the original OCaml uses
      // the logical shift right.  Since these uchar should always be positive
      // ints, both right shifts should give the same result.

      case uchar <= 0x07FF {
        True -> {
          // (buf (0xC0 lor (u lsr 6));
          //  buf (0x80 lor (u land 0x3F)))

          [
            int.bitwise_or(0x80, int.bitwise_and(uchar, 0x3F)),
            int.bitwise_or(0xC0, int.bitwise_shift_right(uchar, 6)),
            ..buffer
          ]
        }
        False -> {
          case uchar <= 0xFFFF {
            True -> {
              // (buf (0xE0 lor (u lsr 12));
              //  buf (0x80 lor ((u lsr 6) land 0x3F));
              //  buf (0x80 lor (u land 0x3F)))

              [
                int.bitwise_or(0x80, int.bitwise_and(uchar, 0x3F)),
                int.bitwise_or(
                  0x80,
                  int.bitwise_and(int.bitwise_shift_right(uchar, 6), 0x3F),
                ),
                int.bitwise_or(0xE0, int.bitwise_shift_right(uchar, 12)),
                ..buffer
              ]
            }
            False -> {
              // (buf (0xF0 lor (u lsr 18));
              //  buf (0x80 lor ((u lsr 12) land 0x3F));
              //  buf (0x80 lor ((u lsr 6) land 0x3F));
              //  buf (0x80 lor (u land 0x3F)))

              [
                int.bitwise_or(0x80, int.bitwise_and(uchar, 0x3F)),
                int.bitwise_or(
                  0x80,
                  int.bitwise_and(int.bitwise_shift_right(uchar, 6), 0x3F),
                ),
                int.bitwise_or(
                  0x80,
                  int.bitwise_and(int.bitwise_shift_right(uchar, 12), 0x3F),
                ),
                int.bitwise_or(0xF0, int.bitwise_shift_right(uchar, 18)),
                ..buffer
              ]
            }
          }
        }
      }
    }
  }
}

fn buffer_clear(_: Buffer) -> Buffer {
  []
}

fn buffer_to_string(buffer: Buffer) -> String {
  list.reverse(buffer) |> do_buffer_to_string
}

@external(erlang, "xmlm_ffi", "int_list_to_string")
@external(javascript, "./xmlm_ffi.mjs", "int_list_to_string")
fn do_buffer_to_string(buffer: Buffer) -> String

fn string_from_char(char: Int) -> String {
  buffer_new() |> buffer_add_uchar(char) |> buffer_to_string
}

// =============================================================================
// Utils
// =============================================================================

fn next_char_then_skip_comment(input: Input) -> Result(Input, InputError) {
  case next_char(input) {
    Error(e) -> Error(e)
    Ok(input) -> skip_comment(input)
  }
}

fn skip_pi_then_parse_limit(input: Input) -> Result(Input, InputError) {
  case skip_pi(input) {
    Error(e) -> Error(e)
    Ok(input) -> parse_limit(input)
  }
}

fn skip_comment_then_parse_limit(input: Input) -> Result(Input, InputError) {
  case skip_comment(input) {
    Error(e) -> Error(e)
    Ok(input) -> parse_limit(input)
  }
}

fn accept_then_parse_limit(input: Input, char: Int) -> Result(Input, InputError) {
  case accept(input, char) {
    Error(e) -> Error(e)
    Ok(input) -> parse_limit(input)
  }
}

fn skip_whitespace_eof_then_parse_limit(
  input: Input,
) -> Result(Input, InputError) {
  case skip_whitespace_eof(input) {
    Error(e) -> Error(e)
    Ok(input) -> parse_limit(input)
  }
}
