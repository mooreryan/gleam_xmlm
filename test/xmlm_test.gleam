import birdie
import gleam/bit_array
import gleam/list
import gleam/option.{None, Some}
import gleam/pair
import gleam/result
import gleeunit/should
import qcheck_gleeunit_utils/run
import simplifile
import utils.{err_exn, ok_exn}
import xmlm.{Attribute, Data, Dtd, ElementEnd, ElementStart, Name, Tag}

// *Note!*  Some of the example XML snippets are from the test suite of a Rust
// [xmlparser](https://github.com/RazrFalcon/xmlparser) by RazrFalon.

pub fn main() {
  run.run_gleeunit()
}

fn xmlm_signals_should_be_error(xml) {
  xml
  |> xmlm.from_string
  |> xmlm.signals
  |> should.be_error
}

fn xmlm_signals_should_be_ok(xml) {
  xml
  |> xmlm.from_string
  |> xmlm.signals
  |> should.be_ok
}

fn xmlm_signals_from_string_exn(xml) {
  xml |> xmlm.from_string |> xmlm.signals |> ok_exn
}

pub fn multiple_data_things__test() {
  "<a>apple pie\nis good<b>yeah\nit is</b>hello!</a>"
  |> xmlm_signals_from_string_exn
  |> pair.first
  |> xmlm.signals_to_string
  |> birdie.snap("xmlm_test.multiple_data_things__test")
}

pub fn basic_xml__usascii__test() {
  let assert Ok(signals) =
    xmlm.from_string("<a>b</a>")
    |> xmlm.with_encoding(xmlm.UsAscii)
    |> xmlm.signals
    |> result.map(pair.first)
    |> result.map(xmlm.signals_to_string)

  signals |> birdie.snap("xmlm_test.basic_xml__usascii__test")
}

pub fn basic_xml__utf8__test() {
  let assert Ok(signals) =
    xmlm.from_string("<a>b</a>")
    |> xmlm.with_encoding(xmlm.Utf8)
    |> xmlm.signals
    |> result.map(pair.first)
    |> result.map(xmlm.signals_to_string)

  signals |> birdie.snap("xmlm_test.basic_xml__utf8__test")
}

pub fn snack_file__test() {
  let assert Ok(xml) = simplifile.read("test/test_files/snack.UTF8.xml")

  let input = xmlm.from_string(xml) |> xmlm.with_encoding(xmlm.Utf8)

  let assert Ok(signals) =
    xmlm.signals(input)
    |> result.map(pair.first)
    |> result.map(xmlm.signals_to_string)

  signals |> birdie.snap("xmlm_test.snack_file__test")
}

pub fn snack_file__utf8_matches_usascii__test() {
  should.equal(
    signals_from_file("test/test_files/snack.UTF8.xml", xmlm.Utf8),
    signals_from_file("test/test_files/snack.UTF8.xml", xmlm.UsAscii),
  )
}

pub fn snack_file__utf8_matches_iso8859x1__test() {
  should.equal(
    signals_from_file("test/test_files/snack.UTF8.xml", xmlm.Utf8),
    signals_from_file("test/test_files/snack.ISO8859x1.xml", xmlm.Iso8859x1),
  )
}

pub fn snack_file__utf8_matches_iso8859x15__test() {
  should.equal(
    signals_from_file("test/test_files/snack.UTF8.xml", xmlm.Utf8),
    signals_from_file("test/test_files/snack.ISO8859x15.xml", xmlm.Iso8859x15),
  )
}

pub fn snack_file__utf8_matches_utf16be__test() {
  should.equal(
    signals_from_file("test/test_files/snack.UTF8.xml", xmlm.Utf8),
    signals_from_file("test/test_files/snack.UTF16BE.xml", xmlm.Utf16Be),
  )
}

pub fn snack_file__utf8_matches_utf16le__test() {
  should.equal(
    signals_from_file("test/test_files/snack.UTF8.xml", xmlm.Utf8),
    signals_from_file("test/test_files/snack.UTF16LE.xml", xmlm.Utf16Le),
  )
}

pub fn snack_file__utf8_matches_utf16be_with_utf16__test() {
  should.equal(
    signals_from_file("test/test_files/snack.UTF8.xml", xmlm.Utf8),
    signals_from_file("test/test_files/snack.UTF16BE.xml", xmlm.Utf16),
  )
}

pub fn snack_file__utf8_matches_utf16le_with_utf16__test() {
  should.equal(
    signals_from_file("test/test_files/snack.UTF8.xml", xmlm.Utf8),
    signals_from_file("test/test_files/snack.UTF16LE.xml", xmlm.Utf16),
  )
}

// todo byte lexer?

fn signals_from_file(
  file_name: String,
  encoding: xmlm.Encoding,
) -> Result(List(xmlm.Signal), xmlm.InputError) {
  simplifile.read_bits(file_name)
  |> utils.ok_exn
  |> xmlm.from_bit_array
  |> xmlm.with_encoding(encoding)
  |> xmlm.signals
  |> result.map(pair.first)
}

pub fn fold_signals__test() {
  let assert Ok(xml) = simplifile.read("test/test_files/snack.UTF8.xml")

  let input =
    xml
    |> xmlm.from_string
    |> xmlm.with_encoding(xmlm.Utf8)

  let expected = xmlm.signals(input) |> result.map(pair.first)

  let result =
    input
    |> xmlm.fold_signals([], fn(acc, signal) { [signal, ..acc] })
    |> result.map(pair.first)
    |> result.map(list.reverse)

  result |> should.equal(expected)
}

pub fn just_comment__test() {
  let xml = "<!-- comment--><a>b</a><!--comment-->"

  let assert Ok(signals) =
    xml
    |> xmlm.from_string
    |> xmlm.signals
    |> result.map(pair.first)
    |> result.map(xmlm.signals_to_string)

  signals
  |> should.equal(
    "Dtd(None)\nElementStart(Tag(name: \"a\", attributes: []))\nData(\"b\")\nElementEnd",
  )
}

