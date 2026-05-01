use crate::{common, exports::angie::set_misc, Entry};

impl set_misc::rotate::Guest for Entry {
    fn rotate(call_env: i32) -> i32 {
        common::call_variable_handler(call_env, rotate)
    }
}

static mut CURRENT: u64 = 0;

fn rotate(arguments: Vec<String>) -> Result<String, common::HandlerError> {
    if arguments.len() != 2 {
        return Err(common::HandlerError {
            message: String::from("error: expected 2 arguments"), code: -1,
        });
    }

    let mut from: u64 = match arguments[0].parse() {
        Ok(v) => v,
        Err(_) => return Err(common::HandlerError {
            message: format!("error: bad \"from\" argument: {}", arguments[0]), code: -1,
        }),
    };
    let mut to: u64 = match arguments[1].parse() {
        Ok(v) => v,
        Err(_) => return Err(common::HandlerError {
            message: format!("error: bad \"to\" argument: {}", arguments[1]), code: -1,
        }),
    };
    if from > to {
        std::mem::swap(&mut from, &mut to);
    }

    let current = unsafe {
        if CURRENT > to || CURRENT < from {
            CURRENT = from;
        }
        CURRENT += 1;

        CURRENT - 1
    };
    Ok(current.to_string())
}
