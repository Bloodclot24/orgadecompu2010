#include <mips/regdef.h>
#include <sys/syscall.h>

############ CONSTANTES ############
.rdata
  FIN_LINEA: 			.asciiz "\r\n"
  FIN_LINEA_NUEVA:		.asciiz "\n"
  LENGHT_FIN_LINEA_NUEVA:	.word 1	

  # Codigos de retorno
  EXIT_SUCCESS:		.word 0
  ERROR_READ:		.word 1
  ERROR_WRITE:		.word 2
  ERROR_ARGS:		.word 3

############ FIN CONSTANTES ############

############ conversor ############
.text
.align 2
.global conversor
.ent conversor

conversor:
	# Iniciar stack frame
  	.frame	$fp,56,ra
	subu	sp,sp,56
	.cprestore 40
	sw	gp,40(sp)
	sw	$fp,44(sp)
	sw	ra,48(sp)
	move	$fp,sp

	# Argumentos recibidos
	sw	a0,56($fp) # argc
	sw	a1,60($fp) # finLinea
	sw	a2,64($fp) # finLineaNueva
	
	# Stack frame
	li	t0,0
	sw	t0,24($fp)  # val_escritura
	lw	t0,EXIT_SUCCESS
	sw	t0,28($fp)  # retorno
	
        # Verifico la cantidad de argumentos	
	lw	t0,56($fp)
	li	t1,1
	bgt	t0,t1,error_cantidad_argumentos
	
	# Obtengo el primer caracter
	li	v0,SYS_read
	li	a0,0
	la	a1,32($fp)
	li	a2,1
	syscall

while_loop:
	## Verifico errores de lectura
	# Si a3 != 0
	bne	a3,zero,error_lectura

	## Condiciones de loop
	# Verifico c == EOF
	beq	v0,zero,fin_conversor		
	
    	# Verifico ferror(origen)
	blt	v0,zero,error_lectura
	
	# Verifico val_escritura != EOF
	lw	t1,24($fp)
	blt	t1,zero,error_escritura	
	## fin condiciones de loop

	## Verifico si es fin linea
	# c == finLinea[0]
	lw	t1,60($fp)
	lb	t0,32($fp)
	lb	t1,0(t1)
	beq	t0,t1,verifico_si_es_fin_linea
	
	# Escribo caracter
	li	v0,SYS_write
	li	a0,1
	la	a1,32($fp)
	li	a2,1
	syscall	

	# si a3 ( return value ) != 0 es un error
	bne 	a3,zero,error_escritura

	# Guardo val_escritura
	sw	v0,24($fp)

leer_otro_caracter:
	# Leo otro caracter
	li	v0,SYS_read
	li	a0,0
	la	a1,32($fp)
	li	a2,1
	syscall

	b	while_loop

manejo_r_r:	#tengo en 32($fp) \r, 33($fp) \r
	#escribo el 1er \r
	li	v0,SYS_write
	li	a0,1
	la	a1,32($fp)
	li	a2,1
	syscall
	
	b verifico_si_es_fin_linea

manejo_r_eof:
	li	v0,SYS_write
	li	a0,1
	la	a1,32($fp)
	li	a2,1
	syscall

	b fin_conversor

verifico_si_es_fin_linea:
	# Leo el siguiente caracter
	li	v0,SYS_read
	li	a0,0
	la	a1,33($fp)
	li	a2,1	
	syscall

	beq	v0,zero,manejo_r_eof	

	## Verifico errores de lectura
	# Si a3 != 0
	bne	a3,zero,error_lectura
	# Si cantidad de bytes leidos != 1 es un error
	li	t0,1
	bne     v0,t0,error_lectura

	# Si el caracter que sigue completa el
	# fin de linea
	# c2 == finLinea[1]
	lw	t1,60($fp)	
	lb	t0,33($fp)
	lb	t1,1(t1)
	beq	t0,t1,cambiar_fin_linea

	# Si el caracter que sigue es \r (es decir, lei \r\r)
	# c2 == finLinea[0]
	lw	t1,60($fp)	
	lb	t0,33($fp)
	lb	t1,0(t1)
	beq	t0,t1,manejo_r_r
	 
	# Escribo caracter1
	li	v0,SYS_write
	li	a0,1
	la	a1,32($fp)
	li	a2,1
	syscall

	# Guardo val_escritura
	sw	v0,24($fp)
	
	# Verifico error de escritura
	blt	v0,zero,error_escritura

	# Verifico si el caracter2 es eof
	beq    	v0,zero,leer_otro_caracter

	# Escribo caracter2
	li	v0,SYS_write
	li	a0,1
	la	a1,33($fp)
	li	a2,1
	syscall

	# si a3 ( return value ) != 0 es un error
	bne 	a3,zero,error_escritura

	# Guardo val_escritura
	sw	v0,24($fp)
	
	b leer_otro_caracter


cambiar_fin_linea:
	lw	t0,LENGHT_FIN_LINEA_NUEVA

	# Escribo fin de linea dos
	li	v0,SYS_write
	li	a0,1
	lw	a1,64($fp)
	move	a2,t0
	syscall
	
	# si a3 ( return value ) != 0 es un error
	bne 	a3,zero,error_escritura

	# Guardo val_escritura
	sw	v0,24($fp)	

	b	leer_otro_caracter	

error_cantidad_argumentos:
	lw	t0,ERROR_ARGS
	sw	t0,28($fp)
	b	fin_conversor

error_lectura:
	lw	t0,ERROR_READ
	sw	t0,28($fp)
	b	fin_conversor

error_escritura:
	lw	t0,ERROR_WRITE
	sw	t0,28($fp)
	b	fin_conversor

fin_conversor:
	# Valor de retorno
	lw	v0,28($fp)
	
	# Liberar stack frame
	move	sp,$fp
	lw	ra,48(sp)
	lw	$fp,44(sp)
	lw	gp,40(sp)
	addu 	sp,sp,56
	jr	ra
	.end conversor
############ FIN conversor ############

############ Main ############
.text
.align 2
.globl main
.ent main

main:
	# Iniciar stack frame
	.frame  $fp,40,ra	
	subu 	sp,sp,40	
	.cprestore 24
	sw      gp,24(sp)
	sw 	$fp,28(sp)
	sw      ra,32(sp)
	move 	$fp,sp

	# Parametros recibidos
	sw 	a0,40($fp)
	sw 	a1,44($fp)

	# Cargo parametros para parser
  	lw 	a0,40($fp)	
  	la 	a1,FIN_LINEA
	la 	a2,FIN_LINEA_NUEVA

	# Llamo a la funcion parser
	la	t9,conversor
	jal	ra,t9

	# Liberar stack frame
	move	sp,$fp
	lw	ra,32(sp)
	lw	$fp,28(sp)
	lw 	gp,24(sp)
	addu	sp,sp,40
	jr	ra
.end main	
############ FIN Main ############
