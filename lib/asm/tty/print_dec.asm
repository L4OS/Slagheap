
; --- Функция вывода десятичного числа
; Вход:  R0  - число

function 	_print_dec
    $ret_addr		equ		3
    $keep_r11		equ		2
    $keep_r12		equ		1
    $keep_reserv	equ		0

;	push	r15
	dec	r14, 8
	dec	r14, 8
	mov	r14.ret_addr, r15
	mov	r14.keep_r12, r12
	mov	r14.keep_r11, r11

	xor	r11, r11
	load    r2,  80   ; 10 bytes buffer
	clc
	subc	r14, r2   ;	
	MOV 	R12, R14 
	DEC 	R14, 4 

loop:
	load	r2, 0xa
;debug	
	call	_div
;debug	
	push	r0
	load	r3, 0x30
	clc
	addc	r3, r2
	mov	(r12), r3
	inc	r11
	inc	r12, 4
	pop	r0
	or	r0, r0
	jne	loop

pool:
	dec	r12, 4
	mov	r3, (r12)
	call	_putchar
	dec	r11
	jne	pool	
	
	load	r2, 84
	clc
	addc	r14, r2

	mov	r15, r14.ret_addr
	mov	r12, r14.keep_r12
	mov	r11, r14.keep_r11
	inc	r14, 8
	inc	r14, 8

;	pop	r15
	return
end

include tty.asm
include ../emulate/div.asm
