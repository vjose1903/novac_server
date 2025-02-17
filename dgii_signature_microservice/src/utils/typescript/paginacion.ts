export function agruparArticulosPorPagina(articulos: any[], itemsPorPagina: number): any[][] {
    const resultado: any[][] = [];

    for (let i = 0; i < articulos.length; i += itemsPorPagina) {
        const grupo = articulos.slice(i, i + itemsPorPagina);
        resultado.push(grupo);
    }

    return resultado;
}