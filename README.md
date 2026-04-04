# Set Misc Angie Module

An incomplete analogue of [ngx_set_misc](https://github.com/openresty/set-misc-nginx-module) for Angie.
The module uses the [WebAssembly](https://habr.com/ru/articles/898022) extension.


## Dependencies

- [Rust](https://rust-lang.org):
    Requires the nightly version and the target wasm32-wasip1.
- [Angie](https://git.angie.software/web-server/angie):
    The web server for which this module is developed.
- [Angie WASM SDK](https://git.angie.software/web-server/angie-wasm-sdk):
    Provides interface definitions and libraries to build WASM modules for Angie
    with higher-level abstractions.
    The **default** version (static library) is used.
- [WASI SDK](https://github.com/WebAssembly/wasi-sdk):
    A WebAssembly System Interface (WASI) SDK that provides tools
    and libraries for building WebAssembly applications using WASI.
- [Bindgen 0.68.1](https://crates.io/crates/bindgen-cli/0.68.1):
    A tool to generate Rust FFI bindings to C/C++ libraries, used to create
    Angie WASM SDK bindings. Version **0.68.1 or lower** is required.
- [WASM Core](https://angie.software/angie/docs/configuration/modules/wasm):
    Implements basic WASM functionality in Angie.
- [Wasmtime](https://angie.software/angie/docs/configuration/modules/wasm/wasm_wasmtime):
    Angie module for the Wasmtime runtime.


## Build

1. Set the following environment variables:
    * `ANGIE_WASM_SDK` - path to the Angie WASM SDK directory (corresponding to `--prefix` key when building the SDK).
    * `WASI_SDK` - path to the WASI SDK directory (corresponding to `--wasi-sdk` key when building the SDK).
2. Run the build command:

        make


## Testing

1. Ensure the following dependencies are present in your system:
    * build-essential
    * libjson-perl
    * zlib1g
    * zlib1g-dev
2. Set the following environment variables:
    * The same environment variables as when building.
    * `ANGIE_MODULES` - path to the directory containing the installed Angie modules.
    * `ANGIE_TESTS` - path to the tests directory from the Angie source code.
    * `TEST_ANGIE_BINARY` - path to the Angie executable.
3. Run the test command:

        make test


## Examples of usage

### Set Base64 encode/decode

```nginx configuration
load_module modules/ngx_wasm_module.so;
load_module modules/ngx_wasm_core_module.so;
load_module modules/ngx_http_wasm_host_module.so;

load_module modules/ngx_wasmtime_module.so;

events {
}

wasm_modules {
    load set_misc_angie_module.wasm id=misc;
}

http {
    wasm_var misc "angie:set-misc/base64#encode" $encoded $arg_s;
    wasm_var misc "angie:set-misc/base64#decode" $decoded $arg_s;

    server {
        listen 127.0.0.1:8080;

        location /encode {
            return 200 $encoded;
        }
        
        location /decode {
            return 200 $decoded;
        }
    }
}
```

Requests and responses
```
GET /encode?s=123 HTTP/1.0 # MTIz
GET /decode?s=MTIz HTTP/1.0 # 123

# Logging in case of an incorrect string
GET /decode?s=InvalidBase64String HTTP/1.0 # error: invalid base64 string
```
