$sysramsize	equ	70		; Words count
$sysramptr	equ	0x1000          ; Syten RAM address

; ------ Именование регистров ------
assign		r0	zero	; 
assign		r1	counter 
assign		r2 	pointer
assign		r3	sourceptr

function	visual_dump
	push	r15
	load	r11, 0 ; 0xff000000
visuail_dump_loop:
	call    show_hex_dump
visuail_dump_wait:
	call	_getchar	

	cmp	r0, 0x6e  ; 'n'
	je      visuail_dump_loop
	cmp	r0, 0x70 ; 'p'
	jne	vd_not_prev_key
	subc	r11, 0x100	
	jmp     visuail_dump_loop
vd_not_prev_key:
	cmp	r0,  0x71 ; 'q'
	je      visual_dump_quit
	cmp	r0,  0x61; 'a'
	jne	visuail_dump_wait	; Клавиша 1
	lea	r1, $address_str
	call	_puts
	call	input_hex
	jmp     visuail_dump_loop

visual_dump_quit:
	pop	r15
	return
end 

disable
; 
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
	jmp	wait_hex_input
finish_hex_input:
	call	_newline	
	pop	r15
	return
end

done

function   show_hex_dump
	dec	r14, 12		; Освобождение места на стеке для локальных переменных
	dec	r14, 12		; Освобождение места на стеке для локальных переменных
	mov	(r14), r15	; Адрес возврата из функции

	load	r13, 8
print_line:
	push	r13
	mov	r0, r11
	call	_print_hex

	lea	r1, $deco_str
	call	_puts

        load	r9, 4
print_word:
	mov	r0,  (r11)
	call	_print_hex
	inc	r11, 4

	dec	r9
	jne	print_word

	lea	r1, $shd_crlf
	call	_puts

	pop	r13
	dec	r13
	jne	print_line

	lea	r1, $footer_str
	call	_puts

	mov	r15, (r14)
	inc	r14, 12
	inc	r14, 12
	return

; ------------------------------------------------------------------

end ; of function

$footer_str	db	'[n]ext  [p]rev [a]ddress  [q]uit',13,10,0
$address_str	db	'Hex address: ',0
$deco_str	db	':',0
$shd_crlf	db	13,10,0

enable
 include		../lib/tty/input_hex.asm
else
 include		../lib/tty/tty.asm
 include		../lib/input_hex.asm
done
                        	
