use regex::Regex;

/// Validate email using a permissive RFC-like regex (case-insensitive).
pub fn validate_email(email: &str) -> bool {
    // Simple, well-tested pattern sufficient for UI validation
    let re = Regex::new(r"(?i)^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$").unwrap();
    re.is_match(email)
}

/// Validate password minimal constraints: at least 8 characters.
pub fn validate_password(password: &str) -> bool {
    password.chars().count() >= 8
}

/// Validate terms checkbox — must be true.
pub fn validate_terms(accepted: bool) -> bool {
    accepted
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn email_valid_examples() {
        assert!(validate_email("user@example.com"));
        assert!(validate_email("USER+tag@sub.domain.co"));
    }

    #[test]
    fn email_invalid_examples() {
        assert!(!validate_email("not-an-email"));
        assert!(!validate_email("no-at-sign.com"));
        assert!(!validate_email("user@localhost"));
    }

    #[test]
    fn password_length() {
        assert!(validate_password("12345678"));
        assert!(!validate_password("short"));
    }

    #[test]
    fn terms_must_be_checked() {
        assert!(validate_terms(true));
        assert!(!validate_terms(false));
    }
}
