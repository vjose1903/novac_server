import express from 'express';
import http from 'http';
import { DgiiService } from '@core/services/DgiiService.service'; // Importamos el servicio

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

app.use(express.json());

// Configurar el servicio DGII
const dgiiService = DgiiService.getInstance();

// Endpoint para recibir el JSON desde Ruby on Rails
app.post('/procesar', async (req, res) => {
  try {
    const jsonData = req.body;

    // Agregar la tarea a la cola y esperar a que termine
    const result = await dgiiService.addToQueue(jsonData);

    // Retornar la respuesta solo cuando el proceso haya terminado
    res.status(200).json(result);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error procesando la solicitud' });
  }
});

// Iniciar el servidor
const port = process.env.PORT || 3000;
server.listen(port, () => {
  console.log(`Servidor escuchando en el puerto ${port}`);
});
