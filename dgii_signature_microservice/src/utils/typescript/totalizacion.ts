import { DetalleFacturaI, FacturaI } from '@core/types/factura.types';
import { DetallesFacturasNota, NotaI } from '@core/types/notas.types';
import { TotalI } from '@core/types/xml/xml_json';
import Big from 'big.js';
import { redondearNum } from './functions';

export class Totalizacion {
  constructor() {}

  run(articulos: DetalleFacturaI[] | DetallesFacturasNota[], isFactura: boolean) {
    const totales: TotalI = {
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

    if (isFactura) {
      this.evaluateFactura(items_itbis as DetalleFacturaI[], items_no_itbis as DetalleFacturaI[], totales);
    } else {
      this.evaluateNota(items_itbis as DetallesFacturasNota[], items_no_itbis as DetallesFacturasNota[], totales);
    }

    if (totales.MontoGravadoI1) totales.MontoGravadoTotal = totales.MontoGravadoI1;
    totales.TotalITBIS = totales.TotalITBIS1;

    totales.MontoTotal = Number(redondearNum((totales.MontoGravadoTotal || 0) + (totales.MontoExento || 0) + (totales.TotalITBIS || 0)));
    // totales.ValorPagar = totales.MontoTotal;

    return totales;
  }

  evaluateFactura(items_itbis: DetalleFacturaI[], items_no_itbis: DetalleFacturaI[], totales: TotalI) {

    if (items_itbis.length > 0) {
      totales.MontoGravadoI1 = items_itbis.reduce((acc, item) => acc + (item.precio * item.cantidad - item.descuento_valor), 0);

      totales.ITBIS1 = 18;
      totales.TotalITBIS1 = totales.MontoGravadoI1 * 0.18;
    }

    if (items_no_itbis.length > 0) {
      totales.MontoExento = items_no_itbis.reduce((acc, item) => acc + (item.precio * item.cantidad - item.descuento_valor), 0);
    }
  }

  evaluateNota(items_itbis: DetallesFacturasNota[], items_no_itbis: DetallesFacturasNota[], totales: TotalI) {
    const calc_total_row = (item: DetallesFacturasNota) => {
      const isPriceChange = item.cantidad == 0;

      if (isPriceChange) {
        return item.precio_real * item.cantidad_origin - item.descuento;
      }

      const descuento_big = Big(item.descuento);
      const descuento_equivalente = descuento_big.div(item.cantidad_origin).toNumber();

      return (item.precio - descuento_equivalente) * item.cantidad;
    };

    if (items_itbis.length > 0) {
      totales.MontoGravadoI1 = items_itbis.reduce((acc, item) => acc + calc_total_row(item), 0);

      totales.ITBIS1 = 18;
      totales.TotalITBIS1 = totales.MontoGravadoI1 * 0.18;
    }

    if (items_no_itbis.length > 0) {
      totales.MontoExento = items_no_itbis.reduce((acc, item) => acc + calc_total_row(item), 0);
    }
  }
}
