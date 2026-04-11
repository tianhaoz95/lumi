pub fn init_agent() -> String {
    "rig-initialized".to_string()
}

#[cfg(test)]
mod tests {
    #[test]
    fn init_agent_returns_expected() {
        assert_eq!(super::init_agent(), "rig-initialized");
    }
}
