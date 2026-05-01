use crate::{common, exports::angie::set_misc, Entry};

impl set_misc::random::Guest for Entry {
    fn range(call_env: i32) -> i32 {
        common::call_variable_handler(call_env, range)
    }
}

fn range(arguments: Vec<String>) -> Result<String, common::HandlerError> {
    if arguments.len() != 2 {
        return Err(common::HandlerError {
            message: String::from("error: expected 2 arguments"), code: -1,
        });
    }

    let mut from: u32 = match arguments[0].parse() {
        Ok(v) => v,
        Err(_) => return Err(common::HandlerError {
            message: format!("error: bad \"from\" argument: {}", arguments[0]), code: -1,
        }),
    };
    let mut to: u32 = match arguments[1].parse() {
        Ok(v) => v,
        Err(_) => return Err(common::HandlerError {
            message: format!("error: bad \"to\" argument: {}", arguments[1]), code: -1,
        }),
    };
    if from > to {
        std::mem::swap(&mut from, &mut to);
    }
    Ok(rand::random_range(from..=to).to_string())
}
