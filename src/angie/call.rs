#![allow(non_upper_case_globals)]
#![allow(non_camel_case_types)]
#![allow(non_snake_case)]
#![allow(dead_code)]

include!("../../bind/ngx_wasi_core.rs");

pub fn init_app(call_env: i32, argv: bool) -> Result<ngx_wasi_app_state_t, i32> {
    let mut app = ngx_wasi_app_state_t {
        internal: 0, ctx: 0, log: 0,
        argv: ngx_wasi_app_str_array_t { ptr: std::ptr::null_mut(), len: 0, },
    };
    let mut err: i32 = -1;

    let res: bool = unsafe { exports_ngx_wasi_call_init_app(call_env, argv, &mut app, &mut err) };
    if res {
        Ok(app)
    } else {
        Err(err)
    }
}
