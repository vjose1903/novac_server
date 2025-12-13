module EntCuentaContable

  ENTIDAD_LABEL = {
    CLIENTE:          'cliente',
    SUPLIDOR:         'suplidor',
    USER:             'empleado',
    CUENTA_BANCARIA:  'cuenta bancaria',
    ARTICULO:         'articulo'
  }.with_indifferent_access



  def self.parsear_cuentas_contables(params, args, is_auto_created=false)
    cuentas                     = []
    is_prima                    = false

    params[:cuentas_contables].each do | cuenta_param |
      configuracion             = ConfiguracionEntidadCuenta.find_by_id(cuenta_param[:configuracion_entidad_cuenta_id])

      if args[:view_prima]
        is_prima                = !args[:usa_moneda_nacional] && configuracion.is_nacional
      end

      descripcion_cuenta = "#{ConfigEntidadCuentaCont::Keys.label[:"#{configuracion.key}"]}: #{args[:descripcion_cuenta]}#{is_prima ? ' PRIMA' : ''}"

      cuentas.push( {  **cuenta_param.as_json, descripcion_cuenta: descripcion_cuenta, tipo_categoria: args[:tipo_categoria] || cuenta_param[:tipo_categoria], is_auto_created: is_auto_created }.with_indifferent_access)
    end

    params[:entidad_cuentas_contables] = cuentas
  end

  def self.get_label(key)
    key = key.upcase if key != key.upcase
    return ENTIDAD_LABEL[:"#{key}"]
  end

end
