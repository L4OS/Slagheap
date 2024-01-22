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

![Demo's screenshot](https://private-user-images.githubusercontent.com/1204638/298361466-4b990d4a-71d5-4351-8d97-7ca4fa41ce4d.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MDU5NTA5MjIsIm5iZiI6MTcwNTk1MDYyMiwicGF0aCI6Ii8xMjA0NjM4LzI5ODM2MTQ2Ni00Yjk5MGQ0YS03MWQ1LTQzNTEtOGQ5Ny03Y2E0ZmE0MWNlNGQucG5nP1gtQW16LUFsZ29yaXRobT1BV1M0LUhNQUMtU0hBMjU2JlgtQW16LUNyZWRlbnRpYWw9QUtJQVZDT0RZTFNBNTNQUUs0WkElMkYyMDI0MDEyMiUyRnVzLWVhc3QtMSUyRnMzJTJGYXdzNF9yZXF1ZXN0JlgtQW16LURhdGU9MjAyNDAxMjJUMTkxMDIyWiZYLUFtei1FeHBpcmVzPTMwMCZYLUFtei1TaWduYXR1cmU9NDQyYjFjMTI0Yzg1MTM3Yjc3Y2M0ZGY3NTA5MWM1MjM2NjE2ZmNiMmYwNGY5ZmViYzQ5ZmIyZThhYWEwN2VmNCZYLUFtei1TaWduZWRIZWFkZXJzPWhvc3QmYWN0b3JfaWQ9MCZrZXlfaWQ9MCZyZXBvX2lkPTAifQ.NXK16DyywrMqi8-BhoJ8vHh2ymkA5aga0nq-v1n2vh4)


## Узнать больше о виртуальном компьютере Террикон

Предлагаем ознакомиться со следующими разделами: 
- демонстрационная программа, печатающая в терминале коды нажатых клавиш - [demos/README](demos/README.md)
- знакомство с ```lib/asm``` на примере разбора реализации библиотечной функции ```_puts``` [lib/README](lib/README.md)
- внутренне устройство компьютера и библиотеки [lib/asm/README](lib/asm/README.md)






   
