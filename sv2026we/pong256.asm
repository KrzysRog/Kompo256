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
gamemode    equ vecy+1
tmp        equ gamemode+1
;rysuj boisko

;TODO
            ;lda #0
            ;sta COLCRS
            ;lda #23
            ;sta ROWCRS

            ;jsr convrt
            rol 710
            ;ldy #39
            lda #INTERNAL_0
            ldy #score_pos
            sta (88),y
            iny
            iny
            sta(88),y
            ;lda #pmb

;bloop
            ;sta (88),y
            ;sta (LOGCOL),y
            ;sta $9c40-1+24*40-39,y
            ;dey
            ;bpl bloop

;inicjalizuj PMG
            ;sta PMBASE
            ;mva #1 GPRIOR
            mva #$2a SDMCTL
            mva #player0x HPOSP0
            ;mva #player1x HPOSP1

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

            ;sta pmb256+PMADR_2LINE_MISSILES+70


begin
            lda CONSOL
            cmp #7
            beq skip_CONSOL
            pha
            ;sta gamemode
;opcja dwóch graczy
            and #2
            tay
            lda playersx,y
            sta HPOSP1
            lda playersx+1,y
            sta HPOSP2
            ;lda #0

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


;kolizja z graczami
            ;ldy #1
            ;lda #4
            ;sta ldacol+1
ldacol      lda M0PL
            beq skip_player_collision
            lda vecx
            eor #$ff
            sta vecx
            inc vecx
            ;asl ldacol+1
            ;dey
            ;bpl ldacol

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
            ;cmp #PLAYFIELD_RIGHT_EDGE_NORMAL
            ;bpl still_playing
            ;jsr bell
            ;jmp reset_ball_position

;check_right_edge
            ;cmp #PLAYFIELD_RIGHT_EDGE_NORMAL
            ;bmi still_playing
            
            ;jsr bell
            ;jmp reset_ball_position

still_playing
;rysuj paletkę

            ldy #1
player_paddle_loop

;uzupełnij adresy pamięci dla "sta"
            lda player_mem_start,y
            sta cleanlp+2
            sta playerlp+2
            sta playerlp+5

            lda PADDL0,y
            lsr @
            cmp playery0,y
            pha
            beq skip_mem_cleanup_p0

;wyczyść pamięć playern i playern+1
            ldx #0
            lda player_erase,y
cleanlp     sta pmb256+PMADR_2LINE_PLAYER0,x    ;$8200 -> $00,$82
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
playerlp    sta pmb256+PMADR_2LINE_PLAYER0,x    ;$8200 -> $00,$82
            sta pmb256+PMADR_2LINE_PLAYER1,x    ;$8280 -> $80,$82
            inx
            dec tmp
            bpl playerlp

            dey
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