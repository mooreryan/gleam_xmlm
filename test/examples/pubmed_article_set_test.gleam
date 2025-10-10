import birdie
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/pair
import gleam/result
import gleam/string
import simplifile
import xmlm.{
  type Attribute, type Input, Data, Dtd, ElementEnd, ElementStart, Name, Tag,
}

pub fn pubmed_article_set__test() {
  let assert Ok(data) =
    simplifile.read_bits("test/examples/pubmed_article_set.xml")

  xmlm.from_bit_array(data)
  |> xmlm.with_stripping(True)
  |> xmlm.with_encoding(xmlm.Utf8)
  |> input_pubmed_article_set
  |> result.map(pair.first)
  |> ok_exn
  |> pubmed_article_set_to_string
  |> birdie.snap("pubmed_article_set_test.pubmed_article_set__test")
}

// =============================================================================
//
// MARK: Entity input
//
// =============================================================================

fn input_pubmed_article_set(
  input: Input,
) -> Result(#(PubmedArticleSet, Input), String) {
  use input <- result.try(accept_dtd(input))

  use input <- result.try(accept_element_start(input, "PubmedArticleSet"))

  use #(pubmed_articles, input) <- result.try(input_sequence(
    input,
    input_pubmed_article,
  ))

  // Eat </PubmedArticleSet>
  use input <- result.try(accept(input, ElementEnd))

  Ok(#(pubmed_articles, input))
}

fn input_pubmed_article(input: Input) -> Result(#(PubmedArticle, Input), String) {
  use input <- result.try(accept_element_start(input, "PubmedArticle"))
  // Note: we can assume this ordering because of the DTD, which must be
  // inspected manually.
  use input <- result.try(accept_element_start(input, "MedlineCitation"))

  use #(pmid, input) <- result.try(input_element(input, "PMID"))

  use input <- result.try(skip_to_element_start(input, "Article"))

  use #(article, input) <- result.try(input_article(
    input,
    PubmedArticle(..default_pubmed_article(), pmid: pmid),
  ))

  // Skip the remaining siblings of the Article
  use input <- result.try(skip_remaining_siblings(input))

  // Eat </Article>
  use input <- result.try(accept(input, ElementEnd))

  // Skip this element if it exists
  use input <- result.try(skip_element_and_any_children_named(
    input,
    "PubmedData",
  ))

  // Eat </PubmedArticle>
  use input <- result.try(accept(input, ElementEnd))

  Ok(#(article, input))
}

