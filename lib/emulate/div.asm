; --- ������� ������� ����� (32/32) ----------------------
;
; ����:
;	R0  - ������� (32-����)
;	R2  - ��������
;
; �����:
; 	R0 - �������
; 	R2 - �������
; ---------------------------------------------------------

function	_div
	load		r1, 0x0
;	jmp		_div64
end

; --- ������� ������� ����� (64/32) -----------------------
;
; ����:
;	R0  - ������� (������� 32-����)
;	R1  - ������� (������� 32-����)
;	R2  - ��������
;
; �����:
; 	R0 - �������
; 	R2 - �������
; ---------------------------------------------------------
; ��������� ��������:
;	R3 	- �������
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
