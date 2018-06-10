		AREA datos,DATA
; variables y constantes
VICBaseEnabl	EQU 0xFFFFF000			;base para activar IRQ
IntEnableOffset	EQU 0x10				;selecciona activar IRQ4
IRQ_Timer0 	EQU 4			   			;Nº de IRQ4 del Timer 0
IRQ_UART 	EQU 7			   			;Nº de IRQ7 del UART

VICIntEnable 	EQU 0xFFFFF010 
VICIntEnClr 	EQU 0xFFFFF014			;desactivar IRQs (solo bits 1)

VICVectAddr0	EQU 0xFFFFF100		
;Registro con la @ de la 1ª instr de la RSI_IRQ0 vectorizada
VICVectAddr		EQU	0xFFFFF030			;Registro @VI
T0_IR			EQU 0xE0004000
UART_IR			EQU 0xE0010000			
I_Bit			EQU 0x80				;bit7 de la CPSR, si a 1 inhibe

;Globales

reloj	DCD 0 ;contador de centesimas de segundo
fin		DCB 0 ;indicador fin de programa (si vale 1)
MINUS	EQU 'a' - 'A'
		ALIGN 4
ASCII	DCD	0 ;caracter pulsado

;vuestras variables y constantes
DIR_SCREEN	EQU 0x40007E00 ;direción de la pantalla
SCREEN_R 	EQU	16	;filas de la pantalla
SCREEN_C	EQU 32	;columnas de la pantalla
SCREEN_PX	EQU SCREEN_R*SCREEN_C ;numero de pixeles (@s) de la pantalla
SCREEN_GAMEOVER	DCB	0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x5F,0x5F,0x5F,0x20,0x20,0x5F,0x5F,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x5F,0x5F,0x5F,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x7C,0x20,0x20,0x20,0x20,0x7C,0x20,0x20,0x7C,0x20,0x7C,0x5C,0x20,0x2F,0x7C,0x20,0x7C,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x7C,0x20,0x5F,0x5F,0x20,0x7C,0x5F,0x5F,0x7C,0x20,0x7C,0x20,0x56,0x20,0x7C,0x20,0x7C,0x5F,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x7C,0x20,0x20,0x7C,0x20,0x7C,0x20,0x20,0x7C,0x20,0x7C,0x20,0x20,0x20,0x7C,0x20,0x7C,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x7C,0x5F,0x5F,0x7C,0x20,0x7C,0x20,0x20,0x7C,0x20,0x7C,0x20,0x20,0x20,0x7C,0x20,0x7C,0x5F,0x5F,0x5F,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x5F,0x5F,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x5F,0x5F,0x5F,0x20,0x20,0x5F,0x5F,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x7C,0x20,0x20,0x7C,0x20,0x7C,0x20,0x20,0x20,0x7C,0x20,0x7C,0x20,0x20,0x20,0x20,0x7C,0x20,0x20,0x5C,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x7C,0x20,0x20,0x7C,0x20,0x7C,0x20,0x20,0x20,0x7C,0x20,0x7C,0x5F,0x20,0x20,0x20,0x7C,0x5F,0x5F,0x7C,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x7C,0x20,0x20,0x7C,0x20,0x20,0x5C,0x20,0x2F,0x20,0x20,0x7C,0x20,0x20,0x20,0x20,0x7C,0x20,0x5C,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x7C,0x5F,0x5F,0x7C,0x20,0x20,0x20,0x56,0x20,0x20,0x20,0x7C,0x5F,0x5F,0x5F,0x20,0x7C,0x20,0x20,0x5C,0x20,0x20,0x20,0x20,0x20,0x20
SCREEN_GAMEOVER_END DCB '\n'
SCREEN_WIN DCB ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','_','_',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','\\',' ',' ',' ','/',' ','|',' ',' ','|',' ','|',' ',' ','|',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','\\',' ','/',' ',' ','|',' ',' ','|',' ','|',' ',' ','|',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','|',' ',' ',' ','|',' ',' ','|',' ','|',' ',' ','|',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','|',' ',' ',' ','|','_','_','|',' ','|','_','_','|',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','_','_','_',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','|',' ',' ',' ',' ',' ','|',' ',' ','|',' ',' ','|','\\',' ',' ',' ','|',' ','|',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','|',' ',' ','|',' ',' ','|',' ',' ','|',' ',' ','|',' ','\\',' ',' ','|',' ','|',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','|',' ',' ','|',' ',' ','|',' ',' ','|',' ',' ','|',' ',' ','\\',' ','|',' ','|',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','\\','/',' ','\\','/',' ',' ','_','|','_',' ','|',' ',' ',' ','\\','|',' ','O',' ',' ',' ',' ',' ',' '
SCREEN_WIN_END DCB '\n'
SCREEN_START	DCB ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','P','R','E','S','S',' ','S','P','A','C','E',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','T','O',' ','S','T','A','R','T',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '
SCREEN_START_END DCB '\n'
SCREEN_PAUSE	DCB	'P','A','U','S','E','D'
SCREEN_PAUSE_END DCB '\n'
		
		ALIGN 4

CHAR_CLEAR	EQU ' '	;caracter de borrado de pantalla

CHAR_CANYON		EQU '#' ;caracter de respresentación del cañón
CHAR_CANYON_L	EQU	'K' ;cañon hancia la izquierda
CHAR_CANYON_R	EQU	'L' ;cañon hacia la derecha
CANYON_CENTER	EQU SCREEN_C/2	;centro del cañón en el instante incial

CHAR_BULLET		EQU	'*'	;caracter de representación bala de cañon
CHAR_BULLET_SHOOT	EQU	0x20
CHAR_BULLET_F	EQU	'+'	;duplica velocidad balas
CHAR_BULLET_S	EQU '-'	;reduce velodidad balas
BULLET_QUICK	EQU	1	;centesimas de segundo entre movimeintos a máxima velocidad
BULLET_SLOW		EQU	128	;centesimas de segundo entre movimeintos a minima velocidad
BULLET_SPEED	DCD 16 ;promedio centesimas de segundo entre movimeintos
bullet_timer	DCB	16
		
		ALIGN 4
bullet_count	DCD	10	;cantidad inicial de valas (MAX: 9999)
bullets_over	DCD 0	;contador para acabar el programa cuando ya no quedan balas
;ALIGN 4
bullet_count_d1	DCB	'0'	
bullet_count_d2	DCB	'0'
bullet_count_d3	DCB	'1'
bullet_count_d4	DCB	'0'

score			DCD 0	;puntuación acumulada
;ALIGN 4
score_d1		DCB '0'
score_d2		DCB '0'
score_d3		DCB '0'
score_d4		DCB '0'

CHAR_ENEMY_L	EQU	'<'	;caracter de representación de enemigo
CHAR_ENEMY_R	EQU '>' ;caracter de representación de enemigo
CHAR_ENEMY_F	EQU	'A'	;duplica velocidad de enemigos
CHAR_ENEMY_S	EQU 'Z'	;reduce velodidad de enemigos
ENEMY_MIN		EQU	2	;minima longitud enemigo
ENEMY_MAX		EQU 10	;maxima longitud enemigo
ENEMY_QUICK		EQU	1	;centesimas de segundo entre movimeintos a máxima velocidad
ENEMY_SLOW		EQU	128	;centesimas de segundo entre movimeintos a minima velocidad
ENEMY_SPEED		DCD ENEMY_SLOW/8 ;promedio centesimas de segundo entre movimeintos	
enemy_timer		DCD 0	;velocidad del enemigo

;struct ENEMIGO{long (0 ó MIN/2 - MAX/2), posx (0 - C), dirx(1(r) ó -1(l)), speedx (SLOW - QUICK), timer}
ENEMY_REG_FIELD EQU	8				;5 campos de registro (4x byte + 1x int)
ENEMY_REG_DIM	EQU 9					;espacio para 9 enemigos
ENEMY_REG_SIZE	EQU ENEMY_REG_FIELD*ENEMY_REG_DIM
;ALIGN 4
ENEMY_REG		SPACE ENEMY_REG_SIZE						
		
