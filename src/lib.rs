wit_bindgen::generate!({
    world: "angie-set-misc",
    generate_all,
});

mod angie;
mod base64;
mod common;

struct Entry;
export!(Entry);
