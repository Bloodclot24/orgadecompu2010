#include <mips/regdef.h>
#include <sys/syscall.h>

	.rdata
FIN_LINEA: 		.asciiz "\r\n"
FIN_LINEA_NUEVO:	.asciiz "\n"
STR_GUION:		.asciiz "-"
OPCIONES:		.asciiz "i:o:"
RT:			.asciiz "rt"
WT:			.asciiz "wt"

EXIT_SUCCESS:		.byte 0
ERROR_ARG:		.byte 1
ERROR_FILE:		.byte 2

error_archivo_origen:	.asciiz "Archivo de origen no existe.\n"
error_getopt_2p:	.asciiz	"Error, se esperaba una ruta despues de la opcion.\n"

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

  	#lw 	a0,40($fp)	#hace falta? ya estan en a0 y a1
  	#lw 	a1,44($fp)
	la 	a2, FIN_LINEA
	la 	a3, FIN_LINEA_NUEVO

	# llamo a la funcion parser
	la	t9, parser
	jal	ra, t9
	b 	fin_main

fin_main:
	move	sp, $fp
	lw	ra, 32(sp)
	lw	$fp, 28(sp)
	lw 	gp, 24(sp)
	addu	sp, sp, 40
	jr	ra
	.end main	



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
	li 	t2, 0		#origen = stdin		
	li 	t3, 1		#destino = stdout
	li	t4, 0		#archivoEntrada
	li	t5, 0		#archivoSalida

	li 	16($fp), 0		#origen = stdin		
	li 	20($fp), 1		#destino = stdout
	li	24($fp), 0		#archivoEntrada
	li	28($fp), 0		#archivoSalida

	b	while_loop

while_loop:	
	la	a0, 72($fp)	#a0 <- argc
	la	a1, 76($fp)	#a1 <- argv
	la	a2, OPCIONES	#a2 <- "i:o:"
	la 	t9, getopt	#llamo a la funcion getopt
	jal	ra, t9
	la 	t0, v0		#leo un caracter de getopt, ???? verificar...
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
	lw	24($fp), v0	#el resultado es archivoEntrada
	lw 	a0, v0 
	la 	a1, STR_GUION
	la	t9, strcmp	#se puede usar strcmp?????
	jal 	ra, t9
	lw	t0, v0		#t0 <- strcmp(archivoEntrada, "-")
	bne	t0, zero, abrir_archivo_entrada 		
	b	while_loop

abrir_archivo_entrada:
	#llamo a fopen	
	lw	a0, 24($fp)
	la	a1, RT
	la	t9, fopen
	jal 	ra, t9
	lw	16($fp), v0	#el resultado es un origen (FILE*) 
	beq	16($fp), zero, error_abrir_archivo_entrada

error_abrir_archivo_entrada:
	#imprimo mensaje de error por stderr
	li	a0, 2		#2 es salida por stderr
	la	a1, error_archivo_origen
	la	t9, fprintf
	jal 	ra, t9	
	#retorno ERROR_FILE y salgo de la funcion
	lw	v0, ERROR_FILE
	b 	fin_parser	
	

caso_getopt_o:
	lw	v0, optarg	#llamo a optarg
	lw	28($fp), v0	#el resultado es archivoSalida
	la	a0, v0
	la 	a1, STR_GUION
	la	t9, strcmp	
	jal 	ra, t9	
	lw	t0, v0		#t0 <- strcmp(archivoSalida, "-")
	bne	t0, zero, abrir_archivo_salida

abrir_archivo_salida:
	lw	a0, 28($fp)
	la	a1, WT
	la	t9, fopen
	jal	ra, t9
	b	while_loop



caso_getopt_2p:		#seria el caso ':'
	li	a0, 2		#2 es salida por stderr
	la	a1, error_getopt_2p
	la	t9, fprintf
	jal 	ra, t9	
	lw	v0, ERROR_ARG	#??
	b	fin_parser


fin_while_loop:
	lw	a0, 16($fp)
	lw	a1, 20($fp)
	la	a2, FIN_LINEA	
	la	a3, FIN_LINEA_NUEVO
	
	#llamo a traducir formato
	
	la	t9, traducirFormato
	jal 	ra, t9

	# cargar valor de retorno en v0
	la 	v0, EXIT_SUCCESS
	
	b	fin_parser

fin_parser:
	move 	sp, $fp
	lw 	ra, 64(sp)
	lw	$fp, 60(sp)
	lw	gp, 58(sp)
	addu	sp, sp, 72
	jr	ra


.text
.align 2
.global traducirFormato
.ent traducirFormato
traducirFormato:
#TODO
.endTraducirFormato