;ALIGN 4
enemy_count		DCD	3	;cantidad de enemigos restantes para completar el juego

CHAR_PAUSE	EQU 'P'	;pausar
CHAR_QUIT	EQU	'Q'	;salir del juego

		AREA codigo,CODE
		EXPORT inicio			; forma de enlazar con el startup.s
		IMPORT srand			; para poder invocar SBR srand
		IMPORT rand				; para poder invocar SBR srand
inicio	; se recomienda poner punto de parada (breakpoint) en la primera
		; instruccion de código para poder ejecutar todo el Startup de golpe
		;Habilitar interrupcion en VIC
		ldr r0, =VICVectAddr0
		;programar @IRQ4 -> RSI_reloj
		ldr r1, =RSI_reloj
		ldr r2, =IRQ_Timer0
	
		str r1, [r0, r2, LSL#2]

		;programar @IRQ7 -> RSI_teclado
		ldr r1, =RSI_teclado
		ldr r2, =IRQ_UART
	
		str r1, [r0, r2, LSL#2]
	
		;activar IRQ4,IRQ7
		ldr r0, =VICIntEnable
		ldr r1, [r0]
		orr r1, r1, #1<<IRQ_Timer0
		orr r1, r1, #1<<IRQ_UART
		str r1, [r0]			
			
		;dibujar pantalla inicial
		;limpiar toda la pantalla
		LDR r8, =DIR_SCREEN		;r8 = DIRECCIÓN DE INICIO DE PANTALLA
		LDR r0, =SCREEN_PX	  	;r0 <-- pixeles totales en pantalla
		PUSH {r0}				;r0 (pixeles) --> #12 @param
		PUSH {r8}				;r8 (screen) --> #8 @param
		bl SBR_limpiar_pantalla
		add sp, sp, #8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 15/05/2017 (BEGIN) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		;START
		LDR r8, =DIR_SCREEN			;r8 = DIRECCIÓN DE INICIO DE PANTALLA
		LDR r0, =SCREEN_C			;r0 <-- #SCREEN_C		
		mov r1, #5					;r1 <-- 4 (linea)
		mul r0, r1, r0 				;r0 <-- offset hasta linea 4
		LDR r1, =SCREEN_START;		r1 <-- @START
		LDR r2, =SCREEN_START_END	;r2 <-- @GO_END
bc_start
		cmp r1, r2 			;if(r0 != r2)
		beq bc_start_end	;	else
		ldrb r3, [r1], #1	;r3 <-- nuevo caracter
		strb r3, [r8, r0]	;r3 --> @pixel 
		add r0, r0, #1		;r0++ (siguiente px)
		b bc_start
bc_start_end
		
		;establecer semilla de números aleatorios
		LDR r0, =ASCII			;r0 <-- @ASCII
		eor r2, r2, r2			;r2 <--
bc_rand
		ldr r1, [r0]			;r1 <-- ASCII
		add r2, r2, #1			;r2++
		cmp r1, #0				;if(r1 != 0)
		beq bc_rand
		PUSH {r2}				;r0 (semilla) --> #8 @param
		bl srand	
		eor r1, r1, r1			;r1 <-- 0
		str r1, [r0]			;r1 (0) --> @ASCII
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 15/05/2017 (END) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		;dibujar pantalla inicial
		;limpiar toda la pantalla
		LDR r8, =DIR_SCREEN		;r8 = DIRECCIÓN DE INICIO DE PANTALLA
		LDR r0, =SCREEN_PX	  	;r0 <-- pixeles totales en pantalla
		PUSH {r0}				;r0 (pixeles) --> #12 @param
		PUSH {r8}				;r8 (screen) --> #8 @param
		bl SBR_limpiar_pantalla
		add sp, sp, #8

		;mostrar cañon
		add r0, r8, r0			;r0 <-- ultimo pixel de la pantalla + 1
		sub r0, r0, #SCREEN_C	;r0 <-- primer pixel de la última fila
		LDR r7, =CANYON_CENTER	;r7 = POSICION CENTRO DEL CAÑÓN
		add r9, r0, r7			;r9 = @PIXEL CENTRAL CAÑÓN
		LDR r0, =CHAR_CANYON	;r0 <-- caracter de representación del cañón 
		strb r0, [r9, #-1]		;mostrar cañon de tamaño 3
		strb r0, [r9]
		strb r0, [r9, #1]

		;mostrar puntuación
		add r0, r8, #1		;r0 <-- @incio del contador de puntuación
		LDR r1, =score_d1	;r1 <-- @bullet_count
		PUSH {r0, r1}		;r0 (contador) --> #8 @param
							;r1 (numero) --> #12 @param
		bl SBR_actualizar_contador
		add sp, sp, #8

		;mostrar balas retantes
		add r0, r8, #(SCREEN_C - 5)	;r0 <--	direcceción de inicio del contador de balas
		LDR r1, =bullet_count_d1	;r1 <-- @bullet_count
		PUSH {r0, r1}				;r0 (contador) --> #8 @param
									;r1 (numero) --> #12 @param
		bl SBR_actualizar_contador
		add sp, sp, #8

		
		;inicializar juego
		;inicializar vector de registro de enemigos 
		LDR r6, =ENEMY_REG 	 		;r6 = @REGISTRO DE ENEMIGOS
		LDR r0, =ENEMY_REG_DIM		;r0 <-- numero máximo de enemigos
		cmp r0, #0					;while (r0 > 0) == for (r0 = ENEMY_REG_DIM; r0 > 0; r0--)
		ble bc_02_end 				;	else (r0 <= 0) --> skip
		eor r1, r1, r1				;r1 <-- 0
		mov r2, r6					;r2 <-- @reg enemigos
bc_02	strb r1, [r2], #ENEMY_REG_FIELD	;@r2 <-- 0 (en_pantalla = false)
		subs r0, r0, #1				;r0--
		bne bc_02 					;continue <-- (r0 != 0)
bc_02_end

bucle 	;comprobar si se ha pulsado nueva tecla
		LDR r0, =ASCII
		ldr	r0, [r0]
		cmp r0, #0
		blne SBR_teclado
		
		;comprobar si hay que introducir a un nuevo enemigo
		LDR r0, =enemy_timer	;r0 <-- @timer de nuevo enemigo
		ldr r1, [r0]			;r1 <-- timer de nuevo enemigo
		LDR r2, =reloj			;r2 <-- @reloj
		ldr r2, [r2]			;r2 <-- reloj
		cmp r2, r1				;if (reloj >= timer) --> introduir enemigo
								;	else (timer < reloj) --> skip	
		blge SBR_intro_enemigo		

		;para cada elemento movil
		;;;;;; ENEMIGOS ;;;;;;;
		mov r0, r6				;r0 <-- @enemigo0
		LDR r3, =ENEMY_REG_DIM	;r3 <-- dimensión del vector
		cmp r3, #0				;while(r3 > 0) == for(r3 = #ENEMY_REG_DIM; r3 > 0; r3--)
		beq bc_03_end			;	else (r3 <= 0) --> skip
bc_03	ldrb r1, [r0]			;r1 <-- enemigo.long
		cmp r1, #0				;if(r1 == 0) --> skip (no existe enemigo)
		beq skip01				
		ldr r1, [r0, #4]		;r1 <-- enemigo.timer
		LDR r2, =reloj
		ldr r2, [r2]			;r2 <-- reloj
		; si toca mover elemento
		cmp r2, r1				;if (reloj >= timer) --> mover enemigo
		blt	skip01				;	else (timer < reloj) --> skip
		LDR r4, =ENEMY_REG_DIM	;r4 <-- dimensión del vector
		sub r4, r4, r3			;r4 <-- fila del enemigo a mover (inicia en 0)
		PUSH {r0,r4}			;r0 (enemigo) --> #8 @param
								;r4 (fila) --> #12 @param
		bl SBR_mover_enemigo
		add sp, sp, #8

skip01	add r0, r0, #ENEMY_REG_FIELD	;@enemigo++
		subs r3, r3, #1			;r3--
		bne bc_03
bc_03_end
		;	finsi

		;;;;;; BALAS ;;;;;;;
		LDR r1, =bullet_timer 	;r0 <-- @bullet_timer
		ldr r1, [r1]			;r1 <-- bullet_timer
		LDR r0, =reloj
		ldr r0, [r0]			;r0 <-- reloj
		;	si toca mover elemento
		cmp r0, r1				;if (reloj >= timer) --> mover balas
		blt finsi 
		bl SBR_mover_balas
		;;;;;; 2017/05/13
		LDR r0, =BULLET_SPEED	;r0 <-- @BULLET_SPEED
		ldr r0, [r0]			;r0 <-- BULLET_SPEED
		add r0, r0, r1			;r0 <-- next timer
		LDR r1, =bullet_timer	;r1 <-- @bullet_timer
		str r0, [r1]			;r0 (next_timer) --> @bullet_timer
		;;;;;;
finsi

		;si fin=0 salto a bucle		
		LDR r0, =fin			;r0 <-- @fin
		ldr r0, [r0]			;r0 <-- (@fin)
		cmp r0, #0				;if(r0 = 0) --> continue
		beq bucle

		;desactivar IRQ4,IRQ7
		;Desprogramar VIC
		;Inhabilitar interrupciones en el VIC
		ldr r0, =VICIntEnClr
		eor r1, r1, r1
		ldr r1, [r0]  ;haria falta?
		;desactivar RSI_reloj
		orr r1, r1, #1<<IRQ_Timer0
		;desactivar RSI_teclado
		orr r1, r1, #1<<IRQ_UART
		
		str r1, [r0]
		
		;Limpiar pantalla
		LDR r0, =(SCREEN_PX-2*SCREEN_C)	  	;r0 <-- pixeles totales en pantalla	- 2 lineas
		PUSH {r0}							;r0 (pixeles) --> #12 @param
		add r8, r8,	#SCREEN_C				;r8 <-- @inicio segiunda fila pantalla
		PUSH {r8}							;r8 (screen) --> #8 @param
		bl SBR_limpiar_pantalla
		add sp, sp, #8

		LDR r0, =enemy_count	;r0 <-- @enemy
		ldr r0, [r0]  			;r0 <-- enemy
		cmp r0, #0				;if(r0 == 0) --> TODOS LOS ENEMIGOS DERROTADOS
		beq win		

		;GAMEOVER
go		LDR r0, =SCREEN_C	;r0 <-- #SCREEN_C		
		mov r1, #2			;r1 <-- 4 (linea)
		mul r0, r1, r0 		;r0 <-- offset hasta linea 4
		LDR r1, =SCREEN_GAMEOVER	;r1 <-- @GO
		LDR r2, =SCREEN_GAMEOVER_END;r2 <-- @GO_END
bc_go	cmp r1, r2 			;if(r0 != r2)
		beq bfin			;	else
		ldrb r3, [r1], #1	;r3 <-- nuevo caracter
		strb r3, [r8, r0]	;r3 --> @pixel 
		add r0, r0, #1		;r0++ (siguiente px)
		b bc_go

		;WIN
win		LDR r0, =SCREEN_C	;r0 <-- #SCREEN_C		
		mov r1, #2			;r1 <-- 4 (linea)
		mul r0, r1, r0 		;r0 <-- offset hasta linea 4
		LDR r1, =SCREEN_WIN	;r1 <-- @WIN
		LDR r2, =SCREEN_WIN_END;r2 <-- @WIN_END
bc_win	cmp r1, r2 			;if(r0 != r2)
		beq bfin			;	else
		ldrb r3, [r1], #1	;r3 <-- nuevo caracter
		strb r3, [r8, r0]	;r3 --> @pixel 
		add r0, r0, #1		;r0++ (siguiente px)
		b bc_win

bfin	b bfin
	 	

RSI_reloj ;Rutina de servicio a la interrupcion IRQ4 (timer 0)
		;Cada 0,01 s. llega una peticion de interrupcion
		;guarda dirección de retorno, palabra de estado, 
		sub lr, lr,#4		;actualiza el PC de retorno para que punte a la @siguiente
		push {lr}			;guardar PC retorno en pila
		mrs r14,spsr 		;guardar estado CPSR_anterior
		push {r14}			;se guarda la spsr en la pila (usando lr)
		
		PUSH {r0, r1}	;guardar registros utilizados

		;activa IRQ
		mrs r1,cpsr			;para habilitar IRQ de la palabra de estado del modo activo
		bic r1,r1,#I_Bit	;pone a 0 el bit de las IRQ
		msr	cpsr_c,r1		;_c indica se copian el byte menos significativo
	
		;deactiva del VIC la petición
		ldr r0,=T0_IR
		mov r1,#1
		str r1, [r0]

		;tratamiento IR
		LDR r0, =reloj		;r0 <-- @reloj
		ldr r1, [r0]		;r1 <-- reloj
		add r1, r1, #1		;r1++
		str r1, [r0]

		;desactiva IRQ
		mrs r1,cpsr
		orr r1,r1,#I_Bit
		msr cpsr_cxsf,r1 	; [?] Why not _c?
		
		;restaura registros
		pop {r0,r1}	

		;desapila spsr y retorna al programa principal
	   	pop {r14}
		msr spsr_cxsf,r14  	;restaura el spsr de la pila
		ldr r14,=VICVectAddr
		str r14,[r14]		; [?] What's this?
		pop {pc}^			;^ --> cambio de modo

RSI_teclado ;Rutina de servicio a la interrupcion IRQ7 (teclado)
			;al pulsar cada tecla llega peticion de interrupcion IRQ7
		;guarda dirección de retorno, palabra de estado, 
		sub lr, lr,#4		;actualiza el PC de retorno para que punte a la @siguiente
		push {lr}			;guardar PC retorno en pila
		mrs r14,spsr 		;guardar estado CPSR_anterior
		push {r14}			;se guarda la spsr en la pila (usando lr)

   		PUSH {r0, r1}	;guardar registros utilizados

		;activa IRQ
		mrs r1,cpsr			;para habilitar IRQ de la palabra de estado del modo activo
		bic r1,r1,#I_Bit	;pone a 0 el bit de las IRQ
		msr	cpsr_c,r1		;_c indica se copian el byte menos significativo
	
		;deactiva del VIC la petición
		; [?] Is this necessary?
		;ldr r0,=T0_IR
		;mov r1,#1
		;str r1, [r0]

		;tratamiento IR
		LDR r0, =UART_IR		;r0 <-- @UART
		ldr r1, [r0]			;r1 <-- UART
		LDR r0, =ASCII			;r0 <-- @ASCII
		str r1, [r0]			;r1 --> ASCII

		;desactiva IRQ
		mrs r1,cpsr
		orr r1,r1,#I_Bit
		msr cpsr_cxsf,r1 	; [?] Why not _c?
		
		;restaura registros
		pop {r0,r1}	

		;desapila spsr y retorna al programa principal
	   	pop {r14}
		msr spsr_cxsf,r14  	;restaura el spsr de la pila
		ldr r14,=VICVectAddr
		str r14,[r14]		; [?] What's this?
		pop {pc}^			;^ --> cambio de modo


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;	SBR_teclado													;;;;
;;;;	ejecuta la acción necesaria según la tecla pulsada			;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SBR_teclado ;Rutina de tratameinto de tecla pulsada
		
		PUSH {lr, fp}		;guardar @PC_retorno y FP_antiguo
		mov fp, sp			;nuevo fp corresponde con sp actual
		PUSH {r0, r1, r2, r3}	;guardar registros utilizados
		
		LDR r0, =ASCII		;r1 <-- @ASCII
		ldr r1, [r0]		;r1 <-- ASCII
		eor r2, r2, r2 		;r2 <-- 0
		str r2,[r0]			;r2 --> ASCII (borrar tecla pulsada)

		;switch(ASCII ó r1){
		;case k:
		cmp r1, #CHAR_CANYON_L
		beq canyon_izq
		cmp r1, #CHAR_CANYON_L+MINUS
		beq canyon_izq
		;case l:
		cmp r1, #CHAR_CANYON_R
		beq canyon_drch
		cmp r1, #CHAR_CANYON_R+MINUS
		beq canyon_drch
		;case SPACE:
		cmp r1, #CHAR_BULLET_SHOOT
		beq bullet
		;case +:
		cmp r1, #CHAR_BULLET_F
		beq bullet_f
		;case +:
		cmp r1, #CHAR_BULLET_S
		beq bullet_s
		;case a:
		cmp r1, #CHAR_ENEMY_F
		beq enemy_f
		cmp r1, #CHAR_ENEMY_F+MINUS
		beq enemy_f
		;case z:
		cmp r1, #CHAR_ENEMY_S
		beq enemy_s
		cmp r1, #CHAR_ENEMY_S+MINUS
		beq enemy_s
		;case p:
		cmp r1, #CHAR_PAUSE
		beq pause
		cmp r1, #CHAR_PAUSE+MINUS
		beq pause
		;case q:
		cmp r1, #CHAR_QUIT
		beq quit
		cmp r1, #CHAR_QUIT+MINUS
		beq quit
		;default
		b skip09

canyon_izq
		;r7 = CENTRO DEL CAÑÓN
		cmp r7, #1
		beq skip09				;en el borde izquierdo
								;ELSE --> mover
		sub r7, r7, #1			;r7--
		mov r1, #CHAR_CLEAR		;r1 <-- #CHAR_CLEAR
		strb r1, [r9, #1]		;r1 --> eliminar px de la derecha
		sub r9, r9, #1			;r9--
		LDR r1, =CHAR_CANYON	;r1 <-- rep. cañom
		strb r1, [r9, #-1]		;r1 --> mostrar nuevo pixel
		b skip09

canyon_drch
		;r7 = CENTRO DEL CAÑÓN
		cmp r7, #(SCREEN_C - 2)	;if(r7 == posición maxima)
		beq skip09				;en el borde derecho
								;ELSE --> mover
		add r7, r7, #1			;r7++
		mov r1, #CHAR_CLEAR		;r1 <-- #CHAR_CLEAR
		strb r1, [r9, #-1]		;r1 --> eliminar px de la izquierda
		add r9, r9, #1			;r9++
		LDR r1, =CHAR_CANYON	;r1 <-- rep. cañón
		strb r1, [r9, #1]		;r1 --> mostrar nuevo pixel
		b skip09
bullet
		LDR r3, =bullet_count	;r3 <-- @bullet_count
		ldr r2, [r3]			;r2 <-- num de bala actual
		cmp r2, #0
		beq	skip09
		sub r2, r2, #1			;r2--
		str r2, [r3]			;r2 --> @bullet_count (actualizar numero de balas)

		;mostrar en pantalla
		sub r1, r9, #SCREEN_C	;r1 <-- posición de la nueva bala
		ldrb r3, [r1]			;r3 <-- valor actual del pixel
		LDR r2, =CHAR_BULLET	;r2 <-- rep. bala
		strb r2, [r1]			;r2 --> @(r1) (mostrar nueva bala)

		;comprobar si enemigo derrotado
		cmp r3, #CHAR_ENEMY_L
		beq enemigo_ultima_fila
		cmp r3, #CHAR_ENEMY_R
		beq enemigo_ultima_fila
		b skip12

enemigo_ultima_fila
		mov r3, #ENEMY_REG_DIM-1
		PUSH {r3}					;r3 (enemigo) --> #8 @param
		bl SBR_enemigo_derrotado
		add sp, sp, #4
skip12		
		;doble bala disparada
		cmp r3, #CHAR_BULLET
		bne skip13 
		LDR r3, =bullet_count	;r3 <-- @bullet_count
		ldr r2, [r3]			;r2 <-- num de bala actual
		add r2, r2, #1			;r2++
		str r2, [r3]			;r2 --> @bullet_count (actualizar numero de balas)
		b skip09
skip13
		;actualizar marcador
		add r1, r8, #(SCREEN_C - 5)	;r0 <--	direcceción de inicio del contador de balas
		PUSH {r1}					;r1 (contador) --> #8 @param
		bl SBR_restar_marcador
		add sp, sp, #4
		b skip09

bullet_f
		LDR r1, =BULLET_SPEED	;r1 <-- @BULLET_SPEED
		ldr r2, [r1]			;r1 <-- velocidad actual
		cmp r2, #BULLET_QUICK
		movgt r2, r2, lsr #1	;r2(delay) <-- delay = delay/2
		str r2, [r1]			;r2 --> salvar cambios
		b skip09

bullet_s
		LDR r1, =BULLET_SPEED
		ldr r2, [r1]			;r1 <-- velocidad actual
		cmp r2, #BULLET_SLOW
		movlt r2, r2, lsl #1	;r2(delay) <-- delay = delay*2
		str r2, [r1]			;r2 --> salvar cambios
		b skip09

enemy_f
		LDR r1, =ENEMY_SPEED
		ldr r2, [r1]			;r1 <-- velocidad actual
		cmp r2, #ENEMY_QUICK
		ble skip09
		mov r2, r2, lsr #1		;r2(delay) <-- delay = delay/2
		str r2, [r1]			;e2 --> salvar cambios

		;modificar velocidad enemigos
		LDR r3, =ENEMY_REG_DIM			;r3 <-- numero de enemigos
		cmp r3, #0
		beq skip09
		mov r1, r6						;r1 <-- r6 (@ENEMY_REG)
bc_11	ldrb r2, [r1, #3]				;r2 <-- velocidad actual
		cmp r2, #ENEMY_QUICK
		movgt r2, r2, lsr #1			;r2(delay) <-- delay = delay/2
		strgtb r2, [r1, #3]				;r2 --> salvar cambios
		add r1, r1, #ENEMY_REG_FIELD	;r1(++) --> siguiente enemigo
		subs r3, r3, #1					;r3--
		bne bc_11
		b skip09

enemy_s
		LDR r1, =ENEMY_SPEED	;r1 <-- @ENEMY_SPEED
		ldr r2, [r1]			;r2 <-- velocidad actual
		cmp r2, #ENEMY_SLOW
		bge skip09
		mov r2, r2, lsl #1		;r2(delay) <-- delay = delay*2
		str r2, [r1]			;r2 --> salvar cambios

		;modificar velocidad enemigos
		LDR r3, =ENEMY_REG_DIM			;r3 <-- numero de enemigos
		cmp r3, #0
		beq skip09
		mov r1, r6						;r1 <-- r6 (@ENEMY_REG)
bc_12	ldrb r2, [r1, #3]				;r1 <-- velocidad actual
		cmp r2, #ENEMY_SLOW
		movlt r2, r2, lsl #1			;r2(delay) <-- delay = delay*2
		strltb r2, [r1, #3]				;r2 --> salvar cambios
		add r1, r1, #ENEMY_REG_FIELD	;r1(++) siguiente enemigo
		subs r3, r3, #1					;r3--
		bne bc_12
		b skip09
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 15/05/2017
pause
		;Inhabilitar interrupciones en el VIC
		ldr r0, =VICIntEnClr
		eor r1, r1, r1
		;desactivar RSI_reloj
		orr r1, r1, #1<<IRQ_Timer0		
		str r1, [r0]


		LDR r0, =DIR_SCREEN+(SCREEN_C-6)/2	;r2 <-- centrar texto en la primera línea
		LDR r1, =SCREEN_PAUSE	;r1 <-- @PAUSE
		LDR r2, =SCREEN_PAUSE_END;r0 <-- @PAUSE_END
bc_pause_msg
		cmp r1, r2 			;if(r0 != r2)
		beq bc_pause_msg_end;	else
		ldrb r3, [r1], #1	;r3 <-- nuevo caracter
		strb r3, [r0], #1	;r3 --> @pixel 
		b bc_pause_msg
bc_pause_msg_end

		LDR r1, =ASCII			;r1 <-- @ ASCII
bc_pause
		ldr r0, [r1]			;r0 <-- ASCII 
		cmp r0, #CHAR_PAUSE		;if(r0 == CHAR_PAUSE)
		beq bc_pause_end
		cmp r0, #CHAR_PAUSE+MINUS	;if(r0 == CHAR_PAUSE (MINUS))
		beq bc_pause_end
		b bc_pause
bc_pause_end

		eor r0, r0, r0			;r0 <-- 0
		str r0,[r1]

		LDR r0, =DIR_SCREEN+(SCREEN_C-6)/2	;r2 <-- centrar texto en la primera línea
		LDR r1, =SCREEN_PAUSE_END-SCREEN_PAUSE;r0 <-- CARACTERES A BORRAR
		mov r2, #CHAR_CLEAR		;r2 <-- CHAR_CLEAR
bc_pause_clr
		cmp r1, #0 			;if(r0 != #0)
		ble bc_pause_clr_end;	else
		strb r2, [r0], #1	;r2 --> @pixel
		sub r1, r1, #1		;r1-- 
		b bc_pause_clr
bc_pause_clr_end

		;Rehabilitar interrupciones en el VIC
		ldr r0, =VICIntEnable
		eor r1, r1, r1
		;desactivar RSI_reloj
		orr r1, r1, #1<<IRQ_Timer0		
		str r1, [r0]
		b skip09
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 15/05/2017

quit
		LDR r1, =fin			;r1 <-- @ fin
		mov r2, #1				;r2 <-- 1
		str r2, [r1]			;FIN DEL PROGRAMA
				
skip09

		POP {r0, r1, r2, r3}	;guardar registros utilizados
		POP {pc, fp}			;guardar @PC_retorno y FP_antiguo

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;	SBR_limpiar_pantalla										;;;;
;;;;	pone a cero los [pixeles] primeros bits de la panatalla		;;;;
;;;;	comenzando desde la dirección [screen]						;;;;
;;;;	#8	@param:	screen --> @ de la pantalla						;;;;
;;;;	#12	@param:	pixeles --> numero de pixeles a borrar			;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SBR_limpiar_pantalla
		PUSH {lr, fp}		;guardar @PC_retorno y FP_antiguo
		mov fp, sp			;nuevo fp corresponde con sp actual
							
		PUSH {r0, r1, r2}	;guardar registros utilizados

		ldr r0, [fp, #8]	;r0 <-- dirección inicial de pantalla
		ldr r1, [fp, #12]	;r1 <-- numero de pixeles de la pantalla
		mov r2, #CHAR_CLEAR	;r2 <-- CHAR_CLEAR	

		cmp r1, #0			;while(r1 > 0){
		ble	bc_01_end		;	else (r1 <= 0) --> b fin
bc_01	strb r2, [r0], #1	;lipiar un pixel
		subs r1, r1, #1		;r1--
		bne	bc_01			;continue <-- (r1 != 0)
bc_01_end

		POP {r0, r1, r2}	;salir de la SBR
		POP {pc, fp}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;	SBR_actualizar_contador										;;;;
;;;;	traslada el buffer del [numero] al área de pantalla			;;;;
;;;;	destinada para el a la derecha de la dirección [contador]	;;;;
;;;;	#8	@param:	contador --> @ del contador en pantalla			;;;;
;;;;	#12	@param:	numero --> @ al buffer del numero a mostrar		;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SBR_actualizar_contador		
		PUSH {lr, fp}		;guardar @PC_retorno y FP_antiguo
		mov fp, sp			;nuevo fp corresponde con sp actual

		PUSH {r0, r1}	;guardar registros utilizados

		ldr r0, [fp, #8]	;r0 <-- @ inicial del contador
		ldr r1, [fp, #12]	;r1 <-- @ inicio numero representado (MAX: 9999)

		ldr r1, [r1]		;r2 <-- 4 cifras del numero
		strb r1, [r0, #0]	;r2 --> 4 cifras del contador
		mov r1, r1, lsr #8	;	siguiente byte (8-bits) del numero
		strb r1, [r0, #1]
		mov r1, r1, lsr #8
		strb r1, [r0, #2]
		mov r1, r1, lsr #8
		strb r1, [r0, #3]


		POP {r0, r1}	;salir de la SBR
		POP {pc, fp}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;	SBR_intro_enemigo											;;;;
;;;;	introduce en el juego un nuevo enemigo calculando sus		;;;;
;;;;	parámetros aleatoriamente									;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SBR_intro_enemigo
		PUSH {lr, fp}		;guardar @PC_retorno y FP_antiguo
		mov fp, sp			;nuevo fp corresponde con sp actual

		PUSH {r0, r1, r2, r3}	;guardar registros utilizados

		;ALEATORIO --> Momento siguinete aparición
		sub sp, sp, #4 			;@resul
		bl rand
		POP {r0}				;r0 <-- numero pseudo aleatorio
		and r0, r0, #31<<4		;r0 <-- enmascarar el núemro entre 16 - 512
		add r0, r0, #1<<4		;	aseguramos que r0 no sea 0
		LDR r1, =enemy_timer	;r1 <-- @enemy_timer
		ldr r2, [r1]			;r2 <-- enemy_timer
		add r2, r2, r0			;r2 <-- nuevo timer
		str r2, [r1]			;r2 --> @enemy_timer
		
		;ALEATORIO --> Línea de aparición (1-14)
		sub sp, sp, #4 			;@resul
		bl rand
		POP {r0}				;r0 <-- numero pseudo aleatorio
		and r0, r0, #SCREEN_R-1	;r0 <-- enmascarar el núemro entre 0 - 15
		cmp r0, #SCREEN_R-3		;if (r0 > 13){
		movgt r0, #SCREEN_R-3	;	r0 <-- 13
					
		LDR r2, =ENEMY_REG_FIELD	;r2 <-- #ENEMY_FIELD
		mul r1, r0, r2			;r1 <-- r0 (num del enemigo) * r2 (dim de reg enemigo) = offset

bc_14  	ldrb r0, [r6, r1]			;r0 <-- enemigo.long
		; Comprobar que la línea no es ocupada
		cmp r0, #0					;if (r0 == 0) --> skip (la línea esta vacia)
		beq bc_14_end
		; Si ocupada, linea++ modulo 13 (MAX 14 iteraciones)
		add r1, r1, #ENEMY_REG_FIELD	;r1 <-- offset siguiente enemigo
		cmp r1, #ENEMY_REG_SIZE		;if (r1 = #ENEMY_REG_SIZE)
		moveq r1, #0				;	r1 <-- 0
		subs r2, r2, #1				;r2--
		bne bc_14					;if (r2 != 0) -->  continue
		b skip10					; NO QUEDAN LINEAS LIBRES --> SALTAR

bc_14_end
		add r1, r6, r1			;r1 <-- @enemigo nuevo
					
		;ALEATORIO -->	Longitud (2 - 10 ! PAR)
		sub sp, sp, #4 			;@resul
		bl rand
		POP {r0}				;r0 <-- numero pseudo aleatorio
		and r0, r0, #127		;r0 <-- enmascarar el último half-word
		add r0, r0, #1			; asegurar que r0 no es 0
		mov r0, r0, lsl #1		;r0 <-- r0 * 2
		cmp r0, #ENEMY_MAX		;if (r0 > ENEMY_MAX)
		ble bc_15a_end			;	else
bc_15a	sub r0, r0, #ENEMY_MAX	;r0 - ENEMY_MAX
		cmp r0, #ENEMY_MAX		;if (r0 > ENEMY_MAX) --> continue
		bgt bc_15a
bc_15a_end

		cmp r0, #ENEMY_MIN		;if (r0 < ENEMY_MIN)
		bge bc_15b_end			;	else
bc_15b	add r0, r0, #ENEMY_MIN	;r0 + ENEMY_MIN
		cmp r0, #ENEMY_MIN		;if (r0 < ENEMY_MIN) --> continue
		blt bc_15b
bc_15b_end

		strb r0, [r1, #0]		;r0 --> enemigo.long

		;ALEATORIO -->	Dirección (-1 (izq) ó 1 (drch))
		sub sp, sp, #4 			;@resul
		bl rand
		POP {r0}				;r0 <-- numero pseudo aleatorio
		and r0, r0, #1			;r0 <-- enmascarar último bit
		cmp r0, #0				;if (r0 == 0)
		subeq r0, r0, #1		;	r0 <-- #-1
		strb r0, [r1, #2]		;r0 --> enemigo.dir

		;ARITMÉTICO -->	Posición (0 - SCREEN_C - 1) (!Se ha de modificar según dirección)
		cmp r0, #-1				;if (r2 (enemigo.dir) == -1 (HACIA LA IZQ))
		moveq r0, #SCREEN_C	
								;DERECHA (dir == 1)
		ldrneb r2, [r1, #0]		;r2 <-- enemigo.long
	   	rsbne r0, r2, #0		;r0 <-- posición oculto	(-long)
		strb r0, [r1, #1]		;r0 --> enemigo.pos

		;ALEATORIO --> 	Velocidad (0,01 - 1,28 ! por potencias de 2)						
		LDR r2, =ENEMY_SPEED	;r2 <-- @ENEMY_SPEED
		ldr r2, [r2]			;r2 <-- ENEMY_SPEED

		sub sp, sp, #4 			;@resul
		bl rand
		POP {r0}				;r0 <-- numero pseudo aleatorio
		and r0, r0, #8-1		;r0 <-- últimos 3 bits del número
		cmp r0, #3				;if (r0 <= 3) --> dividir r0-veces
		movle r2, r2, lsr r0	;	r2 <-- nueva velocidad
		subgt r0, r0, #4		; else if (r0 > 3) --> mutliplicar (r0 - 4)-veces
		movgt r2, r2, lsl r0	;	r2 <-- nueva velocidad

		cmp r2, #ENEMY_QUICK	;if (r2 < ENEMY_QUICK)
		movlt r2, #ENEMY_QUICK	;	r2 <-- ENEMY_QUICK
		cmp r2, #ENEMY_SLOW		;if (r2 > ENEMY_SLOW)
		movgt r2, #ENEMY_SLOW   ;	r2 <-- ENEMY_SLOW
		
		strb r2, [r1, #3]		;r2 --> enemigo.speed	

		;ARITMÉTICO --> Timer (RELOJ + SPEED)
		LDR r0, =reloj			;r0 <-- @reloj
		ldr r0, [r0]			;r0 <-- reloj
		add r2, r0, r2			;r2 <-- nuevo timer
		str r2, [r1, #4]		;r2 --> enemigo.timer 

skip10
		POP {r0, r1, r2, r3}	;guardar registros utilizados
		POP {pc, fp}		;guardar @PC_retorno y FP_antiguo

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;	SBR_mover_enemigo											;;;;
;;;;	desplazar el [enemigo] situado en la [fila] de pantalla		;;;;
;;;;	un paso en la dirección que corresponda						;;;;
;;;;	#8	@param:	enemigo --> @puntero a enemigo					;;;;
;;;;	#12	@param:	fila --> indice de la fila del enemigo			;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SBR_mover_enemigo			
		PUSH {lr, fp}		;guardar @PC_retorno y FP_antiguo
		mov fp, sp			;nuevo fp corresponde con sp actual

		PUSH {r0, r1, r2, r3, r4, r5}	;guardar registros utilizados

		ldr r0, [fp, #8]		;r0 <-- @puntero del enemigo
		ldr r3, [fp, #12]		;r3 <-- fila del enemigo (inicia en 0)
		LDR r4, =SCREEN_C		;r4	<-- numero de columnas por fila
		mul r3, r4, r3			;r3 <-- offset hasta fila del enemigo
		add r3, r3, r4, lsl #1	;r3 <-- CONTEMPLAR QUE LA PRIMERA LINEA DE ENEMIGOS ES LA TERCERA
		add r3, r8, r3			;r3 <-- @ inicio de la linea del enemigo
			
		; calcular instante siguiente movimiento
		ldrb r1, [r0, #3]	;r1 <-- enemigo.speed
		ldr r2, [r0, #4]	;r2 <-- enemigo.timer
		add r2, r2, r1		;r2 <-- nuevo timer
		str r2, [r0, #4]	;r2 --> enemigo.timer

		;borrar elemento anterior
		;calcular nueva posicion (dirx) elemento
		;dibujar nuevo elemento
		;;;;;;;;;;;;;;;;;;;;;;; GUARDA DE ROBUSTEZ ;;;;;;;;;;;;;;;;;;;;;;;;;;;
		ldrb r2, [r0]		;r2 <-- enemigo.long
		cmp r2, #0			;if (long > 0)
		ble	enm_end		   	; else (long <= 0) --> skip (no necesario mover nada)
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		ldrsb r1, [r0, #2]	;r1 <-- enemigo.dirx
		cmp r1, #1			
		beq	enm_r			;if (dirx == 1[derecha]) --> b enm_r

; IZQUIERDA ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
enm_l	
	   	ldrsb r1, [r0, #1]	;r1 <-- enemigo.posx
bc_04	cmp r1, #0			;if (pos > 0)
		ble skip02			; else --> skip02
		cmp r1, #SCREEN_C	;if (pos < SCREEN_C)
		bge	skip03			; else --> skip03
		ldrb r4, [r3, r1]	;r4 <-- caracter de representación del enemigo en (pos)
		sub r1, r1, #1		;r1-- (desplazar a la izquierda)
		strb r4, [r3, r1]	;desplazar
		add r1, r1, #2		;siguiente posición de la linea del enemigo
		subs r2, r2, #1		;caracteres_restantes--
		bne bc_04			;if (caracteres_restantes > 0)
		b bc_04_end			; else

skip02	adds r2, r2, r1		;r2 <-- caracteres restantes una vez llegada a la posición 1 de pantalla
		mov r1, #1			;r1 <-- 1 (posicion 1 de la pantalla)
		subs r2, r2, #1		;caracteres_restantes--
		bne bc_04			;if (caracteres_restantes > 0)
		b bc_04_end			; else

skip03	ldrb r4, [r0]		;r4 <-- enemigo.long
		cmp r2, r4, lsr #1	;r2 (número de caracteres restantes por mostrar)
							;r4 lsl 1 (primer carácter perteneciente a la zona derecha)
							;if (r2 <= r4) --> EL CARACTER ES DERECHO
		movle r4, #CHAR_ENEMY_R	;r4 <-- caracter de representación del enemigo en (pos)
							; else (ES IZQUIERDO)
		movgt r4, #CHAR_ENEMY_L	;r4 <-- caracter de representación del enemigo en (pos)
		sub r1, r1, #1		;r1-- (desplazar a la izquierda)
		strb r4, [r3, r1]	;desplazar
		;no es necesaria ninguna acción mas
		b enm_end

bc_04_end 
		mov r4, #CHAR_CLEAR	;r4 <-- #CHAR_CLEAR
		sub r1, r1, #1		;r1 <-- posición más a la derecha del enemigo (debe ser borrada)
		strb r4, [r3, r1] 	; BORRAR
		b enm_end
; DERECHA ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
enm_r		
		ldrsb r1, [r0, #1]	;r1 <-- enemigo.posx
		cmp r1, #0			;if (pos >= 0)
		blt skip04			;	else --> skip04
		
		mov r5, #CHAR_CLEAR	;r5 <-- ' ' <-> #CHAR_CLEAR (caracter anterior)
		
bc_05	cmp r1, #SCREEN_C	;if (pos < SCREEN_C)
		bge	enm_end		;	else --> skip
		ldrb r4, [r3, r1]	;r4 <-- caracter de representación del enemigo en (pos)
		strb r5, [r3, r1]	;desplazar
		mov r5, r4
		add r1, r1, #1		;r1++ (desplazar a la derecha)
		subs r2, r2, #1		;caracteres_restantes--
		bne bc_05			;if (caracteres_restantes != 0)
		b bc_05_end			; else

skip04	ldrb r4, [r0]		;r4 <-- enemigo.long
		add r1, r2, r1		;r1 <-- (numero de caracteres YA mostrados)
		cmp r1, r4, lsr #1	;r4 lsr 1 (ultimo carácter perteneciente a la zona derecha)
							;if (r2 >= r4) --> EL CARACTER ES IZQUIERDO
		movge r5, #CHAR_ENEMY_L	;r4 <-- caracter de representación del enemigo en (pos)
							; else (ES DERECHO)
		movlt r5, #CHAR_ENEMY_R	;r4 <-- caracter de representación del enemigo en (pos)
		eor r1, r1, r1		;r1 <-- 0 (comienzo de la linea de pantalla)
		b bc_05				;if (caracteres_restantes != 0)


bc_05_end 
		cmp r1, #SCREEN_C		 ;SÓLO ESCRIBIR SI SIGUE SIENDO LA MISMA LÍNEA
		strltb r5, [r3, r1] 	; Ultimo caracter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


enm_end

		; calcular nueva posicion (dirx) elemento
		ldrsb r1, [r0, #1]	;r1 <-- enemigo.posx
		ldrsb r2, [r0, #2]	;r2 <-- enemigo.dirx
		add r1, r1, r2		;r1 <-- nueva posición
	;	and r1, r1, #(1<<8)-1	;r1 <-- enmascarar a byte
						
		cmp r2, #1			;if(r2 == 1) <-> enemigo HACIA DERECHA
		ldrb r2, [r0]		;r2 <-- enemigo.long
		eor r3, r3, r3	    ;r3 <-- 0
		beq del_r			;b DERECHA
del_l
		;comprobar desaparición por la izquierda
		adds r2, r2, r1		;r2 <-- (long + posicion)
		streqb r3, [r0]		;if (long = -posición) --> ELIMINAR ENEMIGO
		b del_end

del_r	;comprobar desaparición por la derecha
		cmp r1, #SCREEN_C	;if (posx >= C)
		strgeb r3, [r0]		;r3 --> enemigo.long
					
del_end	strb r1, [r0, #1]	;r1 --> enemigo.posx

		POP {r0, r1, r2, r3, r4, r5}	;guardar registros utilizados
		POP {pc, fp}		;guardar @PC_retorno y FP_antiguo

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;	SBR_mover_balas												;;;;
;;;;	desplazar la matrix de balas de la pantalla	un paso hacia	;;;;
;;;;	arriba. Detecta impactos contra enemigos.					;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SBR_mover_balas
 		PUSH {lr, fp}		;salvar PC_retorno y FP_antiguo
		mov fp, sp			;nuevo fp

		PUSH {r0, r1, r2, r3, r4} 	;salvar registros utilizados

	   	;;;;;;;;;;;;;;;;;;;;;;;;;;;; GAME OVER ;;;;;;;;;;;;;;;;;;;;;;;;
		LDR r0, =bullet_count  		;r0 <-- @bullet_count
		ldr r0, [r0]				;r0 <-- bullet_count
		cmp r0, #0					;if(r0 == 0)
		beq no_bullets
		;hay balas
		LDR r0, =bullets_over  		;r0 <-- @bullets_over
		eor r1, r1, r1				;r1 <-- 0	
		str r1, [r0]				;r1 --> bullets_over
		b bullets_end

no_bullets
		;no hay balas
		LDR r0, =bullets_over  		;r0 <-- @bullets_over
		ldr r1, [r0]				;r1 <-- bullets_over
		add r1, r1, #1				;r1++
		str r1, [r0]				;r1 --> bullets_over
		cmp r1, #SCREEN_R - 2		;if (r1 >= SCREEN_R-2)
		blt	bullets_end				;	else
		mov r0, #1					;r0 <-- 1
		LDR r1, =fin				;r1 <-- @fin
		str r0, [r1]				;r1 --> @fin (fin del programa)
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bullets_end

		mov r1, #SCREEN_C		;r1 <-- numero de celdas por fila
		add r0, r8, r1			;r0 <-- @ primera calda de segunda fila
	
		;for (r1 = SCREEN_C, r1 > 0, r1--)
		cmp r1, #0
		ble bc_08_end
		;SEGUNDA FILA -->  Solo borrar balas
bc_08	ldrb r2, [r0], #1			;r2 <-- byte de la linea
									;r0++
		cmp r2, #CHAR_BULLET		;if (r2 == CHAR_BULLET){
		moveq r2, #CHAR_CLEAR		;r2 <-- #CHAR_CLEAR
		streqb r2, [r0, #-1] 		;r2 --> 0 --> byte de bala (borrar bala)
		subs r1, r1, #1				;r1--
		bne bc_08
bc_08_end
		;FILAS 3 <-> PENÚLTIMA --> Mover balas. Comprobar enemigos
		mov r1, #0				;r1 <-- 0
								;for (r1 = 0, r1 < (SREEN_R - 3), r1++){
bc_06	cmp r1, #(SCREEN_R - 3)
		bge	bc_06_end			
		eor r2, r2, r2			;r2 <-- 0
								;for (r2 = 0, r2 < SCREEN_C, r2++){
bc_07	cmp r2, #SCREEN_C		
		bge bc_07_end
		ldrb r3, [r0]					;r3 <-- byte de bala (leer siguiente byte)
		cmp r3, #CHAR_BULLET			;if (pixel == CHAR_BULLET){
		bne skip06						;	else
		ldrb r4, [r0, #(-SCREEN_C)]		;r4 <-- pixel de destino
		cmp r4, #CHAR_CLEAR				;if (r4 == CHAR_CLEAR )   NO POSIBLE -->  || r4 == CHAR_BULLET){
		beq not_found					;	b not_found (no se ha alcanzado enemigo)
		;cmp r4, #CHAR_BULLET			
		;beq not_found
found
		PUSH {r1}					;r1 (enemigo) --> #8 @param
		bl SBR_enemigo_derrotado
		add sp, sp, #4
		mov r3, #CHAR_CLEAR			;r3 <-- CHAR_CLEAR (eliminar bala)
not_found
		strb r3, [r0, #(-SCREEN_C)]	;r3 --> move pixel (tenaga bala o no - al alcanzar obj. la bala desaparece)
		mov r3, #CHAR_CLEAR			;r3 <-- #CHAR_CLEAR
		strb r3, [r0]				;r3 --> limpiar anterior			

skip06	add r2, r2, #1				;r2++
		add r0, r0, #1				;r0++
		b bc_07
bc_07_end
		add r1, r1, #1				;r1++
		b bc_06
bc_06_end
		POP {r0, r1, r2, r3, r4}	;guardar registros utilizados
		POP {pc, fp}				;guardar @PC_retorno y FP_antiguo

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;	SBR_enemigo_dorratado										;;;;
;;;;	elimina al [enemigo] derrotado. Lo borra de pantalla. Y		;;;;
;;;;	suma la puntuación correspondiente (score y count)			;;;;
;;;;	#8 @param: enemigo --> indice (0-) de enemigo en vector  	;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SBR_enemigo_derrotado 	
		PUSH {lr, fp}		;salvar PC_retorno y FP_antiguo
		mov fp, sp			;nuevo fp

		PUSH {r0, r1, r2, r3} 	;salvar registros utilizados

		ldr r0, [fp, #8]			;r0 <-- indice de nemigo derrotado
		sub r0, r0, #1
		LDR r2, =ENEMY_REG_FIELD 	;r2 <-- campos del registro
		mul r2, r0, r2				;r2 <-- offset a enemigo
		add r1, r6, r2				;r1 <-- @enemigo derrotado
		
		;borrar enemigo de la pantalla
		LDR r3, =SCREEN_C	;r3 <-- columnas por linea
		add r2, r8, r3, lsl #1		;r2 <-- @inicio TERCERA linea
		mul r3, r0, r3		;r3 <-- offset hasta linea de enemigo
		add r2, r2, r3		;r2 <-- @linea del enemigo
		ldrsb r3, [r1, #1]	;r3 <-- enemigo.posx
		add r3, r2, r3		;r3 <-- @en pantalla del enemigo
		ldrb r2, [r1]		;r2 <-- enemigo.long
		cmp r2, #0			;while (r2 != 0) ó (caracteres restantes != 0)
							; == for(r2 = LONG; r2 > 0; r2--)
		beq	bc_09_end
		mov r0, #CHAR_CLEAR	;r0 <-- #CHAR_CLEAR
bc_09	strb r0, [r3], #1	;borrar pixel del enemigo
		subs r2, r2, #1		;r2--
		bne bc_09
bc_09_end

		;actualizar puntuación
		ldrb r2, [r1]			;r2 <-- enemigo.long
		LDR r3, =(ENEMY_MAX+2)	;r3 <-- max longitud de un enemigo + 2
		sub r2, r3, r2			;r2 <-- puntuación que otorga el enemigo
		LDR r3, =score			;r3 <-- @score
		ldr r0, [r3]			;r0 <-- puntuación acumulada
		add r0, r0, r2			;r2	<-- nueva ""
		str r0, [r3]

		LDR r0, =score_d1		;r0 <-- @buffer de puntuación
		PUSH {r0, r2}			;r0 (cuenta) --> #8 @param
								;r2 (puntuacion) --> #12 @param
		bl SBR_sumar_marcador
		add sp, sp, #8

		add r2, r8, #1 			;r2 <-- @contador de puntuación 
		PUSH {r0}				;r0 (numero) --> #12 @param
		PUSH {r2}			 	;r2 (contador) --> #8 @param 
		bl SBR_actualizar_contador
		add sp, sp, #8

		;eliminar enemigo de vector
		eor r2, r2, r2			;r2 <-- 0
		strb r2, [r1]			;r2 --> enemigo.long
		
		;sumar enemigo derrotado al contador
		LDR r0, =enemy_count	;r0 <-- @enemigos restantes
		ldr r1, [r0]			;r1 <-- enemigos restantes
		subs r1, r1, #1			;r1--
		str r1, [r0]			;r1 --> (@enemigos restantes)
		LDR r0, =fin			;r0 <-- @ fin
		moveq r1, #1			;r1 <-- ¿fin programa? (1 = si)
		streq r1, [r0]			;FIN DEL PROGRAMA

		;aumentar una bala
		LDR r3, =bullet_count
		ldr r2, [r3]			;r2 <-- num de bala actual
		add r2, r2, #1			;r2++
		str r2, [r3]			;r2 --> bullet_count (actualizar numero de balas)

		;actualizar marcador de balas restantes
		add r1, r8, #(SCREEN_C - 5)	;r1 <--	direcceción de inicio del contador de balas
		mov r2, #1					;r2 <-- 1
		PUSH {r1, r2}				;r1 (cuenta) --> #8 @param
									;r2 (puntuacion) --> #12 @param
		bl SBR_sumar_marcador
		add sp, sp, #8

		POP {r0, r1, r2, r3}	;guardar registros utilizados
		POP {pc, fp}			;guardar @PC_retorno y FP_antiguo

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;	SBR_sumar_marcador											;;;;
;;;;	actualiza el buffer de la [cuenta] añadiendo la nueva		;;;;
;;;;	[puntuacion] obtenida 										;;;;
;;;;	#8 @param: cuenta --> buffer de caracteres ASCII			;;;;
;;;;	#12 @param: puntuacion --> nueva puntuación a considerar  	;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SBR_sumar_marcador
		PUSH {lr, fp}		;salvar PC_retorno y FP_antiguo
		mov fp, sp			;nuevo fp

		PUSH {r0, r1, r2} 	;salvar registros utilizados

		ldr r0, [fp, #8]			;r0 <-- @buffer de puntuación
		ldr r1, [fp, #12]			;r1 <-- puntuación a considerar

bc_10	cmp r1, #1000				;MILLARES
		subge r1, r1, #1000			;r1 - 1000
		bge dig1
		cmp r1, #100				;CENTENAS
		subge r1, r1, #100			;r1 - 100
		bge dig2
		cmp r1, #10					;DECENAS
		subge r1, r1, #10			;r1 - 10
		bge dig3
		cmp r1, #1					;UNIDADES
		subge r1, r1, #1			;r1 - 1
		bge dig4
		b bc_10_end


dig1	ldrb r2, [r0]		;r2 <-- dig1
		cmp r2, #'9'		;if (dig1 = '9'){
		addne r2, r2, #1	;	else
		strneb r2, [r0]		;actualizar digito
		b bc_10

dig2	ldrb r2, [r0, #1]		;r2 <-- dig2
		cmp r2, #'9'			;if (dig2 = '9'){
		moveq r2, #'0'			;	dig2 = '0'
		addne r2, r2, #1		;else
		strb r2, [r0, #1]		;actualizar digito
		beq dig1				;añadir MILLAR si es necesario		
		b bc_10

dig3	ldrb r2, [r0, #2]		;r2 <-- dig3
		cmp r2, #'9'			;if (dig3 = '9'){
		moveq r2, #'0'			;	dig3 = '0'
		addne r2, r2, #1		;else
		strb r2, [r0, #2]		;actualizar digito
		beq dig2				;añadir CENTENA si es necesario		
		b bc_10

dig4	ldrb r2, [r0, #3]		;r2 <-- dig4
		cmp r2, #'9'			;if (dig4 = '9'){
		moveq r2, #'0'			;	dig4 = '0'
		addne r2, r2, #1		;else
		strb r2, [r0, #3]		;actualizar digito
		beq dig3				;añadir DECENA si es necesario		
		b bc_10

bc_10_end
		
		POP {r0, r1, r2}	;guardar registros utilizados
		POP {pc, fp}		;guardar @PC_retorno y FP_antiguo

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;	SBR_restar_marcador											;;;;
;;;;	actualiza el buffer de la [cuenta] decrementando en uno		;;;;
;;;;	el numero representado										;;;;
;;;;	#8 @param: cuenta --> buffer de caracteres ASCII			;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SBR_restar_marcador	  
		PUSH {lr, fp}			;salvar PC_retorno y FP_antiguo
		mov fp, sp				;nuevo fp

		PUSH {r0, r1, r2} 		;salvar registros utilizados
		ldr r0, [fp, #8]		;r0 <-- @marcador de puntuación
	
		mov r1, #3				;r1 <-- 3
bc_13	cmp r1, #0
		blt bc_13_end
		ldrb r2, [r0, r1]		;r2 <-- dig
		cmp r2, #'0'			;if (dig = '0'){
		moveq r2, #'9'			;	dig = '9'
		subne r2, r2, #1		;else --> r2--
		strb r2, [r0, r1]		;	  --> actualizar digito
		sub r1, r1, #1			;r1--
		beq bc_13				;NECESARIO decrementar SIGUIENTE DIGITO		

bc_13_end
		POP {r0, r1, r2}	;guardar registros utilizados
		POP {pc, fp}		;guardar @PC_retorno y FP_antiguo

		END