/// Handle the <Article> element
///
/// Note: the caller will need to advance the input to the next starting spot.
///
fn input_article(
  input: Input,
  // Will be used to accumulate the state from the element.
  pubmed_article: PubmedArticle,
) -> Result(#(PubmedArticle, Input), String) {
  use input <- result.try(accept_element_start(input, "Article"))

  use #(year, input) <- result.try({
    use input <- result.try(accept_element_start(input, "Journal"))
    use input <- result.try(skip_to_element_start_then_accept(
      input,
      "JournalIssue",
    ))
    use input <- result.try(skip_to_element_start(input, "PubDate"))
    use #(year, input) <- result.try(input_pub_date(input))

    // Eat </JournalIssue>
    use input <- result.try(accept(input, ElementEnd))

    // The Journal will optionally have these two at the end.
    use input <- result.try(skip_element_and_any_children_named(input, "Title"))
    use input <- result.try(skip_element_and_any_children_named(
      input,
      "ISOAbbreviation",
    ))

    // Eat </Journal>
    use input <- result.try(accept(input, ElementEnd))

    Ok(#(year, input))
  })

  use input <- result.try(skip_to_element_start(input, "ArticleTitle"))
  use #(title, input) <- result.try(input_element(input, "ArticleTitle"))

  // Next is `((Pagination, ELocationID*) | ELocationID+)`
  use #(doi, input) <- result.try(case xmlm.peek(input) {
    Error(e) -> Error(xmlm.input_error_to_string(e))
    Ok(#(ElementStart(Tag(Name("", "Pagination"), _)), input)) -> {
      // We need to skip over the pagination element
      use input <- result.try(skip_element_and_any_children(input))

      // Since we have seen a Pagination, ELocationID is now optional. So we
      // must check for it.
      case xmlm.peek(input) {
        Error(e) -> Error(xmlm.input_error_to_string(e))
        Ok(#(ElementStart(Tag(Name("", "ELocationID"), _)), input)) ->
          case input_doi(input) {
            Error(e) -> Error(e)
            Ok(#(Some(doi), input)) -> Ok(#(Some(doi), input))
            Ok(#(None, input)) -> Ok(#(None, input))
          }
        _ -> Ok(#(None, input))
      }
    }

    Ok(#(ElementStart(Tag(Name("", "ELocationID"), _)), input)) -> {
      use #(doi, input) <- result.map(input_doi(input))
      #(doi, input)
    }

    _ -> Error("expected Pagination or ELocationID tag")
  })

  // Abstracts are next, but they are optional.
  use #(abstract, input) <- result.try(input_abstract(input))

  // Next is the AuthorList, also optional.
  use #(authors, input) <- result.try(input_author_list(input))

  // We need to skip the remainder of the siblings (ie the children of <Article>)
  use input <- result.try(skip_remaining_siblings(input))

  // Eat </Article>
  use input <- result.try(accept(input, ElementEnd))

  Ok(#(
    PubmedArticle(
      ..pubmed_article,
      doi: doi,
      pub_year: year,
      title: title,
      abstract: abstract,
      authors: authors,
    ),
    input,
  ))
}

fn input_pub_date(input: Input) -> Result(#(String, Input), String) {
  case accept_element_start(input, "PubDate") {
    Error(e) -> Error(e)
    Ok(input) -> do_input_pub_date(input, 0, "")
  }
}

