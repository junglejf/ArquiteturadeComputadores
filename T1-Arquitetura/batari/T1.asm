;===============================================================================
; T2 - MSprite
;===============================================================================

    ; Program: T2 - MSprite
    ; Autores:   Jorge Felipe Campos Chagas, Gabriel , Henrique
    ; Programa que mostra quadrado no centro da tela e aceita as entradas do joystick


;===============================================================================
; Inicializando o Dasm
;===============================================================================

        PROCESSOR 6502
    
    ; vcs.h para usar a TIA e os registradores
        include vcs.h       

		
;===============================================================================
; Início da RAM e separamos espaço pra possíveis variáveis - Cabeçalho
;===============================================================================

    ; define um espaço para as variáveis 
        SEG.U VARS
    
    ; RAM scomeça no endereço $80
        ORG $80             
;===============================================================================
; Início do Catucho - Cabeçalho
;===============================================================================

    ; Cabeçalho
		SEG CODE    
    
    ; Recomenda-se que rom até 2k comece em $F800 e 4K $F000
		ORG $F000
;Variáveis reservadas
YPos = $80; ; onde guardaremos a posição vertical do objeto
Quadrado = $81; variável do quadrado
              ;
;===============================================================================
; Inicio do Jogo
;===============================================================================
    
Inicio
    ;Limpa a RAM e os registradores da TIA e do processador
	;recomendação para todos os jogos e limpar a RAM
		sei ;desativa qualquer interrupção
		cld ; limpa o bit de cáculo de BCD
            
		ldx #0 ; carrega x com 0
		txa ; passa o valor de x para A
		tay ; ||           || de a para y 
free   
		dex ; x = x -1
		txs ; passa x para o Stack pointer 
		pha ; da um push em A
		bne free ; enquanto não for zero(tiver algo) ontinua o loop
	    ;escolhemos trabalhar com o míssel 0
		lda #39		; tamanho = 39  pg 40 manual stella
		sta NUSIZ0	; quadrado = tamanho
		sta COLUBK	; background = cor#39 marrom claro
		
		lda #99 ; posicão inicial 192/2 = 96 + 4 pixels = 100 -1 index (começa conta de 0) = 99 
		sta YPos	;Posição inicial no eixo y(vertical)
		sta COLUP0
		
;;;calcular a posiçao inicial no eixo x(horizontal)
		lda #79 ; posicão inicial 160/2 = 80 - 1 index = 79 		
		sec				; limpa o carry
		sta WSYNC        ; espera o inicio da linha
		;;asl shiftleft bit, ajuda a "empurrar o quadrado para direita
DivideLoop
		sbc #15			;2
		bcs DivideLoop  ;4/5    4/ 9.../54 pg 8 manual 15  colour clock interval
		eor #7            ;+6/11... 01 10
		asl				  ;8
		asl				  ;10
		asl              ;12
		asl              ;14/19.../64
		sta.wx HMM0,X    ;19/24.../69
		sta RESM0,X      ;23 precisamos chegar no ciclo 23 ou + para podermos setar
		sta WSYNC         ;necessário antes do HMOVE
		sta HMOVE         ;movimentação horizontal tem q ter ciclo 24> aqui pg 9 manual stella
		;Obs.: bug de 8 bits referente a este HMOVE ^^^^^^^^ que da o tracinho preto na tela superior esquerda
		

;===============================================================================
; Estrutura do Programa Principal
;===============================================================================

Main
        ;1 - VerticalSync    
        ;2 - VerticalBlank
		;3 - Joystick	
        ;4 - Núcleo         
        ;5 - OverScan        
        ;5.1 - voltemos ao Main 
		;6 - Fim do cartucho	
    

;===============================================================================
; 1 - Vertical Sync
; -------------
; Aqui geramos o sinal que orienta a TV a mover o canhão para o topo da tela para 
; podermos ir mandando os frames. O sinal VSync precisa ser de 3 linha como 
; explicamos no trabalho
;===============================================================================

;VerticalSync:
		
        lda #2      ; Carrega o acumulador com 2 para podermos setar D1 = 1 no sta da linha 86
        sta VSYNC   ; acumulador D1 = 1 e liga o sinal do vertical Sync	
		sta WSYNC   ; espera por SYNC para ir até o fim da 1ª linha
        sta WSYNC   ; espera por SYNC para ir até o fim da 2ª linha
		sta WSYNC   ; espera por SYNC para ir até o fim da 3ª linha
		lda #0      ; carrega o acumulador com 0 então poderemos setar D1 = 0 no sta da linha 91    
        sta VSYNC   ; acumulador d1 = 0 e desliga o sinal vsync

;===============================================================================
; 2 - Vertical Blank
; --------------
; Pularemos 37 linhas do vblank
;===============================================================================
        
		ldx #36        ; x = 36, já temos uma linha da nossa inicialição da Pos Horizontal
vbLoop       
        sta WSYNC       ; espera  ir até o fim da linha
        dex             ; x = x -1
        bne vbLoop      ; volta a VbLoop se x > 0
		
		
