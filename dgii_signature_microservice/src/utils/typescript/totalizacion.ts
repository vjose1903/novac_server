import { DetalleFacturaI, FacturaI } from '../../core/types/factura.types';
import { EcfXmlJson } from '../../core/types/xml/xml_json';
import { isEmpty } from './functions';

export class Totalizacion {
  constructor() {}

  run(articulos: DetalleFacturaI[]) {
    const totales = {
        MontoGravadoTotal: null,
        MontoGravadoI1: null,
        MontoGravadoI3: null,
        MontoExento: null,
        ITBIS1: null,
        ITBIS3: null,
        TotalITBIS: null,
        TotalITBIS1: null,
        TotalITBIS3: null,
        MontoTotal: null,
        ValorPagar: null,
      };
  
      const items_itbis = articulos.filter(prod => prod.articulo.calcular_itbis);
      const items_no_itbis = articulos.filter(prod => !prod.articulo.calcular_itbis);
  
      if (items_itbis.length > 0) {
        totales.MontoGravadoI1 = items_itbis.reduce((acc, item) => acc + (item.precio * item.cantidad - item.descuento_valor), 0);
  
        totales.ITBIS1 = 18;
        totales.TotalITBIS1 = totales.MontoGravadoI1 * 0.18;
      }
  
      if (items_no_itbis.length > 0) {
        totales.MontoGravadoI3 = items_no_itbis.reduce((acc, item) => acc + (item.precio * item.cantidad - item.descuento_valor), 0);
  
        totales.ITBIS3 = 0;
        totales.TotalITBIS3 = totales.MontoGravadoI3 * 0;
      }
  
      totales.MontoGravadoTotal = totales.MontoGravadoI1 + totales.MontoGravadoI3;
      totales.TotalITBIS = totales.TotalITBIS1 + totales.TotalITBIS3;
  
      totales.MontoTotal = totales.MontoGravadoTotal || 0 + totales.TotalITBIS || 0;
      totales.ValorPagar = totales.MontoTotal;
  
      return totales;
  }
}
