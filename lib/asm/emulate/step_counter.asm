; ������� ������ ����� ��������� ������ � ������� ������/������
; �����: R0 - ������� �����, R1 - ������� �����

$STEP_COUNTER	equ  0xfffeffb0

function	_get_step_counter
	push		r3
	load		r3, $STEP_COUNTER
	mov             r0, (r3)
	pop		r3
	return			; ������� �� �������
end


