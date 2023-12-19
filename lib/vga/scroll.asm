$vga_vscroll_reg		equ		0xfffeffe8	; ћладший бит означает ожидание
$vga_hscroll_reg		equ		0xfffeffec	; ћладший бит означает ожидание

; --- —двигает экран вертикально
; ¬ход:  
;	R0  - знаковое число на сколько строк прокрутить экран
function _shift_screen_vertically
	load	r1, $vga_vscroll_reg
	mov	(r1), r0	
	return
end

; --- —двигает экран горизонтально
; ¬ход:  
;	R0  - знаковое число на сколько строк прокрутить экран
function _shift_screen_horizontally
	load	r1, $vga_hscroll_reg
	mov	(r1), r0
	return
end
