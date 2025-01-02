import express from 'express';
import bodyParser from 'body-parser';

const app = express();
const port = 3000;

// Middleware
app.use(bodyParser.json());

// Rutas
app.get('/health', (_req, res) => {
	res.send({ status: 'Microservicio activo' });
});

app.post('/process', (req, res) => {
	const { data } = req.body;
	const result = data.toUpperCase(); // Procesamiento de ejemplo
	res.send({ result });
});

// Inicia el servidor
app.listen(port, () => {
	console.log(`Microservicio escuchando en http://localhost:${port}`);
});
