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

    def self.iterator( cuentas )
      cuentas_parsed = []

      cuentas.each do | cuenta |

        arreglo_sin_cuenta_actual     = cuentas.filter { | item | item.codigo != cuenta.codigo }
        padre                         = obtener_padre(arreglo_sin_cuenta_actual, cuenta)

        unless padre.nil?
          padre.cuentas_contables     = [] if padre.cuentas_contables.nil?

          padre.cuentas_contables.push(serialize_parser(cuenta, { all: true }))
        else

          cuentas_parsed.push(serialize_parser(cuenta, { all: true }))
        end

      end

      return cuentas_parsed
    end


    # =======================================================================================================================================

    def self.obtener_padre(cuentas, current_cuenta)
      padre = cuentas.filter { | item | current_cuenta.cuenta_control == item.id }
      return  !padre.empty? ? padre.first : nil
    end

  end


end


