use crate::{common, exports::angie::set_misc, Entry};

impl set_misc::hex::Guest for Entry {
    fn encode(call_env: i32) -> i32 {
        common::call_single_argument_variable_handler(call_env, encode)
    }

    fn decode(call_env: i32) -> i32 {
        common::call_single_argument_variable_handler(call_env, decode)
    }
}

fn encode(argument: String) -> Result<String, common::HandlerError> {
    Ok(hex::encode(argument))
}

fn decode(argument: String) -> Result<String, common::HandlerError> {
    let decoded = match hex::decode(argument) {
        Ok(v) => v,
        Err(_) => return Err(common::HandlerError {
            message: String::from("error: invalid hex string"), code: -1,
        }),
    };
    match String::from_utf8(decoded) {
        Ok(v) => Ok(v), Err(err) => panic!("Invalid UTF-8 sequence: {}", err),
    }
}
