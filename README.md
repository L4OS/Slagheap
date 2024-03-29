# Slagheap SoC

В этом репозитории вы найдёте библиотеки, тесты и примеры програм для компьютера "Террикон", также известного как Slagheap SoC. Изначально "компьютер" был реализован на плате ["Марсоход"](https://marsohod.org/). Slagheap SOC был достаточно простым компьютером, он не задействовал микросхему DRAM и общался с внешним миром через UART порт. 

Главной особенностью этого компьютера была оригинальная система команд архитектуры CISC ([Complex Instruction Set Computer](https://habr.com/ru/companies/selectel/articles/542074/)).
Система команд Everest отличается высокой плотностью кода и оптимизирована для потокового исполнения.

<sup>Архитектура в шутку названная была названа "Эверест", как бы в противовес "Эльбрусам". </sup>

![Everest instruction codes map](https://everest.l4os.ru/wp-content/uploads/2015/02/MAP_EVER_1_1.png)

Система команд Эверест обладает высоким потенциалом расширения - на карте показаны незадействованные коды операций.

### Виртуальный компьютер "Террикон"

В процессе отладки SoC была реализована программная модель микропроцессора. В процессе тестирования программная модель приросла виртуальным видеоадаптером и клавиатурой в дополнение к виртуальному алфавитно-цифровому терминал. Технические характеристики виртуального компьютера "Террикон": 
- 32 бита;
- 16 регистров регистров общего назначения;
- 64 регистра  регистра сообщений;
- 32 килобайта оперативной памяти, может быть увеличена до 2 гигабайт;
- консоль-терминал, может быть использована для отладки;
- видеоадаптер 640х480 с цветностью 32 бита на пиксель;
- виртуальная клавиатура;
- виртуальная мышь;
- счётчик тактов хоста;
- 16 регистров виртуальной CMOS памяти .

## Скриншот одной из демонстрационных программ, показывающей прокрутку текста.

![Demo's screenshot](https://ic.pics.livejournal.com/mandrykin/9950019/2156/2156_original.png)


## Узнать больше о виртуальном компьютере Террикон

Предлагаем ознакомиться со следующими разделами: 
- демонстрационная программа, печатающая в терминале коды нажатых клавиш - [demos/README](demos/README.md)
- знакомство с ```lib/asm``` на примере разбора реализации библиотечной функции ```_puts``` [lib/README](lib/README.md)
- внутренне устройство компьютера и библиотеки [lib/asm/README](lib/asm/README.md)






   
