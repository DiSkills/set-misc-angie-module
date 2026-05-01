use crate::angie::{call, log};

pub struct HandlerError {
    pub message: String,
    pub code: i32,
}

pub fn call_single_argument_variable_handler(
    call_env: i32, handler: fn(String) -> Result<String, HandlerError>,
) -> i32 {
    let mut app = match call::init_app(call_env, true) {
        Ok(v) => v, Err(err) => return err,
    };

    if app.argv.len() != 1 {
        log::log_error(
            app.log, log::Level::Err as u8, 0,
            String::from("error: exactly one argument is expected"),
        );
        return -1;
    }
    // app.argv has been moved, so it becomes empty
    let argument = app.argv.pop().unwrap();

    let result = match handler(argument) {
        Ok(v) => v,
        Err(err) => {
            log::log_error(app.log, log::Level::Err as u8, 0, err.message);
            return err.code;
        },
    };
    call::save_result(app, result.as_bytes().to_vec())
}

pub fn call_no_argument_variable_handler(
    call_env: i32, handler: fn() -> Result<String, HandlerError>,
) -> i32 {
    let app = match call::init_app(call_env, false) {
        Ok(v) => v, Err(err) => return err,
    };
    let result = match handler() {
        Ok(v) => v,
        Err(err) => {
            log::log_error(app.log, log::Level::Err as u8, 0, err.message);
            return err.code;
        },
    };
    call::save_result(app, result.as_bytes().to_vec())
}
