; --- ����� ����� ��� �������. ��� ������ ���� ������ � �����
; �� ������ ���������� ���������� � ������ ��� �������� �������
function _test_string
	load	r14, 0x2000 ; set stack
	notch
	jmp	entry
entry:
end
; �� ��������� ���� ������ - � �������� ������ �� ����� �������� ����������

; --- ������� ������ �������� �������� ������ � ����������� VGA ��������
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

include ../mul.asm

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

function _vga_puts
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
	jne	draw
; ���� ���
	call	linefeed
	jmp	next
draw:
	lock
	set_mr	mr16, r4
	set_mr	mr17, r5
	set_mr	mr18, r6
	call	_draw_char    		; ����� ������������ ������ �������
	get_mr	mr18, r6
	get_mr	mr17, r5
	get_mr	mr16, r4
	unlock
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


; ������� �������� ������
; ����:
;	R1 - ����� � ����������� 
; �����:
;	R1 - ����� � ����������� 

function line_feed
;	cmp r1, ; 0x80000000 + 24 * 16 * 640 ; ��������� ��������
	clc
	addc	R1, 10240
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
	push R0
	push R2
	push R3

	mov	r0, r1 
	load	r2, 10240
	call _div

	pop R3
	pop R2
	pop R0
	return
end
