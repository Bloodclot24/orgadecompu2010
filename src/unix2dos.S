#include <mips/regdef.h>
#include <sys/syscall.h>

############## CONSTANTES ##############
.rdata
  FIN_LINEA: 		.asciiz "\n"
  FIN_LINEA_NUEVA:	.asciiz "\r\n"
  STR_GUION:		.asciiz "-"
  OPCIONES:		.asciiz "i:o:"
  RT:			.asciiz "rt"
  WT:			.asciiz "wt"
  
  # Salidas
  EXIT_SUCCESS:		.byte 0
  ERROR_ARG:		.byte 1
  ERROR_FILE:		.byte 2

####### Funcion traducirFormato #######
.text
.align 2
.global traducirFormato
.ent traducirFormato

traducirFormato:
  .frame $fp,48,ra
  subu	sp,sp,48
  .cprestore 16
  sw	ra,40(sp)
  sw	$fp,36(sp)
  sw	gp,32(sp)
  move	$fp,sp

  # Argumentos recibidos
  sw	a0,48($fp) # origen
  sw	a1,52($fp) # destino
  sw	a2,56($fp) # finLinea
  sw	a3,60($fp) # finLineaNueva

  # Cargo el argumento para fgetc(origen)
  lw	a0,48($fp)    # Cargo el argumento fgetc
  la	t9,fgetc      # Llamo a fgetc
  jal	ra,t9
  sb	v0,24($fp) 

while_loop:
  lb	v1,24($fp)    # sizeof(c) = 1; 1 byte
  li	v0,-1
  bne	v1,v0,loop    # c != EOF
  b	fin_traducirFormato

loop:
  lw	v0,56($fp)
  lb	v1,24($fp)
  lb	v0,0(v0)
  bne	v1,v0,funcion_fputc    # if(c != finLinea[0])
  lw	a0,56($fp)  # Cargo el argumento para strlen(finLinea)    
  la	t9,strlen   
  jal	ra,t9       # Llamo a strlen 
  sltu	v0,v0,2
  bne	v0,zero,funcion_fputs  # strlen(finLinea) != 0
  lw	a0,48($fp)  # Cargo el argumento para fgetc(origen)
  la	t9,fgetc    
  jal	ra,t9       # Llamo a fgetc 
  sb	v0,25($fp)    
  lw	v0,56($fp) 
  addu	v0,v0,1     
  lb	v1,25($fp)
  lb	v0,0(v0)
  bne	v1,v0,loop2 # if(c2 != finLinea[1])
  lw	a0,60($fp)  # Cargo el argumento para fputs(finLineaNueva)
  lw	a1,52($fp)  # Cargo el argumento para fputs(destino)
  la	t9,fputs     
  jal	ra,t9       # Llamo a fputs 
  b	funcion_fgetc

loop2:
  lb	v0,24($fp)     
  move	a0,v0       # Cargo el argumento para fputc(c)
  lw	a1,52($fp)  # Cargo el argumento para fputc(destino)
  la	t9,fputc        
  jal	ra,t9	    # Llamo a fputc(c, destino)
  lb	v1,25($fp)
  li	v0,-1
  beq	v1,v0,funcion_fgetc    # if(c2 == EOF)
  lb	v0,25($fp)
  move	a0,v0       # Cargo el argumento para fputc(c2)
  lw	a1,52($fp)  # Cargo el argumento para fputc(destino)
  la	t9,fputc     
  jal	ra,t9       # Llamo fputc(c2, destino)  
  b	funcion_fgetc

funcion_fputs:
  lw	a0,60($fp)  # Cargo el argumento para fputs(finLineaNueva)
  lw	a1,52($fp)  # Cargo el argumento para fputs(destino)
  la	t9,fputs
  jal	ra,t9       # Llamo a fputs(finLineaNueva, destino)     
  b	funcion_fgetc

funcion_fputc:
  lb	v0,24($fp)  
  move	a0,v0       # Cargo el argumento para fputc(c)
  lw	a1,52($fp)  # Cargo el argumento para fputc(destino)
  la	t9,fputc 
  jal	ra,t9       # Llamo a fputc(c, destino)

funcion_fgetc:
  lw	a0,48($fp)  # Cargo el argumento para fgetc(origen)
  la	t9,fgetc
  jal	ra,t9       # Llamo a fgetc(origen) 
  sb	v0,24($fp)
  b	while_loop

fin_traducirFormato:
  move	sp,$fp
  lw	ra,40(sp)
  lw	$fp,36(sp)
  lw	gp,32(sp)
  addu 	sp,sp,48
  jr	ra
.end traducirFormato

######## Funcion parser ########
.text
.align 2
.global parser
.ent parser

parser:
  .frame $fp,72,ra	
  subu	sp,sp,72
  .cprestore 16
  sw 	ra,64(sp)
  sw 	$fp,60(sp)
  sw 	gp,56(sp)
  move 	$fp,sp

  # Argumentos recibidos
  sw 	a0,72($fp) # argc
  sw 	a1,76($fp) # argv
  sw 	a2,80($fp) # finLinea
  sw 	a3,84($fp) # finLineaNueva

  # TODO: Marceloooooo

fin_parser:
  move 	sp,$fp
  lw 	ra,64(sp)
  lw 	$fp,60(sp)
  lw 	gp,56(sp)
  addu	sp,sp,72
  jr	ra      
.end parser

######## Main de unix2dos ########
.text
.align 2
.global main
.ent main

main:
  .frame $fp,40,ra
  subu	sp,sp,40
  .cprestore 16
  sw 	ra,32(sp)
  sw 	$fp,28(sp)
  sw 	gp,24(sp)
  move 	$fp,sp
  
  # Argumentos recibidos
  sw 	a0,40($fp)
  sw 	a1,44($fp)

  # No hay variables locales

  # Cargo los argumentos para llamar a la funcion parser
  lw 	a0,40($fp)
  lw 	a1,44($fp)
  la 	a2,FIN_LINEA
  la 	a3,FIN_LINEA_NUEVA

  # Llamo a la funcion parser
  #la	t9,parser
  #jal	ra,t9

  # Termino el main
  move	sp,$fp
  lw	ra,32(sp)
  lw	$fp,28(sp)
  lw	gp,24(sp)
  addu	sp,sp,40
  jr	ra
.end main
