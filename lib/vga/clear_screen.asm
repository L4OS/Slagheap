; Функция очистки экрана
; Вход: ничего. 
;
function	_tmp
	load	r14, 0x2000 ; set stack
	notch
	jmp	entry
entry:
end

assign	R3	video_ptr
assign	R4	counter
assign  R8	eax

function	_clear_vga_screen
	load	video_ptr, 0x80000000
	load	counter, 307200 ; 640x480
	load	eax, 0x555a555a
rows2:
	mov	(video_ptr), eax
	inc	video_ptr, 4
	dec	counter
	jnz	rows2
	load	video_ptr, 0xfffeffe0	; порт обновления экрана
	mov	(video_ptr), eax
	return			; Возврат из функции
end

