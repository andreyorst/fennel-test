(local fennel (require :fennel))
(local config {:seed (tonumber (or (os.getenv "FENNEL_TEST_SEED") (os.time)))
               :runner :dots
               :shuffle? true})
(local tests [])
(local errors [])

(fn file-exists [file]
  (let [fh (io.open file)]
    (if fh (do (fh:close) true) false)))

(fn setup-runner []
  (when (file-exists ".fennel-test")
    (match (pcall fennel.dofile :.fennel-test)
      (true rc) (each [k v (pairs rc)]
                  (tset config k v))
      (false msg) (do
                    (io.stderr:write msg "\n")
                    (os.exit 1))))
  config)

(fn module-from-file [file]
  (let [sep (package.config:sub 1 1)
        module (-> file
                   (string.gsub sep ".")
                   (string.gsub "%.fnl$" ""))]
    module))

(fn deepcopy [x]
  ((fn deepcopy [x seen]
     (match  (type x)
       :table (match (. seen x)
                x* x*
                _ (let [res {}]
                    (tset seen x res)
                    (each [k v (pairs x)]
                      (tset res
                            (deepcopy k seen)
                            (deepcopy v seen)))
                    (setmetatable res (getmetatable x))))
       _ x))
   x {}))

(fn load-tests []
  (let [env _ENV
        g _G]
    (each [_ file (ipairs arg)]
      (let [module-name (module-from-file file)
            module-tests []]
        (set-forcibly! _ENV (deepcopy env))
        (set-forcibly! _G (deepcopy _G))
        (table.insert tests [module-name module-tests])
        (fennel.dofile file {:env _G} module-name module-tests)))
    (set-forcibly! _ENV env)
    (set-forcibly! _G g)))

(macro with-no-out [expr]
  "Suppress output to stderr."
  `(let [stdout-mt# (. (getmetatable io.stdout) :__index)
         write# stdout-mt#.write
         pack# #(doto [$...] (tset :n (select "#" $...)))]
     (tset stdout-mt# :write (fn [fd# ...]
                               (when (and (not= fd# io.stdout)
                                          (not= fd# io.stderr))
                                 (write# fd# ...))))
     (let [res# (pack# ,expr)]
       (tset stdout-mt# :write write#)
       (table.unpack res# 1 res#.n))))

(fn dots []
  (each [_ [ns tests] (ipairs tests)]
    (io.stdout:write "(")
    (each [_ [test-name test-fn] (ipairs tests)]
      (match (with-no-out (pcall test-fn))
        (false msg) (do (io.stdout:write "F")
                        (table.insert errors [ns test-name msg]))
        _ (io.stdout:write "."))
      (io.stdout:flush))
    (io.stdout:write ")"))
  (io.stdout:write "\n"))

(fn namespaces []
  (each [_ [ns tests] (ipairs tests)]
    (io.stdout:write ns ": ")
    (var ok? true)
    (if (> (length tests) 0)
        (do (each [_ [test-name test-fn] (ipairs tests)]
              (match (with-no-out (pcall test-fn))
                (false msg) (do (set ok? false)
                                (table.insert errors [ns test-name msg]))))
            (if ok?
                (io.stdout:write "PASS\n")
                (io.stdout:write "FAIL\n")))
        (io.stderr:write ns ": no tests\n"))))

(fn run-tests []
  (match config.runner
    :dots (dots)
    :namespaces (namespaces)
    (where runner (= :function (type runner))) (runner tests errors)
    _ (do (io.stderr "Warning: unknown runner '" (tostring _) "' using default: 'dots'\n")
          (dots))))

(fn print-errors []
  (each [_ [ns test-name message] (ipairs errors)]
    (io.stderr:write "Error in " ns " in test " test-name ":\n" message "\n")))


(fn shuffle-table [t]
  (for [i (length t) 2 -1]
    (let [j (math.random i)
          ti (. t i)]
      (tset t i (. t j))
      (tset t j ti))))

(fn shuffle-tests []
  (each [_ [_ test-ns] (ipairs tests)]
    (shuffle-table test-ns))
  (shuffle-table tests))

(fn print-stats []
  (io.stdout:write "Test run at " (os.date) ", seed: " config.seed "\n"))

(setup-runner)
(print-stats)
(load-tests)
(when config.shuffle?
  (shuffle-tests))
(run-tests)
(print-errors)

(when (> (length errors) 0)
  (os.exit 1))
