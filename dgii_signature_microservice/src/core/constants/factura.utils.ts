export enum tipo_pago_codeE {
  contado = 1,
  credito = 2,
  gratuito = 3,
}

export enum condicionE {
  contado = 'Contado',
  credito = 'Crédito',
  gratuito = 'Gratuito',
}

export type condicionT = `${condicionE}`;

/*
1: Efectivo
2: Cheque/Transferencia/Depósito
3: Tarjeta de Débito/Crédito
4: Venta a Crédito
5: Bonos o Certificados de regalo
6: Permuta
7: Nota de crédito
8: Otras Formas de pago
*/

export enum forma_pago_codeE {
  efectivo = 1,
  cheque = 2,
  transferencia = 2,
  deposito = 2,
  tarjeta = 3,
  venta_credito = 4,
  bonos = 5,
  permuta = 6,
  nota_credito = 7,
  otras = 8,
}

export enum forma_pagoE {
  efectivo = 'Efectivo',
  cheque = 'Cheque',
  transferencia = 'Transferencia',
  deposito = 'Depósito',
  tarjeta = 'Tarjeta',
  venta_credito = 'Venta a Crédito',
  bonos = 'Bonos',
  permuta = 'Permuta',
  nota_credito = 'Nota de Crédito',
  otras = 'Otras',
}

export type forma_pagoT = `${forma_pagoE}`;

export enum indicadorFacturacionE {
  no_facturable = '0',
  itbis_18 = '1',
  itbis_16 = '2',
  itbis_0 = '3',
  excento = '4',
}

export enum indicadorBienoServicioE {
  bien = '1',
  servicio = '2',
}

export enum unidad_codeE {
  barril = '1',
  bolsa = '2',
  botella = '5',
  caja = '6',
  docena = '13',
  fardo = '14',
  galon = '15',
  kilogramo = '21',
  libra = '23',
  litro = '24',
  tanque = '38',
  unidad = '43',
  saco = '46',
  quintal = '51',
  miligramo = '60',
  onzas = '61',
}
