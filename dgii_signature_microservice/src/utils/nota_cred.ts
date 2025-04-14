import { tipoComprobanteE } from '@core/constants/factura.utils';
import { NotaI } from '../core/types/notas.types';
import { factura_32 } from './factura_32';

export const nota_credito: NotaI = {
  cliente_id: 3,
  user_id: null,
  fecha_valida: '30/12/2022',
  numero_comprobante: 'E340000000001',
  tipo_factura_id: 5,
  total: 40000,
  TipoeCF: tipoComprobanteE.nota_de_credito,
  facturas_aplicadas: [
    {
      cabecera_factura_id: 53501,
      total: 40000,
      factura: factura_32,
      detalles_facturas_notas: [
        // { 
        //   articulo_id: 984, 
        //   unidad: 'Saco', 
        //   itbis: 0, 
        //   itbis_real: 0, 
        //   costo: 810, 
        //   precio: 860, 
        //   precio_real: 860, 
        //   total: 21500, 
        //   cantidad_en_unidades: 2500, 
        //   cantidad: 25, 
        //   detalle_factura_id: 150273, 
        //   descuento: 0, 
        //   descuento_real: 0 
        // },
        // { 
        //   articulo_id: 166, 
        //   unidad: 'Saco', 
        //   itbis: 0, 
        //   itbis_real: 0, 
        //   costo: 585, 
        //   precio: 690, 
        //   precio_real: 600, 
        //   total: 4500, 
        //   cantidad_en_unidades: 0, 
        //   cantidad: 0, 
        //   detalle_factura_id: 150274, 
        //   descuento: 500, 
        //   descuento_real: 0 
        // },
        // { 
        //   articulo_id: 208, 
        //   unidad: 'Saco', 
        //   itbis: 0, 
        //   itbis_real: 0, 
        //   costo: 1400, 
        //   precio: 1450, 
        //   precio_real: 1450, 
        //   total: 14000, 
        //   cantidad_en_unidades: 1000, 
        //   cantidad: 10, 
        //   detalle_factura_id: 150275, 
        //   descuento: 2500, 
        //   descuento_real: 0 
        // },
      ],
    },
  ],
};
