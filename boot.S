.text
.code16
	ljmp $0, $start
	
shutdown:
	movw $0x5307,%ax
	movw $1, %bx
	movw $3, %cx
	int $0x15
	ret

hex:
	.byte 48,49,50,51,52,53,54,55,56,57,65,66,67,68,69,70

DBG_AX:
	.ascii "AX = "
	.byte 0
DBG_BX:
	.ascii "BX = "
	.byte 0
DBG_CX:
	.ascii "CX = "
	.byte 0
DBG_DX:
	.ascii "DX = "
	.byte 0

message:
	.byte 13,10
	.byte 13,10
	.ascii "Welcome to the .... !!!"
	.byte 13,10,0

press_key_message:
	.ascii "Press 'r' for restart, any other key for shutdown"
	.byte 13,10,0


dbg_print_registers:
	push %dx
	push %cx
	push %bx
	push %ax

	movw $DBG_AX, %si
	call print
	pop %ax
	call print_hex16
	call nextline

	movw $DBG_BX, %si
	call print
	pop %ax
	call print_hex16
	call nextline

	movw $DBG_CX, %si
	call print
	pop %ax
	call print_hex16
	call nextline

	movw $DBG_DX, %si
	call print
	pop %ax
	call print_hex16
	call nextline

	ret
	

// todo
printnum:
// todo prnt dx
	mov $1, %ax
	mov $0, %cl
// todo 0
printnumB:
	cmp %dx, %ax
	jg printnumA
	inc %cl
	mov $10, %bl
	mul %bl
	jmp printnumB

pow:
// AX = 10 ^ CL
	mov $1, %ax
	mov $0, %ch
pow_2:
	cmp %cl, %ch
	jz pow_1
	xor %dx, %dx
	mov %cl, %dl
	dec %cl
	mul %dx
	jmp pow_2
pow_1:
	ret


get_digit:
// gets digit %cl from %ax, returns in %al
	//push %ax

	//mov $0, %bl
	//cmp %al, %bl
	// digit 0:
	mov $10, %dl
	div %dl
	mov %ah, %al
	ret


printnumA:
// %cl has the number of decimal numbers
// %ax has 10^(cl+1)
// %dx has to be printed
	 

	//mov %cl, %al
	mov $12, %ax
	call get_digit


	addb $0x30, %al
	call putch
	
	dec %cl
	push %dx
	mov $0, %dl
	cmp %cl, %dl
	pop %dx
	jnz printnumA

	//popw %ax
	// todo pop 16 bit num from stack, write out to buf
	ret 

print:
	lodsb
	orb %al, %al
	jz 1f
	movb $0xe, %ah
	movw $7, %bx
	int $0x10
	jmp print
1:
	ret

putch:
	mov $0xe, %ah
	movw $7, %bx
	int $0x10
	ret

put_hex:
// printx AL hex 
	xor %ebx, %ebx
	mov %al, %bl
	mov $hex, %eax
	movb (%eax, %ebx), %al
	call putch
	ret

print_hex8:
// prints 8-bit hexadecimal number, AL
	push %ax

	/*
	// '0x'
	mov $0x30, %al
	call putch
	mov $0x78, %al
	call putch

	pop %ax
	push %ax
	*/

	mov %al, %dh
	shr %dh
	shr %dh
	shr %dh
	shr %dh
	mov %dh, %al
	call put_hex

	pop %ax
	mov $0xf, %dl
	andb %dl, %al // AL &= 0xf
	call put_hex
	ret

print_hex16:
// prints 16-bit hexadex, AX
	push %ax
	// High byte
	mov %ah, %al
	call print_hex8
	// Low byte
	pop %ax
	call print_hex8
	ret

start:
	cli
	movw $0x9000, %ax
	movw %ax, %ss
	movw $0xffff, %sp
	sti
	
	movw %cs, %ax
	movw %ax, %ds

	movw $message, %si
	call print

	mov $13, %al
	call putch
	mov $10, %al
	call putch

	mov $4, %al
	addb $0x30, %al
	call putch

	mov $2, %al
	addb $0x30, %al
	call putch

	mov $13, %al
	call putch
	mov $10, %al
	call putch


	mov $100, %dx
	call printnum
	call nextline

	mov $11, %al
	call put_hex
	mov $9, %al
	call put_hex

	call nextline

	mov $0x1000, %ax
	mov $0x2387, %bx
	mov $0xdead, %cx
	mov $0xbeef, %dx
	call dbg_print_registers
	
	movw $press_key_message, %si
	call print

	// read key
	movb $0, %ah
	int $0x16
	movb $114, %ah // 114 = 'r'
	cmpb %al, %ah	
	jz 1f	

	// shutdown test
	call shutdown

1:	
	// restart
	ljmp $0xffff, $0
 
nextline:
	mov $13, %al
	call putch
	mov $10, %al
	call putch
	ret

// boot sector designation
.org 510
.byte 0x55, 0xaa
