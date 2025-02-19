import { DetalleFacturaI, FacturaI } from '../../core/types/factura.types';
import { EcfXmlJson } from '../../core/types/xml/xml_json';
import { isEmpty } from './functions';

export class Totalizacion {
  constructor() {}

  run(articulos: DetalleFacturaI[]) {
    const totales = {
      MontoGravadoTotal: null,
      MontoGravadoI1: null,
      MontoExento: null,
      ITBIS1: null,
      TotalITBIS: null,
      TotalITBIS1: null,
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
      totales.MontoExento = items_no_itbis.reduce((acc, item) => acc + (item.precio * item.cantidad - item.descuento_valor), 0);
    }

    if (totales.MontoGravadoI1) totales.MontoGravadoTotal = totales.MontoGravadoI1;
    totales.TotalITBIS = totales.TotalITBIS1;

    totales.MontoTotal = (totales.MontoGravadoTotal || 0) + (totales.MontoExento || 0) + (totales.TotalITBIS || 0);
    // totales.ValorPagar = totales.MontoTotal;

    return totales;
  }
}
