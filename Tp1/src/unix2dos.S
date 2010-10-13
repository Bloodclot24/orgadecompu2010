#include <mips/regdef.h>
#include <sys/syscall.h>

########################### CONSTANTES ###########################
.rdata
  FIN_LINEA: 		.asciiz "\n"
  FIN_LINEA_NUEVA:	.asciiz "\r\n"
  STR_GUION:		.asciiz "-"
  OPCIONES:		.asciiz "i:o:"
  RT:			.asciiz "rt"
  WT:			.asciiz "wt"
  SN:			.asciiz "%s\n"  

  # Salidas para stderr
  ERROR_ARCHIVO_ORIGEN: .asciiz "Archivo de origen no existe.\n"   
  ERROR_GETOPT_2P:      .asciiz	"Error, se esperaba una ruta despues de la opcion.\n"

  # Codigos de retorno
  EXIT_SUCCESS:		.byte 0
  ERROR_ARG:		.byte 1
  ERROR_FILE:		.byte 2
  
  
  ######### PRUEBAS ##############
  PRUEBA:                .asciiz "Saliendo           parser.\n"	
  MAIN:			 .asciiz "En MAIN: Antes del parser.\n"	
  MAIN2:                 .asciiz "En MAIN:  Sali del parser.\n"	
  PARSER:                .asciiz "En               Parser...\n"
  LOOP:			 .asciiz "An el while ..............\n"	
  ##################

########################## FIN CONSTANTES ##########################

########################## traducirFormato ##########################
.text
.align 2
.global traducirFormato
.ent traducirFormato

traducirFormato:
  	.frame $fp,48,ra
	subu	sp,sp,48
	.cprestore 32
	sw	gp,32(sp)
	sw	$fp,36(sp)
	sw	ra,40(sp)
	move	$fp,sp

	# Argumentos recibidos
	sw	a0,48($fp) # origen
	sw	a1,52($fp) # destino
	sw	a2,56($fp) # finLinea
	sw	a3,60($fp) # finLineaNueva

	# Cargo el argumento para fgetc(origen)
	li	v0,SYS_read	      #syscall read_file(14)
	lw	a0,48($fp)    # Cargo el argumento fgetc
	la	a1,24($fp)    # buffer.
	li	a2,1  
	li	a2,1	      #Cantidad a leer, leemos de a 1
	syscall

while_loop:
	lb	v1,24($fp)    # sizeof(c) = 1; 1 byte
	li	v0,1
	blt 	v1,v0,loop    # c != EOF
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

fin_traducirFormato:
	move	sp,$fp
	lw	ra,40(sp)
	lw	$fp,36(sp)
	lw	gp,32(sp)
	addu 	sp,sp,48
	jr	ra
	.end traducirFormato
######################## FIN traducirFormato ########################

############################## parser ##############################
.text
.align 2
.global parser
.ent parser

parser:
	# Iniciar stack frame
	.frame  $fp,72,ra	
	subu	sp,sp,72
	.cprestore 56
	sw      gp,56(sp)
	sw      $fp,60(sp)
	sw	ra,64(sp)
	move 	$fp,sp

	# Parametros recibidos
	sw 	a0,72($fp)
	sw 	a1,76($fp)
	sw 	a2,80($fp)
	sw 	a3,84($fp)

	# Variables locales
	la 	t0,0		#FILE* origen = stdin		
	la 	t1,1		#FILE* destino = stdout
	li	t2,0		#int c
	li	t3,0		#char*archivoEntrada
	li	t4,0		#char*archivoSalida

	sw	t0,24($fp)
	sw	t1,28($fp)
	sw	t2,32($fp)
	sw	t3,36($fp)
	sw	t4,40($fp)

	######PRUEBA
	li	v0,SYS_write # ver dentro de <sys/syscall.h>.
	li	a0,1         # a0: standard output file descriptor.
	la	a1,PARSER       # caracter a imprimir
	li	a2,28	      # a2: data length (1 bytes).
	syscall	
	###############	
  
	b	while_loop_parser

caso_getopt_i:
	lw	v0,optarg	#llamo a optarg
	sw	v0,36($fp)	#el resultado es archivoEntrada
	lw	a0,36($fp)
	la 	a1,STR_GUION
	la	t9,strcmp
	jal 	ra,t9
	bne	v0,zero, abrir_archivo_entrada 		
	b	while_loop_parser

error_abrir_archivo_entrada:
	#imprimo mensaje de error por stderr
	li	v0,SYS_write       # ver dentro de <sys/syscall.h>.
	li	a0,2               # stderr
	la	a1,ERROR_ARCHIVO_ORIGEN # mensaje error
	li	a2,30	            # data length
	syscall
	#retorno ERROR_FILE y salgo de la funcion
	lw	v0, ERROR_FILE
	b 	fin_parser	

abrir_archivo_entrada:
	li 	v0,SYS_open	#syscall open_file
	lw	a0,36($fp)
	la	a1,0 		#abro para lectura, flag 0:read
	la	a2,0 		#el modo es ignorado
	syscall
	sw	v0,24($fp)	#el resultado es un origen (FILE*) 
	blt	v0,zero,error_abrir_archivo_entrada
	b while_loop_parser

