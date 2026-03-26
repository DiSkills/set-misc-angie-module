ifneq (clean, $(MAKECMDGOALS))
	ifeq ($(ANGIE_WASM_SDK),)
        $(error "please set ANGIE_WASM_SDK environment variable to continue")
	endif
endif

RBG=bindgen
bind/ngx_wasi_core.rs: bind/ngx_wasi_core_inc.h
	$(RBG) $< -- -I$(ANGIE_WASM_SDK)/include > $@

wit/deps:
	ln -s $(ANGIE_WASM_SDK)/wit $@

.PHONY: clean
clean:
	@rm -f wit/deps
	@rm -f bind/ngx_wasi_core.rs
