import { indicadorBienoServicioE, indicadorFacturacionE, unidad_codeE } from "@core/constants/factura.utils";
import { DetalleFacturaI } from "@core/types/factura.types";
import { DetallesFacturasNota } from "@core/types/notas.types";
import { CodigosItem, ItemI } from "@core/types/xml/xml_detallesItem_json";
import { getProperty, redondearNum } from "./functions";

export class Detalles {
  constructor() {}

  parse(detalles: DetalleFacturaI[] | DetallesFacturasNota[]) {
    const detallesItems = { Item: [] };

    detalles.forEach((item: DetalleFacturaI | DetallesFacturasNota, index: number) => {
      const itemParsed = {} as ItemI;
      itemParsed.NumeroLinea = `${index + 1}`;

      itemParsed.TablaCodigosItem = { CodigosItem: [] };
      const codigo: CodigosItem = { TipoCodigo: 'Interna', CodigoItem: item.articulo.codigo };
      itemParsed.TablaCodigosItem.CodigosItem.push(codigo);

      // TODO: revisar
      itemParsed.IndicadorFacturacion = item.articulo.calcular_itbis ? indicadorFacturacionE.itbis_18 : indicadorFacturacionE.excento;

      itemParsed.NombreItem = item.descripcion.trim();
      itemParsed.IndicadorBienoServicio = item.articulo.tipo_articulo.descripcion.toLowerCase().includes('servicio') ? indicadorBienoServicioE.servicio : indicadorBienoServicioE.bien;
      itemParsed.CantidadItem = redondearNum(item.cantidad);

      let key_unidad = item.unidad.replace(' ', '_').toLowerCase();
      if (key_unidad.match(/saco_de_(\d+)?_libras/)) key_unidad = 'saco';
      if (key_unidad == 'funda') key_unidad = 'bolsa';

      itemParsed.UnidadMedida = unidad_codeE[item.articulo.unidad_medida] || null;
      itemParsed.PrecioUnitarioItem = redondearNum(item.precio);

      const descuento = getProperty(item, 'descuento_real') || getProperty(item, 'descuento_valor');

      console.log(" ");
      console.log(" ");
      console.log(" ");
      console.log("descuento ", descuento);
      console.log(" ");
      console.log(" ");
      console.log(" ");
      

      if (descuento) {
        itemParsed.DescuentoMonto = redondearNum(descuento);

        itemParsed.TablaSubDescuento = {
          SubDescuento: [
            {
              TipoSubDescuento: '$',
              MontoSubDescuento: redondearNum(descuento),
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
