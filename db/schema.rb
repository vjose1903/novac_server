# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_06_23_130726) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "articulos", force: :cascade do |t|
    t.bigint "imagen_id"
    t.bigint "suplidor_id"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["imagen_id"], name: "index_articulos_on_imagen_id"
    t.index ["suplidor_id"], name: "index_articulos_on_suplidor_id"
    t.index ["tipo_articulo_id"], name: "index_articulos_on_tipo_articulo_id"
  end

  create_table "cabecera_conduces", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "cliente_id"
    t.integer "numero_conduce"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cliente_id"], name: "index_cabecera_conduces_on_cliente_id"
    t.index ["user_id"], name: "index_cabecera_conduces_on_user_id"
  end

  create_table "cabecera_facturas", force: :cascade do |t|
    t.bigint "tipo_factura_id"
    t.bigint "suplidor_id"
    t.bigint "cliente_id"
    t.bigint "user_id"
    t.datetime "fecha_facturacion"
    t.date "fecha_vencimiento"
    t.date "fecha_valida"
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
    t.boolean "adelantada"
    t.boolean "is_nota"
    t.boolean "tiene_nota"
    t.string "aplicada_a"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cliente_id"], name: "index_cabecera_facturas_on_cliente_id"
    t.index ["suplidor_id"], name: "index_cabecera_facturas_on_suplidor_id"
    t.index ["tipo_factura_id"], name: "index_cabecera_facturas_on_tipo_factura_id"
    t.index ["user_id"], name: "index_cabecera_facturas_on_user_id"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["imagen_id"], name: "index_clientes_on_imagen_id"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["articulo_id"], name: "index_contenido_articulos_on_articulo_id"
  end

  create_table "detalle_conduces", force: :cascade do |t|
    t.bigint "cabecera_conduce_id"
    t.bigint "detalle_factura_id"
    t.bigint "articulo_id"
    t.integer "cantidad"
    t.string "unidad"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.float "itbis"
    t.float "precio"
    t.float "costo"
    t.integer "retirado"
    t.integer "retirado_en_venta"
    t.float "descuento_valor"
    t.float "descuento_porciento"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["articulo_id"], name: "index_detalle_facturas_on_articulo_id"
    t.index ["cabecera_factura_id"], name: "index_detalle_facturas_on_cabecera_factura_id"
  end

  create_table "detalle_recibos", force: :cascade do |t|
    t.bigint "recibos_ingreso_id"
    t.bigint "cabecera_factura_id"
    t.boolean "pago_total"
    t.float "deposito"
    t.string "descripcion"
    t.boolean "pago_a_tiempo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cabecera_factura_id"], name: "index_detalle_recibos_on_cabecera_factura_id"
    t.index ["recibos_ingreso_id"], name: "index_detalle_recibos_on_recibos_ingreso_id"
  end

  create_table "documentos_de_identidad", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "cliente_id"
    t.bigint "suplidor_id"
    t.string "descripcion"
    t.string "documento"
    t.boolean "principal"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cliente_id"], name: "index_documentos_de_identidad_on_cliente_id"
    t.index ["suplidor_id"], name: "index_documentos_de_identidad_on_suplidor_id"
    t.index ["user_id"], name: "index_documentos_de_identidad_on_user_id"
  end

  create_table "formulas_productos_terminados", force: :cascade do |t|
    t.bigint "articulo_id"
    t.float "cantidad"
    t.float "costo"
    t.integer "secuencia"
    t.integer "articulo_combo"
    t.float "precio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["articulo_id"], name: "index_formulas_productos_terminados_on_articulo_id"
  end

  create_table "historico_produccions", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "articulo_id"
    t.float "cantidad"
    t.string "medida"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["articulo_id"], name: "index_historico_produccions_on_articulo_id"
    t.index ["user_id"], name: "index_historico_produccions_on_user_id"
  end

  create_table "imagenes", force: :cascade do |t|
    t.string "file_name"
    t.string "base_64"
    t.string "path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mantenimiento_articulos", force: :cascade do |t|
    t.bigint "articulo_id"
    t.bigint "user_id"
    t.string "ant_nombre"
    t.string "ant_tipoArticulo"
    t.integer "ant_suplidor"
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
    t.integer "ant_idPadre"
    t.integer "ant_idHijo"
    t.integer "ant_referenciaPadre"
    t.integer "ant_referenciaHijo"
    t.integer "ant_tipoArticuloId"
    t.boolean "ant_isCombo"
    t.boolean "ant_calcularItbis"
    t.float "ant_otrosCostos"
    t.integer "secuencia"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["articulo_id"], name: "index_mantenimiento_articulos_on_articulo_id"
    t.index ["user_id"], name: "index_mantenimiento_articulos_on_user_id"
  end

  create_table "mantenimiento_formulas", force: :cascade do |t|
    t.integer "articulo_id"
    t.float "cantidad"
    t.float "costo"
    t.integer "secuencia"
    t.integer "articulo_combo"
    t.float "precio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "movimientos_inventarios", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "articulo_id"
    t.float "cantidad"
    t.string "accion"
    t.string "motivo"
    t.string "medida"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["articulo_id"], name: "index_movimientos_inventarios_on_articulo_id"
    t.index ["user_id"], name: "index_movimientos_inventarios_on_user_id"
  end

  create_table "recibos_ingresos", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "tipo_recibo_id"
    t.bigint "cliente_id"
    t.float "total"
    t.string "forma_pago"
    t.integer "numero_recibo"
    t.float "devuelta"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cliente_id"], name: "index_recibos_ingresos_on_cliente_id"
    t.index ["tipo_recibo_id"], name: "index_recibos_ingresos_on_tipo_recibo_id"
    t.index ["user_id"], name: "index_recibos_ingresos_on_user_id"
  end

  create_table "secuencia_comprobantes", force: :cascade do |t|
    t.bigint "tipo_factura_id"
    t.integer "secuencia"
    t.integer "desde"
    t.integer "hasta"
    t.datetime "fecha_compra"
    t.datetime "fecha_valida"
    t.boolean "estado"
    t.boolean "usado"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tipo_factura_id"], name: "index_secuencia_comprobantes_on_tipo_factura_id"
  end

  create_table "secuencia_facturas", force: :cascade do |t|
    t.bigint "tipo_factura_id"
    t.integer "secuencia"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tipo_factura_id"], name: "index_secuencia_facturas_on_tipo_factura_id"
  end

  create_table "secuencia_ingresos", force: :cascade do |t|
    t.bigint "tipo_recibo_id"
    t.integer "secuencia"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tipo_recibo_id"], name: "index_secuencia_ingresos_on_tipo_recibo_id"
  end

  create_table "suplidores", force: :cascade do |t|
    t.string "nombre"
    t.string "telefono"
    t.string "direccion"
    t.string "email"
    t.boolean "estado"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tipo_articulos", force: :cascade do |t|
    t.text "descripcion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tipo_facturas", force: :cascade do |t|
    t.string "referencia"
    t.string "descripcion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tipo_recibos", force: :cascade do |t|
    t.text "descripcion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.bigint "imagen_id"
    t.string "nombre"
    t.string "usuario"
    t.string "apellido"
    t.string "sexo"
    t.string "telefono"
    t.string "email"
    t.string "fecha_nacimiento"
    t.boolean "estado"
    t.string "role"
    t.json "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["imagen_id"], name: "index_users_on_imagen_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "articulos", "imagenes"
  add_foreign_key "articulos", "suplidores"
  add_foreign_key "articulos", "tipo_articulos"
  add_foreign_key "cabecera_conduces", "clientes"
  add_foreign_key "cabecera_conduces", "users"
  add_foreign_key "cabecera_facturas", "clientes"
  add_foreign_key "cabecera_facturas", "suplidores"
  add_foreign_key "cabecera_facturas", "tipo_facturas"
  add_foreign_key "cabecera_facturas", "users"
  add_foreign_key "clientes", "imagenes"
  add_foreign_key "contenido_articulos", "articulos"
  add_foreign_key "detalle_conduces", "articulos"
  add_foreign_key "detalle_conduces", "cabecera_conduces"
  add_foreign_key "detalle_conduces", "detalle_facturas"
  add_foreign_key "detalle_facturas", "articulos"
  add_foreign_key "detalle_facturas", "cabecera_facturas"
  add_foreign_key "detalle_recibos", "cabecera_facturas"
  add_foreign_key "detalle_recibos", "recibos_ingresos"
  add_foreign_key "documentos_de_identidad", "clientes"
  add_foreign_key "documentos_de_identidad", "suplidores"
  add_foreign_key "documentos_de_identidad", "users"
  add_foreign_key "formulas_productos_terminados", "articulos"
  add_foreign_key "historico_produccions", "articulos"
  add_foreign_key "historico_produccions", "users"
  add_foreign_key "mantenimiento_articulos", "articulos"
  add_foreign_key "mantenimiento_articulos", "users"
  add_foreign_key "movimientos_inventarios", "articulos"
  add_foreign_key "movimientos_inventarios", "users"
  add_foreign_key "recibos_ingresos", "clientes"
  add_foreign_key "recibos_ingresos", "tipo_recibos"
  add_foreign_key "recibos_ingresos", "users"
  add_foreign_key "secuencia_comprobantes", "tipo_facturas"
  add_foreign_key "secuencia_facturas", "tipo_facturas"
  add_foreign_key "secuencia_ingresos", "tipo_recibos"
  add_foreign_key "users", "imagenes"
end
