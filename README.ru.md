# Set Misc Angie Module

Неполный аналог [ngx_set_misc](https://github.com/openresty/set-misc-nginx-module) для веб-сервера Angie.
Модуль использует расширение [WebAssembly](https://habr.com/ru/articles/898022).


## Зависимости

- [Rust](https://rust-lang.org):
    Требуется версия nightly и цель wasm32-wasip1.
- [Angie](https://git.angie.software/web-server/angie):
    Веб-сервер, для которого разрабатывается этот модуль.
- [Angie WASM SDK](https://git.angie.software/web-server/angie-wasm-sdk):
    Предоставляет определения интерфейсов и библиотеки для создания WASM-модулей для Angie
    с использованием высокоуровневых абстракций.
    Используется версия **по умолчанию** (static library).
- [WASI SDK](https://github.com/WebAssembly/wasi-sdk):
    SDK интерфейса WebAssembly System Interface (WASI), предоставляющий инструменты
    и библиотеки для создания приложений WebAssembly с использованием WASI.
- [Bindgen 0.68.1](https://crates.io/crates/bindgen-cli/0.68.1):
    Инструмент для генерации привязок Rust FFI к библиотекам C/C++, используемый для создания
    привязок Angie WASM SDK. Требуется версия **не выше 0.68.1**.
- [WASM Core](https://angie.software/angie/docs/configuration/modules/wasm):
    Реализует базовую функциональность WASM в Angie.
- [Wasmtime](https://angie.software/angie/docs/configuration/modules/wasm/wasm_wasmtime):
    Модуль Angie для среды выполнения Wasmtime.


## Сборка

1. Установить следующие переменные окружения:
    * `ANGIE_WASM_SDK` - путь к каталогу Angie WASM SDK (соответствует значению ключа `--prefix` при сборки SDK).
    * `WASI_SDK` - путь к каталогу WASI SDK (соответствует значению ключа `--wasi-sdk` при сборки SDK).
2. Запустить команду сборки:

        make


## Тестирование

1. Проверить наличие следующих зависимостей в системе:
    * build-essential
    * libjson-perl
    * zlib1g
    * zlib1g-dev
2. Установить следующие переменные окружения:
    * Переменные окружения такие же как при сборке.
    * `ANGIE_MODULES` - путь к каталогу, содержащему установленные модули Angie.
    * `ANGIE_TESTS` - путь к каталогу tests из исходного кода Angie.
    * `TEST_ANGIE_BINARY` - путь к исполняемому файлу Angie.
3. Запустить команду тестирования:

        make test


## Примеры использования

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

Запросы и ответы
```
GET /encode?s=123 HTTP/1.0 # MTIz
GET /decode?s=MTIz HTTP/1.0 # 123

# Логирование в случае некорректной строки
GET /decode?s=InvalidBase64String HTTP/1.0 # error: invalid base64 string
```
