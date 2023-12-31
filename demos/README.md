Demos and stuff

# Разбор программы usr_demo3.asm

Эта программа использовалась для отладки коммуникации между платой "Марсоход" и персональным компьютером по последовательно коммуникационному порту. Программа использовалась для контроля целостности принимаемых данных. 

Всё, что она умеет делать - выводить приветствие и ожидать нажатия на клавишу удалённого терминала. При получении кода нажатой клавиши, программа в ответ отправляет в терминал строку, содержащую текстовое представление кодов нажатых клавиш в десятичном и шестнадцатеричном виде.

Компьютер "Террикон" - новый компьютер с новой архитектурой.  В 2023 году у него нет компилятора. В в 2034 году у него нет операционной системы. Единственный способ писать программы для него - макроассемблер "Эверест". Чтобы писать на "голом железе" без операционной системы, требуется прошивка. Макроассемблер генерирует такие прошивки. Результатом работы макроассемблера является двоичный файл, являющийся программой аналогом прошивки. Для создания программы-прошивки существует универсальная точка входа - выполнение начинается с первого байта двоичного файла с прошивкой. 

## Генерация исполняемого файла (прошивки)

Для создания прошивки необходимо выполнить следующую команду в командной строке:
<pre>
C:> slagheap.exe usr_demo.asm
</pre>

