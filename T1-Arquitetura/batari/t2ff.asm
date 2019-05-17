; move a dot with the joystick by Kirk Israel
	
	processor 6502
	include vcs.h
	org $F000

YPosFromBot = $80;
VisibleMissileLine = $81;

;generic start up stuff...
Start
	SEI	
	CLD  	
	LDX #$FF	
	TXS	
	LDA #0		
ClearMem 
	STA 0,X		
	DEX		
	BNE ClearMem	
	LDA #$00		
	STA COLUBK	;start with black background
	LDA #66
	STA COLUP0
;Setting some variables...
	LDA #80
	STA YPosFromBot	;Initial Y Position

	LDA #$20	
	STA NUSIZ0	;Quad Width


;VSYNC time
MainLoop
	LDA #2
	STA VSYNC	
	STA WSYNC	
	STA WSYNC 	
	STA WSYNC	
	LDA #43	
	STA TIM64T	
	LDA #0
	STA VSYNC 	


;Main Computations; check down, up, left, right
;general idea is to do a BIT compare to see if 
;a certain direction is pressed, and skip the value
;change if so

;
;Not the most effecient code, but gets the job done,
;including diagonal movement
;

; for up and down, we INC or DEC
; the Y Position

	LDA #%00010000	;Down?
	BIT SWCHA 
	BNE SkipMoveDown
	INC YPosFromBot
SkipMoveDown

	LDA #%00100000	;Up?
	BIT SWCHA 
	BNE SkipMoveUp
	DEC YPosFromBot
SkipMoveUp

; for left and right, we're gonna 
; set the horizontal speed, and then do
; a single HMOVE.  We'll use X to hold the
; horizontal speed, then store it in the 
; appropriate register


;assum horiz speed will be zero
	LDX #0	

	LDA #%01000000	;Left?
	BIT SWCHA 
	BNE SkipMoveLeft
	LDX #$10	;a 1 in the left nibble means go left
SkipMoveLeft
	
	LDA #%10000000	;Right?
	BIT SWCHA 
	BNE SkipMoveRight
	LDX #$F0	;a -1 in the left nibble means go right...
SkipMoveRight
			;(in 4 bits, using "two's complement 
			; notation", binary 1111 = decimal -1
			; (which we write there as hex F --
			; confused?))


	STX HMM0	;set the move for missile 0


; while we're at it, change the color of the background
; if the button is pressed (making sure D6 of VBLANK has
; appropriately set above) We'll set the background color
; to the vertical position, since that will be changing 
; a lot but we can still control it.

	LDA INPT4		;read button input
	BMI ButtonNotPressed	;skip if button not pressed
	LDA YPosFromBot		;must be pressed, get YPos
	STA COLUBK		;load into bgcolor
ButtonNotPressed



WaitForVblankEnd
	LDA INTIM	
	BNE WaitForVblankEnd	
	LDY #191 	
	STA WSYNC
	STA VBLANK  	

	STA WSYNC	
	STA HMOVE 	

;main scanline loop...
;
;(this probably ends the "new code" section of today's
; lesson...)


ScanLoop 
	STA WSYNC 	

; here the idea is that VisibleMissileLine
; is zero if the line isn't being drawn now,
; otherwise it's however many lines we have to go

CheckActivateMissile
	CPY YPosFromBot
	BNE SkipActivateMissile
	LDA #8
	STA VisibleMissileLine 
SkipActivateMissile

;turn missile off then see if it's turned on
	LDA #0		
	STA ENAM0
;
;if the VisibleMissileLine is non zero,
;we're drawing it
;
	LDA VisibleMissileLine 
	BEQ FinishMissile
IsMissileOn	
	LDA #2		
	STA ENAM0
	DEC VisibleMissileLine 
FinishMissile


	DEY		
	BNE ScanLoop	

	LDA #2		
	STA WSYNC  	
	STA VBLANK 	
	LDX #30		
OverScanWait
	STA WSYNC
	DEX
	BNE OverScanWait
	JMP  MainLoop      
 
	org $FFFC
	.word Start
	.word Start