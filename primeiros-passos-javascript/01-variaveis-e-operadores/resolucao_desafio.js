/*
Faça um programa para calcular o valor de uma viagem.

Você terá 3 variáveis. Sendo elas:
1 - Preço do combustível;
2 - Gasto médio de combustível do carro por KM;
3 - Distânica em KM da viagem;

Imprima no console o valor que será gasto para realizar esta viagem.

*/
const precoCombustivel = 5.79;
const kmPorLitros = 12;
const distanciaEmKm = 100;

const litrosConsumidos = distanciaEmKm / kmPorLitros;
const valorGasto = litrosConsumidos = precoCombustivel;
console.log(valorGasto.toFixed(2));