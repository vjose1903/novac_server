class CatalogoDeCuentas < ApplicationRecord

  def self.create_catalogo_de_cuentas_default
    res                                 = Response.new
    CatalogoDeCuentas.transaction do

      all_grupos = GrupoCuenta.where({ estado: true })

      if all_grupos.empty?
        G_CATALOGO_DEFAULT.each do | grupo |
          temp_grupo_cuenta             = GrupoCuenta.create_update_grupo_cuenta(grupo.with_indifferent_access, true)

          if temp_grupo_cuenta.status_valid
            grupo_cuenta                = temp_grupo_cuenta.get_data.as_json
            grupo_cuenta_db             = GrupoCuenta.find_by_id(grupo_cuenta[:id])

            primera_cuenta_contable     = grupo_cuenta[:cuentas_contables].as_json.first
            primera_cuenta_contable_db  = CuentaContable.find_by_id(primera_cuenta_contable[:id])

            resultado                   = CatalogoDeCuentas.create_cuentas_default(grupo[:cuentas_contables], grupo_cuenta_db, primera_cuenta_contable_db)

            unless resultado.status_valid
              res.add_msgs(resultado.get_msgs)
              res.set_status(HTTP_STATUS_CODE[:conflict])
              return res
            end

          else
            res.add_msgs(temp_grupo_cuenta.get_msgs)
            res.set_status(HTTP_STATUS_CODE[:conflict])
            return res
          end
        end

      else
        res.add_msg("Solo se puede crear el catalogo por defecto una sola vez.")
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      raise ActiveRecord::Rollback unless res.status_valid
    end

    return res
  end

  # =========================================================================================================================================================

  def self.create_cuentas_default(cuentas_contables, grupo_cuenta, cuenta_control)
    res = Response.new

    cuentas_contables.each do | cuenta |
      next_cuenta_contable         = { grupo_cuenta_id: grupo_cuenta.id, cuenta_control: cuenta_control.id, **cuenta }.with_indifferent_access

      temp_cuenta_contable         = CuentaContable.create_update_cuenta_contable(next_cuenta_contable, grupo_cuenta, true)

      if temp_cuenta_contable.status_valid
        cuenta_contable            = temp_cuenta_contable.get_data.as_json
        cuenta_contable_db         = CuentaContable.find_by_id(cuenta_contable["id"])

        next_config_entidad_cuenta = G_CONFIG_ENTIDAD_CUENTA.find { | config | config[:cuenta_contable_descripcion] == cuenta_contable_db.descripcion }

        if !next_config_entidad_cuenta.nil?
          config                   = { cuenta_contable_id: cuenta_contable_db.id, **next_config_entidad_cuenta }.with_indifferent_access
          resultado                = ConfiguracionEntidadCuenta.create_update_configuracion_entidad_cuenta(config, nil, true)

          CatalogoDeCuentas.renderError(res, resultado) unless resultado.status_valid
        end

        unless cuenta[:cuentas_contables].nil?
          resultado                = CatalogoDeCuentas.create_cuentas_default(cuenta[:cuentas_contables], grupo_cuenta, cuenta_contable_db)
          CatalogoDeCuentas.renderError(res, resultado) unless resultado.status_valid
        end

      else
        CatalogoDeCuentas.renderError(res, temp_cuenta_contable)
      end

    end

    return res
  end

  # =========================================================================================================================================================

  def self.renderError(res, resultado)
    res.add_msgs(resultado.get_msgs)
    res.set_status(HTTP_STATUS_CODE[:conflict])
    return res
  end

end
