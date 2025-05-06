import { indicadorBienoServicioE, indicadorFacturacionE, unidad_codeE } from '@core/constants/factura.const';
import { DetalleFacturaI } from '@core/types/factura.types';
import { DetallesFacturasNota } from '@core/types/notas.types';
import { CodigosItem, ItemI } from '@core/types/xml/xml_detallesItem_json';
import { getProperty, redondearNum } from './functions';
import Big from 'big.js';

export class Detalles {
  constructor() {}

  parse(detalles: DetalleFacturaI[] | DetallesFacturasNota[], isFactura: boolean) {
    const detallesItems = { Item: [] };

    detalles.forEach((item: DetalleFacturaI | DetallesFacturasNota, index: number) => {
      const itemParsed = {} as ItemI;
      itemParsed.NumeroLinea = `${index + 1}`;

      itemParsed.TablaCodigosItem = { CodigosItem: [] };
      const codigo: CodigosItem = { TipoCodigo: 'Interna', CodigoItem: item.codigo };
      itemParsed.TablaCodigosItem.CodigosItem.push(codigo);

      // TODO: revisar
      itemParsed.IndicadorFacturacion = item.articulo.calcular_itbis ? indicadorFacturacionE.itbis_18 : indicadorFacturacionE.excento;

      itemParsed.NombreItem = item.descripcion.trim();
      itemParsed.IndicadorBienoServicio = item.articulo.tipo_articulo.descripcion.toLowerCase().includes('servicio') ? indicadorBienoServicioE.servicio : indicadorBienoServicioE.bien;
      itemParsed.CantidadItem = redondearNum(item.cantidad);

      let key_unidad = item.unidad.split(' ')[0].toLowerCase();
      if (key_unidad == 'funda') key_unidad = 'bolsa';

      itemParsed.UnidadMedida = unidad_codeE[key_unidad] || null;
      itemParsed.PrecioUnitarioItem = redondearNum(item.precio);

      const descuento = getProperty(item, 'descuento') || getProperty(item, 'descuento_valor');

      if (descuento) {
        const isPriceChange = item.cantidad == 0;

        let descuento_proporcional = 0;

        if (isFactura) {
          descuento_proporcional = descuento;
        } else {
          const descuento_big = Big(descuento);
          const descuento_equivalente = descuento_big.div(item.cantidad_origin).toNumber();

          descuento_proporcional = descuento_equivalente * (isPriceChange ? item.cantidad_origin : item.cantidad);
        }

        itemParsed.DescuentoMonto = redondearNum(descuento_proporcional);

        itemParsed.TablaSubDescuento = {
          SubDescuento: [
            {
              TipoSubDescuento: '$',
              MontoSubDescuento: redondearNum(descuento_proporcional),
            },
          ],
        };
      }

      itemParsed.MontoItem = redondearNum(Number(itemParsed.PrecioUnitarioItem) * item.cantidad - Number(itemParsed.DescuentoMonto || 0));
      detallesItems.Item.push(itemParsed);
    });

    return detallesItems;
  }
}