;===============================================================================
; 3 - Joystick
; --------------
; Aqui captaremos os comandos do Joystic para movimentar o quadrado
;===============================================================================
;Primeiro pra cima e pra baixo
;SWCHA = |1|1|1|1|1|1|1|1| = "repouso"
;quando capta um movimento SWCHA fica com 0 no bit do movimento:(Exemplo Joystick1)
;SWCHA = |1|1|1|0|1|1|1|1| = pra cima 16
;SWCHA = |1|1|0|1|1|1|1|1| = pra baixo 32
;SWCHA = |1|0|1|1|1|1|1|1| = esquerda 64
;SWCHA = |0|1|1|1|1|1|1|1| = direita 128
		lda #16	; a = 16
		bit SWCHA ; faz um and lógico com o registrador A e SWCHA pega o bit de entrada
		bne testaBaixo ; se for diferente de zero 
		inc YPos ;
		inc YPos ; 2 inc para regular a velocidade
testaBaixo

		lda #32	;a = 32
		bit SWCHA  ; faz um and lógico com o registrador A e SWCHA pega o bit de entrada
		bne testaEsquerda ; testa o próximo se >0
		dec YPos ;
		dec YPos ; 2 dec para regular a velocidade
testaEsquerda
;aqui usaremos reg X
		ldx #0		; x = 0
		lda #64	; a = 64
		bit SWCHA ;faz um and lógico com o registrador A e SWCHA pega o bit de entrada
		bne testaDireita ; testa o próximo se >0
		ldx #%00011111	;+1 nos 4 primeiros bits esquerda ; pg 41 manual do stella D7 D6 D5 D4
;4 primeiros bits do registrador
;pg 41 manual do stella 
;D7 D6 D5 D4
;0 1 1 1 +7
;0 1 1 0 +6
;0 1 0 1 +5 Move left
;0 1 0 0 +4 indicated number      +7 vmax -8     1 & -1 vmin
;0 0 1 1 +3 of clocks
;0 0 1 0 +2
;0 0 0 1 +1
;0 0 0 0 0 No Motion
;1 1 1 1 -1
;1 1 1 0 -2
;1 1 0 1 -3
;1 1 0 0 -4 move right
;1 0 1 1 -5 indicated number
;1 0 1 0 -6 of clocks
;1 0 0 1 -7
;1 0 0 0 -8
testaDireita
	
		lda #128	;a = 128
		bit SWCHA  ;faz um and lógico com o registrador A e SWCHA pega o bit de entrada
		bne done ; vaa para done linha 198 se a flag de bit > 0
		ldx #%11111111	; -1 nos 4 primeiros bits direita
done
		stx HMM0	;Enfim,  guarda o comando;
 
;===============================================================================
; 4 - Núcleo
; ------
; Aqui é a parte onde desenhamos o nosso quadrado 
;===============================================================================
          
		ldy #190 ; y = 190
		sta WSYNC  ; espera fim da linha 
		sta VBLANK  ; desliga vblank	
		sta WSYNC	; necessário antes de chamar HMOVE mover
		sta HMOVE 	; executa comando se houver

; Desenhando a tela do jogo		
TelaPrincipal 	
		sta WSYNC 	
QuadradoON
		cpy YPos ; verifica se quadrado ta ativo
		bne no ; pula pra linha 214
		lda #8 ; a = 8
		sta Quadrado ;atualiza quadrado
no
;Ta fora da tela quadrado? 
		lda #0		; a =0
		sta ENAM0 ; atualiza enam0

;Voltou?Então pinta quadrado!

		lda Quadrado ; atualiza quadrado
		beq fim ; se flag =0 vai pra linha 227
ligado	
		lda #2	; a =2	
		sta ENAM0 ; atualiza enam0
		dec Quadrado ; diminui o valor da variável quadrado
fim
		dey		 ; y = y-1
		bne TelaPrincipal ; se y> 0 continua o looping
        
;===============================================================================
; 5 - Overscan
; --------------
;Aqui contamos as 30 linhas finais da tela
;===============================================================================

        lda #2      ; a = 2 pra fazer D1 = 1;
		sta WSYNC   ; espera vsync para ir até o fim da linha, e garantir o fim da scanline
        
        sta VBLANK  ; desliga a imagem e liga vblank
    
        ldx #30     ; x = 30
osLoop
        sta WSYNC   ; espera vsync para ir até o fim da linha
        dex         ; x = x -1
        bne osLoop  ; looping regressivo retornando para osLoop enquanto x != 0
	;===========================================================================
	; 5.1 - Retorna ao Main
	;===========================================================================
		
		jmp Main   ; Volta para o label Main >> linha 93 <<
        
;===============================================================================
; 6 - Fim do Cartucho
;===============================================================================
        ORG $FFFC        ; espaço para o endereço dos vetores de interrupçoes ( Reset o mais importante). 
        .WORD Inicio ; NMI
        .WORD Inicio ; RESET
        .WORD Inicio ; IRQ
        
