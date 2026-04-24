        icl "../shared/map256"

;constants
        player_char     = INTERNAL_UPPER_I
        alien_char      = INTERNAL_QUESTION+128
        alien_flip_mask = %00100000
        laser_char      = INTERNAL_COLON
        human_char      = INTERNAL_UPPER_A
        laser_cnt       = 4
        alien_cnt       = 20

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
        lda #alien_char
alien_setup
        eor #alien_flip_mask    ;every second alien is a static mine
        ldy random
        sty human_pos-1,x       ;update alien pos in the array
        sta (88),y              ;draw alien at pos
        dex
        bne alien_setup         ;use last position for human
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
        lda new_pos
        sta player_pos   ;update player position

        lda prev_char        ;check where the player went
        bmi game_over_lose   ;if player moved onto alien, lose, aliens are negitive
        cmp #human_char
        beq game_over_win    ;if player moved onto human, win

no_player_move
;------------------
;shooting
;------------------

;prepare input for move_char
        mva STICK1 tmpx
        mva player_pos new_pos
        mva #laser_char cur_char
        mva #laser_cnt laser_timer

laser_loop
        lda:cmp:req 20  ;timer wait
        sta COLPF3      ;flashing alien
        ldx tmpx
        cpx #$0f
        beq end_laser_move      ;skip if no jostick move
        ldy new_pos
        jsr move_char
        lda prev_char
        cmp #human_char
        beq game_over_lose   ;if laser hit human, lose
        jsr keyclk           ;laser sound
        ldy player_pos
        lda #player_char
        sta (88),y      ;restore player char at old position broken by laser
        lda new_pos
        sta prev_pos    ;next laser count from new position
        dec laser_timer
        bne laser_loop   ;keep moving laser until timer runs out
        lda #0
        ldy new_pos
        sta (88),y      ;erase laser at last position

end_laser_move
;----------------
;alien movement
;----------------
        lda #alien_char
        sta cur_char
        lda #alien_cnt-1
        sta tmpx
alien_move_loop
        ldx tmpx
        ldy alien_pos,x   ;Y=alien position
        lda (88),y        ;char at alien position
        cmp #alien_char   ;alien type which moves
        bne next_alien    ;if zero, don't move, alien not there
        ldx random
        cpx #$10
        bpl next_alien    ;only move some of the aliens each frame
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
        ldy prev_pos
        lda #0
        sta (88),y      ;erase char at old position
        tya
        clc
        adc cur_vector    ;A=new position
        sta new_pos     ;save new position
        tay             ;Y=current position
no_move
        lda (88),y      ;get char at new position
        sta prev_char   ;save previous char for checking hits
        lda cur_char
        sta (88),y      ;draw char at new position
        rts

vectors
        dta 0,0,0,0,0
        ; 10 14 6
        ; 11 15 7
        ; 9  13 5
        ;   5      6      7   8  9      10     11  12 13   14   15
        dta +1+32, +1-32, +1, 0, -1+32, -1-32, -1, 0, +32, -32
        ;0 excluded assuming clean memory
        ;dta 0

        end