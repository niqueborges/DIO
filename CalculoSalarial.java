// Para ler o número de horas trabalhadas e o valor do salário 
// por hora de um funcionário e calcular o salário total do funcionário.

// Para ler e escrever dados em Java, aqui na Dio padronizamos da seguinte forma:
// Para ler dados, utilizamos a classe Scanner, que é uma classe do pacote java.util.
// - new Scanner(System.in): cria um leitor de Entradas, com métodos úteis com prefixo "next";
// - System.out.println(): imprime um texto de Saída (output) e pulando uma linha.

import java.util.Scanner;

public class CalculoSalarial {
    public static void main(String[] args) {
        //Lê os valores de Entrada:
        Scanner scanner = new Scanner(System.in);

        System.out.print("Enter the number of hours worked: ");
        int hoursWorked = scanner.nextInt();

        System.out.print("Enter the hourly wage: ");
        double hourlyWage = scanner.nextDouble();

        double salary = hoursWorked * hourlyWage;

        System.out.println("The calculated salary is: " + salary);

        scanner.close();
    }
}