use std::{
    env::Args,
    net::Ipv4Addr,
    path::Path,
    sync::{Arc, Mutex},
    thread,
    time::Duration,
};

use anyhow::Result;
use corelib::{
    acdc_authorization::check,
    house_state::HouseState,
    keri_authentication::{AuthenticationError, KeriWrapper},
    listener::Listener,
};
use serde_json::json;

#[actix_web::main]
async fn main() -> Result<()> {
    let data = HouseState::new(&Path::new("./conf")).await;
    let data_arc= Arc::new(data);

    let listener = Listener {
        house_status: data_arc.clone(),
    };

    tokio::spawn(data_box.update_state());

    listener.listen_http((Ipv4Addr::UNSPECIFIED, 8080)).await?;
    Ok(())
}
