#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define EXIT_SUCCESS 0
#define ERROR_ARG 1
#define ERROR_FILE 2

void traducirFormato(FILE * origen, FILE * destino, char *finLinea, char *finLineaNuevo){
    char c = fgetc(origen);
    while(c != EOF){        
        if(c == finLinea[0]){
            if(strlen(finLinea) > 1){
                char c2 = fgetc(origen);
                if(c2 == finLinea[1]){
                    fputs(finLineaNuevo, destino);
                }else{
                    fputc(c, destino);
                    if(c2 != EOF) fputc(c2, destino);
                }
            }else{
                fputs(finLineaNuevo, destino);
            }
        }else{
            fputc(c, destino);
        }
        c = fgetc(origen);
    }
}


int parser(int argc, char **argv, char *FIN_LINEA, char *FIN_LINEA_NUEVO) {
    FILE* destino = stdout;
    FILE* origen = stdin;
    int c;
    char* archivoEntrada = 0;
    char* archivoSalida = 0;
    while((c = getopt(argc,argv,"i:o:"))!= -1){
    	switch(c){
	  case 'i':
	      archivoEntrada = optarg;
	      if(strcmp(archivoEntrada, "-") != 0)
		origen = fopen(archivoEntrada,"rt");
		if(origen == NULL){
		  fprintf(stderr,"%s\n", "Archivo de origen no existe.");
		  return ERROR_FILE;
		}
	      break;
	  case 'o':
	      archivoSalida = optarg;
	      if(strcmp(archivoSalida, "-") != 0)
		destino = fopen(archivoSalida,"wt");
	      break;	
	  case ':':
	      fprintf(stderr,"Error, se esperaba una ruta despues de la opcion.\n");
	      break; 
	  default:
	    break;
    	}
    }
    
    traducirFormato(origen, destino, FIN_LINEA, FIN_LINEA_NUEVO);
    
    if(archivoEntrada != 0) fclose(origen);
    if(archivoSalida != 0) fclose(destino); 
  
    return EXIT_SUCCESS;
}
