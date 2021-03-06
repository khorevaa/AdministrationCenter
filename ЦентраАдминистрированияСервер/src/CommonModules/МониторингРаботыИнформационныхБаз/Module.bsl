
Процедура ВыполнитьМониторингОшибокСинхронизации() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	СостояниеИнформационныхБаз.ИнформационнаяБаза КАК База
		|ИЗ
		|	РегистрСведений.СостояниеИнформационныхБаз КАК СостояниеИнформационныхБаз
		|ГДЕ
		|	СостояниеИнформационныхБаз.МониторингОшибокСинхронизации = ИСТИНА";
	
	ВыборкаИнформационныхБаз = Запрос.Выполнить().Выбрать();
	
	
	Пока ВыборкаИнформационныхБаз.Следующий() Цикл
		
		МассивОшибок = Новый Массив;
		СтруктураОшибки = Новый Структура("ИнформационнаяБаза, УзелИнформационнойБазы, ДействиеПриОбмене, РезультатВыполненияОбмена");
		
		СтруктураПодключения = РаботаСПодключениямиCOM.ПолучитьСоединениеСИнформационнойБазой(ВыборкаИнформационныхБаз.База);
		
		Если СтруктураПодключения.Connect = Неопределено Тогда
			СтруктураОшибки.ИнформационнаяБаза					= ВыборкаИнформационныхБаз.База;
			СтруктураОшибки.УзелИнформационнойБазы 		= "";
			СтруктураОшибки.ДействиеПриОбмене 					= "Подключение";
			СтруктураОшибки.РезультатВыполненияОбмена = "Не удалось установить COM подключение к информационной базе. По причине: "+ символы.ПС +
																														СтруктураПодключения.РезультатПодключения;
			МассивОшибок.Добавить(СтруктураОшибки);	
		Иначе
			Connect = СтруктураПодключения.Connect;
			Запрос = Connect.NewObject("Запрос");;
			Запрос.Текст = 
					"ВЫБРАТЬ
					|	ПРЕДСТАВЛЕНИЕ(СостоянияОбменовДанными.УзелИнформационнойБазы) КАК УзелИнформационнойБазы,
					|	ПРЕДСТАВЛЕНИЕ(СостоянияОбменовДанными.ДействиеПриОбмене) КАК ДействиеПриОбмене,
					|	ПРЕДСТАВЛЕНИЕ(СостоянияОбменовДанными.РезультатВыполненияОбмена) КАК РезультатВыполненияОбмена,
					|	СостоянияОбменовДанными.ДатаНачала,
					|	СостоянияОбменовДанными.ДатаОкончания
					|ИЗ
					|	РегистрСведений.СостоянияОбменовДанными КАК СостоянияОбменовДанными
					|ГДЕ
					|	НЕ СостоянияОбменовДанными.УзелИнформационнойБазы = НЕОПРЕДЕЛЕНО
					|	И (СостоянияОбменовДанными.РезультатВыполненияОбмена = ЗНАЧЕНИЕ(Перечисление.РезультатыВыполненияОбмена.Ошибка)
					|			ИЛИ СостоянияОбменовДанными.РезультатВыполненияОбмена = ЗНАЧЕНИЕ(Перечисление.РезультатыВыполненияОбмена.Ошибка_ТранспортСообщения))";
			
			ВыборкаСостоянийОбмена = Запрос.Выполнить().Выбрать();
			
			Пока ВыборкаСостоянийОбмена.Следующий() Цикл
				СтруктураОшибки.ИнформационнаяБаза					= СтруктураПодключения.ИмяБазыВКластере;
				СтруктураОшибки.УзелИнформационнойБазы 		= ВыборкаСостоянийОбмена.УзелИнформационнойБазы;
				СтруктураОшибки.ДействиеПриОбмене 					= ВыборкаСостоянийОбмена.ДействиеПриОбмене;
				СтруктураОшибки.РезультатВыполненияОбмена = ВыборкаСостоянийОбмена.РезультатВыполненияОбмена;
				МассивОшибок.Добавить(СтруктураОшибки);	
			КонецЦикла;
			
			СтруктураПодключения.Connect = Неопределено; //Закрывает COM соединение
			
		Конецесли;
		
		Если МассивОшибок.Количество() > 0 Тогда
			ОтправитьУведомлениеОбОшибкеСинхронизации(МассивОшибок);	
		КонецЕсли;
	КонецЦикла;
	
	