В результате выполнения этой команды в текущей директории появятся новые файлы, одним из которых будет **usr_demo.bin** - это и есть прошивка, т.е. двоичный файл с инструкциями микропроцессора Эверест. Он используется для загрузки в память виртуального компьютера "Террикон" и передачи ему управления.
В терминах персональных компьютеров двоичный образ исполняемых файлов есть не что иное, как [BIOS](https://ru.wikipedia.org/wiki/BIOS) и является его аналогом - это тот код, которому процесссор передаёт управление после включения питания или сброса.

## Заголовок исполняемого файла.

<pre>
; --- Точка входа при отладке на "голом железе". Она должна быть первой в файле
function test_string
	load	r14, 0x8000 ; set stack
	notch
	jmp	entry
entry:
end
</pre>

Строки, начинающиеся с точки-с-запятой - комментарии. Комментарии нужны разработчикам как воздух - без них трудно понять что делает соответствующий комментариям код. при При построении двоичного кода макроассемблер игнорирует комментарии!

Слово **function** определяет начало функции. Функция, в зависимости  от используемого языка программирования, также известна как подпрограмма или как процедура. Названия разные - смысл одинаков. 

За словом function следует имя функции. В ассемблерах функциями принято называть [подпрограммы](https://ru.wikipedia.org/wiki/Подпрограмма). Подпрограммы умеют вызвать другие подпрограммы, т.е. передать управление другой подпрограмме и вернуться обратно в вызывающую в точности к следующей (которая исполнится следом за вызывающей) инструкции. Подпрограммы-функции - это именованные объекты.

Далее, со смещением вправо и по одной на строку, перечисляются инструкции процессора, являющиеся телом функции. Рассмотрим инструкции заголовка: 

**load	r14, 0x8000** - загрузка константы в регистр R14. По соглашению Everest ABI Этот регистр используется как указатель стека. Аналог регистра SP архитектуры 8086. Установка регистра R14 необходима при отсутствии операционной системы, если файл [usr_demo3.asm](usr_demo3.asm) использован как основной файл проекта и является точкой входа в прошивку. Вершина устанавливается равной размеру оперативной памяти, количество которой ограничено 32 килобайтами.

**notch** - инструкция-префикс. Устанавливает одноимённый внутренний флаг, который меняет поведение следующей за префиксом инструкции.

**jmp	entry** - безусловный переход на метку *entry*. Метка может быть определена выше или ниже, но в пределах функции-подпрограммы. Поскольку перед инструкцией был использован префикс, при переходе на метку в регистр R15 заносится адрес следующей за инструкцией перехода инструкцией. Таким образом сохраняется адрес возврата для инструкции *return*.

**entry:** - собственно сама метка. Хороший стиль - метка в первой позиции строки. Метку отличает от команд, операндов и зарезервированных слов наличие двоеточия в конце. Метка не может начинаться с цифры или любого знака, отличающегося от латинского алфавита.

Далее начнётся исполнение инструкций, следующих за меткой. Приём с сохранением адреса возврата выбран для тестирования библиотечных функций. В каждом исходном файле библиотечных функуий точка входа - первая функция, которая устанавливает стек, поэтому вызывать эту функцию нельзя. Но поскольку она устанавливает стек, она может вызывать другие функции и эта возможность использована для тестирования. 

## Программа печати десятичный и шестнадцатеричных кодов клавиш

На оригинальной Slagheap SoC инициализировать кроме стека было нечего, поэтому следующую за заголовком  небиблиотечную функцию логично назвать maim, по канонам языка Си.

<pre>
function   _main
	push	r15		; сохранение адреса возврата в стеке
	lea	r1, $hi_str	; загрузка в регистр R1 адреса строки, объявленной где-то за пределами функции
	call	_puts		; вывод строки в консоль
loop:
	call	_getchar	; ожидает нажатия клавиши в консоли
	push	r0		; сохраняет код нажатой клавиши в стеке
	lea	r1, $dec_str	; загрузка в регистр R1 адреса строки
	call	_puts		; вывод строки в консоль
	mov	r0, (r14)	; запись в регистр RO кода прочитанного символа, сохранённого в стеке
	call	_print_dec	; вызов подпрограммы печати десятичного числа
	lea	r1, $hex_str	; загрузка в регистр R1 адреса строки
	call	_puts		; вывод строки в консоль
	mov	r0, (r14)	; чтение кода нажатой клавиши с вер
	call	_print_hex	; вызов подпрограммы шестнадцатеричного числа
	call	_newline	; вызов подпрограммы перевода строки
	pop	r0		; восстановление кода нажатой клавиши из стека в регистр R0
	load	r1, 0x51	; Загрузка константы 0x51 (код клавиши Q) в регистр R1
	cmp	r1, r0		; сравнение кода нажатой клавиши
	jne	loop		; если код клавиши, отличный от кода клавиши Q, то переход на метку loop - начало цикла
	pop	r15		; восстановление адреса возврата из стека в регистр R15
	return			; возврат из функции _main
end
</pre>

## Подключение библиотечных подпрограмм

Макроассемблер ничего не знает о функциях *_puts*, *_getchar*, *_print_dec*, *_print_hex* и т.д. Соответственно ему надо как-то сообщить откуда их брать.
Для этого существует директива **include**.

<pre>
include		../lib/asm/tty/tty.asm
include		../lib/asm/emulate/div.asm
include		../lib/asm/tty/print_dec.asm
</pre>

## Объявление констант и строк

Выше в коде использовалась инструкции **lea   r1, $hi_str**, которая ссылалась на текстовые строки. Текстовые строки объявляются в макроассемблере Эверест следующим образом:
<pre>$hi_str		db	'Press Q to quit',13,10,0
$dec_str	db	'Decimal ',0
$hex_str	db	' Hex ',
                db      'number', 0  
</pre>

Особенности выравнивания данных показаны в примере выше. Массивы размерностью N байт имеют особенности выравнивания. В случае, если массив имеет метку, он выравнивается на границу 4 байта (размер машинного слова архитектуры Эверест). Иначе в массив следует без выравнивания за предыдущим. В примере строка с меткой $hex_str имеет размерность, не кратную четырём: `' Hex '` - состоит из двух пробелов и трёх букв, что в сумме даёт длину массива 5 байт. Соответственно, пример сгенерирует следующий массив: 
<pre>
0000: 20 48 65 78 20 6e 75 6d 62 65 72 00 	" Hex number#"
</pre>
В случае же, если бы строка с текстом 'number' имела метка, например так:
<pre>$hex_str	db	' Hex ',
$metka          db      'number', 0  
</pre>
То массив имел бы следующий виде:
<pre>0000: 20 48 65 78 20 00 	" Hex "
0008: 6e 75 6d 62 65 72 00 00 	"number#"
</pre>

## Запуск программы на виртуальном компьютере "Террикон"

В результате обработки файла usr_demo3.asm макроассемблером Эверест был создан файл **usr_demo3.bin**
Для старта виртуального компьютера Эверест используйте следующую команду:
<pre>
C:> slagheap.exe usr_demo3.bin
</pre>

Для сборки прошивки из исходного ассемблерного кода и для моделирования виртуального компьютера используется один и тот же исполняемый файл. Режим работы определяется расширением указанного фала - ```.asm``` - режим ассемблера, ```.bin``` - режим виртуального компьютера с образом прошивки, указанной в командной строке.

