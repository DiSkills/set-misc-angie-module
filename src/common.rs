#![allow(non_upper_case_globals)]
#![allow(non_camel_case_types)]
#![allow(non_snake_case)]
#![allow(dead_code)]

include!("../bind/ngx_wasi_core.rs");

use crate::angie::{call, log};

pub struct HandlerError {
    pub message: String,
    pub code: i32,
}

pub fn call_single_argument_variable_handler(
    call_env: i32, handler: fn(String) -> Result<String, HandlerError>,
) -> i32 {
    let app = match call::init_app(call_env, true) {
        Ok(v) => v, Err(err) => return err,
    };
    if app.argv.len != 1 {
        log::log_error(
            app.log, log::Level::Err as u8, 0,
            String::from("error: exactly one argument is expected"),
        );
        return -1;
    }

    let raw = unsafe { *app.argv.ptr };
    let argument = unsafe {
        match std::str::from_utf8(std::slice::from_raw_parts(raw.ptr, raw.len)) {
            Ok(v) => v, Err(err) => panic!("Invalid UTF-8 sequence: {}", err),
        }
    }.to_string();

    let result = match handler(argument) {
        Ok(v) => v,
        Err(err) => {
            log::log_error(app.log, log::Level::Err as u8, 0, err.message);
            return err.code;
        },
    };
    call::save_result(app, result.as_bytes().to_vec())
}
