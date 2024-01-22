function test_yesno
	load	r14, 0x8000 ; установка вершины стека
	lea	r7, $dosfont2 ; Выбор шрифта по умолчанию
	call	_select_font

	lea	r0, $header
	load	r1, 0x80020000
	lea	r2, $question
	call	_yesno_win
	send
end

$header		db	' Заголовок диалога  ',0
$question	db	'Тест завершён?   ', 0
$yes		db	' ',0x10,'  Да   ',0
$no		db	'   Нет   ',0

$dosfont2		import		fonts/DK-Feoktistov-8x16.utf8.fnt 

include		../string/get_utf8_char.asm
include		get_event.asm
include		draw_char.asm

$hdr	equ	0
$video	equ	1
$text	equ	2
$buff	equ	3
$count	equ	4
$retadr	equ	5
$spccnt	equ	6
$keypos	equ	7
$select equ	8

assign	r5	buffer_ptr
assign	r4	len
assign	r3 	local

; Функция трансляции utf-8 в буфер в utf32
; Вход:
;	R0 - адрес utf8 текста
;	R5 - buffer_ptr, т.е. адрес буфера для трасляции в формат utf32
; Выход:
;	R0 - количество символов в буфере
function translate_utf8
	push	r15
	push	local
	push	r1
	load	len, 0
