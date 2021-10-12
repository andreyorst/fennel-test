(require-macros :init-macros)
(local {: eq} (require "utils"))

(deftest "equality"
  (testing "primitive equality"
    (assert-is (eq 1 1))
    (assert-is (eq nil nil))
    (assert-is (eq false false))
    (assert-not (eq 1 2)))
  (testing "table comparison"
    (assert-is (eq []))
    (assert-is (eq [] []))
    (assert-is (eq [] {}))
    (assert-is (eq [1 2] [1 2]))
    (assert-not (eq [1] [1 2]))
    (assert-not (eq [1 2] [1]))
    (assert-not (eq {:a 1 :b 2} (doto {:a 1 :b 2} (table.insert 10))))
    (assert-not (eq [1 2 3] (doto [1 2 3] (tset :a 10))))
    (assert-is (eq [1 2 3] {1 1 2 2 3 3}))
    (assert-is (eq {4 1} [nil nil nil 1])))
  (testing "deep comparison"
    (assert-is (eq [[1 [2 [3]] {[5] {:a [1 [1 [1 [1]]]]}}]]
                   [[1 [2 [3]] {[5] {:a [1 [1 [1 [1]]]]}}]]))
    (assert-not (eq [[1 [2 [3]] {[5] {:a [1 [1 [1 [1]]]]}}]]
                    [[1 [2 [3]] {[6] {:a [1 [1 [1 [1]]]]}}]]))
    (assert-is (eq [1 [2]] [1 [2]]))
    (assert-is (eq [[1] [2]] [[1] [2]]))
    (assert-not (eq [[1] [2]] [[1] []]))
    (assert-not (eq [1 [2]] [1 [2 [3]]]))
    (assert-not (eq {:a {:b 2}} {:a {:b 3}})))
  (testing "comparing multiple values"
    (assert-is (eq 1 1 1))
    (assert-is (eq "1" "1" "1" "1"))
    (assert-is (eq true true true))
    (assert-not (eq 1 1 2))
    (assert-not (eq 2 1 1))
    (assert-not (eq 1 2 1))
    (assert-not (eq "1" "1" "2" "2"))
    (assert-not (eq nil nil 42))
    (assert-not (eq false false true))
    (assert-not (eq true true true "true"))
    (assert-is (eq [1] [1] [1]))
    (assert-is (eq [[1 2]] [[1 2]] [[1 2]]))
    (assert-is (eq [[1 [2 [3]] {[5] {:a [1 [1 [1 [1]]]]}}]]
                   [[1 [2 [3]] {[5] {:a [1 [1 [1 [1]]]]}}]]
                   [[1 [2 [3]] {[5] {:a [1 [1 [1 [1]]]]}}]]))
    (assert-not (eq [1] [1] [1 2]))
    (assert-not (eq [[1] [2]] [[1] [2]] [[2] [1]]))
    (assert-not (eq [[1 [2 [3]] {[5] {:a [1 [1 [1 [1]]]]}}]]
                    [[1 [2 [3]] {[5] {:a [1 [1 [1 [1]]]]}}]]
                    [[1 [2 [3]] {[6] {:a [1 [1 [1 [1]]]]}}]]))))