pub fn o_p66fail1__test() {
  "<doc>&#65</doc>"
  |> xmlm.from_string
  |> xmlm.signals
  |> should.be_error
}

pub fn o_p66fail1__2__test() {
  "<doc><a>&#65</a></doc>"
  |> xmlm.from_string
  |> xmlm.signals
  |> should.be_error
}

pub fn o_p66fail1__3__test() {
  "
<A a='&#65;abcd'/>"
  |> xmlm.from_string
  |> xmlm.signals
  |> should.be_ok
}

pub fn bom__test() {
  "\u{FEFF}<a/>"
  |> xmlm.from_string
  |> xmlm.signals
  |> result.map(pair.first)
  |> result.map(xmlm.signals_to_string)
  |> ok_exn
  |> birdie.snap("xmlm_test.bom__test")
}

pub fn empty_string__test() {
  "" |> xmlm.from_string |> xmlm.signals |> should.be_error
}

pub fn just_spaces__test() {
  "      " |> xmlm.from_string |> xmlm.signals |> should.be_error
}

pub fn whitespace_only__test() {
  " \n\t\r " |> xmlm.from_string |> xmlm.signals |> should.be_error
}

pub fn xml_decl__test() {
  "<?xml version='1.0'?>"
  |> xmlm.from_string
  |> xmlm.signals
  |> result.map(pair.first)
  |> result.map(xmlm.signals_to_string)
  // TODO: should be 'expected root element'
  |> should.be_error
}

pub fn stripping__test() {
  let a =
    "<p>text</p>"
    |> xmlm.from_string
    |> xmlm.signals
    |> result.map(pair.first)

  let b =
    "<p> text </p>"
    |> xmlm.from_string
    |> xmlm.signals
    |> result.map(pair.first)

  should.not_equal(a, b)

  let c =
    "<p> text </p>"
    |> xmlm.from_string
    |> xmlm.with_stripping(True)
    |> xmlm.signals
    |> result.map(pair.first)

  should.equal(a, c)
}

pub fn basic_text_with_space__test() {
  "<p> text </p>"
  |> xmlm.from_string
  |> xmlm.signals
  |> result.map(pair.first)
  |> result.map(xmlm.signals_to_string)
  |> ok_exn
  |> birdie.snap("xmlm_test.basic_text_with_space__test")
}

pub fn text__2__test() {
  "<p>*欄*</p>"
  |> xmlm.from_string
  |> xmlm.with_encoding(xmlm.Utf8)
  |> xmlm.signals
  |> result.map(pair.first)
  |> result.map(xmlm.signals_to_string)
  |> ok_exn
  |> birdie.snap("xmlm_test.text__2__test")
}

pub fn data__rbracket_gt__test() {
  "<p>]></p>"
  |> xmlm.from_string
  |> xmlm.with_encoding(xmlm.Utf8)
  |> xmlm.signals
  |> result.map(pair.first)
  |> result.map(xmlm.signals_to_string)
  |> ok_exn
  |> birdie.snap("xmlm_test.data__rbracket_gt__test")
}

pub fn data__rbracket_rbracket_gt_not_allowed__test() {
  let assert Error(e) =
    "<p>]]></p>"
    |> xmlm.from_string
    |> xmlm.signals

  xmlm.input_error_to_string(e)
  |> birdie.snap("xmlm_test.data__rbracket_rbracket_gt_not_allowed__test")
}

pub fn data__non_xml_character__test() {
  let assert Error(e) =
    "<p>\u{0c}</p>"
    |> xmlm.from_string
    |> xmlm.signals

  xmlm.input_error_to_string(e)
  |> birdie.snap("xmlm_test.data__non_xml_character__test")
}

// =============================================================================
// Namespaces
// =============================================================================

pub fn namespaced_tag_name__test() {
  "<a xmlns:snazzy=\"thing\">
    <snazzy:b />
  </a>"
  |> xmlm.from_string
  |> xmlm.with_stripping(True)
  |> xmlm.signals
  |> result.map(pair.first)
  |> should.equal(
    Ok([
      Dtd(None),
      ElementStart(
        Tag(Name("", "a"), [
          Attribute(Name("http://www.w3.org/2000/xmlns/", "snazzy"), "thing"),
        ]),
      ),
      ElementStart(Tag(Name("thing", "b"), [])),
      ElementEnd,
      ElementEnd,
    ]),
  )
}

pub fn namespaced_tag_name_unknown_prefix__test() {
  "<a snazzy=\"thing\">
    <snazzy:b />
  </a>"
  |> xmlm.from_string
  |> xmlm.with_stripping(True)
  |> xmlm.signals
  |> err_exn
  |> xmlm.input_error_to_string
  |> should.equal(
    "ERROR Position(line: 2, column: 15) unknown namespace prefix (snazzy)",
  )
}

pub fn namespaced_tag_name_unknown_prefix_2__test() {
  "<a wowza:snazzy=\"thing\">
    <snazzy:b />
  </a>"
  |> xmlm.from_string
  |> xmlm.with_stripping(True)
  |> xmlm.signals
  |> err_exn
  |> xmlm.input_error_to_string
  |> should.equal(
    "ERROR Position(line: 1, column: 24) unknown namespace prefix (wowza)",
  )
}

pub fn unknown_namespace_prefix__test() {
  "<a>
    <snazzy:b />
    <nifty:b />
  </a>"
  |> xmlm.from_string
  |> xmlm.with_stripping(True)
  |> xmlm.signals
  |> err_exn
  |> xmlm.input_error_to_string
  |> should.equal(
    "ERROR Position(line: 2, column: 15) unknown namespace prefix (snazzy)",
  )
}

