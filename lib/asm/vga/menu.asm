function menu_test
	load	r14, 0x8000 ; установка вершины стека

	; Выбор шрифта по умолчанию
	lea	r7, $dosfont2
	call	_select_font

	lea	r0, $menu       ; R0 - текст меню
	load	r1, 0x80004000  ; R1 - адрес видеопамяти
	load	r2, 0x00000000	; R2 - цвет текста
	load	r3, 0xffffffff	; R3 - цыет фона

	call	_menu
	send
end

enable
$menu	db	'Первый \r\n'
	db	'Второй пункт\r\n'
	db	'Третий пункт\r\n'
	db	'Четвёртый пункт\r\n'
	db	'Пятый пункт\r\n'
	db	'Шестой пункт\r\n'
	db	'Седьмой пункт',0

else
$menu	db	'Test\r\nAgain\r\nThird test\nABC\n'
;$menu	db	'Ёлки\r\nWhat?\r\nЧто стряслось'0
done

$dosfont2		import		fonts/DK-Feoktistov-8x16.utf8.fnt 

include		draw_char.asm
include		get_event.asm

; --- Глобальное имя регистра ---
assign		r4	video_ptr
assign		r10	menu
assign		r12	align_counter


$reg_15			equ	15	; Адрес возврата 
$reg_13			equ	13	; Временный регистр 
$reg_12			equ	12	;  
$reg_11			equ	11	;
$utf_state		equ	10
$menu_start		equ	9
$word			equ	8
$max_chars		equ	7 	; Число символово в самой длинной строке
$lf_counter		equ	6
$cr_counter		equ	5
$index			equ	4
$background_color	equ	3
$color			equ	2	; Цвет символа
$video_memory		equ	1	; Адрес видеопаияти
$menu_ptr		equ	0	; Цвет фонв


; -- Менет цвет фона строки.
; Вход:
;	R10 - адрес структуры меню
;	R1 = новый цвет фона	
function		fill_menu_item_background
    assign	r2	pixel_width
    assign	r5	idx
    assign	r6	line_counter
	push	r15

	mov	pixel_width, menu.max_chars
	shl	pixel_width, 3
	clc
	load	video_ptr, 40992
	addc	video_ptr, menu.video_memory
	mov	idx, menu.index
	load	r13, 40960 
skip_loop:
	or	idx, idx
	je	address_found
	addc	video_ptr, r13
	dec	idx
	jne	skip_loop
address_found:
	mov	menu.word, video_ptr
	load	line_counter, 16
line_loop:
	load	video_ptr, 2560
	clc
	addc	video_ptr, menu.word
	mov	menu.word, video_ptr
	
	load	idx, 0
pixel_loop:
	mov	r3, (video_ptr)
	cmp	r3, menu.color
	je	next_pixel
	mov	(video_ptr), r1
next_pixel:
	inc	video_ptr, 4 
	inc	idx
	cmp	idx, pixel_width
	jne	pixel_loop
	dec	line_counter
	jne	line_loop
	pop	r15
	return
end

; --- МЕНЮ ВЕРТИКАЛЬНОЕ ---
; Вход: 
;	R0  - указатель на строку меню
;	R1  - адрес в видеопамяти
;	R2  - цвет символа
;	R3  - цвет фона
function _menu
    assign	r14	stack_pointer	; Указатель на вершину стека
	dec	stack_pointer, 16
	dec	stack_pointer, 16
	dec	stack_pointer, 16
	dec	stack_pointer, 16
	; Сохранение старших регистров по ABI
	mov	stack_pointer.reg_15, r15
	mov	stack_pointer.reg_13, r13
	mov	stack_pointer.reg_12, align_counter
	; Сохранение регистровых параметров функции
	mov	stack_pointer.menu_ptr, r0
	mov	stack_pointer.menu_start, r0
	mov	stack_pointer.video_memory, r1
	mov	stack_pointer.color, r2
	mov     stack_pointer.background_color, r3

	mov	r10, stack_pointer
	push	r1
	call	_draw_menu
	pop	r1
	mov	stack_pointer.video_memory, r1

	mov	stack_pointer.index, 0
	mov	r10, stack_pointer
	load	r1, 0xcf85c0ff
	call	fill_menu_item_background
	

