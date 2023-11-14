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

ActiveRecord::Schema[7.0].define(version: 2023_11_04_120937) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.bigint "sub_tipo_articulo_id"
    t.index ["estado", "nombre"], name: "index_articulos_on_estado_and_nombre", unique: true, where: "(estado = true)"
    t.index ["imagen_id"], name: "index_articulos_on_imagen_id"
    t.index ["sub_tipo_articulo_id"], name: "index_articulos_on_sub_tipo_articulo_id"
    t.index ["tipo_articulo_id"], name: "index_articulos_on_tipo_articulo_id"
  end

  create_table "bancos", force: :cascade do |t|
    t.string "nombre", null: false
    t.string "rnc", null: false
    t.string "comentario"
    t.string "telefono"
    t.string "direccion"
    t.string "ejecutivo_cuenta"
    t.string "telefono_ejecutivo_cuenta"
    t.boolean "estado", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.boolean "can_pagar"
    t.index ["cliente_id"], name: "index_cabecera_facturas_on_cliente_id"
    t.index ["suplidor_id"], name: "index_cabecera_facturas_on_suplidor_id"
    t.index ["tipo_factura_id"], name: "index_cabecera_facturas_on_tipo_factura_id"
    t.index ["user_id"], name: "index_cabecera_facturas_on_user_id"
  end

  create_table "cabezas_asientos_contables", force: :cascade do |t|
    t.bigint "usuario_creador_id", null: false
    t.bigint "usuario_anulador_id"
    t.bigint "periodo_fiscal_id", null: false
    t.string "comentario"
    t.string "tipo"
    t.date "fecha_equivalente"
    t.date "fecha_anulacion"
    t.boolean "estado", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["periodo_fiscal_id"], name: "index_cabezas_asientos_contables_on_periodo_fiscal_id"
    t.index ["usuario_anulador_id"], name: "index_cabezas_asientos_contables_on_usuario_anulador_id"
    t.index ["usuario_creador_id"], name: "index_cabezas_asientos_contables_on_usuario_creador_id"
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

  create_table "categorias_entidades_contables", force: :cascade do |t|
    t.bigint "cuenta_contable_control_id", null: false
    t.bigint "cuenta_contable_auxiliar_id"
    t.bigint "configuracion_entidad_cuenta_id", null: false
    t.string "descripcion"
    t.string "key"
    t.string "entidad"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["configuracion_entidad_cuenta_id"], name: "idx_cat_ent_cont_cuenta_cont_config_ent"
    t.index ["cuenta_contable_auxiliar_id"], name: "idx_cat_ent_cont_cuenta_cont_aux"
    t.index ["cuenta_contable_control_id"], name: "idx_cat_ent_cont_cuenta_cont_cont"
  end

  create_table "choferes_viajes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "recibos_ingreso_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recibos_ingreso_id"], name: "index_choferes_viajes_on_recibos_ingreso_id"
    t.index ["user_id"], name: "index_choferes_viajes_on_user_id"
  end

  create_table "cierre_cuentas", force: :cascade do |t|
    t.bigint "periodo_fiscal_id", null: false
    t.bigint "cuenta_contable_id", null: false
    t.float "enero", default: 0.0
    t.float "enero_debito", default: 0.0
    t.float "enero_credito", default: 0.0
    t.float "febrero", default: 0.0
    t.float "febrero_debito", default: 0.0
    t.float "febrero_credito", default: 0.0
    t.float "marzo", default: 0.0
    t.float "marzo_debito", default: 0.0
    t.float "marzo_credito", default: 0.0
    t.float "abril", default: 0.0
    t.float "abril_debito", default: 0.0
    t.float "abril_credito", default: 0.0
    t.float "mayo", default: 0.0
    t.float "mayo_debito", default: 0.0
    t.float "mayo_credito", default: 0.0
    t.float "junio", default: 0.0
    t.float "junio_debito", default: 0.0
    t.float "junio_credito", default: 0.0
    t.float "julio", default: 0.0
    t.float "julio_debito", default: 0.0
    t.float "julio_credito", default: 0.0
    t.float "agosto", default: 0.0
    t.float "agosto_debito", default: 0.0
    t.float "agosto_credito", default: 0.0
    t.float "septiembre", default: 0.0
    t.float "septiembre_debito", default: 0.0
    t.float "septiembre_credito", default: 0.0
    t.float "octubre", default: 0.0
    t.float "octubre_debito", default: 0.0
    t.float "octubre_credito", default: 0.0
    t.float "noviembre", default: 0.0
    t.float "noviembre_debito", default: 0.0
    t.float "noviembre_credito", default: 0.0
    t.float "diciembre", default: 0.0
    t.float "diciembre_debito", default: 0.0
    t.float "diciembre_credito", default: 0.0
    t.float "total_anual", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cuenta_contable_id"], name: "index_cierre_cuentas_on_cuenta_contable_id"
    t.index ["periodo_fiscal_id"], name: "index_cierre_cuentas_on_periodo_fiscal_id"
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
    t.index ["imagen_id"], name: "index_clientes_on_imagen_id"
  end

  create_table "config_articulos", force: :cascade do |t|
    t.float "porciento_ganancia"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "configuraciones_entidades_cuentas", force: :cascade do |t|
    t.string "descripcion"
    t.string "entidad"
    t.bigint "cuenta_contable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "key"
    t.boolean "is_nacional"
    t.boolean "has_comun"
    t.boolean "has_individual"
    t.boolean "has_categoria"
    t.boolean "has_sub_categoria"
    t.index ["cuenta_contable_id"], name: "index_configuraciones_entidades_cuentas_on_cuenta_contable_id"
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
    t.index ["user_id"], name: "index_cuadre_cajas_on_user_id"
  end

  create_table "cuentas_bancarias", force: :cascade do |t|
    t.bigint "banco_id", null: false
    t.bigint "tipo_cuenta_bancaria_id", null: false
    t.bigint "divisa_id", null: false
    t.bigint "cuenta_contable_id", null: false
    t.bigint "cuenta_contable_prima_id"
    t.date "fecha_apertura"
    t.string "numero_cuenta"
    t.string "comentario"
    t.string "descripcion"
    t.boolean "is_nacional"
    t.boolean "estado", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "balance_inicial_banco", default: 0.0
    t.float "balance_inicial_libro", default: 0.0
    t.index ["banco_id"], name: "index_cuentas_bancarias_on_banco_id"
    t.index ["cuenta_contable_id"], name: "index_cuentas_bancarias_on_cuenta_contable_id"
    t.index ["cuenta_contable_prima_id"], name: "index_cuentas_bancarias_on_cuenta_contable_prima_id"
    t.index ["divisa_id"], name: "index_cuentas_bancarias_on_divisa_id"
    t.index ["tipo_cuenta_bancaria_id"], name: "index_cuentas_bancarias_on_tipo_cuenta_bancaria_id"
  end

  create_table "cuentas_contables", force: :cascade do |t|
    t.bigint "grupo_cuenta_id", null: false
    t.string "descripcion"
    t.string "codigo"
    t.integer "nivel"
    t.string "origen"
    t.string "tipo"
    t.boolean "is_control"
    t.boolean "estado", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "cuenta_control_id"
    t.index ["grupo_cuenta_id"], name: "index_cuentas_contables_on_grupo_cuenta_id"
  end

  create_table "depositos", force: :cascade do |t|
    t.bigint "cuenta_bancaria_id", null: false
    t.bigint "divisa_id", null: false
    t.bigint "user_creador_id", null: false
    t.bigint "user_anulador_id"
    t.bigint "last_user_update_id"
    t.float "tasa"
    t.float "monto"
    t.float "monto_local"
    t.string "comentario"
    t.string "numero_referencia"
    t.date "fecha_equivalente"
    t.date "fecha_anulacion"
    t.boolean "estado", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cuenta_bancaria_id"], name: "index_depositos_on_cuenta_bancaria_id"
    t.index ["divisa_id"], name: "index_depositos_on_divisa_id"
    t.index ["last_user_update_id"], name: "index_depositos_on_last_user_update_id"
    t.index ["user_anulador_id"], name: "index_depositos_on_user_anulador_id"
    t.index ["user_creador_id"], name: "index_depositos_on_user_creador_id"
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
    t.index ["cabecera_factura_id"], name: "index_detalle_recibos_on_cabecera_factura_id"
    t.index ["recibos_ingreso_id"], name: "index_detalle_recibos_on_recibos_ingreso_id"
  end

  create_table "detalles_asientos_contables", force: :cascade do |t|
    t.bigint "cabeza_asiento_contable_id", null: false
    t.bigint "cuenta_contable_auxiliar_id", null: false
    t.bigint "cuenta_contable_control_id", null: false
    t.float "valor_debito"
    t.float "valor_credito"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cabeza_asiento_contable_id"], name: "idx_det_as_cont_cabeza_asi_cont"
    t.index ["cuenta_contable_auxiliar_id"], name: "idx_det_as_cont_cuenta_cont_aux"
    t.index ["cuenta_contable_control_id"], name: "idx_det_as_cont_cuenta_cont_cont"
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
    t.index ["articulo_id"], name: "index_detalles_facturas_notas_on_articulo_id"
    t.index ["detalle_factura_id"], name: "index_detalles_facturas_notas_on_detalle_factura_id"
    t.index ["factura_aplicada_id"], name: "index_detalles_facturas_notas_on_factura_aplicada_id"
    t.index ["tipo_factura_id"], name: "index_detalles_facturas_notas_on_tipo_factura_id"
  end

  create_table "detalles_periodos_fiscales", force: :cascade do |t|
    t.bigint "periodo_fiscal_id", null: false
    t.boolean "enero"
    t.boolean "febrero"
    t.boolean "marzo"
    t.boolean "abril"
    t.boolean "mayo"
    t.boolean "junio"
    t.boolean "julio"
    t.boolean "agosto"
    t.boolean "septiembre"
    t.boolean "octubre"
    t.boolean "noviembre"
    t.boolean "diciembre"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["periodo_fiscal_id"], name: "index_detalles_periodos_fiscales_on_periodo_fiscal_id"
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
    t.index ["cliente_id"], name: "index_documentos_de_identidad_on_cliente_id"
    t.index ["origen_type", "origen_id"], name: "index_documentos_de_identidad_on_origen_type_and_origen_id"
    t.index ["suplidor_id"], name: "index_documentos_de_identidad_on_suplidor_id"
    t.index ["user_id"], name: "index_documentos_de_identidad_on_user_id"
  end

  create_table "entidad_cuentas_contables", force: :cascade do |t|
    t.string "origen_entidad_type", null: false
    t.bigint "origen_entidad_id", null: false
    t.string "key"
    t.string "tipo_agrupacion_contable"
    t.bigint "cuenta_contable_id"
    t.string "origen_categoria_type"
    t.bigint "origen_categoria_id"
    t.bigint "configuracion_entidad_cuenta_id", null: false
    t.boolean "is_comun", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["configuracion_entidad_cuenta_id"], name: "idx_ent_cuenta_cont_config_ent"
    t.index ["cuenta_contable_id"], name: "index_entidad_cuentas_contables_on_cuenta_contable_id"
    t.index ["origen_categoria_type", "origen_categoria_id"], name: "index_entidad_cuentas_contables_on_origen_categoria"
    t.index ["origen_entidad_type", "origen_entidad_id"], name: "index_entidad_cuentas_contables_on_origen_entidad"
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
    t.float "precio"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "medida"
    t.bigint "articulo_combo_id"
    t.index ["articulo_id"], name: "index_formulas_productos_terminados_on_articulo_id"
  end

  create_table "grupos_de_cuentas", force: :cascade do |t|
    t.string "descripcion"
    t.integer "grupo"
    t.string "origen"
    t.string "tipo"
    t.boolean "estado", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["cliente_id"], name: "index_notas_on_cliente_id"
    t.index ["tipo_factura_id"], name: "index_notas_on_tipo_factura_id"
    t.index ["user_id"], name: "index_notas_on_user_id"
  end

  create_table "pago_factura_detalles", force: :cascade do |t|
    t.bigint "pago_factura_id", null: false
    t.bigint "cabecera_factura_id", null: false
    t.float "balance_anterior_factura"
    t.float "balance_factura"
    t.float "deposito"
    t.boolean "is_ultimo"
    t.string "descripcion"
    t.boolean "pago_a_tiempo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cabecera_factura_id"], name: "index_pago_factura_detalles_on_cabecera_factura_id"
    t.index ["pago_factura_id"], name: "index_pago_factura_detalles_on_pago_factura_id"
  end

  create_table "pago_facturas", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "suplidor_id", null: false
    t.bigint "tipo_factura_id", null: false
    t.date "fecha_equivalente"
    t.integer "numero"
    t.string "forma_pago"
    t.boolean "estado", default: true
    t.float "total"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["suplidor_id"], name: "index_pago_facturas_on_suplidor_id"
    t.index ["tipo_factura_id"], name: "index_pago_facturas_on_tipo_factura_id"
    t.index ["user_id"], name: "index_pago_facturas_on_user_id"
  end

  create_table "periodos_fiscales", force: :cascade do |t|
    t.date "fecha_inicio"
    t.date "fecha_cierre"
    t.boolean "estado", default: true
    t.boolean "is_open", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "fecha_cerrado"
    t.bigint "usuario_cerrador_id"
    t.index ["usuario_cerrador_id"], name: "index_periodos_fiscales_on_usuario_cerrador_id"
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

  create_table "sub_tipo_articulos", force: :cascade do |t|
    t.bigint "tipo_articulo_id", null: false
    t.string "descripcion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tipo_articulo_id"], name: "index_sub_tipo_articulos_on_tipo_articulo_id"
  end

  create_table "suplidores", force: :cascade do |t|
    t.string "nombre"
    t.string "telefono"
    t.string "direccion"
    t.string "email"
    t.boolean "estado"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "divisa_id"
    t.index ["divisa_id"], name: "index_suplidores_on_divisa_id"
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

  create_table "tipo_articulo_cuentas_contables", force: :cascade do |t|
    t.string "origen_tipo_type", null: false
    t.bigint "origen_tipo_id", null: false
    t.bigint "configuracion_entidad_cuenta_id"
    t.bigint "cuenta_contable_control_id"
    t.bigint "cuenta_contable_auxiliar_id"
    t.string "key"
    t.string "entidad"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["configuracion_entidad_cuenta_id"], name: "idx_tipo_art_config_ent_cuenta"
    t.index ["cuenta_contable_auxiliar_id"], name: "idx_tipo_art_cuenta_cont_aux"
    t.index ["cuenta_contable_control_id"], name: "idx_tipo_art_cuenta_cont_cont"
    t.index ["origen_tipo_type", "origen_tipo_id"], name: "index_tipo_articulo_cuentas_contables_on_origen_tipo"
  end

  create_table "tipo_articulos", force: :cascade do |t|
    t.text "descripcion"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "tipo"
    t.string "codigo"
  end

  create_table "tipo_cuentas_bancarias", force: :cascade do |t|
    t.string "descripcion"
    t.boolean "estado", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tipo_facturas", force: :cascade do |t|
    t.string "referencia"
    t.string "descripcion"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "transferencias", force: :cascade do |t|
    t.bigint "cuenta_bancaria_origen_id", null: false
    t.bigint "cuenta_bancaria_destino_id"
    t.bigint "divisa_id", null: false
    t.bigint "user_creador_id", null: false
    t.bigint "last_user_update_id"
    t.bigint "user_anulador_id"
    t.float "tasa"
    t.float "monto"
    t.float "monto_local"
    t.string "comentario"
    t.string "nombre_banco_tercero"
    t.string "cuenta_bancaria_tercero"
    t.string "numero_referencia"
    t.date "fecha_equivalente"
    t.date "fecha_anulacion"
    t.boolean "estado", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cuenta_bancaria_destino_id"], name: "index_transferencias_on_cuenta_bancaria_destino_id"
    t.index ["cuenta_bancaria_origen_id"], name: "index_transferencias_on_cuenta_bancaria_origen_id"
    t.index ["divisa_id"], name: "index_transferencias_on_divisa_id"
    t.index ["last_user_update_id"], name: "index_transferencias_on_last_user_update_id"
    t.index ["user_anulador_id"], name: "index_transferencias_on_user_anulador_id"
    t.index ["user_creador_id"], name: "index_transferencias_on_user_creador_id"
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
  add_foreign_key "cabezas_asientos_contables", "periodos_fiscales"
  add_foreign_key "cabezas_asientos_contables", "users", column: "usuario_anulador_id"
  add_foreign_key "cabezas_asientos_contables", "users", column: "usuario_creador_id"
  add_foreign_key "camiones_viajes", "vehiculos"
  add_foreign_key "categorias_entidades_contables", "configuraciones_entidades_cuentas"
  add_foreign_key "categorias_entidades_contables", "cuentas_contables", column: "cuenta_contable_auxiliar_id"
  add_foreign_key "categorias_entidades_contables", "cuentas_contables", column: "cuenta_contable_control_id"
  add_foreign_key "choferes_viajes", "recibos_ingresos"
  add_foreign_key "choferes_viajes", "users"
  add_foreign_key "cierre_cuentas", "cuentas_contables"
  add_foreign_key "cierre_cuentas", "periodos_fiscales"
  add_foreign_key "clientes", "imagenes"
  add_foreign_key "configuraciones_entidades_cuentas", "cuentas_contables"
  add_foreign_key "contenido_articulos", "articulos"
  add_foreign_key "costo_fletes", "municipios"
  add_foreign_key "costos_fletes_historiales", "costo_fletes"
  add_foreign_key "costos_fletes_historiales", "users"
  add_foreign_key "cuadre_cajas", "users"
  add_foreign_key "cuentas_bancarias", "bancos"
  add_foreign_key "cuentas_bancarias", "cuentas_contables"
  add_foreign_key "cuentas_bancarias", "cuentas_contables", column: "cuenta_contable_prima_id"
  add_foreign_key "cuentas_bancarias", "divisas"
  add_foreign_key "cuentas_bancarias", "tipo_cuentas_bancarias"
  add_foreign_key "cuentas_contables", "cuentas_contables", column: "cuenta_control_id"
  add_foreign_key "cuentas_contables", "grupos_de_cuentas"
  add_foreign_key "depositos", "cuentas_bancarias"
  add_foreign_key "depositos", "divisas"
  add_foreign_key "depositos", "users", column: "last_user_update_id"
  add_foreign_key "depositos", "users", column: "user_anulador_id"
  add_foreign_key "depositos", "users", column: "user_creador_id"
  add_foreign_key "detalle_conduces", "articulos"
  add_foreign_key "detalle_conduces", "cabecera_conduces"
  add_foreign_key "detalle_conduces", "detalle_facturas"
  add_foreign_key "detalle_facturas", "articulos"
  add_foreign_key "detalle_facturas", "cabecera_facturas"
  add_foreign_key "detalle_recibos", "cabecera_facturas"
  add_foreign_key "detalle_recibos", "recibos_ingresos"
  add_foreign_key "detalles_asientos_contables", "cabezas_asientos_contables"
  add_foreign_key "detalles_asientos_contables", "cuentas_contables", column: "cuenta_contable_auxiliar_id"
  add_foreign_key "detalles_asientos_contables", "cuentas_contables", column: "cuenta_contable_control_id"
  add_foreign_key "detalles_facturas_notas", "articulos"
  add_foreign_key "detalles_facturas_notas", "detalle_facturas"
  add_foreign_key "detalles_facturas_notas", "facturas_aplicadas"
  add_foreign_key "detalles_periodos_fiscales", "periodos_fiscales"
  add_foreign_key "detalles_produccion", "articulos"
  add_foreign_key "detalles_produccion", "producciones"
  add_foreign_key "documentos_de_identidad", "clientes"
  add_foreign_key "documentos_de_identidad", "suplidores"
  add_foreign_key "documentos_de_identidad", "users"
  add_foreign_key "entidad_cuentas_contables", "configuraciones_entidades_cuentas"
  add_foreign_key "entidad_cuentas_contables", "cuentas_contables"
  add_foreign_key "facturas_aplicadas", "cabecera_facturas"
  add_foreign_key "facturas_aplicadas", "notas"
  add_foreign_key "formulas_productos_terminados", "articulos"
  add_foreign_key "formulas_productos_terminados", "articulos", column: "articulo_combo_id"
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
  add_foreign_key "pago_factura_detalles", "cabecera_facturas"
  add_foreign_key "pago_factura_detalles", "pago_facturas"
  add_foreign_key "pago_facturas", "suplidores"
  add_foreign_key "pago_facturas", "tipo_facturas"
  add_foreign_key "pago_facturas", "users"
  add_foreign_key "periodos_fiscales", "users", column: "usuario_cerrador_id"
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
  add_foreign_key "sub_tipo_articulos", "tipo_articulos"
  add_foreign_key "tasas_de_cambio", "divisas"
  add_foreign_key "tasas_de_cambio", "users"
  add_foreign_key "tasas_de_cambio", "users", column: "last_user_update_id"
  add_foreign_key "tipo_articulo_cuentas_contables", "configuraciones_entidades_cuentas"
  add_foreign_key "tipo_articulo_cuentas_contables", "cuentas_contables", column: "cuenta_contable_auxiliar_id"
  add_foreign_key "tipo_articulo_cuentas_contables", "cuentas_contables", column: "cuenta_contable_control_id"
  add_foreign_key "transferencias", "cuentas_bancarias", column: "cuenta_bancaria_destino_id"
  add_foreign_key "transferencias", "cuentas_bancarias", column: "cuenta_bancaria_origen_id"
  add_foreign_key "transferencias", "divisas"
  add_foreign_key "transferencias", "users", column: "last_user_update_id"
  add_foreign_key "transferencias", "users", column: "user_anulador_id"
  add_foreign_key "transferencias", "users", column: "user_creador_id"
  add_foreign_key "users", "imagenes"
  add_foreign_key "vehiculos", "users"
end