pub fn unknown_namespace_prefix_with_namespace_callback__test() {
  "<a xmlns:shiny=\"very_shiny\">
    <snazzy:b />
    <nifty:b />
    <shiny:b />
  </a>"
  |> xmlm.from_string
  |> xmlm.with_stripping(True)
  |> xmlm.with_namespace_callback(fn(x) {
    case x {
      "snazzy" -> Some("quite_snazzy")
      "nifty" -> Some("very_nifty")
      _ -> None
    }
  })
  |> xmlm.signals
  |> result.map(pair.first)
  |> should.equal(
    Ok([
      Dtd(None),
      ElementStart(
        Tag(Name("", "a"), [
          Attribute(
            Name("http://www.w3.org/2000/xmlns/", "shiny"),
            "very_shiny",
          ),
        ]),
      ),
      ElementStart(Tag(Name("quite_snazzy", "b"), [])),
      ElementEnd,
      ElementStart(Tag(Name("very_nifty", "b"), [])),
      ElementEnd,
      ElementStart(Tag(Name("very_shiny", "b"), [])),
      ElementEnd,
      ElementEnd,
    ]),
  )
}

pub fn unknown_namespace_prefix_with_namespace_callback_unresolved__test() {
  "<a>
    <snazzy:b />
    <nifty:b />
  </a>"
  |> xmlm.from_string
  |> xmlm.with_stripping(True)
  |> xmlm.with_namespace_callback(fn(x) {
    case x {
      "nifty" -> Some("nifty")
      _ -> None
    }
  })
  |> xmlm.signals
  |> err_exn
  |> xmlm.input_error_to_string
  |> should.equal(
    "ERROR Position(line: 2, column: 15) unknown namespace prefix (snazzy)",
  )
}

// =============================================================================
// Entities
// =============================================================================

pub fn entities__test() {
  "<p>&#65; &amp; &#x41;</p>"
  |> xmlm.from_string
  |> xmlm.signals
  |> result.map(pair.first)
  |> should.equal(
    Ok([
      Dtd(None),
      ElementStart(Tag(Name("", "p"), [])),
      Data("A & A"),
      ElementEnd,
    ]),
  )
}

pub fn unresolved_entities__test() {
  "<p> &apple; &pie; </p>"
  |> xmlm.from_string
  |> xmlm.with_stripping(True)
  |> xmlm.signals
  |> err_exn
  |> xmlm.input_error_to_string
  |> should.equal(
    "ERROR Position(line: 1, column: 12) unknown entity reference (apple)",
  )
}

pub fn entities_with_resolving_callback__test() {
  "<p> &apple; &pie; </p>"
  |> xmlm.from_string
  |> xmlm.with_stripping(True)
  |> xmlm.with_entity_callback(fn(entity_reference) {
    case entity_reference {
      "apple" -> Some("APPLE!")
      "pie" -> Some("PIE!")
      _ -> None
    }
  })
  |> xmlm.signals
  |> result.map(pair.first)
  |> should.equal(
    Ok([
      Dtd(None),
      ElementStart(Tag(Name("", "p"), [])),
      Data("APPLE! PIE!"),
      ElementEnd,
    ]),
  )
}

pub fn entities_with_resolving_callback_still_unknown__test() {
  "<p> &apple; &pie; &good; </p>"
  |> xmlm.from_string
  |> xmlm.with_stripping(True)
  |> xmlm.with_entity_callback(fn(entity_reference) {
    case entity_reference {
      "apple" -> Some("APPLE!")
      "pie" -> Some("PIE!")
      _ -> None
    }
  })
  |> xmlm.signals
  |> err_exn
  |> xmlm.input_error_to_string
  |> should.equal(
    "ERROR Position(line: 1, column: 25) unknown entity reference (good)",
  )
}

// =============================================================================
// External tests: cdata.rs
// =============================================================================

pub fn cdata_1__test() {
  "<p><![CDATA[content]]></p>"
  |> xmlm.from_string
  |> xmlm.with_encoding(xmlm.Utf8)
  |> xmlm.signals
  |> result.map(pair.first)
  |> result.map(xmlm.signals_to_string)
  |> ok_exn
  |> birdie.snap("xmlm_test.cdata_1__test")
}

pub fn cdata_2__test() {
  "<p><![CDATA[&amping]]></p>"
  |> xmlm.from_string
  |> xmlm.with_encoding(xmlm.Utf8)
  |> xmlm.signals
  |> result.map(pair.first)
  |> result.map(xmlm.signals_to_string)
  |> ok_exn
  |> birdie.snap("xmlm_test.cdata_2__test")
}

pub fn cdata_3__test() {
  "<p><![CDATA[&amping ]]]></p>"
  |> xmlm.from_string
  |> xmlm.with_encoding(xmlm.Utf8)
  |> xmlm.signals
  |> result.map(pair.first)
  |> result.map(xmlm.signals_to_string)
  |> ok_exn
  |> birdie.snap("xmlm_test.cdata_3__test")
}

pub fn cdata_4__test() {
  "<p><![CDATA[&amping]] ]]></p>"
  |> xmlm.from_string
  |> xmlm.with_encoding(xmlm.Utf8)
  |> xmlm.signals
  |> result.map(pair.first)
  |> result.map(xmlm.signals_to_string)
  |> ok_exn
  |> birdie.snap("xmlm_test.cdata_4__test")
}

pub fn cdata_5__test() {
  "<p><![CDATA[<message>text</message>]]></p>"
  |> xmlm.from_string
  |> xmlm.with_encoding(xmlm.Utf8)
  |> xmlm.signals
  |> result.map(pair.first)
  |> result.map(xmlm.signals_to_string)
  |> ok_exn
  |> birdie.snap("xmlm_test.cdata_5__test")
}

pub fn cdata_6__test() {
  "<p><![CDATA[</this is malformed!</malformed</malformed & worse>]]></p>"
  |> xmlm.from_string
  |> xmlm.with_encoding(xmlm.Utf8)
  |> xmlm.signals
  |> result.map(pair.first)
  |> result.map(xmlm.signals_to_string)
  |> ok_exn
  |> birdie.snap("xmlm_test.cdata_6__test")
}

