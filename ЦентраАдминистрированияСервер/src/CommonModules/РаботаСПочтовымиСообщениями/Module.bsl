

// Служебная функция используется для проверки учетной записи электронной почты.
//
 &НаСервере
Процедура ПроверитьВозможностьОтправкиИПолученияЭлектроннойПочтыНаСервере(УчетнаяЗапись, СообщениеОбОшибке, ДополнительноеСообщение) Экспорт
	
	НастройкиУчетнойЗаписи = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(УчетнаяЗапись, "ИспользоватьДляОтправки,ИспользоватьДляПолучения");
	
	СообщениеОбОшибке = "";
	ДополнительноеСообщение = "";
	
	Если НастройкиУчетнойЗаписи.ИспользоватьДляОтправки Тогда
		Попытка
			ПроверитьВозможностьПодключенияКПочтовомуСерверу(УчетнаяЗапись, Ложь);
		Исключение
			СообщениеОбОшибке = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Ошибка в настройках исходящей почты: %1'"), КраткоеПредставлениеОшибки(ИнформацияОбОшибке()));
		КонецПопытки;
		Если Не НастройкиУчетнойЗаписи.ИспользоватьДляПолучения Тогда
			ДополнительноеСообщение = Символы.ПС + НСтр("ru = '(Выполнена проверка отправки электронных сообщений.)'");
		КонецЕсли;
	КонецЕсли;
	
	Если НастройкиУчетнойЗаписи.ИспользоватьДляПолучения Тогда
		Попытка
			ПроверитьВозможностьПодключенияКПочтовомуСерверу(УчетнаяЗапись, Истина);
		Исключение
			Если ЗначениеЗаполнено(СообщениеОбОшибке) Тогда
				СообщениеОбОшибке = СообщениеОбОшибке + Символы.ПС;
			КонецЕсли;
			
			СообщениеОбОшибке = СообщениеОбОшибке + СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Ошибка в настройках входящей почты: %1'"),
				КраткоеПредставлениеОшибки(ИнформацияОбОшибке()) );
		КонецПопытки;
		Если Не НастройкиУчетнойЗаписи.ИспользоватьДляОтправки Тогда
			ДополнительноеСообщение = Символы.ПС + НСтр("ru = '(Выполнена проверка получения электронных сообщений.)'");
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

 &НаСервере
Процедура ПроверитьВозможностьПодключенияКПочтовомуСерверу(Знач УчетнаяЗапись, ВходящаяПочта)
	
	Профиль = ИнтернетПочтовыйПрофиль(УчетнаяЗапись, ВходящаяПочта);
	Соединение = Новый ИнтернетПочта;
	
	Если ВходящаяПочта Тогда
		Протокол = ПротоколИнтернетПочты.POP3;
		Если ОбщегоНазначения.ЗначениеРеквизитаОбъекта(УчетнаяЗапись, "ПротоколВходящейПочты") = "IMAP" Тогда
			Протокол = ПротоколИнтернетПочты.IMAP;
		КонецЕсли;
		Соединение.Подключиться(Профиль, Протокол);
	Иначе
		Соединение.Подключиться(Профиль);
	КонецЕсли;
	
	Соединение.Отключиться();
	
КонецПроцедуры

// Создает профиль переданной учетной записи для подключения к почтовому серверу.
//
// Параметры:
//  УчетнаяЗапись - СправочникСсылка.УчетныеЗаписиЭлектроннойПочты - учетная запись.
//
// Возвращаемое значение:
//  ИнтернетПочтовыйПрофиль - профиль учетной записи;
//  Неопределено - не удалось получить учетную запись по ссылке.
//
 &НаСервере
