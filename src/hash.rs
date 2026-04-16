use digest::{Digest};
use md5::{Md5};
use sha1::{Sha1};

use crate::{common, exports::angie::set_misc, Entry};

impl set_misc::hash::Guest for Entry {
    fn sha1(call_env: i32) -> i32 {
        common::call_single_argument_variable_handler(call_env, sha1)
    }

    fn md5(call_env: i32) -> i32 {
        common::call_single_argument_variable_handler(call_env, md5)
    }
}

fn sha1(argument: String) -> Result<String, common::HandlerError> {
    Ok(hex::encode(Sha1::digest(argument)))
}

fn md5(argument: String) -> Result<String, common::HandlerError> {
    Ok(hex::encode(Md5::digest(argument)))
}