pub fn cdata_7__test() {
  "<p><![CDATA[1]]><![CDATA[2]]></p>"
  |> xmlm.from_string
  |> xmlm.with_encoding(xmlm.Utf8)
  |> xmlm.signals
  |> result.map(pair.first)
  |> result.map(xmlm.signals_to_string)
  |> ok_exn
  |> birdie.snap("xmlm_test.cdata_7__test")
}

pub fn cdata_8__test() {
  "<p> \n <![CDATA[data]]> \t </p>"
  |> xmlm.from_string
  |> xmlm.with_encoding(xmlm.Utf8)
  |> xmlm.signals
  |> result.map(pair.first)
  |> result.map(xmlm.signals_to_string)
  |> ok_exn
  |> birdie.snap("xmlm_test.cdata_8__test")
}

pub fn cdata_9__test() {
  "<p><![CDATA[bracket ]after]]></p>"
  |> xmlm.from_string
  |> xmlm.with_encoding(xmlm.Utf8)
  |> xmlm.signals
  |> result.map(pair.first)
  |> result.map(xmlm.signals_to_string)
  |> ok_exn
  |> birdie.snap("xmlm_test.cdata_9__test")
}

pub fn cdata_10__test() {
  let assert Error(e) =
    "<p><![CDATA[\u{1}]]></p>"
    |> xmlm.from_string
    |> xmlm.signals

  xmlm.input_error_to_string(e)
  |> birdie.snap("xmlm_test.cdata_10__test")
}

// =============================================================================
// External tests: comments.rs
// =============================================================================

pub fn comment_01__test() {
  "<!--comment--><p />" |> xmlm_signals_should_be_ok
}

pub fn comment_02__test() {
  "<!--<head>--><p />" |> xmlm_signals_should_be_ok
}

pub fn comment_03__test() {
  "<!--<!-x--><p />" |> xmlm_signals_should_be_ok
}

pub fn comment_04__test() {
  "<!--<!x--><p />" |> xmlm_signals_should_be_ok
}

pub fn comment_05__test() {
  "<!--<<!x--><p />" |> xmlm_signals_should_be_ok
}

pub fn comment_06__test() {
  "<!--<<!-x--><p />" |> xmlm_signals_should_be_ok
}

pub fn comment_07__test() {
  "<!--<x--><p />" |> xmlm_signals_should_be_ok
}

pub fn comment_08__test() {
  "<!--<>--><p />" |> xmlm_signals_should_be_ok
}

pub fn comment_09__test() {
  "<!--<--><p />" |> xmlm_signals_should_be_ok
}

pub fn comment_10__test() {
  "<!--<!--><p />" |> xmlm_signals_should_be_ok
}

pub fn comment_11__test() {
  "<!----><p />" |> xmlm_signals_should_be_ok
}

pub fn comment_err_01__test() {
  "<!----!>" |> xmlm_signals_should_be_error
}

pub fn comment_err_02__test() {
  "<!----!" |> xmlm_signals_should_be_error
}

pub fn comment_err_03__test() {
  "<!----" |> xmlm_signals_should_be_error
}

pub fn comment_err_04__test() {
  "<!--->" |> xmlm_signals_should_be_error
}

pub fn comment_err_05__test() {
  "<!-----" |> xmlm_signals_should_be_error
}

pub fn comment_err_06__test() {
  "<!-->" |> xmlm_signals_should_be_error
}

pub fn comment_err_07__test() {
  "<!--" |> xmlm_signals_should_be_error
}

pub fn comment_err_08__test() {
  "<!--x" |> xmlm_signals_should_be_error
}

pub fn comment_err_09__test() {
  "<!--<" |> xmlm_signals_should_be_error
}

pub fn comment_err_10__test() {
  "<!--<!" |> xmlm_signals_should_be_error
}

pub fn comment_err_11__test() {
  "<!--<!-" |> xmlm_signals_should_be_error
}

pub fn comment_err_12__test() {
  "<!--<!--" |> xmlm_signals_should_be_error
}

pub fn comment_err_13__test() {
  "<!--<!--!" |> xmlm_signals_should_be_error
}

pub fn comment_err_14__test() {
  "<!--<!--!>" |> xmlm_signals_should_be_error
}

pub fn comment_err_15__test() {
  "<!--<!---" |> xmlm_signals_should_be_error
}

pub fn comment_err_16__test() {
  "<!--<!--x" |> xmlm_signals_should_be_error
}

pub fn comment_err_17__test() {
  "<!--<!--x-" |> xmlm_signals_should_be_error
}

pub fn comment_err_18__test() {
  "<!--<!--x--" |> xmlm_signals_should_be_error
}

pub fn comment_err_19__test() {
  "<!--<!--x-->" |> xmlm_signals_should_be_error
}

pub fn comment_err_20__test() {
  "<!--<!-x" |> xmlm_signals_should_be_error
}

pub fn comment_err_21__test() {
  "<!--<!-x-" |> xmlm_signals_should_be_error
}

pub fn comment_err_22__test() {
  "<!--<!-x--" |> xmlm_signals_should_be_error
}

pub fn comment_err_23__test() {
  "<!--<!x" |> xmlm_signals_should_be_error
}

pub fn comment_err_24__test() {
  "<!--<!x-" |> xmlm_signals_should_be_error
}

pub fn comment_err_25__test() {
  "<!--<!x--" |> xmlm_signals_should_be_error
}

pub fn comment_err_26__test() {
  "<!--<<!--x-->" |> xmlm_signals_should_be_error
}

pub fn comment_err_27__test() {
  "<!--<!<!--x-->" |> xmlm_signals_should_be_error
}

pub fn comment_err_28__test() {
  "<!--<!-<!--x-->" |> xmlm_signals_should_be_error
}

pub fn comment_err_29__test() {
  "<!----!->" |> xmlm_signals_should_be_error
}

pub fn comment_err_30__test() {
  "<!----!x>" |> xmlm_signals_should_be_error
}

