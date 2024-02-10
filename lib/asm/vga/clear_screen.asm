; Функция очистки экрана
; Вход: ничего. 
;
function	lib_entry_test
	load	r14, 0x2000 ; set stack
	notch
	jmp	entry
entry:
end


function	_clear_vga_screen
  assign	R3	video_ptr
  assign	R4	counter
  assign  	R8	eax
	load	video_ptr, 0x80000000
	load	counter, 307200 ; 640x480
	load	eax, 0x555a555a
rows2:
	mov	(video_ptr), eax
	inc	video_ptr, 4
	dec	counter
	jnz	rows2
	load	video_ptr, 0xfffeffe0	; Порт обновления экрана
	mov	(video_ptr), eax
	return				; Возврат из функции
end


function	_refresh_screen
  assign	R3	video_ptr
  assign  	R8	eax
	load	video_ptr, 0xfffeffe0	; Порт обновления экрана
	mov	(video_ptr), eax
end