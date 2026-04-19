        icl "../shared/map256"

;constants
        player_char     = INT_I
        alien_char      = INT_AT+128
        laser_char      = INT_MINUS
        laser_cnt       = 4
        alien_cnt       = 16

;memory locations
        player_pos      = $80
        prev_pos        = $81
        cur_char        = $82
        prev_char       = $83
        new_pos         = $84
        cur_vector      = $85
        laser_timer     = $86
        alien_pos       = $87



        org $480
        
;mode 13, narrow        
        lda #13
        jsr osgraph
        lda #[PLAYFIELD_WIDTH_NARROW|ENABLE_DL_DMA]
        sta SDMCTL
        
;set aliens
        ldx #alien_cnt
alien_setup
        lda random
        tay
        sta alien_pos,x
        lda #alien_char
        sta (88),y
        dex
        bne alien_setup

game_loop

;player movement
        ldy player_pos   ;Y=player position
        ldx STICK0       ;X=joystick state
        lda #player_char 
        sta cur_char     ;set current char to player char - !!!!!!!!!!may be moved to the proc
        jsr move_char
        lda cur_vector
        beq wait0     ;if zero, no movement
        lda new_pos
        sta player_pos   ;update player position
        
wait0
        lda STICK0
        cmp #15
        bne wait0

;shooting
        ldy player_pos  ;laser starts at player position
        ldx STICK1
        lda #laser_char
        sta cur_char     ;set current char to laser char
        jsr move_char
        lda cur_vector
        beq no_shoot     ;if zero, no shooting
        ldy prev_pos     ;get laser start position
        lda #player_char
        sta (88),y      ;restore player char at old position broken by laser
        lda #laser_cnt
        sta laser_timer  ;reset laser timer

laser_loop
        jsr wait20
        lda new_pos
        sta prev_pos
        jsr move_char_short
        dec laser_timer
        bne laser_loop   ;keep moving laser until timer runs out
        ldy new_pos
        lda #0
        sta (88),y      ;erase laser at last position

no_shoot
wait1
        lda STICK1
        cmp #15
        bne wait1


        jsr wait20

        jmp game_loop


;---------------------
move_char
;x=vector index
;y=position
;cur_char=char to draw
        sty prev_pos    ;save previous position
        lda vectors,x   ;get vector
        sta cur_vector  ;save current vector
        beq no_move     ;if zero, no movement
;        lda #0
;        sta (88),y      ;overwrite char at old position with blank
move_char_short
;uses cur_vector, prev_pos
        ldy prev_pos
        lda #0
        sta (88),y      ;erase char at old position
        tya
        clc
        adc cur_vector    ;A=new position
        sta new_pos     ;save new position
        tay             ;Y=current position
        lda (88),y      ;get char at new position
        sta prev_char   ;save previous char for checking hits
        lda cur_char
        sta (88),y      ;draw char at new position
no_move
        rts

wait20 
        lda 20
        cmp 20
        beq *-2
        rts


vectors
        dta 0,0,0,0,0
        ; 10 14 6
        ; 11 15 7
        ; 9  13 5
        ;   5      6      7   8  9      10     11  12 13   14   15
        dta +1+32, +1-32, +1, 0, -1+32, -1-32, -1, 0, +32, -32, 0

        end