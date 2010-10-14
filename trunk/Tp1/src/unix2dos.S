#include <mips/regdef.h>
#include <sys/syscall.h>

############ CONSTANTES ############
.rdata
  FIN_LINEA: 		.asciiz "\n"
  FIN_LINEA_NUEVA:	.asciiz "\r\n"

  # Codigos de retorno
  EXIT_SUCCESS:		.word 0
  ERROR_READ:		.word 1
  ERROR_WRITE:		.word 2
  ERROR_ARGS:		.word 3
  
  ######### PRUEBAS ##############
  MAIN:			 .asciiz "En MAIN: Antes del parser.\n"	
  MAIN2:                 .asciiz "En MAIN:  Sali del parser.\n"	
  CONVERSOR1:            .asciiz "En            conversor...\n"
  CONVERSOR2:            .asciiz "Saliendo      conversor...\n"	
  CONVERSOR3:            .asciiz "Error args                \n"		
  CONVERSOR4:		 .asciiz "Verificando errores       \n"	
  CONVERSOR5:            .asciiz "fin linea                 \n"
  CONVERSOR6:            .asciiz "poner fin linea dos       \n"	
  	
  ##################

############ FIN CONSTANTES ############

############ conversor ############
.text
.align 2
.global conversor
.ent conversor

conversor:
	# Iniciar stack frame
  	.frame	$fp,72,ra
	subu	sp,sp,72
	.cprestore 56
	sw	gp,56(sp)
	sw	$fp,60(sp)
	sw	ra,64(sp)
	move	$fp,sp

	# Argumentos recibidos
	sw	a0,72($fp) # argc
	sw	a1,76($fp) # finLinea
	sw	a2,80($fp) # finLineaNueva
	
	# Stack frame
	li	t0,0        
	sw	t0,24($fp)  # origen 
	li 	t0,1	   
	sw	t0,28($fp)  # destino	
	li	t0,0
	sw	t0,32($fp)  # val_escritura
	lw	t0,EXIT_SUCCESS
	sw	t0,36($fp)  # retorno
	
        # Verifico la cantidad de argumentos	
	lw	t0,72($fp)
	li	t1,1
	bgt	t0,t1,error_cantidad_argumentos
	
	# Obtengo el primer caracter
	li	v0,SYS_read
	lw	a0,24($fp)
	la	a1,41($fp)
	li	a2,1
	syscall

while_loop:
	## Condiciones de loop
	# Verifico c == EOF
	beq	v0,zero,fin_conversor		
	
    	# Verifico ferror(origen)
	blt	v0,zero,error_lectura
	
	# Verifico val_escritura != EOF
	lw	t1,32($fp)
	blt	t1,zero,error_escritura	
	## fin condiciones de loop

	## Verifico si es fin linea
	# c == finLinea[0]
	lw	t1,76($fp)
	lb	t0,41($fp)
	lb	t1,0(t1)
	beq	t0,t1,verificar_fin_linea
	
	# Escribo caracter
	li	v0,SYS_write
	lw	a0,28($fp)
	la	a1,41($fp)
	li	a2,1
	syscall	

	# Guardo val_escritura
	sw	v0,32($fp)

leer_otro_caracter:
	# Leo otro caracter
	li	v0,SYS_read
	lw	a0,24($fp)
	la	a1,41($fp)
	li	a2,1
	syscall

	b	while_loop

verificar_fin_linea:
	###################### Strlen provisorio
	li	v0,1
	###################    

	# strlen(finLinea) <=  1
	li	t0,1
	ble	v0,t0,poner_fin_linea_dos




	b 	leer_otro_caracter

poner_fin_linea_dos:
	################ Strlen provisorio
	li	t0,2
        #########################

	# Escribo fin de linea dos
	li	v0,SYS_write
	lw	a0,28($fp)
	lw	a1,80($fp)
	move	a2,t0
	syscall
	
	# Guardo val_escritura
	sw	v0,32($fp)	

	b	leer_otro_caracter	

error_cantidad_argumentos:
	lw	t0,ERROR_ARGS
	sw	t0,36($fp)
	b	fin_conversor

error_lectura:
	lw	t0,ERROR_READ
	sw	t0,36($fp)
	b	fin_conversor

error_escritura:
	lw	t0,ERROR_WRITE
	sw	t0,36($fp)
	b	fin_conversor

fin_conversor:
	# Valor de retorno
	lw	v0,36($fp)
	
	# Liberar stack frame
	move	sp,$fp
	lw	ra,64(sp)
	lw	$fp,60(sp)
	lw	gp,56(sp)
	addu 	sp,sp,72
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
