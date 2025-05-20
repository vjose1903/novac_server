G_usuarios =
[
  {
    'nombre': 'Tienda',
    'usuario': 'demo01',
    'uid': 'demo01',
    'apellido': '1',
    'sexo': 'i',
    'telefono': '(000) 000-0000',
    'email': 'demo@gmail.com',
    'fecha_nacimiento': '2022-01-01',
    'role': 'V',
    'password': '1234567',
    'password_confirmation': '1234567',
    'estado': true,
    'imagen_id': nil,
  },
  {
    'nombre': 'Persona',
    'usuario': 'ADMIN',
    'uid': 'ADMIN',
    'apellido': 'Demo',
    'sexo': 'm',
    'telefono': '(809) 879-0161',
    'email': 'inspot.technology@gmail.com',
    'fecha_nacimiento': '2022-04-01',
    'role': 'A',
    'password': '1234567',
    'password_confirmation': '1234567',
    'estado': true,
    'imagen_id': nil,
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
    'imagen_id': nil,
  },
]


G_clientes = [
  {
    'imagen_id': nil,
    'nombre': 'Cliente contado',
    'apellido': '.',
    'telefono': '(---) --------',
    'direccion': 'La Vega. R.D.',
    'sexo': 'i',
    'limite_credito': 0,
    'maximo_credito': 0,
    'vendedor_id':1
  },
]

