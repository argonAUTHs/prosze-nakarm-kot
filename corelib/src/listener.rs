use actix_web::{
    dev::Server, http::StatusCode, web::Data, App, HttpResponse, HttpServer, ResponseError,
};
use std::{
    net::ToSocketAddrs,
    path::{Path, PathBuf},
    sync::{Arc, Mutex},
};
use url;

use crate::{house_state::HouseState, keri_authentication::KeriWrapper};

pub struct Listener {
    pub house_status: Arc<HouseState>,
}

impl Listener {
    pub async fn setup(config_path: &Path) -> Result<Self, String> {
        let house_state = HouseState::new(config_path);

        Ok(Self {
            house_status: Arc::new(house_state.await),
        })
    }

    pub fn listen_http(&self, addr: impl ToSocketAddrs) -> Server {
        let state = Data::new(self.house_status.clone());

        println!("House is listening.",);
        HttpServer::new(move || {
            App::new()
                .app_data(state.clone())
                .route(
                    "/register_code",
                    actix_web::web::get().to(http_handlers::register_code),
                )
                .route(
                    "/authorize",
                    actix_web::web::get().to(http_handlers::authorize_code),
                )
        })
        .bind(addr)
        .unwrap()
        .run()
    }
}

impl ResponseError for crate::api::Error {
    fn status_code(&self) -> StatusCode {
        StatusCode::INTERNAL_SERVER_ERROR
    }

    fn error_response(&self) -> HttpResponse {
        HttpResponse::build(self.status_code()).body(self.to_string())
    }
}

pub mod http_handlers {
    use std::sync::Arc;

    use actix_web::{
        http::{header::ContentType, StatusCode},
        web, HttpResponse, ResponseError,
    };

    use crate::{api::Error, keri_authentication::KeriWrapper};

    pub async fn register_code(data: web::Data<Arc<KeriWrapper>>) -> Result<HttpResponse, Error> {
        let schema_said = "EPtdQc35vLxszRMw3-uyBg3JY0_7uQ0xqZlkCfD0VSB5".to_string();
        let code = crate::api::request_data_code(data.controller.id.to_string(), schema_said);
        Ok(HttpResponse::Ok().json(code))
    }

    pub async fn authorize_code(data: web::Data<Arc<KeriWrapper>>) -> Result<HttpResponse, Error> {
        let schema_said = "EPtdQc35vLxszRMw3-uyBg3JY0_7uQ0xqZlkCfD0VSB5".to_string();
        let messagebox_oobi = data.messagebox_oobis().unwrap();
        let code = crate::api::authorize_qr_code(messagebox_oobi, schema_said);
        Ok(HttpResponse::Ok().json(code))
    }
}
