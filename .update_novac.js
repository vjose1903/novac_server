#!/usr/bin/env node

'use strict';

const { execFileSync } = require('node:child_process');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');

const home = process.env.HOME || os.homedir();
const projectDir = process.env.NOVAC_PROJECT_DIR || process.cwd();
const branch = process.env.NOVAC_BRANCH || 'ADM';
const client = process.env.NOVAC_CLIENT || 'agrodemi';

function run(command, args, options = {}) {
  execFileSync(command, args, { stdio: 'inherit', ...options });
}

function git(args, options) {
  run('git', args, options);
}

function unlockGitCryptFiles() {
  try {
    execFileSync('git-crypt', ['--version'], { stdio: 'ignore' });
  } catch {
    throw new Error('ERROR: git-crypt no está instalado en el servidor.');
  }

  const keyPath = process.env.NOVAC_GIT_CRYPT_KEY || path.join(home, '.config/novac/git-crypt.key');
  const status = execFileSync('git-crypt', ['status'], { encoding: 'utf8' });
  const encryptedFiles = status
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line.startsWith('encrypted:'))
    .map((line) => line.slice('encrypted:'.length).trim())
    .filter(Boolean);

  if (encryptedFiles.length === 0) {
    console.log('      No hay archivos git-crypt cifrados pendientes.');
    return;
  }

  console.log(`      Se detectaron ${encryptedFiles.length} archivos cifrados.`);
  if (!fs.existsSync(keyPath)) {
    throw new Error(`ERROR: no existe la clave git-crypt: ${keyPath}`);
  }

  run('git-crypt', ['unlock', keyPath]);

  const header = Buffer.from('004749544352595054', 'hex');
  const stillEncrypted = encryptedFiles.filter((file) => {
    let fd;
    try {
      fd = fs.openSync(file, 'r');
      const bytes = Buffer.alloc(header.length);
      const bytesRead = fs.readSync(fd, bytes, 0, bytes.length, 0);
      return bytesRead === header.length && bytes.equals(header);
    } catch {
      return false;
    } finally {
      if (fd !== undefined) fs.closeSync(fd);
    }
  });

  if (stillEncrypted.length > 0) {
    throw new Error(`ERROR: quedaron archivos git-crypt cifrados después del desbloqueo:\n${stillEncrypted.join('\n')}`);
  }

  console.log('      Credenciales git-crypt desbloqueadas y verificadas.');
}

function step(number, description, action) {
  console.log(`[${number}/9] ${description}`);
  action();
  console.log('      OK\n');
}

try {
  console.log(`\n\x1b[95m===== INICIAR ACTUALIZACIÓN DE ${client} =====\x1b[0m`);
  console.log(`Proyecto: ${projectDir}\nRama: ${branch}\n`);
  step(1, 'Entrando al proyecto...', () => process.chdir(projectDir));
  step(2, 'Consultando los últimos cambios de Git...', () => git(['fetch', 'origin', branch]));
  step(3, 'Eliminando cambios locales rastreados...', () => git(['reset', '--hard']));
  step(4, 'Eliminando archivos locales no ignorados...', () => git(['clean', '-fd']));
  step(5, 'Cambiando forzosamente a la rama publicada...', () => {
    git(['checkout', '-f', '-B', branch, `origin/${branch}`]);
    git(['reset', '--hard', `origin/${branch}`]);
    git(['clean', '-fd']);
  });
  step(6, 'Verificando credenciales git-crypt...', unlockGitCryptFiles);
  step(7, 'Deteniendo los contenedores actuales...', () => run(process.execPath, ['./scripts/start.js', '-p', '-d']));
  step(8, 'Construyendo y levantando la versión actualizada...', () =>
    run(process.execPath, ['./scripts/start.js', '-p', '-c', client, '-b', '-t', '-u']),
  );
  step(9, 'Verificando que el contenedor esté ejecutándose...', () => {
    const containers = execFileSync('docker', ['ps', '--format', '{{.Names}}'], { encoding: 'utf8' });
    const container = `${client}-prod`;
    if (!containers.split(/\r?\n/).includes(container)) {
      throw new Error(`ERROR: el contenedor ${container} no quedó ejecutándose.`);
    }
    console.log(`      OK: ${container} está ejecutándose.`);
  });

  console.log('\x1b[92m===== ACTUALIZACIÓN COMPLETADA =====\x1b[0m\n');
} catch (error) {
  if (error.status === undefined) console.error(error.message || error);
  process.exit(typeof error.status === 'number' ? error.status : 1);
}
