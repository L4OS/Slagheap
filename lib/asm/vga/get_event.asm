; Чтение с таймаутом событий клавиатишу или мыши виртуального дисплея
; Выход:
;	R0 - время ожидания события в миллисекундах
; Выход:
;	R0 - идентификатор события (0 - таймаут)
;	R1 - W param
;	R2 = L param
;
; Данная функция применима только для эмулятора Slagheap

$window_event_port		equ		0xfffeffe4	; Чтение этого порта блокирует процесс до получения собятия
$window_event_timeout		equ		0xfffeffe4	; Запись в этот порт времени ожидания события
$read_Wparam_port		equ		0xfffeffe8	;
$read_Lparam_port		equ		0xfffeffec

function _get_event
	load	r6, $window_event_timeout
	mov	(r6), r0
;	load	r0, $vga_window_key_port ; Порт для чтения событий и записи таймаутов - общий
	mov	r0, (r6)
	or	r0, r0
	je	exit
	inc	r6, 4 ; Переход на регистр Wparam
	mov	r1, (r6)
	inc	r6, 4 ; Переход на регистр Wparam
	mov	r2, (r6)
exit:	return
end