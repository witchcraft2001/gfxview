В данном архиве расположены исходники утилиты GFXVIEW by Anton Enin для ПК Sprinter.
Исходники получены дизассемблированием программы, поэтому коментарии скудны - насколько
понял код при беглом анализе так и описал.
Для сборки необходим кроссассемблер sjasmplus, путь к нему прописан в батниках, если необходимо - поправьте.
Для сборки основного кода запустить make_main.bat. Для сборки загрузчика - make_loader.bat.
После сборки получаются 2 файла - gfx_loader.bin и gfx_main.bin. Они ассемблируются корректно,
файлы получаются "1 в 1" с исходным. Однако, для использования их нужно склеить в указанном порядке и переименовать
в gfxview.exe, но возможно при запуске (скорее всего без параметров в ком.строке),
все порушится, т.к. в оригинальном файле еще приклеена фоновая картинка, которую я не стал выдирать, но которую загрузчик
дочитывает в память если программе не было передано параметров в командной строке.
Загрузчик передает некоторые параметры в основной код программы через определенные ячейки памяти,
при изменении основного кода адреса могут измениться. Адреса этих ячеек передаются через файл экспорта
при компиляции main, и инклудятся в loader, поэтому стоит компилировать сначала main, а затем loader.

----------------------------------------------------------------------------------------
Дмитрий Михальченков, witchcraft2001@mail.ru				10:33 28.08.2013