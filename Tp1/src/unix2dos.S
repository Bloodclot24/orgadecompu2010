#include <mips/regdef.h>
#include <sys/syscall.h>

.text
.align 2

########Funcion Parser################
##Compara de acuerdo al flag (strings o enteros), devuelve 0 si el primero
##es mayor al segundo, o 1 en caso contrario

parser:
	subu	sp, sp, 16
	sw	$fp, 12(sp)
	sw	gp, 8(sp)
	move	$fp, sp	
	sw	a0, 16($fp)			#comparando 1
	sw	a1, 20($fp)			#comparando 2
	sw	a2, 24($fp)			#flag



	lw t0, 16($fp)				#t0 <- comparando 1
	lw t1, 20($fp)				#t1 <- comparando 2

	lw	t2, 24($fp)			#t2 <- flag
	beqz	t2, comp_string		#si flag = 0 -> comparar strings
							#sino -> comparar numeros
	
fin_parser:
	move	sp, $fp
	lw	$fp, 12(sp)
	addu	sp, sp, 16
	j ra

#### Main de unix2dos #### 
.global main
.ent main

main:
  subu	sp,sp,40
  sw 	ra,32(sp)
  sw 	$fp,28(sp)
  sw 	gp,24(sp)
  move 	$fp,sp
  sw 	a0,40($fp)
  sw 	a1,44($fp)

  # Cargo los argumentos para llamar a la funcion parser
  lw 	a0,40($fp)
  lw 	a1,44($fp)
  la 	a2,FIN_LINEA
  la 	a3,FIN_LINEA_NUEVO

  # Llamo a la funcion parser
  #la	t9,parser
  #jal	ra,t9

  # Termino el main
  b	fin_main

fin_main:
  move	$sp,$fp
  lw	ra,32(sp)
  lw	$fp,28(sp)
  addu	sp,sp,40
  jr	ra

.end main


#### CONSTANTES ####
.rdata
  FIN_LINEA: 		.asciiz "\n"
  FIN_LINEA_NUEVO:	.asciiz "\r\n"

