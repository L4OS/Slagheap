;
; Blink 2-leds sample
;

function   main
	xor	r4, r4		; Обнуление R4
	set_mr	mr32, r4	; Выводим первую строку
	nop
	load	r0, 0x1111
;	load	r1, 0xfffeffe0	; Адрес LED
	load	r1, 0xffe0	; Адрес LED
	load	r2, 0xfffefff0	; Адрес UART_TX
	load	r3, 0x21
	; Выводим вторую строку
	load	r4, 0x0014
	set_mr	mr31, r4
loop:
;	nop
	mov	(r1), r0
	; Выводим третью строку
	load	r4, 0x0034
	set_mr	mr32, r4	
	; Выводим четвёрту строку
	load	r4, 0x0041
	set_mr	mr32, r4	
	; Выводим пятую строку
	load	r4, 0x0052
	set_mr	mr32, r4	
	inc	r0
;	dec	r1, 4
;	mov	(r2),r3
;	call	_blink_led
;	jmp	_blink_led
;	jmp	loop
	debug
	align
end

function	_blink_led
	load	r3, 0xAAAAAAAA
soop:
	mov	(r1), r3
	set_mr	mr1, r3
	inc	r0
	jmp	soop
	return
	nop
	nop
	nop
	nop
end