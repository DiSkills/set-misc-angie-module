#![allow(non_upper_case_globals)]
#![allow(non_camel_case_types)]
#![allow(non_snake_case)]
#![allow(dead_code)]

include!("../bind/ngx_wasi_core.rs");

wit_bindgen::generate!({
    world: "angie-set-misc",
    generate_all,
});

use base64::Engine;
use base64::engine::general_purpose::STANDARD;

use ngx::wasi;

use crate::angie::call;
use crate::angie::log;

struct Entry;
export!(Entry);

impl exports::angie::set_misc::base64::Guest for Entry {
    fn encode(call_env: i32) -> i32 {
        let app = match call::init_app(call_env, true) {
            Ok(v) => v,
            Err(err) => return err,
        };
        if app.argv.len != 1 {
            log::log_error(
                app.log, wasi::log::Level::Err as u8, 0,
                String::from("error: exactly one argument is expected"),
            );
            return -1;
        }

        let s = unsafe { *app.argv.ptr };
        let encoded = STANDARD.encode(
            unsafe { std::slice::from_raw_parts(s.ptr, s.len) },
        );
        call::save_result(app, encoded.as_bytes().to_vec())
    }
}
