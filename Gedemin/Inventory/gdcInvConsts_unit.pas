
{++


  Copyright (c) 2001-2015 by Golden Software of Belarus

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

const
  //
  // Версия документа для потока

  // Незаконченный документ (не до конца настроенный документ)
  gdcInv_Document_Undone = 'UNDONE';
  // Версия 1.6
  gdcInvDocument_Version1_6 = 'IDV1.6';
  // Версия 1.7
  gdcInvDocument_Version1_7 = 'IDV1.7';
  // Версия 1.8
  gdcInvDocument_Version1_8 = 'IDV1.8';
  // Версия 1.9
  gdcInvDocument_Version1_9 = 'IDV1.9';
  // Версия 2.0
  gdcInvDocument_Version2_0 = 'IDV2.0';
  // Версия 2.1
  gdcInvDocument_Version2_1 = 'IDV2.1';
  // Версия 2.2
  gdcInvDocument_Version2_2 = 'IDV2.2';
  // Версия 2.3
  gdcInvDocument_Version2_3 = 'IDV2.3';
  // Версия 2.4
  gdcInvDocument_Version2_4 = 'IDV2.4';
  // Версия 2.5
  gdcInvDocument_Version2_5 = 'IDV2.5';
  // Версия 2.6
  gdcInvDocument_Version2_6 = 'IDV2.6';
  // Версия 3.0 Логика перенесена на триггера.
  gdcInvDocument_Version3_0 = 'IDV3.0';

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
    imctOurCompany,
    imctOurDepartment,
    imctOurPeople,
    imctCompany,
    imctCompanyDepartment,
    imctCompanyPeople,
    imctPeople,
    imctOurDepartAndPeople
  );
  // imctOurCompany - Наша компания
  // imctOurDepartment - Подразделение нашей компании
  // imctOurPeople - Сотрудник нашей компании
  // imctCompany - Клиент (Юридическое лицо)
  // imctCompanyDepartment - Подразделение клиента
  // imctCompanyPeople - Сотрудник клиента
  // imctPeople - физическое лицо

const
  gdcInvMovementContactTypeLow = imctOurCompany;
  gdcInvMovementContactTypeHigh = imctOurDepartAndPeople;
  gdcInvMovementContactTypeNames: array[gdcInvMovementContactTypeLow..gdcInvMovementContactTypeHigh] of String = (
    'imctOurCompany',
    'imctOurDepartment',
    'imctOurPeople',
    'imctCompany',
    'imctCompanyDepartment',
    'imctCompanyPeople',
    'imctPeople',
    'imctOurDepartAndPeople'
  );

type
  TgdcMCOPredefined = array of Integer;

  // Структура используется при определении атрибута
  // отвечающего за источник или получателя ТМЦ
  // в складском документе.
  TgdcInvMovementContactOption = class(TObject)
  public
    RelationName: String[31];               // Наименование таблицы
    SourceFieldName: String[31];            // Наименование поля-атрибута

    SubRelationName: String[31];            // Наименование таблицы
    SubSourceFieldName: String[31];         // Наименование дополнительного поля-атрибута

    ContactType: TgdcInvMovementContactType;// Тип контакта
    ContactTypeSet: Boolean;

    Predefined: TgdcMCOPredefined;           // Набор возможных значений
    SubPredefined: TgdcMCOPredefined;        // Набор возможных значений

    procedure Assign(AnObject: TgdcInvMovementContactOption);
    procedure GetProperties(ASL: TStrings);
    procedure AddPredefined(const AnID: Integer);
    procedure AddSubPredefined(const AnID: Integer);
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
  'Sub %0:s(Sender) '#13#10 +
  '  If scrPublicVariables.Value("%1:s") <> "1" Then '#13#10 +
  '    scrPublicVariables.AddValue "%1:s", "1" '#13#10 +
  '    Sender.DataSet.FieldByName("%2:s").AsVariant = _ '#13#10 +
  '       Sender.AsVariant * Sender.DataSet.FieldByName("QUANTITY").AsVariant '#13#10 +
  '    scrPublicVariables.AddValue "%1:s", "0" '#13#10 +
  '  End If '#13#10#13#10 +
  '  Dim EventParams(0) '#13#10 +
  '  Set  EventParams(0) = Sender'#13#10 +
  '  Call Inherited(Sender, "OnChange", EventParams)'#13#10#13#10 +
  'End Sub ';

  gdcInvCalcPriceMacrosName =
  'Sub %0:s(Sender) '#13#10 +
  '  If scrPublicVariables.Value("%2:s") <> "1" Then '#13#10 +
  '    scrPublicVariables.AddValue "%2:s", "1" '#13#10 +
  '    If Not IsNull(Sender.DataSet.FieldByName("QUANTITY").AsVariant) And _'#13#10 +
  '       Sender.DataSet.FieldByName("QUANTITY").AsVariant <> 0 Then '#13#10 +
  '      Sender.DataSet.FieldByName("%2:s").AsVariant = _ '#13#10 +
  '         Sender.AsVariant / Sender.DataSet.FieldByName("QUANTITY").AsVariant '#13#10 +
  '    End If '#13#10 +
  '    scrPublicVariables.AddValue "%2:s", "0" '#13#10 +
  '  End If '#13#10#13#10 +
  '  Dim EventParams(0) '#13#10 +
  '  Set  EventParams(0) = Sender'#13#10 +
  '  Call Inherited(Sender, "OnChange", EventParams)'#13#10#13#10#13#10 +
  'End Sub ';

  gdcInvQuantityOnChangeHeader = 'Sub gdcInvDocumentLine%sOnChange(Sender)';
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

