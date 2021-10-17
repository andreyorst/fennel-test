;;; Directory Local Variables
;;; For more information see (info "(emacs) Directory Variables")

((fennel-mode . ((eval . (font-lock-add-keywords
                          'fennel-mode
                          `((,(rx word-start
                                  (group (or "deftest"
                                             "testing"
                                             "assert-eq"
                                             "assert-ne"
                                             "assert-is"
                                             "assert-not"
                                             "use-fixtures"))
                                  word-end)
                             1 'font-lock-keyword-face))))
                 (eval . (put 'deftest 'fennel-indent-function 'defun))
                 (eval . (put 'testing 'fennel-indent-function 'defun))
                 (eval . (put 'use-fixtures 'fennel-indent-function 1)))))
