module EntCuentaContable


  def self.parsear_cuentas_contables(params, args)
    cuentas                     = []
    is_prima                    = false

    params[:cuentas_contables].each do | config_cuenta |
      configuracion             = ConfiguracionEntidadCuenta.find_by_id(config_cuenta[:configuracion_entidad_cuenta_id])

      if args[:view_prima]
        is_prima                = !args[:usa_moneda_nacional] && configuracion.is_nacional
      end

      descripcion_cuenta = "#{ConfigEntidadCuentaCont::Keys.label[:"#{configuracion.key}"]}: #{args[:descripcion_cuenta]}#{is_prima ? ' PRIMA' : ''}"
      cuentas.push( {  **config_cuenta.as_json, descripcion_cuenta: descripcion_cuenta, tipo_categoria: args[:tipo_categoria] || config_cuenta[:tipo_categoria] }.with_indifferent_access )
    end

    params[:entidad_cuentas_contables] = cuentas

  end

end
