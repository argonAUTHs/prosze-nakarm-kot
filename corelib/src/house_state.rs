use std::{
    path::Path,
    sync::{Arc},
};


use futures::lock::Mutex;

use crate::{acdc_authorization::check, keri_authentication::KeriWrapper};

enum DoorState {
    Opened,
    Closed,
}
pub struct HouseState {
    pub keri: Mutex<KeriWrapper>,
    door_state: Mutex<DoorState>,
}

impl HouseState {
    pub async fn new(config: &Path) -> Self {
        let wrapper = KeriWrapper::load_identifier(config).await.unwrap();
        Self {
            keri: Mutex::new(wrapper),
            door_state: Mutex::new(DoorState::Closed),
        }
    }

    pub async fn open_door(&self) {
        let mut door_state = self.door_state.lock().await;
        *door_state = DoorState::Opened
    }

    pub async fn update_state(&self) -> Result<(), super::api::Error> {
        let acdc = self.keri.lock().await.process().await.unwrap().clone();
        match check(acdc) {
            Ok(_) => {
                self.open_door();
                Ok(())
            }
            Err(_) => {
                todo!()
            }
        }
    }
}
