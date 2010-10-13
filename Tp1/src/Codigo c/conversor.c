#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define EXIT_SUCCESS 0
#define ERROR_READ 1
#define ERROR_WRITE 2
#define ERROR_ARGS 3

int traducirFormato(int argc, char *finLinea, char *finLineaNueva){
    if(argc > 1) return ERROR_ARGS;
    FILE* destino = stdout;
    FILE* origen = stdin;
    int val_escritura = 0;  
    int retorno = EXIT_SUCCESS;
    char c = fgetc(origen);
    while((c != EOF) && !ferror(origen) && (val_escritura != EOF)){        
        if(c == finLinea[0]){
            if(strlen(finLinea) > 1){
                char c2 = fgetc(origen);
                if(!ferror(origen)) {
		  if(c2 == finLinea[1]){
		      val_escritura = fputs(finLineaNueva, destino);
		  }else{
		      val_escritura = fputc(c, destino);
		      if(c2 != EOF && val_escritura != EOF) val_escritura = fputc(c2, destino);
		  }
		}
            }else{
                val_escritura = fputs(finLineaNueva, destino);
            }
        }else{
            val_escritura = fputc(c, destino);
        }
        c = fgetc(origen);
    } 
    if(ferror(origen)) retorno = ERROR_READ;
    if(val_escritura == EOF) retorno = ERROR_WRITE;   
    return retorno;
}
