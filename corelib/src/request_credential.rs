use serde_json::json;
use thiserror::Error;

use crate::{keri_authorization::KeriWrapper, acdc_authorization::{check_acdc, AuthorizationError}};

pub fn request_data_code(issuer_id: String, schema_said: String) -> String {
    let issuance_request_qr_code =
        json!({"r":"dauthz_cred_req","i": &issuer_id,"s":schema_said});
    println!(
        "Issuance request: {}",
        serde_json::to_string_pretty(&issuance_request_qr_code).unwrap()
    );

    issuance_request_qr_code.to_string()
}

pub fn check(mut keri: KeriWrapper) -> Result<(), super::Error> {
    let stream = keri.get_data().unwrap();
    match keri.verify_stream(&stream) {
            Ok(verified_crudentials) => {
                match verified_crudentials
                    .iter()
                    .map(|cred| check_acdc(cred))
                    .collect::<Result<Vec<_>, AuthorizationError>>()
                {
                    Ok(_) => Ok(()),
                    Err(e) => {
                        println!("{}", e);
                        Err(super::Error::AuthenticateError)
                    }
                }
            }
            Err(e) => {
                println!("{}", e);
                Err(super::Error::PremissionDenied)
            }
        }
}

