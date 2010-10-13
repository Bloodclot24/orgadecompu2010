#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "conversor.c"

#define FIN_LINEA "\r\n"
#define FIN_LINEA_NUEVA "\n"

int main(int argc, char* argv[]) {
  return traducirFormato(argc,FIN_LINEA, FIN_LINEA_NUEVA);
}
