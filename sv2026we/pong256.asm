            icl "../shared/map256"



            org $480

;rysuj boisko

;skasuj lewy margines
            lda #0
            sta COLCRS
            lda #23
            sta ROWCRS

            jsr convrt

            ldy #39
            lda #$80

bloop
            sta (88),y
            sta (LOGCOL),y
            dey
            bpl bloop

;inicjalizuj PMG
            mva #$80 PMBASE
            mva #1 GPRIOR
            mva #3 GRACTL
            mva #$2a SDMCTL

            jmp *