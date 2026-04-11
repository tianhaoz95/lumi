extern crate proc_macro;
use proc_macro::TokenStream;
use quote::quote;
use syn::{parse_macro_input, AttributeArgs, ItemFn};

#[proc_macro_attribute]
pub fn tool(_attr: TokenStream, item: TokenStream) -> TokenStream {
    // For now, this attribute is a no-op that preserves the function unchanged.
    // In future, it may register metadata for the Rig orchestrator.
    item
}
