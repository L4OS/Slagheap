function	init_vga
	load	r14, 0x8000 ; set stack
	notch
	call	_test_vga
	send
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

	load	r0, 1000 	; Ждать событие 1000 мс
	call	_get_event	; Ввод символа с графического окна
	or	r0, r0
	je	timeout
	load	r6, 0x102	; Ввод символа
	cmp	r0, r6
	jne	l1
    ;   ---- обработка события клавиатуры
	load	r1, 0xfffeffe8	; WINDOW_WPARAM порт. После прихода события в нём хранится W-param события
	mov	r0, (r1)	; Чтение с порта хранящего код нажатой клавиши
	call	_input_char_callback
	jmp	loop
l1:
	load	r6, 0x202	; Отпустили клавишу мыши
	cmp	r0, r6
	jne	loop		; Игнорируем остальные события
    ;   ---- печать позиции отпускания клавиши мыши

	lea	r1, $line1	; Адрес строки приветсвия в R1
	call	_puts		; Вывод данных в UART
	load	r0, 0xfffeffe8	; WINDOW_WPARAM порт. После прихода события в нём хранится W-param события
	mov	r0, (r1)	; Чтение с порта хранящего код нажатой клавиши
	call	_print_hex
	load	r0, 0xfffeffec	; WINDOW_WPARAM порт. После прихода события в нём хранится W-param события
	mov	r0, (r0)	; Чтение с порта хранящего код нажатой клавиши
	call	_print_hex

	jmp	loop
timeout:
	jmp	loop
exit:
	pop	r15
	return			; Возврат из функции
end

$MOUSE_TEXT1	db	'Mouse button W param: ',0
$MOUSE_TEXT2	db	'Mouse button W param: ',0

; Вход: R0 - код нажатой клавиши
function _input_char_callback
	push	r15
	cmp	r0, 0x30
	je	exit
;	cmp	r0, 0x3f	; Клавиша Вопрос
;	je	help

	cmp	r0, 0x31	; Клавиша 1
;	notch
;	je	_clear_vga_screen  ; Надо дорабатывать компилятор ассемблера чтобы оптимизировать
 	jne	lab1
	call	_clear_vga_screen
	jmp	exit
lab1:
lab2:
	cmp	r0, 0x32
	jne	lab3
	lea	r7, $dosfont1
	call	_select_font
	call	_test_chars
	jmp	exit
lab3:
	cmp	r0, 0x33
	jne	lab4
	lea	r7, $dosfont2
	call	_select_font
	call	_test_chars
	jmp	exit
lab4:
	cmp	r0, 0x34
	jne	lab5
	lea	r7, $dosfont3
	call	_select_font
	call	_test_chars
	jmp	exit
lab5:
	cmp	r0, 0x35
	jne	lab6
	lea	r7, $dosfont4
	call	_select_font
	call	_test_chars
	jmp	exit
lab6:
	cmp	r0, 0x36
	jne	lab7
	lea	r7, $dosfont5
	call	_select_font
	call	_test_chars
	jmp	exit
lab7:
	cmp	r0, 0x37
	jne	lab8
	lea	r7, $dosfont6
	call	_select_font
	call	_test_chars
	jmp	exit
lab8:
	cmp	r0, 0x38 ; key 8
	jne	lab9
	load 	r0, 16
	call	_shift_screen_vertically
	jmp	exit
lab9:

	cmp	r0, 0x39 ; 'key 9'
	jne	lab10
	load 	r0, -16
	call	_shift_screen_vertically
	jmp	exit
lab10:
	cmp	r0, 0x5b ; key [
	jne	lab11
	load 	r0, 8
	call	_shift_screen_horizontally
	jmp	exit
lab11:

	cmp	r0, 0x5d ; 'key ['
	jne	lab12
	load 	r0, -8
	call	_shift_screen_horizontally
	jmp	exit
lab12:

exit:	pop	r15
	return
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
include		lib/asm/vga/clear_screen.asm
include		lib/asm/vga/draw_char.asm
include		lib/asm/vga/draw_string.asm
include		lib/asm/vga/get_event.asm
include		lib/asm/vga/scroll.asm

include		lib/asm/tty/tty.asm
include		lib/asm/emulate/div.asm

$dosfont1		import		lib/asm/vga/fonts/CYRTHIN-Nesterenko-8x16.fnt
$dosfont2		import		lib/asm/vga/fonts/DK-Feoktistov-8x16.fnt
$dosfont3		import		lib/asm/vga/fonts/beta-Chi-Sovt-8x16.fnt
$dosfont4		import		lib/asm/vga/fonts/EDFN-Anry-VGA3-8x16.FNT
$dosfont5		import		lib/asm/vga/fonts/MYFONT-8x16.FNT
$dosfont6		import		lib/asm/vga/fonts/Goryachev-UNI_8X16.fnt

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

