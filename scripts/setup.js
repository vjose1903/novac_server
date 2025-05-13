const fs = require('fs');
var path = require('path');

const clientes = ['brendy', 'agrodemi', 'vasquez', 'demo'];
const clienteSelected = process.argv[2];
const environmentSelected = process.argv[3];

const setup = {
  demo: {
    ALMACEN: "DEMO",
    ENVIRONMENT_NAME_IMG: "demo-",
    PROD_ENVIRONMENT_NAME_IMG: "demo-",
    DB_PATH: "db-demo-data",
    DB_PORT: "3003",
    CORS_PORT: "5223",
    FRONT_PORT: "9093",
    FRONTEND_HOST: "8n3mw1zq-9093.use2.devtunnels.ms",
    FRONTEND_HOST_SECONDARY: "8n3mw1zq-9093.use2.devtunnels.ms",
    EMAIL: "novacdemo@gmail.com",
    MONTU: "1Wt7ND-m7yZidbgRyf_89fNeK71gyz7fn"
  },
  agrodemi: {
    ALMACEN: "ADM",
    ENVIRONMENT_NAME_IMG: "agrodemi-",
    PROD_ENVIRONMENT_NAME_IMG: "agrodemi-",
    DB_PATH: "db-agrodemi-data",
    DB_PORT: "3000",
    CORS_PORT: "5220",
    FRONT_PORT: "9090",
    FRONTEND_HOST: "agrodemi.inspot-technology.com",
    FRONTEND_HOST_SECONDARY: "admservidor.ddns.net",
    EMAIL: "novacagrodemi@gmail.com",
    MONTU: "1RzMbNCVAhqkNzH0mTO8f27-kfq1oum6a"
  },
  brendy: {
    ALMACEN: "panaderia_brendy",
    ENVIRONMENT_NAME_IMG: "brendy-",
    PROD_ENVIRONMENT_NAME_IMG: "brendy-",
    DB_PATH: "db-brendy-data",
    DB_PORT: "3001",
    CORS_PORT: "5221",
    FRONT_PORT: "9091",
    FRONTEND_HOST: "novac-brendy.ddns.net",
    FRONTEND_HOST_SECONDARY: "novac-brendy.ddns.net",
    EMAIL: "novacbrendy@gmail.com",
		MONTU: "1C96yS20EDDyX7rgi2Y5OQju_4FQ8G5_C"
  },
  vasquez: {
    ALMACEN: "vasquez_services",
    ENVIRONMENT_NAME_IMG: "vasquez-",
    PROD_ENVIRONMENT_NAME_IMG: "vasquez-",
    DB_PATH: "db-vasquez-data",
    DB_PORT: "3002",
    CORS_PORT: "5222",
    FRONT_PORT: "9092",
    FRONTEND_HOST: "vasquez.inspot-technology.com",
    FRONTEND_HOST_SECONDARY: "novac-vasquez.ddns.net",
    EMAIL: "novacvasquez@gmail.com",
		MONTU: "17pDTnH139lHpSRj3_xoPWP8jJYHR0roa"
  }
};

const files = [
  { tipo: 'move',       file_name: 'seedConstantes',         extension: 'rb',       path: 'config/initializers/global/seedConstantes.rb' },

	{ tipo: 'reemplazo',  file_name: 'docker-compose.prod.yml',                       path: 'docker-compose.prod.yml' },
	{ tipo: 'reemplazo',  file_name: 'docker-compose.yml',                            path: 'docker-compose.yml' },
	{ tipo: 'reemplazo',  file_name: 'Dockerfile',                                    path: 'docker/Dockerfile' },
	{ tipo: 'reemplazo',  file_name: 'run_server.sh',                                 path: 'run_server.sh' },
	{ tipo: 'reemplazo',  file_name: 'cors.rb',                                       path: 'config/initializers/cors.rb' },
	{ tipo: 'reemplazo',  file_name: 'development.rb',                                path: 'config/environments/development.rb' },
	{ tipo: 'reemplazo',  file_name: 'production.rb',                                 path: 'config/environments/production.rb' },
];

function makeSetup(cliente) {
  console.log("\n\n\n");

  if (clientes.includes(cliente)) {
    console.log("--------".repeat(10));
    console.log("         ".repeat(4) + `${clienteSelected}`);
    console.log("--------".repeat(10));
    console.log("\n");

    files.forEach(objFile => {
      if (objFile.tipo === 'reemplazo') {
        console.log("-=-=-=-=-=-=- " + "ARCHIVO CON REEMPLAZO");
        replaceFiles(cliente, objFile);
      } else {
        console.log("-=-=-=-=-=-=- " + "ARCHIVO A MOVER");
        moveFiles(cliente, objFile);
      }

      console.log("\n");
    });

    fs.writeFileSync(pathAdd('../config_setup/actual_cliente.txt'), cliente);
  } else {
    console.log("********************************************");
    console.log("**                                        **");
    console.log("**          CLIENTE NO EXISTE             **");
    console.log("**                                        **");
    console.log("********************************************");
    return 0;
  }
}

function replaceFiles(cliente, objFile) {
  let fileData = fs.readFileSync(pathAdd(`../config_setup/${objFile.file_name}`), 'utf-8');

  Object.keys(setup[cliente]).forEach(key => {
    let replaceString = setup[cliente][key];

    if (key.includes("PROD_ENVIRONMENT_")) replaceString += 'prod';
    else if (key.includes("ENVIRONMENT_")) replaceString += environmentSelected;

    fileData = fileData.replaceAll(`$$${key}$$`, replaceString);
  });

  fs.writeFileSync(pathAdd(`../${objFile.path}`), fileData);
  console.log("\n");
  console.log(`ARCHIVO: ${objFile.file_name} reemplazado.`);
}

function moveFiles(cliente, objFile) {
  const fileData = fs.readFileSync(pathAdd(`../config_setup/${objFile.file_name}_${cliente}.${objFile.extension}`), 'utf-8');

  fs.writeFileSync(pathAdd(`../${objFile.path}`), fileData);
  console.log("\n");
  console.log(`ARCHIVO: ${objFile.file_name} movido.`);
}

function pathAdd(str_path) {
  const path_resolved = path.join(__dirname, str_path);
  return path_resolved;
}

makeSetup(clienteSelected);
return 1;