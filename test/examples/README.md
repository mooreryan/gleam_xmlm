# Examples

In this directory, you can find some full examples of using the xmlm library to parse some real(ish) XML data.

Some of the examples have a lot of function doc comments, but others could use some more.

It is probably best to start with the person example then the websites example, as the data is more straightforward.

## Person

This example (`person_test.gleam`) shows a basic XML parsing task with a simple XML file.

This example shows how to deal with optional tags and tags that may be appear in any order.

## Websites

This example (`websites_test.gleam`) shows how to parse XML data that essentially represents tabular data.

None of the data we are interested in parsing is contained in attributes, rather it is all in tags.

Though the data format is regular, this example suggests strategies for dealing with sequences of elements, as well as optional elements.

## Circles

This example (`circles_test.gleam`) shows how to parse a small SVG file (`circles.svg`).

This example is nice for showing how to deal with namespaces and for parsing out a lot of info from attributes in addition to info contained in the data of tags.

## PubMed article set

An example (`pubmed_article_set_test.gleam`) that parses out some information about articles from [NCBI's PubMed](https://pubmed.ncbi.nlm.nih.gov/) (`pubmed_article_set.xml`).

This example uses the corresponding `pubmed_240101.dtd` to guide the parsing.

This is real XML data from PubMed along with its actual DTD file.  The parsing task is inspired by some of my past projects, so it is reasonably representative example of a real-world XML parsing task.

Note: The code for this example is a bit messy and could use some clean up.