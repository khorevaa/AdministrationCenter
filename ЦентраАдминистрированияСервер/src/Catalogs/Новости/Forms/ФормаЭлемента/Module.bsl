
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если НЕ ЗначениеЗаполнено(Объект.УИННовости) Тогда
		Объект.УИННовости = Объект.Ссылка.УникальныйИдентификатор();
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ЗаписатьНовость()
	
	Записать();
	Объект.УИННовости = Объект.Ссылка.УникальныйИдентификатор();
	
КонецПроцедуры

&НаСервере
Процедура ОпубликоватьНовостьНаСервере()
	
	МассивБаз = Объект.СписокИнформационныхБаз.Выгрузить(,"ИнформационнаяБаза");
	
	Для каждого СтрокаБаза из МассивБаз цикл
		
		СтруктураПодключения = РаботаСПодключениямиCOM.ПолучитьСоединениеСИнформационнойБазой(СтрокаБаза);
		
		Попытка
			СоздатьНовостьНаСервере(СтруктураПодключения);
			Сообщить("Новость создана в базе "+ СтруктураПодключения.ИмяБазыВКластере);
		Исключение
			ТекстСообщения             = НСтр("ru = 'Не удалось создать новость %1. %2'");
			ТекстСообщения             = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстСообщения,СтруктураПодключения.ИмяБазыВКластере,ОписаниеОшибки());
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = ТекстСообщения;
			Сообщение.Сообщить();
			продолжить;
		КонецПопытки;
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура СоздатьНовостьНаСервере(СтруктураПодключения)
	
	//ПОИСК ЛЕНТЫ НОВОСТЕЙ "ПИВДОМ (Лента новостей)", если нет, то создаем новую
	Запрос = СтруктураПодключения.Connect.NewObject("Запрос");
	Запрос.Текст = 
				"ВЫБРАТЬ
				|	ЛентыНовостей.Ссылка КАК Ссылка
				|ИЗ
				|	Справочник.ЛентыНовостей КАК ЛентыНовостей
				|ГДЕ
				|	ЛентыНовостей.Наименование ПОДОБНО ""%ПИВДОМ (Лента новостей)%""";
	РезультатЗапроса = Запрос.Выполнить().Выбрать();
	Если РезультатЗапроса.Следующий() Тогда
		ЛентаНовостей = РезультатЗапроса.Ссылка;
	Иначе
		НоваяЛентаНовостей =  СтруктураПодключения.Connect.Справочники.ЛентыНовостей.СоздатьЭлемент();
		НоваяЛентаНовостей.Наименование = "ПИВДОМ (Лента новостей)";
		НоваяЛентаНовостей.ОбязательныйКанал = Истина;
		НоваяЛентаНовостей.Протокол = "file";
		НоваяЛентаНовостей.ВариантЛогинаПароля = СтруктураПодключения.Connect.Перечисления.ВариантЛогинаПароляДляЛентыНовостей.БезЛогинаПароля;
		НоваяЛентаНовостей.ЗагруженоССервера = Ложь;
		НоваяЛентаНовостей.ВидимостьПоУмолчанию = Истина;
		НоваяЛентаНовостей.ПропускатьЗагрузкуБинарныхДанных = Ложь;
		НоваяЛентаНовостей.ЛокальнаяЛентаНовостей = Истина;
		НоваяЛентаНовостей.Записать();
		ЛентаНовостей =  НоваяЛентаНовостей.Ссылка;
	КонецЕсли;
	
	//ПОИСК НОВОСТИ 
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Новости.Ссылка
		|ИЗ
		|	Справочник.Новости КАК Новости
		|ГДЕ
		|	Новости.УИННовости = &УИННовости";
	
	Запрос.УстановитьПараметр("УИННовости", Объект.УИННовости);
	
	РезультатЗапроса = Запрос.Выполнить().Выбрать();
	
	Если РезультатЗапроса.Следующий() Тогда
		ОпубликованнаяНовость = РезультатЗапроса.Ссылка;
	Иначе
		//Создаем новость
		ОпубликованнаяНовость= СтруктураПодключения.Connect.Справочники.Новости.СоздатьЭлемент();
		ЗаполнитьЗначенияСвойств(ОпубликованнаяНовость, Объект);
		ОпубликованнаяНовость.ЛентаНовостей = ЛентаНовостей;
		ОпубликованнаяНовость.СкрыватьВОбщемСпискеНовостей = ЛОЖЬ;
		ОпубликованнаяНовость.ПриОткрытииСразуПереходитьПоСсылке = ЛОЖЬ;
//		УИННовости = Новый УникальныйИдентификатор	;
		ОпубликованнаяНовость.УИННовости =  Объект.УИННовости;
		ОпубликованнаяНовость.Записать();
	КонецЕсли;
	
	//Добавляем запись в регистр чтобы начала появляться наша новость
	Запись = СтруктураПодключения.Connect.РегистрыСведений.ПериодическиеСвойстваНовостей.СоздатьМенеджерЗаписи();
	Запись.Новость = ОпубликованнаяНовость.Ссылка;
	Запись.ВажностьОбщая = 1;
	Запись.Актуальность  = Истина;
	Запись.Записать(Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура ОпубликоватьНовость(Команда)
	ЗаписатьНовость();
	ОпубликоватьНовостьНаСервере();
КонецПроцедуры

&НаСервере
Процедура УдалитьПубликациюНаСервере()
	
	Для каждого СтрокаБаза из Объект.СписокИнформационныхБаз Цикл
		
		СтруктураПодключения = РаботаСПодключениямиCOM.ПолучитьСоединениеСИнформационнойБазой(СтрокаБаза);
		
		Попытка
			УдалитьНовостьНаСервере(СтруктураПодключения);
			Сообщить("Новость удалена в базе "+ СтруктураПодключения.ИмяБазыВКластере);
		Исключение
			ТекстСообщения             = НСтр("ru = 'Не удалось удалить новость %1. %2'");
			ТекстСообщения             = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстСообщения,СтруктураПодключения.ИмяБазыВКластере,ОписаниеОшибки());
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = ТекстСообщения;
			Сообщение.Сообщить();
			продолжить;
		КонецПопытки;
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура УдалитьНовостьНаСервере(СтруктураПодключения)
	
	//ПОИСК НОВОСТИ 
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Новости.Ссылка
		|ИЗ
		|	Справочник.Новости КАК Новости
		|ГДЕ
		|	Новости.УИННовости = &УИННовости";
	
	Запрос.УстановитьПараметр("УИННовости", Объект.УИННовости);
	
	РезультатЗапроса = Запрос.Выполнить().Выбрать();
	
	Если РезультатЗапроса.Следующий() Тогда
		ОпубликованнаяНовость = РезультатЗапроса.Ссылка.ПолучитьОбъект();
		ОпубликованнаяНовость.Удалить();
	КонецЕсли;
		
КонецПроцедуры

&НаКлиенте
Процедура УдалитьПубликацию(Команда)
	УдалитьПубликациюНаСервере();
КонецПроцедуры

