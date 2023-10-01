use serde_json::json;
use thiserror::Error;

pub fn request_data_code(issuer_id: String, schema_said: String) -> String {
    let issuance_request_qr_code = json!({"r":"lend_house","i": &issuer_id,"s":schema_said});
    println!(
        "Issuance request: {}",
        serde_json::to_string_pretty(&issuance_request_qr_code).unwrap()
    );

    issuance_request_qr_code.to_string()
}

pub fn authorize_qr_code(messagebox_oobi: String, schema_said: String) -> String {
    json!({"r":"login","o":messagebox_oobi,"s":schema_said}).to_string()
}

#[derive(Error, Debug)]
pub enum Error {
    #[error("Permision denied")]
    PremissionDenied,
    #[error("Authenticate error")]
    AuthenticateError,
    #[error("Authorization error")]
    AuthorizationError,
}
