(local utils (if (and ... (not= ... :init-macros))
                 (.. ... :.utils)
                 :utils))

(fn string-len [s]
  (if (and _G.utf8 _G.utf8.len)
      (_G.utf8.len s)
      (length s)))

(fn assert-eq [expr1 expr2 msg]
  "Like `assert', except compares results of `expr1' and `expr2' for equality.
Generates formatted message if `msg' is not set to other message.

# Example
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
```"
  (let [s1 (view expr1 {:one-line? true})
        s2 (view expr2 {:one-line? true})
        formatted (if (> (string-len (.. "(eq )" s1 s2)) 80)
                      (string.format "(eq %s\n    %s)" s1 s2)
                      (string.format "(eq %s %s)" s1 s2))]
    `(let [{:eq eq#
            :tostring tostring#} (require ,utils)
           (lok# left#) (pcall (fn [] ,expr1))
           (rok# right#) (pcall (fn [] ,expr2))]
       (if (not lok#)
           (error (: "in expression:\n%s\n%s\n" :format ,s1 (tostring# left#)))
           (not rok#)
           (error (: "in expression:\n%s\n%s\n" :format ,s2 (tostring# right#)))
           (assert (eq# left# right#)
                   (string.format
                    "assertion failed for expression:\n%s\n Left: %s\nRight: %s\n%s"
                    ,formatted
                    (tostring# left#)
                    (tostring# right#)
                    ,(if msg `(.. " Info: " (tostring# ,msg)) ""))))
       nil)))

(fn assert-ne
  [expr1 expr2 msg]
  "Assert for unequality.  Like `assert', except compares results of
`expr1' and `expr2' for equality.  Generates formatted message if
`msg' is not set to other message.  Same as `assert-eq'."
  (let [s1 (view expr1 {:one-line? true})
        s2 (view expr2 {:one-line? true})
        formatted (if (> (string-len (.. "(not (eq ))" s1 s2)) 80)
                      (string.format "(not (eq %s\n         %s))" s1 s2)
                      (string.format "(not (eq %s %s))" s1 s2))]
    `(let [{:eq eq#
            :tostring tostring#} (require ,utils)
           (lok# left#) (pcall (fn [] ,expr1))
           (rok# right#) (pcall (fn [] ,expr2))]
       (if (not lok#)
           (error (: "in expression:\n%s\n%s\n" :format ,s1 (tostring# left#)))
           (not rok#)
           (error (: "in expression:\n%s\n%s\n" :format ,s2 (tostring# right#)))
           (assert (not (eq# left# right#))
                   (string.format
                    "assertion failed for expression:\n%s\n Left: %s\nRight: %s\n%s"
                    ,formatted
                    (tostring# left#)
                    (tostring# right#)
                    ,(if msg `(.. " Info: " (tostring# ,msg)) ""))))
       nil)))

(fn assert-is
  [expr msg]
  "Assert `expr' for truth. Same as inbuilt `assert', except generates more
  verbose message.

``` fennel
(assert-is (= 1 2 3))
;; => runtime error: assertion failed for (= 1 2 3)
```"
  `(let [{:tostring tostring#} (require ,utils)
         (suc# res#) (pcall (fn [] ,expr))]
     (if suc#
         (do (assert res# (string.format
                           "assertion failed for expression:\n%s\nResult: %s\n%s"
                           ,(view expr {:one-line? true})
                           (tostring res#)
                           ,(if msg `(.. "  Info: " (tostring# ,msg)) "")))
             nil)
         (error (string.format
                 "in expression: %s: %s\n"
                 ,(view expr {:one-line? true})
                 res#)))))

(fn assert-not
  [expr msg]
  "Assert `expr' for not truth. Generates more verbose message.  Works
the same as `assert-is'."
  `(let [{:tostring tostring#} (require ,utils)
         (suc# res#) (pcall (fn [] (not ,expr)))]
     (if suc#
         (do (assert res#
                     (string.format
                      "assertion failed for expression:\n(not %s)\nResult: %s\n%s"
                      ,(view expr {:one-line? true})
                      (tostring res#)
                      ,(if msg `(.. "  Info: " (tostring# ,msg)) "")))
             nil)
         (error (string.format
                 "in expression: (not %s): %s\n"
                 ,(view expr {:one-line? true})
                 res#)))))

(fn deftest
  [name ...]
  "Simple way of grouping tests with `name'.

# Example
``` fennel
(deftest some-test
  ;; tests
  )
```
"
  `(let [(_# test-ns#) ...]
     (fn ,name []
       ,...)
     (if (= :table (type test-ns#))
         (table.insert test-ns# [,(tostring name) ,name])
         (,name))))

(fn testing
  [_description ...]
  "Simply wraps code with a `description'.

# Example
``` fennel
(testing \"testing something\"
  ;; test body
  )
```
"
  `(do
     ,...))

(fn use-fixtures [once-each ...]
  (assert-compile (or (= once-each :once) (= once-each :each))
                  "Expected :once or :each as first argument"
                  once-each)
  `(let [(ns# test-ns#) ...]
     (each [_ fixture ,[...]]
       (tset test-ns# ,once-each ns#
             (+ 1 (length (. test-ns# ns#)))
             fixture))))

{: deftest
 : testing
 : assert-eq
 : assert-ne
 : assert-is
 : assert-not}
