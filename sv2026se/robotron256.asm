        icl "../shared/map256"

;constants
        player_char     = INT_I
        alien_char      = INT_QUESTION+128
        laser_char      = INT_COLON
        human_char      = INT_A
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
        last_stick0     = $87
        human_pos       = $8f
        alien_pos       = $90
        tmpx            = alien_pos+alien_cnt

        org $480

new_game
;mode 13, narrow        
        lda #13
        jsr osgraph
        lda #[PLAYFIELD_WIDTH_NARROW|ENABLE_DL_DMA]
        sta SDMCTL
        
;set aliens
        ldx #alien_cnt+1        ;alien loop + 1 human
alien_setup
        lda random
        tay
        sta human_pos-1,x
        lda #alien_char
        sta (88),y
        dex
        bne alien_setup
        lda #human_char
        sta (88),y

        lda #player_char
        ldy player_pos
        sta (88),y

game_loop

;-----------------
;player movement
;-----------------
        ldy player_pos   ;Y=player position
        ldx STICK0       ;X=joystick state
        cpx last_stick0
        beq no_player_move   ;if same as last time, no movement
        stx last_stick0    ;save current joystick state
        lda #player_char 
        sta cur_char     ;set current char to player char
        jsr move_char
        lda cur_vector
        beq no_player_move     ;if zero, no movement
        ;!!!!!!! is this check needed? new_pos now updated in move_char
        lda new_pos
        sta player_pos   ;update player position

        lda prev_char        ;check where the player went
        ;cmp #alien_char
        bmi game_over_lose   ;if player moved onto alien, lose, aliens are negitive
        cmp #human_char
        beq game_over_win    ;if player moved onto human, win
/*        
wait0
        lda STICK0
        cmp #15
        bne wait0
        */
no_player_move
;------------------
;shooting
;------------------
        ldy player_pos  ;laser starts at player position
        ldx STICK1
        lda #laser_char
        sta cur_char     ;set current char to laser char
        jsr move_char
        ;!!!!!!!!!!!!check human shot missing
        lda cur_vector
        beq no_shoot     ;if zero, no shooting
        ldy prev_pos     ;get laser start position
        lda #player_char
        sta (88),y      ;restore player char at old position broken by laser
        lda #laser_cnt
        sta laser_timer  ;reset laser timer

laser_loop
        ;jsr wait20
        lda 20
        cmp 20
        beq *-2

        lda new_pos
        sta prev_pos
        jsr move_char_short
        lda prev_char
        cmp #human_char
        beq game_over_lose   ;if laser hit human, lose

        jsr keyclk
        dec laser_timer
        bne laser_loop   ;keep moving laser until timer runs out
        ldy new_pos
        lda #0
        sta (88),y      ;erase laser at last position

no_shoot
        ;jsr wait20
        lda 20
        cmp 20
        beq *-2
        sta colpf3

;----------------
;alien movement
;----------------
        lda #alien_char
        sta cur_char
        lda #alien_cnt-1
        sta tmpx
alien_move_loop
        lda random
        and #$1f
        bne next_alien    ;only move some of the aliens each frame
        ldx tmpx
        ldy alien_pos,x   ;Y=alien position
        lda (88),y        ;char at alien position
        beq next_alien    ;if zero, don't move, alien not there
        lda random
        and #$0f
        tax               ;X=vector index
        jsr move_char

        lda prev_char
        cmp #player_char
        beq game_over_lose   ;if alien moved onto player, lose
        cmp #human_char
        beq game_over_lose   ;if alien moved onto human, lose

        ldx tmpx          ;alien index
        lda new_pos
        sta alien_pos,x   ;update alien position
next_alien
        dec tmpx
        bpl alien_move_loop

        jmp game_loop

game_over_lose
        jsr bell

game_over_win
        lda STRIG0
        bne *-3

        jmp new_game

;---------------------
;char movement
;---------------------
move_char
;x=vector index
;y=position
;cur_char=char to draw
        sty prev_pos    ;save previous position
        sty new_pos     ;in case of no movement, new position is same as previous
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
/*
wait20 
        lda 20
        cmp 20
        beq *-2
        sta colpf3
        rts
*/

vectors
        dta 0,0,0,0,0
        ; 10 14 6
        ; 11 15 7
        ; 9  13 5
        ;   5      6      7   8  9      10     11  12 13   14   15
        dta +1+32, +1-32, +1, 0, -1+32, -1-32, -1, 0, +32, -32
        ;0excluded assuming clean memory
        ;dta 0

        end