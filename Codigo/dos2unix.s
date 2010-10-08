	.file	1 "dos2unix.c"
	.section .mdebug.abi32
	.previous
	.abicalls
	.text
	.align	2
	.globl	traducirFormato
	.ent	traducirFormato
traducirFormato:
	.frame	$fp,48,$ra		# vars= 8, regs= 3/0, args= 16, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	reorder
	subu	$sp,$sp,48
	.cprestore 16
	sw	$ra,40($sp)
	sw	$fp,36($sp)
	sw	$gp,32($sp)
	move	$fp,$sp
	sw	$a0,48($fp)
	sw	$a1,52($fp)
	sw	$a2,56($fp)
	sw	$a3,60($fp)
	lw	$a0,48($fp)
	la	$t9,fgetc
	jal	$ra,$t9
	sb	$v0,24($fp)
$L18:
	lb	$v1,24($fp)
	li	$v0,-1			# 0xffffffffffffffff
	bne	$v1,$v0,$L20
	b	$L17
$L20:
	lw	$v0,56($fp)
	lb	$v1,24($fp)
	lb	$v0,0($v0)
	bne	$v1,$v0,$L21
	lw	$a0,56($fp)
	la	$t9,strlen
	jal	$ra,$t9
	sltu	$v0,$v0,2
	bne	$v0,$zero,$L22
	lw	$a0,48($fp)
	la	$t9,fgetc
	jal	$ra,$t9
	sb	$v0,25($fp)
	lw	$v0,56($fp)
	addu	$v0,$v0,1
	lb	$v1,25($fp)
	lb	$v0,0($v0)
	bne	$v1,$v0,$L23
	lw	$a0,60($fp)
	lw	$a1,52($fp)
	la	$t9,fputs
	jal	$ra,$t9
	b	$L27
$L23:
	lb	$v0,24($fp)
	move	$a0,$v0
	lw	$a1,52($fp)
	la	$t9,fputc
	jal	$ra,$t9
	lb	$v1,25($fp)
	li	$v0,-1			# 0xffffffffffffffff
	beq	$v1,$v0,$L27
	lb	$v0,25($fp)
	move	$a0,$v0
	lw	$a1,52($fp)
	la	$t9,fputc
	jal	$ra,$t9
	b	$L27
$L22:
	lw	$a0,60($fp)
	lw	$a1,52($fp)
	la	$t9,fputs
	jal	$ra,$t9
	b	$L27
$L21:
	lb	$v0,24($fp)
	move	$a0,$v0
	lw	$a1,52($fp)
	la	$t9,fputc
	jal	$ra,$t9
$L27:
	lw	$a0,48($fp)
	la	$t9,fgetc
	jal	$ra,$t9
	sb	$v0,24($fp)
	b	$L18
$L17:
	move	$sp,$fp
	lw	$ra,40($sp)
	lw	$fp,36($sp)
	addu	$sp,$sp,48
	j	$ra
	.end	traducirFormato
	.size	traducirFormato, .-traducirFormato
	.rdata
	.align	2
$LC0:
	.ascii	"i:o:\000"
	.align	2
$LC1:
	.ascii	"-\000"
	.align	2
$LC2:
	.ascii	"rt\000"
	.align	2
$LC3:
	.ascii	"%s\n\000"
	.align	2
$LC4:
	.ascii	"Archivo de origen no existe.\000"
	.align	2
$LC5:
	.ascii	"wt\000"
	.align	2
$LC6:
	.ascii	"Error, se esperaba una ruta despues de la opcion.\n\000"
	.text
	.align	2
	.globl	parser
	.ent	parser
parser:
	.frame	$fp,72,$ra		# vars= 32, regs= 3/0, args= 16, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	reorder
	subu	$sp,$sp,72
	.cprestore 16
	sw	$ra,64($sp)
	sw	$fp,60($sp)
	sw	$gp,56($sp)
	move	$fp,$sp
	sw	$a0,72($fp)
	sw	$a1,76($fp)
	sw	$a2,80($fp)
	sw	$a3,84($fp)
	la	$v0,__sF+88
	sw	$v0,24($fp)
	la	$v0,__sF
	sw	$v0,28($fp)
	sw	$zero,36($fp)
	sw	$zero,40($fp)
