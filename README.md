# fennel-test

Simple testing library for Fennel.

This library consists of several macros that can be used to test various functions.
See the [doc](.doc/test.md) for what's available.

## Test runner

This library contains a test runner under the [runner](./runner) file, which can run tests accordingly to the `.fennel-test` configuration file.

Tests can be shuffled before each run with `FENNEL_TEST_SEED` environment variable or via `:seed` parameter in the `.fennel-test` file.
By default semi-random seed is picked on each invocation based on `os.time` and `os.clock` functions.

There are two predefined reporters: `:dots` and `:namespaces`, which can be chosen by setting `:reporter` key in the `.fennel-test` file.
The `:dots` reporter produces minimalist output which only marks start and end of each namespace, and indicates passed tests with a `.` and failed test with a `F`:

```
(...)(..)(....F..)(...)
Error in 'some-namespace' in test 'some-test':
error message
```

The `:namespaces` reporter is a bit more verbose, and prints name of each namespace, and overall status of the namespace, which is `PASS` if all tests have passed successfully, and `FAIL` otherwise:

```
some-namespace: FAIL
some-other-namespace: PASS
another-namespace :PASS
yet-another-one: PASS

Error in 'some-namespace' in test 'some-test':
error message
```

It is possible to create custom reporters using the reporter API.
Reporter is just a table with a predetermined set of functions:

- `ns-start` - Invoked before entering a namespace.
  Accepts the namespace's name.
- `ns-report` - Invoked after leaving a namespace.
  Accepts namespace's name, and exit status, which is `true`, if all tests passed, `false` otherwise.
- `test-start` - Invoked before the test.
  Accepts current namespace's name and test's name.
- `test-report` - Invoked after the test.
  Accepts test's exit status, namespace name, test name and error message, if any.
- `stats-report` - Invoked after whole test suite has finished, and accumulated all necessary stats.
  Currently only accepts `errors`, which is a table, where each element is a table of three elements: namespace, test name, and error message for the test.

For example, here's a more verbose reporter, that reports test errors immideatelly, without holding errors until full suite is finished, as other reporters do:

```fennel
(local example-reporter
  {:ns-start (fn [ns] (io.write "Testing '"ns "':\n"))
   :ns-report (fn [ns ok?] (io.write ns ": " (if ok? "PASS" "FAIL") "\n---\n"))
   :test-start (fn [_ns test-name] (io.write "  " test-name ": "))
   :test-report (fn [ok? _ns _test-name msg]
                  (io.write (if ok? "PASS" "FAIL") "\n")
                  (when (not ok?) (io.write "    Reason: " msg "\n")))
   :stats-report (fn [errors]
                   (if (> (length errors) 0)
                       (io.write "Test failure\n")
                       (io.write "Test passed\n")))})
```

Assigning it to the `reporter` key in the `.fennel-test` file will produce something like this:

```
Testing 'some-namespace':
  some-other-test: PASS
  some-test: FAIL
    Reason: error message
  another-some-other-test: PASS
  ...
some-namespace: FAIL
---
Testing 'some-other-namespace':
  another-test: PASS
  ...
some-other-namespace: PASS
---
Testing 'another-namespace':
  ...
another-namespace: PASS
---
Testing: 'yet-another-one':
  ...
yet-another-one: PASS
---
Test failure
```

This is a much more verbose reporter, but it may be usable for someone.

## Contributing

Please do.
You can report issues or feature request at [project's Gitlab repository](https://gitlab.com/andreyorst/fennel-test).
Consider reading [contribution guidelines](https://gitlab.com/andreyorst/fennel-test/-/blob/master/CONTRIBUTING.md) beforehand.
