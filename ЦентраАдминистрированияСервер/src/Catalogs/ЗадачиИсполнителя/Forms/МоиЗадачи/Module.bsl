
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
		Список, "Выполнена", Ложь);
		
		// Установка отбора динамического списка.
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
		Список, "ПометкаУдаления", Ложь, ВидСравненияКомпоновкиДанных.Равно, , ,
		РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Обычный);
		
	Список.Параметры.УстановитьЗначениеПараметра("Исполнитель", ПараметрыСеанса.ТекущийПользователь);
	ПланированиеЗадачСервер.УстановитьПараметрыСпискаМоихЗадач(Список);
		
КонецПроцедуры

&НаСервере
Процедура ПриЗагрузкеДанныхИзНастроекНаСервере(Настройки)
	СгруппироватьПоКолонкеНаСервере(Настройки["РежимГруппировки"]);
КонецПроцедуры

#КонецОбласти

#Область Команды

&НаКлиенте
Процедура СинхронизироватьЗадачи(Команда)
	
	СерверДляЗапроса = "pivdom.intraservice.ru";
	ТекстДляЗапроса = "/api/task?serviceid={11}&fields=Created,Creator,CreatorId,Deadline,Name,Description,Id,ExecutorIds,Executors,StatusId&ExecutorIds=1849,1705&include=user&sort=Created desc";
	
	ssl = Новый ЗащищенноеСоединениеOpenSSL(Новый СертификатКлиентаWindows(	СпособВыбораСертификатаWindows.Выбирать),Новый СертификатыУдостоверяющихЦентровWindows());   
	
	// Создаем HTTPСоединение, параметры оставляем по умолчанию
	Соединение = Новый HTTPСоединение(СерверДляЗапроса,,"Журавский","2252",,,ssl);     
	
	// Запросим имя файла, который будет сохранен. По умолчанию расширение png
	
	ТекстовыйДокумент = Новый ТекстовыйДокумент;
	Каталог = КаталогВременныхФайлов();
	ПолноеИмяФайла = Каталог + "HTTPОтвет.xml";
	
	// Выполнить GET запрос:
	Попытка
		Соединение.Получить(ТекстДляЗапроса, ПолноеИмяФайла);      
		ПрочитанныеДанные = ПрочитатьHTTPОтвет(ПолноеИмяФайла);
	Исключение
		Сообщить(ОписаниеОшибки());
	КонецПопытки;
	
	СинхронизироватьЗадачиНаСервере(ПрочитанныеДанные);
	
	Элементы.Список.Обновить();
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура СинхронизироватьЗадачиНаСервере(ПрочитанныеДанные)
	
	ТаблицаЗадач = МассивВТаблицуЗначений(ПрочитанныеДанные.Tasks);
	ТаблицаЗадач.Колонки.Добавить("ЗадачаВБазе", Новый ОписаниеТипов("СправочникСсылка.ЗадачиИсполнителя"));
	Для каждого Задача из ТаблицаЗадач цикл
		Задача.Created = ?(Задача.Created = Неопределено, Неопределено, ПрочитатьДатуJSON(Задача.Created, ФорматДатыJSON.ISO));
		Задача.Deadline = ?(Задача.Deadline = Неопределено, Неопределено, ПрочитатьДатуJSON(Задача.Deadline, ФорматДатыJSON.ISO));
	КонецЦикла;
	
	МассивИДЗадач = ТаблицаЗадач.ВыгрузитьКолонку("id");
	ТаблицаНайденныхЗадач = ПоискСоответствийЗадачВПриемнике(МассивИДЗадач);
	стОтборОдинаковых = Новый Структура("id");
	ОбъединитьТаблицыЗначений(ТаблицаЗадач,ТаблицаНайденныхЗадач, стОтборОдинаковых);
	
//	ТаблицаЗагруженныхЗадач();
	
	Для каждого Пользователь из ПрочитанныеДанные.Users цикл
		
	КонецЦикла;
	
	ВыполнитьЗагрузкуЗадач(ТаблицаЗадач);
	
