/*
    2) O IMC - Indice de Massa Corporal é um critério da Organização Mundial da Saúde para dar a indicação sobre a condiçãp de peso de uma pessoa adulta.

    Formula do IMC:
    IMC = peso / (altura * altura)

    Elabore um algoritmo que dado o peso e a altura de um adulto mostre sua condição de acordo com a tabela abaixo.

    IMC em adultos Cndição:
    - Abaixo de 18.5 Abaixo do peso;
    - Entre 18.5 e 25 Peso normal;
    - Entre 25 e 30 Acima do peso;    -
    - Entre 30 e 40 Obeso;
    - Acima de 40 Obesidade grave;
*/
const peso = 65;
const altura = 1.70;
const imc = peso / Math.pow(altura, 2);
console.log(imc);


