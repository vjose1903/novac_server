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
  inflect.irregular "imagen", "imagenes"
  inflect.irregular "vendedor", "vendedores"
  inflect.irregular "documento_de_identidad", "documentos_de_identidad"
  inflect.irregular "suplidor", "suplidores"
  inflect.irregular "produccion", "producciones"
  inflect.irregular "detalle_produccion", "detalles_produccion"
  inflect.irregular "incidencia", "incidencias"
  inflect.irregular "forma_de_pago", "formas_de_pago"
  inflect.irregular "municipio", "municipios"
  inflect.irregular "provincia", "provincias"
  inflect.irregular "costo_flete_historial", "costos_fletes_historiales"
end
