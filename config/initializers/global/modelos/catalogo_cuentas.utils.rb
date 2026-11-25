module CatalogoCuenta

  module GrupoCuenta
    def self.iterator( grupos )

      grupos_parsed                     = []

      grupos.each do | grupo |
        grupo_temp                      = grupo.attributes
        cuentas_contables               = CuentaContable.iterator(grupo.cuentas_contables.order('codigo ASC'))

        grupo_temp['origen']            = OrigenGrupo.get_label(grupo_temp['origen'])
        grupo_temp['tipo']              = TipoGrupo.get_label(grupo_temp['tipo'])

        grupo_temp['cuentas_contables'] = cuentas_contables


        grupos_parsed.push(grupo_temp)
      end

      return grupos_parsed
    end
  end

# ---------------------------------------------------------------------------------------------------------------------------------------

  module CuentaContable

    def self.iterator( all_cuentas, parametros_opcionales={} )
      cuentas = all_cuentas.to_a
      cuentas_parsed = []
      cuentas_by_id = cuentas.each_with_object({}) do |cuenta, parsed_by_id|
        cuenta_parsed = serialize_parser(cuenta, { all: true, cuentas_contables: true, **parametros_opcionales })
        cuenta_parsed[:cuentas_contables] = []
        parsed_by_id[cuenta.id] = cuenta_parsed
      end

      cuentas.each do |cuenta|
        cuenta_parsed = cuentas_by_id[cuenta.id]
        padre = cuentas_by_id[cuenta.cuenta_control_id]

        if padre
          padre[:cuentas_contables] << cuenta_parsed
        else
          cuentas_parsed.push(cuenta_parsed)
        end
      end

      return cuentas_parsed
    end

    # =======================================================================================================================================

    def self.obtener_padre(all_cuentas, current_cuenta)
      padre = all_cuentas.filter { | item | current_cuenta.cuenta_control_id == item.id }
      return  !padre.empty? ? padre.first : nil
    end

  end


end