pub fn comment_err_31__test() {
  "<!-----x>" |> xmlm_signals_should_be_error
}

pub fn comment_err_32__test() {
  "<!----->" |> xmlm_signals_should_be_error
}

pub fn comment_err_33__test() {
  "<!------>" |> xmlm_signals_should_be_error
}

pub fn comment_err_34__test() {
  "<!-- --->" |> xmlm_signals_should_be_error
}

pub fn comment_err_35__test() {
  "<!--a--->" |> xmlm_signals_should_be_error
}

// =============================================================================
// External tests: doctype.rs
// =============================================================================

// These all have an empty `p` tag stuck on there at the end, because without at
// least one root element, the parser will fail.

pub fn dtd_01__test() {
  "<!DOCTYPE greeting SYSTEM \"hello.dtd\"><p />" |> xmlm_signals_should_be_ok
}

pub fn dtd_02__test() {
  "<!DOCTYPE greeting PUBLIC \"hello.dtd\" \"goodbye.dtd\"><p />"
  |> xmlm_signals_should_be_ok
}

pub fn dtd_03__test() {
  "<!DOCTYPE greeting SYSTEM 'hello.dtd'><p />" |> xmlm_signals_should_be_ok
}

pub fn dtd_04__test() {
  "<!DOCTYPE greeting><p />" |> xmlm_signals_should_be_ok
}

pub fn dtd_05__test() {
  "<!DOCTYPE greeting []><p />" |> xmlm_signals_should_be_ok
}

pub fn dtd_06__test() {
  "<!DOCTYPE greeting><a/><p />" |> xmlm_signals_should_be_ok
}

pub fn dtd_07__test() {
  "<!DOCTYPE greeting [] ><p />" |> xmlm_signals_should_be_ok
}

pub fn dtd_08__test() {
  "<!DOCTYPE greeting [ ] ><p />" |> xmlm_signals_should_be_ok
}

pub fn dtd_entity_01__test() {
  "<!DOCTYPE svg [
    <!ENTITY ns_extend \"http://ns.adobe.com/Extensibility/1.0/\">
]><p />"
  |> xmlm_signals_should_be_ok
}

pub fn dtd_entity_02__test() {
  "<!DOCTYPE svg [
    <!ENTITY Pub-Status \"This is a pre-release of the
specification.\">|> xmlm_signals_should_be_ok

]><p />"
}

pub fn dtd_entity_03__test() {
  "<!DOCTYPE svg [
    <!ENTITY open-hatch SYSTEM \"http://www.textuality.com/boilerplate/OpenHatch.xml\">
]><p />"
  |> xmlm_signals_should_be_ok
}

pub fn dtd_entity_04__test() {
  "<!DOCTYPE svg [
    <!ENTITY open-hatch
             PUBLIC \"-//Textuality//TEXT Standard open-hatch boilerplate//EN\"
             \"http://www.textuality.com/boilerplate/OpenHatch.xml\">
]><p />"
  |> xmlm_signals_should_be_ok
}

pub fn dtd_entity_05__test() {
  "<!DOCTYPE svg [
    <!ENTITY hatch-pic SYSTEM \"../grafix/OpenHatch.gif\" NDATA gif >
]><p />"
  |> xmlm_signals_should_be_ok
}

pub fn dtd_entity_06__test() {
  "<!DOCTYPE svg [
    <!ELEMENT sgml ANY>
    <!ENTITY ns_extend \"http://ns.adobe.com/Extensibility/1.0/\">
    <!NOTATION example1SVG-rdf SYSTEM \"example1.svg.rdf\">
    <!ATTLIST img data ENTITY #IMPLIED>
]><p />"
  |> xmlm_signals_should_be_ok
}

pub fn dtd_err_01__test() {
  "<!DOCTYPEEG[<!ENTITY%ETT\u{000a}SSSSSSSS<D_IDYT;->\u{000a}<<p />"
  |> xmlm_signals_should_be_error
}

pub fn dtd_err_02__test() {
  "<!DOCTYPE s [<!ENTITY % name S YSTEM<p />" |> xmlm_signals_should_be_error
}

pub fn dtd_err_03__test() {
  "<!DOCTYPE s [<!ENTITY % name B<p />" |> xmlm_signals_should_be_error
}

pub fn dtd_err_04__test() {
  "<!DOCTYPE s []<p />" |> xmlm_signals_should_be_error
}

pub fn dtd_err_05__test() {
  "<!DOCTYPE s [] !<p />" |> xmlm_signals_should_be_error
}

// =============================================================================
// External tests: doctype.rs
// =============================================================================

pub fn document_01__test() {
  "" |> xmlm_signals_should_be_error
}

pub fn document_02__test() {
  "    " |> xmlm_signals_should_be_error
}

pub fn document_03__test() {
  " \n\t\r " |> xmlm_signals_should_be_error
}

pub fn document_05__test() {
  let b = bit_array.from_string("<a/>")
  <<0xEF, 0xBB, 0xBF, b:bits>>
  |> xmlm.from_bit_array
  |> xmlm.signals
  |> should.be_ok
}

pub fn document_06__test() {
  let b = bit_array.from_string("<?xml version='1.0'?><a/>")
  <<0xEF, 0xBB, 0xBF, b:bits>>
  |> xmlm.from_bit_array
  |> xmlm.signals
  |> should.be_ok
}

pub fn document_07__test() {
  "<?xml version='1.0' encoding='utf-8'?>\n<!-- comment -->\n
<!DOCTYPE svg PUBLIC '-//W3C//DTD SVG 1.1//EN' 'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd'><p/>"
  |> xmlm_signals_should_be_ok
}

pub fn document_08__test() {
  "<?xml-stylesheet?>\n
<!DOCTYPE svg PUBLIC '-//W3C//DTD SVG 1.1//EN' 'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd'><p/>"
  |> xmlm_signals_should_be_ok
}