translator_loop:
	push	buffer_ptr
	push	len
	call	_get_utf8_character
	pop	len
	pop	buffer_ptr
	or	r0, r0
	je	finish
	mov	(buffer_ptr), r0
	mov	r0, r1
	inc	len
	inc	buffer_ptr, 4 ; Проверка на переполенение не помешает, а её нет :(
	jmp	translator_loop
finish:
	load	r0, 0
	mov	(buffer_ptr), r0	
	mov	r0, len	
	pop	r1
	pop	local
	pop	r15
	return
end

function draw_character
	push	r15
	push	local
	call	_draw_char
	pop	local
	pop	r15
	return
end

function caret_return
	load	len, 40960
	clc
	addc	local.video, len
	mov	r1, local.video
	return
end

; Вход:
;	R12 - текст кнопки
;	R11 - цвет фона кнопки
function draw_button
	push	r15
	push	r2
	push	local
button_text_loop:                
	mov	r0, (r12)
	or	r0, r0
	je	finish
	mov	r3, r11
	load	r2, 0ff0f8080
	call	_draw_char
	inc	r12, 4
	jmp	button_text_loop	
finish:
	pop	local
	pop	r2
	pop	r15
	return
end

function draw_yesno
	push	r15
	mov	r1, local.keypos
	lea	r0, $yes
	mov	buffer_ptr, local.buff
	call	translate_utf8
	mov	r12, local.buff
	load	r11, -1
	cmp	local.select, 1
	je	draw_yes
	load	r11, 0xcccccccc
draw_yes:
	call	draw_button

	mov	r12, local.spccnt
	shl	r12, 1
second_block:
	load	r0, 32  ; ║
	call	draw_character
	dec	r12
	jnz	second_block

	lea	r0, $no
	mov	buffer_ptr, local.buff
	call	translate_utf8
	mov	r12, local.buff
	load	r11, 0xcccccccc
	cmp	local.select, 1
	je	draw_no
	load	r11, -1
draw_no:
	call	draw_button
	pop	r15
	return
end

function draw_buttons
	push	r15
	load	r0, 0xee  ; ║
	call	draw_character
;debug
	mov	r0, local.count
	load	r13, 17 ; ширина двух кнопок - Да и Нет
	clc
	subc	r0, r13
	shr	r0, 2 ; Деление оставшего пространства на 4 части
	mov	local.spccnt, r0 ; Сохранение  количества пробелов
	
	mov	r12, r0
;send
first_block:
	load	r0, 32  ; ║
	push	r12
	call	draw_character
	pop	r12
	dec	r12
	jnz	first_block

	mov	local.keypos, r1

	call	draw_yesno

	mov	r12, local.spccnt
third_block:
	load	r0, 32  ; ║
	call	draw_character
	dec	r12
	jnz	third_block

	load	r2, -1
	load	r0, 0xee  ; ║
	call	draw_character

	pop	r15
	return
end

function draw_empty_spaces
	push	r15
	call	caret_return
	load	r0, 0xee  ; ║
	call	draw_character

	mov	r11, local.count
empty_loop:
	push	local
	load	r0, 32 ; Код пробела
	call	_draw_char
	pop	local
	dec	r11
	jnz	empty_loop
	
	load	r0, 0xee  ; ║
	call	draw_character

	pop	r15
	return
end

function draw_bottom_line
	push	r15
	call	caret_return
	load	r0, 0xf0; 0xf3  ; ╚
	call	draw_character
final_loop:
	mov	r13, local.count
	or	r13, r13
	jz	so_tired	

	load	r0, 0xf8; 0xe8  ; ═
	call	draw_character
;	load	r13, 1
;	clc
; Тут ломает флаги, надо разобраться
;	subc	local.count, r13
;debug
	dec	r13
	mov	local.count, r13
	jmp	final_loop
;send
so_tired:
	load	r0, 0xf2; 0xf6  ; ╝
	call	draw_character

	pop	r15
	return
end

; Вход
;	R0 - указатель на заголовок
;	R1 - адрес видеопамяти окна
;	R2 - указатель на текст окна
; Выход:
;	R0 - 0 = escqpe, 1 = yes, 2 = no,  
function _yesno_win
    assign	r14	stack_pointer
	dec	stack_pointer, 16
	dec	stack_pointer, 16
	dec	stack_pointer, 16
	mov	local, stack_pointer
	mov	local.retadr, r15
	mov	local.hdr, r0
	mov	local.video, r1
	mov	local.text, r2
	load	len, 1
	mov	local.select, len
	load	len, 320 ; Размер буфера на 80 символов
	subc	stack_pointer, len
	mov	buffer_ptr, stack_pointer
	mov	local.buff, buffer_ptr

	call	translate_utf8
	mov	local.count, r0

	mov	r1, local.video
	load	r2, -1

	load	r0, 0xfe; 0xe3  ; ╔
	call	draw_character
	load	r11, 2
left:
	load	r0, 0x85; 0xe3  ; ╔
	call	draw_character
	dec	r11
	jnz	left

	load	r12, 6
	addc	local.count, r12
	mov	r12, local.buff
hdr_draw_loop:                
	mov	r0, (r12)
	or	r0, r0
	je	hdr_right_corner
	push	local
	push	r2
	load	r3, -1
	load	r2, 0ff0f8080
	call	_draw_char
	pop	r2
	pop	local
	inc	r12, 4
	jmp	hdr_draw_loop	
hdr_right_corner:

	load	r11, 3
right:
	load	r0, 0x85;0xe6  ; ╗
	call	draw_character
	dec	r11
	jnz	right
	load	r0, 0xf8; 0xfd;0xe6  ; ╗
	call	draw_character
	load	r0, 0xe2; 0xfd;0xe6  ; ╗
	call	draw_character
	call	draw_empty_spaces

	call	caret_return
	load	r0, 0xee  ; ║
	call	draw_character

	mov	r0, local.text
	mov	buffer_ptr, local.buff
	call	translate_utf8
	cmp	local.count, r0
	jnc	keep_count
	mov	local.count, r0
	jmp	enter_text_draw
keep_count:
	clc
	subc	r0, local.count
	je	enter_text_draw
	mov	r11, r0
back_loop:
	load	r0, 32 ; Код пробела
	call	draw_character
	inc	r11
	jnz	back_loop
enter_text_draw:
	mov	r12, local.buff
	load	r2, -1
body_draw_loop:
	mov	r0, (r12)
	or	r0, r0
	je	finish_text
	call	draw_character
	inc	r12, 4
	jmp	body_draw_loop
finish_text:
	load	r0, 0xee  ; ║
	call	draw_character

	call	draw_empty_spaces
	call	caret_return
	call	draw_buttons
	call	draw_empty_spaces
	call	draw_bottom_line

again:
	push	local
	load	r3, 0xfffeffe0	; Адрес порта управления терминалом
	mov	(r3), r0	; Обновить экран записью в порт
	load	r0, 3000 	; Ждать событие 3 секунды
	call	_get_event	; Ждать клавиатуру или мышь или таймаут
	pop	local 
	or	r0, r0
	je	again           ; Если таймаут, снова ждать

	cmp	r0, 0x102
	jne	again		; Только клвиатуру слушаем

	load	r1, 0xfffeffe8	; WINDOW_WPARAM порт. После прихода события в нём хранится W-param события
	mov	r0, (r1)	; Чтение с порта хранящего код нажатой клавиши

	cmp	r0, 0x1b	; Клавиша Esc
	jne	check_enter
	load	r0, -1
	mov	local.select, r0
	jmp	finish

check_enter:
	cmp	r0, 0xd		; Клавиша Enter
	je	finish

check_a:	
	cmp	r0, 0x09 ; Клавиша Табуляция
	je	swap_yesno
	cmp	r0, 0x1c ; Клавиша влево
	je	swap_yesno
	cmp	r0, 0x1d ; Клавиша вправо
	jne	n2
swap_yesno:
	mov	r0, local.select
	inc	r0
	load	r1, 1
	and	r0, r1
	mov	local.select, r0
;jmp fixed
;;debug
	or	r0, r0
	je	fix_buttons
	lea	r0, $no
	load	r13, 0xff00ffff
	and	(r0), r13
	load	r13, 0x00200000
	or	(r0), r13
mov r12, (r0)
	lea	r0, $yes
	load	r13, 0xff00ffff
	and	(r0), r13
	load	r13, 0x00100000
	or	(r0), r13
mov r12, (r0)
	jmp	fixed
fix_buttons:
	lea	r0, $yes
	load	r13, 0xff00ffff
	and	(r0), r13
	load	r13, 0x00200000
	or	(r0), r13
mov r12, (r0)
	lea	r0, $no
	load	r13, 0xff00ffff
	and	(r0), r13
	load	r13, 0x00100000
	or	(r0), r13
mov r12, (r0)
fixed:
;;send
	call	draw_yesno
	jmp	again	
n2:

	jmp	again

finish:
	mov	r0, local.select
	
	load	len, 320 ; Размер буфера на 80 символов
	clc
	addc	stack_pointer, len
	inc	stack_pointer, 16
	inc	stack_pointer, 16
	inc	stack_pointer, 16
	mov	r15, local.retadr
	return
end
