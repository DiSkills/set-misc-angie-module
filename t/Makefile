ifneq (clean, $(MAKECMDGOALS))
	ifeq ($(ANGIE_MODULES),)
        $(error "please set ANGIE_MODULES environment variable to continue")
	endif
	ifeq ($(ANGIE_TESTS),)
        $(error "please set ANGIE_TESTS environment variable to continue")
	endif
	ifeq ($(TEST_ANGIE_BINARY),)
        $(error "please set TEST_ANGIE_BINARY environment variable to continue")
	endif
endif

WASMS=$(realpath ..)
WASMTIME=ngx_wasmtime_module.so

TESTS=$(wildcard *.t)
OBJS=$(addprefix objs/, $(TESTS))

PERLFLAGS=-I$(ANGIE_TESTS)/lib -v

.PHONY: test
test: $(OBJS)
	TEST_ANGIE_BINARY=$(TEST_ANGIE_BINARY) prove $(PERLFLAGS) $^

$(OBJS): | $(shell mkdir -p objs)
objs/%.t: %.t
	@cat $< | sed 's%WASM_ENGINE%$(WASMTIME)%g;s%WASMS%$(WASMS)%g;s%WASM_GLOBALS%%g;s%MODULES%$(ANGIE_MODULES)%g;' > $@

.PHONY: clean
clean:
	@rm -rf objs
