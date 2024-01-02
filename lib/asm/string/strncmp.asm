; ------ Именование регистров ------
assign		r0	FirstWord
assign		r1	pStrOne		; Указатель на первую строку
assign		r2	SecondWord
assign		r3	pStrTwo		; Указатель на вторую строку
assign		r4	FIRST_MASK
assign		r5	SECOND_MASK
assign		r6	MYFLAGS
assign		r7	COUNTER
assign		r8	FOUR_COUNTER

function debug_strncmp
	load 	r14, 0x2000
	lea 	pStrOne, $str_one
	lea 	pStrTwo, $str_two
	load	r2, 4
	call	strncmp
	lea	pStrOne, $same
	jz	same
	lea	pStrOne, $diff
same:
	call	_puts
	call	_newline
	send
end

$str_one  db 'onese', 0
$str_two  db 'onesi', 0
$same	  db 'same',0
$diff	  db 'diff',0

; Функция сравнения строк c длиной
; Вход: 
;	R1 - адрес первой строки
;	R2 - адрес второй строки
;	R3 - количество сравниваемых символов
; Выход:
;	Устанавливает флаг нуля (Z) если строки совпадают
;
; Документация к posix strlen() гласит:
; Функции strcmp() и strncmp() возвращают целое число, которое меньше, больше нуля или равно ему, если строка s1 (или ее первые n байтов) 
; соответственно меньше, больше или равна (равны) s2.
; !!! В текущей версии lib/asm им не следуюет  

; !!!! Просто напрашивается новая инструкция сдвиг через флаг нуля !!!!

function strncmp
	push	r8
	mov	COUNTER, r3
;debug
loop:
	mov	FirstWord,  (pStrOne)
	mov	SecondWord, (pStrTwo)	
	cmp	FirstWord, SecondWord
	jne	look_carefully 

	rol	FirstWord, 8		; Циклический сдвиг на 8 бит влево
	load	FIRST_MASK,  0xff
	and	FIRST_MASK, FirstWord
	je	same_string
	dec	COUNTER
	jz	same_string

	rol	FirstWord, 8		; Циклический сдвиг на 8 бит влево
	load	FIRST_MASK,  0xff
	and	FIRST_MASK, FirstWord
	je	same_string
	dec	COUNTER
	jz	same_string

	rol	FirstWord, 8		; Циклический сдвиг на 8 бит влево
	load	FIRST_MASK,  0xff
	and	FIRST_MASK, FirstWord
	je	same_string
	dec	COUNTER
	jz	same_string

	rol	FirstWord, 8		; Циклический сдвиг на 8 бит влево
	load	FIRST_MASK,  0xff
	and	FIRST_MASK, FirstWord
	je	same_string
	dec	COUNTER
	jz	same_string

	inc	pStrOne, 4
	inc	pStrTwo, 4
	jmp	loop

look_carefully:
	load	MYFLAGS, 0
	load	FOUR_COUNTER, 4
do:
	or	COUNTER, COUNTER
	jz	same_string

	rol	FirstWord, 8		; Циклический сдвиг на 8 бит влево
	load	FIRST_MASK,  0xff	; 
	and	FIRST_MASK, FirstWord
	je	check_second
; Сюда попали если текущий байт первой строки не ноль
	inc	MYFLAGS
check_second:
	rol	SecondWord, 8		; Циклический сдвиг на 8 бит влево
	load	SECOND_MASK,  0xff	; 
	and	SECOND_MASK, SecondWord
	je	check_zero
; Сюда попали если текущий байт второй строки не ноль
	inc	MYFLAGS
check_zero:
	or	MYFLAGS, MYFLAGS
	je	same_string
	cmp	FIRST_MASK, SECOND_MASK
	jne	diff_string
	dec	COUNTTER
	dec	FOUR_COUNTER
	jnz	do
	jmp	look_carefully

diff_string:
same_string:
	pop	r8
	return
end


; C-style функция
; Нужен мозговой штурм для C-ABI - первыпараметр в R0 или R1?
function _strcmp
	push	r15
	call 	strcmp
	load	r0, 1
	jz	exit
	load	r0, 0
exit:
	pop	r15
	return
end

include ../tty/tty.asm
