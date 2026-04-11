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

/// Prepare a multimodal prompt by encoding the image as a base64 data URI and
/// injecting it into the receipt OCR prompt template.
/// The prompt template is embedded at compile time from `prompts/receipt_ocr.txt`.
pub fn prepare_receipt_ocr_prompt(image_bytes: &[u8]) -> Result<String, String> {
    if image_bytes.is_empty() {
        return Err("empty image bytes".to_string());
    }

    // Basic mime-type detection (PNG / JPEG fallback)
    let mime = if image_bytes.starts_with(&[0x89, b'P', b'N', b'G']) {
        "image/png"
    } else if image_bytes.starts_with(&[0xFF, 0xD8, 0xFF]) {
        "image/jpeg"
    } else {
        "application/octet-stream"
    };

    let b64 = general_purpose::STANDARD.encode(image_bytes);
    let data_uri = format!("data:{};base64,{}", mime, b64);

    // Include the prompt template at compile time. The file should exist at
    // `rust/lumi_core/src/prompts/receipt_ocr.txt`.
    let template = include_str!("prompts/receipt_ocr.txt");

    let prompt = format!("IMAGE: {}\n\n{}", data_uri, template);
    Ok(prompt)
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
        Err(_e) => {
            // Not UTF-8: prepare the multimodal prompt that would be sent to the model.
            // For now, return the prompt as an Err so higher layers can inspect it in tests.
            match prepare_receipt_ocr_prompt(&image_bytes) {
                Ok(prompt) => Err(format!("prepared_prompt: {}", prompt)),
                Err(e) => Err(e),
            }
        }
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
    fn prepare_prompt_contains_data_uri_and_template() {
        // minimal PNG header followed by some bytes
        let png_bytes = vec![0x89, b'P', b'N', b'G', 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x01, 0x02];
        let prompt = prepare_receipt_ocr_prompt(&png_bytes).expect("should prepare prompt");
        assert!(prompt.starts_with("IMAGE: data:image/png;base64,"));
        assert!(prompt.contains("You are a receipt parser"));
    }

    #[test]
    fn process_non_utf8_returns_prepared_prompt_error() {
        let png_bytes = vec![0x89, b'P', b'N', b'G', 0x00, 0x01, 0x02];
        let res = process_receipt_image(png_bytes);
        assert!(res.is_err());
        let err = res.err().unwrap();
        assert!(err.starts_with("prepared_prompt: "));
        // ensure the prepended IMAGE URI exists inside the error
        assert!(err.contains("data:image/png;base64,"));
    }

    #[test]
    fn empty_bytes_returns_error() {
        let res = process_receipt_image(vec![]);
        assert!(res.is_err());
        assert_eq!(res.err().unwrap(), "empty image bytes");
    }
}
