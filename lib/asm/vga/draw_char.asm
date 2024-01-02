; --- Точка входа при отладке. Она должна быть первой в файле
; Не должна вызываться программой и служит как тестовый заголовок
function _test_char
	load	r14, 0x2000 ; set stack
	load	r0, 32
	load	r1, 0x80000000
	load	r2, 0
	load	r3, 0xffffffff
	call	_draw_char
	send
end


; --- Функция вывода символа на VGA экран по координатам и нужным цветом
; Вход:  R0  - код символа
;	 R1  - адрес в видеопамяти
;	 R2  - цвет символа
;	 R3  - цвет фона
; Выход: 
;	 R1  - адрес видеопамяти следующего символа
;	 R2  - цвет символа
;	 R3  - цвет фона
	

function _draw_char
	push	r15
	push	r10			; Согласно ABI не храним содержимое R8-R15
	push	r1
	load	r10, 2528 		; Размер следующая строка (640 - 8) * 4

	lea	r7, $font_selector
	mov	r7, (r7)
	shl	r0, 4
	clc	
	addc    r7, r0
	load	r6, 4
quorter:
	mov	r0, (r7)
	load	r4, 4
word:
	load	r5, 8
line:
	shl	r0, 1 
	jc	white
	mov	(r1), r3
	jmp 	next
white:
	mov	(r1), r2
next:
	inc	r1, 4
	dec	r5
	jnz	line
	addc	r1, r10
	dec	r4
	jnz	word
	inc	r7, 4
	dec	r6
	jnz	quorter
	pop	r1
	load	r7, 32
	clc
	addc	r1, r7
	pop	r10		
	pop	r15
	return
end

$font_selector	dq	0

; Устанавливает указатель на начало шрифта 8x16
; Вход:
;	R7 - адрес памяти шрифта

function _select_font
	lea	r6, $font_selector
	mov	(r6), r7
	return
end

