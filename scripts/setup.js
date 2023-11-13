const fs = require('fs');
var path = require('path');

const clientes = ['brendy', 'agrodemi', 'vasquez'];
const clienteSelected = process.argv[2];
const environmentSelected = process.argv[3];

const setup = {
  agrodemi: {
    ALMACEN: "ADM",
    ALMACEN_MAIL: "novacagrodemi@gmail.com",
    ENVIRONMENT_NAME_IMG: "agrodemi-",
    DB_PATH: "db-agrodemi-data",
    DB_PORT: "3000",
    CORS_PORT: "5220",
    FRONT_PORT: "9090",
    NGINX_SERVER_NAME: "localhost admservidor.ddns.net *.admservidor.ddns.net"
  },
  brendy: {
    ALMACEN: "panaderia_brendy",
    ALMACEN_MAIL: "novacbrendy@gmail.com",
    ENVIRONMENT_NAME_IMG: "brendy-",
    DB_PATH: "db-brendy-data",
    DB_PORT: "3001",
    CORS_PORT: "5221",
    FRONT_PORT: "9091",
    NGINX_SERVER_NAME: "localhost novac-brendy.ddns.net *.novac-brendy.ddns.net"
  },
  vasquez: {
    ALMACEN: "vasquez_services",
    ALMACEN_MAIL: "novacvasquez@gmail.com",
    ENVIRONMENT_NAME_IMG: "vasquez-",
    DB_PATH: "db-vasquez-data",
    DB_PORT: "3002",
    CORS_PORT: "5222",
    FRONT_PORT: "9092",
    NGINX_SERVER_NAME: "localhost novac-vasquez.ddns.net *.novac-vasquez.ddns.net"
  }
};

const files = [
  { tipo: 'move',       file_name: 'google_api_credentials', extension: 'json',     path: 'config/google_api_credentials.json' },
  { tipo: 'move',       file_name: 'seedConstantes',         extension: 'rb',       path: 'config/initializers/global/seedConstantes.rb' },

	{ tipo: 'reemplazo',  file_name: 'docker-compose.prod.yml',                       path: 'docker-compose.prod.yml' },
	{ tipo: 'reemplazo',  file_name: 'docker-compose.yml',                            path: 'docker-compose.yml' },
	{ tipo: 'reemplazo',  file_name: 'Dockerfile',                                    path: 'docker/services/server/Dockerfile' },
	{ tipo: 'reemplazo',  file_name: 'default.conf',                                  path: 'docker/services/nginx/default.conf' },
	{ tipo: 'reemplazo',  file_name: 'run_server.sh',                                 path: 'run_server.sh' },
	{ tipo: 'reemplazo',  file_name: 'cors.rb',                                       path: 'config/initializers/cors.rb' },
	{ tipo: 'reemplazo',  file_name: 'db.rake',                                       path: 'lib/tasks/db.rake' },
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

    if (key.includes("ENVIRONMENT_")) replaceString += environmentSelected;

		const searchStr = '$$' + key + '$$';
    fileData = fileData.replaceAll(searchStr, replaceString);
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