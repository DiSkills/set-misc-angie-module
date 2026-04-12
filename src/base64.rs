wit_bindgen::generate!({
    world: "angie-set-misc",
    generate_all,
});

use base64::engine::general_purpose::STANDARD;
use base64::Engine;

use crate::common;

struct Entry;
export!(Entry);

impl exports::angie::set_misc::base64::Guest for Entry {
    fn encode(call_env: i32) -> i32 {
        common::call_single_argument_variable_handler(call_env, encode)
    }

    fn decode(call_env: i32) -> i32 {
        common::call_single_argument_variable_handler(call_env, decode)
    }
}

fn encode(argument: String) -> Result<String, common::HandlerError> {
    Ok(STANDARD.encode(argument))
}

fn decode(argument: String) -> Result<String, common::HandlerError> {
    let decoded = match STANDARD.decode(argument) {
        Ok(v) => v,
        Err(_) => return Err(common::HandlerError {
            message: String::from("error: invalid base64 string"), code: -1,
        }),
    };
    match String::from_utf8(decoded) {
        Ok(v) => Ok(v), Err(err) => panic!("Invalid UTF-8 sequence: {}", err),
    }
}
