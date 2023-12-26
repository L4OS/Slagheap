; Функция приёма файла по протоолу X-modem
;
; Вход: 	R0 - адрес записи принятых данных
; Выход: 	R6 - количество принятых данных или статус операции

function	_recive_file
	load			r6, 0xfffefff0	; Адрес порта статуса UART
	load			r7, 0x9		; Число попыток
	load			r10, 0x1	; Номер блока

send_NAK:
	load			r3, 0x15	; NAK-пакет
wait_snd_ready:
	mov			r5, (r6)	; Чтение статуса устройства
	rcr			R5, 1		; Вытесняем бит BUSY в перенос
	jc			wait_snd_ready	; Опрос устройства в цикле
	inc			r6, 4		; Указатель на регистр передачи данных
	mov			(r6), r3	; Вывод байта
	dec			r6, 4		; Указатель на регистр передачи данных
	load			r13, 0x00700000	; Время ожидиная данных с удалённой стороны

wait_start:
	dec			r13		; Уменьшение времени ожидания
	jnz			check_SOH	; Проверить приём
	dec			r7             	; Уменьшить число поптыток
	jne			send_NAK 	; Повторить передачу NAK
;  debug
 ; set_mr			mr1, r3
	return					; Возврат по ошибке
	
check_SOH:
	mov			r5, (r6)	; Чтение статуса устройства
	rcr			r5, 2		; Бит RCV_RDY в перенос
	jnc			wait_start	; Нет данных

start_recv:
	inc			r6, 4		; Указатель на регистр передачи данных
	mov			r3, (r6)	; Ввод байта
	dec			r6, 4		; Указатель на регистр передачи данных

	load			r2, 0x01	; SOH-заголовок
	cmp			r2, r3		; 
	je			wait_block_id	;

	load			r2, 0x04	; EOT-конец передачи
	cmp			r2, r3		; 
	jne			wait_start	;

; Передача данных завершена
confirm_transmission:
	mov			r5, (r6)		; Чтение статуса устройства
	rcr			R5, 1			; Вытесняем бит BUSY в перенос
	jc			confirm_transmission	; Опрос устройства в цикле
	inc			r6, 4			; Указатель на регистр передачи данных
	load			r3, 0x06		; ACK-пакет
	mov			(r6), r3		; Вывод байта
	dec			r6, 4			; Указатель на регистр передачи данных

	dec			r10, 1			; Блок начинается с единицы, посему так
	shl			r10, 7			; Умножить число блоков на 128
	mov			r6, r10
	return

wait_block_id:
	mov			r5, (r6)	; Чтение статуса устройства
	rcr			r5, 2		; Бит RCV_RDY в перенос
	jc			read_block_id	; Блок принят
	dec			r13		; Уменьшение времени ожидания
	jnz			wait_block_id	; Проверить приём
	dec			r6, 1           ;; Статус = адрес регистра статуса UART - 1
	return					; Возврат по ошибке


read_block_id:
	inc			r6, 4		; Указатель на регистр передачи данных
	mov			r1, (r6)	; Ввод байта
	dec			r6, 4		; Указатель на регистр передачи данных
	
wait_block_inv:
	mov			r5, (r6)	; Чтение статуса устройства
	rcr			r5, 2		; Бит RCV_RDY в перенос
	jc			read_block_inv	; Инверсный номер блока принят
	dec			r13		; Уменьшение времени ожидания
	jnz			wait_block_inv	; Проверить приём
	dec			r6, 2           ;; Статус = адрес регистра статуса UART - 2
	return					; Возврат по ошибке

read_block_inv:
	inc			r6, 4		; Указатель на регистр передачи данных
	mov			r2, (r6)	; Ввод байта
	dec			r6, 4		; Указатель на регистр передачи данных

	not			r2
	load			r4, 0xff
	and			r2, r4
	cmp			r2, r1
	je			compare_block_id
	dec			r6, 3           ;; Статус = адрес регистра статуса UART - 3
	return					; Возврат по ошибке

