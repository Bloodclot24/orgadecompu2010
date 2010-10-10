#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "conversor.c"

#define FIN_LINEA "\n"
#define FIN_LINEA_NUEVA "\r\n"

int main(int argc, char* argv[]) {
  return parser(argc, argv, FIN_LINEA, FIN_LINEA_NUEVA);
}
