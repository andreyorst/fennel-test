LUA ?= lua
FENNEL ?= fennel
VERSION ?=
FNLSOURCES = utils.fnl runner.fnl
FNLMACROS = init-macros.fnl
FNLTESTS = $(wildcard tests/*.fnl)
FNLDOCS = $(FNLMACROS) $(FNLSOURCES)
LUAEXECUTABLES ?= lua luajit
FENNELDOC := $(shell command -v fenneldoc)

.PHONY: help doc test

test: $(FNLTESTS)
	@echo "Testing on" $$($(LUA) -v) >&2
	@$(foreach test,$?,$(FENNEL) --lua $(LUA) --correlate $(test) || exit;)
# TODO: make possible to test documentation
# ifdef FENNELDOC
# 	@fenneldoc --mode check -- $(FNLDOCS) || exit
# else
# 	@echo "" >&2
# 	@echo "fenneldoc is not installed" >&2
# 	@echo "Please install fenneldoc to check documentation during testing" >&2
# 	@echo "https://gitlab.com/andreyorst/fenneldoc" >&2
# 	@echo "" >&2
# endif

doc:
ifdef FENNELDOC
ifdef VERSION
	fenneldoc --project-version $(VERSION) --config -- $(FNLMACROS) $(FNLSOURCES)
else
	fenneldoc -- $(FNLMACROS) $(FNLSOURCES)
endif
else
	@echo "" >&2
	@echo "fenneldoc is not installed" >&2
	@echo "Visit https://gitlab.com/andreyorst/fenneldoc for installation instructions" >&2
	@echo "" >&2
endif

help:
	@echo "make test -- run library tests" >&2
	@echo "make doc  -- create documentation with fenneldoc" >&2
	@echo "make help -- print this message and exit" >&2