КонецПроцедуры

&НаКлиенте
Процедура ВыполненаВыполнить(Команда)
	
	МассивЗадач = Новый Массив;
	Для каждого ТекущиеДанные из Элементы.Список.ВыделенныеСтроки цикл
		МассивЗадач.Добавить(ТекущиеДанные);
	КонецЦикла;
	
	ИзменитьСтатусЗадачНаСервере(МассивЗадач, ПредопределенноеЗначение("Перечисление.СтатусыЗадач.Закрыта"));	
	
	Элементы.Список.Обновить();
	
КонецПроцедуры

&НаКлиенте
Процедура КИсполнению(Команда)
	
	МассивЗадач = Новый Массив;
	Для каждого ТекущиеДанные из Элементы.Список.ВыделенныеСтроки цикл
		МассивЗадач.Добавить(ТекущиеДанные);
	КонецЦикла;
	
	ИзменитьСтатусЗадачНаСервере(МассивЗадач, ПредопределенноеЗначение("Перечисление.СтатусыЗадач.ВПроцессе"));	
	
	Элементы.Список.Обновить();
	
КонецПроцедуры

&НаСервере
Процедура ИзменитьСтатусЗадачНаСервере(МассивЗадач, СтатусЗадач)

	Для каждого СтрокаЗадача из МассивЗадач цикл
		ЗадачаОбъект = СтрокаЗадача.Ссылка.ПолучитьОбъект();
		ЗадачаОбъект.СтатусЗадачи = СтатусЗадач;
		СтатусЗадачиПриИзменении(ЗадачаОбъект);
		ЗадачаОбъект.Записать();
	КонецЦикла;
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура СтатусЗадачиПриИзменении(ЗадачаОбъект)
	
	Если ЗадачаОбъект.СтатусЗадачи = Перечисления.СтатусыЗадач.ВПроцессе Тогда 
		Если НЕ ЗначениеЗаполнено(ЗадачаОбъект.ДатаПринятияКИсполнению) Тогда
			ЗадачаОбъект.ДатаПринятияКИсполнению = ТекущаяДата();
		КонецЕсли;
		ЗадачаОбъект.Выполнена = Ложь;
	КонецЕсли;
	
	Если ЗадачаОбъект.СтатусЗадачи = Перечисления.СтатусыЗадач.Закрыта Тогда
		
		Если НЕ ЗначениеЗаполнено(ЗадачаОбъект.ДатаИсполнения) Тогда
			ЗадачаОбъект.ДатаИсполнения = ТекущаяДата();
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(ЗадачаОбъект.ДатаПринятияКИсполнению) Тогда
			ЗадачаОбъект.ДатаПринятияКИсполнению = ТекущаяДата();
		КонецЕсли;
		ЗадачаОбъект.Выполнена = Истина;
		
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура СгруппироватьПоСроку(Команда)
	СгруппироватьПоКолонке("СрокДляГруппировки");
КонецПроцедуры

&НаКлиенте
Процедура СгруппироватьПоБезГруппировки(Команда)
	СгруппироватьПоКолонке("");
КонецПроцедуры

&НаКлиенте
Процедура СгруппироватьПоПриоритету(Команда)
	СгруппироватьПоКолонке("ПриоритетЗадачи");
КонецПроцедуры

&НаКлиенте
Процедура СгруппироватьПоИнициатору(Команда)
	СгруппироватьПоКолонке("Инициатор");
КонецПроцедуры



#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервереБезКонтекста
Функция МассивВТаблицуЗначений(Массив)
	
	//Предпологается что массив это ранее преобразованная таблица значений
	//т.е. каждая строчка массив это структура, ключи структуры в каждой строке массива совпадают
	ТаблицаЗначений = Новый ТаблицаЗначений;
	
	Если Массив.Количество() > 0 Тогда
		//Создаем колонки из ключей структуры в массиве
		СтруктураМассива = Массив[0];
		Для каждого ЭлементСтруктуры из СтруктураМассива цикл
			ТаблицаЗначений.Колонки.Добавить(ЭлементСтруктуры.Ключ);
		КонецЦикла;
		
		//Заполняем таблицу
		Для каждого СтрокаМассива из Массив цикл
			СтрокаТаблицы = ТаблицаЗначений.Добавить();
			ЗаполнитьЗначенияСвойств(СтрокаТаблицы, СтрокаМассива);
		КонецЦикла;
		
	КонецЕсли;
	
	Возврат ТаблицаЗначений;
	
