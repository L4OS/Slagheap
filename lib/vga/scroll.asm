$vga_vscroll_reg		equ		0xfffeffe8	; ������� ��� �������� ��������
$vga_hscroll_reg		equ		0xfffeffec	; ������� ��� �������� ��������

; --- �������� ����� �����������
; ����:  
;	R0  - �������� ����� �� ������� ����� ���������� �����
function _shift_screen_vertically
	load	r1, $vga_vscroll_reg
	mov	(r1), r0	
	return
end

; --- �������� ����� �������������
; ����:  
;	R0  - �������� ����� �� ������� ����� ���������� �����
function _shift_screen_horizontally
	load	r1, $vga_hscroll_reg
	mov	(r1), r0
	return
end
