; ������ ���������� ���� ������������ �������
; �����:
;	R0 - ������� ������� � ������� WIN32
;
; ����� ������� ��������� ������ ��� ��������� Slagheap

$vga_window_key_port		equ		0xfffeffe4	; ������� ��� �������� ��������

function _get_key
	load	r0, $vga_window_key_port
	mov	r0, (r0)	
	return
end