// We are required to have at least one of Year or MedlineDate.
fn do_input_pub_date(
  input: Input,
  depth: Int,
  date: String,
) -> Result(#(String, Input), String) {
  case xmlm.signal(input), depth {
    Error(e), _ -> Error(xmlm.input_error_to_string(e))
    Ok(#(ElementEnd, input)), 0 -> Ok(#(date, input))

    Ok(#(ElementEnd, input)), depth -> {
      // We still need to get to the closing PubDate tag.
      do_input_pub_date(input, depth - 1, date)
    }
    Ok(#(ElementStart(Tag(Name("", "Year"), _)), input)), depth
    | Ok(#(ElementStart(Tag(Name("", "MedlineDate"), _)), input)), depth
    -> {
      // We found the date we are looking for, so now get the data (data is
      // required here).
      case xmlm.signal(input) {
        Error(e) -> Error(xmlm.input_error_to_string(e))
        Ok(#(Data(date), input)) -> do_input_pub_date(input, depth + 1, date)
        Ok(#(signal, _)) ->
          Error("expected Data but got " <> string.inspect(signal))
      }
    }
    Ok(#(ElementStart(_), input)), depth ->
      do_input_pub_date(input, depth + 1, date)
    Ok(#(Data(_), input)), depth -> do_input_pub_date(input, depth, date)
    Ok(#(Dtd(_), _)), _ -> Error("unexpected Dtd signal")
  }
}

// There can be 0 or 1 or more ELocationID tags, so we have to look for the one
// with the correct EIdType.
//
// There *probably* won't be multiple ELocationId tags with the doi type, but we
// won't be checking for that. If there are more than one, we are taking the
// first one that we find.
fn input_doi(input: Input) -> Result(#(Option(String), Input), String) {
  case xmlm.peek(input) {
    Error(e) -> Error(xmlm.input_error_to_string(e))
    Ok(#(ElementStart(Tag(Name("", "ELocationID"), attributes)), input)) -> {
      case get_attribute_value(attributes, "EIdType") {
        Ok("doi") -> {
          use #(doi, input) <- result.map(input_element(input, "ELocationID"))
          #(Some(doi), input)
        }
        Ok(_) -> {
          case input_element(input, "ELocationID") {
            Error(e) -> Error(e)
            Ok(#(_, input)) -> input_doi(input)
          }
        }
        Error(e) -> Error(e)
      }
    }
    Ok(#(signal, _)) ->
      Error("expected ELocationID tag but got " <> string.inspect(signal))
  }
}

fn input_abstract(input: Input) -> Result(#(Option(String), Input), String) {
  case xmlm.peek(input) {
    Error(e) -> Error(xmlm.input_error_to_string(e))
    Ok(#(ElementStart(Tag(Name("", "Abstract"), _)), input)) -> {
      use input <- result.try(accept_element_start(input, "Abstract"))

      use #(abstract_texts, input) <- result.try(input_abstract_text_sequence(
        input,
      ))

      // CopyrightInformation is an optional tag with no children.
      use input <- result.try(skip_element_and_any_children_named(
        input,
        "CopyrightInformation",
      ))

      // Eat </Abstract>
      use input <- result.try(accept(input, ElementEnd))

      let abstract = string.join(abstract_texts, " ")
      Ok(#(Some(abstract), input))
    }
    _ -> Ok(#(None, input))
  }
}

fn input_abstract_text_sequence(
  input: Input,
) -> Result(#(List(String), Input), String) {
  do_input_abstract_text_sequence(input, [])
}

fn do_input_abstract_text_sequence(
  input: Input,
  abstract_texts: List(String),
) -> Result(#(List(String), Input), String) {
  case xmlm.peek(input) {
    Error(e) -> Error(xmlm.input_error_to_string(e))
    Ok(#(ElementStart(Tag(Name("", "AbstractText"), _)), input)) -> {
      case input_element(input, "AbstractText") {
        Error(e) -> Error(e)
        Ok(#(abstract_text, input)) ->
          do_input_abstract_text_sequence(input, [
            abstract_text,
            ..abstract_texts
          ])
      }
    }
    // If you hit a CopyrightInformation or and End tag, then the sequence is
    // over.
    Ok(#(ElementStart(Tag(Name("", "CopyrightInformation"), _)), input))
    | Ok(#(ElementEnd, input)) -> {
      Ok(#(list.reverse(abstract_texts), input))
    }
    Ok(#(signal, _)) -> Error("unexpected signal: " <> string.inspect(signal))
  }
}

fn input_author_list(input: Input) -> Result(#(List(Author), Input), String) {
  // AuthorList has an attribute that says whether it is complete or not, but we
  // will ignore it here.
  use input <- result.try(accept_element_start(input, "AuthorList"))
  use #(authors, input) <- result.try(input_author_sequence(input))
  use input <- result.map(accept(input, ElementEnd))
  #(authors, input)
}

fn input_author_sequence(input: Input) -> Result(#(List(Author), Input), String) {
  do_author_sequence(input, [])
}

// TODO: convert this to not use try in the recursive section.
fn do_author_sequence(
  input: Input,
  authors: List(Author),
) -> Result(#(List(Author), Input), String) {
  case xmlm.peek(input) {
    Error(e) -> Error(xmlm.input_error_to_string(e))
    Ok(#(ElementStart(Tag(Name("", "Author"), _)), input)) -> {
      use input <- result.try(accept_element_start(input, "Author"))
      use #(name, input) <- result.try(input_author_name(input))
      // Identifier is optional, so you can't just skip to the next one.
      // use input <- result.try(skip_to_element_start(input, "Identifier"))
      use #(orcid, input) <- result.try(input_orcid(input))
      use input <- result.try(skip_remaining_siblings(input))

      // Eat </Author>
      use input <- result.try(accept(input, ElementEnd))

      let author = Author(name, orcid)
      do_author_sequence(input, [author, ..authors])
    }
    Ok(#(ElementEnd, input)) -> {
      Ok(#(list.reverse(authors), input))
    }
    Ok(#(signal, _)) -> Error("unexpected signal: " <> string.inspect(signal))
  }
}

/// Next tags should be either `Identifier` or `AffiliationInfo` or the next
/// `Author`
fn input_author_name(input: Input) -> Result(#(String, Input), String) {
  case xmlm.peek(input) {
    Error(e) -> Error(xmlm.input_error_to_string(e))
    Ok(#(ElementStart(Tag(Name("", "LastName"), _)), input)) -> {
      use #(name, input) <- result.try(input_element(input, "LastName"))
      use input <- result.try(skip_element_and_any_children_named(
        input,
        "ForeName",
      ))
      use input <- result.try(skip_element_and_any_children_named(
        input,
        "Initials",
      ))
      use input <- result.try(skip_element_and_any_children_named(
        input,
        "Suffix",
      ))
      Ok(#(name, input))
    }
    Ok(#(ElementStart(Tag(Name("", "CollectiveName"), _)), input)) ->
      input_element(input, "CollectiveName")
    Ok(#(signal, _)) ->
      Error(
        "expected StartTag with local name 'LastName' or 'CollectiveName', but got "
        <> string.inspect(signal),
      )
  }
}

// We are looking for an Identifier with the Source="ORCID" attribute.
// Identifiers are themselves optional, and even if there is an identifer, it
// may not be an ORCID.
//
// If by some chance there are multiple Identifiers with Source="ORCID", we
// aren't checking for it. Rather we're just taking the first one we find.
fn input_orcid(input: Input) -> Result(#(Option(String), Input), String) {
  case xmlm.peek(input) {
    Error(e) -> Error(xmlm.input_error_to_string(e))
    Ok(#(ElementStart(Tag(Name("", "Identifier"), attributes)), input)) -> {
      // Check if there is the correct source on this identifier.  Source is a
      // required attribute but it's value may not be what we expect.
      case get_attribute_value(attributes, "Source") {
        Ok("ORCID") -> {
          use #(orcid, input) <- result.map(input_element(input, "Identifier"))
          #(Some(orcid), input)
        }
        Ok(_) -> {
          case input_element(input, "Identifier") {
            Error(e) -> Error(e)
            Ok(#(_, input)) -> input_orcid(input)
          }
        }
        Error(e) -> Error(e)
      }
    }
    // AffiliationInfo may follow any identifiers, so if we are here then we're
    // done.
    Ok(#(ElementStart(Tag(Name("", "AffiliationInfo"), _)), input))
    | Ok(#(ElementEnd, input)) -> Ok(#(None, input))
    Ok(#(signal, _)) ->
      Error(
        "expected ElementStart with Identifier or AffiliationInfo, or an ElementEnd.  Got "
        <> string.inspect(signal),
      )
  }
}

// =============================================================================
//
// MARK: xmlm utils
//
// =============================================================================

/// `accept_dtd(input)` inputs the `Dtd` if it is the next `Signal`, or returns
/// an error if any other `Signal` is encountered.
///
/// *Note!* `Dtd` signals don't have corresponding `ElementEnd` signals, so the
/// caller need not address it.
///
fn accept_dtd(input: Input) -> Result(Input, String) {
  case xmlm.signal(input) {
    Error(e) -> Error(xmlm.input_error_to_string(e))
    Ok(#(xmlm.Dtd(_), input)) -> Ok(input)
    Ok(#(signal, _)) ->
      Error(
        "parse error -- expected Dtd signal, found " <> string.inspect(signal),
      )
  }
}

/// `accept(input, signal)` inputs the next `Signal` if it is equal to the given
/// `signal`, or returns an error if any other `Signal` is encountered.
///
/// *Note!*  If accepting and `ElementStart` signal, then the caller must handle
/// the corresponding `ElementEnd` signal.
///
fn accept(input: Input, expected_signal: xmlm.Signal) -> Result(Input, String) {
  // Using `peek` here rather than `signal` along with a more granular error
  // type, could allow the caller to make a decision on what to do if it is not
  // the expected signal.  But we won't deal with that for this example.
  case xmlm.signal(input) {
    Error(e) -> Error(xmlm.input_error_to_string(e))
    Ok(#(signal, input)) if signal == expected_signal -> Ok(input)
    Ok(#(signal, _)) ->
      Error(
        "parse error -- expected "
        <> string.inspect(expected_signal)
        <> ", found "
        <> string.inspect(signal),
      )
  }
}

/// `accept_element_start(input, expected_local_name)` inputs the next `Signal`
/// if it is an `ElementStart` signal with the given local name.  If that
/// element is not found, return an error.
///
/// *Note!* The caller must handle the corresponding `ElementEnd` signal.
///
fn accept_element_start(
  input: Input,
  expected_local_name: String,
) -> Result(Input, String) {
  // Using `peek` here rather than `signal` along with a more granular error
  // type, could allow the caller to make a decision on what to do if it is not
  // the expected signal.  But we won't deal with that for this example.
  case xmlm.signal(input) {
    Error(e) -> Error(xmlm.input_error_to_string(e))
    Ok(#(ElementStart(Tag(Name("", local_name), _)), input))
      if local_name == expected_local_name
    -> Ok(input)
    Ok(#(signal, _)) ->
      Error(
        "accept_element_start: expected ElementStart with local name "
        <> string.inspect(expected_local_name)
        <> ", found "
        <> xmlm.signal_to_string(signal),
      )
  }
}

/// `skip_element_and_any_children(input)` moves past the current element and
/// any of its children.
///
/// *Note!*  Be sure to read the docs for xmlm.tree as this uses the same
/// semantics as that function.
///
/// *Note!*  If the next signal is an `ElementStart` the corresponding
/// `ElementEnd` will be handled, and the caller need not handle it.
///
fn skip_element_and_any_children(input: Input) -> Result(Input, String) {
  case xmlm.tree(input, fn(_, _) { Nil }, fn(_) { Nil }) {
    Error(e) -> Error(xmlm.input_error_to_string(e))
    Ok(#(Nil, input)) -> Ok(input)
  }
}

/// `skip_element_and_any_children(input, expected_local_name)` moves past the
/// current element and / any of its children, if the current signal is an
/// `ElementStart` with a `Tag` that has a matching local name.
///
/// *Note!*  The caller does not need to handle the corresponding ElementEnd
/// signal.
///
fn skip_element_and_any_children_named(
  input: Input,
  with_local_name: String,
) -> Result(Input, String) {
  case xmlm.peek(input) {
    Error(e) -> Error(xmlm.input_error_to_string(e))
    Ok(#(ElementStart(Tag(Name("", local_name), _)), input))
      if local_name == with_local_name
    -> skip_element_and_any_children(input)
    Ok(#(_, input)) -> Ok(input)
  }
}

/// `input_element(input, local_name)` inputs a single element and get its data if it matches the given `local_name`.
///
/// *Note!*  This function handles the corresponding `ElementEnd` signal.
///
/// For an alternate way of parsing a simple element, see
/// `test/examples/person_test.do_input_basic_element`.
///
fn input_element(input: Input, name: String) -> Result(#(String, Input), String) {
  use input <- result.try(accept_element_start(input, name))

  use #(signal, input) <- result.try(
    xmlm.peek(input) |> result.map_error(xmlm.input_error_to_string),
  )

  use #(data, input) <- result.try(case signal {
    xmlm.Data(data) -> {
      use #(_, input) <- result.try(
        xmlm.signal(input) |> result.map_error(xmlm.input_error_to_string),
      )
      Ok(#(data, input))
    }
    ElementEnd -> Ok(#("", input))
    ElementStart(_) | xmlm.Dtd(_) ->
      Error("parse error: expected Data or ElementEnd")
  })
  use input <- result.map(accept(input, ElementEnd))
  #(data, input)
}

/// `input_sequence(input, element_callback)` inputs a sequence of elements with
/// the given `element_callback`.
///
/// *Note!*  The `element_callback` should input a whole element (and possibly
/// its children), and handle the corresponding `ElementEnd` signal.
///
fn input_sequence(
  input: Input,
  element_callback: fn(Input) -> Result(#(a, Input), String),
) -> Result(#(List(a), Input), String) {
  do_input_sequence(input, element_callback, [])
}

fn do_input_sequence(
  input: Input,
  element_callback: fn(Input) -> Result(#(a, Input), String),
  acc: List(a),
) -> Result(#(List(a), Input), String) {
  case xmlm.peek(input) {
    Error(e) -> Error(xmlm.input_error_to_string(e))
    Ok(#(ElementStart(_), input)) -> {
      case element_callback(input) {
        Error(e) -> Error(e)
        Ok(#(a, input)) ->
          do_input_sequence(input, element_callback, [a, ..acc])
      }
    }
    Ok(#(ElementEnd, input)) -> Ok(#(list.reverse(acc), input))
    Ok(#(_, _)) -> Error("expected either ElementStart or ElementEnd")
  }
}

/// `get_attribute_value(attributes, expected_local_name)` attempts to find the attribute with the given local name from a list of `attributes`.
///
fn get_attribute_value(
  attributes: List(Attribute),
  expected_local_name: String,
) -> Result(String, String) {
  use xmlm.Attribute(Name(_, _), value) <- result.map(
    list.find(attributes, fn(attribute) {
      let xmlm.Attribute(Name(_, local_name), _) = attribute
      local_name == expected_local_name
    })
    |> result.replace_error(
      "expected to find an attribute with local name " <> expected_local_name,
    ),
  )
  value
}

/// `skip_to_element_start(input, expected_local_name)` skips to the start of
/// the first `ElementStart` signal whose `Tag` has the given local name.
///
/// *Note!*  As written, this function can loop all the way to the end of the
/// document and hit an unexpected EOI error, so be careful to only call it in
/// scenarios in which you know that the expected element will be found.
///
fn skip_to_element_start(
  input: Input,
  expected_local_name: String,
) -> Result(Input, String) {
  case xmlm.peek(input) {
    Error(e) -> Error(xmlm.input_error_to_string(e))
    Ok(#(ElementStart(Tag(Name("", local_name), attributes: _)), input))
      if local_name == expected_local_name
    -> Ok(input)
    Ok(#(_, input)) ->
      case xmlm.signal(input) {
        Error(e) -> Error(xmlm.input_error_to_string(e))
        Ok(#(_, input)) -> skip_to_element_start(input, expected_local_name)
      }
  }
}

/// Like `skip_to_element_start` except that the element that the element is
/// also accepted.
///
/// *Note!*  The caller must deal with the corresponding `ElementEnd` singal.
fn skip_to_element_start_then_accept(
  input: Input,
  expected_local_name: String,
) -> Result(Input, String) {
  use input <- result.try(skip_to_element_start(input, expected_local_name))
  accept_element_start(input, expected_local_name)
}

/// `skip_remaining_siblings(input)` skips any remaining siblings at the same
/// depth as the last parsed `Signal`.
///
fn skip_remaining_siblings(input: Input) {
  do_skip_remaining_siblings(input, 0)
}

fn do_skip_remaining_siblings(input: Input, depth: Int) {
  case xmlm.peek(input), depth {
    Error(e), _ -> Error(xmlm.input_error_to_string(e))

    // if
    Ok(#(ElementEnd, input)), 0 -> Ok(input)
    Ok(#(ElementEnd, input)), depth -> {
      case xmlm.signal(input) {
        Error(e) -> Error(xmlm.input_error_to_string(e))
        Ok(#(_, input)) -> do_skip_remaining_siblings(input, depth - 1)
      }
    }
    Ok(#(ElementStart(_), input)), depth -> {
      case xmlm.signal(input) {
        Error(e) -> Error(xmlm.input_error_to_string(e))
        Ok(#(_, input)) -> do_skip_remaining_siblings(input, depth + 1)
      }
    }
    Ok(#(Data(_), input)), depth -> {
      case xmlm.signal(input) {
        Error(e) -> Error(xmlm.input_error_to_string(e))
        Ok(#(_, input)) -> do_skip_remaining_siblings(input, depth)
      }
    }
    Ok(#(Dtd(_), _)), _ -> Error("unexpected Dtd signal")
  }
}

// =============================================================================
//
// MARK: PubmedArticle
//
// =============================================================================

type PubmedArticleSet =
  List(PubmedArticle)

fn pubmed_article_set_to_string(pubmed_articles: PubmedArticleSet) -> String {
  "(pubmed_article_set\n"
  <> {
    list.map(pubmed_articles, pubmed_article_to_string(_, 1))
    |> string.join("\n")
  }
  <> ")"
}

type PubmedArticle {
  PubmedArticle(
    pmid: String,
    doi: Option(String),
    pub_year: String,
    title: String,
    abstract: Option(String),
    authors: List(Author),
  )
}

fn pubmed_article_to_string(pubmed_article: PubmedArticle, level: Int) -> String {
  let pmid =
    indent(level + 1) <> "(pmid " <> string.inspect(pubmed_article.pmid) <> ")"
  let doi =
    indent(level + 1)
    <> "(doi "
    <> {
      case pubmed_article.doi {
        Some(doi) -> "(" <> string.inspect(doi) <> ")"
        None -> "()"
      }
    }
    <> ")"
  let pub_year =
    indent(level + 1)
    <> "(pub_year "
    <> string.inspect(pubmed_article.pub_year)
    <> ")"
  let title =
    indent(level + 1)
    <> "(title "
    <> string.inspect(pubmed_article.title)
    <> ")"
  let abstract = abstract_to_string(pubmed_article.abstract, level + 1)

  let authors = authors_to_string(pubmed_article.authors, level + 2)

  indent(level)
  <> "(pubmed_article\n"
  <> pmid
  <> "\n"
  <> doi
  <> "\n"
  <> pub_year
  <> "\n"
  <> title
  <> "\n"
  <> abstract
  <> "\n"
  <> authors
  <> ")"
}

fn abstract_to_string(abstract, level) {
  indent(level)
  <> "(abstract "
  <> {
    case abstract {
      Some(abstract) -> {
        let excerpt = case string.length(abstract) > 80 {
          True -> {
            string.slice(abstract, 0, 40)
            <> "..."
            <> string.slice(abstract, -40, 40)
          }
          False -> abstract
        }
        "(" <> string.inspect(excerpt) <> ")"
      }
      None -> "()"
    }
  }
  <> ")"
}

fn default_pubmed_article() -> PubmedArticle {
  PubmedArticle("", None, "", "", None, [])
}

// =============================================================================
//
// MARK: Author
//
// =============================================================================

type Author {
  Author(name: String, orcid: Option(String))
}

fn authors_to_string(authors: List(Author), level: Int) -> String {
  let indent = string.pad_start("", to: level, with: "  ")
  indent
  <> "(authors\n"
  <> { list.map(authors, author_to_string(_, level + 1)) |> string.join("\n") }
  <> ")"
}

fn author_to_string(author: Author, level: Int) -> String {
  let name = "(name " <> string.inspect(author.name) <> ")"
  let orcid =
    "(orcid "
    <> {
      case author.orcid {
        Some(orcid) -> "(" <> string.inspect(orcid) <> ")"
        None -> "()"
      }
    }
    <> ")"

  indent(level) <> "(author " <> name <> " " <> orcid <> ")"
}

// =============================================================================
//
// MARK: Utils
//
// =============================================================================

fn indent(level: Int) -> String {
  string.pad_start("", to: level, with: "  ")
}

fn ok_exn(a) {
  let assert Ok(a) = a
  a
}
