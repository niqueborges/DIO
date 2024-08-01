
const numero = 0;
const numDivisivelPor5 = (numero % 5) === 0;

if(numero === 0) {
    console.log('O número é inválido');
} else if (numDivisivelPor5) {
    console.log('Sim, é divisível por 5');
} else {
    console.log('Não, não é divisível por 5');
}