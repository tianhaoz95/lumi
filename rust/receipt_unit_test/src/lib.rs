use serde::{Deserialize, Serialize};
use base64::{engine::general_purpose, Engine as _};

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

pub fn process_receipt_image(image_bytes: Vec<u8>) -> Result<ReceiptData, String> {
    if image_bytes.is_empty() {
        return Err("empty image bytes".to_string());
    }

    match std::str::from_utf8(&image_bytes) {
        Ok(s) => match serde_json::from_str::<ReceiptData>(s) {
            Ok(rd) => Ok(rd),
            Err(e) => Err(format!("json_parse_error: {}", e)),
        },
        Err(_e) => Err("non_utf8_bytes_not_supported_in_test_crate".to_string()),
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
    fn empty_bytes_returns_error() {
        let res = process_receipt_image(vec![]);
        assert!(res.is_err());
        assert_eq!(res.err().unwrap(), "empty image bytes");
    }
}