again:
	load	r3, 0xfffeffe0	; Адрес порта управления терминалом
	mov	(r3), r0	; Обновить экран записью в порт

	load	r0, 3000 	; Ждать событие 3 секунды
	call	_get_event	; 
	or	r0, r0
	je	again           ; Если таймаут, снова ждать

	cmp	r0, 0x102
	jne	again		; Только клвиатуру слушаем

	load	r1, 0xfffeffe8	; WINDOW_WPARAM порт. После прихода события в нём хранится W-param события
	mov	r0, (r1)	; Чтение с порта хранящего код нажатой клавиши

	cmp	r0, 0x1b	; Клавиша Esc
	jne	check_enter
	load	r0, -1
	jmp	finish
check_enter:
	cmp	r0, 0xd		; Клавиша Enter
	jne	check_a
	mov	r0, stack_pointer.index
	jmp	finish
check_a:	
	cmp	r0, 0x1f ; Клавиша вниз
	jne	n2
	mov	r1, stack_pointer.background_color
	call	fill_menu_item_background
	mov	r1, stack_pointer.index
	inc	r1
	cmp	stack_pointer.lf_counter, r1
	jl	down_ok
	xor	r1, r1
down_ok:
	mov	stack_pointer.index, r1
	load	r1, 0xcf85c0ff
	call	fill_menu_item_background
	jmp	again	
n2:
	cmp	r0, 0x1e ; Клавиша вверх
	jne	show_key

	load	r1, 0xffffffff
	call	fill_menu_item_background
	load	r1, 1
	clc
	subc	stack_pointer.index, r1
	jnc	up_ok
	mov	r1, stack_pointer.lf_counter
	mov	stack_pointer.index, r1
up_ok:
	load	r1, 0xcf85c0ff
	call	fill_menu_item_background
	jmp	again	

show_key:
;	call	_print_dec
	jmp	again
finish:
	mov	align_counter, stack_pointer.reg_12 
	mov	r13, stack_pointer.reg_13
	mov	r15, stack_pointer.reg_15

	inc	stack_pointer, 16
	inc	stack_pointer, 16
	inc	stack_pointer, 16
	inc	stack_pointer, 16
	return
end

; --- Рисует символ в текущей позиции укранного буфера ---
; Вход:
;	R11 - указатель на видеопамять
;	R13 - указатель на структуру menu
function draw_char_ptr
	push	r15
	mov	r3, menu.background_color
	mov	r1, video_ptr	
	call	_draw_char
	mov	video_ptr, r1
	pop	r15
	return
end

function _draw_menu
;    assign	r14	stack_pointer	; Указатель на вершину стека
    assign	r13	slopper
;;;    assign	r11	video_ptr
    assign	r4	chars_counter
;    assign	r5	cr_counter
;    assign	r6	index
;    assign	r7	max_chars
;    assign	r10	utf_state
	push	r15
	xor	r0, r0
	mov	menu.utf_state, r0
	mov	menu.cr_counter, r0
	mov	menu.lf_counter, r0
	mov	menu.max_chars, r0
	mov	video_ptr, menu.video_memory
	mov	chars_counter, r0
l0:
	mov	slopper, menu.menu_ptr               
	mov	r0, (r13)  ; Не работает: (slopper)
	load	align_counter, 4
l1:
     	rol	r0, 8			; Циклический сдвиг на 8 бит влево
	cmp	menu.utf_state, 0
	jne	second_utf_state	; Конечный автомат
	load	r3, 0xff
	and	r3, r0
	jz	draw_header
	cmp	r3, 0xd
	je	cr
	cmp	r3, 0xa
	je 	lf
	cmp	r3, 0x80
	jnc	check_unicode
	inc	chars_counter
	jmp	next_char
cr:
	addc	menu.cr_counter, 1
	cmp	menu.max_chars, chars_counter
	jnc	skip_1
	mov	menu.max_chars, chars_counter
