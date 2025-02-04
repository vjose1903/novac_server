export interface P12ReaderData {
	key: string | undefined;
	cert: string | undefined;
}

export enum CommercialApprovalEnum {
  code_accepted = '01',
	code_rejected = '02',
	status_accepted = 'Aprobación Comercial Aprobada.',
	status_rejected = 'Aprobacion Comercial Rechazada.',
}

