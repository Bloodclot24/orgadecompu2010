#include <mips/regdef.h>
#include <sys/syscall.h>

############## CONSTANTES ##############
.rdata
  FIN_LINEA: 		.asciiz "\r\n"
  FIN_LINEA_NUEVA:	.asciiz "\n"
  STR_GUION:		.asciiz "-"
  OPCIONES:		.asciiz "i:o:"
  RT:			.asciiz "rt"
  WT:			.asciiz "wt"
  SN:			.asciiz "%s\n"  

  # Salidas
  EXIT_SUCCESS:		.byte 0
  ERROR_ARG:		.byte 1
  ERROR_FILE:		.byte 2

error_archivo_origen:	.asciiz "Archivo de origen no existe.\n"
error_getopt_2p:	.asciiz	"Error, se esperaba una ruta despues de la opcion.\n"
############## FIN CONSTANTES ##############

.text
.align 2
.global parser
.ent parser

parser:
	.frame  $fp, 72, ra
	subu	sp, sp, 72
	.cprestore 16
	sw	ra, 64(sp)
	sw	$fp, 60(sp)
	sw	gp, 56(sp)
	move	$fp, sp

	sw 	a0, 72($fp)
	sw 	a1, 76($fp)
	sw 	a2, 80($fp)
	sw 	a3, 84($fp)

	# Variables locales
	li 	t0, 0		#origen = stdin		
	li 	t1, 1		#destino = stdout
	li	t2, 0		#int c
	li	t3, 0		#archivoEntrada
	li	t4, 0		#archivoSalida

	sw	t0, 28($fp)	#guardo primero destino y despues origen
	sw	t1, 24($fp)
	sw	t2, 32($fp)
	sw	t3, 36($fp)
	sw	t4, 40($fp)	

	b	while_loop_parser

while_loop_parser:	
	lw	a0, 72($fp)	#a0 <- argc
	lw	a1, 76($fp)	#a1 <- argv
	la	a2, OPCIONES	#a2 <- "i:o:"
	la 	t9, getopt	#llamo a la funcion getopt
	jal	ra, t9
	sw	v0, 32($fp)

	lw	t0, 32($fp)
	li	t1, -1	
	#switch del while	
	beq	t0, t1, fin_while_loop	#si es -1, voy a fin_while_loop
	li	t1, 105 		# 105 es el caracter 'i'
	beq	t0, t1, caso_getopt_i
	li	t1, 111 		# 111 es el caracter 'o'	
	beq	t0, t1, caso_getopt_o
	li 	t1, 58			# 58 es el caracter ':'
	beq	t0, t1, caso_getopt_2p
	#fin del switch

caso_getopt_i:
	lw	v0, optarg	#llamo a optarg
	sw	v0, 36($fp)	#el resultado es archivoEntrada
	lw	a0, 36($fp)
	la 	a1, STR_GUION
	la	t9, strcmp	#se puede usar strcmp?????
	jal 	ra, t9
	move	t0, v0		#t0 <- strcmp(archivoEntrada, "-")
	bne	t0, zero, abrir_archivo_entrada 		
	b	while_loop_parser

abrir_archivo_entrada:
	#llamo a fopen	
	lw	a0, 36($fp)
	la	a1, RT
	la	t9, fopen
	jal 	ra, t9
	sw	v0, 28($fp)	#el resultado es un origen (FILE*) 
	beq	v0, zero, error_abrir_archivo_entrada

error_abrir_archivo_entrada:
	#imprimo mensaje de error por stderr
	li	a0, 2		#2 es salida por stderr
	la	a1, SN
	la	a2, error_archivo_origen
	la	t9, fprintf
	#jal 	ra, t9	
	#retorno ERROR_FILE y salgo de la funcion
	lw	v0, ERROR_FILE
	b 	fin_parser	
	

caso_getopt_o:
	lw	v0, optarg	#llamo a optarg
	sw	v0, 40($fp)		#el resultado es archivoSalida
	lw	a0, 40($fp)
	la 	a1, STR_GUION
	la	t9, strcmp	
	jal 	ra, t9	
	move	t0, v0		#t0 <- strcmp(archivoSalida, "-")
	bne	t0, zero, abrir_archivo_salida

abrir_archivo_salida:
	lw	a0, 40($fp)
	la	a1, WT
	la	t9, fopen
	jal	ra, t9
	sw	v0, 24($fp)
	b	while_loop



caso_getopt_2p:		#seria el caso ':'
	li	a0, 2		#2 es salida por stderr
	la	a1, SN
	la	a2, error_getopt_2p
	la	t9, fprintf
	jal 	ra, t9	
	lw	v0, ERROR_ARG	#??
	b	fin_parser


fin_while_loop:
	la	a0, 28($fp)
	la	a1, 24($fp)
	la	a2, FIN_LINEA	
	la	a3, FIN_LINEA_NUEVA
	
	#llamo a traducir formato
	
	la	t9, traducirFormato
	jal 	ra, t9

	# cargar valor de retorno en v0
	la 	v0, EXIT_SUCCESS
	
	b	fin_parser

#cerrar_archivo_origen:
#	lw	a0, 28($fp)
#	la	t9, fclose
#	jal 	ra, t9
	
#cerrar_archivo_destino:
#	lw	a0, 24($fp)
#	la	t9, fclose
#	jal 	ra, t9

cerrar_archivo_origen: 
    lw     t0, 24($fp) 
    beq   t0, zero, cerrando_archivo_destino 
    lw    a0, 24($fp) 
    la    t9, fclose 
    jal    ra, t9 

cerrar_archivo_destino: 
  lw    t1, 28($fp) 
  beq   t1, zero, fin_parser 
  lw    a0, 28($fp) 
  la    t9, fclose 
  jal     ra, t9

fin_parser:
	lw 	t0, 28($fp)
	bne 	t0, zero, cerrar_archivo_origen

	move 	sp, $fp
	lw 	ra, 64(sp)
	lw	$fp, 60(sp)
	lw	gp, 58(sp)
	addu	sp, sp, 72
	jr	ra

	.end parser

####### Fin parser ########	

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


.text
.align 2
.globl main
.ent main

main:
	.frame  $fp,40,ra
	subu 	sp, sp, 40	
	.cprestore 16
	sw	ra, 32(sp)	# guardo ra dado que llamo a otra funcion (parser)
	sw 	$fp, 28(sp)
	sw	gp, 24(sp)	
	move 	$fp, sp

	sw 	a0, 40($fp)
	sw 	a1, 44($fp)

  	lw 	a0, 40($fp)	
  	lw 	a1, 44($fp)
	la 	a2, FIN_LINEA
	la 	a3, FIN_LINEA_NUEVA

	# llamo a la funcion parser
	la	t9, parser
	jal	ra, t9

	#fin_main
	move	sp, $fp
	lw	ra, 32(sp)
	lw	$fp, 28(sp)
	lw 	gp, 24(sp)
	addu	sp, sp, 40
	jr	ra
.end main	
