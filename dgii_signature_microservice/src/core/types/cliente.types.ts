export interface ClienteI {
  id: number;
  nombre: string;
  apellido: string;
  telefono: string;
  direccion: string;
  limite_credito: number;
  documentos_de_identidad?: DocumentoIdentidadI[];
  provincia?: DireccionI;
  municipio?: DireccionI;
  [key: string]: any;
}

export interface DocumentoIdentidadI {
  id: number;
  tipo: string;
  numero: string;
  principal: boolean;
  [key: string]: any;
}

export interface DireccionI {
  id: number;
  nombre: string;
  codigo: string;
  [key: string]: any;
}
