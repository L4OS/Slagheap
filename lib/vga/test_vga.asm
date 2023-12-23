function	_init_vga
	load	r14, 0x8000 ; set stack
	notch
	jmp	entry
entry:
end

function	_test_vga
enter:
	push	r15
	
	lock
	set_mr	mr32, r1	; Тест регистров сообщений
	get_mr  mr32, r7
	unlock

	; Выбор шрифта по умолчанию
	lea	r7, $dosfont1
	call	_select_font

help:
	lea	r1, $line1	; Адрес строки приветсвия в R1
	call	_puts		; Вывод данных в UART
;debug
	lea	r0, $line1	; Адрес строки приветствия в R1
	load	r1, 0x00100000	; Позиция на экране - старшие 16 бит номер строки, младшие - номер столбца
	load	r2, 0xFFFFFFFF  ; Цвет пикселей
	load	r3, 0x00000000  ; Цвет фона
	call 	_draw_string

	lea	r0, $line2	; Адрес строки приветствия в R1
	load	r1, 0x00110000	; Позиция на экране - старшие 16 бит номер строки, младшие - номер столбца
	load	r2, 0xFFFFFFFF  ; Цвет пикселей
	load	r3, 0x00000000  ; Цвет фона
	call 	_vga_puts
;	call 	_draw_string

loop:
	load	r3, 0xfffeffe0	; Обновлене экрана пока не вынесено в функцию
	mov	(r3), r0	; Обновить экран перед чтением клавиатуры

;	call	_getchar	; Ввод символа с терминала
	call	_get_key	; Ввод символа с графического окна

	cmp	r0, 0x30
	je	exit
	cmp	r0, 0x3f	; Клавиша Вопрос
	je	help

	cmp	r0, 0x31	; Клавиша 1
;	notch
;	je	_clear_vga_screen  ; Надо дорабатывать компилятор ассемблера чтобы оптимизировать
 	jne	lab1
	call	_clear_vga_screen
	jmp	loop				
lab1:
lab2:
	cmp	r0, 0x32
	jne	lab3
	lea	r7, $dosfont1
	call	_select_font
	call	_test_chars
	jmp	enter
lab3:
	cmp	r0, 0x33
	jne	lab4
	lea	r7, $dosfont2
	call	_select_font
	call	_test_chars
	jmp	enter
lab4:
	cmp	r0, 0x34
	jne	lab5
	lea	r7, $dosfont3
	call	_select_font
	call	_test_chars
	jmp	enter
lab5:
	cmp	r0, 0x35
	jne	lab6
	lea	r7, $dosfont4
	call	_select_font
	call	_test_chars
	jmp	enter
lab6:
	cmp	r0, 0x36
	jne	lab7
	lea	r7, $dosfont5
	call	_select_font
	call	_test_chars
	jmp	enter
lab7:
	cmp	r0, 0x37
	jne	lab8
	lea	r7, $dosfont6
	call	_select_font
	call	_test_chars
	jmp	enter
lab8:
	cmp	r0, 0x38 ; key 8
	jne	lab9
	load 	r0, 16
	call	_shift_screen_vertically
	jmp	loop
lab9:

	cmp	r0, 0x39 ; 'key 9'
	jne	lab10
	load 	r0, -16
	call	_shift_screen_vertically
	jmp	loop
lab10:


	cmp	r0, 0x5b ; key [
	jne	lab11
	load 	r0, 8
	call	_shift_screen_horizontally
	jmp	loop
lab11:

	cmp	r0, 0x5d ; 'key ['
	jne	lab12
	load 	r0, -8
	call	_shift_screen_horizontally
	jmp	loop
lab12:



	jmp	loop
exit:
	pop	r15
	return			; Возврат из функции
end


$line1 	db	'1 - clear vga screen  ',13,10  ,0 
$line2	db	'2 - CYRTHIN-Nesterenko-8x16   ',13,10,
$line3	db	'3 - DK-Feoktistov-8x16',13,10
	db	'4 - beta-Chi-Sovt-8x16',13,10
	db	'5 - EDFN-Anry-VGA3-8x16   ',13,10
	db	'6 - MYFONT-8x16   ',13,10
	db	'7 - Goryachev-UNI_8X16',13,10,
	db	'8 - scroll screen down',13,10,
	db	'9 - scroll screen up',13,10,
	db	'0 - exit to prev menu',13,10,0

; VGA 640x480x32
include		clear_screen.asm
include		draw_char.asm
include		draw_string.asm
include		get_key.asm
include		scroll.asm

include		../tty/tty.asm
include		../emulate/div.asm

$dosfont1		import		fonts/CYRTHIN-Nesterenko-8x16.fnt 
$dosfont2		import		fonts/DK-Feoktistov-8x16.fnt 
$dosfont3		import		fonts/beta-Chi-Sovt-8x16.fnt   
$dosfont4		import		fonts/EDFN-Anry-VGA3-8x16.FNT  
$dosfont5		import		fonts/MYFONT-8x16.FNT   
$dosfont6		import		fonts/Goryachev-UNI_8X16.fnt    

function _test_chars
	push	r15
	load 	r8, 0
	load 	r9, 256
	load 	r1, 0x80000000
	mov	r13, r1
	load	r11, 32
loop:
	mov 	r1, r13		; Начало строки
next_pos:
	mov	r0, r8
	load	r2, 0xffffffff
	load	r3, 0x00000000
	mov	r12, r1
	call	_draw_char
	dec	r11
	je	newline
	mov	r1, r12
	inc	r1, 16
	inc	r1, 16
	inc	r8
	dec	r9
	jz	exit
	jmp	next_pos
newline:
	load	r11, 40960 ; 640 * 4 * 16
	clc
	addc	r13, r11
	load	r11, 32	
next:	
	inc	r8
	dec	r9
	jnz	loop	
exit:
	pop	r15
	return
end