КонецПроцедуры

Процедура ОтправитьУведомлениеОбОшибкеСинхронизации(МассивОшибок)
	
	ТекстТелаПисьма = "";
	Для каждого СтрокаОшибка из МассивОшибок цикл
		ТекстТемыПисьма = "Ошибка синхронизации " + СтрокаОшибка.ИнформационнаяБаза;
		ТекстТелаПисьма = ТекстТелаПисьма +"Произошли ошибки при синхронизации" + Символы.ПС + 
			"Действие: "+  СтрокаОшибка.ДействиеПриОбмене + Символы.ПС +
			"Узел: " + СтрокаОшибка.УзелИнформационнойБазы + Символы.ПС +
			"Результат:  " +СтрокаОшибка.РезультатВыполненияОбмена  + Символы.ПС; 
	КонецЦикла;
	
	ПараметрыПисьма = Новый Структура;
	ПараметрыПисьма.Вставить("Кому", ПолучитьСписокПолучателей());
	ПараметрыПисьма.Вставить("Тело", ТекстТелаПисьма);
	ПараметрыПисьма.Вставить("Тема", ТекстТемыПисьма);
	
	ТекстСообщения = "";
	УровеньВажностиСобытия = УровеньЖурналаРегистрации.Информация; 
	
	Попытка
		РаботаСПочтовымиСообщениями.ОтправитьПочтовоеСообщение(РаботаСПочтовымиСообщениями.СистемнаяУчетнаяЗапись(), ПараметрыПисьма);
	Исключение
		ОписаниеОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Ошибка при отправке ошибок синхронизации: %1.'"),
		ОписаниеОшибки);
		УровеньВажностиСобытия = УровеньЖурналаРегистрации.Ошибка;
	КонецПопытки;
	
	ЗаписьЖурналаРегистрации(НСтр("ru = 'Мониторинг работы информационных баз'",
		ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()), 
		УровеньВажностиСобытия,,, ТекстСообщения);
		
	
КонецПроцедуры

Функция ПолучитьСписокПолучателей();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ГруппыПользователейСостав.Пользователь,
		|	ПользователиКонтактнаяИнформация.Значение КАК АдресЭП
		|ИЗ
		|	Справочник.ГруппыПользователей.Состав КАК ГруппыПользователейСостав
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Пользователи.КонтактнаяИнформация КАК ПользователиКонтактнаяИнформация
		|		ПО ГруппыПользователейСостав.Пользователь = ПользователиКонтактнаяИнформация.Ссылка
		|ГДЕ
		|	ГруппыПользователейСостав.Ссылка = ЗНАЧЕНИЕ(Справочник.ГруппыПользователей.МониторингОшибокСинхронизации)
		|	И ПользователиКонтактнаяИнформация.Тип = ЗНАЧЕНИЕ(Перечисление.ТипыКонтактнойИнформации.АдресЭлектроннойПочты)";
	
	ВыборкаПолучаталей = Запрос.Выполнить().Выбрать();
	
	СтрокаКому = "";
	Пока ВыборкаПолучаталей.Следующий() Цикл
		Если СтрокаКому = "" Тогда
			СтрокаКому = ВыборкаПолучаталей.АдресЭП;
		Иначе
			СтрокаКому = СтрокаКому + ";" +ВыборкаПолучаталей.АдресЭП 
		КонецЕсли;
	КонецЦикла;
	
	Возврат СтрокаКому;
	
КонецФункции

