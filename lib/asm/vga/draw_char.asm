; --- ����� ����� ��� �������. ��� ������ ���� ������ � �����
; �� ������ ���������� ���������� � ������ ��� �������� ���������
function _test_char
	load	r14, 0x2000 ; set stack
	notch
	jmp	entry
entry:
end
; �� ��������� ���� ������ - � �������� ������ �� ����� �������� ����������


; --- ������� ������ ������� �� VGA ����� �� ����������� � ������ ������
; ����:  R0  - ��� �������
;	 R1  - ����� � �����������
;	 R2  - ���� �������
;	 R3  - ���� ����
; �����: 
;	 R1  - ����� ����������� ���������� �������
;	 R2  - ���� �������
;	 R3  - ���� ����
	

function _draw_char
	push	r15
	push	r10			; �������� ABI �� ������ ���������� R8-R15
	push	r1
	load	r10, 2528 		; ������ ��������� ������ (640 - 8) * 4

	lea	r7, $font_selector
	mov	r7, (r7)
	shl	r0, 4
	clc	
	addc    r7, r0
	load	r6, 4
quorter:
	mov	r0, (r7)
	load	r4, 4
word:
	load	r5, 8
line:
	shl	r0, 1 
	jc	white
	mov	(r1), r3
	jmp 	next
white:
	mov	(r1), r2
next:
	inc	r1, 4
	dec	r5
	jnz	line
	addc	r1, r10
	dec	r4
	jnz	word
	inc	r7, 4
	dec	r6
	jnz	quorter
	pop	r1
	load	r7, 32
	clc
	addc	r1, r7
	pop	r10		
	pop	r15
	return
end

$font_selector	db	0,0,0,0

; ������������� ��������� �� ������ ������ 8x16
; ����:
;	R7 - ����� ������ ������

function _select_font
	lea	r6, $font_selector
	mov	(r6), r7
	return
end

