# stash
Selection of some interesting examples for the Everest processor

Assembly generated listing

<code>
; ------------------- _init_debug ------------------
0000:   01              ; DEBUG                   debug
0001:   9e 20 00        ; LOAD 	R14, 0x2000       	load r14, 0x2000
0004:   e0 ff ff ff ff  ; LOAD 	R0, 0xffffffff    	load r0, 0xffffffff
0009:   52 0a           ; LOAD 	R2, 0x0a          	load r2, 10	                   	
000b:   04              ; NOTCH                   	call	_div
000c:   8f 00 08        ; JMP 	0x0014             
000f:   01              ; DEBUG                   debug
0010:   04              ; NOTCH                   	call	_getchar
0011:   8f 00 87        ; JMP 	0x0098             
0014: 	""
; ------------------- _div ------------------
0014:   51 00           ; LOAD 	R1, 0x00          	load		r1, 0x0
; ------------------- _div64 ------------------
0018:   53 21           ; LOAD 	R3, 0x21          	load		r3, 33 ; 33
001a:   20 62           ; MOV 	R6, R2             	mov		r6, r2  	;	Divisor
001c:   21 77           ; XOR 	R7, R7             	xor		r7, r7
001e:   20 41           ; MOV 	R4, R1             	mov		r4, r1		;	lremainder
0020:   20 50           ; MOV 	R5, R0             	mov		r5, r0
0022:   21 88           ; XOR 	R8, R8             	xor		r8, r8		;	Quotient = 0
0024:   02              ; CLC                     	clc
0025:   26 57           ; SUBC 	R5, R7            	subc		r5, r7
0027:   26 46           ; SUBC 	R4, R6            	subc		r4, r6
0029:   80 00 0a        ; JC 	0x0033              	jc		step_to
002c:   34 80           ; SHL 	R8, 0              	shl		r8, 1
002e:   36 80           ; INC 	R8, 1              	inc		r8, 1
0030:   8f 00 0a        ; JMP 	0x003a             	jmp		skip
0033:   02              ; CLC                     	clc
0034:   25 57           ; ADDC 	R5, R7            	addc		r5, r7
0036:   25 46           ; ADDC 	R4, R6            	addc		r4, r6
0038:   34 80           ; SHL 	R8, 0              	shl		r8, 1
003a:   02              ; CLC                     	clc
003b:   31 60           ; RCR 	R6, 0              	rcr		r6, 1
003d:   31 70           ; RCR 	R7, 0              	rcr		r7, 1
003f:   37 30           ; DEC 	R3, 1              	dec		r3
0041:   83 ff e3        ; JNZ 	0x0024             	jne		loop	
0044:   20 25           ; MOV 	R2, R5             	mov		r2, r5
0046:   20 08           ; MOV 	R0, R8             	mov		r0, r8
0048:   05              ; RETURN                  	return
; ------------------- _puts ------------------
004c:   20 cf           ; MOV 	R12, R15           	mov	R12, R15	; Сохранение адреса возврата в R12
004e:   20 01           ; MOV 	R0, R1             	mov	r0, r1		; Копирование указателя на строку
0050:   68 20           ; MOV 	R2, (R0)           	mov	r2, (r0)	; Загрузка машинного слова (4-символа)
0052:   54 04           ; LOAD 	R4, 0x04          	load	r4, 4		; Количество байт в машинном слове
0054:   32 27           ; ROL 	R2, 7              	rol	r2, 8		; Циклический сдвиг на 8 бит влево
0056:   53 ff           ; LOAD 	R3, 0xff          	load	r3, 0xff	; Загрузка восьмибитной константы
0058:   22 32           ; AND 	R3, R2             	and	r3, r2		; Проверка на конец строки
005a:   82 00 11        ; JZ 	0x006b              	je	done		; Вывод строки закончен
005d:   04              ; NOTCH                   	call	_putchar        ; Вызов подпрограммы вывода символа
005e:   8f 00 16        ; JMP 	0x0074             
0061:   36 00           ; INC 	R0, 1              	inc	r0, 1		; Инкремент указателя
0063:   37 40           ; DEC 	R4, 1              	dec	r4, 1		; Декремент счётчика
0065:   83 ff ef        ; JNZ 	0x0054             	jne	check_byte	; Следующий символ
0068:   8f ff e8        ; JMP 	0x0050             	jmp	load_word	; Повтор операции
006b:   02              ; CLC                     	clc			; Сброс переноса
006c:   26 01           ; SUBC 	R0, R1            	subc	r0, r1		; Подсчёт количества выведенных символов
006e:   20 fc           ; MOV 	R15, R12           	mov	R15, R12	; Восстановление адреса возврата из R12
0070:   05              ; RETURN                  	return			; Возврат из функции
; ------------------- _putchar ------------------
0074:   e6 ff fe ff f0  ; LOAD 	R6, 0xfffefff0    	load			R6, 0xfffefff0	; Адрес порта статуса UART
0079:   68 56           ; MOV 	R5, (R6)           	mov			R5, (R6)	; Чтение статуса устройства
007b:   31 50           ; RCR 	R5, 0              	rcr			R5, 1		; Вытесняем бит BUSY в перенос
007d:   80 ff fc        ; JC 	0x0079              	jc			do_poll		; Опрос устройства в цикле
0080:   36 63           ; INC 	R6, 4              	inc			R6, 4		; Указатель на регистр передачи данных
0082:   60 63           ; MOV 	(R6), R3           	mov			(R6), R3	; Вывод байта
0084:   37 63           ; DEC 	R6, 4              	dec			R6, 4		; Указатель на регистр передачи данных
0086:   68 56           ; MOV 	R5, (R6)           	mov			R5, (R6)	; Чтение статуса устройства
0088:   31 50           ; RCR 	R5, 0              	rcr			R5, 1		; Вытесняем бит BUSY в перенос
008a:   80 ff fc        ; JC 	0x0086              	jc			wait		; Опрос устройства в цикле
008d:   05              ; RETURN                  	return					; Возврат из функции
; ------------------- _uart_status ------------------
0090:   e6 ff fe ff f0  ; LOAD 	R6, 0xfffefff0    	load			R6, 0xfffefff0	; Адрес порта статуса UART
0095:   68 06           ; MOV 	R0, (R6)           	mov			R0, (R6)	; Чтение статуса устройства
0097:   05              ; RETURN                  	return
; ------------------- _getchar ------------------
0098:   e6 ff fe ff f0  ; LOAD 	R6, 0xfffefff0    	load			R6, 0xfffefff0	; Адрес порта статуса UART
009d:   68 06           ; MOV 	R0, (R6)           	mov			R0, (R6)	; Чтение статуса устройства
009f:   31 01           ; RCR 	R0, 1              	rcr			R0, 2		; Бит RCV_RDY в перенос
00a1:   81 ff fc        ; JNC 	0x009d             	jnc			do_poll		; Опрос устройства в цикле
00a4:   36 63           ; INC 	R6, 4              	inc			R6, 4		; Указатель на регистр чтения данных
00a6:   68 06           ; MOV 	R0, (R6)           	mov			R0, (R6)	; Чтение  
00a8:   05              ; RETURN                  	return					; Возврат из функции
; ------------------- _print_hex ------------------
00ac:   20 cf           ; MOV 	R12, R15           	mov	R12, R15	; Сохранение адреса возврата в R12
00ae:   53 20           ; LOAD 	R3, 0x20          	load		R3, 0x20
00b0:   04              ; NOTCH                   	call		_putchar
00b1:   8f ff c3        ; JMP 	0x0074             
00b4:   57 09           ; LOAD 	R7, 0x09          	load		R7, 0x9
00b6:   37 70           ; DEC 	R7, 1              	dec		R7
00b8:   82 00 27        ; JZ 	0x00df              	je		finish
00bb:   54 09           ; LOAD 	R4, 0x09          	load		r4, 0x9
00bd:   51 0f           ; LOAD 	R1, 0x0f          	load		R1, 0xf
00bf:   32 03           ; ROL 	R0, 3              	rol		r0, 4
00c1:   22 10           ; AND 	R1, R0             	and		r1, r0
00c3:   24 41           ; CMP 	R4, R1             	cmp		r4, r1
00c5:   80 00 0e        ; JC 	0x00d3              	jc		alphachar
00c8:   53 30           ; LOAD 	R3, 0x30          	load		r3, 0x30
00ca:   25 31           ; ADDC 	R3, R1            	addc		r3, r1
00cc:   04              ; NOTCH                   	call		_putchar
00cd:   8f ff a7        ; JMP 	0x0074             
00d0:   8f ff e6        ; JMP 	0x00b6             	jmp		fullnum
00d3:   02              ; CLC                     	clc
00d4:   53 37           ; LOAD 	R3, 0x37          	load		r3, 0x37 		; 'A' - 0xa
00d6:   25 31           ; ADDC 	R3, R1            	addc		r3, r1
00d8:   04              ; NOTCH                   	call		_putchar
00d9:   8f ff 9b        ; JMP 	0x0074             
00dc:   8f ff da        ; JMP 	0x00b6             	jmp		fullnum
00df:   53 20           ; LOAD 	R3, 0x20          	load		R3, 0x20
00e1:   04              ; NOTCH                   	call		_putchar
00e2:   8f ff 92        ; JMP 	0x0074             
00e5:   20 fc           ; MOV 	R15, R12           	mov	R15, R12	; Восстановление адреса возврата из R12
00e7:   05              ; RETURN                  	return
; ------------------- _newline ------------------
00e8:   20 cf           ; MOV 	R12, R15           	mov		R12, R15	; Сохранение адреса возврата в R12
00ea:   53 0d           ; LOAD 	R3, 0x0d          	load		R3, 0x0d
00ec:   04              ; NOTCH                   	call		_putchar
00ed:   8f ff 87        ; JMP 	0x0074             
00f0:   53 0a           ; LOAD 	R3, 0x0a          	load		R3, 0x0a
00f2:   04              ; NOTCH                   	call		_putchar
00f3:   8f ff 81        ; JMP 	0x0074             
00f6:   20 fc           ; MOV 	R15, R12           	mov		R15, R12	; Восстановление адреса возврата из R12
00f8:   05              ; RETURN                  	return
003f:
</code>
