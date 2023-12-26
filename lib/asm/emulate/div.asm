; --- Функция деления чисел (32/32) ----------------------
;
; Вход:
;	R0  - делимое (32-бита)
;	R2  - делитель
;
; Выход:
; 	R0 - частное
; 	R2 - остаток
; ---------------------------------------------------------

function	_div
	load		r1, 0x0
;	jmp		_div64
end

; --- Функция деления чисел (64/32) -----------------------
;
; Вход:
;	R0  - делимое (младшие 32-бита)
;	R1  - делимое (старшие 32-бита)
;	R2  - делитель
;
; Выход:
; 	R0 - частное
; 	R2 - остаток
; ---------------------------------------------------------
; Изменённые регистры:
;	R3 	- счётчик
; 	R4, R5	- lremainder
; 	R6, R7	- divisor
;	R8	- Quotient

function	_div64
	load		r3, 33 ; 33

	mov		r6, r2  	;	Divisor
	xor		r7, r7

	mov		r4, r1		;	lremainder
	mov		r5, r0

	xor		r8, r8		;	Quotient = 0
loop:
	clc
	subc		r5, r7
	subc		r4, r6
	jc		step_to

;  set_mr			mr5, r5
;  set_mr			mr4, r4

	shl		r8, 1
	inc		r8, 1
	jmp		skip

step_to:

;  set_mr			mr5, r5
;  set_mr			mr4, r4

	clc
	addc		r5, r7
	addc		r4, r6
	shl		r8, 1
skip:	

;  set_mr			mr8, r8

	clc
	rcr		r6, 1
	rcr		r7, 1

;  set_mr			mr6, r6
;  set_mr			mr7, r7

	dec		r3

;  set_mr			mr3, r3

	jne		loop	

	mov		r2, r5
	mov		r0, r8

	return
end

; --- Поля Task Control Block ------------------------------
$reg_1		equ		0	; 
$reg_3		equ		1	; 
$reg_4		equ		2	; 
$reg_5		equ		3	; 
$reg_6		equ		4	; 
$reg_7		equ		5	; 
$reg_8		equ		6	; 
$reg_15		equ		7	; 

assign		r14	stack_pointer	; Указатель на вершину стека

function _safe_div64
	dec	stack_pointer, 16
	dec	stack_pointer, 16
	mov	stack_pointer.reg_15, r15
	mov	stack_pointer.reg_8, r8
	mov	stack_pointer.reg_7, r7
	mov	stack_pointer.reg_6, r6
	mov	stack_pointer.reg_5, r5
	mov	stack_pointer.reg_4, r4
	mov	stack_pointer.reg_3, r3
	call	_div64
	mov	r3, stack_pointer.reg_3
	mov	r4, stack_pointer.reg_4
	mov	r5, stack_pointer.reg_5
	mov	r6, stack_pointer.reg_6
	mov	r7, stack_pointer.reg_7
	mov	r8, stack_pointer.reg_8
	mov	r15, stack_pointer.reg_15
	inc	stack_pointer, 16
	inc	stack_pointer, 16
	return
end