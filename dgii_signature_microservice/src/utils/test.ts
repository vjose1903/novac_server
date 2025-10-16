import { DgiiAuthService } from '@core/services/DgiiAuth.service';
import { DateUtils } from '@vjose1903/dateutils';

async function test() {
  // const dgiiAuthService = DgiiAuthService.getInstance();
  // console.log(await dgiiAuthService.testAuthentication());

  // // Desmontar el servicio después del test
  // dgiiAuthService.shutdown();

  const fecha_vencimiento = '2025-02-23 14:00:00';
  const fecha_emision = '23-05-2025 14:00:00';

  const fechaVencimiento = DateUtils.format({ date: fecha_vencimiento, dateFormat: 'YYYY-MM-DD' });
  console.log("fechaVencimiento ", fechaVencimiento);
  // TODO: Revisar esto
  const fechaActual = DateUtils.format({ date: fecha_emision, dateFormat: 'YYYY-MM-DD' });
  console.log("fechaActual ", fechaActual);

  const esFechaValida = DateUtils.compareDates(fechaActual, fechaVencimiento) >= 0;

  console.log("DateUtils.compareDates(fechaActual, fechaVencimiento) ", DateUtils.compareDates(fechaActual, fechaVencimiento));
  console.log("esFechaValida ", esFechaValida);
  

  // si la fecha de vencimiento es mayor o igual a la fecha actual, se asigna la fecha de vencimiento de lo contrario se asigna la fecha actual
  const fecha_limite = esFechaValida ? DateUtils.format({ date: fecha_vencimiento, dateFormat: 'DD-MM-YYYY' }) : fecha_emision;

  console.log('fecha_limite --> ', fecha_limite);
}

test();
