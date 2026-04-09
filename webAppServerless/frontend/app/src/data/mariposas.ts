import type { Mariposa } from '@/types/mariposas';

// Mariposas nativas de Buenos Aires según el PDF del Ministerio de Ambiente
export const mariposasPrecargadas: Mariposa[] = [
  {
    id: 'morpho-episthropus',
    nombreCientifico: 'Morpho episthropus argentinus',
    nombreComun: 'Bandera Argentina',
    descripcion: 'Una de las mariposas más emblemáticas de la Argentina. Sus alas grandes y de color azul iridiscente la hacen inconfundible. Es una especie dependiente exclusiva del Coronillo para completar su ciclo de vida.',
    plantaNutricia: {
      nombreCientifico: 'Scutia buxifolia',
      nombreComun: 'Coronillo'
    },
    imagen: '/images/mariposa_bandera_argentina.jpg',
    ecorregion: 'espinal'
  },
  {
    id: 'dione-vanillae',
    nombreCientifico: 'Dione vanillae',
    nombreComun: 'Espejitos',
    descripcion: 'Mariposa de alas naranja brillante con manchas negras y plateadas que parecen espejos. Su nombre común hace referencia a estos reflejos metálicos en sus alas.',
    plantaNutricia: {
      nombreCientifico: 'Passiflora caerulea',
      nombreComun: 'Pasionaria, Mburucuyá'
    },
    imagen: '/images/mariposa_espejitos.jpg',
    ecorregion: 'pampeana'
  },
  {
    id: 'danaus-erippus',
    nombreCientifico: 'Danaus erippus',
    nombreComun: 'Monarca',
    descripcion: 'Mariposa de alas anaranjadas con venas negras y puntos blancos en los bordes. Es una especie migratoria y cumple un rol importante como polinizadora.',
    plantaNutricia: {
      nombreCientifico: 'Asclepia mellodora',
      nombreComun: 'Yerba de víbora'
    },
    imagen: '/images/mariposa_moneda.jpg',
    ecorregion: 'pampeana'
  },
  {
    id: 'abaeis-deva',
    nombreCientifico: 'Abaeis deva',
    nombreComun: 'Limoncito',
    descripcion: 'Pequeña mariposa de color amarillo brillante con pequeños puntos negros en las alas. Su nombre hace referencia a su coloración cítrica.',
    plantaNutricia: {
      nombreCientifico: 'Senna corymbosa',
      nombreComun: 'Sen del campo'
    },
    imagen: '/images/mariposa_limoncito.jpg',
    ecorregion: 'pampeana'
  },
  {
    id: 'doxocopa-laurentia',
    nombreCientifico: 'Doxocopa laurentia',
    nombreComun: 'Zafiro del Talar',
    descripcion: 'Mariposa de alas marrones con reflejos azulados iridiscentes en el ápice. Habita principalmente en los bosques de talar, de ahí su nombre.',
    plantaNutricia: {
      nombreCientifico: 'Celtis tala',
      nombreComun: 'Tala'
    },
    imagen: '/images/mariposa_zafiro_talar.jpg',
    ecorregion: 'espinal'
  },
  {
    id: 'riodina-lysippoides',
    nombreCientifico: 'Riodina lysippoides',
    nombreComun: 'Danzarina Chica',
    descripcion: 'Mariposa de tamaño pequeño con alas marrones y manchas metálicas plateadas y cobrizas que brillan al sol.',
    plantaNutricia: {
      nombreCientifico: 'Vachellia caven',
      nombreComun: 'Espinillo'
    },
    imagen: '/images/mariposa_danzarina.jpg',
    ecorregion: 'espinal'
  },
  {
    id: 'papilio-thoas',
    nombreCientifico: 'Papilio thoas',
    nombreComun: 'Limonera Grande',
    descripcion: 'Es una especie imponente, con una envergadura de 10 a 13 cm, conocida por sus alas negras con manchas amarillas en diagonal y vuelo potente. Se caracteriza por cola de golondrina y es una de las más grandes de Argentina. Se adaptó a desovar en Limoneros o Mandarinas.',
    plantaNutricia: {
      nombreCientifico: 'Zanthoxylum rhoifolium',
      nombreComun: 'Tembetarí'
    },
    imagen: '/images/mariposa_limoneragrande.jpg',
    ecorregion: 'espinal'
  },
  {
    id: 'actinote-pellenea',
    nombreCientifico: 'Actinote pellenea',
    nombreComun: 'Perezosa',
    descripcion: 'Mariposa de alas naranja con manchas negras y bordes oscuros. Se la encuentra frecuentemente en praderas y bordes de caminos.',
    plantaNutricia: {
      nombreCientifico: 'Austroeupatorium inulifolium',
      nombreComun: 'Mariposera, chilca de olor'
    },
    imagen: '/images/mariposa_perezosa.jpg',
    ecorregion: 'pampeana'
  },
  {
    id: 'tatochila-autodice',
    nombreCientifico: 'Tatochila autodice',
    nombreComun: 'Lechera',
    descripcion: 'Mariposa de alas blancas con puntos negros en los bordes y venas grises. Su nombre hace referencia a su coloración blanquecina.',
    plantaNutricia: {
      nombreCientifico: 'Cestrum parqui',
      nombreComun: 'Duraznillo negro'
    },
    imagen: '/images/mariposa_lechera.jpg',
    ecorregion: 'pampeana'
  },
  {
    id: 'ajedrezada-menor',
    nombreCientifico: 'Pyrgus malvoides',
    nombreComun: 'Ajedrezada Menor',
    descripcion: 'Pequeña mariposa de vuelo rápido, posee el anverso de las alas de color castaño oscuro con numerosas manchas blancas, pequeñas y cuadrangulares y el margen fimbriado y ajedrezado con los mismos tonos castaño oscuro y blanco. En el reverso, el color de fondo es marrón claro con un ligero matiz verde y traslucen las mismas manchas blancas .',
    plantaNutricia: {
      nombreCientifico: 'Pavonia hastata',
      nombreComun: 'Malva Rosada / Malva Dura'
    },
    imagen: '/images/mariposa_ajedrezadamenor_hastata.jpg',
    ecorregion: 'delta'
  }
];

// Función para obtener una mariposa por ID
export const getMariposaById = (id: string): Mariposa | undefined => {
  return mariposasPrecargadas.find(m => m.id === id);
};

// Función para obtener mariposas por ecorregión
export const getMariposasByEcorregion = (ecorregion: string): Mariposa[] => {
  return mariposasPrecargadas.filter(m => m.ecorregion === ecorregion);
};
