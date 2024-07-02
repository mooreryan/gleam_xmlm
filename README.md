# xmlm

Xmlm is a package for working with XML data in Gleam.

## Documentation & Usage

- For documentation and some usage examples, see the API docs in `src/xmlm.gleam`
- For complete XML processing examples, see the `test/examples` directory.

## Hacking

Check out the `justfile` for various utilities and helpers.  (You will need [just](https://just.systems/) installed to use it.)

### XML Conformance Tests

- XML Conformance tests are located in `test/xmlconf`. 
  - Within each subdirectory, there is a `gen.gleam` file that auto-generates the tests.
  - These files include some rules about when tests that are expected to fail according to the spec will actually pass in this package, and vice-versa.
- Corresponding XML test files are located in `test/test_files/xmlconf`. 
- To generate the tests, run `just gen_xmlconf_tests`.
  - Currently, only the oasis tests are used, but more will be incorporated.

### Benchmarks

You can run various benchmarks with:

- `just bench_compare_erlang`
- `just bench_compare_javascript`
- `just bench_signals_erlang`
- `just bench_signals_javascript`

Note that the JavaScript benchmarks are fairly slow to run.

### Profiling Erlang Code

Run the Erlang shell with `gleam shell`.  Then input the following:

```
fprof:trace(start).
bench@run_in_shell:main().
fprof:trace(stop).
fprof:profile().
fprof:analyse({dest, "_output/profile.fprof"}).
```

Once that finishes (it shouldn't take more than a few moments), then run `just erlgrind` to view the profile with kchachegrind.

Note that this requires both [kcachegrind](https://kcachegrind.sourceforge.net/html/Home.html) and [erlgrind](https://github.com/isacssouza/erlgrind) to be installed.

## Roadmap

- [ ] Accept input sources other than string or bit array.  (Ideally, some sort of abstraction that would also allow processing a stream of data.)

## Acknowledgements

Very heavily inspired by OCaml's [xmlm](https://erratique.ch/software/xmlm) package by Daniel Bünzli.

## License

[![license MIT or Apache
2.0](https://img.shields.io/badge/license-MIT%20or%20Apache%202.0-blue)](https://github.com/mooreryan/gleam_qcheck)

Copyright (c) 2024 Ryan M. Moore

Licensed under the Apache License, Version 2.0 or the MIT license, at your option. This program may not be copied, modified, or distributed except according to those terms.