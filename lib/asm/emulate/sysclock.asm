; ������� ������ ����� ��������� ������ � ������� ������/������
; �����: R0 - ������� �����, R1 - ������� �����

function	_get_sysclock
	push		r3
	load		r3, 0xfffefff8
	mov             r0, (r3)
	inc		r3, 4
	mov             r1, (r3)
	pop		r3
	return			; ������� �� �������
end


