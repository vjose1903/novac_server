Rails.application.routes.draw do
  resources :modelos
  resources :marcas
  resources :incidencias
  resources :incidencia
  resources :vehiculos
  resources :cuadre_cajas
  resources :detalles_produccion
  resources :producciones
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
  resources :reportes
  
  
  
  # - REPORTES --------------------------------------------------------------
  get "reporte/:tipo_reporte" => "reportes#getReportes"
  # - CUENTAS POR COBRAR --------------------------------------------------------------
  # get "reporte/cuentas/cobrar/:tipo/:cliente_id" => "reportes#getCuentasCobrar"

  # Cuadre caja
  post "cuadre_cajas/custom" => "cuadre_cajas#createCuadre"
  
  # vehiculos
  get "vehiculos/filtro/:arg" => "vehiculos#getVehiculosFiltrados"
  patch "vehiculos/delete/:id" => "vehiculos#deleteVehiculo" #
  
  # marcas
  get "marcas/filtro/:arg" => "marcas#getMarcasFiltradas"
  
  # modelos
  get "modelos/por_marca/:marca" => "modelos#getModelosPorMarca"
  get "modelos/filtro/:arg" => "modelos#getModelosFiltrados"
  
  # recibos de ingresos
  get "recibos_ingresos/filtro/:arg" => "recibos_ingresos#getRecibosFiltrados"
  get "recibos_ingresos/revertir/:tipo/:id" => "recibos_ingresos#revertirRecibos" #
  get "recibos_ingresos/get/:cant" => "recibos_ingresos#getRecibosLimit" #

  # produccion
  get "articulos/ingredientes/:id" => "articulos#getIngredientesFormula" #

  # articulos
  get "articulos/get/contenidos/:id" => "articulos#getContenidos" #
  get "articulos/check_excede/:id" => "articulos#checkIfExcede" #
  get "articulos/filtro/:arg" => "articulos#getArticulosFiltrados" #
  get "articulosF" => "articulos#getArticulosFormateados"
  get "articulos/historico/:date" => "mantenimiento_articulos#getAllArticulosByDate" #
  get "articulos/historico/:date/:articulo_id" => "mantenimiento_articulos#getOneArticuloByDate" #
  patch "articulos/delete/:id" => "articulos#deleteArticulo" #
  get "articulos/custom/materias_primas" => "articulos#getMateriasPrimas" #
  get "articulos/custom/productos_terminados" => "articulos#getProductosTerminados" #
  get "articulos/tipo_nombre/:tipo/:nombre" => "articulos#getArticuloByNameObyCodigo"
  get "articulos/custom/costo/:tipo/:id" => "articulos#getArticuloCosto"
  get "articulos/custom/cantidad_inventario" => "articulos#getcountArticulos"
  
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
  get "users/by_role/:role" => "users#getUserByRole"
  get "users/:id" => "users#getUserById"
  get "users/filtro/:arg" => "users#getUsuariosFiltrados"
  get "users/custom/names" => "users#getUsersNames"

  # notas 
  get "cabecera_facturas/custom/get_cantidad_devuelto/:aplicadaA" => "cabecera_facturas#getCantidadDevuelto"

  # cabecera facturas
  get "cabecera_facturas/cliente/:id/pagada/:pagada" => "cabecera_facturas#getFacturasByClienteIdAndEstado"
  get "cabecera_facturas/cliente/:id" => "cabecera_facturas#getFacturasByClienteId"
  get "cabecera_facturas/params/:campo/:valor/:tipo_factura_id/:is_adelantada" => "cabecera_facturas#getFacturasByParams"
  post "cabecera_facturas/anular_factura/:id" => "cabecera_facturas#cancelarFactura"
  get "cabecera_facturas/custom/viajes/:estado/:arg" => "cabecera_facturas#getViajesSinCompletar"
  patch "cabecera_facturas/custom/update/:id" => "cabecera_facturas#updateFacturaById"
  get "cabecera_facturas/custom/canUpdate/:id" => "cabecera_facturas#verificateCanUpdateById"
  get "cabecera_facturas/custom/getinfo" => "cabecera_facturas#getInfoFacturas"

  mount_devise_token_auth_for "User", at: "auth", controllers: {
                                        sessions: "devise_token_auth/sessions",
                                        registrations: "devise_token_auth/registrations",
                                        token_validations: "devise_token_auth/token_validations",
                                      }

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
