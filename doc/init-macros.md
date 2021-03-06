# Init-macros.fnl (v0.0.3-dev)

**Table of contents**

- [`deftest`](#deftest)
- [`testing`](#testing)
- [`assert-eq`](#assert-eq)
- [`assert-ne`](#assert-ne)
- [`assert-is`](#assert-is)
- [`assert-not`](#assert-not)

## `deftest`
Function signature:

```
(deftest _name ...)
```

Simple way of grouping tests with `name`.

### Example
``` fennel
(deftest some-test
  ;; tests
  )
```

## `testing`
Function signature:

```
(testing description ...)
```

Print test `description` and run it.

### Example
``` fennel
(testing "testing something"
  ;; test body
  )
```

## `assert-eq`
Function signature:

```
(assert-eq expr1 expr2 msg)
```

Like `assert`, except compares results of `expr1` and `expr2` for equality.
Generates formatted message if `msg` is not set to other message.

### Example
Compare two expressions:

``` fennel
(assert-eq 1 (+ 1 2))
;; => runtime error: equality assertion failed
;; =>   Left: 1
;; =>   Right: 3
```

Deep compare values:

``` fennel
(assert-eq [1 {[2 3] [4 5 6]}] [1 {[2 3] [4 5]}])
;; => runtime error: equality assertion failed
;; =>   Left:  [1 {[2 3] [4 5 6]}]
;; =>   Right: [1 {[2 3] [4 5]}]
```

## `assert-ne`
Function signature:

```
(assert-ne expr1 expr2 msg)
```

Assert for unequality.  Like `assert`, except compares results of
`expr1` and `expr2` for equality.  Generates formatted message if
`msg` is not set to other message.  Same as [`assert-eq`](#assert-eq).

## `assert-is`
Function signature:

```
(assert-is expr msg)
```

Assert `expr` for truth. Same as inbuilt `assert`, except generates more
  verbose message.

``` fennel
(assert-is (= 1 2 3))
;; => runtime error: assertion failed for (= 1 2 3)
```

## `assert-not`
Function signature:

```
(assert-not expr msg)
```

Assert `expr` for not truth. Generates more verbose message.  Works
the same as [`assert-is`](#assert-is).


<!-- Generated with Fenneldoc v0.1.7
     https://gitlab.com/andreyorst/fenneldoc -->
