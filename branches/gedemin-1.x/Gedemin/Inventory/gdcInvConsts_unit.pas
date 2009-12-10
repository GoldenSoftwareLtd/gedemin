
{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gdcInvConsts_unit.pas

  Abstract

    Part of inventory subsystem.

  Author

    Romanovski Denis (17-09-2001)

  Revisions history

    Initial  17-09-2001  Dennis  Initial version.

--}

unit gdcInvConsts_unit;

interface

uses Classes;

type
  // Массив настроек признаков
  TgdcInvFeatures = array of String;

  // Вид движения
  TgdcInvMovementPart = (impIncome, impExpense, impAll);
  // impIncome - приход
  // impExpense - расход

  // Вид признака
  TgdcInvFeatureKind = (ifkDest, ifkSource);
  // ifkSource - из карточки-источника
  // ifkDest - из карточки-назначения

  // Тип используемого контакта в движении
  TgdcInvMovementContactType = (
    imctOurCompany, imctOurDepartment, imctOurPeople, imctCompany,
      imctCompanyDepartment, imctCompanyPeople, imctPeople
  );
  // imctOurCompany - Наша компания
  // imctOurDepartment - Подразделение нашей компании
  // imctOurPeople - Сотрудник нашей компании
  // imctCompany - Клиент (Юридическое лицо)
  // imctCompanyDepartment - Подразделение клиента
  // imctCompanyPeople - Сотрудник клиента
  // imctPeople - физическое лицо

  // Структура используется при определении атрибута
  // отвечающего за источник или получателя ТМЦ
  // в складском документе.
  TgdcInvMovementContactOption = class(TObject)
  public
    RelationName: String[31]; // Наименование таблицы
    SourceFieldName: String[31]; // Наименование поля-атрибута

    SubRelationName: String[31]; // Наименование таблицы
    SubSourceFieldName: String[31]; // Наименование дополнительного поля-атрибута

    ContactType: TgdcInvMovementContactType; // Тип контакта
    Predefined: array of Integer; // Набор возможных значений
    SubPredefined: array of Integer; // Набор возможных значений
  end;

  // Вид складской справочной информации
  TgdcInvReferenceSource = (irsGoodRef, irsRemainsRef, irsMacro);
  // irsGoodRef - в качестве справочника используется справочник товаров
  // irsRemainsRef - в качестве справочника используется справочник остатков ТМЦ
  // irsMacro - в качестве справочника используется справочник, получаемый из макроса

  // Набор видов складской информации
  TgdcInvReferenceSources = set of TgdcInvReferenceSource;

  // Направление использования движения
  TgdcInvMovementDirection = (imdFIFO, imdLIFO, imdDefault);
  // imdFIFO - очередь
  // imLIFO - стек
  // imdDefault - по каждому ТМЦ

  // Тип таблицы позиции складского документа
  TgdcInvRelationType = (irtSimple, irtFeatureChange, irtInventorization,
    irtTransformation, irtInvalid);
  // irtSimple -  обычная позиция документа
  // irtFeatureChange - изменение признаков документа
  // irtInventorization - инвентаризация
  // irtTransformation - трансформация

  // Список резервных складов
  TgdcInvReserveInvents = array of Integer;

  // Вид сохранения позиции (документ или одна позиция)
  TgdcInvPositionSaveMode = (ipsmDocument, ipsmPosition);

  TgdcInvErrorCode = (
    iecNoErr,
    iecGoodNotFound, // Нет товара на складе по текщей позиции
    iecRemainsNotFound, // Недостаточно остатков по текущей позиции
    iecFoundOtherMovement,  // По позиции есть движение
    iecFoundEarlyMovement,  // По позиции есть более раннее движение
    iecRemainsNotFoundOnDate, // На указанную дату отсутствуют остатки
    iecDontDecreaseQuantity, // Нельзя уменьшить количество по данной позиции
    iecDontChangeDest, // Нельзя изменить источник (т.к. по старому имеется движение)
    iecDontChangeFeatures, // Нельзя изменить свойства (т.к. по предыдущим имеется движение)
    iecDontDeleteFoundMovement, // Нельзя удалить позицию по которой было движение
    iecDontDeleteDecreaseQuantity, // Нельзя удалить позиции, из-за недостатка остатков
    iecRemainsLocked, // Остаток изменен другим пользователем
    iecOtherIBError, // Другая ИБ ошибка
    iecDontDisableMovement, // Нельзя переформировать движение
    iecIncorrectCardField, // Не корректное значение поля
    iecUnknowError  // Неизвестная ошибка
  );


