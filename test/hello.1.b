'
' Example of a .inline code block.  
' all asm code is stored at the end of the basic file.
'

call hello

#asm
	.inline
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