G_documentos_de_identidad = [
  {
    'origen_type': 'User',
    'origen_entity': 'demo01',
    'descripcion': 'cedula',
    'documento': '000-0000000-0',
    'principal': true,
  },
  {
    'origen_type': 'User',
    'origen_entity': 'ADMIN',
    'descripcion': 'cedula',
    'documento': '000-0000000-1',
    'principal': true,
  },
  {
    'origen_type': 'User',
		'origen_entity': 'novac',
    'descripcion': 'cedula',
    'documento': '000-0000000-2',
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
  { 'descripcion': 'Tipo Demo 1', 'tipo': 'venta_normal', 'codigo': 'demo1' },
  { 'descripcion': 'Tipo Demo 2', 'tipo': 'servicio', 'codigo': 'demo2' },
]



CREATE_ACTION   = { nombre:'crear',       mostrar_front: true, descripcion: 'create',    metodo: 'create' }
READ_ALL_ACTION = { nombre:'ver todos',   mostrar_front: true, descripcion: 'read_all',  metodo: 'index'}
READ_ONE_ACTION = { nombre:'buscar uno',  mostrar_front: true, descripcion: 'read_one',  metodo: 'show'}
UPDATE_ACTION   = { nombre:'editar',      mostrar_front: true, descripcion: 'update',    metodo: 'update'}

ACCIONES_COMUNES = [ CREATE_ACTION, READ_ALL_ACTION, READ_ONE_ACTION, UPDATE_ACTION ]

ACCION_DESTROY = [{ nombre:'eliminar', mostrar_front: true, descripcion: 'destroy', metodo: 'destroy'}]


G_PERMISOS = [
  { nombre:'articulos',                      mostrar_front: true,     descripcion: 'articulo',                          controlador: 'Articulos',                      acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'ver inventario',mostrar_front: true, descripcion: 'get_stock', metodo: 'getStock'}, {nombre:'buscar filtrados',mostrar_front: true, descripcion: 'get_filtrados', metodo: 'getArticulosFiltrados'}, {nombre:'verificar si excede',mostrar_front: true, descripcion: 'check_excede',metodo: 'checkIfExcede'}, {nombre:'ver formulas',mostrar_front: true, descripcion: 'read_formula',metodo: nil}, {nombre:'editar formular',mostrar_front: true, descripcion: 'update_formula', metodo: nil} ]},
  { nombre:'conduces',                       mostrar_front: true,     descripcion: 'conduce',                           controlador: 'CabeceraConduces',               acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY ]},
  { nombre:'facturas venta',                 mostrar_front: true,     descripcion: 'factura_venta',                     controlador: 'CabeceraFacturas',               acciones: [*ACCIONES_COMUNES, {nombre:'buscar facturas por parametros',mostrar_front: true, descripcion: 'get_facturas_by_params', metodo: 'getFacturasByParams'}, {nombre:'comprobar serial',mostrar_front: true, descripcion: 'comprobar_serial', metodo: 'comprobarSerial'}, {nombre:'verificar si puede editar',mostrar_front: true, descripcion: 'verificate_can_update_id', metodo: 'verificateCanUpdateById'}, {nombre:'buscar viajes sin completar',mostrar_front: true, descripcion: 'get_viajes_sin_completar', metodo: 'getViajesSinCompletar'}, {nombre:'buscar facturas por cliente y estado',mostrar_front: true, descripcion: 'get_facturas_by_cliente_estado', metodo: 'getFacturasByClienteIdAndEstado'}, {nombre:'cancelar factura',mostrar_front: true, descripcion: 'cancelar_factura', metodo: 'cancelarFactura'}, {nombre:'seleccionar camion en facturacion',mostrar_front: true, descripcion: 'seleccionar_camion_en_facturacion', metodo: nil}]},
  { nombre:'facturas compra',                mostrar_front: true,     descripcion: 'factura_compra',                    controlador: 'CabeceraFacturas',               acciones: [*ACCIONES_COMUNES, {nombre:'buscar facturas por parametros',mostrar_front: true, descripcion: 'get_facturas_by_params', metodo: 'getFacturasByParams'}, {nombre:'comprobar serial',mostrar_front: true, descripcion: 'comprobar_serial', metodo: 'comprobarSerial'}, {nombre:'verificar si puede editar',mostrar_front: true, descripcion: 'verificate_can_update_id', metodo: 'verificateCanUpdateById'}, {nombre:'buscar facturas por suplidor y estado',mostrar_front: true, descripcion: 'get_facturas_by_suplidor_estado', metodo: 'getFacturasBySuplidorIdAndEstado'}, {nombre:'cancelar factura',mostrar_front: true, descripcion: 'cancelar_factura', metodo: 'cancelarFactura'}]},
  { nombre:'pre venta',                      mostrar_front: false,    descripcion: 'pre_venta',                         controlador: 'CabeceraFacturas',               acciones: [*ACCIONES_COMUNES, {nombre:'comprobar serial',mostrar_front: true, descripcion: 'comprobar_serial', metodo: 'comprobarSerial'}]},
  { nombre:'cotizaciones',                   mostrar_front: true,     descripcion: 'cotizacion',                        controlador: 'CabeceraFacturas',               acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY]},
  { nombre:'notas crédito',                  mostrar_front: true,     descripcion: 'nota_credito',                      controlador: 'Nota',                           acciones: [*ACCIONES_COMUNES, {nombre:'cancelar nota',mostrar_front: true, descripcion: 'cancelar_nota', metodo: 'cancelarNota'}, {nombre:'buscar filtrados',mostrar_front: true, descripcion: 'get_filtrados', metodo: 'getNotasFiltradas'}]},
  { nombre:'notas débito',                   mostrar_front: true,     descripcion: 'nota_debito',                       controlador: 'Nota',                           acciones: [*ACCIONES_COMUNES, {nombre:'cancelar nota',mostrar_front: true, descripcion: 'cancelar_nota', metodo: 'cancelarNota'}, {nombre:'buscar filtrados',mostrar_front: true, descripcion: 'get_filtrados', metodo: 'getNotasFiltradas'}]},
  { nombre:'facturas en notas',              mostrar_front: true,     descripcion: 'facturas_aplicadas',                controlador: 'FacturaAplicada',                acciones: [{nombre:'buscar cantidad devuelto',mostrar_front: true, descripcion: 'get_cantidad_devuelto', metodo: 'getCantidadDevuelto'}]},
  { nombre:'clientes',                       mostrar_front: true,     descripcion: 'cliente',                           controlador: 'Clientes',                       acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'buscar filtrados',mostrar_front: true, descripcion: 'get_filtrados', metodo: 'getClientesFiltrados'} ]},
  { nombre:'costos fletes',                  mostrar_front: true,     descripcion: 'costo_flete',                       controlador: 'CostoFletes',                    acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY ]},
  { nombre:'detalles factura',               mostrar_front: true,     descripcion: 'detalle_factura',                   controlador: 'DetalleFacturas',                acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY ]},
  { nombre:'historicos producciones',        mostrar_front: true,     descripcion: 'historico_produccion',              controlador: 'HistoricoProduccions',           acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY ]},
  { nombre:'imagenes',                       mostrar_front: true,     descripcion: 'imagen',                            controlador: 'Imagenes',                       acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY ]},
  { nombre:'cuadres caja',                   mostrar_front: true,     descripcion: 'cuadre_caja',                       controlador: 'CuadreCajas',                    acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'verificar cuadre del dia',mostrar_front: true, descripcion: 'check_today_cuadre', metodo: 'checkTodayCuadre'} ]},
  { nombre:'mantenimientos articulos',       mostrar_front: true,     descripcion: 'mantenimiento_articulo',            controlador: 'MantenimientoArticulos',         acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'buscar articulo por fecha',mostrar_front: true, descripcion: 'get_one_articulo_date', metodo: 'getOneArticuloByDate'} ]},
  { nombre:'marcas',                         mostrar_front: true,     descripcion: 'marca',                             controlador: 'Marcas',                         acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'buscar filtrados',mostrar_front: true, descripcion: 'get_filtrados', metodo: 'getMarcasFiltradas'} ]},
  { nombre:'modelos',                        mostrar_front: true,     descripcion: 'modelo',                            controlador: 'Modelos',                        acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'ver modelos por marca',mostrar_front: true, descripcion: 'get_modelos_by_marca', metodo: 'getModelosPorMarca'}, {nombre:'buscar filtrados',mostrar_front: true, descripcion: 'get_filtrados', metodo: 'getModelosFiltrados'} ]},
  { nombre:'movimientos de inventarios',     mostrar_front: true,     descripcion: 'movimiento_inventario',             controlador: 'MovimientosInventarios',         acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY ]},
  { nombre:'municipios',                     mostrar_front: true,     descripcion: 'municipio',                         controlador: 'Municipios',                     acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY]},
  { nombre:'producciones',                   mostrar_front: true,     descripcion: 'produccion',                        controlador: 'Producciones',                   acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'buscar filtrados',mostrar_front: true, descripcion: 'get_filtrados', metodo: 'getProduccionesFiltradas'} ]},
  { nombre:'provincias',                     mostrar_front: true,     descripcion: 'provincia',                         controlador: 'Provincias',                     acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY ]},
  { nombre:'recibos ingreso',                mostrar_front: true,     descripcion: 'recibo_ingreso',                    controlador: 'RecibosIngresos',                acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'buscar filtrados',mostrar_front: true, descripcion: 'get_filtrados', metodo: 'getRecibosFiltrados'}, {nombre:'revertir recibo',mostrar_front: true, descripcion: 'revertir_recibo', metodo: 'revertirRecibos'} ]},
  { nombre:'reportes',                       mostrar_front: true,     descripcion: 'reporte',                           controlador: 'Reportes',                       acciones: [{nombre:'ver reportes', mostrar_front: true, descripcion: 'get_reportes', metodo: 'getReportes'} ]},
  { nombre:'comprobantes fiscales',          mostrar_front: true,     descripcion: 'secuencia_comprobante',             controlador: 'SecuenciaComprobantes',          acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'buscar filtrados',mostrar_front: true, descripcion: 'get_filtrados', metodo: 'getSecuenciaComprobantesFiltrados'}, {nombre:'buscar comprobanrte por estado',mostrar_front: true, descripcion: 'get_paquete_rnc_estado', metodo: 'getPaqueteRncByEstado'} ]},
  { nombre:'suplidores',                     mostrar_front: true,     descripcion: 'suplidor',                          controlador: 'Suplidores',                     acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'buscar nombres de suplidores',mostrar_front: true, descripcion: 'get_nombres_suplidores', metodo: 'getNombresSuplidores'}, {nombre:'buscar filtrados',mostrar_front: true, descripcion: 'get_filtrados', metodo: 'getSuplidoresFiltrados'} ]},
  { nombre:'tipos articulos',                mostrar_front: true,     descripcion: 'tipo_articulo',                     controlador: 'TipoArticulos',                  acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY ]},
  { nombre:'tipos facturas',                 mostrar_front: true,     descripcion: 'tipo_factura',                      controlador: 'TipoFacturas',                   acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY ]},
  { nombre:'tipos recibos',                  mostrar_front: true,     descripcion: 'tipo_recibo',                       controlador: 'TipoRecibos',                    acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY ]},
  { nombre:'empleados',                      mostrar_front: true,     descripcion: 'user',                              controlador: 'Users',                          acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'buscar filtrados',mostrar_front: true, descripcion: 'get_filtrados', metodo: 'getUsuariosFiltrados'} ]},
  { nombre:'vehiculos',                      mostrar_front: true,     descripcion: 'vehiculo',                          controlador: 'Vehiculos',                      acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'buscar filtrados',mostrar_front: true, descripcion: 'get_filtrados', metodo: 'getVehiculosFiltrados'}  ]},
  { nombre:'sesion de usuario',              mostrar_front: true,     descripcion: 'device',                            controlador: 'devise_token_auth/sessions',     acciones: [{nombre:'iniciar sesión', mostrar_front: true, descripcion: 'login', metodo: 'create'}]},
  { nombre:'roles',                          mostrar_front: true,     descripcion: 'role',                              controlador: 'Roles',                          acciones: [*ACCIONES_COMUNES, *ACCION_DESTROY, {nombre:'buscar filtrados',mostrar_front: true, descripcion: 'get_filtrados', metodo: 'getRolesFiltrados'}]},
  { nombre: 'Recepcion Ecf',                 mostrar_front: true,     descripcion: 'ecf_reception',                     controlador: 'EcfReception',                   acciones: [READ_ALL_ACTION, READ_ONE_ACTION, { nombre: 'Responder recibo de factura', mostrar_front: true, descripcion: 'response_receive', metodo: 'approveDenyEcf'}]},
  { nombre: 'Aprobaciónes comerciales',      mostrar_front: true,     descripcion: 'commertial_approval_reception',     controlador: 'CommertialApprovalReception',    acciones: [READ_ALL_ACTION, READ_ONE_ACTION]}
]

G_ROLES_CUSTOM = [
  {  nombre: "Vendedor", key:'vendedor', descripcion: "Persona encargada de captar clientes para la empresa.", ruta_defecto:"/", estado: true, permisos_acciones: []}
]

G_CONFIG_ARTICULOS = [
  { porciento_ganancia: 10 }
]