;
; Show device uptime
; 
; --- Точка входа при отладке. Она должна быть первой в файле
; Не должна вызываться программой и служит как тестовый заголовок
function test_uptime
		load	r14, 0x8000 ; set stack
		call    uptime_demo
		xor     r0, r0
		send
end

function        uptime_demo
                push    r15
		call	_show_uptime  	
		lea	r1, $uptime_string
		call	_puts
		call	_newline
		pop     r15
		return
end

; Переделать на $lib_string@uptime

$uptime_string	db	'TEST UPT: due to difference of CPU clocks of host and emulator', 13, 10
                db      '          this test will show wrong values. Will be fixed some day...',13, 10


; --- Поля Function Control Block ------------------------------

;$return_address		equ		0	; Позиция адреса возврата
$seconds_count_lo	equ		1	; Количество секунд с момента старта устройства
$seconds		equ		2	; Количество секунд 
$minutes		equ		3	; Количество минут
$hours			equ		4	; Количество часов

; ------ Именование регистров ------
assign		r3	TaskState		; Состояние задачи
assign		r2	TaskPtr			; Указатель на задачу
assign		r1	TimeoutValue		; Количество тактов до следующей операции планирования
assign		r0	TCB			; Указатель на область данных задачи


function   _show_uptime
	dec	r14, 12		; Освобождение места на стеке для локальных переменных
	dec	r14, 12		; Освобождение места на стеке для локальных переменных
	mov	(r14), r15	; Адрес возврата из функции

	lea	r1, $tick_str
	call	_puts

	call	_get_sysclock
	
	push	r0
	mov	r0, r1
	call	_print_hex
	pop	r0
	call	_print_hex

	call	_get_sysclock		; ну и что

;	mov	r2, 100000000
;	mov	r2, 50000000	; 50 MHz version
	mov	r2, 1000	; DWORD GetTickCount();
	call	_div64

	mov	r14[$seconds_count_lo], r0

	lea	r1, $is_str
	call	_puts

	mov	r0,  r14[$seconds_count_lo]
	call	_print_dec

	lea	r1, $sec_mid_str
	call	_puts

	mov	r0,  r14[$seconds_count_lo]
	xor	r1, r1
	mov	r2, 60
	call	_div64
	mov	r14[$seconds], R2

	xor	r1, r1
	mov	r2, 60
	call	_div64
	mov	r14[$minutes], R2

	xor	r1, r1
	mov	r2, 24
	call	_div64
	mov	r14[$hours], R2

	or	r0, r0
	je	skip_days
	call	_print_dec
	lea	r1, $days_str
	call	_puts
skip_days:
	movt	r0, r14[$hours]
	je	skip_hours
	call	_print_dec
	lea	r1, $hours_str
	call	_puts
skip_hours:
	movt	r0, r14[$minutes]
	je	skip_minutes
	call	_print_dec
	lea	r1, $min_str
	call	_puts
skip_minutes:
	mov	r0, r14[$seconds]
	call	_print_dec
	lea	r1, $sec_fin_str
	call	_puts

	call	_get_step_counter
	call	_print_dec
	lea	r1, $step_count
	call	_puts

	call	_get_speed_counter
	call	_print_dec
	lea	r1, $step_count
	call	_puts

	mov	r15, (r14)
	inc	r14, 12
	inc	r14, 12
	return

; ------------------------------------------------------------------

end ; of function

$tick_str	db	'Tick ',0
$is_str		db	' is ',0
$days_str	db	' days ',0
$hours_str	db	' hours ',0
$min_str	db	' min ',0
$sec_mid_str	db	' seconds = ',0
$sec_fin_str	db	' sec',13,10,0
$step_count	db	' total instructions executed',13,10,0
$speed_count	db	' cpu speed',13,10,0

disable
else
 include		../tty/tty.asm
 include		../emulate/div.asm
 include		../emulate/sysclock.asm
 include		../emulate/step_counter.asm
 include		../emulate/cpu_speed.asm
 include		../tty/print_dec.asm
done
