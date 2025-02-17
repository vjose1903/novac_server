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


export enum sheet_typeE {
  paper = 'paper',
  roll = 'roll',
}

export enum unidad_codeE {
  barril = '1',       // -> BARR
  bolsa = '2',        // -> BOL
  botella = '5',      // -> BOTELLA
  caja = '6',         // -> CAJ 
  docena = '13',      // -> DOC
  fardo = '14',       // -> FARD
  galon = '15',       // -> GL
  kilogramo = '21',   // -> KG
  libra = '23',       // -> LB
  litro = '24',       // -> LITRO
  tanque = '38',      // -> TANQUE
  unidad = '43',      // -> UND
  saco = '46',        // -> SAC
  quintal = '51',     // -> Q
  miligramo = '60',   // -> MG
  onzas = '61',       // -> OZ
}
