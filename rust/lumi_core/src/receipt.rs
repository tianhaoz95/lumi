use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, PartialEq, Clone)]
pub struct LineItem {
    pub description: String,
    pub amount: f64,
}

#[derive(Debug, Serialize, Deserialize, PartialEq, Clone)]
pub struct ReceiptData {
    pub vendor_name: String,
    pub total_amount: f64,
    pub currency: String,
    pub date: String,
    pub line_items: Vec<LineItem>,
}

/// Process raw image bytes and attempt to extract receipt data.
/// Current implementation: if bytes decode as UTF-8 JSON matching ReceiptData, parse and return it.
/// Otherwise returns an Err describing the failure. This is a deterministic, unit-testable stub
/// that will be replaced by a true multimodal OCR + model pipeline later.
pub fn process_receipt_image(image_bytes: Vec<u8>) -> Result<ReceiptData, String> {
    if image_bytes.is_empty() {
        return Err("empty image bytes".to_string());
    }

    // Try to interpret bytes as UTF-8 JSON (test-friendly stub)
    match std::str::from_utf8(&image_bytes) {
        Ok(s) => match serde_json::from_str::<ReceiptData>(s) {
            Ok(rd) => Ok(rd),
            Err(e) => Err(format!("json_parse_error: {}", e)),
        },
        Err(e) => Err(format!("not_utf8: {}", e)),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_valid_json_bytes() {
        let json = r#"
        {
          "vendor_name": "Corner Store",
          "total_amount": 12.34,
          "currency": "USD",
          "date": "2026-04-01",
          "line_items": [
            {"description":"Coffee","amount":3.5},
            {"description":"Sandwich","amount":8.84}
          ]
        }
        "#;
        let bytes = json.as_bytes().to_vec();
        let res = process_receipt_image(bytes).expect("should parse");
        assert_eq!(res.vendor_name, "Corner Store");
        assert!(res.total_amount > 0.0);
        assert_eq!(res.line_items.len(), 2);
    }

    #[test]
    fn invalid_json_returns_error() {
        let bytes = b"not a json".to_vec();
        let res = process_receipt_image(bytes);
        assert!(res.is_err());
        let msg = res.err().unwrap();
        assert!(msg.starts_with("not_utf8") || msg.starts_with("json_parse_error") || msg == "empty image bytes");
    }

    #[test]
    fn empty_bytes_returns_error() {
        let res = process_receipt_image(vec![]);
        assert!(res.is_err());
        assert_eq!(res.err().unwrap(), "empty image bytes");
    }
}
