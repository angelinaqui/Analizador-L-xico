/*
Integrantes: Díaz González Rivas Ángel Iñaqui, Gayosso Rosillo Sebastian Emiliano, 
Perez Delgado Erandy Estefanya y Siliano Haller Rodrigo 
Fecha de elaboración: 15 de septiembre de 2024

Descripción breve:
Este programa es un analizador léxico que utiliza Flex para analizar un archivo de entrada y generar 
una lista de tokens, tabla de símbolos y dos tablas de literales (numéricas y de cadenas). También gestiona los errores léxicos, 
almacenándolos en un archivo separado. El programa maneja identificadores, palabras reservadas, operadores,
constantes literales y caracteres especiales.

Funciones:
- buscarSimbolo: Busca un símbolo en la tabla de símbolos y retorna su posición.
- agregarSimbolo: Agrega un nuevo símbolo a la tabla de símbolos si no existe.
- agregarLiteralNumerico: Agrega un nuevo literal numérico a la tabla de literales numéricas.
- agregarLiteralCadena: Agrega un nuevo literal cadena a la tabla de literales cadenas.
- guardarTablas: Guarda las tablas de símbolos y literales en archivos de texto.
- guardarErrorLexico: Registra un error léxico en el archivo de errores léxicos.
- guardarToken: Guarda los tokens generados en un archivo.
- main: Controla la ejecución principal del programa y abre los archivos de entrada y salida.
*/

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Estructura para almacenar símbolos
typedef struct{
    char nombre[50]; // Nombre del símbolo
    int tipo; // Tipo del símbolo (valor inicial -2)
} Simbolo;

// Estructura para almacenar literales numéricos
typedef struct {
    int posicion; // Posición del literal numérico en la tabla de literales
    char dato[50]; // Valor del literal numérico
} LiteralNumerico;

// Estructura para almacenar literales cadenas
typedef struct {
    int posicion; // Posición del literal cadena en la tabla de literales
    char dato[50]; // Valor del literal cadena
} LiteralCadena;

// Tablas de símbolos, literales numéricos y literales cadenas
Simbolo tablaSimbolos[100];
LiteralNumerico tablaLiteralesNumericos[100];
LiteralCadena tablaLiteralesCadenas[100];
int indexSimbolos = 0; // Contador de símbolos
int indexLiteralesNumericos = 0; // Contador de literales numéricos
int indexLiteralesCadenas = 0; // Contador de literales cadenas

// Archivos de salida para tokens y errores
FILE *tokensFile;
FILE *erroresFile;

// Busca un símbolo en la tabla de símbolos, retorna su índice o -1 si no existe
int buscarSimbolo(const char *nombre) {
    for (int i = 0; i < indexSimbolos; i++) {
        if (strcmp(tablaSimbolos[i].nombre, nombre) == 0) {
            return i;
        }
    }
    return -1;
}

// Agrega un nuevo símbolo a la tabla de símbolos si no está presente
void agregarSimbolo(const char *nombre) {
    if (buscarSimbolo(nombre) == -1) {
        strcpy(tablaSimbolos[indexSimbolos].nombre, nombre); // Copia el nombre del símbolo
        tablaSimbolos[indexSimbolos].tipo = -2; // Inicializa el tipo a -2
        indexSimbolos++; // Incrementa el índice de símbolos
    }
}

// Agrega un nuevo literal numérico a la tabla de literales numéricos
void agregarLiteralNumerico(const char *dato) {
    strcpy(tablaLiteralesNumericos[indexLiteralesNumericos].dato, dato); // Copia el valor literal
    tablaLiteralesNumericos[indexLiteralesNumericos].posicion = indexLiteralesNumericos; // Asigna la posición del literal
    indexLiteralesNumericos++; // Incrementa el índice de literales numéricos
}

// Agrega un nuevo literal cadena a la tabla de literales cadenas
void agregarLiteralCadena(const char *dato) {
    strcpy(tablaLiteralesCadenas[indexLiteralesCadenas].dato, dato); // Copia el valor literal
    tablaLiteralesCadenas[indexLiteralesCadenas].posicion = indexLiteralesCadenas; // Asigna la posición del literal
    indexLiteralesCadenas++; // Incrementa el índice de literales cadenas
}

// Guarda las tablas de símbolos, literales numéricos y literales cadenas en archivos
void guardarTablas() {
    FILE *simbolosFile = fopen("tabla_simbolos.txt", "w");
    if (simbolosFile == NULL) {
        perror("Error al crear el archivo de tabla de simbolos");
        return;
    }
    fprintf(simbolosFile, "Tabla de Simbolos:\n");
    for (int i = 0; i < indexSimbolos; i++) {
        fprintf(simbolosFile, "%d\t%s\n", i, tablaSimbolos[i].nombre); // Guarda símbolos en archivo
    }
    fclose(simbolosFile);

    FILE *literalesNumericosFile = fopen("tabla_literales_numericos.txt", "w");
    if (literalesNumericosFile == NULL) {
        perror("Error al crear el archivo de tabla de literales numéricas");
        return;
    }
    fprintf(literalesNumericosFile, "Tabla de Literales Numéricos:\n");
    for (int i = 0; i < indexLiteralesNumericos; i++) {
        fprintf(literalesNumericosFile, "%d\t%s\n", tablaLiteralesNumericos[i].posicion, tablaLiteralesNumericos[i].dato); // Guarda literales numéricos en archivo
    }
    fclose(literalesNumericosFile);

    FILE *literalesCadenasFile = fopen("tabla_literales_cadenas.txt", "w");
    if (literalesCadenasFile == NULL) {
        perror("Error al crear el archivo de tabla de literales cadenas");
        return;
    }
    fprintf(literalesCadenasFile, "Tabla de Literales Cadenas:\n");
    for (int i = 0; i < indexLiteralesCadenas; i++) {
        fprintf(literalesCadenasFile, "%d\t%s\n", tablaLiteralesCadenas[i].posicion, tablaLiteralesCadenas[i].dato); // Guarda literales cadenas en archivo
    }
    fclose(literalesCadenasFile);
}

