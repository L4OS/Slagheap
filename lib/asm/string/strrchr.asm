assign	r14 	SP

function test_strchr
	load	SP,	0x2000	; Установка вершины стека
	lea		r1,	$test_str
debug
	load	r2,	'e'
	call	_strrchr
	send	; В текущей версии завершит работу программы с с сообщением BUS ERROR
end

$test_str	db	'tester', 0
; Функция нахождения символа в строке
; Вход: 
;	R1 - адрес строки
;	R2 - код символа
; Выход: 
;	R0 - позиция символа в строке или 0, если символа в строке нет

function	_strrchr
  assign	r0 	MASK
  assign	r3	COUNTER
  assign	r4 	WORD32
  assign	r5	POSITION

	load	POSITION, 0		; Хранит адрес последнего найденного искомого символа
loop:
	mov	WORD32, (r1)		; Загрузка машинного слова из памяти
	load	COUNTER, 4		; Количество символов в машинном слове

charloop:
	rol	WORD32, 8		; Циклический сдвиг на 8 бит влево
	load	MASK, 0xff		; Загрузка восьмибитной константы
	and	MASK, WORD32		; Первая проверка на конец строки
	jz	done			; Найден терминатор строки

	cmp	MASK, r2		; Сравнение текущего символа с искомымы
	je	found

comeback:
	dec	COUNTER                 ; Следующая буква в машинном слове (4 байта)
	jnz	charloop

	inc	r1, 4			; Приращение указателя на следующий символ
	jmp	loop

found:
	load	POSITION, 4		; Счётчик символов в машинном слова
	subc	POSITION, COUNTER  	; Нахождении позици символа в слове
	addc	POSITION, r1		; Адрес искомого символа
	jmp	comeback		; И снова в поиск

done:
	mov	r0, POSITION		; Установка адреса найденного символа
	return				; Возврат из функции
end
