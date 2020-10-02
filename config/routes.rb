Rails.application.routes.draw do
  resources :detalle_conduces
  resources :cabecera_conduces
  resources :secuencia_comprobantes
  resources :secuencia_ingresos
  resources :detalle_recibos
  resources :tipo_recibos
  resources :recibos_ingresos
  resources :movimientos_inventarios
  resources :historico_produccions
  resources :mantenimiento_formulas
  resources :formulas_productos_terminados
  resources :mantenimiento_articulos
  resources :detalle_facturas
  resources :cabecera_facturas
  resources :tipo_facturas
  resources :suplidores
  resources :clientes
  resources :documentos_de_identidad
  resources :imagenes
  resources :contenido_articulos
  resources :articulos
  resources :tipo_articulos
  resources :secuencia_facturas

  # produccion
  get "articulos/ingredientes/:id" => "articulos#getIngredientesFormula" #

  # articulos
  get "articulos/filtro/:arg" => "articulos#getArticulosFiltrados" #
  get "articulosF" => "articulos#getArticulosFormateados"
  get "historico/:id" => "contenido_articulos#getCondicionContenidoById"
  get "articulos/historico/:date/:articulo_id" => "mantenimiento_articulos#getAllArticulosByDate" #
  patch "articulos/delete/:id" => "articulos#deleteArticulo" #
  get "articulos/custom/materias_primas" => "articulos#getMateriasPrimas" #
  get "articulos/tipo_nombre/:tipo/:nombre" => "articulos#getArticuloByNameObyCodigo"

  # suplidores
  get "nombreSuplidores" => "suplidores#getNombresSuplidores"
  get "suplidores/filtro/:arg" => "suplidores#getSuplidoresFiltrados"

  # secuencia comprobantes
  get "paqueteNCF/:id/:estado" => "secuencia_comprobantes#getPaqueteRncByEstado"
  get "secuencia_comprobantes/filtro/:arg" => "secuencia_comprobantes#getSecuenciaComprobantesFiltrados"

  # clientes
  get "clientes/filtro/:arg" => "clientes#getClientesFiltrados"
  get "clientes/nombre/:nombre" => "clientes#getClientesByName"

  # usuarios
  get "users" => "users#getUsers"
  get "users/vendedores" => "users#getVendedores"
  get "users/:id" => "users#getUserById"
  get "users/filtro/:arg" => "users#getUsuariosFiltrados"

  # cabecera facturas
  get "cabecera_facturas/cliente/:id/pagada/:pagada" => "cabecera_facturas#getFacturasByClienteIdAndEstado"
  get "cabecera_facturas/cliente/:id" => "cabecera_facturas#getFacturasByClienteId"
  get "cabecera_facturas/params/:campo/:valor/:tipo_factura_id/:adelantada" => "cabecera_facturas#getFacturasByParams"
  post "cabecera_facturas/anular_factura/:id" => "cabecera_facturas#cancelarFactura"

  mount_devise_token_auth_for "User", at: "auth", controllers: {
                                        sessions: "devise_token_auth/sessions",
                                        registrations: "devise_token_auth/registrations",
                                        token_validations: "devise_token_auth/token_validations",
                                      }

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
