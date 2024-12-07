Rails.application.routes.draw do
  resources :entidad_cuentas_contables
  resources :categorias_entidades_contables
  resources :sub_tipo_articulos

  resources :cuentas_bancarias
  resources :costos_fletes_historiales
  resources :provincias
  resources :municipios
  resources :incidencias
  resources :incidencia
  resources :detalles_produccion
  resources :detalle_conduces
  resources :detalle_recibos
  resources :tipo_recibos
  resources :movimientos_inventarios
  resources :historico_produccions
  resources :mantenimiento_formulas
  resources :formulas_productos_terminados
  resources :mantenimiento_articulos
  resources :tipo_facturas
  resources :imagenes
  resources :contenido_articulos
  resources :tipo_articulos
  resources :secuencia_facturas
  resources :acciones
  resources :config_articulos
  resources :grupos_de_cuentas
  resources :nombre_bancos

  resources :configuraciones_entidades_cuentas

  resources :tipo_cuentas_bancarias


	get "ruta/test"              => "application#testFunction"

  resources :roles do
    collection do
      get "filtro/:arg"        => "roles#getRolesFiltrados"
    end
  end

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
      get "por_marca/:marca"                           => "modelos#getModelosPorMarca"
      get "filtro/:arg"                                => "modelos#getModelosFiltrados"
    end
  end

  resources :articulos do
    collection do
      get "check_excede/:id"                           => "articulos#checkIfExcede" #
      get "filtro/:arg"                                => "articulos#getArticulosFiltrados" #
      get "historico/:date/:articulo_id"               => "mantenimiento_articulos#getOneArticuloByDate" #

      scope "custom" do
        get "stock"                               => "articulos#getStock"
        get "get_actual_price_detalles"           => "articulos#getActualPriceDetalles"
      end
    end
  end

  resources :recibos_ingresos do
    collection do
      get "filtro/:arg"                                => "recibos_ingresos#getRecibosFiltrados"
      get "revertir/:tipo/:id"                         => "recibos_ingresos#revertirRecibos"
    end
  end

	resources :pago_facturas do
		collection do
			get "filtro/:arg"                                => "pago_facturas#getPagosFiltrados"
      get "revertir/:tipo/:id"                         => "pago_facturas#revertirPagos"
		end
	end

  resources :cabecera_conduces do
    collection do
      get "filtro/:arg"                                => "cabecera_conduces#getConducesFiltrados"
      get "revertir/:tipo/:id"                         => "cabecera_conduces#revertirConduce"
    end
  end

  resources :suplidores do
    collection do
      get "filtro/:arg"                                => "suplidores#getSuplidoresFiltrados"

			scope "custom" do
				get "get_balances/:id"                         => "suplidores#getBalances"
			end
    end
  end

  resources :clientes do
    collection do
      get "filtro/:arg"                                => "clientes#getClientesFiltrados"

      scope "custom" do
        get "get_balances/:id"                         => "clientes#getBalances"
      end
    end
  end

  resources :facturas_aplicadas do
    collection do
      scope "custom" do
        get "get_cantidad_devuelto/:ids"          => "facturas_aplicadas#getCantidadDevuelto"
      end
    end
  end


  resources :notas do
    collection do
      post "anular_nota/:id"                           => "notas#cancelarNota"
      get "filtro/:arg"                                => "notas#getNotasFiltradas"
    end
  end

  resources :cabecera_facturas do
    collection do

      # cabecera facturas
      get "cliente/:cliente_id/pagada/:pagada"                    => "cabecera_facturas#getFacturasByClienteIdAndEstado"
      get "cliente/:id"                                           => "cabecera_facturas#getFacturasByClienteId"
      post "anular_factura/:id"                                   => "cabecera_facturas#cancelarFactura"
      patch ":id/update/movimientos_viaje"                        => "cabecera_facturas#updateMovimientosViaje"

      scope "custom" do
        patch "update/:id"                                   => "cabecera_facturas#update"
        get ":ruta_complemento"                              => "cabecera_facturas#custom_route"
      end
    end
  end

  resources :secuencia_comprobantes do
    collection do
      get "filtro/:arg"                   => "secuencia_comprobantes#getSecuenciaComprobantesFiltrados"

      scope "custom" do
        get ":id/:estado"                 => "secuencia_comprobantes#getPaqueteRncByEstado"
      end
    end
  end

  resources :permisos do
    collection do
      scope "custom" do
        get "parse_permisos_front"        => "permisos#parsePermisosFront"
      end
    end
  end

  resources :periodos_fiscales do
    collection do
      scope "custom" do
        post "open_new_periodo"           => "periodos_fiscales#openNewPeriodo"
        get "is_open_month"               => "periodos_fiscales#isOpenMonth"
      end
    end
  end

  resources :catalogo_de_cuentas do
    collection do
      post "create_default"               => "catalogo_de_cuentas#createCatalogoDeCuentasDefault"
    end
  end

  resources :tasas_de_cambio do
    collection do
      scope "custom" do
        get "get_history_changes"         => "tasas_de_cambio#getHistoryChanges"
      end
    end
  end

  resources :cabezas_asientos_contables do
    collection do
      get "filtro/:arg"                     => "cabezas_asientos_contables#getAsientosFiltrados"
    end
  end

  resources :bancos do
    collection do
      get "filtro/:arg"                     => "bancos#getBancosFiltrados"
    end
  end

  resources :depositos do
    collection do
      get "filtro/:arg"                     => "depositos#getDepositosFiltrados"
      delete "anular/:id"                   => "depositos#anularDeposito"
    end
  end

	resources :transferencias do
    collection do
      get "filtro/:arg"                     => "transferencias#getTransferenciasFiltradas"
      delete "anular/:id"                   => "transferencias#anularTransferencia"
    end
  end


  resources :cheques do
    collection do
      get "filtro/:arg"                     => "cheques#getChequesFiltrados"
      delete "anular/:id"                   => "cheques#anularCheque"
    end
  end

	resources :cuentas_contables do
    collection do
      patch ":id/deactivate_or_reactivate"  => "cuentas_contables#deactivateOrReactivate"
    end
  end

	resources :divisas do
    collection do
			patch ":id/deactivate_or_reactivate"     => "divisas#deactivateOrReactivate"

      scope "custom" do
        get "get_principal"                    => "divisas#getPrincipalDivisa"
      end
    end
  end





  mount_devise_token_auth_for "User", at: "auth", controllers: {
    sessions: "devise_token_auth/sessions",
    registrations: "devise_token_auth/registrations",
    token_validations: "devise_token_auth/token_validations",
  }

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
