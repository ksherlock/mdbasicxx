'
' Example of a .poke code block.  
' this will generate & poke 300, ....
' (which requires amperworks)
'

#asm
	.poke
	.org $300
COUT	.equ $fded

hello	.export

	ldx #0
loop	lda str,x
	beq fin
	jsr COUT
	inx
	bne loop
fin	rts

str	.str "Hello, World",$8d,$00
#endasm

call 300
