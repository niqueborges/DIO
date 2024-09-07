// Faça um programa que calcule e impriima o sal´rio a ser transferido para um funcionário.

// Para ler e escrever dados em Java, aqui na Dio padronizamos da seguinte forma:
// Para ler dados, utilizamos a classe Scanner, que é uma classe do pacote java.util.
// - new Scanner(System.in): cria um leitor de Entradas, com métodos úteis com prefixo "next";
// - System.out.println(): imprime um texto de Saída (output) e pulando uma linha.

import java.util.Scanner;

public class CalculoSalarial {
    public static void main(String[] args) {
        try ( //Lê os valores de Entrada:
                Scanner leitorDeEntradas = new Scanner(System.in)) {
            float ValorSalario  = leitorDeEntradas.nextFloat(); // Lê o salário do funcionário
            float valorbeneficios = leitorDeEntradas.nextFloat(); // Lê o valor dos benefícios do funcionário
            
            float valorImposto;
            if (ValorSalario >= 0 && ValorSalario <= 1100) {
                valorImposto = 0.05f * ValorSalario; // 5% do salário
            } else if (ValorSalario >= 1101 && ValorSalario <= 2500) {
                valorImposto = 0.10f * ValorSalario; // 10% do salário
            } else {
                valorImposto = 0.15f * ValorSalario; // 15% do salário
            }
        }
           
            // Calcula e imprime a Saída (com duas casas decimais):
            float saída = ValorSalario - valorImposto + valorbeneficios;
            System.out.printf("O salário líquido é de R$ %.2f\n", saída);
        }

    }