// Tipos para las mariposas nativas de Buenos Aires

export interface PlantaNutricia {
  nombreCientifico: string;
  nombreComun: string;
}

export interface Mariposa {
  id: string;
  nombreCientifico: string;
  nombreComun: string;
  descripcion: string;
  plantaNutricia: PlantaNutricia;
  imagen: string;
  ecorregion: string;
  usuarioSubido?: boolean;
  usuarioId?: string;
  fechaSubida?: string;
}

export interface UserSighting {
  id: string;
  mariposaId: string;
  usuarioId: string;
  usuarioNombre: string;
  imagenUrl: string;
  ubicacion: string;
  fechaAvistamiento: string;
  notas?: string;
  fechaSubida: string;
}

export interface User {
  id: string;
  nombre: string;
  email: string;
  avatar?: string;
}

// Ecorregiones de Buenos Aires
export const ecorregiones = [
  { id: 'pampeana', nombre: 'Pampeana', descripcion: 'Praderas y pastizales del centro-este de la provincia' },
  { id: 'espinal', nombre: 'Espinal', descripcion: 'Bosques de talas y espinillos del noroeste' },
  { id: 'delta', nombre: 'Delta e Islas del Paraná', descripcion: 'Humedales y bosques ribereños del noreste' },
] as const;