pub fn document_09__test() {
  "<?xml version='1.0' encoding='utf-8'?>\n<?xml-stylesheet?>\n
<!DOCTYPE svg PUBLIC '-//W3C//DTD SVG 1.1//EN' 'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd'><p/>"
  |> xmlm_signals_should_be_ok
}

pub fn document_err_01__test() {
  "<![CDATA[text]]>" |> xmlm_signals_should_be_error
}

pub fn document_err_02__test() {
  " &www---------Ӥ+----------w-----www_" |> xmlm_signals_should_be_error
}

pub fn document_err_03__test() {
  "q" |> xmlm_signals_should_be_error
}

pub fn document_err_04__test() {
  "<!>" |> xmlm_signals_should_be_error
}

pub fn document_err_05__test() {
  "<!DOCTYPE greeting1><!DOCTYPE greeting2>" |> xmlm_signals_should_be_error
}

pub fn document_err_06__test() {
  "&#x20;" |> xmlm_signals_should_be_error
}

// =============================================================================
// External tests: elements.rs
// =============================================================================

pub fn element_01__test() {
  "<a/>"
  |> xmlm.from_string
  |> xmlm.signals
  |> result.map(pair.first)
  |> ok_exn
  |> xmlm.signals_to_string
  |> birdie.snap("xmlm_test.element_01__test")
}

pub fn element_02__test() {
  "<a></a>"
  |> xmlm.from_string
  |> xmlm.signals
  |> result.map(pair.first)
  |> ok_exn
  |> xmlm.signals_to_string
  |> birdie.snap("xmlm_test.element_02__test")
}

pub fn element_03__test() {
  "  \t  <a/>   \n "
  |> xmlm.from_string
  |> xmlm.signals
  |> result.map(pair.first)
  |> ok_exn
  |> xmlm.signals_to_string
  |> birdie.snap("xmlm_test.element_03__test")
}

pub fn element_04__test() {
  "  \t  <b><a/></b>   \n "
  |> xmlm.from_string
  |> xmlm.signals
  |> result.map(pair.first)
  |> ok_exn
  |> xmlm.signals_to_string
  |> birdie.snap("xmlm_test.element_04__test")
}

pub fn element_06__test() {
  "<俄语 լեզու=\"ռուսերեն\">данные</俄语>"
  |> xmlm.from_string
  |> xmlm.with_encoding(xmlm.Utf8)
  |> xmlm.signals
  |> result.map(pair.first)
  |> ok_exn
  |> xmlm.signals_to_string
  |> birdie.snap("xmlm_test.element_06__test")
}

// You can't have namespaces without declarations.
pub fn element_07__test() {
  "<svg:circle></svg:circle>"
  |> xmlm.from_string
  |> xmlm.signals
  |> err_exn
  |> xmlm.input_error_to_string
  |> should.equal(
    "ERROR Position(line: 1, column: 12) unknown namespace prefix (svg)",
  )
}

// `:` is illegal at the start of a tag name
pub fn element_08__test() {
  "<:circle/>"
  |> xmlm.from_string
  |> xmlm.signals
  |> err_exn
  |> xmlm.input_error_to_string
  |> should.equal(
    "ERROR Position(line: 1, column: 2) character sequence illegal here (\":\")",
  )
}

pub fn element_err_01__test() {
  "<>" |> xmlm_signals_should_be_error
}

pub fn element_err_02__test() {
  "</" |> xmlm_signals_should_be_error
}

pub fn element_err_03__test() {
  "</a" |> xmlm_signals_should_be_error
}

pub fn element_err_04__test() {
  "<a x='test' /" |> xmlm_signals_should_be_error
}

pub fn element_err_05__test() {
  "<<" |> xmlm_signals_should_be_error
}

pub fn element_err_06__test() {
  "< a" |> xmlm_signals_should_be_error
}

pub fn element_err_07__test() {
  "< " |> xmlm_signals_should_be_error
}

pub fn element_err_08__test() {
  "<&#x9;" |> xmlm_signals_should_be_error
}

pub fn element_err_09__test() {
  "<a></a></a>" |> xmlm_signals_should_be_error
}

// TODO: this one will become an error once xmlm only accepts a single root
// document.
pub fn element_err_10__test() {
  "<a/><a/>" |> xmlm_signals_should_be_ok
}

pub fn element_err_11__test() {
  "<a></br/></a>" |> xmlm_signals_should_be_error
}

pub fn element_err_12__test() {
  "<svg:/>" |> xmlm_signals_should_be_error
}

pub fn element_err_13__test() {
  "
<root>
</root>
</root>"
  |> xmlm_signals_should_be_error
}

pub fn element_err_14__test() {
  "<-svg/>"
  |> xmlm_signals_should_be_error
}

pub fn element_err_15__test() {
  "<svg:-svg/>"
  |> xmlm_signals_should_be_error
}

pub fn element_err_16__test() {
  "<svg::svg/>"
  |> xmlm_signals_should_be_error
}

pub fn element_err_17__test() {
  "<svg:s:vg/>"
  |> xmlm_signals_should_be_error
}

pub fn element_err_18__test() {
  "<::svg/>"
  |> xmlm_signals_should_be_error
}

pub fn element_err_19__test() {
  "<a><"
  |> xmlm_signals_should_be_error
}

pub fn attribute_01__test() {
  "<a ax=\"test\"/>"
  |> xmlm_signals_from_string_exn
  |> pair.first
  |> should.equal([
    Dtd(None),
    ElementStart(Tag(Name("", "a"), [Attribute(Name("", "ax"), "test")])),
    ElementEnd,
  ])
}

pub fn attribute_02__test() {
  "<a ax='test'/>"
  |> xmlm_signals_from_string_exn
  |> pair.first
  |> should.equal([
    Dtd(None),
    ElementStart(Tag(Name("", "a"), [Attribute(Name("", "ax"), "test")])),
    ElementEnd,
  ])
}