uses
  SysUtils, gd_common_functions;

{ TgdcInvMovementContactOption }

procedure TgdcInvMovementContactOption.AddPredefined(const AnID: Integer);
begin
  SetLength(Predefined, Length(Predefined) + 1);
  Predefined[High(Predefined)] := AnID;
end;

procedure TgdcInvMovementContactOption.AddSubPredefined(
  const AnID: Integer);
begin
  SetLength(SubPredefined, Length(SubPredefined) + 1);
  Predefined[High(SubPredefined)] := AnID;
end;

procedure TgdcInvMovementContactOption.Assign(
  AnObject: TgdcInvMovementContactOption);
begin
  RelationName := AnObject.RelationName;
  SourceFieldName := AnObject.SourceFieldName;

  SubRelationName := AnObject.SubRelationName;
  SubSourceFieldName := AnObject.SubSourceFieldName;

  ContactType := AnObject.ContactType;
  ContactTypeSet := AnObject.ContactTypeSet;

  Predefined := Copy(AnObject.Predefined, 0, MaxInt);
  SubPredefined := Copy(AnObject.SubPredefined, 0, MaxInt);
end;

procedure TgdcInvMovementContactOption.GetProperties(ASL: TStrings);
var
  S: String;
  I: Integer;
begin
  Assert(ASL <> nil);

  ASL.Add(AddSpaces('Relation name') + RelationName);
  ASL.Add(AddSpaces('Source field name') + SourceFieldName);
  ASL.Add(AddSpaces('Sub relation name') + SubRelationName);
  ASL.Add(AddSpaces('Sub source field name') + SubSourceFieldName);

  case ContactType of
    imctOurCompany: S := 'Наша компания';
    imctOurDepartment: S := 'Наше подразделение';
    imctOurPeople: S := 'Наш сотрудник';
    imctCompany: S := 'Компания';
    imctCompanyDepartment: S := 'Подразделение';
    imctCompanyPeople: S := 'Сотрудник';
    imctPeople: S := 'Физическое лицо';
    imctOurDepartAndPeople: S := 'Наше подразделение и сотрудник';
  end;

  ASL.Add(AddSpaces('ContactType') + S);

  S := '';
  for I := 0 to High(Predefined) do
    S := S + IntToStr(Predefined[I]) + ', ';
  if S > '' then
    SetLength(S, Length(S) - 2);
  ASL.Add(AddSpaces('Predefined') + S);

  S := '';
  for I := 0 to High(SubPredefined) do
    S := S + IntToStr(SubPredefined[I]) + ', ';
  if S > '' then
    SetLength(S, Length(S) - 2);
  ASL.Add(AddSpaces('SubPredefined') + S);
end;

end.
