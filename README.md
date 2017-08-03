# MD-BASIC++

A pre-processor for MD-BASIC.

## Roadmap:


### Mini Assembler

    #asm
        lda #0
        rts
    #end

will generate appropriate `DATA` or `& POKE` (amperworks)


### More command-line flags

    -O0           -> #pragma optimize 0,2
    -Dvalue[=...] -> #define value[=...]
    -I path       -> set include paths
    
