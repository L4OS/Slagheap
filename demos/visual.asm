assign		r11	dot_step
assign 		r12	text_ptr
assign		r10	buffer_ptr
;assign		r1	this

;$buffer_ptr	equ	0
$text_ptr	equ	1

function visual_test
	load	r14, 0x8000 ; установка вершины стека

	load	r0, 32
	clc
	subc	r14, r0
;	mov	this, r14

	load	r0, 320	    ; Размер буфкера с индексами символов	
	clc
	subc	r14, r0
	mov	buffer_ptr, r14

	lea	r0, $message
;	mov	this.text_ptr, r0
	lea	r0, $hello
	lea	text_ptr, $message
	load	dot_step, 8
	load	r2, 0xffffffff
	load	r3, 0x552a552a
loop:
inner_loop:
	push	buffer_ptr
	push	r2
	push	r3
	call	_get_utf8_character
	pop	r3
	pop	r2
	pop	buffer_ptr
	cmp	r0, 0xa
	je	line_feed
	or	r0, r0
	je	done
	mov	(buffer_ptr), r0
	inc	buffer_ptr, 4
	mov	r0, r1
	jmp	inner_loop
line_feed:
;debug
	load	r0, 0
;;;;;	inc	r1
	mov	text_ptr, r1
	mov	(buffer_ptr), r0	; Нуль - терминатор
	mov	buffer_ptr, r14
	jmp	inside
done:
	mov	(buffer_ptr), r0	; Нуль - терминатор
inside:
;	lea	r0, $hello
;	clc
;	subc	char_count, r0
	mov	r0, r14
	push	r1
	push	r2
	push	r3
;	push	this.text_ptr
	call	draw_line
;	pop	this.text_ptr
	pop	r3
	pop	r2
	pop	r1
	or	r0, r0
	jne	exit
	mov	buffer_ptr, r14
;	lea	r0, $message
	mov	r0, text_ptr
;debug
	load	r2, 0xff00ffff
	load	r3, 0x552a552a   ; 0xff00ff00 : 0x552a552a
	load	dot_step, 4
	jmp	loop
exit:
	send
end


enable
$hello		db	'Slagheap SoC emulator Demo', 0
$message	db	' \n'
		db	'Здравствуй, дорогой друг!\n \n'
		db	'Я - демонстрационная программа для системы на кристалле "Террикон".\n'
		db	'Я представляю собой виртуальный 32-х битный компьютер с 16 килобайтами\n'
		db	'оперативной памяти, которая разделяется между программами, данными'
		db	' и стеком.\n \n'
		db	'На борту у меня так же присутствует алфавитно-цифровой терминал. Доступ\n'
		db	'к нему можно получить покопавшись в диреектории lib/asm/tty/ - в ней\n'
		db	'находятся библиотечные функции для работы с терминалом.\n'
		db	' \n'
		db	'Но это ещё не всё, обрати внимание на папку lib/asm/vga/ - твой новый \n'
		db	'вирутальный компьютер имеет на борту мощнейший, по меркам двадцатилетней\n'
		db	'давности, терминал Super VGA 640x480 точек c 32-мя битами на\n'
		db	'пиксель - настоящий TrueColor!\n \n'
		db	'Терминал позволяет читать клавиутуру, ловить щелчки мыши и ожидать эти события\n'
		db	'Терминал позволяет "аппаратный сдвиг" - достатчно записать\n'
		db	'знаковое число в определёный порт и содержимое экрана сдвинется на это\n'
		db	'количество пикселей. Именно так я сейчас и работаю.\n'
		db	' \n \n'                                         
		db	'Дорогой друг, у меня есть для тебя секрет!\n'
		db	'Дело в том, что "Террикон" не только виртуальный компьютер, но я ещё и...\n'
		db	'транслятор языка Ассемблер.\n'
		db	' \n'
		db	'Помимо этого в "Террикон" встроены возможнсти отладчика и дизассемблере.\n'
		db	'И всё это делает кроссплатформенная программа размером менее 200 килобайт!\n'
		db	'Да, "Террикон" меньше двухсот килобайт и он не греет твой процессор.\nНе веришь?\n'
		db	'Запусти procexplorer, если используешь меня на Windows, или top, если\n'
		db	'Линукс. Я "хамелеонестый" и адаптируюсь на обе системы. Пока только на две.\n'
		db	'Запустил? Теперь ищи меня - виртуальный компьютер slagheap.exe\n \n'
		db	'"Террикон" использет оригинальную систему команд системы CISC.\n'
		db	'Эта система команда называется Эверест. Иногда её кличут - Etherest ;-)\n'
		db	' \n'
		db	'Система команд "Эверест" адаптирована под многопоточность, многозадачность.\n'
		db	'Она спроектирована максимамально расширяемой. Но при этом её авторы очень не\n'
		db	'любят, когда и если кто-то полезет её расширять. Авторы будут топать\n'
		db	'ногами, жаловаться и делать прочие непотребные вещи.\n \n'
		db	'А почему они так будут так неадекватно себя вести???\n'
		db	'Да помтому что у авторов далеко идущие планы по расширению системы команд -\n'
		db	'"Террикон" это побочный продукт в области исследования операционных систем и\n'
		db	'и аппаратной обработки синхронных сообщений. Его цель - проверка некоторых\n'
		db	'теорий в области построения ядер операционных систем.\n \n'
		db	'Cпасибо, дорогой друг, что дочитал до этого места.\nНа это не каждый способен. Ты крут.\n \n'
		db	'Если я тебя заинтересовал, то заходи в гости - \n \n'
		db	'https://github.com/L4OS/Slagheap\n \n'
		db	'там ты найдёшь мой исходный код - программы, которая вывела этот текст.\n \n \n'
		db	'Нажмите любую клавишу чтобы закончить тест...',0; тесты...', 0