Функция ИнтернетПочтовыйПрофиль(УчетнаяЗапись, ДляПолучения = Ложь) Экспорт
	
	ТекстЗапроса =
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	УчетныеЗаписиЭлектроннойПочты.СерверВходящейПочты КАК АдресСервераIMAP,
	|	УчетныеЗаписиЭлектроннойПочты.ПортСервераВходящейПочты КАК ПортIMAP,
	|	УчетныеЗаписиЭлектроннойПочты.ИспользоватьЗащищенноеСоединениеДляВходящейПочты КАК ИспользоватьSSLIMAP,
	|	УчетныеЗаписиЭлектроннойПочты.Пользователь КАК ПользовательIMAP,
	|	УчетныеЗаписиЭлектроннойПочты.ИспользоватьБезопасныйВходНаСерверВходящейПочты КАК ТолькоЗащищеннаяАутентификацияIMAP,
	|	УчетныеЗаписиЭлектроннойПочты.СерверВходящейПочты КАК АдресСервераPOP3,
	|	УчетныеЗаписиЭлектроннойПочты.ПортСервераВходящейПочты КАК ПортPOP3,
	|	УчетныеЗаписиЭлектроннойПочты.ИспользоватьЗащищенноеСоединениеДляВходящейПочты КАК ИспользоватьSSLPOP3,
	|	УчетныеЗаписиЭлектроннойПочты.Пользователь КАК Пользователь,
	|	УчетныеЗаписиЭлектроннойПочты.ИспользоватьБезопасныйВходНаСерверВходящейПочты КАК ТолькоЗащищеннаяАутентификацияPOP3,
	|	УчетныеЗаписиЭлектроннойПочты.СерверИсходящейПочты КАК АдресСервераSMTP,
	|	УчетныеЗаписиЭлектроннойПочты.ПортСервераИсходящейПочты КАК ПортSMTP,
	|	УчетныеЗаписиЭлектроннойПочты.ИспользоватьЗащищенноеСоединениеДляИсходящейПочты КАК ИспользоватьSSLSMTP,
	|	УчетныеЗаписиЭлектроннойПочты.ТребуетсяВходНаСерверПередОтправкой КАК POP3ПередSMTP,
	|	УчетныеЗаписиЭлектроннойПочты.ПользовательSMTP КАК ПользовательSMTP,
	|	УчетныеЗаписиЭлектроннойПочты.ИспользоватьБезопасныйВходНаСерверИсходящейПочты КАК ТолькоЗащищеннаяАутентификацияSMTP,
	|	УчетныеЗаписиЭлектроннойПочты.ВремяОжидания КАК Таймаут,
	|	УчетныеЗаписиЭлектроннойПочты.ПротоколВходящейПочты КАК Протокол
	|ИЗ
	|	Справочник.УчетныеЗаписиЭлектроннойПочты КАК УчетныеЗаписиЭлектроннойПочты
	|ГДЕ
	|	УчетныеЗаписиЭлектроннойПочты.Ссылка = &Ссылка";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("Ссылка", УчетнаяЗапись);
	Выборка = Запрос.Выполнить().Выбрать();
	
	Результат = Неопределено;
	Если Выборка.Следующий() Тогда
		СписокСвойствIMAP = "АдресСервераIMAP,ПортIMAP,ИспользоватьSSLIMAP,ПользовательIMAP,ТолькоЗащищеннаяАутентификацияIMAP";
		СписокСвойствPOP3 = "АдресСервераPOP3,ПортPOP3,ИспользоватьSSLPOP3,Пользователь,ТолькоЗащищеннаяАутентификацияPOP3";
		СписокСвойствSMTP = "АдресСервераSMTP,ПортSMTP,ИспользоватьSSLSMTP,ПользовательSMTP,ТолькоЗащищеннаяАутентификацияSMTP";
		
		УстановитьПривилегированныйРежим(Истина);
		Пароли = ОбщегоНазначения.ПрочитатьДанныеИзБезопасногоХранилища(УчетнаяЗапись, "Пароль,ПарольSMTP");
		УстановитьПривилегированныйРежим(Ложь);
		
		Результат = Новый ИнтернетПочтовыйПрофиль;
		Если ДляПолучения Тогда
			Если Выборка.Протокол = "IMAP" Тогда
				ТребуемыеСвойства = СписокСвойствIMAP;
				Результат.ПарольIMAP = Пароли.Пароль;
			Иначе
				ТребуемыеСвойства = СписокСвойствPOP3;
				Результат.Пароль = Пароли.Пароль;
			КонецЕсли;
		Иначе
			ТребуемыеСвойства = СписокСвойствSMTP;
			Результат.ПарольSMTP = Пароли.ПарольSMTP;
			Если Выборка.Протокол <> "IMAP" И Выборка.POP3ПередSMTP Тогда
				ТребуемыеСвойства = ТребуемыеСвойства + ",POP3ПередSMTP," + СписокСвойствPOP3;
				Результат.Пароль = Пароли.Пароль;
			КонецЕсли;
			Если Выборка.Протокол = "IMAP" Тогда
				ТребуемыеСвойства = ТребуемыеСвойства + "," + СписокСвойствIMAP;
				Результат.ПарольIMAP =Пароли.Пароль;
			КонецЕсли;
		КонецЕсли;
		ТребуемыеСвойства = ТребуемыеСвойства + ",Таймаут";
		ЗаполнитьЗначенияСвойств(Результат, Выборка, ТребуемыеСвойства);
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Выполняет отправку почтовых сообщений.
// Функция может вызвать исключение, которое требуется обработать.
//
// Параметры:
//  УчетнаяЗапись - СправочникСсылка.УчетныеЗаписиЭлектроннойПочты - ссылка на
//                 учетную запись электронной почты.
//  ПараметрыОтправки - Структура - содержит всю необходимую информацию о письме:
//
//   * Кому - Массив, Строка - интернет адреса получателей письма.
//          - Массив - коллекция структур адресов:
//              * Адрес         - Строка - почтовый адрес (должно быть обязательно заполнено).
//              * Представление - Строка - имя адресата.
//          - Строка - интернет адреса получателей письма, разделитель - ";".
//
//   * ПолучателиСообщения - Массив - массив структур, описывающий получателей:
//      ** Адрес - Строка - Почтовый адрес получателя сообщения.
//      ** Представление - Строка - представление адресата.
//
//   * Копии        - Массив, Строка - адреса получателей копий письма. См. описание поля Кому.
//
//   * СкрытыеКопии - Массив, Строка - адреса получателей скрытых копий письма. См. описание поля Кому.
//
//   * Тема       - Строка - (обязательный) тема почтового сообщения.
//   * Тело       - Строка - (обязательный) текст почтового сообщения (простой текст в кодировке win-1251).
//   * Важность   - ВажностьИнтернетПочтовогоСообщения.
//
//   * Вложения - Массив - файлы, которые необходимо приложить к письму (описания в виде структур):
//     ** Представление - Строка - имя файла вложения;
//     ** АдресВоВременномХранилище - Строка - адрес двоичных данных вложения во временном хранилище.
//     ** Кодировка - Строка - кодировка вложения (используется, если отличается от кодировки письма).
//     ** Идентификатор - Строка - (необязательный) используется для отметки картинок, отображаемых в теле письма.
//
//   * АдресОтвета - Соответствие - см. описание поля Кому.
//   * ИдентификаторыОснований - Строка - идентификаторы оснований данного письма.
//   * ОбрабатыватьТексты  - Булево - необходимость обрабатывать тексты письма при отправке.
//   * УведомитьОДоставке  - Булево - необходимость запроса уведомления о доставке.
//   * УведомитьОПрочтении - Булево - необходимость запроса уведомления о прочтении.
//   * ТипТекста   - Строка, Перечисление.ТипыТекстовЭлектронныхПисем, ТипТекстаПочтовогоСообщения - определяет тип
//                  переданного теста допустимые значения:
//                  HTML/ТипыТекстовЭлектронныхПисем.HTML - текст почтового сообщения в формате HTML.
//                  ПростойТекст/ТипыТекстовЭлектронныхПисем.ПростойТекст - простой текст почтового сообщения.
//                                                                          Отображается "как есть" (значение по
//                                                                          умолчанию).
//                  РазмеченныйТекст/ТипыТекстовЭлектронныхПисем.РазмеченныйТекст - текст почтового сообщения в формате
//                                                                                  Rich Text.
//   * Соединение - ИнтернетПочта - существующее соединение с почтовым сервером. Если не указано, то создается новое.
//   * ПротоколПочты - Строка - если указано значение "IMAP", то письмо будет передано по протоколу IMAP, иначе - по
//                              протоколу SMTP.
//   * ИдентификаторСообщения - Строка - (возвращаемый параметр) идентификатор отправленного почтового сообщения на SMTP
//                                       сервере;
//   * ОшибочныеПолучатели - Соответствие - (возвращаемый параметр) список адресов, по которым отправка не выполнена. 
//                                          См. возвращаемое значение метода ИнтернетПочта.Послать() в синтакс-помощнике.
//
//  Соединение - ИнтернетПочта - (параметр устарел) см. параметр ПараметрыОтправки.Соединение.
//  ПротоколПочты - Строка     - (параметр устарел) см. параметр ПараметрыОтправки.Соединение.
//
// Возвращаемое значение:
//  Строка - Идентификатор сообщения.
Функция ОтправитьПочтовоеСообщение(Знач УчетнаяЗапись, Знач ПараметрыОтправки,
	Знач Соединение = Неопределено, ПротоколПочты = "") Экспорт
	
	Если Соединение <> Неопределено Тогда
		ПараметрыОтправки.Вставить("Соединение", Соединение);
	КонецЕсли;
	
	Если Не ПустаяСтрока(ПротоколПочты) Тогда
		ПараметрыОтправки.Вставить("ПротоколПочты", ПротоколПочты);
	КонецЕсли;
	
	Если ТипЗнч(УчетнаяЗапись) <> Тип("СправочникСсылка.УчетныеЗаписиЭлектроннойПочты")
		Или НЕ ЗначениеЗаполнено(УчетнаяЗапись) Тогда
		ВызватьИсключение НСтр("ru = 'Учетная запись не заполнена или заполнена неправильно.'");
	КонецЕсли;
	
	Если ПараметрыОтправки = Неопределено Тогда
		ВызватьИсключение НСтр("ru = 'Не заданы параметры отправки.'");
	КонецЕсли;
	
	ТипЗнчКому = ?(ПараметрыОтправки.Свойство("Кому"), ТипЗнч(ПараметрыОтправки.Кому), Неопределено);
	ТипЗнчКопии = ?(ПараметрыОтправки.Свойство("Копии"), ТипЗнч(ПараметрыОтправки.Копии), Неопределено);
	СкрытыеКопии = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(ПараметрыОтправки, "СкрытыеКопии");
	Если СкрытыеКопии = Неопределено Тогда
		СкрытыеКопии = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(ПараметрыОтправки, "СлепыеКопии");
	КонецЕсли;
	
	Если ТипЗнчКому = Неопределено И ТипЗнчКопии = Неопределено И СкрытыеКопии = Неопределено Тогда
		ВызватьИсключение НСтр("ru = 'Не указано ни одного получателя.'");
	КонецЕсли;
	
	Если ТипЗнчКому = Тип("Строка") Тогда
		ПараметрыОтправки.Кому = ОбщегоНазначенияКлиентСервер.РазобратьСтрокуСПочтовымиАдресами(ПараметрыОтправки.Кому);
	ИначеЕсли ТипЗнчКому <> Тип("Массив") Тогда
		ПараметрыОтправки.Вставить("Кому", Новый Массив);
	КонецЕсли;
	
	Если ТипЗнчКопии = Тип("Строка") Тогда
		ПараметрыОтправки.Копии = ОбщегоНазначенияКлиентСервер.РазобратьСтрокуСПочтовымиАдресами(ПараметрыОтправки.Копии);
	ИначеЕсли ТипЗнчКопии <> Тип("Массив") Тогда
		ПараметрыОтправки.Вставить("Копии", Новый Массив);
	КонецЕсли;
	
	Если ТипЗнч(СкрытыеКопии) = Тип("Строка") Тогда
		ПараметрыОтправки.СкрытыеКопии = ОбщегоНазначенияКлиентСервер.РазобратьСтрокуСПочтовымиАдресами(СкрытыеКопии);
	ИначеЕсли ТипЗнч(СкрытыеКопии) <> Тип("Массив") Тогда
		ПараметрыОтправки.Вставить("СкрытыеКопии", Новый Массив);
	КонецЕсли;
	
	Если ПараметрыОтправки.Свойство("АдресОтвета") И ТипЗнч(ПараметрыОтправки.АдресОтвета) = Тип("Строка") Тогда
		ПараметрыОтправки.АдресОтвета = ОбщегоНазначенияКлиентСервер.РазобратьСтрокуСПочтовымиАдресами(ПараметрыОтправки.АдресОтвета);
	КонецЕсли;
	
	ОтправитьСообщение(УчетнаяЗапись, ПараметрыОтправки);
	ПослеОтправкиПисьма(ПараметрыОтправки);
	
	Если ПараметрыОтправки.ОшибочныеПолучатели.Количество() > 0 Тогда
		ТекстОшибки = НСтр("ru = 'Следующие почтовые адреса не были приняты почтовым сервером:'");
		Для Каждого ОшибочныйПолучатель Из ПараметрыОтправки.ОшибочныеПолучатели Цикл
			ТекстОшибки = ТекстОшибки + Символы.ПС + СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку("%1: %2",
				ОшибочныйПолучатель.Ключ, ОшибочныйПолучатель.Значение);
		КонецЦикла;
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;
	
	Возврат ПараметрыОтправки.ИдентификаторСообщения;
	
