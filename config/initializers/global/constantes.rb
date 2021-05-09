HTTP_STATUS_CODE = Rack::Utils::SYMBOL_TO_STATUS_CODE

DIAS = ['Lunes', 'Martes', 'Miercoles', 'Jueves',  'Viernes', 'Sabado', 'Domingo']

module Documentos
	CEDULA = 'C'
	MATRICULA = 'M'

	def self.cedula
		return CEDULA
	end

	def self.matricula
		return MATRICULA
	end
end
DOCUMENTOS_DE_IDENTIDAD_VALIDOS = [Documentos.cedula, Documentos.matricula]



PROVINCIAS_MUNICIPIOS=[
  { nombre: "Distrito Nacional", municipios: ["Santo Domingo Centro (DN)", "Santo Domingo Este", "Santo Domingo Oeste", "Santo Domingo Norte", "Boca Chica", "San Antonio DE Guerra", "Los Alcarrizos", "Pedro Brand"] },
  { nombre: "San Pedro de Macorís", municipios: ["San Pedro DE Macoris", "Los Llanos", "Ramon Santana", "Consuelo", "Quisqueya", "Guayacanes"] },
  { nombre: "La Romana", municipios: ["La Romana", "Guaymate", "Villa Hermosa"] },
  { nombre: "La Altagracia", municipios: ["Higuey", "San Rafael Del Yuma" ] },
  { nombre: "El Seibo", municipios: ["El Seibo", "Miches"] },
  { nombre: "Hato Mayor", municipios: ["Hato Mayor", "Sabana De La Mar", "El Valle"] },
  { nombre: "Duarte",	municipios: ["San Francisco De Macoris", "Arenoso", "Castillo", "Pimentel", "Villa Riva", "Las Guaranas", "Eugenio Maria De Hostos"] },
  { nombre: "Samaná",	municipios: ["Samaná", "Sanchez", "Las Terrenas"] },
  { nombre: "Maria Trinidad Sánchez",	municipios: ["Nagua", "Cabrera", "El Factor", "Rio San Juan"] },
  { nombre: "Salcedo",	municipios: ["Salcedo", "Tenares", "Villa Tapia"] },
  { nombre: "La Vega",	municipios: ["La Vega", "Constanza", "Jarabacoa", "Jima Abajo"] },
  { nombre: "Monseñor Nouel",	municipios: ["Bonao", "Maimon", "Piedra Blanca"] },
  { nombre: "Sánchez Ramirez",	municipios: ["Cotui", "Cevicos", "Fantino", "La Mata"] },
  { nombre: "Santiago",	municipios: ["Santiago", "Bisono", "Janico", "Licey Al Medio", "San Jose De Las Matas", "Tamboril", "Villa Gonzalez", "Puñal", "Sabana Iglesia"] },
  { nombre: "Espaillat",	municipios: ["Moca", "Cayetano Germosen", "Gaspar Hernandez", "Jamao Al Norte"] },
  { nombre: "Puerto Plata",	municipios: ["Puerto plata", "altamira", "guananico", "imbert", "Los hidalgos", "luperon", "sosua", "Villa isabela", "Villa montellano"] },
  { nombre: "Valverde",	municipios: ["Mao", "Esperanza", "Laguna Salada"] },
  { nombre: "Monte Cristi",	municipios: ["Monte Cristi", "Castañuelas", "Guayubin", "Las Matas De Santa Cruz", "Pepillo Salcedo", "Villa Vasquez"] },
  { nombre: "Dajabón",	municipios: ["Dajabon", "Loma De Cabrera", "Partido", "Restauracion", "El Pino"] },
  { nombre: "Santiago Rodríguez",	municipios: ["San Ignacio De Sabaneta", "Villa Los Almacigos", "Moncion"] },
  { nombre: "Azua",	municipios: ["Azua", "Las Charcas", "Las Yayas De Viajama", "Padre Las Casas", "Peralta", "Sabana Yegua", "Pueblo Viejo", "Tabara Arriba", "Guayabal", "Estebania"] },
  { nombre: "San Juan de la Maguana",	municipios: ["San Juan", "Bohechio", "El Cercado", "Juan De Herrera", "Las Matas De Farfan", "Vallejuelo"] },
  { nombre: "Elías Piña",	municipios: ["Comendador", "Banica", "El Llano", "Hondo Valle", "Pedro Santana", "Juan Santiago"] },
  { nombre: "Barahona",	municipios: ["Barahona", "Cabral", "Enriquillo", "Paraiso", "Vicente Noble", "El Peñon", "La Cienaga", "Fundacion", "Las Salinas", "Polo", "Jaquimeyes"] },
  { nombre: "Bahoruco",	municipios: ["Neiba", "Galvan", "Tamayo", "Villa Jaragua", "Los Rios"] },
  { nombre: "Independencia",	municipios: ["Jimani", "Duverge", "La Descubierta", "Postrer Rio", "Cristobal", "Mella"] },
  { nombre: "Perdenales",	municipios: ["Pedernales", "Oviedo"] },
  { nombre: "San Cristóbal",	municipios: ["San Cristobal", "Sabana Grande De Palenque", "Bajos De Haina", "Cambita Garabitos", "Villa Altagracia", "Yaguate", "San Gregorio De Nigua", "Los Cacaos"] },
  { nombre: "Monte Plata",	municipios: ["Monte Plata", "Bayaguana", "Sabana Grande De Boya", "Yamasa", "Peralvillo"] },
  { nombre: "San José de Ocoa",	municipios: ["San Jose De Ocoa", "Sabana Larga", "Rancho Arriba"] },
  { nombre: "Peravia",	municipios: ["Bani", "Nizao"] }
]
