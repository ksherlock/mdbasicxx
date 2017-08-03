

init:
	for i = start to end-1
		read x
		poke i,x
	next i
	return

#asm
	.machine 65c02
	.org 300
	.export start, end
start
	lda #0
	sta $d00d
	rts
end
#end

init2:
#asm
	.machine 65c02
	.org 300
	.poke

	lda #0
	sta $d00d
	rts
#end
	return
