# xmlm

Xmlm is a pull-based XML parser for Gleam, in a similar style as the OCaml [xmlm](https://erratique.ch/software/xmlm/doc/Xmlm/index.html) library.

## Documentation & Usage

- For documentation and some usage examples, see the API docs in `src/xmlm.gleam`
- For complete XML processing examples, see the `test/examples` directory.
- Tests include XML spec conformance tests (currently the OASIS/NIST suite only), which also is currently serving as the "documentation" for where it diverges from the XML spec (i.e., in the same ways as the OCaml library on which it is based does), as well as the integration tests from this Rust library (https://github.com/RazrFalcon/xmlparser/tree/master/tests/integration).

## Hacking

Check out the `justfile` for various utilities and helpers. (You will need [just](https://just.systems/) installed to use it.)

### XML Conformance Tests

- XML Conformance tests are located in `test/xmlconf`.
  - Within each subdirectory, there is a `gen.gleam` file that auto-generates the tests.
  - These files include some rules about when tests that are expected to fail according to the spec will actually pass in this package, and vice-versa.
- Corresponding XML test files are located in `test/test_files/xmlconf`.
- To generate the tests, run `just gen_xmlconf_tests`.
  - Currently, only the oasis tests are used, but more will be incorporated.

### Benchmarks

There are some benchmarks in `test/bench`. There are some just recipes in the `justfile` that may help you out.

Note that the JavaScript benchmarks are fairly slow to run.

### Profiling Erlang Code

Run the Erlang shell with `gleam shell`. Then input the following:

```
fprof:trace(start).
bench@run_in_shell:main().
fprof:trace(stop).
fprof:profile().
fprof:analyse({dest, "_output/profile.fprof"}).
```

([fprof:apply](https://www.erlang.org/doc/apps/tools/fprof#apply/3) can be helpful here too.)

If you want to profile using a longer file, you can run the following instead.

```
Input = bench@run_in_shell:make_input("/home/ryan/projects/gleam/xmlm/test/test_files/33397721_long.xml").
fprof:trace(start).
bench@run_in_shell:no_op(Input).
fprof:trace(stop).
fprof:profile().
fprof:analyse({dest, "_output/profile.fprof"}).
```

(You can also use `bench@run_in_shell:count_start_signals(Input)` rather than `no_op`.)

Once either one of the above finishes running (it shouldn't take more than a few moments), then run `just erlgrind` to view the profile with kchachegrind.

Note that this requires both [kcachegrind](https://kcachegrind.sourceforge.net/html/Home.html) and [erlgrind](https://github.com/isacssouza/erlgrind) to be installed.

_Note: On MacOS, you could use [qcachegrind](https://formulae.brew.sh/formula/qcachegrind) rather than kcachegrind._

## Roadmap

- [ ] Accept input sources other than string or bit array. (Ideally, some sort of abstraction that would also allow processing a stream of data.)

## Acknowledgements

Very heavily inspired by OCaml's [xmlm](https://erratique.ch/software/xmlm) package by Daniel Bünzli. You can view licenses for those works in the `licenses` directory.

## License

[![license MIT or Apache
2.0](https://img.shields.io/badge/license-MIT%20or%20Apache%202.0-blue)](https://github.com/mooreryan/gleam_qcheck)

Copyright (c) 2024 Ryan M. Moore

Licensed under the Apache License, Version 2.0 or the MIT license, at your option. This program may not be copied, modified, or distributed except according to those terms.
