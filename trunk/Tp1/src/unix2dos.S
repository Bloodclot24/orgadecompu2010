#include <mips/regdef.h>
#include <sys/syscall.h>

############ CONSTANTES ############
.rdata
  FIN_LINEA: 		.asciiz "\n"
  FIN_LINEA_NUEVA:	.asciiz "\r\n"
  STR_GUION:		.asciiz "-"
  OPCIONES:		.asciiz "i:o:"
  RT:			.asciiz "rt"
  WT:			.asciiz "wt"
  SN:			.asciiz "%s\n"  

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
	
	######## PRUEBA
	
	li	v0,SYS_write       # ver dentro de <sys/syscall.h>.
	li	a0,1               # a0: standard output file descriptor.
	la	a1,CONVERSOR1	
	li	a2,28	 	           # a2: data length 
	syscall
	########################

	# Stack frame
	li	t0,0        
	sw	t0,24($fp)  # origen 
	li 	t0,0	   
	sw	t0,28($fp)  # destino	
	lw	t0,EXIT_SUCCESS
	sw	t0,36($fp)  # retorno
	
        # Verifico la cantidad de argumentos	
	lw	t0,72($fp)
	li	t1,1
	bgt	t0,t1,error_cantidad_argumentos
	
	# Obtengo el primer caracter
	li	v0,SYS_read
	li	a0,1
	la	a1,25($fp)
	li	a2,2
	syscall
	
	b 	fin_conversor

while_loop:
	lb	v1,24($fp)    # sizeof(c) = 1; 1 byte
	li	v0,1
	blt 	v1,v0,loop    # c != EOF
	b	fin_conversor

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
	li	v0,SYS_read	      #syscall read_file(14)
	lw	a0,48($fp)  # Cargo el argumento para fgetc(origen)
	la	a1,25($fp)    # buffer.
	li      a2,1  
	syscall	
	sb	v0,25($fp)    
	lw	v0,56($fp) 
	addu	v0,v0,1     
	lb	v1,25($fp)
	lb	v0,0(v0)
	bne	v1,v0,loop2 # if(c2 != finLinea[1])

	lw	a0,60($fp)  # Cargo el argumento para strlen(finLineaNueva)    
	la	t9,strlen   
	jal	ra,t9
	move	t0, v0		#almaceno momentaneamente la long. de finLineaNueva

	li	v0,SYS_write
	lw	a0,52($fp)	#file descriptor
	lw	a1,60($fp)	#address of output buffer
	move 	a2,t0		#number of characters to write (el strlen anterior)
	syscall

	b	funcion_fgetc

loop2:
	li   	v0,SYS_write         # system call for write to file
	la  	a0,52($fp)
	la   	a1,24($fp)    # address of buffer from which to write
	li   	a2,1          # hardcoded buffer length
	syscall             # write to file
	lb	v1,25($fp)
	li	v0,-1
	beq	v1,v0,funcion_fgetc    # if(c2 == EOF)
	li	v0,SYS_write         # system call for write to file
	la   	a0,52($fp)
	la   	a1,25($fp)    # address of buffer from which to write
	li   	a2,1          # hardcoded buffer length
	syscall             # write to file
	b	funcion_fgetc

funcion_fputs:
	lw	a0,60($fp)  # Cargo el argumento para strlen(finLineaNueva)    
	la	t9,strlen   
	jal	ra,t9
	move	t0,v0		#almaceno momentaneamente la long. de finLineaNueva
	li	v0,SYS_write
	lw	a0,52($fp)
	lw	a1,60($fp)
	move 	a2,t0
	syscall	

	b	funcion_fgetc

funcion_fputc:
	li   	v0,SYS_write         # system call for write to file
	la   	a0,52($fp)
	la   	a1,24($fp)    # address of buffer from which to write
	li   	a2,1          # hardcoded buffer length
	syscall             # write to file

funcion_fgetc:
	li	v0,SYS_read	      #syscall read_file(14)
	lw	a0,48($fp)  # Cargo el argumento para fgetc(origen)
	la	a1,24($fp)    # buffer.
	li	a2,1	      #Cantidad a leer, leemos de a 1
	syscall	
	#sb	v0,24($fp)
	b	while_loop

error_cantidad_argumentos:
	######### PRUEBA
	li	v0,SYS_write
	li	a0,1
	la	a1,CONVERSOR3
	li	a2,28
	syscall

	###########		
	
	lw	t0,ERROR_ARGS
	sw	t0,36($fp)
	b	fin_conversor

fin_conversor:
	######## PRUEBA
	li	v0,SYS_write       # ver dentro de <sys/syscall.h>.
	li	a0,1               # a0: standard output file descriptor.
	la	a1,CONVERSOR2      # caracter a imprimir
	li	a2,28 	           # a2: data length 
	syscall
	########################

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

	######## PRUEBA
	#li	v0,SYS_write       # ver dentro de <sys/syscall.h>.
	#li	a0,1               # a0: standard output file descriptor.
	#la	a1,MAIN            # caracter a imprimir
	#li	a2,28 	           # a2: data length 
	#syscall
	########################

	# Llamo a la funcion parser
	la	t9,conversor
	jal	ra,t9

	######## PRUEBA
	#li	v0,SYS_write # ver dentro de <sys/syscall.h>.
	#li	a0,1         # a0: standard output file descriptor.
	#la	a1,MAIN2       # caracter a imprimir
	#li	a2,28	      # a2: data length (1 bytes).
	#syscall
	########################

	# Liberar stack frame
	move	sp,$fp
	lw	ra,32(sp)
	lw	$fp,28(sp)
	lw 	gp,24(sp)
	addu	sp,sp,40
	jr	ra
.end main	
############ FIN Main ############
