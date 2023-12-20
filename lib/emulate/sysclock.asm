; Функция чтения числа системных клоков с момента старта/сброса
; Выход: R0 - младшее слово, R1 - старшее слово

function	_get_sysclock
	push		r3
	load		r3, 0xfffefff8
	mov             r0, (r3)
	inc		r3, 4
	mov             r1, (r3)
	pop		r3
	return			; Возврат из функции
end


