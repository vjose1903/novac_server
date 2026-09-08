interface CacheEntry<T> {
  data: T;
  timestamp: number;
}

interface CacheOptions {
  ttl?: number; // Time to live en milisegundos
}

const DEFAULT_TTL = 3600000; // 1 hora por defecto

/**
 * Clase genérica para manejo de cache en memoria
 * Permite cachear cualquier tipo de dato con un TTL configurable
 */
export class MemoryCache<T> {
  private cache: Map<string, CacheEntry<T>> = new Map();
  private ttl: number;

  constructor(options: CacheOptions = {}) {
    this.ttl = options.ttl ?? DEFAULT_TTL;
  }

  /**
   * Obtiene un valor del cache si existe y no ha expirado
   */
  get(key: string): T | null {
    const cached = this.cache.get(key);
    if (!cached) return null;

    if (Date.now() - cached.timestamp >= this.ttl) {
      this.cache.delete(key);
      return null;
    }

    return cached.data;
  }

  /**
   * Guarda un valor en el cache
   */
  set(key: string, data: T): void {
    this.cache.set(key, { data, timestamp: Date.now() });
  }

  /**
   * Verifica si una key existe y no ha expirado
   */
  has(key: string): boolean {
    return this.get(key) !== null;
  }

  /**
   * Elimina una entrada del cache
   */
  delete(key: string): boolean {
    return this.cache.delete(key);
  }

  /**
   * Limpia todo el cache
   */
  clear(): void {
    this.cache.clear();
  }

  /**
   * Obtiene un valor del cache o lo genera si no existe/expiró
   * @param params Objeto con los parámetros:
   *   - key: Clave del cache
   *   - fetcher: Función async que obtiene el dato si no está en cache
   */
  async getOrFetch(params: { key: string; fetcher: () => Promise<T> }): Promise<T> {
    const { key, fetcher } = params;
    
    const cached = this.get(key);
    if (cached !== null) return cached;

    const data = await fetcher();
    this.set(key, data);
    return data;
  }
}

// Instancia singleton para el directorio de clientes DGII
const customerDirectoryCache = new MemoryCache<any[]>({ ttl: 3600000 }); // 1 hora

export { customerDirectoryCache };
