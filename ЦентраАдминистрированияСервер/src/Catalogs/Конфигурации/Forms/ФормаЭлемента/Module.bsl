
&НаКлиенте
Процедура ПредставлениеПриИзменении(Элемент)
	Объект.Наименование=Объект.Представление;
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	РеестрДоработок.Параметры.УстановитьЗначениеПараметра("Владелец", Объект.Ссылка);
	
КонецПроцедуры
