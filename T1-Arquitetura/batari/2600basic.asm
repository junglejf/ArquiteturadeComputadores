 processor 6502
 include "vcs.h"
 include "macro.h"
 include "2600basic.h"
 include "2600basic_variable_redefs.h"

 ORG $F000
kernel ;called from drawscreen
; This is a 2-line kernel!
 sta WSYNC
 lda #0
 sta GRP0
 sta GRP1
 sta PF1
 sta PF2
 sta CXCLR
 lda playfieldpos
 sta temp1
 lda player0y ;store these so they can be retrieved later
 sta temp2
 lda player1y
 sta temp3

 lda missile0y
 sta temp5
 lda missile1y
 sta temp6

 lda #0
 sta temp4 ; pointer to PF gfx

 ldx #88 ;scanline counter
 jmp .kerloop

.skipDrawP0
 sleep 7
 jmp .continueP0

.skipDrawP1
 sleep 7
 jmp .continueP1

.kerloop ; enter at cycle 59??
 lda player0height ;3
 dcp player0y ;5
 bcc .skipDrawP0 ;2
 ldy player0y ;3
 lda (player0pointer),y ;5; player0pointer must be selected carefully by the compiler
			; so it doesn't cross a page boundary!

 sta GRP0 ;3
.continueP0
 lda missile0height ;3
 dcp missile0y ;5
 ;c=1 active
 ldy temp4 ;3;playfield counter
; lda #0 ;14
; adc #1 ;16
 rol;2
 rol;2
 sta ENAM0 ;3

 ;missile/ball? 
 lda playfield,y ;4
 sta PF1 ;3
 lda playfield+1,y ;4
 sta PF2 ;3
 lda playfield+3,y ;4
 sta PF1 ; 3 too early?
 lda playfield+2,y;4
 sta PF2 ;3
 
 dec temp1
 beq altkernel
 sleep 2

 lda player1height
 dcp player1y
 bcc .skipDrawP1
 ldy player1y
 lda (player1pointer),y
 sta GRP1
.continueP1

 lda missile1height ;3
 dcp missile1y ;5
 ;c=1 active
 ldy temp4 ;3
; lda #0 ;14
; adc #1 ;16
 rol;2
 rol;2
 sta ENAM1 ;3

 ;missile/ball? 
 lda playfield,y ;4
 sta PF1 ;3
 lda playfield+1,y ;4
 sta PF2 ;3
 lda playfield+3,y ;4
 sta PF1 ; 3 too early?
 lda playfield+2,y;4
 sta PF2 ;3

 sleep 4
goback
 dex
 bne .kerloop

 beq endkernel

.skipDrawaltP1
 sleep 7
 jmp .continuealtP1

altkernel

 sleep 2

 lda player1height
 dcp player1y
 bcc .skipDrawaltP1
 ldy player1y
 lda (player1pointer),y
 sta GRP1
.continuealtP1

 lda missile1height ;3
 dcp missile1y ;5
 ;c=1 active
 ldy temp4 ;3
; lda #0 ;14
; adc #1 ;16
 rol;2
 rol;2
 sta ENAM1 ;3

 lda #0
 sta PF1
 sta PF2

 sleep 3

 ;28 cycles to fix things
 ;minus 11=17

 lda temp4
 clc
 adc #4
 sta temp4
 lda #8
 sta temp1
 sleep 2

 jmp goback

 ;align 256
endkernel
 ; 6 digit score routine
 
                STA WSYNC ;first one, need one more
                LDA #0
                STA GRP0
                STA GRP1
                STA PF0
                STA PF1
                STA PF2
 sta ENAM0
 sta ENAM1
 sta ENABL
 sta WSYNC
 sleep 2
                STA GRP0
                STA GRP1 ; seems to be needed because of vdel

                LDY #7
                STY temp1
        LDA #$03
        STA NUSIZ0
        STA NUSIZ1
        STA VDELP0
        STA VDELP1
        LDA #$F0
        STA HMP0
               LDA scorecolor 
                nop
                STA RESP0
                STA RESP1
                STA COLUP0
                STA COLUP1
;               STA HMCLR
                STA WSYNC; second one
                STA HMOVE

