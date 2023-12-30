; Печатает коды нажатых клавиш на отладочной консоле

; --- Точка входа при отладке на "голом железе". Она должна быть первой в файле
function test_string
	load	r14, 0x8000 ; set stack
	notch
	jmp	entry
entry:
end

function   user_main
	push	r15
	lea	r1, $hi_str	
	call	_puts		
loop:
	call	_getchar
	push	r0
	lea	r1, $dec_str	
	call	_puts		
	mov	r0, (r14)
	call	_print_dec
	lea	r1, $hex_str	
	call	_puts		
	mov	r0, (r14)
	call	_print_hex
	call	_newline
	pop	r0
	load	r1, 0x51
	cmp	r1, r0
	jne	loop
	pop	r15
	return
end

include		../lib/asm/tty/tty.asm
include		../lib/asm/emulate/div.asm
include		../lib/asm/tty/print_dec.asm

$hi_str		db	'Press Q to quit',13,10,0
$dec_str	db	'Decimal ',0
$hex_str	db	' Hex ',0
