; ������ � ��������� ������� ���������� ��� ���� ������������ �������
; �����:
;	R0 - ����� �������� ������� � �������������
; �����:
;	R0 - ������������� ������� (0 - �������)
;	R1 - W param
;	R2 = L param
;
; ������ ������� ��������� ������ ��� ��������� Slagheap

$window_event_port		equ		0xfffeffe4	; ������ ����� ����� ��������� ������� �� ��������� �������
$window_event_timeout		equ		0xfffeffe4	; ������ � ���� ���� ������� �������� �������
$read_Wparam_port		equ		0xfffeffe8	;
$read_Lparam_port		equ		0xfffeffec

function _get_event
	load	r6, $window_event_timeout
	mov	(r6), r0
;	load	r0, $vga_window_key_port ; ���� ��� ������ ������� � ������ ��������� - �����
	mov	r0, (r6)
	je	exit
	inc	r6, 4 ; ������� �� ������� Wparam
	mov	r1, (r6)
	inc	r6, 4 ; ������� �� ������� Wparam
	mov	r2, (r6)
exit:	return
end