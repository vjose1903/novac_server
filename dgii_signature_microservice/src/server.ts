import express from 'express';
import http from 'http';
import { DgiiService } from '@core/services/DgiiService.service'; // Importamos el servicio
import { handleNovacDgiiRequest } from '@controllers/dgiiController';


if (process.env.ENVIRONMENT !== 'production') {
  printEnvironment('DESARROLLO');
  import('dotenv/config');
} else {
  printEnvironment('PRODUCCIÓN');
}

function printEnvironment(environment: string) {
  console.log('  ');
  console.log(' - - - - - - - - - - - - - - - - - - - -');
  console.log(`  EJECUTANDO EN AMBIENTE DE ${environment}`);
  console.log(' - - - - - - - - - - - - - - - - - - - -');
  console.log('  ');
}

const app = express();
const server = http.createServer(app);

// Configurar el servicio DGII
DgiiService.getInstance();

app.use(express.json());

// Crear un router para manejar todas las rutas bajo /api/v1
const apiV1Router = express.Router();

// Definir la ruta novac-dgii dentro del router /api/v1
apiV1Router.post('/novac-dgii', handleNovacDgiiRequest);

// Usar el router con el prefijo /api/v1
app.use('/api/v1', apiV1Router);

// Iniciar el servidor
const port = process.env.PORT || 9091;
server.listen(port, () => {
  console.log(`Servidor escuchando en el puerto ${port}`);
});
