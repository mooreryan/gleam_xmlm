project_name := "xmlm"
output_dir := "_output"

build:
  gleam build

check:
  gleam check

docs:
  gleam docs build

test:
  gleam test

build_erlang: build 

check_erlang: check

test_erlang: test

build_javascript:
  gleam build --target=javascript

check_javascript:
  gleam check --target=javascript

test_javascript:
  gleam test --target=javascript


check_both: check_erlang check_javascript

build_both: build_erlang build_javascript

test_both: test_erlang test_javascript

review_snaps:
  gleam run -m birdie

accept_all_snaps:
  gleam run -m birdie -- accept-all

reject_all_snaps:
  gleam run -m birdie -- reject-all

test_and_accept:
  gleam test ; gleam run -m birdie -- accept-all

mk_output_dir:
  mkdir -p {{ output_dir }}

bench_compare_erlang: mk_output_dir build_erlang
  #!/usr/bin/env bash
  set -euxo pipefail

  TIMESTAMP=$(date +%Y_%m_%d_%H_%M_%S)
  BENCH_OUT="{{ output_dir }}/bench_compare_erlang_33397721.${TIMESTAMP}.txt"

  echo "outfile: $BENCH_OUT"

  gleam run -m bench/bench_compare -- test/test_files/33397721.xml \
    2> $BENCH_OUT \
    && cat $BENCH_OUT \
    && grep '^# mean' $BENCH_OUT

bench_signals_erlang: mk_output_dir build_erlang
  #!/usr/bin/env bash
  set -euxo pipefail

  TIMESTAMP=$(date +%Y_%m_%d_%H_%M_%S)
  BENCH_OUT="{{ output_dir }}/bench_signals_erlang_33397721.${TIMESTAMP}.txt"
  BENCH_OUT_PLOT="{{ output_dir }}/bench_signals_erlang_33397721.${TIMESTAMP}.pdf"

  echo "outfile: $BENCH_OUT"

  gleam run -m bench/bench_signals -- test/test_files/33397721.xml \
    2> $BENCH_OUT \
    && grep '^# mean' $BENCH_OUT

  cat << EOF > yooo.txt
    library(ggplot2)

    df <- read.table(
      "$BENCH_OUT",
      sep = "|", col.names = c("bench", "time")
    )

    ggplot(df, aes(x = time, fill = bench)) + geom_density(alpha = 0.25)
    ggsave("$BENCH_OUT_PLOT")
  EOF

  Rscript --vanilla yooo.txt

  qpdfview "$BENCH_OUT_PLOT" &



bench_compare_javascript: mk_output_dir build_javascript
  #!/usr/bin/env bash
  set -euxo pipefail

  gleam run --target=javascript -m bench/bench_compare -- test/test_files/33397721.xml

bench_signals_javascript: mk_output_dir build_javascript
  #!/usr/bin/env bash
  set -euxo pipefail

  gleam run --target=javascript -m bench/bench_signals -- test/test_files/33397721.xml


erlgrind: mk_output_dir
  #!/usr/bin/env bash
  set -euxo pipefail

  TIMESTAMP=$(date +%Y_%m_%d_%H_%M_%S)

  erlgrind {{ output_dir }}/profile.fprof {{ output_dir }}/profile."${TIMESTAMP}".cgrind
  kcachegrind {{ output_dir }}/profile."${TIMESTAMP}".cgrind &

examples: build mk_output_dir
  #!/usr/bin/env bash
  set -euxo pipefail
  
  cd examples

  gleam build
  
  gleam run -m examples/small_usascii 2> {{ output_dir }}/small_usascii.txt
  gleam run -m examples/small_utf8 2> {{ output_dir }}/small_utf8.txt

examples_javascript: build mk_output_dir
  #!/usr/bin/env bash
  set -euxo pipefail
  
  cd examples

  gleam build --target=javascript
  
  gleam run -m small_usascii --target=javascript 2> {{ output_dir }}/small_usascii.txt
  gleam run -m small_utf8 --target=javascript 2> {{ output_dir }}/small_utf8.txt

parse_xml_file_erlang file:
  gleam run --target=erlang -m examples/parse_xml_file -- {{ file }}

parse_xml_file_javascript file:
  gleam run --target=javascript -m examples/parse_xml_file -- {{ file }}

count_elements_erlang file:
  gleam run --target=erlang -m examples/count_elements -- {{ file }}

count_elements_javascript file:
  gleam run --target=javascript -m examples/count_elements -- {{ file }}

gen_xmlconf_tests:
  #!/usr/bin/env bash
  set -euxo pipefail

  OUT=test/xmlconf/oasis/oasis_test.gleam

  if [[ -f $OUT  ]]; then 
    rm $OUT
  fi 
  
  gleam run -m xmlconf/oasis/gen
  gleam format

cov_javascript: build_javascript
  #!/usr/bin/env bash
  set -euxo pipefail

  COV_DIR=_coverage

  [[ -d "${COV_DIR}" ]] && rm -r "${COV_DIR}"
  mkdir -p "${COV_DIR}"

  TEST_RUNNER=./"${COV_DIR}"/test_runner.mjs
  
  cat << EOF > "${TEST_RUNNER}"
    import { test } from "node:test";
    import { main } from "../build/dev/javascript/{{ project_name }}/{{ project_name }}_test.mjs";
    test("suite", (_) => {
      main();
    })
  EOF

  cat "${TEST_RUNNER}" 

  # Run tests with coverage.
  node \
    --test \
    --experimental-test-coverage \
    --test-reporter=lcov  \
    --test-reporter-destination="./${COV_DIR}/cov_full.lcov" \
    "${TEST_RUNNER}"

  # Select files from this project.
  lcov \
    --extract "./${COV_DIR}/cov_full.lcov" '*{{ project_name }}*' \
    --output-file="./${COV_DIR}/cov_project.lcov"

  # Reject the actual test files from coverage report.
  lcov \
    --remove "./${COV_DIR}/cov_project.lcov" '*_test.mjs' \
    --output-file="./${COV_DIR}/cov_project_no_test.lcov"

  # Generate the html report.
  genhtml \
    --output-directory="./${COV_DIR}/html" \
    "./${COV_DIR}/cov_project_no_test.lcov"

  REPORT="./${COV_DIR}/html/index.html"

  [[ -f "${REPORT}" ]] && printf "report: ${REPORT}\n"

profile_javascript:
  #!/usr/bin/env bash
  set -euxo pipefail

  gleam run -m examples/parse_xml_file --target=javascript -- test/test_files/snack.UTF8.xml 1> /dev/null 2> /dev/null

  node --prof --no-logfile-per-isolate build/dev/javascript/xmlm/gleam.main.mjs _test_files/33397721_medium.xml >/dev/null
  node --prof-process v8.log > v8.processed.log
  rm v8.log
  mv v8.processed.log {{ output_dir }}

profile_javascript2:
  #!/usr/bin/env bash
  set -euxo pipefail

  gleam run -m examples/parse_xml_file --target=javascript -- test/test_files/snack.UTF8.xml 1> /dev/null 2> /dev/null

  node --cpu-prof --cpu-prof-interval=500 --no-logfile-per-isolate build/dev/javascript/xmlm/gleam.main.mjs _test_files/33397721_medium.xml >/dev/null
  mv *cpuprofile {{ output_dir }}
