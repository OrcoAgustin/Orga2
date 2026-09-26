#include "../ejs.h"

uint32_t sumarTesoros(Mapa *mapa, uint32_t actual, bool *visitado) {
    // 1. Caso base: índice fuera de rango (ej. 99 o >= n_habitaciones)
    if ((uint64_t)actual >= mapa->n_habitaciones) {
        return 0;
    }
    // 2. Caso base: ya fue visitada
    if (visitado[actual]) {
        return 0;
    }
    // 3. Marcar como visitada para no ciclar ni contar dos veces
    visitado[actual] = true;
    // 4. Obtener puntero a la habitación actual
    Habitacion *hab = &mapa->habitaciones[actual];
    // 5. Si tiene tesoro, inicializar acumulador con su valor; sino en 0
    uint32_t acumulador = 0;
    if (hab->contenido.es_tesoro) {
        acumulador += hab->contenido.valor;
    }
    // 6. Recorrer recursivamente los 4 vecinos (Norte, Sur, Este, Oeste)
    for (int i = 0; i < 4; i++) {
        uint32_t id_vecino = hab->vecinos[i];
        acumulador += sumarTesoros(mapa, id_vecino, visitado);
    }
    return acumulador;
}