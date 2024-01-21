; Возвращает utf-8 символ и указатель на следующий
; Вход: 
;	R0 - указатель на символ в строке
; Выход: 
;	R0 - код символа utf32
;	R1 - адрес следующего символа или 0 в случае ошибки
function _get_utf8_character
    assign 	r0 	char_ptr
    assign 	r2	cpu_word
    assign	r3	align_counter
    assign	r4	char
    assign	r5	uchar
    assign	r6	holder
    assign	r7	utf_state
    assign	r8	final_reg
    assign	r13	slopper

	push	r13
	load	utf_state, 0
;debug
strange_entrypoint:
	load	align_counter, 0x3
	mov	slopper, char_ptr
	and	align_counter, char_ptr
	jz	load_aligned_word

	load	slopper, 0xfffffffc
	and	slopper, char_ptr
	mov	cpu_word, (slopper)
skip_loop:
     	rol	cpu_word, 8				; Циклический сдвиг на 8 бит влево
	dec	align_counter
	jnz	skip_loop
	jmp	load_word

load_aligned_word:
	mov	cpu_word, (slopper)
	load	align_counter, 4
	jmp	 load_word

load_word:
     	rol	cpu_word, 8				; Циклический сдвиг на 8 бит влево
	inc	char_ptr
	cmp	utf_state, 0
	jne	found_utf_char		; Конечный автомат

	load	char, 0xff
	and	char, cpu_word
	cmp	char, 0x80
	jnc	load_utf8
	mov	r1, char_ptr
	mov	r0, char
	jmp	leave_function

load_utf8:
	load	uchar, 0xe0
	and	uchar, char
	cmp	uchar, 0xc0
	je	do_two_bytes

	load	uchar, 0xf0
	and	uchar, char
	cmp	uchar, 0xe0
	je	draw_three_bytes

	load	uchar, 0xf8
	and	uchar, char
	cmp	uchar, 0xe0
	je	draw_four_bytes

draw_error:
	load	r1, 0
	load	r0, -1
	jmp	leave_function

;--- Кодирования двумя байтами
do_two_bytes:
	load	holder, 0x1f
	and	holder, cpu_word

	mov	utf_state, 1
	jmp	draw_next_char

found_utf_char:
	load	final_reg, 0xc0
	and	final_reg, cpu_word
	cmp	final_reg, 0x80
	jne	draw_error		; Сигнатура не соответствует

	shl	holder, 6		; В этом месте в регистре R9 биты 10..6
	load	final_reg, 0x3f
	and	final_reg, cpu_word; char		; В этом месте в регистре R0 биты 5-0
	or	holder, final_reg	; В этом месте в регистре R9 код символа
	load	slopper, 1
	subc	utf_state, slopper
	jnz	draw_next_char
;	inc	chars_counter
	; Тут можно положить символ в буффервр
	; mov	menu.word, r0
	load	slopper, 0x380 ; 0x400
	clc
	subc	holder, slopper
	jc	substitute_char
	load	slopper, 0xff
	subc	slopper, holder
	jnc     character_successfully_translated
substitute_char:
	load	r0, '?' ;0x0f	; https://en.wikipedia.org/wiki/Shift_Out_and_Shift_In_characters
character_successfully_translated:
	mov	r1, char_ptr	
	mov	r0, holder
	jmp	leave_function

; --- Кодирование тремя байтами
draw_three_bytes:
	load	final_reg, 0x0f
	and	final_reg, char
	load	utf_state, 2
	jmp	draw_next_char
	

; --- Кодирование четырьмя байтами
draw_four_bytes:
	load	final_reg, 0x07
	and	final_reg, char
	load	utf_state, 3
	jmp	draw_next_char
	
draw_next_char:	

	or	align_counter, align_counter
enable
	jz	strange_entrypoint
else
	jnz	itsok
	debug
	jmp	strange_entrypoint
done
	
itsok:
	dec	align_counter
	jnz	load_word

	mov	cpu_word, (char_ptr)
;     	rol	cpu_word, 8				; Циклический сдвиг на 8 бит влево
	jmp	load_word


leave_function:
	pop	r13
	return
end

