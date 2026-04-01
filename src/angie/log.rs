#![allow(non_upper_case_globals)]
#![allow(non_camel_case_types)]
#![allow(non_snake_case)]
#![allow(dead_code)]

include!("../../bind/ngx_wasi_core.rs");

pub fn log_error(fd: i32, level: u8, errnum: i32, msg: String) {
    let mut message = ngx_wasi_core_string_t {
        ptr: msg.as_ptr() as *mut u8, len: msg.len(),
    };
    unsafe { exports_ngx_wasi_log_log_error(fd, level, errnum, &mut message) }
}
