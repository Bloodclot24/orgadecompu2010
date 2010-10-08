#include <mips/regdef.h>
#include <sys/syscall.h>



	.data
fin_linea: 		.asciiz "\r\n"
fin_linea_nuevo:	.asciiz "\n"
str_guion:		.asciiz "-"

exit_success:		.byte 0
error_arg:		.byte 1
error_file:		.byte 2

error_archivo_origen:	.asciiz "Archivo de origen no existe.\n"
error_getopt_2p:	.asciiz	"Error, se esperaba una ruta despues de la opcion.\n"


	.globl main
	.ent main
main:
	subu 	sp, sp, 40	
	sw	ra, 32(sp)
	sw 	$fp, 28(sp)
	sw	gp, 24(sp)	# guardo ra dado que llamo a otra funcion
	move 	$fp, sp

	#argc y argv estan ya en a0 y a1?????
	sw	a0, 12($fp)
	sw	a1, 8($fp)

	la 	a2, fin_linea
	la 	a3, fin_linea_nuevo

	# llamo a la funcion parser
	jal parser

fin_main:
	move	sp, $fp
	lw	ra, 32(sp)
	lw	$fp, 28(sp)
	lw 	gp, 24(sp)
	addu	sp, sp, 40
	jr	ra
	.end main	

parser:
	subu	sp, sp, 48
	sw	ra, 40(sp)
	sw	$fp, 36(sp)
	sw	gp, 32(sp)
	move	$fp, sp

#	lw t2, stdin	#origen
#	lw t3, stdout	#destino

while_loop:	
	la 	t0, getopt	#leo un caracter de getopt, ???? verificar...
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
	lw 	a0, v0 
	la 	a1, str_guion
	la	t9, strcmp	#se puede usar strcmp?????
	jal 	ra, t9
	lw	t0, v0		#t0 <- strcmp(archivoEntrada, "-")
	lw	t1, 0	

	bne	t0, t1, abrir_archivo_entrada 
	b	while_loop

abrir_archivo_entrada:
	



caso_getopt_o:

	b	while_loop
caso_getopt_2p:		#seria el caso ':'
	
	b	while_loop


fin_while_loop:
	lw	a0, t2
	lw	a1, t3
	la	a2, fin_linea	
	la	a3, fin_linea_nuevo
	
	#llamo a traducir formato
	jal traducir_formato


	# cargar valor de retorno en v0
	la 	v0, exit_success


	
	.end parser


traducir_formato:
	

	.end traducirFormato
