; Чтение клавиатуры окна виртуального дисплея
; Выход:
;	R0 - сканкод клавишы в формате WIN32
;
; Данна функция применима только для эмулятора Slagheap

$vga_window_key_port		equ		0xfffeffe4	; Младший бит означает ожидание

function _get_key
	load	r0, $vga_window_key_port
	mov	r0, (r0)	
	return
end