// Prompts module for receipt OCR
pub const RECEIPT_OCR_PROMPT: &str = include_str!("receipt_ocr.txt");

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn prompt_contains_required_phrases() {
        // Verify the prompt file includes the required JSON instruction and field names.
        let s = RECEIPT_OCR_PROMPT;
        assert!(s.contains("You are a high-precision receipt parser"), "prompt missing role instruction");
        assert!(s.contains("Respond ONLY with valid JSON" ) || s.contains("Respond only with valid JSON"), "prompt must instruct JSON-only output");
        assert!(s.contains("vendor_name"), "prompt must mention vendor_name");
        assert!(s.contains("total_amount"), "prompt must mention total_amount");
        assert!(s.contains("date"), "prompt must mention date");
    }
}
