use std::{
    fs::File,
    io::Write,
    path::{Path, PathBuf},
    sync::Arc,
    thread,
    time::Duration,
};

use acdc::Attestation;
use controller::{
    config::ControllerConfig, error::ControllerError, identifier_controller::IdentifierController,
    BasicPrefix, Controller, IdentifierPrefix, LocationScheme, Oobi, PrivateKey, PublicKey,
    SeedPrefix,
};
use figment::{
    providers::{Format, Yaml},
    Figment,
};
use futures::future::join_all;
use said::derivation::{HashFunction, HashFunctionCode};
use serde::{Deserialize, Serialize};
use serde_json::json;
use thiserror::Error;
use tokio::runtime::Runtime;

pub struct KeriWrapper {
    pub controller: IdentifierController,
    keypair: (PublicKey, PrivateKey),
    pub last_index: usize,
}

#[derive(Error, Debug)]
pub enum AuthenticationError {
    #[error("Keri error: {0}")]
    Keri(#[from] ControllerError),
    #[error("Can't resolve following oobi: {0}")]
    OobiResolving(String),
    #[error("Can't parse cesr stream")]
    StreamParsing,
    #[error("Empty stream, nothing to parse")]
    EmptyStream,
    #[error("Runtime error")]
    Runtime(#[from] std::io::Error),
    #[error("Can't communicate to cread agent: {0}")]
    Communication(String),
    #[error("Credential revoked")]
    Revoked,
    #[error("Unknown credential")]
    UnknownCredential,
    #[error("Can't parse registry identifeir")]
    RegistryIdentifier,
}

#[derive(Deserialize, Serialize, Debug)]
struct IdentifierConfig {
    database_path: PathBuf,
    seed: String,
    watcher_oobi: Vec<LocationScheme>,
    witness_oobi: Vec<LocationScheme>,
    messagebox_oobi: Vec<LocationScheme>,
    last_index: usize,
}

impl Default for IdentifierConfig {
    fn default() -> Self {
        let default_watcher_oobi: LocationScheme = serde_json::from_str(r#"{"eid":"BF2t2NPc1bwptY1hYV0YCib1JjQ11k9jtuaZemecPF5b","scheme":"http","url":"http://watcher.sandbox.argo.colossi.network"}"#).unwrap();
        let default_witness_oobi: LocationScheme = serde_json::from_str(r#"{"eid":"BDg3H7Sr-eES0XWXiO8nvMxW6mD_1LxLeE1nuiZxhGp4","scheme":"http","url":"http://witness2.sandbox.argo.colossi.network/"}"#).unwrap();
        let default_messagebox_oobi: LocationScheme = serde_json::from_str(r#"{"eid":"BFY1nGjV9oApBzo5Oq5JqjwQsZEQqsCCftzo3WJjMMX-","scheme":"http","url":"http://messagebox.sandbox.argo.colossi.network/"}"#).unwrap();
        Self {
            database_path: PathBuf::from("./identifier_database"),
            seed: "AJZ7ZLd7unQ4IkMUwE69NXcvDO9rrmmRH_Xk3TPu9BpP".to_string(),
            watcher_oobi: vec![default_watcher_oobi],
            witness_oobi: vec![default_witness_oobi],
            messagebox_oobi: vec![default_messagebox_oobi],
            last_index: 0,
        }
    }
}

impl KeriWrapper {
    /// Loads machine identifier from provided config file. If file doesn't
    /// exist, generate new identifier, and save its data in provided file.
    pub async fn load_identifier(config_file: &Path) -> Result<KeriWrapper, AuthenticationError> {
        let loaded_config: Result<IdentifierConfig, _> =
            Figment::new().merge(Yaml::file(config_file)).extract();
        let create_config = &loaded_config.is_err();

        let config = loaded_config.unwrap_or_default();
        dbg!(&config);

        let controller_config = ControllerConfig {
            db_path: config.database_path.clone(),
            ..Default::default()
        };
        let controller = Arc::new(Controller::new(controller_config)?);
        let seed: &SeedPrefix = &config.seed.parse().unwrap();

        let (vk, sk) = seed.derive_key_pair().unwrap();
        let bp =
            IdentifierPrefix::Basic(BasicPrefix::Ed25519NT(controller::PublicKey::new(vk.key())));

        if *create_config {
            // No config yet. Save generated identifier in config file.
            println!("Saving default configuration in: {:?}", config_file);
            let mut file = File::create(config_file)?;
            file.write_all(serde_yaml::to_string(&config).unwrap().as_bytes())?;
        } else {
            println!("Using configuration from: {:?}", config_file);
        };

        println!("Machine identifier: {}", &bp.to_string());
        let identifier1 = IdentifierController::new(bp, controller.clone(), None);

        let identifier = KeriWrapper {
            controller: identifier1,
            keypair: (vk, sk),
            last_index: config.last_index,
        };
        // Configure watcher for verifying identifier
        identifier.configure_watcher(&config.watcher_oobi[0]).await?;
        identifier.configure_witness(&config.witness_oobi).await?;
        identifier.configure_messagebox(&config.messagebox_oobi[0]).await?;

        Ok(identifier)
    }

    async fn configure_watcher(&self, watcher_oobi: &LocationScheme) -> Result<(), AuthenticationError> {
        // let rt = Runtime::new().unwrap();
        // rt.block_on(async {
            self.controller
                .source
                .resolve_loc_schema(watcher_oobi)
                .await
                .map_err(|e| AuthenticationError::OobiResolving(e.to_string()))?;
            Ok::<_, AuthenticationError>(())?;
        // })?;

        let to_sign = self.controller.add_watcher(watcher_oobi.eid.clone())?;
        let private_key = &self.keypair.1;
        let signature = private_key.sign_ed(to_sign.as_bytes()).unwrap();

        // rt.block_on(async {
            self.controller
                .finalize_event(
                    to_sign.as_bytes(),
                    controller::SelfSigningPrefix::Ed25519Sha512(signature),
                )
                .await
                .map_err(AuthenticationError::Keri);
        // })?;
        println!("Watcher {} configured successfully.", watcher_oobi.eid);
        Ok(())
    }

    async fn configure_witness(
        &self,
        witness_oobis: &[LocationScheme],
    ) -> Result<(), AuthenticationError> {
        // let rt = Runtime::new().unwrap();
        // rt.block_on(async {
            for oobi in witness_oobis {
                let loc_oobi = Oobi::Location(oobi.clone());
                // Save obis locally
                self.controller
                    .source
                    .resolve_oobi(loc_oobi.clone())
                    .await
                    .unwrap();

                // Send witness oobi to watcher.
                self.controller
                    .source
                    .send_oobi_to_watcher(&self.controller.id, &loc_oobi)
                    .await
                    .unwrap();
                println!("Witness {} configured successfully.", &oobi.eid);
            };
        // });
        Ok(())
    }

    async fn configure_messagebox(&self, oobi: &LocationScheme) -> Result<(), AuthenticationError> {
        // let rt = Runtime::new().unwrap();
        // rt.block_on(async {
            self.controller
                .source
                .resolve_oobi(Oobi::Location(oobi.clone()))
                .await
                .unwrap();
            let messagebox_id = "BFY1nGjV9oApBzo5Oq5JqjwQsZEQqsCCftzo3WJjMMX-"
                .parse()
                .unwrap();
            let reply = self.controller.add_messagebox(messagebox_id).unwrap();
            let key: &PrivateKey = &self.keypair.1;
            let signature = key.sign_ed(reply.as_bytes()).unwrap();
            self.controller
                .finalize_event(
                    reply.as_bytes(),
                    controller::SelfSigningPrefix::Ed25519Sha512(signature),
                )
                .await
                .map_err(AuthenticationError::Keri)
                .unwrap();
        // });
        println!("Messagebox {} configured successfully.", &oobi.eid);

        Ok(())
    }

    pub(crate) async fn resolve_oobi(
        &mut self,
        signer_oobi: &Oobi,
    ) -> Result<(), AuthenticationError> {
        // let rt = Runtime::new()?;
        let signer_id = match &signer_oobi {
            Oobi::Location(lc) => lc.eid.clone(),
            Oobi::EndRole(er) => er.cid.clone(),
        };

        // rt.block_on(async {
        // Save oobi locally
        self.controller
            .source
            .resolve_oobi(signer_oobi.clone())
            .await?;
        // Send oobi to watcher
        self.controller
            .source
            .send_oobi_to_watcher(&self.controller.id, signer_oobi)
            .await?;

        // Generate query messages
        let queries = self.controller.query_own_watchers(&signer_id)?;

        // Sign them and send to watcher
        for qry in queries {
            let to_sign = qry.encode().unwrap();
            let key: &PrivateKey = &self.keypair.1;
            let signature = key.sign_ed(&to_sign).unwrap();

            self.controller
                .finalize_query(vec![(
                    qry,
                    controller::SelfSigningPrefix::Ed25519Sha512(signature),
                )])
                .await?;
        }
        Ok::<(), ControllerError>(());
        // })?;
        Ok(())
    }

    /// Parse CESR stream, and verify signatures. Returns list of ACDCs without signatures for further checks.
    pub(crate) async fn verify_stream(
        &mut self,
        stream: &str,
    ) -> Result<Vec<String>, AuthenticationError> {
        if !stream.is_empty() {
            let (oobis, creds) = self.controller.source.parse_cesr_stream(stream)?;
            for oobi in oobis {
                self.resolve_oobi(&oobi).await?
            }

            // Remove attachmens from acdcs
            let creds: Result<Vec<String>, _> = creds
                .into_iter()
                .map(|mut cred| {
                    cred.attachments = vec![];
                    String::from_utf8(cred.to_cesr().expect("Cesr error"))
                        .map_err(|_e| AuthenticationError::StreamParsing)
                })
                .collect();

            // get tel events for incoming said from witness
            join_all(
            creds
                .as_ref()
                .unwrap()
                .iter()
                .map(|cred| self.check_tel(cred.as_bytes()))
            ).await;
            creds
        } else {
            Err(AuthenticationError::EmptyStream)
        }
    }

    async fn check_tel(&self, cred: &[u8]) -> Result<(), AuthenticationError> {
        // let rt = Runtime::new()?;
        let acdc: Attestation = serde_json::from_slice(cred).unwrap();
        // .map_err(|_e| AuthorizationError::ACDCParsingError)?;
        let registry_id = acdc.registry_identifier;
        let issuer_id = acdc.issuer;
        // TODO should use digest
        let credential_id = HashFunction::from(HashFunctionCode::Blake3_256)
            .derive(cred)
            .to_string();
        // Generate query messages
        let query = self.controller.query_tel(
            registry_id
                .parse()
                .map_err(|_e| AuthenticationError::RegistryIdentifier)?,
            credential_id.parse().unwrap(),
        )?;

        // Sign them and send to witness
        let to_sign = query.encode().unwrap();
        let key: &PrivateKey = &self.keypair.1;
        let signature = key.sign_ed(&to_sign).unwrap();

        let issuer_id: IdentifierPrefix = issuer_id.parse().unwrap();
        // rt.block_on(async {
            self.controller
                .finalize_tel_query(
                    &issuer_id,
                    query,
                    controller::SelfSigningPrefix::Ed25519Sha512(signature),
                )
                .await
                .unwrap();
        // });

        let vc_state = self
            .controller
            .source
            .tel
            .get_vc_state(&credential_id.parse().unwrap())
            .unwrap();
        match vc_state {
            Some(controller::TelState::Issued(_)) => Ok(()),
            Some(controller::TelState::Revoked) => Err(AuthenticationError::Revoked),
            Some(controller::TelState::NotIssued) => Err(AuthenticationError::UnknownCredential),
            None => Err(AuthenticationError::UnknownCredential),
        }
    }

    // TODO
    pub fn messagebox_oobis(&self) -> Result<String, AuthenticationError> {
        let er = self
            .controller
            .source
            .get_messagebox_end_role(&self.controller.id)?;

        let loc = self
            .controller
            .source
            .get_messagebox_location(&self.controller.id)?;

        let out = format!(
            "{}{}",
            serde_json::to_string(loc.last().unwrap()).unwrap(),
            serde_json::to_string(er.last().unwrap()).unwrap()
        );
        Ok(out)
    }

    pub fn get_url(&self) -> String {
        let location = self
            .controller
            .source
            .get_messagebox_location(&self.controller.id)
            .unwrap();
        let location = location[0].clone();
        let _end_role = self
            .controller
            .source
            .get_messagebox_end_role(&self.controller.id)
            .unwrap()[0]
            .clone();

        format!("{}", location.url)
    }

    /// Request for credential every 2 seconds until it will get it.
    pub async fn get_data(&self) -> Result<String, AuthenticationError> {
        let url = self.get_url();
        println!("Expecting credential here: {}", url);
        let query = json!({"t":"qry","id": self.controller.id ,"sn":self.last_index}).to_string();
        println!("Post {} to {}", query, &url);
        let mut res = ureq::post(&url)
            .send_string(&query)
            .map_err(|e| AuthenticationError::Communication(e.to_string()))?;
        while res.status() == 204 {
            thread::sleep(Duration::from_secs(2));
            res = ureq::post(&url)
                .send_string(&query)
                .map_err(|e| AuthenticationError::Communication(e.to_string()))?;
        }
        let res = res.into_string()?;
        let out: Vec<String> = serde_json::from_str(&res).unwrap();
        Ok(out.join("").clone())
    }

    pub fn authorization_data(&self, schema_said: String) -> String {
        let messagebox_oobi = self.messagebox_oobis().unwrap();
        json!({"r":"login","o": messagebox_oobi,"s":schema_said}).to_string()
    }

    pub async fn process(&mut self) -> Result<Vec<String>, super::api::Error> {
        let stream = self.get_data().await.unwrap();
        self.verify_stream(&stream)
            .await
            .map_err(|e| super::api::Error::AuthenticateError)
    }
}
