Rails.application.routes.draw do
  resources :costos_fletes_historiales
  resources :provincias
  resources :municipios
  resources :incidencias
  resources :incidencia
  resources :detalles_produccion
  resources :detalle_conduces
  resources :cabecera_conduces
  resources :detalle_recibos
  resources :tipo_recibos
  resources :movimientos_inventarios
  resources :historico_produccions
  resources :mantenimiento_formulas
  resources :formulas_productos_terminados
  resources :mantenimiento_articulos
  resources :detalle_facturas
  resources :tipo_facturas
  resources :imagenes
  resources :contenido_articulos
  resources :tipo_articulos
  resources :secuencia_facturas
  resources :permisos
  resources :acciones
  resources :roles

  resources :reportes do
    collection do
      get "custom/:tipo_reporte" => "reportes#getReportes"
    end
  end

  resources :cuadre_cajas do
    collection do
			post "custom"            => "cuadre_cajas#create"
      get "check_today_cuadre" => "cuadre_cajas#checkTodayCuadre"
    end
  end

  resources :documentos_de_identidad do
    collection do
      get "persona"            => "application#getPersonasOfDocumento"
    end
  end

  resources :users do
    collection do
      get "filtro/:arg"        => "users#getUsuariosFiltrados"
    end
  end

  resources :costo_fletes do
    collection do
      get "filtro/:arg"        => "costo_fletes#index"
    end
  end

  resources :producciones do
    collection do
      get "filtro/:arg"        => "producciones#getProduccionesFiltradas"
    end
  end

  resources :vehiculos do
    collection do
      get "filtro/:arg"        => "vehiculos#getVehiculosFiltrados"
    end
  end

  resources :marcas do
    collection do
      get "filtro/:arg"        => "marcas#getMarcasFiltradas"
    end
  end

  resources :modelos do
    collection do
      get "por_marca/:marca"   => "modelos#getModelosPorMarca"
      get "filtro/:arg"        => "modelos#getModelosFiltrados"
    end
  end

  resources :articulos do
    collection do
      get "check_excede/:id"              => "articulos#checkIfExcede" #
      get "filtro/:arg"                   => "articulos#getArticulosFiltrados" #
      get "historico/:date/:articulo_id"  => "mantenimiento_articulos#getOneArticuloByDate" #
      get "custom/stock"                  => "articulos#getStock"
    end
  end

  resources :recibos_ingresos do
    collection do
      get "filtro/:arg"                   => "recibos_ingresos#getRecibosFiltrados"
      get "revertir/:tipo/:id"            => "recibos_ingresos#revertirRecibos"
    end
  end

  resources :suplidores do
    collection do
      get "filtro/:arg"                   => "suplidores#getSuplidoresFiltrados"
    end
  end

  resources :clientes do
    collection do
      get "filtro/:arg"                   => "clientes#getClientesFiltrados"
    end
  end

  resources :cabecera_facturas do
    collection do
      # notas
      get "custom/get_cantidad_devuelto/:aplicadaA"               => "cabecera_facturas#getCantidadDevuelto"

      # cabecera facturas
      get "cliente/:cliente_id/pagada/:pagada"                    => "cabecera_facturas#getFacturasByClienteIdAndEstado"
      get "cliente/:id"                                           => "cabecera_facturas#getFacturasByClienteId"
      get "params/:campo/:valor/:tipo_factura_id/:is_adelantada"  => "cabecera_facturas#getFacturasByParams"
      post "anular_factura/:id"                                   => "cabecera_facturas#cancelarFactura"
      get "custom/viajes/:estado/:arg"                            => "cabecera_facturas#getViajesSinCompletar"
      patch "custom/update/:id"                                   => "cabecera_facturas#update"
      get "custom/notas"                                          => "cabecera_facturas#getNotas"
      get "custom/comprobar_serial"                               => "cabecera_facturas#comprobarSerial"
      get "custom/canUpdate/:id"                                  => "cabecera_facturas#verificateCanUpdateById"
    end
  end

  resources :secuencia_comprobantes do
    collection do
      get "custom/:id/:estado"  => "secuencia_comprobantes#getPaqueteRncByEstado"
      get "filtro/:arg"         => "secuencia_comprobantes#getSecuenciaComprobantesFiltrados"
    end
  end

  post "ruta/test"              => "application#testFunction"

  mount_devise_token_auth_for "User", at: "auth", controllers: {
                                        sessions: "devise_token_auth/sessions",
                                        registrations: "devise_token_auth/registrations",
                                        token_validations: "devise_token_auth/token_validations",
                                      }

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
