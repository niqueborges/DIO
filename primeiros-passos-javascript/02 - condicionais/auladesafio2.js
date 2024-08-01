/* Faça um programa para calcular o valor de uma viagem.

Você terá 5 variáveis. Sendo elas:
 1 - Preço do etanol;
 2 - Preço do gasolina;
 3 - O tipo de combustível que está no seu carro;
 4 - Gasto médio de combustível do carro por KM;
 5 - Distância em KM da viagem;

Imprima no console o valor que será gasto para realizar esta viagem. */

const precoEtanol = 3.96;
const precoGasolina = 5.79;
const tipoCombustivel = 'etanol';
const kmPorLitros = 10;
const distanciaEmKm = 100;

const litrosConsumidos = distanciaEmKm / kmPorLitros;

if (tipoCombustivel === 'etanol') {
  const valorGasto = litrosConsumidos * precoEtanol;
  console.log(`O valor gasto para realizar a viagem é de R$ ${valorGasto.toFixed(2)}`);
} else {
  const valorGasto = litrosConsumidos * precoGasolina;
  console.log(`O valor gasto para realizar a viagem é de R$ ${valorGasto.toFixed(2)}`);
}