loop2
 ldy  temp1        ;+3  63  189
 lda  (scorepointers),y     ;+5  68  204
 sta  GRP0            ;+3  71  213      D1     --      --     --
 sta  WSYNC           ;go
 lda  (scorepointers+$2),y  ;+5   5   15
 sta  GRP1            ;+3   8   24      D1     D1      D2     --
 lda  (scorepointers+$4),y  ;+5  13   39
 sta  GRP0            ;+3  16   48      D3     D1      D2     D2
 lda  (scorepointers+$6),y  ;+5  21   63
 sta  temp4         ;+3  24   72
 lda  (scorepointers+$8),y  ;+5  29   87
 tax                  ;+2  31   93
 lda  (scorepointers+$A),y  ;+5  36  108
 tay                  ;+2  38  114
 lda  temp4         ;+3  41  123              !
 sta  GRP1            ;+3  44  132      D3     D3      D4     D2!
 stx  GRP0            ;+3  47  141      D5     D3!     D4     D4
 sty  GRP1            ;+3  50  150      D5     D5      D6     D4!
 sta  GRP0            ;+3  53  159      D4*    D5!     D6     D6
 dec  temp1        ;+5  58  174                             !
 bpl  loop2           ;+2  60  180
 
                STA WSYNC       ;JUST ADDED
                LDA #0   
               STA GRP0
                STA GRP1
        STA VDELP0
        STA VDELP1;do we need these
        STA NUSIZ0
        STA NUSIZ1


 lda temp2 ;restore variables that were obliterated by kernel
 sta player0y
 lda temp3
 sta player1y
 lda temp5
 sta missile0y
 lda temp6
 sta missile1y

 lda #43
 sta TIM64T
 LDA #%01000010
 sta WSYNC
 STA VBLANK
 rts ;returns to game

 ;ORG $F100
start
 sei
 cld
 ldx #0
 txa
clearmem
 inx
 txs
 pha
 bne clearmem
 lda #8
 sta playfieldpos
 ldx #11
initscore
 lda #>scoretable
 sta scorepointers,x 
 dex
 lda #<scoretable
 sta scorepointers,x 
 dex
 bpl initscore
 lda #1
 sta CTRLPF
 ora INTIM
 sta rand
 jmp game

; playfield drawing routines
; you get a 32x12 bitmapped display in a single color :)
; 0-31 and 0-11
setuppointers
 sta temp2
 txa
 lsr
 lsr
 lsr ; divide by 8
 sta temp1
 tya
 asl
 asl
 clc
 adc temp1
 tay
 lda temp2
 rts

pfpixel
;x=xvalue, y=yvalue, a=0,1,2
 jsr setuppointers
 jmp plotpoint

pfhline
;x=xvalue, y=yvalue, a=0,1,2, temp3=endx
 jsr setuppointers
 jmp noinc
keepgoing
 inx
 txa
 and #7
 bne noinc
 iny
noinc
 jsr plotpoint
 cpx temp3
 bmi keepgoing
 rts

pfvline
;x=xvalue, y=yvalue, a=0,1,2, temp3=endx
 jsr setuppointers
 sty temp1
 inc temp3
 lda temp3
 asl
 asl
 clc
 adc temp1
 sta temp3
keepgoingy
 jsr plotpoint
 iny
 iny
 iny
 iny
 cpy temp3
 bmi keepgoingy
 rts

plotpoint
 lda temp2
 beq pixelon
 lsr
 bcs pixeloff
 lda playfield,y
 eor setbyte,x
 sta playfield,y
 rts
pixelon
 lda playfield,y
 ora setbyte,x
 sta playfield,y
 rts
pixeloff
 lda playfield,y
 eor #$ff
 and setbyte,x
 sta playfield,y
 rts

pfscroll ;(a=0 left, 1 right, 2 up, 4 down)
 bne notleft
;left
 ldx #48
leftloop
 lda playfield-1,x
 lsr
 rol playfield-2,x
 ror playfield-3,x
 rol playfield-4,x
 ror playfield-1,x
; txa
; sbx #4
 dex
 dex
 dex
 dex
 bne leftloop
 rts

notleft
 lsr
 bcc notright
;right

 ldx #48
rightloop
 lda playfield-4,x
 lsr
 rol playfield-3,x
 ror playfield-2,x
 rol playfield-1,x
 ror playfield-4,x
 txa
 dex
 dex
 dex
 dex
; sbx #4
; bne rightloop
 rts

notright
 lsr
 bcc notup
;up
 dec playfieldpos
 bne noshiftdown 
 lda #8
 sta playfieldpos
 ldx #4
wrapup
 lda playfield-1,x
 sta temp1-1,x
 dex
 bne wrapup

