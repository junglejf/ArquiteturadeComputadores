; '2600 for Newbies
; Session 13 - Playfield





                processor 6502

                include "vcs.h"



                SEG

                ORG $F000



;Inicio



   ; Clear RAM and all TIA registers



                ;ldx #0 

                ;lda #0 

;Clear           sta 0,x 

                ;inx 

                ;bne Clear



Principal



   ; Start of new frame

   ; Start of vertical blank processing



                lda #0

                sta VBLANK



                lda #2

                sta VSYNC



                sta WSYNC

                sta WSYNC

                sta WSYNC               ; 3 scanlines of VSYNC signal



                lda #0

                sta VSYNC           





       ;------------------------------------------------

       ; 37 scanlines of vertical blank...

            

                ldx #0

VerticalBlank   sta WSYNC

                inx

                cpx #37

                bne VerticalBlank

       ; Do 192 scanlines of color-changing (our picture)



                ldx #$50                 ; id da cor roxa
				stx COLUBK				; seta a cor roxa de fundo
				
				ldx #0			 ; reseta x

PintaTela                     ; conta as 192 linhas da tela

                sta WSYNC              
                inx
                cpx #192
                bne PintaTela



       ;------------------------------------------------



   

 
				; coloca a faixa preta no fim da tela
                lda #%01000010   

                sta VBLANK          ; end of screen - enter blanking



   ; 30 scanlines of overscan...



                ldx #0

Overscan        sta WSYNC

                inx

                cpx #30

                bne Overscan
				



				jmp Principal
				



;------------------------------------------------------------------------------



            ;ORG $FFFA ; endereço do fim do cartucho



;pro looping infinito 

            .word Principal         ; NMI   ;looping

            .word Principal         ; RESET

            .word Principal          ; IRQ



      END