pub fn attribute_03__test() {
  "<a b='test1' c=\"test2\"/>"
  |> xmlm_signals_from_string_exn
  |> pair.first
  |> should.equal([
    Dtd(None),
    ElementStart(
      Tag(Name("", "a"), [
        Attribute(Name("", "c"), "test2"),
        Attribute(Name("", "b"), "test1"),
      ]),
    ),
    ElementEnd,
  ])
}

pub fn attribute_04__test() {
  "<a b='\"test1\"' c=\"'test2'\"/>"
  |> xmlm_signals_from_string_exn
  |> pair.first
  |> should.equal([
    Dtd(None),
    ElementStart(
      Tag(Name("", "a"), [
        Attribute(Name("", "c"), "'test2'"),
        Attribute(Name("", "b"), "\"test1\""),
      ]),
    ),
    ElementEnd,
  ])
}

pub fn attribute_05__test() {
  "<c a=\"test1' c='test2\" b='test1\" c=\"test2'/>"
  |> xmlm_signals_from_string_exn
  |> pair.first
  |> should.equal([
    Dtd(None),
    ElementStart(
      Tag(Name("", "c"), [
        Attribute(Name("", "b"), "test1\" c=\"test2"),
        Attribute(Name("", "a"), "test1' c='test2"),
      ]),
    ),
    ElementEnd,
  ])
}

pub fn attribute_06__test() {
  "<c   a   =    'test1'     />"
  |> xmlm_signals_from_string_exn
  |> pair.first
  |> should.equal([
    Dtd(None),
    ElementStart(
      Tag(Name("", "c"), attributes: [Attribute(Name("", "a"), value: "test1")]),
    ),
    ElementEnd,
  ])
}

// We don't allow unknown namespaces.
pub fn attribute_07__test() {
  "<c q:a='b'/>"
  |> xmlm.from_string
  |> xmlm.signals
  |> err_exn
  |> xmlm.input_error_to_string
  |> should.equal(
    "ERROR Position(line: 1, column: 11) unknown namespace prefix (q)",
  )
}

pub fn attribute_err_01__test() {
  "<c az=test>" |> xmlm_signals_should_be_error
}

pub fn attribute_err_02__test() {
  "<c a>" |> xmlm_signals_should_be_error
}

pub fn attribute_err_03__test() {
  "<c a/>" |> xmlm_signals_should_be_error
}

pub fn attribute_err_04__test() {
  "<c a='b' q/>" |> xmlm_signals_should_be_error
}

pub fn attribute_err_05__test() {
  "<c a='<'/>" |> xmlm_signals_should_be_error
}

pub fn attribute_err_06__test() {
  "<c a='\u{1}'/>" |> xmlm_signals_should_be_error
}

pub fn attribute_err_07__test() {
  "<c a='v'b='v'/>" |> xmlm_signals_should_be_error
}

// =============================================================================
// External tests: pi.rs
// =============================================================================

// We need at least one "root" to make it parse: `<p />`

pub fn pi_01__test() {
  "<?xslt ma?><p />" |> xmlm_signals_should_be_ok
}

pub fn pi_02__test() {
  "<?xslt \t\n m?><p />" |> xmlm_signals_should_be_ok
}

pub fn pi_03__test() {
  "<?xslt?><p />" |> xmlm_signals_should_be_ok
}

pub fn pi_04__test() {
  "<?xslt ?><p />" |> xmlm_signals_should_be_ok
}

pub fn pi_05__test() {
  "<?xml-stylesheet?><p />" |> xmlm_signals_should_be_ok
}

pub fn pi_err_01__test() {
  "<??xml \t\n m?><p />" |> xmlm_signals_should_be_error
}

pub fn declaration_01__test() {
  "<?xml version=\"1.0\"?><p />" |> xmlm_signals_should_be_ok
}

pub fn declaration_02__test() {
  "<?xml version='1.0'?><p />" |> xmlm_signals_should_be_ok
}

pub fn declaration_03__test() {
  "<?xml version='1.0' encoding=\"UTF-8\"?><p />" |> xmlm_signals_should_be_ok
}

pub fn declaration_04__test() {
  "<?xml version='1.0' encoding='UTF-8'?><p />" |> xmlm_signals_should_be_ok
}

pub fn declaration_05__test() {
  "<?xml version='1.0' encoding='utf-8'?><p />" |> xmlm_signals_should_be_ok
}

// Note: this is an error for xmlm because we only accept certain encodings.
pub fn declaration_06__test() {
  "<?xml version='1.0' encoding='EUC-JP'?><p />"
  |> xmlm.from_string
  |> xmlm.signals
  |> err_exn
  |> xmlm.input_error_to_string
  |> should.equal(
    "ERROR Position(line: 1, column: 38) unknown encoding (euc-jp)",
  )
}

pub fn declaration_07__test() {
  "<?xml version='1.0' encoding='UTF-8' standalone='yes'?><p />"
  |> xmlm_signals_should_be_ok
}

pub fn declaration_08__test() {
  "<?xml version='1.0' encoding='UTF-8' standalone='no'?><p />"
  |> xmlm_signals_should_be_ok
}

pub fn declaration_09__test() {
  "<?xml version='1.0' standalone='no'?><p />" |> xmlm_signals_should_be_ok
}

pub fn declaration_10__test() {
  "<?xml version='1.0' standalone='no' ?><p />" |> xmlm_signals_should_be_ok
}

// Declaration with an invalid order
pub fn declaration_err_01__test() {
  "<?xml encoding='UTF-8' version='1.0'?><p />" |> xmlm_signals_should_be_error
}

pub fn declaration_err_02__test() {
  "<?xml version='1.0' encoding='*invalid*'?><p />"
  |> xmlm_signals_should_be_error
}

pub fn declaration_err_03__test() {
  "<?xml version='2.0'?><p />" |> xmlm_signals_should_be_error
}

pub fn declaration_err_04__test() {
  "<?xml version='1.0' standalone='true'?><p />" |> xmlm_signals_should_be_error
}

