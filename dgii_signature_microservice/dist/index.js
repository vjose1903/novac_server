"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const body_parser_1 = __importDefault(require("body-parser"));
const app = (0, express_1.default)();
const port = 3000;
// Middleware
app.use(body_parser_1.default.json());
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
