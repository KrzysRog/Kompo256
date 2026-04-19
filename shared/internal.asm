; ============================================================
; internal.inc — INTERNAL CHARACTER CODES (screen/internal)
; zgodne z Mapping The Atari Appendix 10
; ============================================================

; --- Basic printable characters ---
INT_SPACE      = 0
INT_EXCL       = 1      ; !
INT_QUOTE      = 2      ; "
INT_HASH       = 3      ; #
INT_DOLLAR     = 4      ; $
INT_PERCENT    = 5      ; %
INT_AMP        = 6      ; &
INT_APOST      = 7      ; '
INT_LPAREN     = 8      ; (
INT_RPAREN     = 9      ; )
INT_STAR       = 10     ; *
INT_PLUS       = 11     ; +
INT_COMMA      = 12     ; ,
INT_MINUS      = 13     ; -
INT_DOT        = 14     ; .
INT_SLASH      = 15     ; /

; --- Digits 0–9 ---
INT_0          = 16
INT_1          = 17
INT_2          = 18
INT_3          = 19
INT_4          = 20
INT_5          = 21
INT_6          = 22
INT_7          = 23
INT_8          = 24
INT_9          = 25

; --- Punctuation ---
INT_COLON      = 26     ; :
INT_SEMI       = 27     ; ;
INT_LT         = 28     ; <
INT_EQUAL      = 29     ; =
INT_GT         = 30     ; >
INT_QUESTION   = 31     ; ?

INT_AT         = 32     ; @

; --- Uppercase letters A–Z ---
INT_A          = 33
INT_B          = 34
INT_C          = 35
INT_D          = 36
INT_E          = 37
INT_F          = 38
INT_G          = 39
INT_H          = 40
INT_I          = 41
INT_J          = 42
INT_K          = 43
INT_L          = 44
INT_M          = 45
INT_N          = 46
INT_O          = 47
INT_P          = 48
INT_Q          = 49
INT_R          = 50
INT_S          = 51
INT_T          = 52
INT_U          = 53
INT_V          = 54
INT_W          = 55
INT_X          = 56
INT_Y          = 57
INT_Z          = 58

; --- Brackets and symbols ---
INT_LBRACKET   = 59     ; [
INT_BACKSLASH  = 60     ; \
INT_RBRACKET   = 61     ; ]
INT_CARET      = 62     ; ^
INT_UNDERSCORE = 63     ; _

; --- Control characters (CTRL-A etc.) ---
INT_CTRL_COMMA = 64
INT_CTRL_A     = 65
INT_CTRL_B     = 66
INT_CTRL_C     = 67
INT_CTRL_D     = 68
INT_CTRL_E     = 69
INT_CTRL_F     = 70
INT_CTRL_G     = 71
INT_CTRL_H     = 72
INT_CTRL_I     = 73
INT_CTRL_J     = 74
INT_CTRL_K     = 75
INT_CTRL_L     = 76
INT_CTRL_M     = 77
INT_CTRL_N     = 78
INT_CTRL_O     = 79
INT_CTRL_P     = 80
INT_CTRL_Q     = 81
INT_CTRL_R     = 82
INT_CTRL_S     = 83
INT_CTRL_T     = 84
INT_CTRL_U     = 85
INT_CTRL_V     = 86
INT_CTRL_W     = 87
INT_CTRL_X     = 88
INT_CTRL_Y     = 89
INT_CTRL_Z     = 90

; --- Special keys ---
INT_ESCAPE     = 91
INT_UP         = 92
INT_DOWN       = 93
INT_LEFT       = 94
INT_RIGHT      = 95
INT_CTRL_DOT   = 96

; --- Lowercase letters a–z ---
INT_A_LOWER    = 97
INT_B_LOWER    = 98
INT_C_LOWER    = 99
INT_D_LOWER    = 100
INT_E_LOWER    = 101
INT_F_LOWER    = 102
INT_G_LOWER    = 103
INT_H_LOWER    = 104
INT_I_LOWER    = 105
INT_J_LOWER    = 106
INT_K_LOWER    = 107
INT_L_LOWER    = 108
INT_M_LOWER    = 109
INT_N_LOWER    = 110
INT_O_LOWER    = 111
INT_P_LOWER    = 112
INT_Q_LOWER    = 113
INT_R_LOWER    = 114
INT_S_LOWER    = 115
INT_T_LOWER    = 116
INT_U_LOWER    = 117
INT_V_LOWER    = 118
INT_W_LOWER    = 119
INT_X_LOWER    = 120
INT_Y_LOWER    = 121
INT_Z_LOWER    = 122

; --- More control codes ---
INT_CTRL_SEMI  = 123
INT_124        = 124
INT_CLEAR      = 125
INT_DELETE     = 126
INT_TAB        = 127

; --- Inverse characters = internal + 128 ---
; Możesz użyć:  INT_A + 128  → inverse 'A'
