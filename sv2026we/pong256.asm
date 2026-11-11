            icl "../shared/map256"



            org $480

;stałe
pmb         equ $80
pmb256      equ pmb*$100
playerh     equ 7
playermask  equ playerh
player0x    equ PLAYFIELD_RIGHT_EDGE_NORMAL-12
player3x    equ PLAYFIELD_LEFT_EDGE_NORMAL
player1x    equ player3x+(player0x-player3x)/3
player2x    equ player3x+(player0x-player3x)*2/3
score_pos   equ INTERNAL_0

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
player_erase    equ p1pmb+4 ;nie rozumiem dlaczego p1pmb+2 daje nieprawidłową maskę

            asl 710
game_init
            lda #INTERNAL_0
            ;ldy #score_pos
            ;pozioma pozycja wyniku taka jak kod wewnętrzny "0"
            tay
            sta (88),y
            iny
            iny
            sta (88),y

;inicjalizuj PMG
            mva #$2a SDMCTL
            sta 712
            mva #player3x HPOSP3
            mva #player0x HPOSP0
            mva #3 GRACTL
            lsr @       ;A:=1
            sta GPRIOR

;inicjalizacja piłki - wektor [+1,+1]
            sta vecx
            sta vecy

reset_ball_position
            jsr bell
            lda #100
            sta ballx
            sta bally

gameloop
;reset wyniku przy fire
            lda PTRIG0
            beq game_init

            lda CONSOL
            and #7  ;potrzebny bo zaburza go dźwięk click
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


;czyść pociski
            ldy #$80    ;pmb
            sty PMBASE
            sty p1pmb   ;pół strony offsetu dla player1
            lda #0
m_cleanup_loop
            sta pmb256+PMADR_2LINE_MISSILES,y
            dey
            bpl m_cleanup_loop

;kolizja z paletką gracza
            lda M0PL
            beq skip_player_collision
            lda vecx
            eor #$ff
            sta vecx
            inc vecx
            jsr keyclk

skip_player_collision
            lda bally
            ldx vecy
            cmp #PM_2LINE_NORMAL_TOP
            bpl not_in_top
            ldx #1  ;piłka w dół bo jest za wysoko
not_in_top
            cmp #PM_2LINE_NORMAL_BOTTOM
            bmi not_in_bottom
            ldx #$ff ;piłka w górę
not_in_bottom
            stx vecy

;ruch pionowy piłki
            ;lda bally - A=bally
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
            dey     ;punkt dla tego po lewej, bo piłka wyszła poza prawą krawędź
            dey
left_edge_positive
            cmp #PLAYFIELD_LEFT_EDGE_NORMAL
            bpl still_playing
            lda (88),y
            adc #1
            sta (88),y
            jmp reset_ball_position

still_playing
;pętla paletek
            ldx #1
player_paddle_loop
            txa
            clc
            adc #$82    ;początek pamięci player0 albo player2
            sta p0pmb+1
            sta p1pmb+1

            lda PADDL0,x
            lsr @
            cmp playery0,x
            pha
            beq skip_mem_cleanup_p0

;wyczyść pamięć playern i playern+1 - czyści 255B
            ldy #0
            lda player_erase,x
cleanlp     sta (p0pmb),y    ;$8200 -> $00,$82
            dey
            bne cleanlp

skip_mem_cleanup_p0
            pla
            sta playery0,x
            tay
            lda #playerh
            sta tmp
            ;lda #playermask
playerlp    sta (p0pmb),y    ;$8200 -> $00,$82
            sta (p1pmb),y    ;$8280 -> $80,$82
            iny
            dec tmp
            bpl playerlp

            dex
            bpl player_paddle_loop

            jmp gameloop

;pamięć graczy
;PL0 - $8200
;PL1 - $8280
;PL2 - $8300
;PL3 - $8380
player1_mask
            dta playermask,0
playersx
            dta player1x,player2x ;0,0 - używa dodatkowych zer do schowania paletek, jeśli gra 1 gracz

;player_erase    equ playersx+4
            ;dta 0,0