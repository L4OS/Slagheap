; ------ ���������� ��������� ------
assign		r0	FirstWord
assign		r1	pStrOne		; ��������� �� ������ ������
assign		r2	SecondWord
assign		r3	pStrTwo		; ��������� �� ������ ������
assign		r4	FIRST_MASK
assign		r5	SECOND_MASK
assign		r6	MYFLAGS


function debug_strcmp
	load 	r14, 0x2000
	lea 	pStrOne, $str_one
	lea 	pStrTwo, $str_two	                   	
	call	strcmp
	lea	pStrOne, $same
	jz	same
	lea	pStrOne, $diff
same:
	call	_puts
	call	_newline
	send
end

$str_one  db 'onese', 0
$str_two  db 'onesi', 0
$same	  db 'same',0
$diff	  db 'diff',0

include ../tty/tty.asm
; ������� ��������� �����
; ����: 
;	R1 - ����� ������ ������
;	R3 - ����� ������ ������
; �����:
;	������������� ���� ���� (Z) ���� ������ ���������
;
; ������������ � posix strlen() ������:
; ������� strcmp() � strncmp() ���������� ����� �����, ������� ������, ������ ���� ��� ����� ���, ���� ������ s1 (��� �� ������ n ������) 
; �������������� ������, ������ ��� ����� (�����) s2.
; !!! � ������� ������ lib/asm �� �� ��������  

; !!!! ������ ������������� ����� ���������� ����� ����� ���� ���� !!!!

function strcmp
;debug
loop:
	mov	FirstWord, (pStrOne)
	mov	SecondWord, (pStrTwo)	
	cmp	FirstWord, SecondWord
	jne	look_carefully 

	rol	FirstWord, 8		; ����������� ����� �� 8 ��� �����
	load	FIRST_MASK,  0xff
	and	FIRST_MASK, FirstWord
	je	same_string

	rol	FirstWord, 8		; ����������� ����� �� 8 ��� �����
	load	FIRST_MASK,  0xff
	and	FIRST_MASK, FirstWord
	je	same_string

	rol	FirstWord, 8		; ����������� ����� �� 8 ��� �����
	load	FIRST_MASK,  0xff
	and	FIRST_MASK, FirstWord
	je	same_string

	rol	FirstWord, 8		; ����������� ����� �� 8 ��� �����
	load	FIRST_MASK,  0xff
	and	FIRST_MASK, FirstWord
	je	same_string

	inc	pStrOne, 4
	inc	pStrTwo, 4
	jmp	loop
look_carefully:
	load	MYFLAGS, 0
do:
	rol	FirstWord, 8		; ����������� ����� �� 8 ��� �����
	load	FIRST_MASK,  0xff	; 
	and	FIRST_MASK, FirstWord
	je	check_second
; ���� ������ ���� ������� ���� ������ ������ �� ����
	inc	MYFLAGS
check_second:
	rol	SecondWord, 8		; ����������� ����� �� 8 ��� �����
	load	SECOND_MASK,  0xff	; 
	and	SECOND_MASK, SecondWord
	je	check_zero
; ���� ������ ���� ������� ���� ������ ������ �� ����
	inc	MYFLAGS
check_zero:
	or	MYFLAGS, MYFLAGS
	je	same_string
	cmp	FIRST_MASK, SECOND_MASK	
same_string:
	return
end


; C-style �������
; ����� �������� ����� ��� C-ABI - ������������� � R0 ��� R1?
function _strcmp
	push	r15
	call 	strcmp
	load	r0, 1
	jz	exit
	load	r0, 0
exit:
	pop	r15
	return
end