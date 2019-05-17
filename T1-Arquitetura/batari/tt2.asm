; yet another moving dot by Kirk Israel
  
  processor 6502
  include vcs.h
  org $F000



YPosFromBot = $80;
VisiblePlayerLine = $81;
PlayerBuffer = $82;
PlayerVertSpeed = $83;
ButtonOnLast = $84
Temp = $85

GravTimer = $86;



;CONSTANTS
FlapStrength = #5;
GravDelay = #5 ;How often does gravity pull 'em down?
MaximumSpeed = #6 

;generic start up stuff...
Start
	SEI	
	CLD	
	TXS	
	LDX #$FF	
	LDA #0			
ClearMem 
	STA 0,X		
	DEX			
	BNE ClearMem		
	LDA #$00			
	STA COLUBK			
	LDA #33
	STA COLUP0




;Some other initialization
    LDA #80
    STA YPosFromBot	;Initial Y Position
    LDA #0
    STA PlayerVertSpeed
    LDA GravDelay
    STA GravTimer


;VSYNC time
MainLoop
	LDA  #2
	STA  VSYNC	
	STA  WSYNC	
	STA  WSYNC	
	STA  WSYNC	
	LDA  #43	
	STA  TIM64T	
	LDA #0			
	STA  VSYNC		



CheckButton
	LDA INPT4
	BMI NoButton

	;Check to see if the button was already down
	LDA ButtonOnLast
	BNE ButtonWasAlreadyDown

	;New Button Pressed Time to Flap!
	LDA PlayerVertSpeed
	SEC
	SBC FlapStrength
	STA PlayerVertSpeed
	
	LDA #1
	STA ButtonOnLast
ButtonWasAlreadyDown
	JMP EndButton
NoButton    ;button wasn't pressed, remember that
	LDA #0
	STA ButtonOnLast
EndButton
;Time to Add Gravity to Speed?

    DEC GravTimer
    BNE DoneWithGravity

    INC PlayerVertSpeed
    LDA GravDelay
    STA GravTimer

DoneWithGravity
;See if we're going too darn fast
    LDA PlayerVertSpeed
    SEC
    SBC MaximumSpeed ; Maximum Speed

    BMI SpeedNotMaxxed ;if speed - maxspeed is positive, we need to slow down
    LDA MaximumSpeed
    STA PlayerVertSpeed

SpeedNotMaxxed
;Subtract the Player's Speed from the Position
;Add the negative of the Player Vert Speed to 0 in A
    LDA #0
    SEC
    SBC PlayerVertSpeed
;Then add the current position
    CLC
    ADC YPosFromBot
    STA YPosFromBot

FinishPositioning
;check if player hit floor
    LDA #10
    CLC
    CMP YPosFromBot
    BCC DoneCheckingHitFloor
;we need a better bounce routine, like reducing the speed?
    LDA #4; 
    STA PlayerVertSpeed
    LDA #10
    STA YPosFromBot

DoneCheckingHitFloor
;check if player hit ceiling
    LDA #180
    CMP YPosFromBot
    BCS DoneCheckingHitCeiling

;we need a better bounce routine, like reducing the speed?
    LDA #2; 
    STA PlayerVertSpeed

    LDA #180
    STA YPosFromBot

DoneCheckingHitCeiling
;assum horiz movement will be zero
    LDX #$00	      
    LDA #$40	      ;Left?
    BIT SWCHA 
    BNE SkipMoveLeft
    LDX #$10	
    LDA %00001000
    STA REFP0

SkipMoveLeft
	LDA #$80	;Right?
	BIT SWCHA 
	BNE SkipMoveRight
	LDX #$F0	
	LDA %00000000
	STA REFP0

SkipMoveRight
	STX HMP0	;set horiz movement for player 0

WaitForVblankEnd
	LDA INTIM	
	BNE WaitForVblankEnd	
	LDY #191		

	STA VBLANK		

	STA WSYNC		
	STA HMOVE		

;main scanline loop...
ScanLoop 
	STA WSYNC	

; here the idea is that VisiblePlayerLine
; is zero if the line isn't being drawn now,
; otherwise it's however many lines we have to go
  LDA PlayerBuffer
  STA GRP0

CheckActivatePlayer
	CPY YPosFromBot
	BNE SkipActivatePlayer
	LDA #8
	STA VisiblePlayerLine 

SkipActivatePlayer

;turn player off then see if it should be on
    LDA #00	      

;
;if the VisiblePlayerLine is non zero,
;we're drawing it
;
	LDX VisiblePlayerLine 
	BEQ FinishPlayer
IsPlayerOn  
	LDA BigHeadGraphic-1,X
	DEC VisiblePlayerLine 
FinishPlayer
	STA PlayerBuffer

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
	JMP MainLoop      
 
 org $FF00
BigHeadGraphic
	.byte %00000000
	;.byte %01111110
	;.byte %11000001
	;.byte %10111111
	;.byte %11111111
	;.byte %11101011
	;.byte %01111110
	;.byte %00111100

	org $FFFC
	.word Start
	.word Start







;	LDA YPosFromBot
;	STA COLUBK	