﻿local L = LibStub("AceLocale-3.0"):NewLocale("MacroBank", "ruRU", false);
if not L then return end
L["AcceptIcon"] = "Принять"
L["AcceptIconDesc"] = "Принять эту иконку."
L["Accept new Macro from %s?"] = "Принять новый макрос от %s?" -- Needs review
-- L["Auto accepted %d macros."] = "Auto accepted %d macros."
-- L["Auto Accept Macros"] = "Auto Accept Macros"
-- L["Auto Accept Macros Desc"] = "Automatically accept macros sent from other MacroBank users."
L["AutoLoad"] = "Автозагрузка"
L["AutoLoadDesc"] = "Настройки для автоматической загрузки групп макросов"
L["AutoOpenMacroBank"] = "Автооткрытие MacroBank"
L["AutoOpenMacroBankDesc"] = "Открыть окно MacroBank, при открытии основного окна макросов"
L["CancelDesc"] = "Закрыть это меню"
L["Can't find category"] = "Невозможно найти категорию"
L["Can't load macros in combat"] = "Невозможно загрузить макрос в бою" -- Needs review
L["Category"] = "Категория"
L["Category?"] = "Категория?"
L["CategoryDesc"] = [=[Назначить категорию для выбранного макроса.
(Сохраняется при нажатии клавиши Enter)]=]
L["Category Name"] = "Имя категории"
L["Change Category"] = "Изменить категорию"
L["Change Category Description"] = [=[Изменить категорию для этих макросов
(Макросы в подкатегории останутся)]=]
L["Char"] = "Персонаж"
L["CharCategory"] = "Категория персонажа"
L["CharCategoryDesc"] = "Выберите категорию макросов для загрузки в макросы персонажа"
L["CharDesc"] = "Загрузить макрос в раздел персонажа" -- Needs review
-- L["Couldn't create category"] = "Couldn't create category"
L["Create"] = "Создать"
-- L["Create Category"] = "Create Category"
L["CreateDesc"] = "Создать новый макрос в банке макросов" -- Needs review
-- L["Creates a new category."] = "Creates a new category."
L["Default"] = "По умолчанию"
L["DefaultCategoryDesc"] = "Установить категорию созданных/сохраненных макросов"
L["DefaultDescriptionDesc"] = "Задать описание созданного/сохраненного макроса"
L["DefaultNameDesc"] = "Задать имя созданного/сохраненного макроса"
L["Delete"] = "Удалить"
L["Delete Char Macros"] = "Удалить макрос персонажа"
L["DeleteDesc"] = "Удалить выбранный макрос из банка макросов."
L["Delete Global Macros"] = "Удалить глобальный макрос"
-- L["Delete Macros"] = "Delete Macros"
L["Delete Macro %s?"] = "Удалить макрос %s?"
-- L["Delete macros in %s?"] = "Delete macros in %s?"
L["Delete Macros On AutoLoad Desc"] = "Если макрос выбран для автозагрузки, этот макрос будет удален перед загрузкой."
-- L["Deletes all subcategories and their macros of this category."] = "Deletes all subcategories and their macros of this category."
-- L["Deletes macros in this category."] = "Deletes macros in this category."
-- L["Delete Subcategories"] = "Delete Subcategories"
-- L["Delete subcategories of %s?"] = "Delete subcategories of %s?"
L["Description"] = "Описание"
L["DescriptionDesc"] = [=[Введите описание этого макроса.
(Сохраняется после нажатия enter)]=]
L["FromMacroBank"] = " <-----"
L["Global"] = "Глобально"
L["GlobalCategory"] = "Глобальная категория"
L["GlobalCategoryDesc"] = "Выберите категорию макросов для зарузки в глобальные макросы"
L["GlobalDesc"] = "Загрузить макрос в общий раздел"
L["Guild"] = "Гильдия"
L["Icon"] = "Иконка"
L["IconDesc"] = "Назначить иконку для выбранного макроса"
L["Load"] = "Загрузить"
L["LoadCategory"] = "Загрузить категорию"
L["Load Category"] = "Загрузить категорию"
L["LoadCategoryDesc"] = "Загружает категорию или отдельный макрос из категории"
L["LoadDesc"] = [=[Загрузить макрос из макро-банка
Shift-клик загрузить всю категорию
(если макрос с таким же именем существует, он будет заменен)]=]
L["LoadPreMade"] = "Загрузить макрос"
L["LoadPreMadeDesc"] = "Загрузить шаблон макросов из PreMadeMacros.lua"
L["Loads the selected category."] = "Загрузить выбранную категорию"
L["Login Group"] = "Группа загрузки"
L["Login Group Desc"] = "Какие макросы будут загружены при загрузке"
L["Macro"] = "Макрос"
L["MacroBank"] = " MacroBank"
L["MacroBank User"] = "Пользователь MacroBank"
L["MacroDefaults"] = "Макросы по-умолчанию"
L["MacroDefaultsDesc"] = "Настройки по-умолчанию для созданного/сохраненного макроса"
L["MacroDesc"] = [=[Установить "тело" для выбранного макроса
(Сохраняется при нажатии Esc или закрытии окна редактора)]=]
L["MacroOptions"] = "Настройки макросов"
L["MacroOptionsDesc"] = "Настройки поведения MacroBank"
L["MacroScrollLine"] = "Список макросов"
L["MacroScrollLineDesc"] = "Выбрать макрос для изменения, загрузки или удаления"
-- L["Must not be empty"] = "Must not be empty"
L["Name"] = "Имя"
L["NameDesc"] = [=[Задать имя выбранного макроса
Используется для загрузки нового.
(Сохраняется при нажатии Enter)]=]
L["None"] = "Ничего"
L["Non-MacroBank User"] = "Не использует MacroBank"
L["Not enough room to load macro"] = "Недостаточно места для загрузки макроса"
L["On Login"] = "При загрузке"
L["On Talent Swap"] = "При смене талантов"
L["Options"] = "Опции"
L["OptionsDesc"] = "Отобразить окно опций"
-- L["Overwrite Received"] = "Overwrite Received"
-- L["Overwrite Received Desc"] = "Replace macros with the same name, description and icon when receiving macros from someone."
L["Party"] = "Группа"
L["Player"] = "Игрок"
L["Pre-Made Macros"] = "Шаблоны макросов"
L["Primary Talent Spec Group"] = "Группа первого набора талантов" -- Needs review
L["Primary Talent Spec Group Desc"] = "Какой макрос будет загружен, при переключении на основной спек"
L["Raid"] = "Рейд"
L["ReceivedCategory"] = "Категория Принятых"
L["ReceivedCategoryDesc"] = "Установить категорию для макросов, которые были приняты (используйте %s как возможную для отправителя)"
L["RememberPosition"] = "Запомнить позицию"
L["RememberPositionDesc"] = "Запоминать позицию MacroBank при перемещении"
L["Replace"] = "Заменить" -- Needs review
L["ReplaceDesc"] = "Заменить макрос другим из макро-банка"
L["ReplaceIconDesc"] = "Заменить иконку другой из MacroBank"
L["ReplaceNameDesc"] = "Заменить имя другим из MacroBank"
L["ReplaceOptions"] = "Опции замены"
L["ReplaceOptionsDesc"] = "Изменить поведение кнопки замены"
L["ResetAnchor"] = "Сбросить якорь"
L["ResetAnchorDesc"] = "Помещает окно MacroBank на его первоначальную позицию"
L["%s Accepted your macro"] = "%s принял ваш макрос"
L["Save"] = "Сохранить"
L["SaveDesc"] = "Сохранить выбранный макрос в банке макросов."
L["Secondary Talent Spec Group"] = "Группа второго набора талантов" -- Needs review
L["Secondary Talent Spec Group Desc"] = "Какой макрос будет загружен, при переключении на вторичный спек"
L["Send selected macro to"] = "Отправить макрос "
L["Sends the currently selected macro to another MacroBank user."] = "Отправить выбранный макрос другому пользователю MacroBank"
L["Sends the currently selected macro to another user."] = "Отослать выбранный макрос другому пользователю"
L["SendTo"] = "Отправить"
-- L["Show Icons"] = "Show Icons"
-- L["Show Icons Desc"] = "Show icons in the macro bank list."
-- L["SlashCmd1"] = "macrobank"
-- L["SlashCmd2"] = "mb"
L["%s Rejected your macro"] = "%s отклонил ваш макрос"
L["TempCategory"] = "Временная категория" -- Needs review
L["TempDescription"] = "Временное описание" -- Needs review
L["TempName"] = "Временное имя"
L["TempReceivedCategory"] = "от %s"
-- L["ToMacroBank"] = "----->"
-- L["Unable to load macro - no macro name"] = "Unable to load macro - no macro name"
L["UseNameForDescription"] = "Использовать имя для описания"
L["UseNameForDescriptionDesc"] = "Использовать имя макроса для описания, вместо стандартного описания сохраняемого макроса"
