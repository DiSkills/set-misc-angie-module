ifneq (clean, $(MAKECMDGOALS))
	ifeq ($(ANGIE_WASM_SDK),)
        $(error "please set ANGIE_WASM_SDK environment variable to continue")
	endif
    ifeq ($(WASI_SDK),)
        $(error "please set WASI_SDK environment variable to continue")
    endif
endif

TARGET=wasm32-wasip1
BIN=target/$(TARGET)/release/set_misc_angie_module.wasm
WSDKLIBS=$(WASI_SDK)/share/wasi-sysroot/lib/wasm32-wasip1
RUSTFLAGS=-Zwasi-exec-model=reactor \
		  -lngx_wasi_core -L$(ANGIE_WASM_SDK)/lib \
		  -lc++ -L$(WSDKLIBS) -lc++abi

SRCS=$(shell find src -name "*.rs")
WITS=$(shell find wit -name "*.wit")

.PHONY: all
all: set_misc_angie_module.wasm

.PHONY: test
test: all
	make -C t test

$(BIN): $(SRCS) $(WITS) bind/ngx_wasi_core.rs wit/deps
	cargo rustc --target $(TARGET) --release -- $(RUSTFLAGS)

set_misc_angie_module.wasm: $(BIN)
	install -v $< $@

RBG=bindgen
bind/ngx_wasi_core.rs: bind/ngx_wasi_core_inc.h
	$(RBG) $< -- -I$(ANGIE_WASM_SDK)/include > $@

wit/deps:
	ln -s $(ANGIE_WASM_SDK)/wit $@

.PHONY: clean
clean:
	@cargo clean
	@rm -f set_misc_angie_module.wasm
	@rm -f wit/deps
	@rm -f bind/ngx_wasi_core.rs
	@make -C t clean
