#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const chalk = require('chalk');

const green = chalk.green;
const red = chalk.red;
const white = chalk.white;
const cyan = chalk.cyan;

function setupEnv() {
  console.log(white(' '));
  console.log(green(' -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-'));
  console.log(green(' ||      CONFIGURACIÓN DE VARIABLES DE ENTORNO   ||'));
  console.log(green(' -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-'));
  console.log(white(' '));

  const microservicePath = path.join(__dirname, '../dgii_signature_microservice');
  const examplePath = path.join(microservicePath, 'env.example');
  const envPath = path.join(microservicePath, '.env');

  // Verificar que el directorio del microservicio existe
  if (!fs.existsSync(microservicePath)) {
    console.error(red('Error: No se encontró la carpeta del microservicio DGII.'));
    process.exit(1);
  }

  // Verificar que el archivo de ejemplo existe
  if (!fs.existsSync(examplePath)) {
    console.error(red('Error: No se encontró el archivo env.example en el microservicio.'));
    process.exit(1);
  }

  // Crear .env si no existe
  if (!fs.existsSync(envPath)) {
    console.log(cyan('Creando .env desde env.example...'));
    fs.copyFileSync(examplePath, envPath);
    console.log(green('✅ Archivo .env creado. Por favor, edítelo con los valores correctos.'));
  } else {
    console.log(cyan('El archivo .env ya existe. Si desea regenerarlo, elimínelo primero.'));
  }

  console.log(white(' '));
  console.log(green(' Recuerde editar el archivo .env con los valores reales.'));
  console.log(green(' Este archivo no se incluirá en el control de versiones por seguridad.'));
  console.log(white(' '));

  return {
    envPath: envPath,
    examplePath: examplePath
  };
}

// Permitir la ejecución como módulo o como script independiente
if (require.main === module) {
  // Fue ejecutado directamente (no como un módulo requerido)
  setupEnv();
} else {
  // Fue importado como un módulo
  module.exports = setupEnv;
} 