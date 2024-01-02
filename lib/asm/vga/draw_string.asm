; --- Точка входа при отладке. Она должна быть первой в файле
; Не должна вызываться программно и служит как тестовый заловок
function _test_string
	load	r14, 0x8000 ; set stack
	lea	r0, $test_tring
	load	r1, 0x00010001
	load	r2, 0xFF000077
	load	r3, 0x00777777
	call	_draw_string
	send
end

$test_tring	db	'Debug library mode', 0


; --- Функция вывода символа заданным цветом в видеопамять VGA адаптера
; Вход:  R0  - указатель на строку
;	 R1  - YX - строка-столбец - старшие 16 бит номер строки, младшие 16 бит номер столбца
;	 R2  - цвет символа
;	 R3  - цвет фона
; Выход: 
;	 R1 - адрес видеопамяти следущего символа;	
function _draw_string
	push	r15

	lock
	set_mr	mr16, r0
	set_mr	mr18, r2

	mov	r4, r1
	load	r5, 0xffff
	and	r4, r5
	shl	r4, 5 	; это 2^5 = 32 = 8 pixels * 4 bytes per pixel

	load	r0, 40960	; 640 * 16 * 4
	shr	r1, 16		; high 16 bits
	call	_mul
	load	r1, 0x80000000
	clc
	addc	r1, r4
	addc	r1, r2
	
	get_mr	mr18, r2
	get_mr	mr16, r0
	unlock

	call	_draw_string_vga
	pop	r15
	return
end


; --- Функция вывода строки заданным цветом в видеопамять VGA адаптера
; Вход:  R0  - указатель на строку
;	 R1  - адрес в видеопамяти
;	 R2  - цвет символа
;	 R3  - цвет фона
; Выход: 
;	 R1 - адрес видеопамяти следущего символа;	

assign 	r4	counter
assign	r5	text_qword_ptr
assign  r6	chars

function _draw_string_vga
	push	r15
	mov	text_qword_ptr, r0		; Копирование указателя на строку

load_word:
	mov	chars, (text_qword_ptr)	; Загрузка машинного слова (4-символа)
	load	counter, 4		; Количество байт в машинном слове
;debug
check_byte:
	rol	chars, 8		; Циклический сдвиг на 8 бит влево
	load	r0, 0xff		; Загрузка восьмибитной константы
	and	r0, chars		; Проверка на конец строки
	je	done			; Вывод строки закончен
	lock
	set_mr	mr16, r4
	set_mr	mr17, r5
	set_mr	mr18, r6
	call	_draw_char    		; Вызов подпрограммы вывода символа
	get_mr	mr18, r6
	get_mr	mr17, r5
	get_mr	mr16, r4
	unlock

	inc	text_qword_ptr		; Инкремент указателя
	dec	counter			; Декремент счётчика
	jne	check_byte		; Следующий символ
;debug
	jmp	load_word		; Повтор операции
done:
	pop	r15
	return
end

include ../emulate/mul.asm
include ../emulate/div.asm
include draw_char.asm

; --- Функция вывода символа заданным цветом в видеопамять VGA адаптера
; Вход:  R0  - указатель на строку
;	 R1  - адрес в видеопамяти
;	 R2  - цвет символа
;	 R3  - цвет фона
; Выход: 
;	 R1 - адрес видеопамяти следущего символа;	

assign 	r4	counter
assign	r5	text_qword_ptr
assign  r6	chars

function _vga_puts_memory
	push	r15
	push	r13			; Чтобы не нарушать ABI
	mov	text_qword_ptr, r0	; Копирование указателя на строку
	load	r13, 0x3
	and	r13, r0
	je	load_word
	debug    ; невыровненные на границу байта строки. Отладка
	send

load_word:
	mov	chars, (text_qword_ptr)	; Загрузка машинного слова (4-символа)
	load	counter, 4		; Количество байт в машинном слове
;debug
check_byte:
	rol	chars, 8		; Циклический сдвиг на 8 бит влево
	load	r0, 0xff		; Загрузка восьмибитной константы
	and	r0, chars		; Проверка на конец строки
	je	done			; Вывод строки закончен
	cmp	r0, 0xd			; Перевод \r
	je	cr
	cmp	r0, 0xa			; Перевод \n
	je	lf
; рисовать символ
	push	counter
	push	text_qword_ptr
	push	chars
	push	r2
	call	_draw_char    		; Вызов подпрограммы вывода символа
	pop	r2
	pop	chars
	pop	text_qword_ptr
	pop	counter
comeback:
	dec	counter			; Декремент счётчика
	jne	check_byte		; Следующий символ
	inc	text_qword_ptr, 4	; Инкремент указателя
	jmp	load_word		; Повтор операции
cr:
	call    caretreturn
	jmp	comeback
lf:
	call	linefeed
	jmp	comeback
done:
	pop	r13
	pop	r15
	return
end

; --- Функция вывода символа заданным цветом в видеопамять VGA адаптера
; Вход:  R0  - указатель на строку
;	 R1  - YX - строка-столбец - старшие 16 бит номер строки, младшие 16 бит номер столбца
;	 R2  - цвет символа
;	 R3  - цвет фона
; Выход: 
;	 R1 - адрес видеопамяти следущего символа;	
function _vga_puts
	push	r15
	push	r0
	push	r2

	mov	r4, r1
	load	r5, 0xffff
	and	r4, r5
	shl	r4, 5 	; это 2^5 = 32 = 8 pixels * 4 bytes per pixel

	load	r0, 40960	; 640 * 16 * 4
	shr	r1, 16		; high 16 bits
	call	_mul
	load	r1, 0x80000000
	clc
	addc	r1, r4
	addc	r1, r2

	pop	r2
	pop	r0
	call	_vga_puts_memory
	pop	r15
	return
end

; Функция перевода строки
; Вход:
;	R1 - адрес в видеопамяти 
; Выход:
;	R1 - адрес в видеопамяти 

function linefeed
	load	r13, 40960	; 640 * 16 * 4bpp 
	clc
	addc	R1, r13 	; 10240 * 4bpp

	load	r13, 0x8012c000	; 0x80000000 + 24 * 16 * 640 
	clc
	subc	r13, r1                ; Проверка на границу видеопамяти
	jbe	scroll
exit:
	return
scroll:
	jmp	exit
end


; Возврат каретки
; Вход:
;	R1 - адрес в видеопамяти 
; Выход:
;	R1 - адрес в видеопамяти 
function caretreturn
	push	r15
	push	r2
;	push	r0
;debug
	load	r0, 0x80000000 ; Начало видеопамяти
	clc
	subc	r1, r0
	mov	r0, r1
	load	r1, 0
	load	r2, 40960
	call 	_safe_div64
	; В регистра R0 - номер текущей строки
;debug
	load	r1, 40960
	call	_mul 
	load	r1, 0x80000000 
	clc
	addc	r1, r2

;	pop	r0
	pop	r2
	pop	r15
	return
end
