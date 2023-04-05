module EntCuentaContable


  def self.procesos_crear_cuenta(params, args)
    cuentas    = []
    is_prima   = false

    params[:cuentas_contables].each do | config_cuenta |
      if args[:view_prima]
        configuracion      = ConfiguracionEntidadCuenta.find_by_id(config_cuenta[:configuracion_entidad_cuenta_id])
        is_prima           = !args[:usa_moneda_nacional] && configuracion.is_nacional
      end

      args[:descripcion_cuenta] = "#{args[:descripcion_cuenta]} PRIMA" if is_prima
      cuentas.push( { tipo_categoria: args[:tipo_categoria], descripcion_cuenta: args[:descripcion_cuenta], **config_cuenta.as_json }.with_indifferent_access )
    end
    params[:entidad_cuentas_contables] = cuentas

  end

end
