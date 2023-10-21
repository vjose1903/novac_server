G_usuarios =
[
  {
    'nombre': 'AGRODEMI',
    'usuario': 'adm01',
    'uid': 'adm01',
    'apellido': '01',
    'sexo': 'i',
    'telefono': '(809) 573-0060',
    'email': 'adm@gmail.com',
    'fecha_nacimiento': '2022-01-01',
    'role': 'V',
    'password': '1234567',
    'password_confirmation': '1234567',
    'estado': true,
  },
  {
    'nombre': 'Administrador',
    'usuario': 'ADMIN',
    'uid': 'ADMIN',
    'apellido': 'sistema',
    'sexo': 'f',
    'telefono': '(829) 292-8772',
    'email': 'admin@hotmail.com',
    'fecha_nacimiento': '2022-01-01',
    'role': 'A',
    'password': '1234567',
    'password_confirmation': '1234567',
    'estado': true,
  },
  {
    'nombre': 'Novac',
    'usuario': 'novac',
    'uid': 'novac',
    'apellido': 'system',
    'sexo': 'i',
    'telefono': '(000) 000-0000',
    'email': 'novacagrodemi@gmail.com',
    'fecha_nacimiento': '1998-03-19',
    'role': 'A',
    'password': '1234567',
    'password_confirmation': '1234567',
    'estado': true,
  },
]


G_clientes = [
  {
    'nombre': 'Cliente contado',
    'apellido': '.',
    'telefono': '(---) --------',
    'direccion': 'Autopista duarte KM 0 el Higuero',
    'sexo': 'i',
    'limite_credito': 0,
    'maximo_credito': 0,
    'vendedor_id':1
  },
]

G_documentos_de_identidad = [
  {
    'origen_type': 'User',
    'origen_entity': 'adm01',
    'descripcion': 'cedula',
    'documento': '047-0099635-0',
    'principal': true,
  },
  {
    'origen_type': 'User',
    'origen_entity': 'ADMIN',
    'descripcion': 'cedula',
    'documento': '047-0099635-0',
    'principal': true,
  },
  {
    'origen_type': 'User',
    'origen_entity': 'novac',
    'descripcion': 'cedula',
    'documento': '000-0000000-1',
    'principal': true,
  },
  {
    'origen_type': 'Cliente',
    'origen_entity': 'Cliente contado',
    'descripcion': 'cedula',
    'documento': ' ',
    'principal': true,
  },
]


G_tipos_articulo = [
  { 'descripcion': 'Materia prima',       'tipo': 'venta_normal', 'codigo': 'materia_prima' },
  { 'descripcion': 'Veterinaria',         'tipo': 'venta_normal', 'codigo': 'veterinaria' },
  { 'descripcion': 'Producto terminado',  'tipo': 'venta_normal', 'codigo': 'producto_terminado' },
  { 'descripcion': 'Nucleo',              'tipo': 'venta_normal', 'codigo': 'nucleo' },
  { 'descripcion': 'Otros',               'tipo': 'venta_normal', 'codigo': 'otros' },
]


ACCIONES_COMUNES = [
  {nombre:'crear',       mostrar_front: true, descripcion: 'create',    metodo: 'create'},
  {nombre:'ver todos',   mostrar_front: true, descripcion: 'read_all',  metodo: 'index'},
  {nombre:'buscar uno',  mostrar_front: true, descripcion: 'read_one',  metodo: 'show'},
  {nombre:'editar',      mostrar_front: true, descripcion: 'update',    metodo: 'update'},
]

ACCION_DESTROY = [{ nombre:'eliminar', mostrar_front: true, descripcion: 'destroy', metodo: 'destroy'}]


