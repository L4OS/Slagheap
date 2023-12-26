; --- ����� ����� ��� �������. ��� ������ ���� ������ � �����
; �� ������ ���������� ���������� � ������ ��� �������� �������
function _test_string
	load	r14, 0x2000 ; set stack
	notch
	jmp	entry
entry:
end
; �� ��������� ���� ������ - � �������� ������ �� ����� �������� ����������

; --- ������� ������ ������� �������� ������ � ����������� VGA ��������
; ����:  R0  - ��������� �� ������
;	 R1  - YX - ������-������� - ������� 16 ��� ����� ������, ������� 16 ��� ����� �������
;	 R2  - ���� �������
;	 R3  - ���� ����
; �����: 
;	 R1 - ����� ����������� ��������� �������;	
function _draw_string
	push	r15

	lock
	set_mr	mr16, r0
	set_mr	mr18, r2

	mov	r4, r1
	load	r5, 0xffff
	and	r4, r5
	shl	r4, 5 	; ��� 2^5 = 32 = 8 pixels * 4 bytes per pixel

	load	r0, 40960	; 640 * 16 * 4
	shr	r1, 16		; high 16 bits
	call	_mul
	load	r1, 0x80000000
	clc
	addc	r1, r4
	addc	r1, r2
	
	get_mr	mr18, r2
	get_mr	mr16, r0
	unlock

	call	_draw_string_vga
	pop	r15
	return
end


; --- ������� ������ ������� �������� ������ � ����������� VGA ��������
; ����:  R0  - ��������� �� ������
;	 R1  - ����� � �����������
;	 R2  - ���� �������
;	 R3  - ���� ����
; �����: 
;	 R1 - ����� ����������� ��������� �������;	

assign 	r4	counter
assign	r5	text_qword_ptr
assign  r6	chars

function _draw_string_vga
	push	r15
	mov	text_qword_ptr, r0		; ����������� ��������� �� ������

load_word:
	mov	chars, (text_qword_ptr)	; �������� ��������� ����� (4-�������)
	load	counter, 4		; ���������� ���� � �������� �����
;debug
check_byte:
	rol	chars, 8		; ����������� ����� �� 8 ��� �����
	load	r0, 0xff		; �������� ������������ ���������
	and	r0, chars		; �������� �� ����� ������
	je	done			; ����� ������ ��������
	lock
	set_mr	mr16, r4
	set_mr	mr17, r5
	set_mr	mr18, r6
	call	_draw_char    		; ����� ������������ ������ �������
	get_mr	mr18, r6
	get_mr	mr17, r5
	get_mr	mr16, r4
	unlock

	inc	text_qword_ptr		; ��������� ���������
	dec	counter			; ��������� ��������
	jne	check_byte		; ��������� ������
;debug
	jmp	load_word		; ������ ��������
done:
	pop	r15
	return
end

include ../emulate/mul.asm
include ../emulate/div.asm
include draw_char.asm

; --- ������� ������ ������� �������� ������ � ����������� VGA ��������
; ����:  R0  - ��������� �� ������
;	 R1  - ����� � �����������
;	 R2  - ���� �������
;	 R3  - ���� ����
; �����: 
;	 R1 - ����� ����������� ��������� �������;	

assign 	r4	counter
assign	r5	text_qword_ptr
assign  r6	chars

function _vga_puts_memory
	push	r15
	mov	text_qword_ptr, r0		; ����������� ��������� �� ������

load_word:
	mov	chars, (text_qword_ptr)	; �������� ��������� ����� (4-�������)
	load	counter, 4		; ���������� ���� � �������� �����
;debug
check_byte:
	rol	chars, 8		; ����������� ����� �� 8 ��� �����
	load	r0, 0xff		; �������� ������������ ���������
	and	r0, chars		; �������� �� ����� ������
	je	done			; ����� ������ ��������
	cmp	r0, 0xd			; ������� \r
	jne	check_linefeed
; ���� ����
	jmp	next
check_linefeed:
	cmp	r0, 0xa			; ������� \n
	call    caretreturn
	jmp	next
	jne	draw
; ���� ���
	call	linefeed
	jmp	next
draw:
	push	r4
	push	r5
	push	r6
	call	_draw_char    		; ����� ������������ ������ �������
	pop	r6
	pop	r5
	pop	r4
next:
	inc	text_qword_ptr		; ��������� ���������
	dec	counter			; ��������� ��������
	jne	check_byte		; ��������� ������
;debug
	jmp	load_word		; ������ ��������
done:
	pop	r15
	return
end

;
function _vga_puts
	push	r15
	push	r0
	push	r2

	mov	r4, r1
	load	r5, 0xffff
	and	r4, r5
	shl	r4, 5 	; ��� 2^5 = 32 = 8 pixels * 4 bytes per pixel

	load	r0, 40960	; 640 * 16 * 4
	shr	r1, 16		; high 16 bits
	call	_mul
	load	r1, 0x80000000
	clc
	addc	r1, r4
	addc	r1, r2

	pop	r2
	pop	r0
	call	_vga_puts_memory
	pop	r15
	return
end

; ������� �������� ������
; ����:
;	R1 - ����� � ����������� 
; �����:
;	R1 - ����� � ����������� 

function linefeed
;	cmp r1, ; 0x80000000 + 24 * 16 * 640 ; ��������� ��������
	clc
	addc	R1, 40960 ; 10240 * 4bpp
	return
end

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

; ������� �������
; ����:
;	R1 - ����� � ����������� 
; �����:
;	R1 - ����� � ����������� 
function caretreturn
	push	r15
;	return
;debug
	load	r0, 0x80000000 ; ������ �����������
	clc
	subc	r1, r0
	mov	r0, r1
	load	r1, 0
	load	r2, 40960
	call 	_safe_div64
	;  �������� R0 - ����� ������� ������
;debug
	load	r1, 40960
	call	_mul 
	load	r1, 0x80000000 
	clc
	addc	r1, r2
; ��� ���� ������� �������� �� ������� ����������� � ���� ����� ������� ���������. Ƞ�������� ������� �� ����� ������
	pop	r15
	return
end
