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

ActiveRecord::Schema.define(version: 2020_07_28_115216) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "articulos", force: :cascade do |t|
    t.bigint "suplidor_id"
    t.bigint "marca_id"
    t.bigint "modelo_id"
    t.bigint "tipo_articulo_id"
    t.string "identificador"
    t.string "nombre"
    t.string "color"
    t.float "costo_principal"
    t.float "precio_principal"
    t.integer "existencia"
    t.string "codigo"
    t.string "medida"
    t.boolean "is_detallable"
    t.integer "aviso_existencia"
    t.string "medida_alerta"
    t.boolean "estado"
    t.boolean "is_combo"
    t.boolean "unico"
    t.boolean "agotado"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["marca_id"], name: "index_articulos_on_marca_id"
    t.index ["modelo_id"], name: "index_articulos_on_modelo_id"
    t.index ["suplidor_id"], name: "index_articulos_on_suplidor_id"
    t.index ["tipo_articulo_id"], name: "index_articulos_on_tipo_articulo_id"
  end

  create_table "cabecera_facturas", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "cliente_id"
    t.string "forma_pago"
    t.integer "numero_factura"
    t.float "total_factura"
    t.boolean "pagada"
    t.float "balance"
    t.boolean "tiene_nota"
    t.float "devuelta"
    t.string "noCliente_nombre"
    t.string "noCliente_direccion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cliente_id"], name: "index_cabecera_facturas_on_cliente_id"
    t.index ["user_id"], name: "index_cabecera_facturas_on_user_id"
  end

  create_table "cabecera_recibos", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "cliente_id"
    t.string "forma_pago"
    t.integer "numero_recibo"
    t.float "total"
    t.float "devuelta"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cliente_id"], name: "index_cabecera_recibos_on_cliente_id"
    t.index ["user_id"], name: "index_cabecera_recibos_on_user_id"
  end

  create_table "clientes", force: :cascade do |t|
    t.string "nombre"
    t.string "apellido"
    t.string "telefono"
    t.string "direccion"
    t.string "email"
    t.boolean "estado"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contenido_articulos", force: :cascade do |t|
    t.bigint "articulo_id"
    t.string "referencia"
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

  create_table "detalle_facturas", force: :cascade do |t|
    t.bigint "cabecera_factura_id"
    t.bigint "articulo_id"
    t.integer "cantidad"
    t.float "total"
    t.float "precio"
    t.float "costo"
    t.integer "retirado"
    t.integer "retirado_en_venta"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["articulo_id"], name: "index_detalle_facturas_on_articulo_id"
    t.index ["cabecera_factura_id"], name: "index_detalle_facturas_on_cabecera_factura_id"
  end

  create_table "detalle_recibos", force: :cascade do |t|
    t.bigint "cabecera_recibo_id"
    t.bigint "trabajo_id"
    t.bigint "cabecera_factura_id"
    t.float "total"
    t.string "descripcion"
    t.float "deposito"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cabecera_factura_id"], name: "index_detalle_recibos_on_cabecera_factura_id"
    t.index ["cabecera_recibo_id"], name: "index_detalle_recibos_on_cabecera_recibo_id"
    t.index ["trabajo_id"], name: "index_detalle_recibos_on_trabajo_id"
  end

  create_table "documentos_de_identidad", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "suplidor_id"
    t.bigint "cliente_id"
    t.string "descripcion"
    t.string "documento"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cliente_id"], name: "index_documentos_de_identidad_on_cliente_id"
    t.index ["suplidor_id"], name: "index_documentos_de_identidad_on_suplidor_id"
    t.index ["user_id"], name: "index_documentos_de_identidad_on_user_id"
  end

  create_table "historico_articulos", force: :cascade do |t|
    t.bigint "articulo_id"
    t.bigint "suplidor_id"
    t.bigint "marca_id"
    t.bigint "modelo_id"
    t.bigint "tipo_articulo_id"
    t.bigint "user_id"
    t.string "identificador"
    t.string "nombre"
    t.string "color"
    t.float "costo_principal"
    t.float "precio_principal"
    t.integer "existencia"
    t.string "codigo"
    t.string "medida"
    t.boolean "is_detallable"
    t.integer "aviso_existencia"
    t.string "medida_alerta"
    t.boolean "estado"
    t.boolean "is_combo"
    t.integer "secuencia"
    t.boolean "agotado"
    t.string "medida_hijo"
    t.float "costo_hijo"
    t.float "precio_hijo"
    t.integer "cantidad_hijo"
    t.integer "referencia_hijo"
    t.string "medida_padre"
    t.float "costo_padre"
    t.float "precio_padre"
    t.integer "cantidad_padre"
    t.integer "referencia_padre"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["articulo_id"], name: "index_historico_articulos_on_articulo_id"
    t.index ["marca_id"], name: "index_historico_articulos_on_marca_id"
    t.index ["modelo_id"], name: "index_historico_articulos_on_modelo_id"
    t.index ["suplidor_id"], name: "index_historico_articulos_on_suplidor_id"
    t.index ["tipo_articulo_id"], name: "index_historico_articulos_on_tipo_articulo_id"
    t.index ["user_id"], name: "index_historico_articulos_on_user_id"
  end

  create_table "marcas", force: :cascade do |t|
    t.string "descripcion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "modelos", force: :cascade do |t|
    t.bigint "marca_id"
    t.string "descripcion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["marca_id"], name: "index_modelos_on_marca_id"
  end

  create_table "secuencia_facturas", force: :cascade do |t|
    t.bigint "tipo_factura_id"
    t.integer "secuencia"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tipo_factura_id"], name: "index_secuencia_facturas_on_tipo_factura_id"
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
    t.string "descripcion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tipo_facturas", force: :cascade do |t|
    t.string "referencia"
    t.string "descripcion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trabajos", force: :cascade do |t|
    t.bigint "cliente_id"
    t.string "tipo_trabajo"
    t.bigint "marca_id"
    t.bigint "modelo_id"
    t.string "identificador"
    t.boolean "tiene_bateria"
    t.string "descripcion"
    t.boolean "empezado"
    t.boolean "terminado"
    t.boolean "estado"
    t.datetime "fecha_cancelado"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cliente_id"], name: "index_trabajos_on_cliente_id"
    t.index ["marca_id"], name: "index_trabajos_on_marca_id"
    t.index ["modelo_id"], name: "index_trabajos_on_modelo_id"
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
    t.string "nombre"
    t.string "usuario"
    t.string "apellido"
    t.string "sexo"
    t.string "telefono"
    t.string "email"
    t.date "fecha_nacimiento"
    t.string "role"
    t.boolean "estado"
    t.json "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "articulos", "marcas"
  add_foreign_key "articulos", "modelos"
  add_foreign_key "articulos", "suplidores"
  add_foreign_key "articulos", "tipo_articulos"
  add_foreign_key "cabecera_facturas", "clientes"
  add_foreign_key "cabecera_facturas", "users"
  add_foreign_key "cabecera_recibos", "clientes"
  add_foreign_key "cabecera_recibos", "users"
  add_foreign_key "contenido_articulos", "articulos"
  add_foreign_key "detalle_facturas", "articulos"
  add_foreign_key "detalle_facturas", "cabecera_facturas"
  add_foreign_key "detalle_recibos", "cabecera_facturas"
  add_foreign_key "detalle_recibos", "cabecera_recibos"
  add_foreign_key "detalle_recibos", "trabajos"
  add_foreign_key "documentos_de_identidad", "clientes"
  add_foreign_key "documentos_de_identidad", "suplidores"
  add_foreign_key "documentos_de_identidad", "users"
  add_foreign_key "historico_articulos", "articulos"
  add_foreign_key "historico_articulos", "marcas"
  add_foreign_key "historico_articulos", "modelos"
  add_foreign_key "historico_articulos", "suplidores"
  add_foreign_key "historico_articulos", "tipo_articulos"
  add_foreign_key "historico_articulos", "users"
  add_foreign_key "modelos", "marcas"
  add_foreign_key "secuencia_facturas", "tipo_facturas"
  add_foreign_key "trabajos", "clientes"
  add_foreign_key "trabajos", "marcas"
  add_foreign_key "trabajos", "modelos"
end
