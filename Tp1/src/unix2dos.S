#include <mips/regdef.h>
#include <sys/syscall.h>

#### Funcion traducirFormato ####
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

  # Argumentos
  sw	a0,48($fp) # origen
  sw	a1,52($fp) # destino
  sw	a2,56($fp) # finLinea
  sw	a3,60($fp) # finLineaNueva

  # Cargo el argumento para fgetc(origen)
  lw	a0,48($fp) # Cargo el argumento fgetc
  la	t9,fgetc   # Llamo a fgetc
  jal	ra,t9
  sb	v0,24($fp) 

L1:
  lb	v1,24($fp)
  li	v0,-1
  bne	v1,v0,L2    # c != EOF
  b	fin_traducirFormato

L2:
  lw	v0,56($fp)
  lb	v1,24($fp)
  lb	v0,0(v0)
  bne	v1,v0,L5    # if(c != finLinea[0])
  lw	a0,56($fp)  # Cargo el argumento para strlen(finLinea)    
  la	t9,strlen   
  jal	ra,t9       # Llamo a strlen 
  sltu	v0,v0,2
  bne	v0,zero,L4  # strlen(finLinea) != 0
  lw	a0,48($fp)  # Cargo el argumento para fgetc(origen)
  la	t9,fgetc    
  jal	ra,t9       # Llamo a fgetc 
  sb	v0,25($fp)    
  lw	v0,56($fp) 
  addu	v0,v0,1     
  lb	v1,25($fp)
  lb	v0,0(v0)
  bne	v1,v0,L3    # if(c2 != finLinea[1])
  lw	a0,60($fp)  # Cargo el argumento para fputs(finLineaNueva)
  lw	a1,52($fp)  # Cargo el argumento para fputs(destino)
  la	t9,fputs     
  jal	ra,t9       # Llamo a fputs 
  b	L6

L3:
  lb	v0,24($fp)     
  move	a0,v0       # Cargo el argumento para fputc(c)
  lw	a1,52($fp)  # Cargo el argumento para fputc(destino)
  la	t9,fputc        
  jal	ra,t9	    # Llamo a fputc(c, destino)
  lb	v1,25($fp)
  li	v0,-1
  beq	v1,v0,L6    # if(c2 == EOF)
  lb	v0,25($fp)
  move	a0,v0       # Cargo el argumento para fputc(c2)
  lw	a1,52($fp)  # Cargo el argumento para fputc(destino)
  la	t9,fputc     
  jal	ra,t9       # Llamo fputc(c2, destino)  
  b	L6

L4:
  lw	a0,60($fp)  # Cargo el argumento para fputc(finLineaNueva)
  lw	a1,52($fp)  # Cargo el argumento para fputc(destino)
  la	t9,fputs
  jal	ra,t9       # Llamo a fputc(finLineaNueva, destino)     
  b	L6

L5:
  lb	v0,24($fp)  
  move	a0,v0       # Cargo el argumento para fputc(c)
  lw	a1,52($fp)  # Cargo el argumento para fputc(destino)
  la	t9,fputc 
  jal	ra,t9       # Llamo a fputc(c, destino)

L6:
  lw	a0,48($fp)  # Cargo el argumento para fgetc(origen)
  la	t9,fgetc
  jal	ra,t9       # Llamo a fgetc(origen) 
  sb	v0,24($fp)
  b	L1

fin_traducirFormato:
  move	sp,$fp
  lw	ra,40(sp)
  lw	$fp,36(sp)
  addu sp,sp,48
  jr	ra
.end traducirFormato

#### Funcion parser ####
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

  # Argumentos
  sw 	a0,72($fp)
  sw 	a1,76($fp)
  sw 	a2,80($fp)
  sw 	a3,84($fp)

  # Termino parser
  b	fin_parser

fin_parser:
  move 	sp,$fp
  lw 	ra,64(sp)
  lw 	$fp,60(sp)
  lw 	gp,56(sp)
  addu	sp,sp,72
  jr	ra      
.end parser

#### Main de unix2dos #### 
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
  
  # Argumentos
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
  move	sp,$fp
  lw	ra,32(sp)
  lw	$fp,28(sp)
  addu	sp,sp,40
  jr	ra
.end main

#### CONSTANTES ####
.rdata
  FIN_LINEA: 		.asciiz "\n"
  FIN_LINEA_NUEVO:	.asciiz "\r\n"

