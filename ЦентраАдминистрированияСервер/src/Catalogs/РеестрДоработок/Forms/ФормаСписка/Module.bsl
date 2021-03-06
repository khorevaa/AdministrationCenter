
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	СписокТекущихОтборов = Список.Отбор.Элементы;
	
	НуженОтборПоКонфигурации = Истина;	
	Для каждого ЭлементОтбора из СписокТекущихОтборов цикл
		Если ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Владелец") Тогда
			НуженОтборПоКонфигурации=ложь;
			Конфигурация = ЭлементОтбора.ПравоеЗначение;
		КонецЕсли;
	КонецЦикла;
	
	Если НуженОтборПоКонфигурации Тогда
		ОтборПоКонфигурации = Список.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		ОтборПоКонфигурации.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Владелец"); 
		ОтборПоКонфигурации.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
		ОтборПоКонфигурации.Использование = Истина;
		ОтборПоКонфигурации.ПравоеЗначение = Конфигурация;	
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура КонфигурацияПриИзменении(Элемент)
	
	СписокТекущихОтборов = Список.Отбор.Элементы;
	
		Для каждого ЭлементОтбора из СписокТекущихОтборов цикл
			Если ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Владелец") Тогда
				ЭлементОтбора.ПравоеЗначение = Конфигурация;
			КонецЕсли;
		КонецЦикла;
	
КонецПроцедуры
