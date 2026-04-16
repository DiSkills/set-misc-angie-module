use crate::{common, exports::angie::set_misc, Entry};

impl set_misc::local::Guest for Entry {
    fn today(call_env: i32) -> i32 {
        common::call_no_argument_variable_handler(call_env, today)
    }
}

fn today() -> Result<String, common::HandlerError> {
    let now = chrono::Local::now();
    Ok(now.format("%Y-%m-%d").to_string())
}
