#asm
	.org 1000
	.machine 65c02

	bra 1000
	bra 1000
	bra 1032

#endasm

#asm

	.org 1000
	.machine 65c02

	bra x1000
	bra x1000
	bra x1032

x1000	.equ 1000
x1032	.equ 1032
#endasm
