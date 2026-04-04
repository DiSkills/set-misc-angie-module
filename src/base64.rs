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
}

fn encode(argument: String) -> Result<String, String> {
    Ok(STANDARD.encode(argument))
}