// Guarda los errores léxicos en un archivo
void guardarErrorLexico(const char *error) {
    if (erroresFile == NULL) {
        erroresFile = fopen("errores_lexicos.txt", "a");
    }
    if (erroresFile != NULL) {
        fprintf(erroresFile, "Error léxico: %s\n", error); // Guarda el error léxico
    }
}

// Guarda los tokens en el archivo tokens.txt
void guardarToken(int clase, const char *valor) {
    if (tokensFile == NULL) {
        tokensFile = fopen("tokens.txt", "a");
    }
    if (tokensFile != NULL) {
        fprintf(tokensFile, "Token (%d, %s)\n", clase, valor); // Guarda el token
    }
}
%}

%%

[ \t\n]+    {}  // Ignora espacios en blanco

"cadena"    { guardarToken(0, "0"); }  // Token de tipo cadena
"caracter"  { guardarToken(0, "1"); }  // Token de tipo caracter
"else"      { guardarToken(0, "2"); }  // Token para palabra reservada "else"
"entero"    { guardarToken(0, "3"); }  // Token para palabra reservada "entero"
"For"       { guardarToken(0, "4"); }  // Token para palabra reservada "For"
"if"        { guardarToken(0, "5"); }  // Token para palabra reservada "if"
"real"      { guardarToken(0, "6"); }  // Token para palabra reservada "real"
"return"    { guardarToken(0, "7"); }  // Token para palabra reservada "return"
"void"      { guardarToken(0, "8"); }  // Token para palabra reservada "void"
"while"     { guardarToken(0, "9"); }  // Token para palabra reservada "while"

[\+\-\*\/\$] { guardarToken(1, yytext); }

"~"|\+~|\-~|\*~|\/~|\$~ { guardarToken(2, yytext); }

"<"|">"|"=="|"<="|">="|"!="|"^^" { guardarToken(4, yytext); }

"("|")"|"{"|"}"|"["|"]"|","|":"|"()"|"{}"|"[]" { guardarToken(3, yytext); }

[a-zA-Z][a-zA-Z0-9]{0,4}_ {
    agregarSimbolo(yytext); // Agrega identificador a la tabla de símbolos
    int pos = buscarSimbolo(yytext);
    char posStr[10];
    sprintf(posStr, "%d", pos); // Convierte la posición a cadena
    guardarToken(5, posStr);
}

[a-zA-Z][0-9]+ {
    guardarErrorLexico(yytext);
}

-?[0-9]{1,6} {
    agregarLiteralNumerico(yytext); // Agrega el literal numérico a la tabla
    char posStr[10];
    sprintf(posStr, "%d", indexLiteralesNumericos - 1); // Convierte la posición del literal
    guardarToken(6, posStr);
}

[0-9]+\.[0-9]*|\.[0-9]+ {
    agregarLiteralNumerico(yytext);
    char posStr[10];
    sprintf(posStr, "%d", indexLiteralesNumericos - 1);
    guardarToken(7, posStr);
}

\"([^\"']|(\\\")){2,40}\" {
    agregarLiteralCadena(yytext);  // Agrega el literal cadena a la tabla
    char posStr[10];               // Buffer para la posición del literal
    sprintf(posStr, "%d", indexLiteralesCadenas - 1);  // Formatea la posición
    guardarToken(8, posStr);       // Guarda el token de tipo 8 (cadena)
}

'[^']*' {
    agregarLiteralCadena(yytext);  // Agrega el literal de carácter a la tabla
    char posStr[10];               // Buffer para la posición del literal
    sprintf(posStr, "%d", indexLiteralesCadenas - 1);  // Formatea la posición
    guardarToken(9, posStr);       // Guarda el token de tipo 9 (carácter)
}

[a-zA-Z0-9_]{5,} {
    guardarErrorLexico(yytext);
}

. {
    guardarErrorLexico(yytext);
}

%%

// Función yywrap que termina la ejecución del análisis
int yywrap() {
    return 1;
}

// Función principal que controla la ejecución del programa
int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Uso: %s <archivo de entrada>\n", argv[0]);
        return 1;
    }

    // Abre el archivo de entrada
    FILE *file = fopen(argv[1], "r");
    if (!file) {
        perror("Error al abrir el archivo");
        return 1;
    }

    // Inicializa los archivos de tokens y errores léxicos
    yyin = file;
    tokensFile = fopen("tokens.txt", "w");
    erroresFile = fopen("errores_lexicos.txt", "w");

    // Ejecuta el análisis léxico
    yylex();

    // Cierra el archivo de entrada
    fclose(file);

    // Guarda las tablas de símbolos y literales
    guardarTablas();

    // Cierra los archivos de tokens y errores léxicos
    if (tokensFile != NULL) fclose(tokensFile);
    if (erroresFile != NULL) fclose(erroresFile);

    return 0;
}