КонецФункции

&НаКлиенте
Функция ПрочитатьHTTPОтвет(ПолноеИмяФайла);
	
	ЧтениеДанных = Новый ЧтениеJSON;
	ЧтениеДанных.ОткрытьФайл(ПолноеИмяФайла);
	ПрочитанныеДанные = ПрочитатьJSON(ЧтениеДанных, Ложь);
	
	ЧтениеДанных.Закрыть();
	
	Возврат ПрочитанныеДанные;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПоискСоответствийЗадачВПриемнике(МассивИДЗадач)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ЗадачаИсполнителя.Ссылка КАК ЗадачаВБазе,
		|	ЗадачаИсполнителя.НомерВнешнейЗадачи КАК id
		|ИЗ
		|	Справочник.ЗадачиИсполнителя КАК ЗадачаИсполнителя
		|ГДЕ
		|	ЗадачаИсполнителя.НомерВнешнейЗадачи В(&МассивИДЗадач)";
	
	Запрос.УстановитьПараметр("МассивИДЗадач", МассивИДЗадач);
	
	ТаблицаНайденныхЗадач = Запрос.Выполнить().Выгрузить();
	
	Возврат ТаблицаНайденныхЗадач;	
	
КонецФункции

// Объединить 2 таблицы значения
// тзОсновная - таблица к которой будут изменяться данные
// тзПрисоединяемая - таблица из которой будут браться данные
// стОтборОдинаковых - стурктура со списком полей по которым определяеться одинаковость записи
// ДобавлятьНеНайденное  - ИСТИНА => не сущесвующие записи в тзОсновная будут браться из тзПрисоединяемая
&НаСервереБезКонтекста
Процедура ОбъединитьТаблицыЗначений(тзОсновная,тзПрисоединяемая, стОтборОдинаковых, ДобавлятьНеНайденное = Ложь) 
	
	Для каждого текПрисоединяемаяЗапись из тзПрисоединяемая цикл
		ЗаполнитьЗначенияСвойств(стОтборОдинаковых,текПрисоединяемаяЗапись);
		НайденыеСтроки = тзОсновная.НайтиСтроки(стОтборОдинаковых);
		Если НайденыеСтроки.Количество() > 0 тогда
			Для каждого текНайденная из НайденыеСтроки цикл
				ЗаполнитьЗначенияСвойств(текНайденная,текПрисоединяемаяЗапись);
			КонецЦикла;
		ИначеЕсли ДобавлятьНеНайденное тогда
			НовСтрокаОсновном = тзОсновная.Добавить();
			ЗаполнитьЗначенияСвойств(НовСтрокаОсновном,текПрисоединяемаяЗапись);
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ВыполнитьЗагрузкуЗадач(ТаблицаЗадач)
	
	Для каждого СтрокаЗадача из ТаблицаЗадач цикл
		Если ЗначениеЗаполнено(СтрокаЗадача.ЗадачаВБазе) Тогда
			ЗадачаОбъект = СтрокаЗадача.ЗадачаВБазе.ПолучитьОбъект();
		Иначе
			ЗадачаОбъект = Справочники.ЗадачиИсполнителя.СоздатьЭлемент();
		КонецЕсли;
		
		//Найдем или создадим родителя
		ЗадачаРодитель = Справочники.ЗадачиИсполнителя.НайтиПоНаименованию("Задачи из Intraservice");
		Если ЗадачаРодитель = Справочники.ЗадачиИсполнителя.ПустаяСсылка() Тогда
			НоваяЗадачаРодитель = Справочники.ЗадачиИсполнителя.СоздатьЭлемент();
			НоваяЗадачаРодитель.Наименование  = "Задачи из Intraservice";
			НоваяЗадачаРодитель.ДатаСоздания  = ТекущаяДата();
			НоваяЗадачаРодитель.Записать();
			ЗадачаРодитель = НоваяЗадачаРодитель.Ссылка;
		КонецЕсли;
		
		ЗадачаОбъект.ДатаСоздания = СтрокаЗадача.Created;
		ЗадачаОбъект.Родитель = ЗадачаРодитель;
		ЗадачаОбъект.НомерВнешнейЗадачи = СтрокаЗадача.id;
		ЗадачаОбъект.СрокИсполнения = СтрокаЗадача.deadline;
		//ЗадачаОбъект.Инициатор = СтрокаЗадача.deadline;
		ЗадачаОбъект.Наименование = СтрокаЗадача.Name;
		ЗадачаОбъект.ХранилищеОписаниеЗадачи = Новый ХранилищеЗначения(СтрокаЗадача.Description);
		Если СтрокаЗадача.StatusId = 29 ИЛИ  СтрокаЗадача.StatusId = 28 Тогда 
			ЗадачаОбъект.СтатусЗадачи = Перечисления.СтатусыЗадач.Закрыта;
			ЗадачаОбъект.Выполнена=Истина;
		Иначе
			ЗадачаОбъект.СтатусЗадачи = Перечисления.СтатусыЗадач.Открыта;
			ЗадачаОбъект.Выполнена=ложь;
		КонецЕсли; 
		
		ЗадачаОбъект.ПриоритетЗадачи = Перечисления.ПриоритетыЗадач.Средний;
		
		ЗадачаОбъект.Записать();
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ПоказыватьВыполненныеЗадачиПриИзменении(Элемент)
	
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
		Список, "Выполнена", ПоказыватьВыполненныеЗадачи,,,НЕ ПоказыватьВыполненныеЗадачи);
		
	УстановитьОформлениеИВидимостьРеквизитов();
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьОформлениеИВидимостьРеквизитов()
	
	Элементы.Список.НачальноеОтображениеДерева=НачальноеОтображениеДерева.РаскрыватьВсеУровни;
	
