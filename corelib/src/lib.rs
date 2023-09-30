use keri_authorization::KeriWrapper;
use request_credential::check;
use serde_json::json;
use thiserror::Error;

pub mod keri_authorization;
pub mod acdc_authorization;
pub mod request_credential;

pub fn request_data_code(issuer_id: String, schema_said: String) -> String {
    let issuance_request_qr_code =
        json!({"r":"lend_house","i": &issuer_id,"s":schema_said});
    println!(
        "Issuance request: {}",
        serde_json::to_string_pretty(&issuance_request_qr_code).unwrap()
    );

    issuance_request_qr_code.to_string()
}

pub fn login(keri: KeriWrapper) -> Result<(), Error> {
    check(keri)
}

#[derive(Error, Debug)]
pub enum Error {
    #[error("Permision denied")]
    PremissionDenied,
    #[error("Authenticate error")]
    AuthenticateError,
}