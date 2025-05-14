import express from 'express';
import http from 'http';
import { DgiiEcfService } from '@core/services/DgiiEcf.service'; // Importamos el servicio
import { handleNovacDgiiReception, handleNovacDgiiRequest, handleNovacDgiiValidateCommercialApproval } from '@controllers/dgiiController';
import { DgiiAuthService } from '@core/services/DgiiAuth.service';
import { ENVIRONMENT } from 'dgii-ecf';
import GoogleDriveUtils from '@utils/typescript/google/google_drive.utils';
import { DgiiReceptionService } from '@core/services/DgiiReception.service';
import { DgiiCommercialApprovalService } from '@core/services/DgiiCommercialApproval.service';


if (process.env.ENV !== 'PROD') {
  printEnvironment(`DESARROLLO: ${ENVIRONMENT[process.env.ENV]}`);
  import('dotenv/config');
} else {
  printEnvironment('PRODUCCIÓN');
}

function printEnvironment(environment: string) {
  console.log('  ');
  console.log(' - - - - - - - - - - - - - - - - - - - - - - - - -');
  console.log(`  EJECUTANDO EN AMBIENTE DE ${environment}`);
  console.log(' - - - - - - - - - - - - - - - - - - - - - - - - -');
  console.log('  ');
}

const app = express();
const server = http.createServer(app);

// Inicializar los servicios DGII en orden correcto
DgiiAuthService.getInstance(); 
DgiiEcfService.getInstance();

DgiiReceptionService.getInstance();
DgiiCommercialApprovalService.getInstance();
GoogleDriveUtils.getInstance();

app.use(express.json());

// Crear un router para manejar todas las rutas bajo /api/v1
const apiV1Router = express.Router();

// Definir la ruta novac-dgii dentro del router /api/v1
apiV1Router.post('/novac-dgii', handleNovacDgiiRequest);
apiV1Router.post('/novac-dgii-reception', handleNovacDgiiReception);
apiV1Router.post('/novac-dgii-validate-commercial-approval', handleNovacDgiiValidateCommercialApproval);

// Usar el router con el prefijo /api/v1
app.use('/api/v1', apiV1Router);

// Iniciar el servidor
const port = process.env.PORT || 9091;
server.listen(port, () => {
  console.log(`Servidor escuchando en el puerto ${port}`);
});
