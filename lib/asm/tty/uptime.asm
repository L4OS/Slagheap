;
; Show device uptime
; 

; --- Поля Function Control Block ------------------------------

$return_address		equ		0	; Позиция адреса возврата
$seconds_count_lo	equ		1	; Количество секунд с момента старта устройства
$seconds		equ		2	; Количество секунд 
$minutes		equ		3	; Количество минут
$hours			equ		4	; Количество часов

; ------ Именование регистров ------
assign		r3	TaskState		; Состояние задачи
assign		r2	TaskPtr			; Указатель на задачу
assign		r1	TimeoutValue		; Количество тактов до следующей операции планирования
assign		r0	TCB			; Указатель на область данных задачи


function   show_uptime
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
$step_count	db	' instructions executed',13,10,0

disable
;else
 include		../lib/tty/tty.asm
 include		../lib/emulate/div.asm
 include		../lib/emulate/sysclock.asm
 include		../lib/emulate/step_counter.asm
 include		../lib/tty/print_dec.asm
done
