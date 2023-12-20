;
; Show device uptime
; 

; --- ���� Function Control Block ------------------------------

$return_address		equ		0	; ������� ������ ��������
$seconds_count_lo	equ		1	; ���������� ������ � ������� ������ ����������
$seconds		equ		2	; ���������� ������ 
$minutes		equ		3	; ���������� �����
$hours			equ		4	; ���������� �����

; ------ ���������� ��������� ------
assign		r3	TaskState		; ��������� ������
assign		r2	TaskPtr			; ��������� �� ������
assign		r1	TimeoutValue		; ���������� ������ �� ��������� �������� ������������
assign		r0	TCB			; ��������� �� ������� ������ ������


function   show_uptime
	dec	r14, 12		; ������������ ����� �� ����� ��� ��������� ����������
	dec	r14, 12		; ������������ ����� �� ����� ��� ��������� ����������
	mov	(r14), r15	; ����� �������� �� �������

	lea	r1, $tick_str
	call	_puts

	call	_get_sysclock
	
	push	r0
	mov	r0, r1
	call	_print_hex
	pop	r0
	call	_print_hex

	call	_get_sysclock		; �� � ���

;	mov	r2, 100000000
;	mov	r2, 50000000	; 50 MHz version
	mov	r2, 1000	; DWORD GetTickCount();
	call	_div64

	mov	r14[$seconds_count_lo], r0

	lea	r1, $is_str
	call	_puts

	mov	r0,  r14[$seconds_count_lo]
	call	_print_dec

	lea	r1, $sec_mid_str
	call	_puts

	mov	r0,  r14[$seconds_count_lo]
	xor	r1, r1
	mov	r2, 60
	call	_div64
	mov	r14[$seconds], R2

	xor	r1, r1
	mov	r2, 60
	call	_div64
	mov	r14[$minutes], R2

	xor	r1, r1
	mov	r2, 24
	call	_div64
	mov	r14[$hours], R2

	or	r0, r0
	je	skip_days
	call	_print_dec
	lea	r1, $days_str
	call	_puts
skip_days:
	movt	r0, r14[$hours]
	je	skip_hours
	call	_print_dec
	lea	r1, $hours_str
	call	_puts
skip_hours:
	movt	r0, r14[$minutes]
	je	skip_minutes
	call	_print_dec
	lea	r1, $min_str
	call	_puts
skip_minutes:
	mov	r0, r14[$seconds]
	call	_print_dec
	lea	r1, $sec_fin_str
	call	_puts

	mov	r15, (r14)
	inc	r14, 12
	inc	r14, 12
	return

; ------------------------------------------------------------------

end ; of function

$tick_str	db	'Tick ',0
$is_str		db	' is ',0
$days_str	db	' days ',0
$hours_str	db	' hours ',0
$min_str	db	' min ',0
$sec_mid_str	db	' seconds = ',0
$sec_fin_str	db	' sec',13,10,0

disable
;else
 include		../lib/tty.asm
 include		../lib/div.asm
 include		../lib/sysclock.asm
 include		../lib/print_dec.asm
done
; --- ������� ������� ����� (32/32) -----------------------
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
; R4, R5 - lremainder
; R6, R7 - divisor