caso_getopt_o:
	lw	v0,optarg	#llamo a optarg
	sw	v0,40($fp)		#el resultado es archivoSalida
	lw	a0,40($fp)
	la 	a1,STR_GUION
	la	t9,strcmp	######### TODO COPIAR EL STRCMP DEL GRUPO!!!!
	jal 	ra,t9	
	bne	v0,zero, abrir_archivo_salida 
	b while_loop_parser

abrir_archivo_salida:
	li	v0,SYS_open		#llamo a open_file
	lw	a0,40($fp)
	la	a1,1		#flags 	(0 read, 1 write)
	li	a2,0		#mode
	syscall
	sw	v0, 28($fp)
	b	while_loop_parser

caso_getopt_2p:		#seria el caso ':'
	li	v0,SYS_write       # ver dentro de <sys/syscall.h>.
	li	a0,2               # stderr
	la	a1,ERROR_GETOPT_2P # mensaje error
	li	a2,51	            # data length
	syscall
	b	fin_parser

while_loop_parser:	
	############ PRUEBA
	li	v0,SYS_write # ver dentro de <sys/syscall.h>.
	li	a0,1         # a0: standard output file descriptor.
	la	a1,LOOP       # caracter a imprimir
	li	a2,28	      # a2: data length (1 bytes).
	syscall
	####################

	lw	a0,72($fp)	#a0 <- argc
	lw	a1,76($fp)	#a1 <- argv
	la	a2,OPCIONES	#a2 <- "i:o:"
	la 	t9,getopt	#llamo a la funcion getopt
	jal	ra,t9
	sw	v0,32($fp)

	########## PRUEBA
	li	v0,SYS_write
	li	a0,1
	lw	a1,32($fp)
	li	a2,5
	syscall
	####################

	lw	t0,32($fp)
	li	t1,-1	
	# Switch del while	
	beq	t0,t1,fin_while_loop	#si es -1, voy a fin_while_loop
	li	t1,105 		# 105 es el caracter 'i'
	beq	t0,t1,caso_getopt_i
	li	t1,111 		# 111 es el caracter 'o'	
	beq	t0,t1,caso_getopt_o
	li 	t1,58			# 58 es el caracter ':'
	beq	t0,t1,caso_getopt_2p

fin_while_loop:
	# Cargo argumentos para traducirFormato
	la	a0,24($fp)
	la	a1,28($fp)
	la	a2,FIN_LINEA	
	la	a3,FIN_LINEA_NUEVA
	
	# Llamo a traducir formato
	#la	t9,traducirFormato
	#jal 	ra,t9

	# Cargo valor de retorno en v0
	la 	v0,EXIT_SUCCESS
	
	b	fin_parser

cerrar_archivo_origen: 
    li    	v0,SYS_close
    lw		t0,24($fp) 
    beq   	t0,zero,cerrar_archivo_destino 
    lw    	a0,24($fp) 
    syscall

cerrar_archivo_destino: 
    li		v0,SYS_close	#16 es close	  
    lw    	t1,28($fp) 
    blt   	t1,zero, fin_parser 
    lw    	a0,28($fp) 
    syscall			

fin_parser:
 	######## PRUEBA
	li	v0,SYS_write # ver dentro de <sys/syscall.h>.
	li	a0,1         # a0: standard output file descriptor.
	la	a1,PRUEBA      # caracter a imprimir
	li	a2,28	      # a2: data length (1 bytes).
	syscall
        ############

	# Cierro archivos
	lw 	t0,24($fp)
	blt 	t0,zero, cerrar_archivo_origen

	# Liberar stack frame
	move 	sp,$fp
	lw 	ra,64(sp)
	lw	$fp,60(sp)
	lw	gp,56(sp)
	addu	sp,sp,72
	j	ra
	.end parser
############################# FIN parser #############################

################################ Main ################################
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
  	lw 	a1,44($fp)
	la 	a2,FIN_LINEA
	la 	a3,FIN_LINEA_NUEVA

	######## PRUEBA
	li	v0,SYS_write       # ver dentro de <sys/syscall.h>.
	li	a0,1               # a0: standard output file descriptor.
	la	a1,MAIN            # caracter a imprimir
	li	a2,28 	           # a2: data length 
	syscall
	########################

	# Llamo a la funcion parser
	la	t9,parser
	jal	ra,t9

	######## PRUEBA
	li	v0,SYS_write # ver dentro de <sys/syscall.h>.
	li	a0,1         # a0: standard output file descriptor.
	la	a1,MAIN2       # caracter a imprimir
	li	a2,28	      # a2: data length (1 bytes).
	syscall
	########################

	# Liberar stack frame
	move	sp,$fp
	lw	ra,32(sp)
	lw	$fp,28(sp)
	lw 	gp,24(sp)
	addu	sp,sp,40
	jr	ra
.end main	
############################## FIN Main ##############################
