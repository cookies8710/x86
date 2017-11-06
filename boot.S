.text
.code16
	ljmp $0, $start
	
shutdown:
	movw $0x5307,%ax
	movw $1, %bx
	movw $3, %cx
	int $0x15
	ret

message:
	.ascii "Booting FoolingAroundInRealModeOS"
	.byte 13,10,0

press_key_message:
	.ascii "Press 'r' for restart, any other key for shutdown"
	.byte 13,10,0
// todo
printnum:
	popw %ax
	// todo pop 16 bit num from stack, write out to buf
	ret 

print:
	lodsb
	orb %al, %al
	jz 1f
	movb $14, %ah
	movw $7, %bx
	int $0x10
	jmp print
1:
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
 
// boot sector designation
.org 510
.byte 0x55, 0xaa