compare_block_id:
	cmp			r1, r10			; Сравнить номера блоков
	je			read_data_block
	jc			re_read_data_block	; Временный тест
	dec			r6, 4           	;; Статус = адрес регистра статуса UART - 4

;  debug
;  nop
;  nop
;  nop
;  nop
;  set_mr			mr1, r1
;  set_mr			mr1, r2
;  set_mr			mr2, r10

	return					; Возврат по ошибке

re_read_data_block:
	load			r2, 0x80
	clc
	subc			r0, r2
	dec			r10, 1

read_data_block:
	load			r12, 0x00	; Контрольная сумма
	load			r11, 0x80	; Количество принимаемых байт
	load			r13, 0x00500000	; Время ожидиная данных с удалённой стороны

read_word:
	load			r8, 0		; В этом регистре накапливаем результат
	load			r9, 4		; Количество байт в слове

wait_data:
	mov			r5, (r6)	; Чтение статуса устройства
	rcr			r5, 2		; Бит RCV_RDY в перенос
	jc			data_ready	; Инверсный номер блока принят
	dec			r13		; Уменьшение времени ожидания
	jnz			wait_data	; Проверить приём
	dec			r6, 5           ;; Статус = адрес регистра статуса UART - 5
	return					; Возврат по ошибке
	
data_ready:
	inc			r6, 4		; Указатель на регистр передачи данных
	mov			r2, (r6)	; Ввод байта
	dec			r6, 4		; Указатель на регистр передачи данных
	
	clc
	addc			r12, r2
	rol			r8, 8		; Сдвигаем очередь на 8 бит
	or			r8, r2		; Сливаем с принятым байтом
	
	dec			r9, 1		; Проверяем слово
	jne			wait_data

	mov			(r0), r8	; Сохраняем 4 байта
	inc			r0, 4		; К следующему слову
	dec			r11, 4
	jne			read_word	

; Фиксация контрольной суммы
	load			r2, 0xff
	and			r12, r2

; Чтение контрольной суммы
wait_checksum:
	mov			r5, (r6)	; Чтение статуса устройства
	rcr			r5, 2		; Бит RCV_RDY в перенос
	jc			checksum_ready	; Контрольная сумма ждёт
	dec			r13		; Уменьшение времени ожидания
	jnz			wait_checksum	; Проверить приём
	dec			r6, 5           ;; Статус = адрес регистра статуса UART - 5
	return					; Возврат по ошибке
	
checksum_ready:
	inc			r6, 4		; Указатель на регистр передачи данных
	mov			r2, (r6)	; Ввод байта
	dec			r6, 4		; Указатель на регистр передачи данных

;  debug
;  nop
;  nop
;  nop
;  nop
;  set_mr			mr1, r12
;  set_mr			mr2, r2
;  set_mr			mr3, r13


	cmp			r2, r12		; Сравнение контольных сумм
	je			prepare_next_block
	dec			r6, 6           ;; Статус = адрес регистра статуса UART - 6
	return					; Возврат по ошибке

prepare_next_block:
	inc			r10, 1

;;	load			r2, 0xff	; Номера блоков переполнятся!!! 
;;	and			r10, r2		; Надо раскоментировать чтобы принимать более 32 Кб !!!!

wait_snd_ack:
	mov			r5, (r6)	; Чтение статуса устройства
	rcr			R5, 1		; Вытесняем бит BUSY в перенос
	jc			wait_snd_ack	; Опрос устройства в цикле

	inc			r6, 4		; Указатель на регистр передачи данных
	load			r3, 0x06	; ACK-пакет
	mov			(r6), r3	; Вывод байта
	dec			r6, 4		; Указатель на регистр передачи данных

wait_ack_sent:
	mov			r5, (r6)	; Чтение статуса устройства
	rcr			R5, 1		; Вытесняем бит BUSY в перенос
	jc			wait_ack_sent	; Опрос устройства в цикле

wait_data_recv:
	mov			r5, (r6)	; Чтение статуса устройства
	rcr			r5, 2		; Бит RCV_RDY в перенос
	jnc			wait_data_recv	; Нет данных

	load			r13, 0x00500000	; Время ожидиная данных с удалённой стороны
	jmp			start_recv

end

