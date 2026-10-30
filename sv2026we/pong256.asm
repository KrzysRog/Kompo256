            icl "../shared/map256"



            org $480

;stałe
pmb         equ $80
pmb256      equ $8000
playerh     equ 10
ballh       equ 6
player0x    equ 200
player1x    equ 100
player2x    equ 150
player3x    equ 50
playermask  equ 7
score_pos   equ 17

;pamięć
playery0    equ $80
playery1    equ playery0+1
ballx       equ playery1+1
bally       equ ballx+1
vecx        equ bally+1
vecy        equ vecx+1
tmp         equ vecy+1
p0pmb       equ tmp+1
p1pmb       equ p0pmb+2


            rol 710
            lda #INTERNAL_0
            ldy #score_pos
            sta (88),y
            iny
            iny
            sta(88),y

;inicjalizuj PMG
            mva #$2a SDMCTL
            mva #player0x HPOSP0
            mva #player3x HPOSP3
            mva #3 GRACTL
            lsr @
            sta GPRIOR

;inicjalizacja piłki
            sta vecx
            sta vecy

reset_ball_position
            lda #100
            sta ballx
            sta bally

begin
;TODO - reset wyniku przy fire
            lda CONSOL
            cmp #7
            beq skip_CONSOL
            pha

;opcja dwóch graczy
            and #2
            tay
            lda playersx,y
            sta HPOSP1
            lda playersx+1,y
            sta HPOSP2

;jeden gracz
            pla
            and #1
            tay
            lda player1_mask,y
            sta player_erase+1
            sta playery1

skip_CONSOL

            sta HITCLR
            lda:cmp:req 20


ldacol      lda M0PL
            beq skip_player_collision
            lda vecx
            eor #$ff
            sta vecx
            inc vecx

skip_player_collision
            lda bally
            ldx vecy
            cmp #PM_2LINE_NORMAL_TOP
            bpl not_in_top
            ldx #1
not_in_top
            cmp #PM_2LINE_NORMAL_BOTTOM
            bmi not_in_bottom
            ldx #$ff
not_in_bottom
            stx vecy

;czyść pociski - TODO - dać to wcześniej, a odbicie i rysowanie zrobić jedno po drugim
            ldy #$80    ;pmb
            sty PMBASE
            lda #0
            ;sta 709
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
            tax
            lda #3
            ;ldx bally
            sta pmb256+PMADR_2LINE_MISSILES,x
            


;ruch poziomy piłki
            ldy #score_pos+2
            lda ballx
            clc
            adc vecx
            sta ballx
            sta HPOSM0
            bpl left_edge_positive
            eor #$ff
            dey
            dey
left_edge_positive
            cmp #PLAYFIELD_LEFT_EDGE_NORMAL
            bpl still_playing
            ;jsr bell
            lda (88),y
            adc #1
            sta (88),y
            jmp reset_ball_position

still_playing
;rysuj paletkę

;TODO - główna pętla po x zamiast y
            ldx #1
player_paddle_loop

;uzupełnij adresy pamięci dla "sta"
            lda player_mem_start,x
            sta cleanlp+2
            sta playerlp+2
            sta playerlp+5

            lda PADDL0,x
            lsr @
            cmp playery0,x
            pha
            beq skip_mem_cleanup_p0

;wyczyść pamięć playern i playern+1
            ldy #0
            lda player_erase,x
;TODO - adresowanie przez zerową
cleanlp     sta pmb256+PMADR_2LINE_PLAYER0,y    ;$8200 -> $00,$82
            ;sta pmb256+PMADR_2LINE_PLAYER1,x
            dey
            bne cleanlp

skip_mem_cleanup_p0
            pla
            sta playery0,x
            tay
            lda #playerh
            sta tmp
            lda #playermask
;TODO - adresowanie przez zerową
playerlp    sta pmb256+PMADR_2LINE_PLAYER0,y    ;$8200 -> $00,$82
            sta pmb256+PMADR_2LINE_PLAYER1,y    ;$8280 -> $80,$82
            iny
            dec tmp
            bpl playerlp

            dex
            bpl player_paddle_loop

            jmp begin

player_mem_start
            dta $82,$83

;pamięć graczy
;PL0 - $8200
;PL1 - $8280
;PL2 - $8300
;PL3 - $8380
player1_mask
            dta playermask,0
playersx
            dta player1x,player2x ;0,0

player_erase    equ playersx+4
            ;dta 0,0