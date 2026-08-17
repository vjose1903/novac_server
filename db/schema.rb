# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2026_08_17_090000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "acciones", force: :cascade do |t|
    t.string "nombre"
    t.string "descripcion"
    t.string "metodo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "mostrar_front"
  end

  create_table "articulos", force: :cascade do |t|
    t.bigint "imagen_id"
    t.bigint "tipo_articulo_id"
    t.string "nombre"
    t.float "costo_principal"
    t.float "precio_principal"
    t.float "existencia"
    t.integer "aviso_existencia"
    t.string "codigo"
    t.date "fecha_ingreso"
    t.string "medida"
    t.boolean "is_detallable"
    t.string "medida_alerta"
    t.boolean "calcular_itbis"
    t.boolean "estado"
    t.boolean "is_combo"
    t.float "otros_costos"
    t.string "vendido_en"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "is_materia_prima"
    t.boolean "calcular_saco"
    t.index ["estado", "nombre"], name: "index_articulos_on_estado_and_nombre", unique: true, where: "(estado = true)"
    t.index ["imagen_id"], name: "index_articulos_on_imagen_id"
    t.index ["tipo_articulo_id"], name: "index_articulos_on_tipo_articulo_id"
  end

  create_table "cabecera_conduces", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "cliente_id"
    t.integer "numero_conduce"
    t.datetime "fecha_equivalente", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "estado"
    t.index ["cliente_id"], name: "index_cabecera_conduces_on_cliente_id"
    t.index ["user_id"], name: "index_cabecera_conduces_on_user_id"
  end

  create_table "cabecera_facturas", force: :cascade do |t|
    t.bigint "tipo_factura_id"
    t.bigint "suplidor_id"
    t.bigint "cliente_id"
    t.bigint "user_id"
    t.datetime "fecha_viaje", precision: nil
    t.datetime "fecha_equivalente", precision: nil
    t.datetime "fecha_vencimiento", precision: nil
    t.datetime "fecha_valida", precision: nil
    t.datetime "fecha_completada", precision: nil
    t.string "numero_comprobante"
    t.integer "numero_factura"
    t.string "condicion"
    t.string "forma_pago"
    t.float "total_factura"
    t.float "itbis"
    t.float "descuento"
    t.float "Bruto"
    t.boolean "estado"
    t.string "tipo"
    t.string "NoCliente_nombre"
    t.string "NoCliente_direccion"
    t.string "costoYgasto"
    t.boolean "pagada"
    t.integer "vendedor_id"
    t.float "balance"
    t.float "devuelta"
    t.boolean "is_adelantada"
    t.boolean "is_nota"
    t.boolean "is_viaje"
    t.boolean "tiene_nota"
    t.string "aplicada_a"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "identificador"
    t.integer "pre_factura"
    t.integer "cotizacion"
    t.string "serie"
    t.string "fecha_hora_firma"
    t.string "trackId"
    t.string "security_code"
    t.string "xml_file_name"
    t.string "qr_url_dgii"
    t.string "is_aceptada"
    t.string "dgii_message"
    t.boolean "is_ncf_modificado", default: false
    t.string "NoCliente_rnc"
    t.boolean "is_external", default: false
    t.index ["cliente_id"], name: "index_cabecera_facturas_on_cliente_id"
    t.index ["suplidor_id"], name: "index_cabecera_facturas_on_suplidor_id"
    t.index ["tipo_factura_id"], name: "index_cabecera_facturas_on_tipo_factura_id"
    t.index ["user_id"], name: "index_cabecera_facturas_on_user_id"
  end

  create_table "calendar_event_links", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "calendar_event_id", null: false
    t.string "linkable_type", null: false
    t.bigint "linkable_id", null: false
    t.string "label"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_event_id", "linkable_type", "linkable_id"], name: "idx_calendar_event_links_unique_link", unique: true
    t.index ["calendar_event_id"], name: "index_calendar_event_links_on_calendar_event_id"
    t.index ["linkable_type", "linkable_id"], name: "index_calendar_event_links_on_linkable_type_and_linkable_id"
  end

  create_table "calendar_event_types", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "color", null: false
    t.boolean "is_system", default: false, null: false
    t.boolean "active", default: true, null: false
    t.integer "sort_order", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_calendar_event_types_on_active"
    t.index ["slug"], name: "index_calendar_event_types_on_slug", unique: true
    t.index ["sort_order"], name: "index_calendar_event_types_on_sort_order"
  end

  create_table "calendar_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "calendar_event_type_id", null: false
    t.string "title", null: false
    t.text "description"
    t.string "location"
    t.string "color"
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.boolean "all_day", default: false, null: false
    t.string "timezone", default: "America/Santo_Domingo", null: false
    t.string "recurrence_type", default: "none", null: false
    t.text "recurrence_rule"
    t.integer "recurrence_interval", default: 1, null: false
    t.string "recurrence_days", default: [], array: true
    t.date "recurrence_until"
    t.integer "recurrence_count"
    t.string "google_uid"
    t.string "ical_uid"
    t.string "source", default: "manual", null: false
    t.boolean "is_global", default: false, null: false
    t.boolean "is_holiday", default: false, null: false
    t.string "holiday_key"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_working_day", default: true, null: false
    t.index ["calendar_event_type_id"], name: "index_calendar_events_on_calendar_event_type_id"
    t.index ["created_by_id"], name: "index_calendar_events_on_created_by_id"
    t.index ["deleted_at"], name: "index_calendar_events_on_deleted_at"
    t.index ["end_date"], name: "index_calendar_events_on_end_date"
    t.index ["ends_at"], name: "index_calendar_events_on_ends_at"
    t.index ["google_uid"], name: "index_calendar_events_on_google_uid", where: "(google_uid IS NOT NULL)"
    t.index ["holiday_key"], name: "idx_calendar_events_unique_global_holiday", unique: true, where: "((is_global = true) AND (is_holiday = true) AND (deleted_at IS NULL))"
    t.index ["holiday_key"], name: "index_calendar_events_on_holiday_key"
    t.index ["ical_uid"], name: "index_calendar_events_on_ical_uid", unique: true, where: "(ical_uid IS NOT NULL)"
    t.index ["is_global", "start_date", "end_date"], name: "index_calendar_events_on_is_global_and_start_date_and_end_date"
    t.index ["is_holiday"], name: "index_calendar_events_on_is_holiday"
    t.index ["is_working_day"], name: "index_calendar_events_on_is_working_day"
    t.index ["source"], name: "index_calendar_events_on_source"
    t.index ["start_date", "end_date"], name: "index_calendar_events_on_start_date_and_end_date"
    t.index ["start_date"], name: "index_calendar_events_on_start_date"
    t.index ["starts_at"], name: "index_calendar_events_on_starts_at"
    t.index ["updated_by_id"], name: "index_calendar_events_on_updated_by_id"
  end

  create_table "camiones_viajes", force: :cascade do |t|
    t.bigint "vehiculo_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "origen_type"
    t.bigint "origen_id"
    t.index ["origen_type", "origen_id"], name: "index_camiones_viajes_on_origen"
    t.index ["vehiculo_id"], name: "index_camiones_viajes_on_vehiculo_id"
  end

  create_table "choferes_viajes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "recibos_ingreso_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recibos_ingreso_id"], name: "index_choferes_viajes_on_recibos_ingreso_id"
    t.index ["user_id"], name: "index_choferes_viajes_on_user_id"
  end

  create_table "clientes", force: :cascade do |t|
    t.bigint "imagen_id"
    t.string "nombre"
    t.string "apellido"
    t.string "telefono"
    t.string "direccion"
    t.integer "limite_credito"
    t.string "sexo", limit: 1
    t.boolean "estado"
    t.float "maximo_credito"
    t.integer "vendedor_id"
    t.float "balance"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "municipio_id"
    t.index "immutable_unaccent((apellido)::text) gin_trgm_ops", name: "index_clientes_on_unaccent_apellido_trgm", using: :gin
    t.index "immutable_unaccent((nombre)::text) gin_trgm_ops", name: "index_clientes_on_unaccent_nombre_trgm", using: :gin
    t.index ["imagen_id"], name: "index_clientes_on_imagen_id"
    t.index ["municipio_id"], name: "index_clientes_on_municipio_id"
    t.index ["nombre", "apellido"], name: "index_clientes_on_nombre_apellido"
  end

  create_table "commertial_approval_receptions", force: :cascade do |t|
    t.bigint "cabecera_factura_id"
    t.string "eNCF"
    t.string "rnc_emisor"
    t.string "rnc_comprador"
    t.float "monto_total"
    t.integer "estado"
    t.string "fecha_emision"
    t.string "detalleMotivoRechazo"
    t.string "xml_file_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "suplidor_id"
    t.index ["cabecera_factura_id"], name: "index_commertial_approval_receptions_on_cabecera_factura_id"
    t.index ["suplidor_id"], name: "index_commertial_approval_receptions_on_suplidor_id"
  end

  create_table "config_articulos", force: :cascade do |t|
    t.float "porciento_ganancia"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "configuracion_cuadres", force: :cascade do |t|
    t.jsonb "config", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contenido_articulos", force: :cascade do |t|
    t.bigint "articulo_id"
    t.integer "referencia"
    t.float "costo"
    t.float "precio"
    t.integer "cantidad"
    t.string "medida"
    t.string "condicion"
    t.boolean "calcular_itbis"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["articulo_id"], name: "index_contenido_articulos_on_articulo_id"
  end

  create_table "costo_fletes", force: :cascade do |t|
    t.bigint "municipio_id", null: false
    t.float "costo", default: 0.0
    t.boolean "estado", default: true
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["municipio_id"], name: "index_costo_fletes_on_municipio_id"
  end

  create_table "costos_fletes_historiales", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "costo_flete_id"
    t.integer "municipio_id"
    t.float "costo"
    t.boolean "estado"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["costo_flete_id"], name: "index_costos_fletes_historiales_on_costo_flete_id"
    t.index ["user_id"], name: "index_costos_fletes_historiales_on_user_id"
  end

  create_table "cuadre_caja_denominaciones", force: :cascade do |t|
    t.bigint "cuadre_caja_id", null: false
    t.string "denomination_type", null: false
    t.string "currency_code", default: "DOP", null: false
    t.decimal "denomination_value", precision: 18, scale: 2, null: false
    t.decimal "quantity", precision: 18, scale: 2, default: "0.0", null: false
    t.decimal "exchange_rate", precision: 18, scale: 6, default: "1.0", null: false
    t.decimal "foreign_amount", precision: 18, scale: 2, default: "0.0", null: false
    t.decimal "local_currency_total", precision: 18, scale: 2, default: "0.0", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "divisa_id"
    t.bigint "tasa_cambio_id"
    t.index ["cuadre_caja_id", "denomination_type", "currency_code", "denomination_value"], name: "idx_cuadre_denominaciones_unique", unique: true
    t.index ["cuadre_caja_id"], name: "index_cuadre_caja_denominaciones_on_cuadre_caja_id"
    t.index ["divisa_id"], name: "index_cuadre_caja_denominaciones_on_divisa_id"
    t.index ["tasa_cambio_id"], name: "index_cuadre_caja_denominaciones_on_tasa_cambio_id"
  end

  create_table "cuadre_caja_eventos", force: :cascade do |t|
    t.bigint "cuadre_caja_id", null: false
    t.bigint "user_id"
    t.string "event_type", null: false
    t.string "from_status"
    t.string "to_status"
    t.text "reason"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cuadre_caja_id", "created_at"], name: "idx_cuadre_eventos_fecha"
    t.index ["cuadre_caja_id"], name: "index_cuadre_caja_eventos_on_cuadre_caja_id"
    t.index ["user_id"], name: "index_cuadre_caja_eventos_on_user_id"
  end

  create_table "cuadre_caja_movimientos", force: :cascade do |t|
    t.bigint "cuadre_caja_id", null: false
    t.string "movement_group", null: false
    t.string "payment_method", null: false
    t.string "description", null: false
    t.string "reference"
    t.string "counterparty_name"
    t.string "bank_name"
    t.decimal "amount", precision: 18, scale: 2, default: "0.0", null: false
    t.integer "position", default: 0, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cuadre_caja_id", "movement_group"], name: "idx_cuadre_movimientos_group"
    t.index ["cuadre_caja_id"], name: "index_cuadre_caja_movimientos_on_cuadre_caja_id"
  end

  create_table "cuadre_cajas", force: :cascade do |t|
    t.bigint "user_id"
    t.float "total_general"
    t.float "total_venta_credito"
    t.float "total_venta_contado"
    t.float "total_recibo_ingreso"
    t.float "total_anterior"
    t.integer "numero_reporte"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "fecha_equivalente", precision: nil
    t.date "closing_date", null: false
    t.string "status", default: "submitted", null: false
    t.string "closing_version", default: "legacy", null: false
    t.string "source_type", default: "system", null: false
    t.string "currency_code", default: "DOP", null: false
    t.bigint "prepared_by_id"
    t.bigint "approved_by_id"
    t.bigint "submitted_by_id"
    t.bigint "rejected_by_id"
    t.bigint "reopened_by_id"
    t.datetime "submitted_at"
    t.datetime "approved_at"
    t.datetime "rejected_at"
    t.datetime "reopened_at"
    t.decimal "local_bills_total", precision: 18, scale: 2, default: "0.0", null: false
    t.decimal "local_coins_total", precision: 18, scale: 2, default: "0.0", null: false
    t.decimal "foreign_currency_total", precision: 18, scale: 2, default: "0.0", null: false
    t.decimal "physical_cash_total", precision: 18, scale: 2, default: "0.0", null: false
    t.decimal "other_payment_methods_total", precision: 18, scale: 2, default: "0.0", null: false
    t.decimal "additional_transfers_total", precision: 18, scale: 2, default: "0.0", null: false
    t.decimal "operational_total", precision: 18, scale: 2, default: "0.0", null: false
    t.decimal "final_consumer_invoices_total", precision: 18, scale: 2, default: "0.0", null: false
    t.decimal "income_receipts_total", precision: 18, scale: 2, default: "0.0", null: false
    t.decimal "system_income_total", precision: 18, scale: 2, default: "0.0", null: false
    t.decimal "difference_amount", precision: 18, scale: 2, default: "0.0", null: false
    t.decimal "reconciliation_tolerance", precision: 18, scale: 2, default: "0.0", null: false
    t.boolean "considered_balanced", default: false, null: false
    t.jsonb "system_income_details", default: {}, null: false
    t.text "notes"
    t.text "rejection_reason"
    t.text "reopen_reason"
    t.decimal "opening_cash_fund", precision: 18, scale: 2, default: "0.0", null: false
    t.decimal "next_day_cash_fund", precision: 18, scale: 2, default: "0.0", null: false
    t.decimal "expected_total", precision: 18, scale: 2, default: "0.0", null: false
    t.index ["approved_by_id"], name: "index_cuadre_cajas_on_approved_by_id"
    t.index ["closing_date"], name: "idx_cuadre_cajas_unique_active_closing_date", unique: true, where: "((status)::text <> 'cancelled'::text)"
    t.index ["prepared_by_id"], name: "index_cuadre_cajas_on_prepared_by_id"
    t.index ["rejected_by_id"], name: "index_cuadre_cajas_on_rejected_by_id"
    t.index ["reopened_by_id"], name: "index_cuadre_cajas_on_reopened_by_id"
    t.index ["submitted_by_id"], name: "index_cuadre_cajas_on_submitted_by_id"
    t.index ["user_id"], name: "index_cuadre_cajas_on_user_id"
  end

  create_table "detalle_conduces", force: :cascade do |t|
    t.bigint "cabecera_conduce_id"
    t.bigint "detalle_factura_id"
    t.bigint "articulo_id"
    t.float "cantidad"
    t.float "cantidad_en_unidades"
    t.string "unidad"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["articulo_id"], name: "index_detalle_conduces_on_articulo_id"
    t.index ["cabecera_conduce_id"], name: "index_detalle_conduces_on_cabecera_conduce_id"
    t.index ["detalle_factura_id"], name: "index_detalle_conduces_on_detalle_factura_id"
  end

  create_table "detalle_facturas", force: :cascade do |t|
    t.bigint "cabecera_factura_id"
    t.bigint "articulo_id"
    t.string "unidad"
    t.float "total"
    t.float "cantidad"
    t.float "cantidad_en_unidades"
    t.float "itbis"
    t.float "precio"
    t.float "costo"
    t.float "retirado"
    t.float "retirado_en_venta"
    t.float "descuento_valor"
    t.float "descuento_porciento"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "calcular_saco"
    t.integer "detalle_factura_nota"
    t.boolean "is_devuelto"
    t.boolean "is_defectuoso"
    t.string "codigo"
    t.index ["articulo_id"], name: "index_detalle_facturas_on_articulo_id"
    t.index ["cabecera_factura_id"], name: "index_detalle_facturas_on_cabecera_factura_id"
  end

  create_table "detalle_recibos", force: :cascade do |t|
    t.bigint "recibos_ingreso_id"
    t.bigint "cabecera_factura_id"
    t.float "balance_factura"
    t.float "balance_anterior_factura"
    t.boolean "pago_total"
    t.float "deposito"
    t.string "descripcion"
    t.boolean "pago_a_tiempo"
    t.boolean "is_ultimo"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.float "mora"
    t.index ["cabecera_factura_id"], name: "index_detalle_recibos_on_cabecera_factura_id"
    t.index ["recibos_ingreso_id"], name: "index_detalle_recibos_on_recibos_ingreso_id"
  end

  create_table "detalles_facturas_notas", force: :cascade do |t|
    t.bigint "factura_aplicada_id", null: false
    t.bigint "articulo_id", null: false
    t.bigint "detalle_factura_id", null: false
    t.string "unidad"
    t.float "cantidad"
    t.float "cantidad_en_unidades"
    t.float "itbis"
    t.float "costo"
    t.float "precio"
    t.float "total"
    t.float "descuento"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "precio_real"
    t.float "itbis_real"
    t.float "descuento_real"
    t.bigint "tipo_factura_id"
    t.float "cantidad_origin"
    t.string "codigo"
    t.index ["articulo_id"], name: "index_detalles_facturas_notas_on_articulo_id"
    t.index ["detalle_factura_id"], name: "index_detalles_facturas_notas_on_detalle_factura_id"
    t.index ["factura_aplicada_id"], name: "index_detalles_facturas_notas_on_factura_aplicada_id"
    t.index ["tipo_factura_id"], name: "index_detalles_facturas_notas_on_tipo_factura_id"
  end

  create_table "detalles_produccion", force: :cascade do |t|
    t.bigint "produccion_id"
    t.bigint "articulo_id"
    t.float "cantidad"
    t.float "cantidad_en_unidades"
    t.string "medida"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["articulo_id"], name: "index_detalles_produccion_on_articulo_id"
    t.index ["produccion_id"], name: "index_detalles_produccion_on_produccion_id"
  end

  create_table "divisas", force: :cascade do |t|
    t.string "nombre"
    t.string "simbolo"
    t.boolean "is_principal"
    t.boolean "estado", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "current_tasa", default: 1.0
    t.boolean "predeterminado", default: false
    t.string "code"
    t.index ["code"], name: "index_divisas_on_code"
  end

  create_table "document_references", force: :cascade do |t|
    t.string "document_origin_type", null: false
    t.bigint "document_origin_id", null: false
    t.string "document_referenced_type", null: false
    t.bigint "document_referenced_id", null: false
    t.datetime "referenced_at"
    t.bigint "referenced_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_origin_type", "document_origin_id"], name: "index_document_references_on_document_origin"
    t.index ["document_referenced_type", "document_referenced_id"], name: "index_document_references_on_document_referenced"
    t.index ["referenced_by_id"], name: "index_document_references_on_referenced_by_id"
  end

  create_table "documentos_de_identidad", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "cliente_id"
    t.bigint "suplidor_id"
    t.string "descripcion"
    t.string "documento"
    t.boolean "principal"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "origen_type"
    t.bigint "origen_id"
    t.index "immutable_unaccent((documento)::text) gin_trgm_ops", name: "index_documentos_identidad_on_unaccent_documento_trgm", using: :gin
    t.index ["cliente_id"], name: "index_documentos_de_identidad_on_cliente_id"
    t.index ["origen_type", "origen_id"], name: "index_documentos_de_identidad_on_origen_type_and_origen_id"
    t.index ["suplidor_id"], name: "index_documentos_de_identidad_on_suplidor_id"
    t.index ["user_id"], name: "index_documentos_de_identidad_on_user_id"
  end

  create_table "ecf_receptions", force: :cascade do |t|
    t.bigint "suplidor_id"
    t.string "eNCF"
    t.string "rnc_emisor"
    t.string "rnc_comprador"
    t.float "monto_total"
    t.boolean "approved"
    t.string "fecha_emision"
    t.string "xml_file_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["suplidor_id"], name: "index_ecf_receptions_on_suplidor_id"
  end

  create_table "facturas_aplicadas", force: :cascade do |t|
    t.bigint "nota_id", null: false
    t.bigint "cabecera_factura_id", null: false
    t.float "total"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tipo_factura_id"
    t.index ["cabecera_factura_id"], name: "index_facturas_aplicadas_on_cabecera_factura_id"
    t.index ["nota_id"], name: "index_facturas_aplicadas_on_nota_id"
    t.index ["tipo_factura_id"], name: "index_facturas_aplicadas_on_tipo_factura_id"
  end

  create_table "formulas_productos_terminados", force: :cascade do |t|
    t.bigint "articulo_id"
    t.float "cantidad"
    t.float "costo"
    t.integer "articulo_combo"
    t.float "precio"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "medida"
    t.index ["articulo_id"], name: "index_formulas_productos_terminados_on_articulo_id"
  end

  create_table "global_holidays", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "country_code", default: "DO", null: false
    t.string "holiday_key", null: false
    t.string "name", null: false
    t.date "date", null: false
    t.date "observed_date"
    t.integer "year", null: false
    t.string "source", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_working_day", default: false, null: false
    t.index ["country_code", "date", "name"], name: "index_global_holidays_on_country_code_and_date_and_name", unique: true
    t.index ["country_code", "holiday_key"], name: "index_global_holidays_on_country_code_and_holiday_key", unique: true
    t.index ["country_code"], name: "index_global_holidays_on_country_code"
    t.index ["date"], name: "index_global_holidays_on_date"
    t.index ["is_working_day"], name: "index_global_holidays_on_is_working_day"
    t.index ["observed_date"], name: "index_global_holidays_on_observed_date"
    t.index ["year"], name: "index_global_holidays_on_year"
  end

  create_table "historico_producciones", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "articulo_id"
    t.float "cantidad"
    t.string "medida"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["articulo_id"], name: "index_historico_producciones_on_articulo_id"
    t.index ["user_id"], name: "index_historico_producciones_on_user_id"
  end

  create_table "imagenes", force: :cascade do |t|
    t.string "file_name"
    t.string "base_64"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "origen_img_type"
    t.bigint "origen_img_id"
    t.string "file_hash"
    t.index ["origen_img_type", "origen_img_id"], name: "index_imagenes_on_origen"
  end

  create_table "incidencias", force: :cascade do |t|
    t.integer "referencia"
    t.string "descripcion"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "origen_type"
    t.bigint "origen_id"
    t.index ["origen_type", "origen_id"], name: "index_incidencias_on_origen"
  end

  create_table "mantenimiento_articulos", force: :cascade do |t|
    t.bigint "articulo_id"
    t.bigint "user_id"
    t.string "ant_nombre"
    t.string "ant_medida"
    t.float "ant_costoP"
    t.float "ant_precioP"
    t.integer "ant_alertaExistencia"
    t.boolean "ant_isDetallable"
    t.string "ant_medidaPadre"
    t.float "ant_costoPadre"
    t.float "ant_precioPadre"
    t.integer "ant_cantidadPadre"
    t.string "ant_medidaHijo"
    t.float "ant_costoHijo"
    t.float "ant_precioHijo"
    t.integer "ant_cantidadHijo"
    t.string "ant_medidaAlerta"
    t.string "vendido_en"
    t.integer "ant_idPadre"
    t.integer "ant_idHijo"
    t.integer "ant_referenciaPadre"
    t.integer "ant_referenciaHijo"
    t.integer "ant_tipoArticuloId"
    t.boolean "ant_isCombo"
    t.boolean "ant_calcularItbis"
    t.float "ant_otrosCostos"
    t.string "secuencia"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "is_materia_prima"
    t.boolean "calcular_saco"
    t.index ["articulo_id"], name: "index_mantenimiento_articulos_on_articulo_id"
    t.index ["user_id"], name: "index_mantenimiento_articulos_on_user_id"
  end

  create_table "mantenimiento_formulas", force: :cascade do |t|
    t.integer "articulo_id"
    t.float "cantidad"
    t.float "costo"
    t.string "secuencia"
    t.integer "articulo_combo"
    t.float "precio"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "formula_id"
    t.string "medida"
  end

  create_table "marcas", force: :cascade do |t|
    t.string "descripcion"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "modelos", force: :cascade do |t|
    t.bigint "marca_id"
    t.string "descripcion"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["marca_id"], name: "index_modelos_on_marca_id"
  end

  create_table "movimientos_inventarios", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "articulo_id"
    t.float "cantidad"
    t.string "accion"
    t.string "motivo"
    t.string "medida"
    t.string "tipo_salida"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "cantidad_en_unidades"
    t.index ["articulo_id"], name: "index_movimientos_inventarios_on_articulo_id"
    t.index ["user_id"], name: "index_movimientos_inventarios_on_user_id"
  end

  create_table "movimientos_viaje", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "vehiculo_id"
    t.bigint "cabecera_factura_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cabecera_factura_id"], name: "index_movimientos_viaje_on_cabecera_factura_id"
    t.index ["user_id"], name: "index_movimientos_viaje_on_user_id"
    t.index ["vehiculo_id"], name: "index_movimientos_viaje_on_vehiculo_id"
  end

  create_table "municipios", force: :cascade do |t|
    t.bigint "provincia_id"
    t.string "nombre"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "codigo"
    t.index ["provincia_id"], name: "index_municipios_on_provincia_id"
  end

  create_table "notas", force: :cascade do |t|
    t.bigint "cliente_id"
    t.bigint "user_id", null: false
    t.bigint "tipo_factura_id", null: false
    t.float "total"
    t.string "identificador"
    t.integer "numero_documento"
    t.string "numero_comprobante"
    t.datetime "fecha_equivalente", precision: nil
    t.string "no_cliente_nombre"
    t.string "no_cliente_direccion"
    t.boolean "estado"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "fecha_valida", precision: nil
    t.string "fecha_hora_firma"
    t.string "trackId"
    t.string "security_code"
    t.string "xml_file_name"
    t.string "qr_url_dgii"
    t.string "serie"
    t.string "razon"
    t.float "bruto"
    t.float "itbis"
    t.string "is_aceptada"
    t.string "dgii_message"
    t.string "no_cliente_rnc"
    t.index ["cliente_id"], name: "index_notas_on_cliente_id"
    t.index ["tipo_factura_id"], name: "index_notas_on_tipo_factura_id"
    t.index ["user_id"], name: "index_notas_on_user_id"
  end

  create_table "permisos", force: :cascade do |t|
    t.string "nombre"
    t.string "descripcion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "controlador"
    t.boolean "mostrar_front"
  end

  create_table "permisos_acciones", force: :cascade do |t|
    t.bigint "permiso_id", null: false
    t.bigint "accion_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["accion_id"], name: "index_permisos_acciones_on_accion_id"
    t.index ["permiso_id", "accion_id"], name: "index_permisos_acciones_on_permiso_id_and_accion_id"
    t.index ["permiso_id"], name: "index_permisos_acciones_on_permiso_id"
  end

  create_table "producciones", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "numero"
    t.datetime "fecha_equivalente", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id"], name: "index_producciones_on_user_id"
  end

  create_table "provincias", force: :cascade do |t|
    t.string "nombre"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "codigo"
  end

  create_table "recibos_ingresos", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "tipo_factura_id"
    t.bigint "cliente_id"
    t.bigint "vehiculo_id"
    t.float "total"
    t.integer "chofer"
    t.string "forma_pago"
    t.integer "numero_recibo"
    t.integer "incidencia"
    t.float "devuelta"
    t.datetime "fecha_equivalente", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "estado"
    t.float "bruto"
    t.float "mora"
    t.float "balance_cliente"
    t.index ["cliente_id"], name: "index_recibos_ingresos_on_cliente_id"
    t.index ["tipo_factura_id"], name: "index_recibos_ingresos_on_tipo_factura_id"
    t.index ["user_id"], name: "index_recibos_ingresos_on_user_id"
    t.index ["vehiculo_id"], name: "index_recibos_ingresos_on_vehiculo_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "nombre"
    t.string "descripcion"
    t.string "ruta_defecto"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "estado"
    t.string "key"
  end

  create_table "roles_permisos_acciones", force: :cascade do |t|
    t.bigint "role_id", null: false
    t.bigint "permiso_accion_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["permiso_accion_id"], name: "index_roles_permisos_acciones_on_permiso_accion_id"
    t.index ["role_id", "permiso_accion_id"], name: "index_roles_permisos_acciones_on_role_id_and_permiso_accion_id"
    t.index ["role_id"], name: "index_roles_permisos_acciones_on_role_id"
  end

  create_table "secuencia_comprobantes", force: :cascade do |t|
    t.bigint "tipo_factura_id"
    t.bigint "secuencia"
    t.bigint "desde"
    t.bigint "hasta"
    t.datetime "fecha_compra", precision: nil
    t.datetime "fecha_valida", precision: nil
    t.boolean "estado"
    t.boolean "usado"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "referencia"
    t.index ["tipo_factura_id"], name: "index_secuencia_comprobantes_on_tipo_factura_id"
  end

  create_table "secuencia_facturas", force: :cascade do |t|
    t.bigint "tipo_factura_id"
    t.integer "secuencia"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["tipo_factura_id"], name: "index_secuencia_facturas_on_tipo_factura_id"
  end

  create_table "suplidores", force: :cascade do |t|
    t.string "nombre"
    t.string "telefono"
    t.string "direccion"
    t.string "email"
    t.boolean "estado"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index "immutable_unaccent((direccion)::text) gin_trgm_ops", name: "index_suplidores_on_unaccent_direccion_trgm", using: :gin
    t.index "immutable_unaccent((email)::text) gin_trgm_ops", name: "index_suplidores_on_unaccent_email_trgm", using: :gin
    t.index "immutable_unaccent((nombre)::text) gin_trgm_ops", name: "index_suplidores_on_unaccent_nombre_trgm", using: :gin
    t.index ["nombre"], name: "index_suplidores_on_nombre"
  end

  create_table "tasas_de_cambio", force: :cascade do |t|
    t.bigint "divisa_id", null: false
    t.bigint "user_id"
    t.bigint "last_user_update_id"
    t.date "fecha_equivalente"
    t.float "valor", default: 0.0
    t.integer "secuencia", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["divisa_id"], name: "index_tasas_de_cambio_on_divisa_id"
    t.index ["last_user_update_id"], name: "index_tasas_de_cambio_on_last_user_update_id"
    t.index ["user_id"], name: "index_tasas_de_cambio_on_user_id"
  end

  create_table "tipo_articulos", force: :cascade do |t|
    t.text "descripcion"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "tipo"
    t.string "codigo"
  end

  create_table "tipo_facturas", force: :cascade do |t|
    t.string "referencia"
    t.string "descripcion"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "serie"
    t.string "key"
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at", precision: nil
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.bigint "imagen_id"
    t.string "nombre"
    t.string "usuario"
    t.string "apellido"
    t.string "sexo"
    t.string "telefono"
    t.string "email"
    t.date "fecha_nacimiento"
    t.boolean "estado"
    t.string "role"
    t.json "tokens"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["imagen_id"], name: "index_users_on_imagen_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  create_table "vehiculos", force: :cascade do |t|
    t.bigint "user_id"
    t.string "marca"
    t.string "modelo"
    t.integer "cantidad_viajes"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "nombre_no_empleado"
    t.string "apellido_no_empleado"
    t.string "telefono_no_empleado"
    t.string "anio"
    t.boolean "estado"
    t.index ["user_id"], name: "index_vehiculos_on_user_id"
  end

  add_foreign_key "articulos", "imagenes"
  add_foreign_key "articulos", "tipo_articulos"
  add_foreign_key "cabecera_conduces", "clientes"
  add_foreign_key "cabecera_conduces", "users"
  add_foreign_key "cabecera_facturas", "clientes"
  add_foreign_key "cabecera_facturas", "suplidores"
  add_foreign_key "cabecera_facturas", "tipo_facturas"
  add_foreign_key "cabecera_facturas", "users"
  add_foreign_key "calendar_event_links", "calendar_events"
  add_foreign_key "calendar_events", "calendar_event_types"
  add_foreign_key "calendar_events", "users", column: "created_by_id"
  add_foreign_key "calendar_events", "users", column: "updated_by_id"
  add_foreign_key "camiones_viajes", "vehiculos"
  add_foreign_key "choferes_viajes", "recibos_ingresos"
  add_foreign_key "choferes_viajes", "users"
  add_foreign_key "clientes", "imagenes"
  add_foreign_key "clientes", "municipios"
  add_foreign_key "commertial_approval_receptions", "cabecera_facturas"
  add_foreign_key "commertial_approval_receptions", "suplidores"
  add_foreign_key "contenido_articulos", "articulos"
  add_foreign_key "costo_fletes", "municipios"
  add_foreign_key "costos_fletes_historiales", "costo_fletes"
  add_foreign_key "costos_fletes_historiales", "users"
  add_foreign_key "cuadre_caja_denominaciones", "cuadre_cajas"
  add_foreign_key "cuadre_caja_denominaciones", "divisas"
  add_foreign_key "cuadre_caja_denominaciones", "tasas_de_cambio"
  add_foreign_key "cuadre_caja_eventos", "cuadre_cajas"
  add_foreign_key "cuadre_caja_eventos", "users"
  add_foreign_key "cuadre_caja_movimientos", "cuadre_cajas"
  add_foreign_key "cuadre_cajas", "users"
  add_foreign_key "cuadre_cajas", "users", column: "approved_by_id"
  add_foreign_key "cuadre_cajas", "users", column: "prepared_by_id"
  add_foreign_key "cuadre_cajas", "users", column: "rejected_by_id"
  add_foreign_key "cuadre_cajas", "users", column: "reopened_by_id"
  add_foreign_key "cuadre_cajas", "users", column: "submitted_by_id"
  add_foreign_key "detalle_conduces", "articulos"
  add_foreign_key "detalle_conduces", "cabecera_conduces"
  add_foreign_key "detalle_conduces", "detalle_facturas"
  add_foreign_key "detalle_facturas", "articulos"
  add_foreign_key "detalle_facturas", "cabecera_facturas"
  add_foreign_key "detalle_recibos", "cabecera_facturas"
  add_foreign_key "detalle_recibos", "recibos_ingresos"
  add_foreign_key "detalles_facturas_notas", "articulos"
  add_foreign_key "detalles_facturas_notas", "detalle_facturas"
  add_foreign_key "detalles_facturas_notas", "facturas_aplicadas"
  add_foreign_key "detalles_produccion", "articulos"
  add_foreign_key "detalles_produccion", "producciones"
  add_foreign_key "document_references", "users", column: "referenced_by_id"
  add_foreign_key "documentos_de_identidad", "clientes"
  add_foreign_key "documentos_de_identidad", "suplidores"
  add_foreign_key "documentos_de_identidad", "users"
  add_foreign_key "ecf_receptions", "suplidores"
  add_foreign_key "facturas_aplicadas", "cabecera_facturas"
  add_foreign_key "facturas_aplicadas", "notas"
  add_foreign_key "formulas_productos_terminados", "articulos"
  add_foreign_key "historico_producciones", "articulos"
  add_foreign_key "historico_producciones", "users"
  add_foreign_key "mantenimiento_articulos", "articulos"
  add_foreign_key "mantenimiento_articulos", "users"
  add_foreign_key "modelos", "marcas"
  add_foreign_key "movimientos_inventarios", "articulos"
  add_foreign_key "movimientos_inventarios", "users"
  add_foreign_key "movimientos_viaje", "cabecera_facturas"
  add_foreign_key "movimientos_viaje", "users"
  add_foreign_key "movimientos_viaje", "vehiculos"
  add_foreign_key "municipios", "provincias"
  add_foreign_key "notas", "clientes"
  add_foreign_key "notas", "tipo_facturas"
  add_foreign_key "notas", "users"
  add_foreign_key "permisos_acciones", "acciones"
  add_foreign_key "permisos_acciones", "permisos"
  add_foreign_key "producciones", "users"
  add_foreign_key "recibos_ingresos", "clientes"
  add_foreign_key "recibos_ingresos", "tipo_facturas"
  add_foreign_key "recibos_ingresos", "users"
  add_foreign_key "recibos_ingresos", "vehiculos"
  add_foreign_key "roles_permisos_acciones", "permisos_acciones"
  add_foreign_key "roles_permisos_acciones", "roles"
  add_foreign_key "secuencia_comprobantes", "tipo_facturas"
  add_foreign_key "secuencia_facturas", "tipo_facturas"
  add_foreign_key "tasas_de_cambio", "divisas"
  add_foreign_key "tasas_de_cambio", "users"
  add_foreign_key "tasas_de_cambio", "users", column: "last_user_update_id"
  add_foreign_key "users", "imagenes"
  add_foreign_key "vehiculos", "users"
end