; ldx #0
up2
 lda playfield+4,x
 sta playfield,x
 lda playfield+5,x
 sta playfield+1,x
 lda playfield+6,x
 sta playfield+2,x
 lda playfield+7,x
 sta playfield+3,x

 inx
 inx
 inx
 inx
 cpx #44
 bne up2
 ldx #4
wrapup1
 lda temp1-1,x
 sta playfield+43,x
 dex
 bne wrapup1

 rts

notup
;down
 inc playfieldpos
 lda playfieldpos
 cmp #9
 bne noshiftdown 
 lda #1
 sta playfieldpos
 ldx #4
swapdown
 lda playfield+43,x
 sta temp1-1,x
 dex
 bne swapdown
 ldx #44
down2
 lda playfield-1,x
 sta playfield+3,x
 lda playfield-2,x
 sta playfield+2,x
 lda playfield-3,x
 sta playfield+1,x
 lda playfield-4,x
 sta playfield,x
; txa
; sbx #4
 dex
 dex
 dex
 dex
 bne down2

 ldx #4
swapdown1
 lda temp1-1,x
 sta playfield-1,x
 dex
 bne swapdown1

noshiftdown
 rts
 

setbyte
 .byte $80
 .byte $40
 .byte $20
 .byte $10
 .byte $08
 .byte $04
 .byte $02
 .byte $01
 .byte $01
 .byte $02
 .byte $04
 .byte $08
 .byte $10
 .byte $20
 .byte $40
 .byte $80
 .byte $80
 .byte $40
 .byte $20
 .byte $10
 .byte $08
 .byte $04
 .byte $02
 .byte $01
 .byte $01
 .byte $02
 .byte $04
 .byte $08
 .byte $10
 .byte $20
 .byte $40
 .byte $80

;switch register
switchreset
 lda #1
 bit SWCHB
 rts

switchselect
 lda #2
 bit SWCHB
 rts

switchleftb
 lda #$40
 bit SWCHB
 rts

switchrightb
 lda #$80
 bit SWCHB
 rts

switchbw
 lda #8
 bit SWCHB
 rts

;joyx routines return Z=0 if joystick is pressed that direction, otherwise Z=1.
joy0up
 lda #$10
 bit SWCHA
 rts

joy0down
 lda #$20
 bit SWCHA
 rts 

joy0left
 lda #$40
 bit SWCHA
 rts 

joy0right
 lda #$80
 bit SWCHA
 rts 
 
joy0fire
 lda #$80
 bit INPT4
 rts


horpos
 sec
 sta WSYNC
rept
 sbc #15
 bcs rept
 eor #7
 asl
 asl
 asl
 asl
 sta RESP0,x
 sta HMP0,x
 sta WSYNC
 sta HMOVE
 sleep 24
 sta HMCLR
 rts
 
playerset ;x: 0=p0, 1=p0, 2=m0, 3=m1, 4=bl
; a=horpos
; y=verpos
 jsr horpos 
 sty objecty,x
 rts

randomize
 lda rand
 lsr
 bcc noeor
 eor #$B2
noeor
 sta rand
 rts

scorepointerset
 tax
 and #$0F
 asl
 asl
 asl
 adc #<scoretable
 tay
 txa
 and #$F0
 lsr
 adc #<scoretable
 tax
 rts

drawscreen
overscan
 lda INTIM ;wait for sync
 bne overscan
;do VSYNC
 lda #2
 sta WSYNC
 sta VSYNC
 STA WSYNC
 STA WSYNC
 LDA #0
 STA WSYNC
 STA VSYNC
 sta VBLANK
 lda #37
 sta TIM64T

; position player 0
 lda player0x
 ldx #0
 ldy player0y
 jsr playerset

; position player 1
 lda player1x
 ldx #1
 ldy player1y
 jsr playerset

; position missile 0
 lda missile0x
 ldx #2
 ldy missile0y
 jsr playerset

; position missile 1
 lda missile1x
 ldx #3
 ldy missile1y
 jsr playerset

; position ball
 lda missile1x
 ldx #4
 ldy missile1y
 jsr playerset

;set score pointers
 lda score+2
 jsr scorepointerset
 sty scorepointers+10
 stx scorepointers+8
 lda score+1
 jsr scorepointerset
 sty scorepointers+6
 stx scorepointers+4
 lda score
 jsr scorepointerset
 sty scorepointers+2
 stx scorepointers

vblk
 LDA INTIM
 bne vblk
 jmp kernel

game