КонецФункции

Процедура ОтправитьСообщение(Знач УчетнаяЗапись, Знач ПараметрыОтправки) Экспорт
	Перем Кому, Тема, Тело, Вложения, АдресОтвета, ТипТекста, Копии, СкрытыеКопии, ПротоколПочты, Соединение;
	
	ПараметрыОтправки.Свойство("Соединение", Соединение);
	ПараметрыОтправки.Свойство("ПротоколПочты", ПротоколПочты);
	ПараметрыОтправки.Вставить("ИдентификаторСообщения", "");
	ПараметрыОтправки.Вставить("ОшибочныеПолучатели", Новый Соответствие);
	
	Если Не ПараметрыОтправки.Свойство("Тема", Тема) Тогда
		Тема = "";
	КонецЕсли;
	
	Если Не ПараметрыОтправки.Свойство("Тело", Тело) Тогда
		Тело = "";
	КонецЕсли;
	
	Кому = ПараметрыОтправки.Кому;
	
	Если ТипЗнч(Кому) = Тип("Строка") Тогда
		Кому = ОбщегоНазначенияКлиентСервер.РазобратьСтрокуСПочтовымиАдресами(Кому);
	КонецЕсли;
	
	ПараметрыОтправки.Свойство("Вложения", Вложения);
	
	Письмо = Новый ИнтернетПочтовоеСообщение;
	Письмо.Тема = Тема;
	
	// Формируем адрес получателя.
	Для Каждого ПочтовыйАдресПолучателя Из Кому Цикл
		Получатель = Письмо.Получатели.Добавить(ПочтовыйАдресПолучателя.Адрес);
		Получатель.ОтображаемоеИмя = ПочтовыйАдресПолучателя.Представление;
	КонецЦикла;
	
	// Формируем адрес получателя поля Копии.
	Если ПараметрыОтправки.Свойство("Копии", Копии) Тогда
		Для Каждого ПочтовыйАдресПолучателяКопии Из Копии Цикл
			Получатель = Письмо.Копии.Добавить(ПочтовыйАдресПолучателяКопии.Адрес);
			Получатель.ОтображаемоеИмя = ПочтовыйАдресПолучателяКопии.Представление;
		КонецЦикла;
	КонецЕсли;
	
	// Формируем адрес получателя поля СкрытыеКопии.
	Если ПараметрыОтправки.Свойство("СкрытыеКопии", СкрытыеКопии) Тогда
		Для Каждого СведенияОПолучателе Из СкрытыеКопии Цикл
			Получатель = Письмо.СлепыеКопии.Добавить(СведенияОПолучателе.Адрес);
			Получатель.ОтображаемоеИмя = СведенияОПолучателе.Представление;
		КонецЦикла;
	КонецЕсли;
	
	// Формируем адрес ответа, если необходимо.
	Если ПараметрыОтправки.Свойство("АдресОтвета", АдресОтвета) Тогда
		Для Каждого ПочтовыйАдресОтвета Из АдресОтвета Цикл
			ПочтовыйАдресОбратный = Письмо.ОбратныйАдрес.Добавить(ПочтовыйАдресОтвета.Адрес);
			ПочтовыйАдресОбратный.ОтображаемоеИмя = ПочтовыйАдресОтвета.Представление;
		КонецЦикла;
	КонецЕсли;
	
	// Получение реквизитов отправителя.
	РеквизитыОтправителя = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(УчетнаяЗапись, "ИмяПользователя,АдресЭлектроннойПочты,ОтправлятьСкрытыеКопииПисемНаЭтотАдрес");
	
	// Добавляем к письму имя отправителя.
	Письмо.ИмяОтправителя              = РеквизитыОтправителя.ИмяПользователя;
	Письмо.Отправитель.ОтображаемоеИмя = РеквизитыОтправителя.ИмяПользователя;
	Письмо.Отправитель.Адрес           = РеквизитыОтправителя.АдресЭлектроннойПочты;
	
	// Добавляем скрытую копию на адрес отправителя.
	Если РеквизитыОтправителя.ОтправлятьСкрытыеКопииПисемНаЭтотАдрес Тогда
		Получатель = Письмо.СлепыеКопии.Добавить(РеквизитыОтправителя.АдресЭлектроннойПочты);
		Получатель.ОтображаемоеИмя = РеквизитыОтправителя.ИмяПользователя;
	КонецЕсли;
	
	// Добавляем вложения к письму.
	Если Вложения <> Неопределено Тогда
		Для Каждого Вложение Из Вложения Цикл
			Если ТипЗнч(Вложение) = Тип("Структура") Тогда
				НовоеВложение = Письмо.Вложения.Добавить(ПолучитьИзВременногоХранилища(Вложение.АдресВоВременномХранилище), Вложение.Представление);
				Если Вложение.Свойство("Кодировка") И Не ПустаяСтрока(Вложение.Кодировка) Тогда
					НовоеВложение.Кодировка = Вложение.Кодировка;
				КонецЕсли;
				Если Вложение.Свойство("Идентификатор") Тогда
					НовоеВложение.Идентификатор = Вложение.Идентификатор;
				КонецЕсли;
			Иначе // Поддержка обратной совместимости с 2.2.1.
				Если ТипЗнч(Вложение.Значение) = Тип("Структура") Тогда
					НовоеВложение = Письмо.Вложения.Добавить(Вложение.Значение.ДвоичныеДанные, Вложение.Ключ);
					Если Вложение.Значение.Свойство("Идентификатор") Тогда
						НовоеВложение.Идентификатор = Вложение.Значение.Идентификатор;
					КонецЕсли;
					Если Вложение.Значение.Свойство("Кодировка") Тогда
						НовоеВложение.Кодировка = Вложение.Значение.Кодировка;
					КонецЕсли;
					Если Вложение.Значение.Свойство("ТипСодержимого") Тогда
						НовоеВложение.ТипСодержимого = Вложение.Значение.ТипСодержимого;
					КонецЕсли;
					Если Вложение.Значение.Свойство("Имя") Тогда
						НовоеВложение.Имя = Вложение.Значение.Имя;
					КонецЕсли;
				Иначе
					ИнтернетПочтовоеВложение = Письмо.Вложения.Добавить(Вложение.Значение, Вложение.Ключ);
					Если ТипЗнч(Вложение.Значение) = Тип("ИнтернетПочтовоеСообщение") Тогда
						ИнтернетПочтовоеВложение.ТипСодержимого = "message/rfc822";
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	//Для Каждого Вложение Из Письмо.Вложения Цикл
	//	Если Не ЗначениеЗаполнено(Вложение.ТипСодержимого) Тогда
	//		ТипСодержимого = ОпределитьТипСодержимогоПоИмениФайла(Вложение.Имя);
	//		Если ЗначениеЗаполнено(ТипСодержимого) Тогда
	//			Вложение.ТипСодержимого = ТипСодержимого;
	//		КонецЕсли;
	//	КонецЕсли;
	//КонецЦикла;
	
	Если ПараметрыОтправки.Свойство("ИдентификаторыОснований") Тогда
		Письмо.УстановитьПолеЗаголовка("References", ПараметрыОтправки.ИдентификаторыОснований);
	КонецЕсли;
	
	ТипТекста = Неопределено;
	//Если ТипЗнч(Тело) = Тип("ФорматированныйДокумент") Тогда
	//	СодержимоеПисьма = ПолучитьHTMLФорматированногоДокументаДляПисьма(Тело);
	//	Тело = СодержимоеПисьма.ТекстHTML;
	//	Картинки = СодержимоеПисьма.Картинки;
	//	ТипТекста = ТипТекстаПочтовогоСообщения.HTML;
	//	
	//	ДополнительныеВложения = Новый Массив;
	//	Для Каждого Картинка Из Картинки Цикл
	//		ИмяКартинки = Картинка.Ключ;
	//		ДанныеКартинки = Картинка.Значение;
	//		Вложение = Письмо.Вложения.Добавить(ДанныеКартинки.ПолучитьДвоичныеДанные(), ИмяКартинки);
	//		Вложение.Идентификатор = ИмяКартинки;
	//	КонецЦикла;
	//КонецЕсли;
	Текст = Письмо.Тексты.Добавить(Тело);
	Если ЗначениеЗаполнено(ТипТекста) Тогда
		Текст.ТипТекста = ТипТекста;
	КонецЕсли;
	
	Если ТипТекста = Неопределено Тогда
		Если ПараметрыОтправки.Свойство("ТипТекста", ТипТекста) Тогда
			Если ТипЗнч(ТипТекста) = Тип("Строка") Тогда
				Если      ТипТекста = "HTML" Тогда
					Текст.ТипТекста = ТипТекстаПочтовогоСообщения.HTML;
				ИначеЕсли ТипТекста = "RichText" Тогда
					Текст.ТипТекста = ТипТекстаПочтовогоСообщения.РазмеченныйТекст;
				Иначе
					Текст.ТипТекста = ТипТекстаПочтовогоСообщения.ПростойТекст;
				КонецЕсли;
			ИначеЕсли ТипЗнч(ТипТекста) = Тип("ПеречислениеСсылка.ТипыТекстовЭлектронныхПисем") Тогда
				Если      ТипТекста = Перечисления.ТипыТекстовЭлектронныхПисем.HTML
					  ИЛИ ТипТекста = Перечисления.ТипыТекстовЭлектронныхПисем.HTMLСКартинками Тогда
					Текст.ТипТекста = ТипТекстаПочтовогоСообщения.HTML;
				ИначеЕсли ТипТекста = Перечисления.ТипыТекстовЭлектронныхПисем.РазмеченныйТекст Тогда
					Текст.ТипТекста = ТипТекстаПочтовогоСообщения.РазмеченныйТекст;
				Иначе
					Текст.ТипТекста = ТипТекстаПочтовогоСообщения.ПростойТекст;
				КонецЕсли;
			Иначе
				Текст.ТипТекста = ТипТекста;
			КонецЕсли;
		Иначе
			Текст.ТипТекста = ТипТекстаПочтовогоСообщения.ПростойТекст;
		КонецЕсли;
	КонецЕсли;

	Важность = Неопределено;
	Если ПараметрыОтправки.Свойство("Важность", Важность) Тогда
		Письмо.Важность = Важность;
	КонецЕсли;
	
	Кодировка = Неопределено;
	Если ПараметрыОтправки.Свойство("Кодировка", Кодировка) Тогда
		Письмо.Кодировка = Кодировка;
	КонецЕсли;

	Если ПараметрыОтправки.Свойство("ОбрабатыватьТексты") И НЕ ПараметрыОтправки.ОбрабатыватьТексты Тогда
		ОбрабатыватьТекстСообщения =  ОбработкаТекстаИнтернетПочтовогоСообщения.НеОбрабатывать;
	Иначе
		ОбрабатыватьТекстСообщения =  ОбработкаТекстаИнтернетПочтовогоСообщения.Обрабатывать;
	КонецЕсли;
	
	Если ПараметрыОтправки.Свойство("УведомитьОДоставке") Тогда
		Письмо.УведомитьОДоставке = ПараметрыОтправки.УведомитьОДоставке;
		Письмо.АдресаУведомленияОДоставке.Добавить(РеквизитыОтправителя.АдресЭлектроннойПочты);
	КонецЕсли;
	
	Если ПараметрыОтправки.Свойство("УведомитьОПрочтении") Тогда
		Письмо.УведомитьОПрочтении = ПараметрыОтправки.УведомитьОПрочтении;
		Письмо.АдресаУведомленияОПрочтении.Добавить(РеквизитыОтправителя.АдресЭлектроннойПочты);
	КонецЕсли;
	
	Если ТипЗнч(Соединение) <> Тип("ИнтернетПочта") Тогда
		Профиль = ИнтернетПочтовыйПрофиль(УчетнаяЗапись);
		Соединение = Новый ИнтернетПочта;
		Соединение.Подключиться(Профиль);
	КонецЕсли;

	ОшибочныеПолучатели = Соединение.Послать(Письмо, ОбрабатыватьТекстСообщения, 
		?(ПротоколПочты = "IMAP", ПротоколИнтернетПочты.IMAP, ПротоколИнтернетПочты.SMTP));
		
	ПараметрыОтправки.Вставить("ИдентификаторСообщения", Письмо.ИдентификаторСообщения);
	ПараметрыОтправки.Вставить("ОшибочныеПолучатели", ОшибочныеПолучатели);
	