skip_1:
	load	chars_counter, 0
	jmp	next_char
	
lf:
	addc	menu.lf_counter, 1
	cmp	menu.max_chars, chars_counter
	jnc	skip_2
	mov	menu.max_chars, chars_counter
skip_2:
	load	chars_counter, 0
	jmp	next_char

check_unicode:
	load	r8, 0xe0
	and	r8, r0
	cmp	r8, 0xc0
	je	tww_bytes_enconding

	load	r8, 0xf0
	and	r8, r0
	cmp	r8, 0xe0
	je	three_bytes_encoding

	load	r8, 0xf8
	and	r8, r0
	cmp	r8, 0xe0
	je	four_bytes_encoding
error:
	load	r0, -1
	jmp	exit_from_function

;--- Кодирования двумя байтами
tww_bytes_enconding:
	load	r9, 0x1f
	and	r9, r0
	mov	menu.utf_state, 1
	jmp	next_char

second_utf_state:
	load	r8, 0xc0
	and	r8, r0
	cmp	r8, 0x80
	jne	error		; Сигнатура не соответствует

	shl	r9, 6		; В этом месте в регистре R9 биты 10..6
	load	r8, 0x3f
	and	r8, r0		; В этом месте в регистре R0 биты 5-0
	or	r9, r8		; В этом месте в регистре R9 код символа
	load	slopper, 1
	subc	menu.utf_state, slopper
	jnz	next_char
	inc	chars_counter
	; Тут можно положить символ в буффервр
	jmp	next_char

; --- Кодирование тремя байтами
three_bytes_encoding:
	load	r9, 0x0f
	and	r9, r3
	load	menu.utf_state, 2
	jmp	next_char
	

; --- Кодирование четырьмя байтами
four_bytes_encoding:
	load	r9, 0x07
	and	r9, r3
	load	menu.utf_state, 3
	jmp	next_char
	
next_char:	
	dec	align_counter
	jnz	l1
	load	slopper, 4
	addc	menu.menu_ptr, slopper
	jmp	l0

draw_header:
;debug
	mov	r13, menu.max_chars
	cmp	chars_counter, menu.max_chars
	jc	found_width
	mov	menu.max_chars, chars_counter
found_width:
	mov	video_ptr, menu.video_memory
	load	r0, 0xe3  ; ╔
	call	draw_char_ptr
	mov	r4, menu.max_chars
header_loop:
	push	r4
	load	r0, 0xe8  ; ═
	call	_draw_char
	pop	r4
	dec	r4
	jnz	header_loop	
	load	r0, 0xe6  ; ╗
	call	_draw_char

; Рисование пунктов меню
	mov	r13, menu.menu_start
	mov	menu.menu_ptr, r13
	mov	r13, menu.max_chars
	mov	menu.index, r13
line_loop:
	load	video_ptr, 40960				; 640 * 16 * 4bpp 
	clc
	addc	video_ptr, menu.video_memory 	; 10240 * 4bpp
	mov	menu.video_memory, video_ptr

	load	r0, 0xef  ; ║
	mov	r1, video_ptr
	call	_draw_char
	mov	video_ptr, r1

draw_four:
	mov	r13, menu.menu_ptr 
	mov	r0, (r13) ; Вот эта форма не среботала: (slopper) Поправить!!!
	load	align_counter, 4
draw_character:
     	rol	r0, 8					; Циклический сдвиг на 8 бит влево
	cmp	menu.utf_state, 0
	jne	draw_utf_state				; Конечный автомат
	load	r3, 0xff
	and	r3, r0
	jz	draw_footer
	cmp	r3, 0x0d
	je	draw_cr
	cmp	r3, 0x0a
	je 	draw_lf
	cmp	r3, 0x80
	jnc	draw_unicode
	

	mov	menu.word, r0
	mov	r0, r3
	mov	r1, video_ptr	
	mov	r2, menu.color
	mov	r3, menu.background_color
	call	_draw_char
	clc
	subc	menu.index, 1
	jc	error
	mov	video_ptr, r1	
	mov	r0, menu.word
	jmp	draw_next_char