else                                                                   
$hello		db	'АяйЯ~', 0
done

$dosfont2		import		../lib/asm/vga/fonts/DK-Feoktistov-8x16.utf8.fnt 

 include		../lib/asm/tty/tty.asm
 include		../lib/asm/vga/scroll.asm
 include		../lib/asm/vga/get_event.asm
 include		../lib/asm/string/get_utf8_char.asm

; Вход:
;	R0 - адрес идексов символов шрифта
;	R2 - цвет шрифта
;	R3 - цвет фона
function draw_line
  assign	r8	prev_video_ptr
  assign	r7	line_counter
  assign	r6      charlist
  assign	r5	helper
  assign	r4	char
  assign	r9	charlist_holder	

	push	r15
	mov	charlist, r0
	mov	charlist_holder, r0
	mov	prev_video_ptr, r1



	load	line_counter, 16
	mov	charlist_holder, charlist
line_loop:
	load 	r0, -1
	call	_shift_screen_vertically

	load	r1, 0x8012B600	; Адрес самой нижней строки дисплея 1226240 + 0x80000000
	mov	charlist, charlist_holder
item_loop:
	mov	char, (charlist)
	or	char, char
	jz	line_done

	lea	helper, $dosfont2
	shl	char, 4

	addc	char, helper
	load	helper, 16
	subc	helper, line_counter
	load	r0, 3
	and	r0, helper
	load	r13, 0xfffffffc
	and	helper, r13

	addc	char, helper
	mov	helper, char
	mov	char, (helper)

	or	r0, r0
	je	ok
align:
	shl	char, 8
	dec	r0
	jne	align	
ok:
	inc	charlist, 4
	load	helper, 8

character_loop:
	shl	char, 1
	jc	foreground_dot
	mov	(r1), r3
	jmp	next_dot
foreground_dot:
	mov	(r1), r2
next_dot:
disable
	inc	r1, 4;	
	inc	r1, 4 ; Ха-ха давай через точрку?
else
	clc
	addc	r1, dot_step
done
	dec	helper
	jnz	character_loop
	jmp	item_loop

line_done:
	load	r1, 0xfffeffe0	; Адрес порта управления терминалом
	mov	(r1), r0	; Обновить экран записью в порт

	load	r0, 50 	; Ждать событие 3 секунды
	call	_get_event	; 
	or	r0, r0
	jne	logout          ; Если таймаут, снова ждать

	mov	r0, charlist

	dec	line_counter
	jnz	line_loop
	load	r0, 0
logout:
	pop	r15
	return
end
 