$L29:
	lw	$a0,72($fp)
	lw	$a1,76($fp)
	la	$a2,$LC0
	la	$t9,getopt
	jal	$ra,$t9
	sw	$v0,32($fp)
	lw	$v1,32($fp)
	li	$v0,-1			# 0xffffffffffffffff
	bne	$v1,$v0,$L31
	b	$L30
$L31:
	lw	$v0,32($fp)
	sw	$v0,48($fp)
	li	$v0,105			# 0x69
	lw	$v1,48($fp)
	beq	$v1,$v0,$L33
	lw	$v1,48($fp)
	slt	$v0,$v1,106
	beq	$v0,$zero,$L41
	li	$v0,58			# 0x3a
	lw	$v1,48($fp)
	beq	$v1,$v0,$L38
	b	$L29
$L41:
	li	$v0,111			# 0x6f
	lw	$v1,48($fp)
	beq	$v1,$v0,$L36
	b	$L29
$L33:
	lw	$v0,optarg
	sw	$v0,36($fp)
	lw	$a0,36($fp)
	la	$a1,$LC1
	la	$t9,strcmp
	jal	$ra,$t9
	beq	$v0,$zero,$L34
	lw	$a0,36($fp)
	la	$a1,$LC2
	la	$t9,fopen
	jal	$ra,$t9
	sw	$v0,28($fp)
$L34:
	lw	$v0,28($fp)
	bne	$v0,$zero,$L29
	la	$a0,__sF+176
	la	$a1,$LC3
	la	$a2,$LC4
	la	$t9,fprintf
	jal	$ra,$t9
	li	$v0,2			# 0x2
	sw	$v0,44($fp)
	b	$L28
$L36:
	lw	$v0,optarg
	sw	$v0,40($fp)
	lw	$a0,40($fp)
	la	$a1,$LC1
	la	$t9,strcmp
	jal	$ra,$t9
	beq	$v0,$zero,$L29
	lw	$a0,40($fp)
	la	$a1,$LC5
	la	$t9,fopen
	jal	$ra,$t9
	sw	$v0,24($fp)
	b	$L29
$L38:
	la	$a0,__sF+176
	la	$a1,$LC6
	la	$t9,fprintf
	jal	$ra,$t9
	b	$L29
$L30:
	lw	$a0,28($fp)
	lw	$a1,24($fp)
	lw	$a2,80($fp)
	lw	$a3,84($fp)
	la	$t9,traducirFormato
	jal	$ra,$t9
	lw	$v0,36($fp)
	beq	$v0,$zero,$L42
	lw	$a0,28($fp)
	la	$t9,fclose
	jal	$ra,$t9
$L42:
	lw	$v0,40($fp)
	beq	$v0,$zero,$L43
	lw	$a0,24($fp)
	la	$t9,fclose
	jal	$ra,$t9
$L43:
	sw	$zero,44($fp)
$L28:
	lw	$v0,44($fp)
	move	$sp,$fp
	lw	$ra,64($sp)
	lw	$fp,60($sp)
	addu	$sp,$sp,72
	j	$ra
	.end	parser
	.size	parser, .-parser
	.rdata
	.align	2
$LC7:
	.ascii	"\r\n\000"
	.align	2
$LC8:
	.ascii	"\n\000"
	.text
	.align	2
	.globl	main
	.ent	main
main:
	.frame	$fp,40,$ra		# vars= 0, regs= 3/0, args= 16, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	reorder
	subu	$sp,$sp,40
	.cprestore 16
	sw	$ra,32($sp)
	sw	$fp,28($sp)
	sw	$gp,24($sp)
	move	$fp,$sp
	sw	$a0,40($fp)
	sw	$a1,44($fp)
	lw	$a0,40($fp)
	lw	$a1,44($fp)
	la	$a2,$LC7
	la	$a3,$LC8
	la	$t9,parser
	jal	$ra,$t9
	move	$sp,$fp
	lw	$ra,32($sp)
	lw	$fp,28($sp)
	addu	$sp,$sp,40
	j	$ra
	.end	main
	.size	main, .-main
	.ident	"GCC: (GNU) 3.3.3 (NetBSD nb3 20040520)"
