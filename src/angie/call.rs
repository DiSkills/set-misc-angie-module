#![allow(non_upper_case_globals)]
#![allow(non_camel_case_types)]
#![allow(non_snake_case)]
#![allow(dead_code)]

use crate::angie::app::State;

include!("../../bind/ngx_wasi_core.rs");

pub fn init_app(call_env: i32, argv: bool) -> Result<State, i32> {
    let mut app = ngx_wasi_app_state_t {
        internal: 0, ctx: 0, log: 0,
        argv: ngx_wasi_app_str_array_t { ptr: std::ptr::null_mut(), len: 0, },
    };
    let mut err: i32 = -1;

    let res: bool = unsafe {
        exports_ngx_wasi_call_init_app(call_env, argv, &mut app, &mut err)
    };
    if res != true {
        return Err(err);
    }

    let mut args = Vec::new();
    let slice = unsafe {
        std::slice::from_raw_parts(app.argv.ptr, app.argv.len)
    };
    for el in slice.iter() {
        let item = *el;

        let arg = unsafe {
            match std::str::from_utf8(std::slice::from_raw_parts(item.ptr, item.len)) {
                Ok(v) => v, Err(e) => panic!("Invalid UTF-8 sequence: {}", e),
            }
        };
        args.push(arg.to_string());
    }
    Ok(State { internal: app.internal, ctx: app.ctx, log: app.log, argv: args })
}

pub fn save_result(app: State, buf: Vec<u8>) -> i32 {
    let mut b = exports_ngx_wasi_call_res_t {
        ptr: buf.as_ptr() as *mut u8, len: buf.len(),
    };
    let mut app = ngx_wasi_app_state_t {
        internal: app.internal, ctx: app.ctx, log: app.log,
        argv: ngx_wasi_app_str_array_t { ptr: std::ptr::null_mut(), len: 0, },
    };
    unsafe { exports_ngx_wasi_call_save_result(&mut app, &mut b) }
}
