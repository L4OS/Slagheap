; ������� ������ ����������� �������� ������������ ����������
; 
; �����: R0 - ������� �����, R1 - ������� �����

$CPU_SPEED_COUNTER	equ	0xfffeffb4

function	_get_speed_counter
	push		r3
	load		r3, $CPU_SPEED_COUNTER
	mov             r0, (r3)
	pop		r3
	return			; ������� �� �������
end
