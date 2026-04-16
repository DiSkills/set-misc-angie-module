wit_bindgen::generate!({
    world: "angie-set-misc",
    generate_all,
});

mod angie;
mod base64;
mod common;
mod hash;

struct Entry;
export!(Entry);
