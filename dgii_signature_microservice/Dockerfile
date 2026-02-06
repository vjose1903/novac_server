FROM node:20.19.2-alpine AS build

WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./
COPY tsconfig.json ./

# Instalar dependencias
RUN npm install

# Copiar código fuente
COPY src/ ./src/

# Compilar el proyecto
RUN npm run build

FROM node:20.19.2-alpine

WORKDIR /app

# Copiar solo el build y el package.json desde la etapa de compilación
COPY --from=build /app/dist ./dist
COPY --from=build /app/package*.json ./

# Instalar solo dependencias de producción
RUN npm ci --omit=dev

# Exponer puerto
EXPOSE 9091

# Comando para iniciar el servicio
CMD ["node", "dist/server.js"] 