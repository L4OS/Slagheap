; Input hex number from terminal
; and return it in register R11 

function input_hex
	push	r15
	load	r11, 0
wait_hex_input:
	call	_getchar
	mov	r3, r0
	cmp	r0, 0x30 ; '0'
	jc	compare_out
	cmp	r0, 0x39   ; '9'
	ja	compare_alpha
	clc
	subc	r0, 0x30
	jmp	found_digit
compare_alpha:
	cmp	r0,  0x61 ; 'a'
	jc	wait_hex_input
	cmp	r0, 0x66 ; 'f'
	ja	compare_out
	clc
	subc	r0, 0x57 ; ( 'a' - 10 )
found_digit:
	shl	r11, 4
	or	r11, r0
	call	_putchar
	jmp	wait_hex_input
compare_out:
	cmp	r0, 0xd ; CR 
	je	finish_hex_input
	cmp	r0, 0xa ; LF
	je	finish_hex_input
	cmp	r0, 0x8 ; Backspace
	jne	wait_hex_input
	call	print_backspace
	load	r0, 0x0fffffff
	shr	r11, 4
	and	r11, r0
	jmp	wait_hex_input
finish_hex_input:
	call	_newline	
	pop	r15
	return
end
