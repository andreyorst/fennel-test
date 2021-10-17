(require-macros :init-macros)

(local se {})

(use-fixtures :once
              (fn [t]
                (tset se :once (+ (or se.once 0) 1))
                (t)))

(use-fixtures :each
              (fn [t]
                (tset se :each (+ (or se.each 0) 1))
                (t)))

(deftest fixture-test-1
  (assert-eq se.once 1)
  (assert-eq se.each 1))

(deftest fixture-test-2
  (assert-eq se.once 1)
  (assert-eq se.each 2))

(deftest fixture-test-3
  (assert-eq se.once 1)
  (assert-eq se.each 3))
