use acdc::{error::Error, Attestation, Attributes};

use thiserror::Error;

#[derive(Error, Debug)]
pub enum AuthorizationError {
    #[error(" ")]
    ACDCError(#[from] Error),
    #[error("Missing `passed` field in attributes section")]
    MissingPassedField,
    #[error("Wrong `passed` field type. Expected bool, found {0}")]
    WrongPassedType(String),
    #[error("ACDC parsing error")]
    ACDCParsingError,
    #[error("Passing not allowed")]
    NotAllowed,
}

pub fn check_acdc(stream: &str) -> Result<(), AuthorizationError> {
    let acdc: Attestation = serde_json::from_slice(stream.as_bytes())
        .map_err(|_e| AuthorizationError::ACDCParsingError)?;
    match acdc.attrs {
        Attributes::Inline(attributes) => {
            // TODO check oca schema.
            match attributes
                .attributes()
                .get("passed")
                .ok_or(AuthorizationError::MissingPassedField)?
            {
                serde_json::Value::Bool(true) => Ok(()),
                serde_json::Value::Bool(false) => Err(AuthorizationError::NotAllowed),
                value => Err(AuthorizationError::WrongPassedType(value.to_string())),
            }
        }
        Attributes::External(_) => todo!(),
    }
}

pub fn check(credentials: Vec<String>) -> Result<(), super::api::Error> {
    match credentials
        .iter()
        .map(|cred| check_acdc(cred))
        .collect::<Result<Vec<_>, AuthorizationError>>()
    {
        Ok(_) => Ok(()),
        Err(AuthorizationError::NotAllowed) => Err(super::api::Error::PremissionDenied),
        Err(e) => {
            println!("{}", e);
            Err(super::api::Error::AuthorizationError)
        }
    }
}

#[test]
pub fn test_check_acdc() {
    let acdc = r#"{"v":"ACDC10JSON0000d0_","d":"EGzqtlwbkkNAnAVKjdnSeGH2-_1JBFbJXHu-B35bPe7h","i":"EHtuebjH252H9hFmWKVUCEinVJ447ZJgMVebUa9brh_E","ri":"","s":"EnJtassrx8tT9u9g4Y5dOd3VcPGE9UHlAzKfbv3UG_a4","a":{"passed":false}}"#;
    let r = check_acdc(acdc);
    assert!(matches!(r, Err(AuthorizationError::NotAllowed)));
}
