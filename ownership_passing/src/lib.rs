extern crate libc;

use libc::{c_void, size_t};

use std::ops::Deref;
use std::thread;
use std::time::Duration;

struct SwiftObjectWrapper(SwiftObject);

impl Deref for SwiftObjectWrapper {
    type Target = SwiftObject;

    fn deref(&self) -> &SwiftObject {
        &self.0
    }
}

impl Drop for SwiftObjectWrapper {
    fn drop(&mut self) {
        (self.destroy)(self.user);
    }
}

#[repr(C)]
pub struct RustByteSlice {
    pub bytes: *const u8,
    pub len: size_t,
}

impl<'a> From<&'a str> for RustByteSlice {
    fn from(s: &'a str) -> Self {
        RustByteSlice {
            bytes: s.as_ptr(),
            len: s.len() as size_t,
        }
    }
}

#[repr(C)]
pub struct SwiftObject {
    user: *mut c_void,
    destroy: extern fn(user: *mut c_void),
    callback_with_int_arg: extern fn(user: *mut c_void, arg: i32),
}

unsafe impl Send for SwiftObject {}

#[no_mangle]
pub extern fn give_object_to_rust(obj: SwiftObject) {
    println!("moving SwiftObject onto a new thread created by Rust");
    let obj = SwiftObjectWrapper(obj);
    thread::spawn(move|| {
        thread::sleep(Duration::new(1, 0));
        (obj.callback_with_int_arg)(obj.user, 10);
    });
}

#[derive(Debug)]
pub struct NamedData {
    name: String,
    data: Vec<i32>,
}

impl Drop for NamedData {
    fn drop (&mut self) {
        println!("{:#?} is being deallocated", self);
    }
}

#[no_mangle]
pub extern fn named_data_new() -> *mut NamedData {
    let named_data = NamedData{
        name: "some data".to_string(),
        data: vec![1, 2, 3, 4, 5],
    };

    let boxed_data = Box::new(named_data);

    Box::into_raw(boxed_data)
}

#[no_mangle]
pub unsafe extern fn named_data_destroy(data: *mut NamedData) {
    let _ = Box::from_raw(data);
}

#[no_mangle]
pub unsafe extern fn named_data_get_name(named_data: *const NamedData) -> RustByteSlice {
    let named_data = &*named_data;
    RustByteSlice::from(named_data.name.as_ref())
}

#[no_mangle]
pub unsafe extern fn named_data_count(named_data: *const NamedData) -> size_t {
    let named_data = &*named_data;
    named_data.data.len() as size_t
}
