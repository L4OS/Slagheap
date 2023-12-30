; --- Точка входа при отладке. Она должна быть первой в файле
; Не должна вызываться программой и служит как тестовый заголовок
function _test_tty
		load	r14, 0x2000 ; set stack
		notch
		jmp	entry
entry:  	
		lea	r0, $lib_string
		call	_puts
		call	_newline
		send
end

$lib_string	db	'TEST TTY',0

; Идея сделать форму строки "TEST TTY\r\n"?????

; --- Функция вывода строки
; Вход: R1 - адрес строки
; Выход: R0 - количество переданных символов

function	_puts
	push	r15
	push	r2
	mov	r0, r1		; Копирование указателя на строку
load_word:
	mov	r2, (r0)	; Загрузка машинного слова (4-символа)
	load	r4, 4		; Количество байт в машинном слове
check_byte:
	rol	r2, 8		; Циклический сдвиг на 8 бит влево
	load	r3, 0xff	; Загрузка восьмибитной константы
	and	r3, r2		; Проверка на конец строки
	je	done		; Вывод строки закончен
	call	_putchar        ; Вызов подпрограммы вывода символа
	inc	r0, 1		; Инкремент указателя
	dec	r4, 1		; Декремент счётчика
	jne	check_byte	; Следующий символ
	jmp	load_word	; Повтор операции
done:
	clc			; Сброс переноса
	subc	r0, r1		; Подсчёт количества выведенных символов
	pop	r2
	pop	r15
	return			; Возврат из функции
end

; --- Функция вывод символа
; Вход: R3 - выводимый символ
; Выход: R3 - выводимый символ
function	_putchar
	push			R6
	push			R5
	load			R6, 0xfffefff0	; Адрес порта статуса UART
do_poll:
	mov			R5, (R6)	; Чтение статуса устройства
	rcr			R5, 1		; Вытесняем бит BUSY в перенос
	jc			do_poll		; Опрос устройства в цикле
	inc			R6, 4		; Указатель на регистр передачи данных
	mov			(R6), R3	; Вывод байта
	dec			R6, 4		; Указатель на регистр передачи данных
wait:
	mov			R5, (R6)	; Чтение статуса устройства
	rcr			R5, 1		; Вытесняем бит BUSY в перенос
	jc			wait		; Опрос устройства в цикле
	pop			R5
	pop			R6
	return					; Возврат из функции
end

; --- Функция возвращает состояние были ли нажата клавиша в терминале
; Выход: R0 - статус устройства (RCV_RDY & 0x02)
function	_uart_status
	load			R6, 0xfffefff0	; Адрес порта статуса UART
	mov			R0, (R6)	; Чтение статуса устройства
	return
end

; --- Функция ожидания ожидания символа с терминала
; блокируется в цикле до принятия данных
; Выход: R0 - принятый символ
function	_getchar
	load			R6, 0xfffefff0	; Адрес порта статуса UART
do_poll:
	mov			R0, (R6)	; Чтение статуса устройства
	rcr			R0, 2		; Бит RCV_RDY в перенос
	jnc			do_poll		; Опрос устройства в цикле
	inc			R6, 4		; Указатель на регистр чтения данных
	mov			R0, (R6)	; Чтение  
	return					; Возврат из функции
end


; Send backspace to dumb termnal
;  Input:       No
;  Output:      No
;  Fortune:     r0  and some over registers
function print_backspace
	push	r15
	lea	r1, $backspace_str
	call	_puts
	pop	r15
	return
end

$backspace_str		db	0x1b,'[1D ',0x1b, '[1D', 0


; --- Функция печати шестнадцатеричного числа
; Вход: R0 - число для печати в шестнадцатеричном виде
function	_print_hex
	push		R15
	load		R3, 0x20
	call		_putchar
	load		R7, 0x9
fullnum:
	dec		R7
	je		finish
	load		r4, 0x9
	load		R1, 0xf
	rol		r0, 4
	and		r1, r0
	cmp		r4, r1
	jc		alphachar
	load		r3, 0x30
	addc		r3, r1
	call		_putchar
	jmp		fullnum
alphachar:
	clc
	load		r3, 0x37 		; 'A' - 0xa
	addc		r3, r1
	call		_putchar
	jmp		fullnum
finish:
	load		R3, 0x20
	call		_putchar
	pop		R15
	return
end

; --- Функция перевода строки
function	_newline
	push		R15
	load		R3, 0x0d
	call		_putchar
	load		R3, 0x0a
	call		_putchar
	pop		R15
	return
end
