(local fennel (require :fennel))
(local config {:seed (or (os.getenv "FENNEL_TEST_SEED") (os.time))})
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

(fn load-tests []
  (each [_ file (ipairs arg)]
    (let [module-name (module-from-file file)
          module-tests []]
      (table.insert tests [module-name module-tests])
      (fennel.dofile file {:env _G} module-name module-tests))))

(macro with-no-stdout [expr]
  "Suppress output to stderr."
  `(let [stdout-mt# (. (getmetatable io.stdout) :__index)
         write# stdout-mt#.write]
     (tset stdout-mt# :write (fn [fd# ...]
                               (when (not= fd# io.stdout)
                                 (write# fd# ...))))
     (let [res# (table.pack ,expr)]
       (tset stdout-mt# :write write#)
       (table.unpack res# 1 res#.n))))

(fn run-tests []
  (each [_ [ns tests] (ipairs tests)]
    (io.stdout:write "running tests for: " ns "\n")
    (io.stdout:write "(")
    (each [_ [test-name test-fn] (ipairs tests)]
      (match (with-no-stdout (pcall test-fn))
        (false msg) (do (io.stdout:write "F")
                        (table.insert errors [ns test-name msg]))
        _ (io.stdout:write ".")))
    (io.stdout:write ")"))
  (io.stdout:write "\n")
  (each [_ [ns test-name message] (ipairs errors)]
    (io.stderr:write "Error in " ns " in test " test-name ":\n" message "\n")))


(fn shuffle-tests []
  (each [_ [_ test-ns] (ipairs tests)]
    (for [i (length test-ns) 2 -1]
      (let [j (math.random i)
            test-ns-i (. test-ns i)]
        (tset test-ns i (. test-ns j))
        (tset test-ns j test-ns-i)))))

(fn print-stats []
  (io.stdout:write "Test run at " (os.date) ", seed: " config.seed "\n"))

(setup-runner)
(print-stats)
(load-tests)
(shuffle-tests)
(run-tests)
