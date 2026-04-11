#[test]
fn build_script_runs() {
    // This trivial test ensures the lumi_core crate (and its build script) compiles
    // in the current host environment. The real verification for cross-target
    // linking should run in CI or on the target device with LITERT native libs.
    assert!(true);
}
