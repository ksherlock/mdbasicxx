
	gosub init
	gosub init2
	end

init:
	for i = start to end-1
		read x
		poke i,x
	next i
	return

#asm
	.machine 65c02
	.org $300
	.export start, end
start
	lda #0
	sta $d00d
	rts
end
#endasm

init2:
#asm
	.machine 65c02
	.org 300
	.poke

foo
	bcc foo
	bcs bar
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
bar
	rts

#endasm
	return
