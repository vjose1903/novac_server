# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym 'RESTful'
# end

ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.irregular "imagen",                                 "imagenes"
  inflect.irregular "vendedor",                               "vendedores"
  inflect.irregular "documento_de_identidad",                 "documentos_de_identidad"
  inflect.irregular "suplidor",                               "suplidores"
  inflect.irregular "produccion",                             "producciones"
  inflect.irregular "detalle_produccion",                     "detalles_produccion"
  inflect.irregular "incidencia",                             "incidencias"
  inflect.irregular "forma_de_pago",                          "formas_de_pago"
  inflect.irregular "municipio",                              "municipios"
  inflect.irregular "provincia",                              "provincias"
  inflect.irregular "costo_flete_historial",                  "costos_fletes_historiales"
  inflect.irregular "entidad",                                "entidades"
  inflect.irregular "correo_electronico",                     "correos_electronicos"
  inflect.irregular "config_entidad",                         "config_entidades"
  inflect.irregular "accion",           				              "acciones"
  inflect.irregular "permiso_accion",                         "permisos_acciones"
  inflect.irregular "rol_permiso_accion",                     "roles_permisos_acciones"
  inflect.irregular "nota",                                   "notas"
  inflect.irregular "factura_aplicada",                       "facturas_aplicadas"
  inflect.irregular "detalle_factura_nota",                   "detalles_facturas_notas"
  inflect.irregular "camion_viaje",                           "camiones_viajes"
  inflect.irregular "chofer_viaje",                           "choferes_viajes"
  inflect.irregular "movimiento_viaje",                       "movimientos_viaje"
  inflect.irregular "movimiento_viaje",                       "movimientos_viaje"
  inflect.irregular "grupo_cuenta",                           "grupos_de_cuentas"
  inflect.irregular "cuenta_contable",                        "cuentas_contables"
  inflect.irregular "periodo_fiscal",                         "periodos_fiscales"
  inflect.irregular "detalle_periodo_fiscal",                 "detalles_periodos_fiscales"
  inflect.irregular "cierre_cuenta",                          "cierre_cuentas"
  inflect.irregular "configuracion_entidad_cuenta",           "configuraciones_entidades_cuentas"
  inflect.irregular "divisa",                                 "divisas"
  inflect.irregular "tasa_cambio",                            "tasas_de_cambio"
  inflect.irregular "tipo_cuenta_bancaria",                   "tipos_cuentas_bancarias"
  inflect.irregular "banco",                                  "bancos"
  inflect.irregular "cuenta_bancaria",                        "cuentas_bancarias"
  inflect.irregular "cuenta_contable_cuenta_bancaria",        "cuentas_contables_cuentas_bancarias"
  inflect.irregular "cabeza_asiento_contable",                "cabezas_asientos_contables"
  inflect.irregular "detalle_asiento_contable",               "detalles_asientos_contables"
  inflect.irregular "deposito",                               "depositos"
  inflect.irregular "transferencia",                          "transferencias"
  inflect.irregular "categoria_entidad_contable",             "categorias_entidades_contables"


end
