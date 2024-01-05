assign	r14 	SP

function test_strchr
	load	SP,	0x2000	; Установка вершины стека
	load	r1,	-1
	nop
	lea	r1,	$test_str
debug
	load	r2,	's'
	call	_strchr
	send	; В текущей версии завершит работу программы с с сообщением BUS ERROR
end

$test_str	db	'tester', 0
; Функция нахождения символа в строке
; Вход: 
;	R1 - адрес строки
;	R2 - код символа
; Выход: 
;	R0 - позиция символа в строке или 0, если символа в строке нет

function	_strchr
  assign	r0 	MASK
  assign	r3	COUNTER
  assign	r4 	WORD32

loop:
	mov	WORD32, (r1)	; Загрузка машинного слова из памяти
	load	COUNTER, 4	; Количество символов в машинном слове

charloop:
	rol	WORD32, 8	; Циклический сдвиг на 8 бит влево
	load	MASK, 0xff	; Загрузка восьмибитной константы
	and	MASK, WORD32	; Первая проверка на конец строки
	jz	done		; Переход если найден терминатор строки

	cmp	MASK, r2	; Сравнение текущего символа с искомымы
	je	found

	dec	COUNTER		; Счётчик символов в машинном слове
	jnz	charloop	; Повтор пока не проверит все четыре символа

	inc	r1		; Приращение указателя на следующее машинное слово
	jmp	loop		; И снова поиск
found:
	load	r0, 4		; Количество символов в машинном слове
	subc	r0, COUNTER	; Нвхождение позиции символа в машинном слове
	addc	r0, r1		; Адрес искомого символа
done:
	return			; Возврат из функции
end
