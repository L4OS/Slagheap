; --- Точка входа при отладке. Она должна быть первой в файле
; Не должна вызываться программно и служит как тестовый заловок
function _test_string
	load	r14, 0x2000 ; set stack
	notch
	jmp	entry
entry:
end
; Не помещайте сюда данные - в тестовом режиме им будет передано управление

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

include ../mul.asm

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

function _vga_puts
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
	cmp	r0, 0xd			; Перевод \r
	jne	check_linefeed
; сюда кода
	jmp	next
check_linefeed:
	cmp	r0, 0xa			; Перевод \n
	call    caretreturn
	jne	draw
; сюда код
	call	linefeed
	jmp	next
draw:
	lock
	set_mr	mr16, r4
	set_mr	mr17, r5
	set_mr	mr18, r6
	call	_draw_char    		; Вызов подпрограммы вывода символа
	get_mr	mr18, r6
	get_mr	mr17, r5
	get_mr	mr16, r4
	unlock
next:
	inc	text_qword_ptr		; Инкремент указателя
	dec	counter			; Декремент счётчика
	jne	check_byte		; Следующий символ
;debug
	jmp	load_word		; Повтор операции
done:
	pop	r15
	return
end


; Функция перевода строки
; Вход:
;	R1 - адрес в видеопамяти 
; Выход:
;	R1 - адрес в видеопамяти 

function line_feed
;	cmp r1, ; 0x80000000 + 24 * 16 * 640 ; Скроллинг добавить
	clc
	addc	R1, 10240
	return
end

; --- Функция деления чисел (32/32) ----------------------
;
; Вход:
;	R0  - делимое (32-бита)
;	R2  - делитель
;
; Выход:
; 	R0 - частное
; 	R2 - остаток
; ---------------------------------------------------------

; Возврат каретки
; Вход:
;	R1 - адрес в видеопамяти 
; Выход:
;	R1 - адрес в видеопамяти 
function caretreturn
	push R0
	push R2
	push R3

	mov	r0, r1 
	load	r2, 10240
	call _div

	pop R3
	pop R2
	pop R0
	return
end