G_PERMISOS = [
  { nombre:'articulos',                             mostrar_front: true,     descripcion: 'articulo',                         controlador: 'Articulos',                      acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'ver inventario',mostrar_front: true, descripcion: 'get_stock', metodo: 'getStock'}, {nombre:'buscar filtrados',mostrar_front: true, descripcion: 'get_filtrados', metodo: 'getArticulosFiltrados'}, {nombre:'verificar si excede',mostrar_front: true, descripcion: 'check_excede',metodo: 'checkIfExcede'}, {nombre:'ver formulas',mostrar_front: true, descripcion: 'read_formula',metodo: nil}, {nombre:'editar formular',mostrar_front: true, descripcion: 'update_formula', metodo: nil} ]},
  { nombre:'conduces',                              mostrar_front: true,     descripcion: 'conduce',                          controlador: 'CabeceraConduces',               acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY ]},
  { nombre:'facturas venta',                        mostrar_front: true,     descripcion: 'factura_venta',                    controlador: 'CabeceraFacturas',               acciones: [ *ACCIONES_COMUNES, {nombre:'buscar facturas por parametros',mostrar_front: true, descripcion: 'get_facturas_by_params', metodo: 'getFacturasByParams'}, {nombre:'comprobar serial',mostrar_front: true, descripcion: 'comprobar_serial', metodo: 'comprobarSerial'}, {nombre:'verificar si puede editar',mostrar_front: true, descripcion: 'verificate_can_update_id', metodo: 'verificateCanUpdateById'}, {nombre:'buscar viajes sin completar',mostrar_front: true, descripcion: 'get_viajes_sin_completar', metodo: 'getViajesSinCompletar'}, {nombre:'buscar facturas por cliente y estado',mostrar_front: true, descripcion: 'get_facturas_by_cliente_estado', metodo: 'getFacturasByClienteIdAndEstado'}, {nombre:'cancelar factura',mostrar_front: true, descripcion: 'cancelar_factura', metodo: 'cancelarFactura'}, {nombre:'seleccionar camion en facturacion',mostrar_front: true, descripcion: 'seleccionar_camion_en_facturacion', metodo: nil}]},
  { nombre:'facturas compra',                       mostrar_front: true,     descripcion: 'factura_compra',                   controlador: 'CabeceraFacturas',               acciones: [ *ACCIONES_COMUNES, {nombre:'buscar facturas por parametros',mostrar_front: true, descripcion: 'get_facturas_by_params', metodo: 'getFacturasByParams'}, {nombre:'comprobar serial',mostrar_front: true, descripcion: 'comprobar_serial', metodo: 'comprobarSerial'}, {nombre:'verificar si puede editar',mostrar_front: true, descripcion: 'verificate_can_update_id', metodo: 'verificateCanUpdateById'}, {nombre:'buscar facturas por suplidor y estado',mostrar_front: true, descripcion: 'get_facturas_by_suplidor_estado', metodo: 'getFacturasBySuplidorIdAndEstado'}, {nombre:'cancelar factura',mostrar_front: true, descripcion: 'cancelar_factura', metodo: 'cancelarFactura'}]},
  { nombre:'pre venta',                             mostrar_front: false,    descripcion: 'pre_venta',                        controlador: 'CabeceraFacturas',               acciones: [ *ACCIONES_COMUNES, {nombre:'comprobar serial',mostrar_front: true, descripcion: 'comprobar_serial', metodo: 'comprobarSerial'}]},
  { nombre:'cotizaciones',                          mostrar_front: true,     descripcion: 'cotizacion',                       controlador: 'CabeceraFacturas',               acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY]},
  { nombre:'notas crédito',                         mostrar_front: true,     descripcion: 'nota_credito',                     controlador: 'Nota',                           acciones: [ *ACCIONES_COMUNES, {nombre:'cancelar nota',mostrar_front: true, descripcion: 'cancelar_nota', metodo: 'cancelarNota'}, {nombre:'buscar filtrados',mostrar_front: true, descripcion: 'get_filtrados', metodo: 'getNotasFiltradas'}]},
  { nombre:'notas débito',                          mostrar_front: true,     descripcion: 'nota_debito',                      controlador: 'Nota',                           acciones: [ *ACCIONES_COMUNES, {nombre:'cancelar nota',mostrar_front: true, descripcion: 'cancelar_nota', metodo: 'cancelarNota'}, {nombre:'buscar filtrados',mostrar_front: true, descripcion: 'get_filtrados', metodo: 'getNotasFiltradas'}]},
  { nombre:'facturas en notas',                     mostrar_front: true,     descripcion: 'facturas_aplicadas',               controlador: 'FacturaAplicada',                acciones: [ {nombre:'buscar cantidad devuelto',mostrar_front: true, descripcion: 'get_cantidad_devuelto', metodo: 'getCantidadDevuelto'}]},
  { nombre:'clientes',                              mostrar_front: true,     descripcion: 'cliente',                          controlador: 'Clientes',                       acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'buscar filtrados',mostrar_front: true, descripcion: 'get_filtrados', metodo: 'getClientesFiltrados'}, {nombre:'obtener balance pendiente',mostrar_front: true, descripcion: 'get_balances', metodo: 'getBalances'} ]},
  { nombre:'costos fletes',                         mostrar_front: true,     descripcion: 'costo_flete',                      controlador: 'CostoFletes',                    acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY ]},
  { nombre:'detalles factura',                      mostrar_front: true,     descripcion: 'detalle_factura',                  controlador: 'DetalleFacturas',                acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY ]},
  { nombre:'historicos producciones',               mostrar_front: true,     descripcion: 'historico_produccion',             controlador: 'HistoricoProduccions',           acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY ]},
  { nombre:'imagenes',                              mostrar_front: true,     descripcion: 'imagen',                           controlador: 'Imagenes',                       acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY ]},
  { nombre:'cuadres caja',                          mostrar_front: true,     descripcion: 'cuadre_caja',                      controlador: 'CuadreCajas',                    acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'verificar cuadre del dia',mostrar_front: true, descripcion: 'check_today_cuadre', metodo: 'checkTodayCuadre'} ]},
  { nombre:'mantenimientos articulos',              mostrar_front: true,     descripcion: 'mantenimiento_articulo',           controlador: 'MantenimientoArticulos',         acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'buscar articulo por fecha',mostrar_front: true, descripcion: 'get_one_articulo_date', metodo: 'getOneArticuloByDate'} ]},
  { nombre:'marcas',                                mostrar_front: true,     descripcion: 'marca',                            controlador: 'Marcas',                         acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'buscar filtrados',mostrar_front: true, descripcion: 'get_filtrados', metodo: 'getMarcasFiltradas'} ]},
  { nombre:'modelos',                               mostrar_front: true,     descripcion: 'modelo',                           controlador: 'Modelos',                        acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'ver modelos por marca',mostrar_front: true, descripcion: 'get_modelos_by_marca', metodo: 'getModelosPorMarca'}, {nombre:'buscar filtrados',mostrar_front: true, descripcion: 'get_filtrados', metodo: 'getModelosFiltrados'} ]},
  { nombre:'movimientos de inventarios',            mostrar_front: true,     descripcion: 'movimiento_inventario',            controlador: 'MovimientosInventarios',         acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY ]},
  { nombre:'municipios',                            mostrar_front: true,     descripcion: 'municipio',                        controlador: 'Municipios',                     acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY]},
  { nombre:'producciones',                          mostrar_front: true,     descripcion: 'produccion',                       controlador: 'Producciones',                   acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'buscar filtrados',mostrar_front: true, descripcion: 'get_filtrados', metodo: 'getProduccionesFiltradas'} ]},
  { nombre:'provincias',                            mostrar_front: true,     descripcion: 'provincia',                        controlador: 'Provincias',                     acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY ]},
  { nombre:'recibos ingreso',                       mostrar_front: true,     descripcion: 'recibo_ingreso',                   controlador: 'RecibosIngresos',                acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'buscar filtrados',mostrar_front: true, descripcion: 'get_filtrados', metodo: 'getRecibosFiltrados'}, {nombre:'revertir recibo',mostrar_front: true, descripcion: 'revertir_recibo', metodo: 'revertirRecibos'} ]},
  { nombre:'pago facturas compra',                  mostrar_front: true,     descripcion: 'pagos_compras',                    controlador: 'PagoFactura',                    acciones: [ *ACCIONES_COMUNES, {nombre:'buscar filtrados',mostrar_front: true, descripcion: 'get_filtrados', metodo: 'getPagosFiltrados'}, {nombre:'revertir pago', mostrar_front: true, descripcion: 'revertir_pago', metodo: 'revertirPagos'} ]},
  { nombre:'reportes',                              mostrar_front: true,     descripcion: 'reporte',                          controlador: 'Reportes',                       acciones: [ {nombre:'cuadre de caja', mostrar_front: true, descripcion: 'cuadre', metodo: 'getReportes'} , {nombre:'ventas diarias', mostrar_front: true, descripcion: 'ventas_diarias', metodo: 'getReportes'} , {nombre:'ventas en rango', mostrar_front: true, descripcion: 'ventas_rango', metodo: 'getReportes'} , {nombre:'ventas de productos', mostrar_front: true, descripcion: 'ventas_productos', metodo: 'getReportes'} , {nombre:'cuentas con pagos', mostrar_front: true, descripcion: 'cuentas_con_pagos', metodo: 'getReportes'} , {nombre:'ventas por cliente', mostrar_front: true, descripcion: 'ventas_cliente', metodo: 'getReportes'} , {nombre:'movimientos de vehiculo', mostrar_front: true, descripcion: 'movimientos_vehiculo', metodo: 'getReportes'} , {nombre:'inventario', mostrar_front: true, descripcion: 'inventario', metodo: 'getReportes'} , {nombre:'suplidor por producto', mostrar_front: true, descripcion: 'suplidor_prod', metodo: 'getReportes'} , {nombre:'cuentas cobrar cliente', mostrar_front: true, descripcion: 'cuentas_cobrar_cliente', metodo: 'getReportes'} , {nombre:'cuentas cobrar con antiguedad de saldo', mostrar_front: true, descripcion: 'cuentas_cobrar_ant_saldo', metodo: 'getReportes'} , {nombre:'recibos', mostrar_front: true, descripcion: 'recibos', metodo: 'getReportes'} , {nombre:'notas', mostrar_front: true, descripcion: 'notas', metodo: 'getReportes'}]},
  { nombre:'comprobantes fiscales',                 mostrar_front: true,     descripcion: 'secuencia_comprobante',            controlador: 'SecuenciaComprobantes',          acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'buscar filtrados',mostrar_front: true, descripcion: 'get_filtrados', metodo: 'getSecuenciaComprobantesFiltrados'}, {nombre:'buscar comprobanrte por estado',mostrar_front: true, descripcion: 'get_paquete_rnc_estado', metodo: 'getPaqueteRncByEstado'} ]},
  { nombre:'suplidores',                            mostrar_front: true,     descripcion: 'suplidor',                         controlador: 'Suplidores',                     acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'buscar nombres de suplidores',mostrar_front: true, descripcion: 'get_nombres_suplidores', metodo: 'getNombresSuplidores'}, {nombre:'buscar filtrados',mostrar_front: true, descripcion: 'get_filtrados', metodo: 'getSuplidoresFiltrados'}, {nombre:'obtener balance pendiente',mostrar_front: true, descripcion: 'get_balances', metodo: 'getBalances'}  ]},
  { nombre:'tipos articulos',                       mostrar_front: true,     descripcion: 'tipo_articulo',                    controlador: 'TipoArticulos',                  acciones: [ *ACCIONES_COMUNES ]},
  { nombre:'sub tipos articulos',                   mostrar_front: true,     descripcion: 'sub_tipo_articulo',                controlador: 'SubTipoArticulo',                acciones: [ *ACCIONES_COMUNES ]},
  { nombre:'tipos facturas',                        mostrar_front: true,     descripcion: 'tipo_factura',                     controlador: 'TipoFacturas',                   acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY ]},
  { nombre:'tipos recibos',                         mostrar_front: true,     descripcion: 'tipo_recibo',                      controlador: 'TipoRecibos',                    acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY ]},
  { nombre:'empleados',                             mostrar_front: true,     descripcion: 'user',                             controlador: 'Users',                          acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'buscar filtrados', mostrar_front: true, descripcion: 'get_filtrados', metodo: 'getUsuariosFiltrados'} ]},
  { nombre:'vehiculos',                             mostrar_front: true,     descripcion: 'vehiculo',                         controlador: 'Vehiculos',                      acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'buscar filtrados', mostrar_front: true, descripcion: 'get_filtrados', metodo: 'getVehiculosFiltrados'}  ]},
  { nombre:'sesion de usuario',                     mostrar_front: true,     descripcion: 'device',                           controlador: 'devise_token_auth/sessions',     acciones: [ {nombre:'iniciar sesión', mostrar_front: true, descripcion: 'login', metodo: 'create'}]},
  { nombre:'roles',                                 mostrar_front: true,     descripcion: 'role',                             controlador: 'Roles',                          acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'buscar filtrados', mostrar_front: true, descripcion: 'get_filtrados', metodo: 'getRolesFiltrados'}]},

  { nombre:'periodo fiscal',                        mostrar_front: true,     descripcion: 'periodo_fiscal',                   controlador: 'PeriodoFiscal',                  acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY, { nombre:'abrir nuevo periodo', mostrar_front: true, descripcion: 'open_new_periodo', metodo: 'openNewPeriodo' }]},
  { nombre:'grupos de cuentas contables',           mostrar_front: true,     descripcion: 'grupo_cuenta',                     controlador: 'GrupoCuenta',                    acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY ]},
  { nombre:'cuentas contables',                     mostrar_front: true,     descripcion: 'cuenta_contable',                  controlador: 'CuentaContable',                 acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY ]},
  { nombre:'cuentas contables',                     mostrar_front: true,     descripcion: 'cuenta_contable',                  controlador: 'CuentaContable',                 acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY ]},
  { nombre:'cierre de cuentas contables',           mostrar_front: true,     descripcion: 'cierre_cuenta',                    controlador: 'CierreCuenta',                   acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY ]},
  { nombre:'configuracion cuentas contables',       mostrar_front: true,     descripcion: 'configuracion_entidad_cuenta',     controlador: 'ConfiguracionEntidadCuenta',     acciones: [ {nombre:'ver todos', mostrar_front: true, descripcion: 'read_all', metodo: 'index'}, {nombre:'buscar uno', mostrar_front: true, descripcion: 'read_one', metodo: 'show'}, {nombre:'editar', mostrar_front: true, descripcion: 'update', metodo: 'update'}, ]},
  { nombre:'divisa',                                mostrar_front: true,     descripcion: 'divisa',                           controlador: 'Divisa',                         acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY ]},
  { nombre:'tasa de cambio',                        mostrar_front: true,     descripcion: 'tasa_cambio',                      controlador: 'TasaCambio',                     acciones: [ {nombre:'ver todos', mostrar_front: true, descripcion: 'read_all', metodo: 'index'}, {nombre:'buscar uno', mostrar_front: true, descripcion: 'read_one', metodo: 'show'}, {nombre:'editar', mostrar_front: true, descripcion: 'update', metodo: 'update'}, {nombre:'obtener historicos de tasas de cambio', mostrar_front: true, descripcion: 'get_history_changes', metodo: 'getHistoryChanges'} ]},
  { nombre:'tipo de cuenta bancaria',               mostrar_front: true,     descripcion: 'tipo_cuenta_bancaria',             controlador: 'TipoCuentaBancaria',             acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY ]},
  { nombre:'banco',                                 mostrar_front: true,     descripcion: 'banco',                            controlador: 'Banco',                          acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY ]},
  { nombre:'cuenta_bancaria',                       mostrar_front: true,     descripcion: 'cuenta_bancaria',                  controlador: 'CuentaBancaria',                 acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY ]},
  { nombre:'asiento contable',                      mostrar_front: true,     descripcion: 'cabeza_asiento_contable',          controlador: 'CabezaAsientoContable',          acciones: [ *ACCIONES_COMUNES, *ACCION_DESTROY ]},
  { nombre:'categoria de entidad contable',         mostrar_front: true,     descripcion: 'categoria_entidad_contable',       controlador: 'CategoriaEntidadContable',       acciones: [ *ACCIONES_COMUNES ]},
  { nombre:'entidad cuenta contable',               mostrar_front: true,     descripcion: 'entidad_cuenta_contable',          controlador: 'EntidadCuentaContable',          acciones: [ *ACCIONES_COMUNES ]},
  { nombre:'deposito',                              mostrar_front: true,     descripcion: 'deposito',                         controlador: 'Deposito',                       acciones: [ *ACCIONES_COMUNES, {nombre:'anular deposito', mostrar_front: true, descripcion: 'anular_deposito', metodo: 'anularDeposito'} ]},
  { nombre:'transferencia',                         mostrar_front: true,     descripcion: 'transferencia',                    controlador: 'Transferencia',                  acciones: [ *ACCIONES_COMUNES, {nombre:'anular transferencia', mostrar_front: true, descripcion: 'anular_transferencia', metodo: 'anularTransferencia'} ]},
]

# ejemplo de permisos_acciones
# {permiso_descripcion:'algo', acciones:['descripcion', 'descripcion2']}
G_ROLES_CUSTOM = [
  {  nombre: 'Chofer', key: 'chofer', descripcion: 'Persona encargada de realizar los viajes de pedidos a los clientes.', ruta_defecto:'/', estado: true, permisos_acciones: []},
  {  nombre: "Vendedor", key:'vendedor', descripcion: "Persona encargada de captar clientes para la empresa.", ruta_defecto:"/", estado: true, permisos_acciones: []}
]

G_CONFIG_ARTICULOS = [
  { porciento_ganancia: 15}
]

G_DIVISA_DEFAULT = [
  { nombre: 'Peso Dominicano',      simbolo: 'RD$', is_principal: true,  estado: true, current_tasa: 1,  predeterminado: true, imagenes: { file_name: 'peso_dominicano', base_64: G_IMG_PESO } },
  { nombre: 'Dolar Estadounidense', simbolo: 'US$', is_principal: false, estado: true, current_tasa: 56, predeterminado: true, imagenes: { file_name: 'dolar_estadounidense', base_64: G_IMG_DOLAR } },
]

G_HAS_CONTABILIDAD = true