КонецПроцедуры

&НаКлиенте
Процедура СгруппироватьПоКолонке(Знач ИмяКолонкиРеквизита)
	
	РежимГруппировки = ИмяКолонкиРеквизита;
	Список.Группировка.Элементы.Очистить();
	Если НЕ ПустаяСтрока(ИмяКолонкиРеквизита) Тогда
		//При группировке с видом отображения "Дерево", возможны платформенные ошибки, поэтому переводим в список
		Элементы.Список.Отображение=ОтображениеТаблицы.Список;	
		ПолеГруппировки = Список.Группировка.Элементы.Добавить(Тип("ПолеГруппировкиКомпоновкиДанных"));
		ПолеГруппировки.Поле = Новый ПолеКомпоновкиДанных(ИмяКолонкиРеквизита);
	Иначе
		Элементы.Список.Отображение=ОтображениеТаблицы.Дерево;
	КонецЕсли;
	
	УстановитьОформлениеИВидимостьРеквизитов();

КонецПроцедуры

&НаСервере
Процедура СгруппироватьПоКолонкеНаСервере(Знач ИмяКолонкиРеквизита)
	
	РежимГруппировки = ИмяКолонкиРеквизита;
	Список.Группировка.Элементы.Очистить();
	Если НЕ ПустаяСтрока(ИмяКолонкиРеквизита) Тогда
		Элементы.Список.Отображение=ОтображениеТаблицы.Список;			
		ПолеГруппировки = Список.Группировка.Элементы.Добавить(Тип("ПолеГруппировкиКомпоновкиДанных"));
		ПолеГруппировки.Поле = Новый ПолеКомпоновкиДанных(ИмяКолонкиРеквизита);
	Иначе
		Элементы.Список.Отображение=ОтображениеТаблицы.Дерево;
	КонецЕсли;
	
КонецПроцедуры


#КонецОбласти