КонецПроцедуры

// Позволяет выполнить дополнительные операции после отправки почтового сообщения.
//
// Параметры:
//  ПараметрыПисьма - Структура - содержит всю необходимую информацию о письме:
//   * Кому      - Массив структур, строка - (обязательный) Интернет адрес получателя письма.
//                 Адрес         - строка - почтовый адрес.
//                 Представление - строка - имя адресата.
//
//   * ПолучателиСообщения - Массив - массив структур, описывающий получателей:
//                            * ИсточникКонтактнойИнформации - СправочникСсылка - владелец контактной информации.
//                            * Адрес - Строка - Почтовый адрес получателя сообщения.
//                            * Представление - Строка - представление адресата.
//
//   * Копии      - Массив - коллекция структур адресов:
//                   * Адрес         - строка - почтовый адрес (должно быть обязательно заполнено).
//                   * Представление - строка - имя адресата.
//                  
//                - Строка - интернет адреса получателей письма, разделитель - ";".
//
//   * СкрытыеКопии - Массив, Строка - см. описание поля Копии.
//
//   * Тема       - Строка - (обязательный) тема почтового сообщения.
//   * Тело       - Строка - (обязательный) текст почтового сообщения (простой текст в кодировке win-1251).
//   * Важность   - ВажностьИнтернетПочтовогоСообщения.
//   * Вложения   - Соответствие - список вложений, где:
//                   * ключ     - Строка - наименование вложения
//                   * значение - ДвоичныеДанные, АдресВоВременномХранилище - данные вложения;
//                              - Структура -    содержащая следующие свойства:
//                                 * ДвоичныеДанные - ДвоичныеДанные - двоичные данные вложения.
//                                 * Идентификатор  - Строка - идентификатор вложения, используется для хранения картинок,
//                                                             отображаемых в теле письма.
//
//   * АдресОтвета - Соответствие - см. описание поля Кому.
//   * Пароль      - Строка - пароль для доступа к учетной записи.
//   * ИдентификаторыОснований - Строка - идентификаторы оснований данного письма.
//   * ОбрабатыватьТексты  - Булево - необходимость обрабатывать тексты письма при отправке.
//   * УведомитьОДоставке  - Булево - необходимость запроса уведомления о доставке.
//   * УведомитьОПрочтении - Булево - необходимость запроса уведомления о прочтении.
//   * ТипТекста   - Строка, Перечисление.ТипыТекстовЭлектронныхПисем, ТипТекстаПочтовогоСообщения - определяет тип
//                  переданного теста допустимые значения:
//                  HTML/ТипыТекстовЭлектронныхПисем.HTML - текст почтового сообщения в формате HTML.
//                  ПростойТекст/ТипыТекстовЭлектронныхПисем.ПростойТекст - простой текст почтового сообщения.
//                                                                          Отображается "как есть" (значение по
//                                                                          умолчанию).
//                  РазмеченныйТекст/ТипыТекстовЭлектронныхПисем.РазмеченныйТекст - текст почтового сообщения в формате
//                                                                                  Rich Text.
//
Процедура ПослеОтправкиПисьма(ПараметрыПисьма) Экспорт
	
	
	
КонецПроцедуры

// Получает ссылку на учетную запись по виду назначения учетной записи.
//
// Возвращаемое значение:
//  УчетнаяЗапись - СправочникСсылка.УчетныеЗаписиЭлектроннойПочты - ссылка
//                  на описание учетной записи.
//
Функция СистемнаяУчетнаяЗапись() Экспорт
	
	Возврат Справочники.УчетныеЗаписиЭлектроннойПочты.СистемнаяУчетнаяЗаписьЭлектроннойПочты;
	
КонецФункции

