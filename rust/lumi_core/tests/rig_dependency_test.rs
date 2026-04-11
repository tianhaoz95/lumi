#[test]
fn rig_dependency_works() {
    let s = rig_core::init_agent();
    assert_eq!(s, "rig-initialized");
}