const
  INV_SOURCEFEATURE_PREFIX = 'FROM_';
  INV_DESTFEATURE_PREFIX = 'TO_';

  gdcInvErrorMessage: array[TgdcInvErrorCode] of String =
    ('Без ошибки ',
     'Выбранный ТМЦ не найден на указанном складе',
     'По выбранному ТМЦ недостаточное кол-во остатков',
     'Данная позиция используется в других документах',
     'По данной позиции есть более раннее движение',
     'На указанную дату по позиции отсутствуют остатки', 
     'Нельзя уменьшить количество по данной позиции',
     'Нельзя изменить источник (т.к. по предыдущему имеется движение)',
     'Нельзя изменить свойства (т.к. по предыдущим имеется движение)',
     'Нельзя удалить позицию по которой было движение',
     'Нельзя удалить позицию, из-за недостатка остатков',
     'Остатки по данной позиции изменены другим пользователем. Необходимо подождать или отменить выбор данной позиции',
     'Ошибка Interbase: %s',
     'Нельзя переформировать движение по данной позиции',
     'Некорректное значение поля', 
     '%s');

const
  gdcInvCalcAmountMacrosName =
  'sub %0:s(Sender) '#13#10 +
  '  if scrPublicVariables.Value("%1:s") <> "1" then '#13#10 +
  '    scrPublicVariables.AddValue "%1:s", "1" '#13#10 +
  '    Sender.DataSet.FieldByName("%2:s").AsVariant = _ '#13#10 +
  '       Sender.AsVariant * Sender.DataSet.FieldByName("QUANTITY").AsVariant '#13#10 +
  '    scrPublicVariables.AddValue "%1:s", "0" '#13#10 +
  '  end if '#13#10#13#10 +
  '  dim EventParams(0) '#13#10 +
  '  set  EventParams(0) = Sender'#13#10 +
  '  call Inherited(Sender, "OnChange", EventParams)'#13#10#13#10 +
  'end sub ';

  gdcInvCalcPriceMacrosName =
  'sub %0:s(Sender) '#13#10 +
  '  if scrPublicVariables.Value("%2:s") <> "1" then '#13#10 +
  '    scrPublicVariables.AddValue "%2:s", "1" '#13#10 +
  '    if not IsNull(Sender.DataSet.FieldByName("QUANTITY").AsVariant) and _'#13#10 +
  '       Sender.DataSet.FieldByName("QUANTITY").AsVariant <> 0 then '#13#10 +
  '      Sender.DataSet.FieldByName("%2:s").AsVariant = _ '#13#10 +
  '         Sender.AsVariant / Sender.DataSet.FieldByName("QUANTITY").AsVariant '#13#10 +
  '    end if '#13#10 +
  '    scrPublicVariables.AddValue "%2:s", "0" '#13#10 +
  '  end if '#13#10#13#10 +
  '  dim EventParams(0) '#13#10 +
  '  set  EventParams(0) = Sender'#13#10 +
  '  call Inherited(Sender, "OnChange", EventParams)'#13#10#13#10#13#10 +
  'end sub ';

  gdcInvQuantityOnChangeHeader = 'sub gdcInvDocumentLine%sOnChange(Sender)';
  gdcInvQuantityOnChangeBodyLine = '  Sender.DataSet.FieldByName("%0:s").AsVariant = Sender.DataSet.FieldByName("%0:s").AsVariant ';


type
  // Запись для хранения поля прайс-листа
  TgdcInvPriceField = record
    FieldName: String[31]; // Наименование поля
    CurrencyKey: Integer; // Тип валюты
    ContactKey: Integer; // Тип контакта
  end;

  // Список полей прайс-листа
  TgdcInvPriceFields = array of TgdcInvPriceField;

implementation

end.
