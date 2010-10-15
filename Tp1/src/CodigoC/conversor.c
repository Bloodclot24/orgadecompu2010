#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define EXIT_SUCCESS 0
#define ERROR_READ 1
#define ERROR_WRITE 2
#define ERROR_ARGS 3

int conversor(int argc, char *finLinea, char *finLineaNueva){
    if(argc > 1) return ERROR_ARGS;
    int val_escritura = 0;  
    int retorno = EXIT_SUCCESS;
    char c2, c = fgetc(stdin);
    while((c != EOF) && !ferror(stdin) && (val_escritura != EOF)){        
        if(c == finLinea[0]){
            if(strlen(finLinea) > 1){
                c2 = fgetc(stdin);
                if(!ferror(stdin)) {
		  if(c2 == finLinea[1]){
		      val_escritura = fputs(finLineaNueva, stdout);
		  }else{
		      val_escritura = fputc(c, stdout);
		      if(c2 != EOF && val_escritura != EOF) val_escritura = fputc(c2, stdout);
		  }
		}
            }else{
                val_escritura = fputs(finLineaNueva, stdout);
            }
        }else{
            val_escritura = fputc(c, stdout);
        }
        c = fgetc(stdin);
    } 
    if(ferror(stdin)) retorno = ERROR_READ;
    if(val_escritura == EOF) retorno = ERROR_WRITE;   
    return retorno;
}
