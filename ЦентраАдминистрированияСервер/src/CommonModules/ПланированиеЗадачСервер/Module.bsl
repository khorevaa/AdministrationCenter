
Процедура УстановитьПараметрыСпискаМоихЗадач(Список) Экспорт
	
	ТекущаяДатаСеанса = ТекущаяДатаСеанса();
	Сегодня = Новый СтандартныйПериод(ВариантСтандартногоПериода.Сегодня);
	ЭтаНеделя = Новый СтандартныйПериод(ВариантСтандартногоПериода.ЭтаНеделя);
	СледующаяНеделя = Новый СтандартныйПериод(ВариантСтандартногоПериода.СледующаяНеделя);
	
	Список.Параметры.УстановитьЗначениеПараметра("ТекущаяДата", ТекущаяДатаСеанса);
	Список.Параметры.УстановитьЗначениеПараметра("КонецДня", Сегодня.ДатаОкончания);
	Список.Параметры.УстановитьЗначениеПараметра("КонецНедели", ЭтаНеделя.ДатаОкончания);
	Список.Параметры.УстановитьЗначениеПараметра("КонецСледующейНедели", СледующаяНеделя.ДатаОкончания);
	Список.Параметры.УстановитьЗначениеПараметра("Просрочено", " " + НСтр("ru = 'Просрочено'")); // пробел для сортировки
	Список.Параметры.УстановитьЗначениеПараметра("Сегодня", НСтр("ru = 'В течение сегодня'"));
	Список.Параметры.УстановитьЗначениеПараметра("ЭтаНеделя", НСтр("ru = 'До конца недели'"));
	Список.Параметры.УстановитьЗначениеПараметра("СледующаяНеделя", НСтр("ru = 'На следующей неделе'"));
	Список.Параметры.УстановитьЗначениеПараметра("Позднее", НСтр("ru = 'Позднее'"));
	Список.Параметры.УстановитьЗначениеПараметра("НачалоДня", НачалоДня(ТекущаяДатаСеанса));
	Список.Параметры.УстановитьЗначениеПараметра("НезаполненнаяДата", Дата(1,1,1));
	
КонецПроцедуры
