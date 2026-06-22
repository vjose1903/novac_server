export function resolveFolderId(environment: NodeJS.ProcessEnv, folderKey: string): string {
  const targetKey = environment.ENV === 'DEV' ? `DEV_${folderKey}` : folderKey;
  return environment[targetKey] || '';
}