draw_cr:
	jmp	draw_next_char
draw_lf:
	mov	menu.word, r0
spaces:
	clc
	subc	menu.index, 1
	jc	right_position
	load	r0, 0x20
	call	draw_char_ptr
	jmp	spaces			

right_position:
	load	r0, 0xef  ; ║
	call	draw_char_ptr

	load	r0, 40960				; 640 * 16 * 4bpp 
	clc
	addc	r0, menu.video_memory 	; 10240 * 4bpp
	mov	menu.video_memory, r0
	mov	r1, r0	
	load	r0, 0xef  ; ║
	call	_draw_char
	mov	video_ptr, r1
	mov	r13, menu.max_chars
	mov	menu.index, r13
	mov	r0, menu.word
	jmp	draw_next_char

draw_unicode:
	load	r8, 0xe0
	and	r8, r0
	cmp	r8, 0xc0
	je	draw_two_bytes

	load	r8, 0xf0
	and	r8, r0
	cmp	r8, 0xe0
	je	draw_three_bytes

	load	r8, 0xf8
	and	r8, r0
	cmp	r8, 0xe0
	je	draw_four_bytes

draw_error:
	load	r0, -1
	jmp	exit_from_function

;--- Кодирования двумя байтами
draw_two_bytes:
	load	r9, 0x1f
	and	r9, r0

	mov	menu.utf_state, 1
	jmp	draw_next_char

draw_utf_state:
	load	r8, 0xc0
	and	r8, r0
	cmp	r8, 0x80
	jne	draw_error		; Сигнатура не соответствует

	shl	r9, 6		; В этом месте в регистре R9 биты 10..6
	load	r8, 0x3f
	and	r8, r0		; В этом месте в регистре R0 биты 5-0
	or	r9, r8		; В этом месте в регистре R9 код символа
	load	slopper, 1
	subc	menu.utf_state, slopper
	jnz	draw_next_char
;	inc	chars_counter
	; Тут можно положить символ в буффервр
	mov	menu.word, r0
	load	slopper, 0x380 ; 0x400
	mov	r0, r9
	clc
	subc	r0, slopper
	jc	substitute_char
	load	slopper, 0xff
	subc	slopper, r0
	jnc     character_successfully_translated
substitute_char:
	load	r0, 0x0f	; https://en.wikipedia.org/wiki/Shift_Out_and_Shift_In_characters
character_successfully_translated:
 	call	draw_char_ptr
	clc
	subc	menu.index, 1
	mov	r0, menu.word

	jmp	draw_next_char

; --- Кодирование тремя байтами
draw_three_bytes:
	load	r9, 0x0f
	and	r9, r3
	load	menu.utf_state, 2
	jmp	draw_next_char
	

; --- Кодирование четырьмя байтами
draw_four_bytes:
	load	r9, 0x07
	and	r9, r3
	load	menu.utf_state, 3
	jmp	draw_next_char
	
draw_next_char:	
	dec	align_counter
	jnz	draw_character
	load	slopper, 4
	addc	menu.menu_ptr, slopper
	jmp	draw_four
	

draw_footer:
	mov	menu.word, r0

final_spaces:
	clc
	subc	menu.index, 1
	jc	final_right_position
	load	r0, 0x20
	call	draw_char_ptr
	jmp	final_spaces			
final_right_position:
	load	r0, 0xef  ; ║
	call	draw_char_ptr

	mov	r0, menu.word

	load	video_ptr, 40960				; 640 * 16 * 4bpp 
	clc
	addc	video_ptr, menu.video_memory 	; 10240 * 4bpp
	mov	menu.video_memory, video_ptr

	load	r0, 0xf3  ; ╚
	call	draw_char_ptr

	mov	r6, menu.max_chars

footer_loop:
	mov	menu.word, r6
	load	r0, 0xe8  ; ═
	call	draw_char_ptr
	mov	r6, menu.word
	dec	r6
	jnz	footer_loop	

	load	r0, 0xf6  ; ╝
	call	draw_char_ptr

exit_from_function:
	pop	r15
	return
end
