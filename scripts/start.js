var { execSync } = require('child_process');
var fs = require('fs');
var chalk = require('chalk');
var path = require('path');

// Importar el script de configuración de variables de entorno
const setupEnv = require('./env-setup');

const green = chalk.green;
const red = chalk.red;
const white = chalk.white;
const yellow = chalk.yellow;
const cyan = chalk.cyan;

let PRODUCTION = 'no';
let BACKGROUND = 'no';

function shDockerContainer() {

  const cliente = fs.readFileSync(pathAdd('../config_setup/actual_cliente.txt'), 'utf8').trim();
  const environmentSelected = PRODUCTION === 'yes' ? '-prod' : '-dev';

  console.log(`${green(' docker compose exec ')}${cliente}${environmentSelected} sh`);
  console.log(`${white(' ')}`);

  execSync(`docker compose exec ${cliente}${environmentSelected} sh`, { stdio: 'inherit' });
}

function getActualClient() {
  const cliente = fs.readFileSync(pathAdd('../config_setup/actual_cliente.txt'), 'utf8').trim();

  console.log(' ');
  console.log(`${green(' ||-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=||')}`);
  console.log(`${green(' ||          ')}${white('CLIENTE ACTUAL')}${green('          ||')}`);
  console.log(`${green(' ||-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=||')}`);
  console.log(' ');
  console.log(`${white('  ')}${cliente}`);
  console.log(' ');
}

function setClient(client) {
  console.log(`${cyan('setClient >>')} ${client}`);
  console.log(`${white(' ')}`);

  const environmentSelected = PRODUCTION === 'yes' ? 'prod' : 'dev';

  if (['agrodemi', 'brendy', 'vasquez', 'demo'].includes(client)) {
    execSync(`node ${pathAdd('./setup.js')} ${client} ${environmentSelected}`, { stdio: 'inherit' });
  } else {
    console.log(`${red('*************************************')}`);
    console.log(`${red('**                                 **')}`);
    console.log(`${red('**      CLIENTE NO ENCONTRADO      **')}`);
    console.log(`${red('**                                 **')}`);
    console.log(`${red('*************************************')}`);
    process.exit(2);
  }
}

function dockerCommand(command) {
  console.log(`${cyan('command >>')} ${command}`);
  console.log(`${white(' ')}`);

  const isBackground = command === 'up' && BACKGROUND === 'yes' ? '-d' : '';
  const bakeEnv = command === 'build' ? 'COMPOSE_BAKE=false ' : '';

	execSync(`cd ..`, { stdio: 'inherit' });
  if (PRODUCTION === 'yes') {
		execSync(`${bakeEnv}docker compose -f docker-compose.prod.yml ${command} ${isBackground}`, { stdio: 'inherit' });
  } else {
		execSync(`${bakeEnv}docker compose ${command} ${isBackground}`, { stdio: 'inherit' });
  }
	execSync(`cd scripts`, { stdio: 'inherit' });
}

function execCommandInContainer(commandKey) {
	const rakeCommands = {
		migrate: 'migrate',
		seed: 'seed',
		create: 'create',
		'migrate-status': 'migrate:status',
		drop: 'drop',
		rollback: 'rollback'
	}
	const railsCommands = { console: 'c' }

	if (commandKey in rakeCommands) {
		execDockerContainer(`rake db:${rakeCommands[commandKey]}`)
	} else if (commandKey in railsCommands) {
		execDockerContainer(`rails ${railsCommands[commandKey]}`)
	}
}

function execDockerContainer(command) {
	const cliente = fs.readFileSync(pathAdd('../config_setup/actual_cliente.txt'), 'utf8').trim();
	const environmentSelected = PRODUCTION === "yes" ? "-prod" : "-dev";

	console.log(
		`${green(
			" docker-compose exec "
		)}${cliente}${environmentSelected} ${command}`
	);
	console.log(`${white(" ")}`);

	execSync(`docker compose exec ${cliente}${environmentSelected} ${command}`, {
		stdio: "inherit",
	});
}

function removeItemAtIndex(array, index) {
  if (index >= 0 && index < array.length) {
    array.splice(index, 1);
  } else {
    console.log(`${red('Índice fuera de rango.')}`);
  }
}

function pathAdd(str_path) {
  const path_resolved = path.join(__dirname, str_path);
  return path_resolved;
}

async function processArgs() {
	const args = process.argv.slice(2);

	while (args.length) {
		console.log(' ');
		const opt = args[0]

		if (opt.startsWith('-')) {
			switch (opt) {
				case '-env':
					console.log('la opcion -env');
					setupEnv(); // Configurar variables de entorno
					break;
				case '-w':
					console.log('la opcion -w');
					execSync('docker system prune -f', {stdio: 'inherit'});
					break;
				case '-r':
					console.log('la opcion -r');
					dockerCommand('restart');
					break;
				case '-sh':
					console.log('la opcion -sh');
					execDockerContainer("sh");
					break;
				case '-e':
					console.log("la opcion -e");
					const commandIndex = 1;
					const command = args[commandIndex];

					console.log("command ==> ", command);
					if (command !== undefined) {
						if (["migrate", "seed", "create", "migrate-status", "drop", "console", "rollback"].includes(command)) {
							execCommandInContainer(command);
						} else {
							console.log(`${red("************************************")}`);
							console.log(`${red("**                                **")}`);
							console.log(`${red("**      COMANDO NO PERMITIDO      **")}`);
							console.log(`${red("**                                **")}`);
							console.log(`${red("************************************")}`);
							process.exit(2);
						}
					} else {
						console.log(`${red("**********************************************")}`);
						console.log(`${red("**                                          **")}`);
						console.log(`${red("**      DEBE DE ESPECIFICAR UN COMANDO      **")}`);
						console.log(`${red("**                                          **")}`);
						console.log(`${red("**********************************************")}`);
						process.exit(2);
					}
					break;
				case '-a':
					console.log('la opcion -a');
					getActualClient();
					break;
				case '-p':
					console.log('la opcion -p');
					PRODUCTION = 'yes';
					console.log(`${white(' ')}`);
					console.log(`${yellow(' -=-=-=- EJECUTANDO EN PRODUCCION -=-=-=-')}${white(' ')}`);
					console.log(`${white(' ')}`);
					break;
				case '-t':
					console.log('la opcion -t');
					BACKGROUND = 'yes';
					break;
				case '-c':
					console.log('la opcion -c');
					const clientIndex = args.indexOf('-c') + 1;
					if (clientIndex < args.length) {
						setClient(args[clientIndex]);
						removeItemAtIndex(args, clientIndex)
					}

					break;
				case '-b':
					console.log('la opcion -b');
					dockerCommand('build');
					break;
				case '-u':
					console.log('la opcion -u');
					dockerCommand('up');
					break;
				case '-d':
					console.log('la opcion -d');
					dockerCommand('down');
					break;
				case '-s':
					console.log('la opcion -s');
					dockerCommand('stop');
					break;
				default:
					console.log(`${red('*************************************')}`);
					console.log(`${red('**                                 **')}`);
					console.log(`${red('**        FLAG NO PERMITIDO        **')}`);
					console.log(`${red('**                                 **')}`);
					console.log(`${red('*************************************')}`);
					process.exit(2);
			}
		}
		args.splice(0, 1);
	}
}

processArgs()