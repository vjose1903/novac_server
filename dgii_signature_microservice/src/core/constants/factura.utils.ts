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
