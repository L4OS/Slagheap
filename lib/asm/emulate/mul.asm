; --- Функция умножения двух чисел
; Вход:  R0  - первый множитель
;	 R1  - второй множитель
; Выход: R2 - результат умножения

function 	_mul
	load	r2, 0
loop:
;;	set_mr	mr4, r1
	shr	r1, 1
	jnc	lab
	clc
	addc	r2, r0
lab:
	shl	r0, 1
	or	r1, r1
	jne	loop
	return
end