pub fn declaration_err_05__test() {
  "<?xml version='1.0' yes='true'?><p />" |> xmlm_signals_should_be_error
}

pub fn declaration_err_06__test() {
  "<?xml version='1.0' encoding='UTF-8' standalone='yes' yes='true'?><p />"
  |> xmlm_signals_should_be_error
}

pub fn declaration_err_07__test() {
  "\u{000a}<?xml\u{000a}&jg'];" |> xmlm_signals_should_be_error
}

pub fn declaration_err_08__test() {
  "<?xml \t\n ?m?><p />" |> xmlm_signals_should_be_error
}

pub fn declaration_err_09__test() {
  "<?xml \t\n m?><p />" |> xmlm_signals_should_be_error
}

// XML declaration allowed only at the start of the document.
pub fn declaration_err_10__test() {
  " <?xml version='1.0'?><p />" |> xmlm_signals_should_be_error
}

// XML declaration allowed only at the start of the document.
pub fn declaration_err_11__test() {
  "<!-- comment --><?xml version='1.0'?><p />" |> xmlm_signals_should_be_error
}

// Duplicate.
pub fn declaration_err_12__test() {
  "<?xml version='1.0'?><?xml version='1.0'?><p />"
  |> xmlm_signals_should_be_error
}

pub fn declaration_err_13__test() {
  "<?target \u{1}content><p />" |> xmlm_signals_should_be_error
}

// Note: this is not an error for xmlm because we do very light parsing of the
// declaration.
pub fn declaration_err_14__test() {
  "<?xml version='1.0'encoding='UTF-8'?><p />" |> xmlm_signals_should_be_ok
}

// Note: this is not an error for xmlm because we do very light parsing of the
// declaration.
pub fn declaration_err_15__test() {
  "<?xml version='1.0' encoding='UTF-8'standalone='yes'?><p />"
  |> xmlm_signals_should_be_ok
}

pub fn declaration_err_16__test() {
  "<?xml version='1.0'" |> xmlm_signals_should_be_error
}

// =============================================================================
// External tests: text.rs
// =============================================================================

pub fn text_01__test() {
  "<p>text</p>"
  |> xmlm.from_string
  |> xmlm.signals
  |> result.map(pair.first)
  |> should.equal(
    Ok([
      Dtd(None),
      ElementStart(Tag(Name("", "p"), [])),
      Data("text"),
      ElementEnd,
    ]),
  )
}

pub fn text_02__test() {
  "<p> text </p>"
  |> xmlm.from_string
  |> xmlm.signals
  |> result.map(pair.first)
  |> should.equal(
    Ok([
      Dtd(None),
      ElementStart(Tag(Name("", "p"), [])),
      Data(" text "),
      ElementEnd,
    ]),
  )
}

// 欄 is EF A4 9D. And EF can be mistreated for UTF-8 BOM.
pub fn text_03__test() {
  "<p>欄</p>"
  |> xmlm.from_string
  |> xmlm.signals
  |> result.map(pair.first)
  |> should.equal(
    Ok([
      Dtd(None),
      ElementStart(Tag(Name("", "p"), [])),
      Data("欄"),
      ElementEnd,
    ]),
  )
}

pub fn text_04__test() {
  "<p> </p>"
  |> xmlm.from_string
  |> xmlm.signals
  |> result.map(pair.first)
  |> should.equal(
    Ok([Dtd(None), ElementStart(Tag(Name("", "p"), [])), Data(" "), ElementEnd]),
  )
}

/// With stripping=True, you would get `Data("")` but that isn't valid so the
/// `Data` tag is dropped.
pub fn text_04_2__test() {
  "<p> </p>"
  |> xmlm.from_string
  |> xmlm.with_stripping(True)
  |> xmlm.signals
  |> result.map(pair.first)
  |> should.equal(
    Ok([Dtd(None), ElementStart(Tag(Name("", "p"), [])), ElementEnd]),
  )
}

pub fn text_04_3__test() {
  "<p></p>"
  |> xmlm.from_string
  |> xmlm.signals
  |> result.map(pair.first)
  |> should.equal(
    Ok([Dtd(None), ElementStart(Tag(Name("", "p"), [])), ElementEnd]),
  )
}

pub fn text_05__test() {
  "<p> \r\n\t </p>"
  |> xmlm.from_string
  |> xmlm.signals
  |> result.map(pair.first)
  |> should.equal(
    Ok([
      Dtd(None),
      ElementStart(Tag(Name("", "p"), [])),
      Data(" \n\t "),
      ElementEnd,
    ]),
  )
}

pub fn text_06__test() {
  "<p>&#x20;</p>"
  |> xmlm.from_string
  |> xmlm.signals
  |> result.map(pair.first)
  |> should.equal(
    Ok([Dtd(None), ElementStart(Tag(Name("", "p"), [])), Data(" "), ElementEnd]),
  )
}

pub fn text_07__test() {
  "<p>]></p>"
  |> xmlm.from_string
  |> xmlm.signals
  |> result.map(pair.first)
  |> should.equal(
    Ok([Dtd(None), ElementStart(Tag(Name("", "p"), [])), Data("]>"), ElementEnd]),
  )
}

pub fn text_err_01__test() {
  "<p>]]></p>" |> xmlm_signals_should_be_error
}

pub fn text_err_02__test() {
  "<p>\u{0c}</p>" |> xmlm_signals_should_be_error
}

// =============================================================================
// Basic properties
// =============================================================================

pub fn running_signals_on_the_same_input_twice__test() {
  let assert Ok(xml) = simplifile.read("test/test_files/snack.UTF8.xml")

  let input =
    xml
    |> xmlm.from_string
    |> xmlm.with_encoding(xmlm.Utf8)

  let assert Ok(#(signals_1, _input)) = xmlm.signals(input)
  let assert Ok(#(signals_2, _input)) = xmlm.signals(input)

  assert signals_1 == signals_2
}
