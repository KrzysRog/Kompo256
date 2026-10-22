            icl "../shared/map256"



            org $480

;stałe
pmb         equ $80
pmb256      equ $8000
playerh     equ 10
ballh       equ 6
player0x    equ 200
player1x    equ 100

player3x    equ 50
playermask  equ 7

;pamięć
playery0    equ $80
playery1    equ playery0+1
ballx       equ playery1+1
bally       equ ballx+1
vecx        equ bally+1
vecy        equ vecx+1
gamemode    equ vecy+1
tmp        equ gamemode+1
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
            mva #pmb PMBASE
            mva #1 GPRIOR
            mva #3 GRACTL
            mva #$2a SDMCTL

            mva #player0x HPOSP0
            mva #player1x HPOSP1

            mva #player3x HPOSP3


;na razie stała ściana po lewej stronie player3
            lda #playermask
            ldy #$80
scianalp
            sta pmb256+PMADR_2LINE_PLAYER3,y
            dey
            bpl scianalp

;inicjalizacja piłki

reset_ball_position
            lda #70
            sta ballx
            sta bally
            lda #0
            sta vecx
            lda #1
            sta vecy

            ;sta pmb256+PMADR_2LINE_MISSILES+70


begin
            sta HITCLR
            lda:cmp:req 20


;kolizja z graczami
            lda M0PL
            beq skip_player_collision
            lda vecx
            eor #$ff
            sta vecx
            inc vecx

skip_player_collision
            lda M0PF
            beq skip_field_collision
            lda vecy
            eor #$ff
            sta vecy
            inc vecy

skip_field_collision
;czyść pociski
            ldy #$80
            lda #0
m_cleanup_loop
            sta pmb256+PMADR_2LINE_MISSILES,y
            dey
            bpl m_cleanup_loop

;ruch pionowy piłki
            lda bally
            clc
            adc vecy
            sta bally

;rysuj piłkę
            lda #3
            ldx bally
            sta pmb256+PMADR_2LINE_MISSILES,x

;ruch poziomy piłki
            lda ballx
            clc
            adc vecx
            sta ballx
            sta HPOSM0

;rysuj paletkę
            ldy #0
            lda PADDL0,y
            lsr @
            cmp playery0,y
            pha
            beq skip_mem_cleanup_p0

;wyczyść pamięć player0 i player1
            ldx #0
            lda #0
cleanlp     sta pmb256+PMADR_2LINE_PLAYER0,x
            ;sta pmb256+PMADR_2LINE_PLAYER1,x
            dex
            bne cleanlp

skip_mem_cleanup_p0
            pla
            sta playery0,y
            tax
            ;ldx #100
            lda #playerh
            sta tmp
            lda #playermask
player0lp   sta pmb256+PMADR_2LINE_PLAYER0,x
            sta pmb256+PMADR_2LINE_PLAYER1,x
            inx
            dec tmp
            bpl player0lp

            jmp begin
