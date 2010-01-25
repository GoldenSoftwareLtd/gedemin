
{++

  Copyright (c) 1998-99 by Golden Software of Belarus

  Module

    mmRunTimeStore.pas (ex-mmVisualDataSettings)

  Abstract

    A non-visual component, which stores all user's visual setings in a database.

  Author

    Smirnov Anton (1-11-98), Romanovski Denis (06.03.99)

  Revisions history

    Initial  31-12-98  Anton   Initial version.

    Update   06-03-99  Dennis  Complitely remaking component on the basis of
                               mmVisualDataSettings.

    Beta1    16-03-99  Dennis  Beta version! Component rebuilt complitely. Speed much
                               improved, everything's stored in cache.

    Beta2    18-03-99  Dennis  Speed improved! Everything works!

    Beta3    19-03-99  Dennis  Bugs on database key jumping fixed.Other bugs.
                               Ultra settings storing (conditional formatting, detail viewing)!

    Beta4    20-03-99  Dennis  Some things improved! Buggs fixed!

    Beta5    21-03-99  Dennis  Database bugs fixed. Do not try to call post after post for
                               the same record without calling refresh method.

    Beta6    25-03-99  Dennis  Bug on space fixed.

    Beta7    23-03-99  Dennis  TmmDBGridTreeEx included.

    Beta8    23-03-99  Dennis  Procedure ReadDefaultSettings included. Buggs fixed. TxDBLookupCombo2
                               included.

    Beta9    14-04-99  Dennis  Speed improved. In ReadCache I set DisableControls then change all
                               the parameters and then only EnableControls.

    Beta10   21-08-99  Dennis  Some code changed. ReadData procedure in TRunTimeStore a little bit
                               changed: [if not IsTree] removed.

    Beta11   02-09-99  Andreik Multilingual support added.

    Beta12   24-01-00  Dennis  Query changed. Also some code changed. Now it works faster.
--}

{
  ВНИМАНИЕ! (Delphi 4.3)

  Для нормальной работы данной компоненты необходимо произвести замену кода
  в файле DBGrids.pas, в классе TColumn, в методе DefaultWidth код

  Result := Field.DisplayWidth * (Canvas.TextWidth('0') - TM.tmOverhang) + TM.tmOverhang + 4;

  на код

  Result := Field.DisplayWidth * TM.tmAveCharWidth - (TM.tmAveCharWidth div 2) + TM.tmOverhang + 3;

  иначе будет проблема с правильным установлением размеров колонок.

  P.S. Это связано с тем, что Borland неправильно рассчитывает размеры колонок!
}

unit mmRunTimeStore;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UserLogin, ExList, DB, DBTables, DBClient, DBGrids;

const
  DefUserKey = -1;
  DefContext = -1;

type
  TmmRunTimeStore = class(TComponent)
  private
    FTableName, FTableFieldName: String; // Наименование таблицы данных
    FContext: Integer; // Контекст
    FUserKey: Integer; // Ключ пользователя

    FUseUserLogin: Boolean; // Использовать ли компоненту подключения по паролю
    FDatabaseName: String; // Наименование базы данных
    FEnabled: Boolean; // Режим включения/отключения

    FTables: TStringList; // Список сохраняемых таблиц
    FQueries: TStringList; // Список сохраняемых запросов

    FStores: TExList; // Список сохраняемых элементов

    FStoreTable, FStoreFields: TTable; // Таблица сохраняемых настроек
    FStoreProc: TStoredProc; // Уникальный номер
    FFindQuery: TQuery; // Запрос на поиск необходимых данных

    OldOnCreateForm, OldOnDestroyForm: TNotifyEvent; // Event создания, уничтожения формы-родителя данной компоненты

    FOnCustomGrid: TNotifyEvent; // Eevent Grid-ов пользователя

    procedure DoOnCreateForm(Sender: TObject);
    procedure DoOnDestroyForm(Sender: TObject);

    procedure OpenStoreTable(Reading: Boolean);
    procedure CloseStoreTable;

    procedure ReadStoreKeys;
    procedure AssociateGrids;

    procedure SetTables(const Value: TStringList);
    procedure SetQueries(const Value: TStringList);

    function GetActiveStoreTable: Boolean;
    function FindStoreByName(ATableName: String; var Index: Integer): Boolean;

  protected
    procedure Loaded; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure AddGridToStore(TableName: String; G: TDBGrid);
    procedure ReadDefaultSettings(TableName: String);
    procedure ReadAllDefaults;

    // Открыта ли таблица сохранения настроек
    property ActiveStoreTable: Boolean read GetActiveStoreTable;

  published
    // Таблица, из которой брать данные, в которую возвращать данные
    property TableName: String read FTableName write FTableName;
    // Таблица, из которой брать данные, в которую возвращать данные по полям
    property TableFieldName: String read FTableFieldName write FTableFieldName;
    // Контекст, по которому производить выборку необходимых данных
    property Context: Integer read FContext write FContext default DefContext;
    // Включает, отключает работу компоненты
    property Enabled: Boolean read FEnabled write FEnabled default True;
    // Ключ UserKey, по которому производить выборку необходимых данных
    property UserKey: Integer read FUserKey write FUserKey default DefUserKey;
    // Использовать ли компоненту подключения по паролю
    property UseUserLogin: Boolean read FUseUserLogin write FUseUserLogin default True;
    // Наименование базы данных
    property DatabaseName: String read FDatabaseName write FDatabaseName;
    // Список сохраняемых таблиц
    property Tables: TStringList read FTables write SetTables;
    // Список сохраняемых запросов
    property Queries: TStringList read FQueries write SetQueries;
    // Event по указанию Grid-ов пользователя
    property OnCustomGrid: TNotifyEvent read FOnCustomGrid write FOnCustomGrid;

  end;

implementation

uses
  Ternaries, mmDBGrid, mmDBGridTree, mmDBGridTreeEx, xDBLookU, xDBLookupStored,
  gsMultilingualSupport;

{
  ++++++++++++++++++++++++++++++++++++
  +++   Константы названий полей   +++
  ++++++++++++++++++++++++++++++++++++
}

const
  F_StoreKey = 'STOREKEY';
  F_UserKey = 'USERKEY';
  F_Context = 'CONTEXT';
  F_TableName = 'TABLENAME';
  F_FontColor = 'FONTCOLOR';
  F_FontSize = 'FONTSIZE';
  F_FontStyle = 'FONTSTYLE';
  F_FontName = 'FONTNAME';
  F_TitleFontColor = 'TITLEFONTCOLOR';
  F_TitleFontSize = 'TITLEFONTSIZE';
  F_TitleFontStyle = 'TITLEFONTSTYLE';
  F_TitleFontName = 'TITLEFONTNAME';
  F_Color = 'COLOR';
  F_TitleColor = 'TITLECOLOR';
  F_ColorSelected = 'COLORSELECTED';
  F_Striped = 'STRIPED';
  F_StripeOne = 'STRIPEONE';
  F_StripeTwo = 'STRIPETWO';
  F_ScaleColumns = 'SCALECOLUMNS';
  F_CondFormat = 'CONDFORMAT';
  F_ShowLines = 'SHOWLINES';
  F_Settings = 'SETTINGS';

  FF_FieldKey = 'FIELDKEY';
  FF_StoreKey = 'STOREKEY';
  FF_FieldName = 'FIELDNAME';
  FF_FieldOrder = 'FIELDORDER';
  FF_Visible = 'VISIBLE';
  FF_DisplayLabel = 'DISPLAYLABEL';
  FF_DisplayWidth = 'DISPLAYWIDTH';
  FF_Resizeable = 'RESIZEABLE';
  FF_MaxWidth = 'MAXWIDTH';
  FF_MinWidth = 'MINWIDTH';
  FF_DisplayFormat = 'DISPLAYFORMAT';
  FF_Alignment = 'ALIGNMENT';
  FF_EditMask = 'EDITMASK';
  FF_TitleFontColor = 'TITLEFONTCOLOR';
  FF_TitleFontSize = 'TITLEFONTSIZE';
  FF_TitleFontStyle = 'TITLEFONTSTYLE';
  FF_TitleFontName = 'TITLEFONTNAME';
  FF_TitleAlignment = 'TITLEALIGNMENT';
  FF_TitleColor = 'TITLECOLOR';
  FF_FontColor = 'FONTCOLOR';
  FF_FontSize = 'FONTSIZE';
  FF_FontStyle = 'FONTSTYLE';
  FF_FontName = 'FONTNAME';
  FF_Color = 'COLOR';

const
  SP_STOREKEY = 'FIN_P_RTS_STOREKEY';

{
  +++++++++++++++++++++++++++++++++++++++++++
  +++   Common Procedures and Functions   +++
  +++++++++++++++++++++++++++++++++++++++++++
}


// Стиль шрифта в строку перводит.
function FontStyleToStr(Style: TFontStyles): String;
begin
  Result := Format('%s%s%s%s', [
    Ternary(fsBold in Style, 'B', ''),
    Ternary(fsItalic in Style, 'I', ''),
    Ternary(fsUnderline in Style, 'U', ''),
    Ternary(fsStrikeout in Style, 'S', '')]);
end;

// Переводит стиль шрифта из строки в значение.
function StrToFontStyle(const S: String): TFontStyles;
begin
  Result := [];
  if Pos('B', S) > 0 then Result := Result + [fsBold];
  if Pos('I', S) > 0 then Result := Result + [fsItalic];
  if Pos('U', S) > 0 then Result := Result + [fsUnderline];
  if Pos('S', S) > 0 then Result := Result + [fsStrikeout];
end;

// Переводит строку в цвет.
function StringToColorEx(const S: String; DefColor: TColor): TColor;
begin
  try
    if S = '' then
      Result := DefColor
    else
      Result := StringToColor(S);
  except
    on Exception do
      Result := DefColor;
  end;
end;

// Выравнивание перевод в тип Char.
function AlToStr(const Align: TAlignment): Char;
begin
  case Align of
    taCenter: Result := 'C';
    taRightJustify: Result := 'R';
  else
    Result := 'L';
  end;
end;

// Возвращает из Char-а выравнивание.
function StrToAl(const Align: String): TAlignment;
begin
  if Length(Align) < 1 then
  begin
    Result := taLeftJustify;
    Exit;
  end;

  case UpCase(Align[1]) of
    'C': Result := taCenter;
    'R': Result := taRightJustify;
  else
    Result := taLeftJustify;
  end;
end;

// Производит поиск колонки в Grid-е по указателю на поле.
function FindColumn(G: TDBGrid; F: TField; var C: TColumn): Boolean;
var
  I: Integer;
begin
  Result := False;
  C := nil;
  if F = nil then Exit;

  for I := 0 to G.Columns.Count - 1 do
    if G.Columns[I].Field = F then
    begin 
      Result := True;
      C := G.Columns[I];
      Break;
    end;
end;


// Производит поиск опции поля по его имени.
function FindFieldOption(G: TmmDBGrid; F: String; var FO: TFieldOption): Boolean;
var
  I: Integer;
begin
  Result := False;
  FO := nil;

  for I := 0 to G.FieldOptions.Count - 1 do
    if AnsiCompareText(TFieldOption(G.FieldOptions[I]).FieldName, F) = 0 then
    begin
      Result := True;
      FO := G.FieldOptions[I];
      Break;
    end;
end;

type
  TFontRecord = record
    Color: TColor;
    Size: Integer;
    Style: TFontStyles;
    Name: String;
  end;

{
  ----------------------------
  ---                      ---
  ---   Internal Classes   ---
  ---                      ---
  ----------------------------
}


type
  TCachedStore = class
  private
    FFieldName: String; // Имя поля

    FTitleFont: TFontRecord; // Шрифт заглавия колонки
    FFont: TFontRecord; // Шрифт колонки

    FTitleAlignment: TAlignment; // Выравнивание заглвания колонки
    FTitleColor: TColor; // Цвет заглавия колонки
    FColor: TColor; // Цвет колонки

    FFieldOrder: Integer; // Индекс поля
    FVisible: Boolean; // Является ли визуально отображаемым
    FDisplayLabel: String; // Наименование
    FDisplayWidth: Integer; // Размер
    FDisplayFormat: String; // Формат отображения
    FAlignment: TAlignment; // Выравнивание колонки
    FEditMask: String; // Маска редактирования

    FWorkWithColumn: Boolean; // Есть ли у данного поля ассоциируемая колонка
    FClear: Boolean; // Является ли данная запись чистой
    FFieldKey: Integer; // Ключ на поле
  public
    constructor Create(AClear: Boolean);
  end;

// Производит поиск Cache по указателю поля
function FindCache(FCaches: TExList; F: String; var Cache: TCachedStore): Boolean;
var
  K: Integer;
begin
  Result := False;
  Cache := nil;

  for K := 0 to FCaches.Count - 1 do
    if AnsiCompareText(TCachedStore(FCaches[K]).FFieldName, F) = 0 then
    begin
      Result := True;
      Cache := FCaches[K];
      Break;
    end;
end;

type
  TRunTimeStore = class
  private
    FStoreKey: Integer; // Первичный ключ записи
    FExists: Boolean; // Создана ли запись для данных UserKey, Context

    FDataSet: TDataSet; // Таблица или запрос
    FTreeSet: TDataSet; // На случай использования дерева!

    FGrid: TDBGrid; // Связанный с ней Grid

    OldAfterOpen, OldBeforeClose: TDataSetNotifyEvent; // Event-ы таблицы
    OldAfterOpenTree: TDataSetNotifyEvent; // Event-ы таблицы-дерева

    FRTS: TmmRunTimeStore; // Ссылка на главный класс

    FFastCachedStores: TExList; // Кэш на некоторые установки для более быстрой работы
    FFullStores: TExList; // Кэш на все поля для сравнения
    FFullLoad: Boolean; // Была ли произведена полная загрузка данных

    FFont: TFontRecord; // Шрифт таблицы
    FTitleFont: TFontRecord; // Шрифт заглавий
    FColor: TColor; // Цвет таблицы
    FTitleColor: TColor; // Цвет заглавий
    FColorSelected: TColor; // Цвет выделенной строки
    FStriped: Boolean; // Полосатость
    FStripeOne: TColor; // Первая полоса
    FStripeTwo: TColor; // Вторая полоса
    FScaleColumns: Boolean; // Растягивание
    FCondFormat: Boolean; // Условное форматирование
    FShowLines: Boolean; // Детальное отображение

    procedure ReadSettings;
    procedure CompareAndWrite;

    procedure DoAfterOpen(DataSet: TDataSet);
    procedure DoBeforeClose(DataSet: TDataSet);

    procedure ReadCache(Cache: TExList; All: Boolean);
    procedure SaveCache(Cache: TExList; All: Boolean);

    procedure SetDataSet(const Value: TDataSet);

    function GetTableName: String;
    function GetIsTable: Boolean;
    function GetIsTree: Boolean;
    function GetIsTreeEx: Boolean;

  public
    constructor Create(ARTS: TmmRunTimeStore);
    destructor Destroy; override;

    procedure ClearData;
    procedure SaveData;
    procedure ReadData;

    // Первичный ключ
    property StoreKey: Integer read FStoreKey write FStoreKey;
    // Таблица или запрос
    property DataSet: TDataSet read FDataSet write SetDataSet;
    // Ассоциируемый Grid
    property Grid: TDBGrid read FGrid write FGrid;
    // Существуют ли сохраненные устновки на данную таблицу
    property Exists: Boolean read FExists write FExists;
    // Имя таблицы или имя компоненты запроса
    property TableName: String read GetTableName;
    // Являются ли данные таблицой
    property IsTable: Boolean read GetIsTable;
    // Является ли Grid деревом
    property IsTree: Boolean read GetIsTree;
    // Является ли Grid продвинутым деревом
    property IsTreeEx: Boolean read GetIsTreeEx;

  end;

{
  ------------------------
  ---   TCachedStore   ---
  ------------------------
}

{
  Делаем начальные установки.
}

constructor TCachedStore.Create;
begin
  FFieldName := '';

  FTitleFont.Color := clNone;
  FTitleFont.Size := 0;
  FTitleFont.Style := [];
  FTitleFont.Name := '';

  FTitleAlignment := taLeftJustify;
  FTitleColor := clNone;

  FFont.Color := clNone;
  FFont.Size := 0;
  FFont.Style := [];
  FFont.Name := '';

  FColor := clNone;

  FFieldOrder := 0;
  FVisible := False;
  FDisplayLabel := '';
  FDisplayWidth := 0;
  FDisplayFormat := '';
  FAlignment := taLeftJustify;
  FEditMask := '';

  FWorkWithColumn := False;
  FClear := AClear;
  FFieldKey := -1;
end;

{
  -------------------------
  ---   TRunTimeStore   ---
  -------------------------
}


{
  ***********************
  ***   Public Part   ***
  ***********************
}

{
  Делаем начальные установки.
}

constructor TRunTimeStore.Create(ARTS: TmmRunTimeStore);
begin
  FStoreKey := -1;
  FExists := False;

  FDataSet := nil;
  FTreeSet := nil;
  FGrid := nil;

  OldAfterOpen := nil;
  OldBeforeClose := nil;
  OldAfterOpenTree := nil;

  FFastCachedStores := TExList.Create;
  FFullStores := TExList.Create;

  FFullLoad := False;

  FRTS := ARTS;

  FFont.Color := clNone;
  FFont.Size := 0;
  FFont.Style := [];
  FFont.Name := '';

  FTitleFont.Color := clNone;
  FTitleFont.Size := 0;
  FTitleFont.Style := [];
  FTitleFont.Name := '';

  FColor := clNone;
  FTitleColor := clNone;
  FColorSelected := clNone;
  FStriped := False;
  FStripeOne := clNone;
  FStripeTwo := clNone;
  FScaleColumns := False;
  FCondFormat := False;
  FShowLines := False;
end;

{
  Высвобождаем память.
}

destructor TRunTimeStore.Destroy;
begin
  FFastCachedStores.Free;
  FFullStores.Free;

  inherited Destroy;
end;

{
  Производит очистку данных.
}

procedure TRunTimeStore.ClearData;
var
  I: Integer;
begin
  for I := 0 to FFastCachedStores.Count - 1 do FFastCachedStores.DeleteAndFree(0);
  for I := 0 to FFullStores.Count - 1 do  FFullStores.DeleteAndFree(0);

  FStoreKey := -1;
  FFullLoad := False;
  FExists := False;

  FFont.Color := clNone;
  FFont.Size := 0;
  FFont.Style := [];
  FFont.Name := '';

  FTitleFont.Color := clNone;
  FTitleFont.Size := 0;
  FTitleFont.Style := [];
  FTitleFont.Name := '';

  FColor := clNone;
  FTitleColor := clNone;
  FColorSelected := clNone;
  FStriped := False;
  FStripeOne := clNone;
  FStripeTwo := clNone;
  FScaleColumns := False;
  FCondFormat := False;
  FShowLines := False;
end;

{
  Сохраняет данные.
}

procedure TRunTimeStore.SaveData;
begin
  CompareAndWrite;
  FExists := True;
end;

{
  Считывает данные.
}

procedure TRunTimeStore.ReadData;
var
  I: Integer;
  CurrStore: TCachedStore;
begin
  if FDataSet.Active and not FFullLoad then
  begin
    if FStoreKey >= 0 then
      ReadSettings
    else //if not IsTree then {Changed here!!!!!}
    begin
      // Добавляем поля, по которым еще не были сохранены данные
      for I := 0 to FDataSet.FieldCount - 1 do
        if not FindCache(FFullStores, FDataSet.Fields[I].FieldName, CurrStore) then
        begin
          CurrStore := TCachedStore.Create(True);
          CurrStore.FFieldName := FDataSet.Fields[I].FieldName;
          FFullStores.Add(CurrStore);
        end;

      FFullLoad := True;
    end;
  end;  
end;

{
  ************************
  ***   Private Part   ***
  ************************
}

{
  Производит чтение текущих установок в потоке.
}

procedure TRunTimeStore.ReadSettings;
var
  F: TField;
  I, K: Integer;
  C: TColumn;
  FO: TFieldOption;
  Found: Boolean;
  CurrStore: TCachedStore;

  BlobStream: TBlobStream;
  CurrCondition: TCondition;

  AColor: TColor;
  ABool: Boolean;
  ASize: Integer;
  AnOperation: TConditionOperation;

  // Производит считывание строки из потока
  function ReadString: String;
  var
    L: Integer;
  begin
    BlobStream.Read(L, SizeOf(Integer));
    SetString(Result, PChar(nil), L);
    BlobStream.Read(Pointer(Result)^, L);
  end;

begin
  // Если ключ существует то производим переход на него.
  if FStoreKey >= 0 then
  with FRTS do
  begin
    if not FStoreTable.FindKey([FStoreKey]) then
      raise Exception.Create('Запись настроек не найдена!');

    // Удаляем старые установки
    for I := 0 to FFullStores.Count - 1 do FFullStores.DeleteAndFree(0);

    // Установки по колонкам таблицы
    FStoreFields.SetRange([FStoreKey], [FStoreKey]);
    FStoreFields.First;

    while not FStoreFields.EOF do
    begin
      F := DataSet.FindField(FStoreFields.FieldByName(FF_FIELDNAME).AsString);

      if F <> nil then
      begin
        CurrStore := TCachedStore.Create(False);
        CurrStore.FFieldKey := FStoreFields.FieldByName(FF_FIELDKEY).AsInteger;
        CurrStore.FFieldName := FStoreFields.FieldByName(FF_FIELDNAME).AsString;
        FFullStores.Add(CurrStore);

        CurrStore.FFieldOrder := FStoreFields.FieldByName(FF_FieldOrder).AsInteger;
        CurrStore.FVisible := Boolean(FStoreFields.FieldByName(FF_Visible).AsInteger)
          or FStoreFields.FieldByName(FF_Visible).IsNull;
        CurrStore.FDisplayLabel := FStoreFields.FieldByName(FF_DisplayLabel).AsString;
        CurrStore.FDisplayFormat := FStoreFields.FieldByName(FF_DisplayFormat).AsString;

        CurrStore.FAlignment :=  StrToAl(FStoreFields.FieldByName(FF_Alignment).AsString);
        CurrStore.FEditMask := FStoreFields.FieldByName(FF_EditMask).AsString;

        // Если есть ассоциируемый Grid
        if FGrid <> nil then        
        begin
          CurrStore.FWorkWithColumn := FindColumn(FGrid, F, C);

          CurrStore.FTitleFont.Color := StringToColorEx(FStoreFields.FieldByName(FF_TitleFontColor).AsString,
            FGrid.TitleFont.Color);

          if FStoreFields.FieldByName(FF_TitleFontSize).AsInteger <= 0 then
            CurrStore.FTitleFont.Size := FGrid.TitleFont.Size
          else
            CurrStore.FTitleFont.Size := FStoreFields.FieldByName(FF_TitleFontSize).AsInteger;

          CurrStore.FTitleFont.Style := StrToFontStyle(FStoreFields.FieldByName(FF_TitleFontStyle).AsString);

          if FStoreFields.FieldByName(FF_TitleFontName).AsString = '' then
            CurrStore.FTitleFont.Name := FGrid.TitleFont.Name
          else
            CurrStore.FTitleFont.Name := FStoreFields.FieldByName(FF_TitleFontName).AsString;

          CurrStore.FTitleAlignment := StrToAl(FStoreFields.FieldByName(FF_TitleAlignment).AsString);
          CurrStore.FTitleColor := StringToColorEx(FStoreFields.FieldByName(FF_TitleColor).AsString,
            FGrid.FixedColor);

          CurrStore.FFont.Color := StringToColorEx(FStoreFields.FieldByName(FF_FontColor).AsString,
            FGrid.Font.Color);

          if FStoreFields.FieldByName(FF_FontSize).AsInteger <= 0 then
            CurrStore.FFont.Size := FGrid.Font.Size
          else
            CurrStore.FFont.Size := FStoreFields.FieldByName(FF_FontSize).AsInteger;

          CurrStore.FFont.Style := StrToFontStyle(FStoreFields.FieldByName(FF_FontStyle).AsString);

          if FStoreFields.FieldByName(FF_FontName).AsString = '' then
            CurrStore.FFont.Name := FGrid.Font.Name
          else
            CurrStore.FFont.Name := FStoreFields.FieldByName(FF_FontName).AsString;

          CurrStore.FColor := StringToColorEx(FStoreFields.FieldByName(FF_Color).AsString, FGrid.Color);

          // Если данный Grid является TmmDBGrid
          // Данную информацию сразу скидываем в Grid
          if FGrid is TmmDBGrid then
          begin
            Found := FindFieldOption(FGrid as TmmDBGrid, F.FieldName, FO);
            if not Found then FO := TFieldOption.Create;

            FO.FieldName := F.FieldName;

            if FStoreFields.FieldByName(FF_Resizeable).IsNull then
              FO.Scaled := True
            else
              FO.Scaled := Boolean(FStoreFields.FieldByName(FF_Resizeable).AsInteger);

            if FStoreFields.FieldByName(FF_MaxWidth).IsNull then
              FO.MaxWidth := -1
            else
              FO.MaxWidth := FStoreFields.FieldByName(FF_MaxWidth).AsInteger;

            if FStoreFields.FieldByName(FF_MinWidth).IsNull then
              FO.MinWidth := -1
            else
              FO.MinWidth := FStoreFields.FieldByName(FF_MinWidth).AsInteger;

            if not Found then TmmDBGrid(FGrid).FieldOptions.Add(FO);
          end;
        end;

        CurrStore.FDisplayWidth := FStoreFields.FieldByName(FF_DisplayWidth).AsInteger;
      end;

      FStoreFields.Next;
    end;

    // Установки по ассоциируемому Grid-у
    if FGrid <> nil then
    begin
      FFont.Color := StringToColorEx(FStoreTable.FieldByName(F_FontColor).AsString, FGrid.Font.Color);
      FGrid.Font.Color := FFont.Color;
      if Assigned(TranslateBase) then
        FGrid.Font.Charset := TranslateBase.CharSet;

      if FStoreTable.FieldByName(F_FontSize).AsInteger <= 0 then
        FFont.Size := FGrid.Font.Size
      else
        FFont.Size := FStoreTable.FieldByName(F_FontSize).AsInteger;

      FGrid.Font.Size := FFont.Size;

      FFont.Style := StrToFontStyle(FStoreTable.FieldByName(F_FontStyle).AsString);
      FGrid.Font.Style := FFont.Style;

      if FStoreTable.FieldByName(F_FontName).AsString = '' then
        FFont.Name := FGrid.Font.Name
      else
        FFont.Name := FStoreTable.FieldByName(F_FontName).AsString;
      FGrid.Font.Name := FFont.Name;

      FTitleFont.Color := StringToColorEx(FStoreTable.FieldByName(F_TitleFontColor).AsString,
        FGrid.TitleFont.Color);
      FGrid.TitleFont.Color := FTitleFont.Color;
      if Assigned(TranslateBase) then
        FGrid.TitleFont.Charset := TranslateBase.CharSet;

      if FStoreTable.FieldByName(F_TitleFontSize).AsInteger <= 0 then
        FTitleFont.Size := FGrid.Font.Size
      else
        FTitleFont.Size := FStoreTable.FieldByName(F_TitleFontSize).AsInteger;
      FGrid.TitleFont.Size := FTitleFont.Size;

      FTitleFont.Style := StrToFontStyle(FStoreTable.FieldByName(F_TitleFontStyle).AsString);
      FGrid.TitleFont.Style := FTitleFont.Style;

      if FStoreTable.FieldByName(F_TitleFontName).AsString = '' then
        FTitleFont.Name := FGrid.TitleFont.Name
      else
        FTitleFont.Name := FStoreTable.FieldByName(F_TitleFontName).AsString;
      FGrid.TitleFont.Name := FTitleFont.Name;

      FColor := StringToColorEx(FStoreTable.FieldByName(F_Color).AsString, FGrid.Color);
      FGrid.Color := FColor;

      FTitleColor := StringToColorEx(FStoreTable.FieldByName(F_TitleColor).AsString, FGrid.FixedColor);
      FGrid.FixedColor := FTitleColor;

      // Если ассоциируемый Grid является TmmDBGrid
      if FGrid is TmmDBGrid then
      begin
        FColorSelected := StringToColorEx(FStoreTable.FieldByName(F_ColorSelected).AsString,
          (FGrid as TmmDBGrid).ColorSelected);
        (FGrid as TmmDBGrid).ColorSelected  := FColorSelected;

        FStriped := Boolean(FStoreTable.FieldByName(F_Striped).AsInteger) or
          FStoreTable.FieldByName(F_Striped).IsNull;
        (FGrid as TmmDBGrid).Striped := FStriped;

        FStripeOne := StringToColorEx(FStoreTable.FieldByName(F_StripeOne).AsString,
          (FGrid as TmmDBGrid).StripeOne);
        (FGrid as TmmDBGrid).StripeOne := FStripeOne;

        FStripeTwo := StringToColorEx(FStoreTable.FieldByName(F_StripeTwo).AsString,
          (FGrid as TmmDBGrid).StripeTwo);
        (FGrid as TmmDBGrid).StripeTwo := FStripeTwo;

        if FStoreTable.FieldByName(F_ScaleColumns).IsNull then
          FScaleColumns := (FGrid as TmmDBGrid).ScaleColumns
        else  
          FScaleColumns := Boolean(FStoreTable.FieldByName(F_ScaleColumns).AsInteger);
          
        (FGrid as TmmDBGrid).ScaleColumns := FScaleColumns;

        FCondFormat := Boolean(FStoreTable.FieldByName(F_CondFormat).AsInteger);
        (FGrid as TmmDBGrid).ConditionalFormatting := FCondFormat;

        FShowLines := Boolean(FStoreTable.FieldByName(F_ShowLines).AsInteger);
        (FGrid as TmmDBGrid).ShowLines := FShowLines;

        /////////////////////////////////////////////////
        //                                             //
        //   B L O B - С У П Е Р  У С Т А Н О В К И!   //
        //                                             //
        /////////////////////////////////////////////////

        if not FStoreTable.FieldByName(F_Settings).IsNULL then
        begin
          // Создаем поток для записи данных по суперустановкам
          BlobStream := FStoreTable.
            CreateBlobStream(FStoreTable.FieldByName(F_Settings), bmRead) as TBlobStream;

          BlobStream.Seek(0, soFromBeginning);

          try
            with FGrid as TmmDBGrid do
            begin
              // У С Л О В Н О Е  Ф О Р М А Т И Р О В А Н И Е

              BlobStream.Read(K, SizeOf(Integer));

              for I := 1 to K do
              begin
                CurrCondition := TCondition.Create;
                Conditions.Add(CurrCondition);

                BlobStream.Read(AColor, SizeOf(TColor));
                CurrCondition.Color := AColor;

                BlobStream.Read(ABool, SizeOf(Boolean));
                CurrCondition.UseColor := ABool;

                BlobStream.Read(AColor, SizeOf(TColor));
                CurrCondition.Font.Color := AColor;

                BlobStream.Read(ASize, SizeOf(Integer));
                CurrCondition.Font.Size := ASize;

                CurrCondition.Font.Style := StrToFontStyle(ReadString);
                CurrCondition.Font.Name := ReadString;

                BlobStream.Read(ABool, SizeOf(Boolean));
                CurrCondition.UseFont := ABool;

                CurrCondition.Condition1 := ReadString;
                CurrCondition.Condition2 := ReadString;

                BlobStream.Read(AnOperation, SizeOf(TConditionOperation));
                CurrCondition.Operation := AnOperation;

                BlobStream.Read(ABool, SizeOf(Boolean));
                CurrCondition.Formula := ABool;

                CurrCondition.FieldName := ReadString;
                CurrCondition.DisplayFields.Text := ReadString;
              end;

              LineFields.Text := ReadString;
              UltraChanges := False;
            end;
          finally
            BlobStream.Free;
          end;

          (FGrid as TmmDBGrid).PrepareConditions;
        end;
      end;
    end;

    // Считываем данные по колонкам из созданного кэша
    ReadCache(FFullStores, True);
  end;

  // Добавляем поля, по которым еще не были сохранены данные
  for I := 0 to FDataSet.FieldCount - 1 do
    if not FindCache(FFullStores, FDataSet.Fields[I].FieldName, CurrStore) then
    begin
      CurrStore := TCachedStore.Create(True);
      CurrStore.FFieldName := FDataSet.Fields[I].FieldName;
      FFullStores.Add(CurrStore);
    end;

  FFullLoad := True;
end;

{
  Сохраняет текущие установки в потоке.
}

procedure TRunTimeStore.CompareAndWrite;
var
  Compare, CompareField: Boolean;
  I: Integer;
  S: String;

  BlobStream: TBlobStream;
  CurrCondition: TCondition;

  AColor: TColor;
  ASize: Integer;
  AName: String;
  AnAlignment: TAlignment;
  AStyle: TFontStyles;
  AnIndex: Integer;

  // Переходит в режим редактирования
  procedure EnsureStoreTableEdit;
  begin
    if not FRTS.FStoreTable.Active or not FRTS.FStoreFields.Active then
      FRTS.OpenStoreTable(False);
    if not (FRTS.FStoreTable.State in [dsEdit, dsInsert]) then
    begin
      if not FRTS.FStoreTable.FindKey([FStoreKey]) then raise Exception.Create('Не найден StoreKey!');
      FRTS.FStoreTable.Edit;
    end;
  end;

  // Записывает поле
  procedure WriteField(F: TField; FieldName: String; CS: TCachedStore);
  var
    C: TColumn;
    FastCS: TCachedStore;

    // Переходит в режим редактирования
    procedure EnsureStoreFieldsEdit;
    begin
      if not FRTS.FStoreTable.Active or not FRTS.FStoreFields.Active then
        FRTS.OpenStoreTable(False);
      if not (FRTS.FStoreFields.State in [dsEdit, dsInsert]) then
      begin
        if not FRTS.FStoreFields.FindKey([CS.FFieldKey]) then raise Exception.Create('Не найден FieldKey!');
        FRTS.FStoreFields.Edit;
      end;
    end;

  begin
    with FRTS do
    begin
      FastCS := nil;
      // Если база уже закрыта
      if (F = nil) and not FindCache(FFastCachedStores, FieldName, FastCS) then
        raise Exception.Create('Ошибка после закрытия базы данных!');

      if F <> nil then
        AnIndex := F.Index
      else
        AnIndex := FastCS.FFieldOrder;

      // Данные по обычным полям

      if not CompareField or (CompareField and (CS.FFieldOrder <> AnIndex)) then
      begin
        EnsureStoreFieldsEdit;
        FStoreFields.FieldByName(FF_FieldOrder).AsInteger := AnIndex;
      end;

      if F <> nil then
        AnIndex := Integer(F.Visible)
      else
        AnIndex := Integer(FastCS.FVisible);

      if not CompareField or (CompareField and (Integer(CS.FVisible) <> AnIndex)) then
      begin
        EnsureStoreFieldsEdit;
        FStoreFields.FieldByName(FF_Visible).AsInteger := AnIndex;
      end;

      if F <> nil then
        AName := F.DisplayLabel
      else
        AName := FastCS.FDisplayLabel;

      if not CompareField or (CompareField and (AnsiCompareText(CS.FDisplayLabel, AName) <> 0)) then
      begin
        EnsureStoreFieldsEdit;
        FStoreFields.FieldByName(FF_DisplayLabel).AsString := AName;
      end;

      if F <> nil then
        AnIndex := F.DisplayWidth
      else
        AnIndex := FastCS.FDisplayWidth;

      if not CompareField or (CompareField and (Integer(CS.FDisplayWidth) <> AnIndex)) then
      begin
        EnsureStoreFieldsEdit;
        FStoreFields.FieldByName(FF_DisplayWidth).AsInteger := AnIndex;
      end;

      if F <> nil then
      begin
        if F is TNumericField then
          S := (F as TNumericField).DisplayFormat
        else if F is TDateTimeField then
          S := (F as TDateTimeField).DisplayFormat
        else
          S := '';
      end else
        S := FastCS.FDisplayFormat;

      if not CompareField or (CompareField and (CS.FDisplayFormat <> S)) then
      begin
        EnsureStoreFieldsEdit;

        if F is TNumericField then
          FStoreFields.FieldByName(FF_DisplayFormat).AsString := S
        else if F is TDateTimeField then
          FStoreFields.FieldByName(FF_DisplayFormat).AsString := S;
      end;

      if F <> nil then
        AnAlignment := F.Alignment
      else
        AnAlignment := FastCS.FAlignment;

      if not CompareField or (CompareField and (CS.FAlignment <> AnAlignment)) then
      begin
        EnsureStoreFieldsEdit;
        FStoreFields.FieldByName(FF_Alignment).AsString := AlToStr(AnAlignment);
      end;

      if F <> nil then
        AName := F.EditMask
      else
        AName := FastCS.FEditMask;

      if not CompareField or (CompareField and (AnsiCompareText(CS.FEditMask, AName) <> 0)) then
      begin
        EnsureStoreFieldsEdit;
        FStoreFields.FieldByName(FF_EditMask).AsString := AName;
      end;

      // Если есть ассоциируемый Grid
      if (FGrid <> nil) and (FindColumn(FGrid, F, C) or (Assigned(FastCS) and FastCS.FWorkWithColumn)) then
      begin
        if C <> nil then
          AColor := C.Title.Font.Color
        else
          AColor := FastCS.FTitleFont.Color;

        if not CompareField or (CompareField and (CS.FTitleFont.Color <> AColor)) then
        begin
          EnsureStoreFieldsEdit;
          FStoreFields.FieldByName(FF_TitleFontColor).AsString := ColorToString(AColor);
        end;

        if C <> nil then
          ASize := C.Title.Font.Size
        else
          ASize := FastCS.FTitleFont.Size;

        if not CompareField or (CompareField and (CS.FTitleFont.Size <> ASize)) then
        begin
          EnsureStoreFieldsEdit;
          FStoreFields.FieldByName(FF_TitleFontSize).AsInteger := ASize;
        end;

        if C <> nil then
          AStyle := C.Title.Font.Style
        else
          AStyle := FastCS.FTitleFont.Style;

        if not CompareField or (CompareField and (CS.FTitleFont.Style <> AStyle)) then
        begin
          EnsureStoreFieldsEdit;
          FStoreFields.FieldByName(FF_TitleFontStyle).AsString := FontStyleToStr(AStyle);
        end;

        if C <> nil then
          AName := C.Title.Font.Name
        else
          AName := FastCS.FTitleFont.Name;

        if not CompareField or (CompareField and (AnsiCompareText(CS.FTitleFont.Name, AName) <> 0)) then
        begin
          EnsureStoreFieldsEdit;
          FStoreFields.FieldByName(FF_TitleFontName).AsString := AName;
        end;

        if C <> nil then
          AnAlignment := C.Title.Alignment
        else
          AnAlignment := FastCS.FTitleAlignment;

        if not CompareField or (CompareField and (CS.FTitleAlignment <> AnAlignment)) then
        begin
          EnsureStoreFieldsEdit;
          FStoreFields.FieldByName(FF_TitleAlignment).AsString := AlToStr(AnAlignment);
        end;

        if C <> nil then
          AColor := C.Title.Color
        else
          AColor := FastCS.FTitleColor;

        if not CompareField or (CompareField and (CS.FTitleColor <> AColor)) then
        begin
          EnsureStoreFieldsEdit;
          FStoreFields.FieldByName(FF_TitleColor).AsString := ColorToString(AColor);
        end;

        if C <> nil then
          AColor := C.Font.Color
        else
          AColor := FastCS.FFont.Color;

        if not CompareField or (CompareField and (CS.FFont.Color <> AColor)) then
        begin
          EnsureStoreFieldsEdit;
          FStoreFields.FieldByName(FF_FontColor).AsString := ColorToString(AColor);
        end;

        if C <> nil then
          ASize := C.Font.Size
        else
          ASize := FastCS.FFont.Size;

        if not CompareField or (CompareField and (CS.FFont.Size <> ASize)) then
        begin
          EnsureStoreFieldsEdit;
          FStoreFields.FieldByName(FF_FontSize).AsInteger := ASize;
        end;

        if C <> nil then
          AStyle := C.Font.Style
        else
          AStyle := FastCS.FFont.Style;

        if not CompareField or (CompareField and (CS.FFont.Style <> AStyle)) then
        begin
          EnsureStoreFieldsEdit;
          FStoreFields.FieldByName(FF_FontStyle).AsString := FontStyleToStr(AStyle);
        end;

        if C <> nil then
          AName := C.Font.Name
        else
          AName := FastCS.FFont.Name;

        if not CompareField or (CompareField and (AnsiCompareText(CS.FFont.Name, AName) <> 0)) then
        begin
          EnsureStoreFieldsEdit;
          FStoreFields.FieldByName(FF_FontName).AsString := AName;
        end;

        if C <> nil then
          AColor := C.Color
        else
          AColor := FastCS.FColor;

        if not CompareField or (CompareField and (CS.FColor <> AColor)) then
        begin
          EnsureStoreFieldsEdit;
          FStoreFields.FieldByName(FF_Color).AsString := ColorToString(AColor);
        end;
      end;
    end;
  end;

  // Производит запись строки в поток
  procedure WriteString(S: String);
  var
    L: Integer;
  begin
    L := Length(S);
    BlobStream.Write(L, SizeOf(Integer));
    BlobStream.Write(Pointer(S)^, L);
  end;

begin
  // Необходимо еще проверить! Но если не загружено, то сохранять не надо!
  if not FFullLoad then Exit;

  Compare := (FStoreKey >= 0) and FExists;

  with FRTS do
  begin
    // Если необходимо создать новую запись по таблице
    if not Compare then
    begin
      try
        if not FRTS.FStoreTable.Active or not FRTS.FStoreFields.Active then
          FRTS.OpenStoreTable(False);
        FStoreProc.ExecProc;
        FStoreKey := FStoreProc.ParamByName(F_STOREKEY).AsInteger;
        FStoreTable.Append;
        FStoreTable.FieldByName(F_StoreKey).AsInteger := FStoreKey;
        FStoreTable.FieldByName(F_UserKey).AsInteger := FUserKey;
        FStoreTable.FieldByName(F_Context).AsInteger := FContext;
        FStoreTable.FieldByName(F_TableName).AsString := Self.TableName;
        FStoreTable.Post;
        FStoreTable.Refresh;
      except
        Exit;
      end;
    end;

    for I := 0 to FFullStores.Count - 1 do
    begin
      CompareField := (TCachedStore(FFullStores[I]).FFieldKey >= 0) and Exists;

      // Если данная запись еще не создана
      if not CompareField then
      begin
        if not FRTS.FStoreTable.Active or not FRTS.FStoreFields.Active then
          FRTS.OpenStoreTable(False);
        FStoreFields.Append;
        FStoreFields.FieldByName(FF_StoreKey).AsInteger := FStoreKey;
        FStoreFields.FieldByName(FF_FieldName).AsString := TCachedStore(FFullStores[I]).FFieldName;
      end;

      // Если поля созданы автоматически (не в Design режиме)
      if not FDataSet.Active and FDataSet.DefaultFields then
        WriteField(nil, TCachedStore(FFullStores[I]).FFieldName, FFullStores[I])
      else
        WriteField(FDataSet.FindField(TCachedStore(FFullStores[I]).FFieldName),
          TCachedStore(FFullStores[I]).FFieldName, FFullStores[I]);

      if FStoreFields.State in [dsEdit, dsInsert] then FStoreFields.Post;
    end;

    // Если существует ассоциируемый Grid
    if FGrid <> nil then
    begin
      if not Compare or (Compare and (FFont.Color <> FGrid.Font.Color)) then
      begin
        EnsureStoreTableEdit;
        FStoreTable.FieldByName(F_FontColor).AsInteger := FGrid.Font.Color;
      end;

      if not Compare or (Compare and (FFont.Size <> FGrid.Font.Size)) then
      begin
        EnsureStoreTableEdit;
        FStoreTable.FieldByName(F_FontSize).AsInteger := FGrid.Font.Size;
      end;

      if not Compare or (Compare and (FFont.Style <> FGrid.Font.Style)) then
      begin
        EnsureStoreTableEdit;
        FStoreTable.FieldByName(F_FontStyle).AsString := FontStyleToStr(FGrid.Font.Style);
      end;

      if not Compare or (Compare and (AnsiCompareText(FFont.Name, FGrid.Font.Name) <> 0)) then
      begin
        EnsureStoreTableEdit;
        FStoreTable.FieldByName(F_FontName).AsString := FGrid.Font.Name;
      end;

      if not Compare or (Compare and (FTitleFont.Color <> FGrid.TitleFont.Color)) then
      begin
        EnsureStoreTableEdit;
        FStoreTable.FieldByName(F_TitleFontColor).AsString := ColorToString(FGrid.TitleFont.Color);
      end;

      if not Compare or (Compare and (FTitleFont.Size <> FGrid.TitleFont.Size)) then
      begin
        EnsureStoreTableEdit;
        FStoreTable.FieldByName(F_TitleFontSize).AsInteger := FGrid.TitleFont.Size;
      end;

      if not Compare or (Compare and (FTitleFont.Style <> FGrid.TitleFont.Style)) then
      begin
        EnsureStoreTableEdit;
        FStoreTable.FieldByName(F_TitleFontStyle).AsString := FontStyleToStr(FGrid.TitleFont.Style);
      end;

      if not Compare or (Compare and (AnsiCompareText(FTitleFont.Name, FGrid.TitleFont.Name) <> 0)) then
      begin
        EnsureStoreTableEdit;
        FStoreTable.FieldByName(F_TitleFontName).AsString := FGrid.TitleFont.Name;
      end;

      if not Compare or (Compare and (FColor <> FGrid.Color)) then
      begin
        EnsureStoreTableEdit;
        FStoreTable.FieldByName(F_Color).AsString := ColorToString(FGrid.Color);
      end;

      if not Compare or (Compare and (FTitleColor <> FGrid.FixedColor)) then
      begin
        EnsureStoreTableEdit;
        FStoreTable.FieldByName(F_TitleColor).AsString := ColorToString(FGrid.FixedColor);
      end;

      // Если ассоциируемый Grid, является TmmDBGrid
      if FGrid is TmmDBGrid then
      begin
        if not Compare or (Compare and (FColorSelected <> (FGrid as TmmDBGrid).ColorSelected)) then
        begin
          EnsureStoreTableEdit;
          FStoreTable.FieldByName(F_ColorSelected).AsString :=
            ColorToString((FGrid as TmmDBGrid).ColorSelected);
        end;

        if not Compare or (Compare and (FStriped <> (FGrid as TmmDBGrid).Striped)) then
        begin
          EnsureStoreTableEdit;
          FStoreTable.FieldByName(F_Striped).AsInteger := Integer((FGrid as TmmDBGrid).Striped);
        end;

        if not Compare or (Compare and (FStripeOne <> (FGrid as TmmDBGrid).StripeOne)) then
        begin
          EnsureStoreTableEdit;
          FStoreTable.FieldByName(F_StripeOne).AsString := ColorToString((FGrid as TmmDBGrid).StripeOne);
        end;

        if not Compare or (Compare and (FStripeTwo <> (FGrid as TmmDBGrid).StripeTwo)) then
        begin
          EnsureStoreTableEdit;
          FStoreTable.FieldByName(F_StripeTwo).AsString := ColorToString((FGrid as TmmDBGrid).StripeTwo);
        end;

        if not Compare or (Compare and (FScaleColumns <> (FGrid as TmmDBGrid).ScaleColumns)) then
        begin
          EnsureStoreTableEdit;
          FStoreTable.FieldByName(F_ScaleColumns).AsInteger := Integer((FGrid as TmmDBGrid).ScaleColumns);
        end;

        if not Compare or (Compare and (FCondFormat <> (FGrid as TmmDBGrid).ConditionalFormatting)) then
        begin
          EnsureStoreTableEdit;
          FStoreTable.FieldByName(F_CondFormat).AsInteger := Integer((FGrid as TmmDBGrid).ConditionalFormatting);
        end;

        if not Compare or (Compare and (FShowLines <> (FGrid as TmmDBGrid).ShowLines)) then
        begin
          EnsureStoreTableEdit;
          FStoreTable.FieldByName(F_ShowLines).AsInteger := Integer((FGrid as TmmDBGrid).ShowLines);
        end;

        /////////////////////////////////////////////////
        //                                             //
        //   B L O B - С У П Е Р  У С Т А Н О В К И!   //
        //                                             //
        /////////////////////////////////////////////////

        // Если были произведены изменения
        if (FGrid as TmmDBGrid).UltraChanges or not Compare then
        begin
          EnsureStoreTableEdit;
          FStoreTable.FieldByName(F_Settings).Clear;
          // Создаем поток для записи данных по суперустановкам
          BlobStream := FStoreTable.
            CreateBlobStream(FStoreTable.FieldByName(F_Settings) as TBlobField, bmWrite) as TBlobStream;

          try
            BlobStream.Seek(0, soFromBeginning);
            BlobStream.Truncate;

            with FGrid as TmmDBGrid do
            begin
              // У С Л О В Н О Е  Ф О Р М А Т ИР О В А Н И Е

              BlobStream.Write(Conditions.Count, SizeOf(Integer));

              for I := 0 to Conditions.Count - 1 do
              begin
                CurrCondition := Conditions[I];

                BlobStream.Write(CurrCondition.Color, SizeOf(TColor));
                BlobStream.Write(CurrCondition.UseColor, SizeOf(Boolean));

                BlobStream.Write(CurrCondition.Font.Color, SizeOf(TColor));

                ASize := CurrCondition.Font.Size;
                BlobStream.Write(ASize, SizeOf(Integer));

                WriteString(FontStyleToStr(CurrCondition.Font.Style));
                WriteString(CurrCondition.Font.Name);
                BlobStream.Write(CurrCondition.UseFont, SizeOf(Boolean));

                WriteString(CurrCondition.Condition1);
                WriteString(CurrCondition.Condition2);

                BlobStream.Write(CurrCondition.Operation, SizeOf(TConditionOperation));
                BlobStream.Write(CurrCondition.Formula, SizeOf(Boolean));

                WriteString(CurrCondition.FieldName);
                WriteString(CurrCondition.DisplayFields.Text);
              end;

              WriteString(LineFields.Text);
            end;
          finally
            BlobStream.Free;
          end;
        end;
      end;
    end;

    if FStoreTable.State in [dsEdit, dsInsert] then FStoreTable.Post;
  end;
end;

{
  Перед открытием таблицы производим считывание параметров.
}

procedure TRunTimeStore.DoAfterOpen(DataSet: TDataSet);
var
  I: Integer;
  CurrStore: TCachedStore;
begin                                
  if Assigned(OldAfterOpen) then OldAfterOpen(DataSet);
  if Assigned(FRTS.FOnCustomGrid) then FRTS.FOnCustomGrid(FRTS);

  if not FFullLoad then
  begin
    if FStoreKey >= 0 then
    begin
      if not FRTS.FStoreTable.Active then FRTS.OpenStoreTable(True);
      ReadSettings;
      FRTS.CloseStoreTable;
    end else // Если такие данные в таблице не содержаться, то добавляем их сами
    begin
      // Добавляем поля, по которым еще не были сохранены данные
      for I := 0 to FDataSet.FieldCount - 1 do
        if not FindCache(FFullStores, FDataSet.Fields[I].FieldName, CurrStore) then
        begin
          CurrStore := TCachedStore.Create(True);
          CurrStore.FFieldName := FDataSet.Fields[I].FieldName;
          FFullStores.Add(CurrStore);
        end;

      FFullLoad := True;
    end;
  end;  

  ReadCache(FFastCachedStores, False);
end;

{
  Перед закрытием таблицы производим запись параметров.
}

procedure TRunTimeStore.DoBeforeClose(DataSet: TDataSet);
begin
  if Assigned(OldBeforeClose) then OldBeforeClose(DataSet);

  SaveCache(FFastCachedStores, False);
end;

{
  Считывает данные из Cache.
}

procedure TRunTimeStore.ReadCache(Cache: TExList; All: Boolean);
var
  I: Integer;
  C: TColumn;
  OldScaleColumn: Boolean;

  function SortItems(Item1, Item2: Integer): Integer;
  begin
    if TCachedStore(Item1).FFieldOrder > TCachedStore(Item2).FFieldOrder then
      Result := 1
    else if TCachedStore(Item1).FFieldOrder < TCachedStore(Item2).FFieldOrder then
      Result := -1
    else
      Result := 0;
  end;

begin
  FDataSet.DisableControls;

  C := nil;
  Cache.Sort(@SortItems);

  if (FGrid <> nil) and (FGrid is TmmDBGrid) then
  begin
    OldScaleColumn := (FGrid as TmmDBGrid).ScaleColumns;
    (FGrid as TmmDBGrid).ScaleColumns := False;
  end else
    OldScaleColumn := False;

  for I := 0 to Cache.Count - 1 do
  with TCachedStore(Cache[I]) do
  begin
    // Если кэш пуст, то пропускаем его
    if (All and FClear) or (FDataSet.FindField(FFieldName) = nil) then Continue;

    // Если существует колонка
    if (FGrid <> nil) and FindColumn(FGrid, FDataSet.FieldByName(FFieldName), C) then
    begin
      FGrid.Columns.BeginUpdate;
      C.Title.Font.Color := FTitleFont.Color;
      if Assigned(TranslateBase) then
        C.Title.Font.Charset := TranslateBase.CharSet;

      if FTitleFont.Size <= 0 then
        C.Title.Font.Size := 8
      else
        C.Title.Font.Size := FTitleFont.Size;

      C.Title.Font.Style := FTitleFont.Style;
      C.Title.Font.Name := FTitleFont.Name;
      C.Title.Alignment := FTitleAlignment;
      C.Title.Color := FTitleColor;

      C.Font.Color := FFont.Color;
      if Assigned(TranslateBase) then
        C.Font.Charset := TranslateBase.CharSet;

      if FFont.Size <= 0 then
        C.Font.Size := 8
      else
        C.Font.Size := FFont.Size;

      C.Font.Style := FFont.Style;
      C.Font.Name := FFont.Name;
      C.Color := FColor;
      FGrid.Columns.EndUpdate;
    end;

    // Если поля создаются по умолчанию
    if DataSet.DefaultFields or IsTree or IsTreeEx or All then
    begin
      FDataSet.FieldByName(FFieldName).Index := FFieldOrder;
      FDataSet.FieldByName(FFieldName).DisplayLabel := FDisplayLabel;

      if FDataSet.FieldByName(FFieldName) is TNumericField then
        (FDataSet.FieldByName(FFieldName) as TNumericField).DisplayFormat := FDisplayFormat
      else if FDataSet.FieldByName(FFieldName) is TDateTimeField then
        (FDataSet.FieldByName(FFieldName) as TDateTimeField).DisplayFormat := FDisplayFormat;

      FDataSet.FieldByName(FFieldName).Alignment := FAlignment;
      FDataSet.FieldByName(FFieldName).EditMask := FEditMask;

      FDataSet.FieldByName(FFieldName).Visible := FVisible;

      if FDisplayWidth > 0 then
        FDataSet.FieldByName(FFieldName).DisplayWidth := FDisplayWidth;

      if (FGrid <> nil) and (FGrid is TmmDBGrid) and FindColumn(FGrid, FDataSet.FieldByName(FFieldName), C)
        and (C.Width <> C.DefaultWidth)
      then
        C.Width := C.DefaultWidth;

    end;
  end;

  if (FGrid <> nil) and (FGrid is TmmDBGrid) then
    (FGrid as TmmDBGrid).ScaleColumns := OldScaleColumn;
    
  FDataSet.EnableControls;
end;

{
  Записывает данные в Cache.
}

procedure TRunTimeStore.SaveCache(Cache: TExList; All: Boolean);
var
  C: TColumn;
  I: Integer;
  CS: TCachedStore;
begin
  for I := 0 to FDataSet.FieldCount - 1 do
  begin
    if not FindCache(Cache, FDataSet.Fields[I].FieldName, CS) then
    begin
      CS := TCachedStore.Create(False);
      Cache.Add(CS);
    end;

    with CS Do
    begin
      FFieldName := FDataSet.Fields[I].FieldName;

      // Если найдена колонка
      if (FGrid <> nil) and FindColumn(FGrid, FDataSet.Fields[I], C) then
      begin
        FTitleFont.Color := C.Title.Font.Color;
        FTitleFont.Size := C.Title.Font.Size;
        FTitleFont.Style := C.Title.Font.Style;
        FTitleFont.Name := C.Title.Font.Name;
        FTitleAlignment := C.Title.Alignment;
        FTitleColor := C.Title.Color;

        FFont.Color := C.Font.Color;
        FFont.Size := C.Font.Size;
        FFont.Style := C.Font.Style;
        FFont.Name := C.Font.Name;
        FColor := C.Color;

        FWorkWithColumn := True;
      end;

      // Если колонки создаются по умолчанию
      if DataSet.DefaultFields or IsTree or IsTreeEx or All then
      begin
        FFieldOrder := FDataSet.Fields[I].Index;
        FVisible := FDataSet.Fields[I].Visible;
        FDisplayLabel := FDataSet.Fields[I].DisplayLabel;
        FDisplayWidth := FDataSet.Fields[I].DisplayWidth;

        if FDataSet.Fields[I] is TNumericField then
          FDisplayFormat := (FDataSet.Fields[I] as TNumericField).DisplayFormat
        else if FDataSet.Fields[I] is TDateTimeField then
          FDisplayFormat := (FDataSet.Fields[I] as TDateTimeField).DisplayFormat
        else
          FDisplayFormat := '';

        FAlignment := FDataSet.Fields[I].Alignment;
        FEditMask := FDataSet.Fields[I].EditMask;
      end;
    end;
  end;
end;

{
  Устаналтвает компоненту данных и делает соответствующие действия.
}

procedure TRunTimeStore.SetDataSet(const Value: TDataSet);
begin
  if FDataSet <> nil then
  begin
    if Assigned(OldAfterOpen) then FDataSet.AfterOpen := OldAfterOpen;
    if Assigned(OldBeforeClose) then FDataSet.BeforeClose := OldBeforeClose;
    OldAfterOpen := nil;
    OldBeforeClose := nil;
  end;

  FDataSet := Value;

  // Event-ы открытия и закрытия таблицы: получаем их и сохраняем старые
  if FDataSet <> nil then
  begin
    if Assigned(FDataSet.AfterOpen) then
      OldAfterOpen := FDataSet.AfterOpen;

    FDataSet.AfterOpen := DoAfterOpen;

    if Assigned(FDataSet.BeforeClose) then
      OldBeforeClose := FDataSet.BeforeClose;
      
    FDataSet.BeforeClose := DoBeforeClose;
  end;
end;

{
  Вовзращает наименование таблицы.
}

function TRunTimeStore.GetTableName: String;
var
  D: TDataSet;
begin
  // Если обычное дерево
  if
    (FGrid <> nil)
      and
    IsTree
  then begin
    if
      (FGrid.DataSource <> nil)
        and
      ((FGrid as TmmDBGridTree).DataSource.DataSet <> nil)
    then begin
      D := (FGrid as TmmDBGridTree).DataSource.DataSet;

      if D is TTable then
        Result := (D as TTable).TableName
      else
        Result := D.Name;
    // Если дерево через пользовательские события    
    end else if (FGrid as TmmDBGridTree).IsCustomTree then
    begin
      Result := FGrid.Name;
    end;
  // Если продвинутое дерево
  end else if (FGrid <> nil) and (FGrid is TmmDBGridTreeEx) then
  begin
    Result := FGrid.Name;
  // Если lookup combo через store-процедуры
  end else if (FGrid <> nil) and (FGrid is TxLookupGridStored) then
  begin
    Result := (FGrid.Parent as TxDBLookupCombo2).Name;
  // В любом другом случае
  end else if FDataSet <> nil then
  begin
    if FDataSet is TTable then
      Result := (FDataSet as TTable).TableName
    else if (FDataSet is TQuery) or (FDataSet is TClientDataSet) then
      Result := FDataSet.Name;
  end else
    Result := '';
end;

{
  Является данный DataSet таблицой данных.
}

function TRunTimeStore.GetIsTable: Boolean;
begin
  Result := (FDataSet <> nil) and (FDataSet is TTable);
end;

{
  Является ли Grid деревом.
}

function TRunTimeStore.GetIsTree: Boolean;
begin
  Result := (FGrid <> nil) and (FGrid is TmmDBGridTree);
end;

{
  Является ли Grid продвинутым деревом.
}


function TRunTimeStore.GetIsTreeEx: Boolean;
begin
  Result := (FGrid <> nil) and (FGrid is TmmDBGridTreeEx);
end;

{
  ---------------------------
  ---                     ---
  ---   TmmRunTimeStore   ---
  ---                     ---
  ---------------------------
}


{
  ***********************
  ***   Public Part   ***
  ***********************
}


{
  Делаем начальные установки.
}

constructor TmmRunTimeStore.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  // По умолчанию таблицу ставим fin_store
  FTableName := 'fin_rts';
  FTableFieldName := 'fin_rtsfield';

  // Делаем установки по умолчанию
  FContext := DefContext;
  FEnabled := True;
  FUserKey := DefUserKey;
  FUseUserLogin := True;
  FDatabaseName := 'xxx';

  FTables := TStringList.Create;
  FQueries := TStringList.Create;

  FStores := TExList.Create;
  
  FOnCustomGrid := nil;

  if not (csDesigning in ComponentState) then
  begin
    FStoreTable := TTable.Create(Self);
    FStoreFields := TTable.Create(Self);
    FFindQuery := TQuery.Create(Self);
    FStoreProc := TStoredProc.Create(Self);
  end;  
end;

{
  Высвобождаем память.
}

destructor TmmRunTimeStore.Destroy;
begin
  FTables.Free;
  FQueries.Free;

  FStores.Free;

  inherited Destroy;      
end;

{
  Добавляет grid в установки. Если невозможно произвести связь автоматически (при DataModule).
}

procedure TmmRunTimeStore.AddGridToStore(TableName: String; G: TDBGrid);
var
  I: Integer;
begin
  for I := 0 to FStores.Count - 1 do
   if AnsiCompareText(TRunTimeStore(FStores[I]).TableName, TableName) = 0 then
   begin
     TRunTimeStore(FStores[I]).Grid := G;
     Break;
   end;
end;

{
  Производит считывание нулевых установок.
}

procedure TmmRunTimeStore.ReadDefaultSettings(TableName: String);
var
  I, K: Integer;
  CurrStore: TRunTimeStore;
  FindStore: TStoredProc;
begin
  if FindStoreByName(TableName, I) then
  begin
    CurrStore := FStores[I];

    // Удаляем старые данные
    if ((FUserKey <> -1) or (FContext <> -1)) and CurrStore.FExists then
    begin
      OpenStoreTable(False);

      for K := 0 to CurrStore.FFullStores.Count - 1 do
        if (TCachedStore(CurrStore.FFullStores[K]).FFieldKey >= 0) and
          FStoreFields.FindKey([TCachedStore(CurrStore.FFullStores[K]).FFieldKey])
        then
          FStoreFields.Delete;

      if FStoreTable.FindKey([CurrStore.FStoreKey]) then
        FStoreTable.Delete;

      CloseStoreTable;
    end;

    CurrStore.ClearData;

    // Загружаем новые
    FindStore := TStoredProc.Create(Self);
    try
      FindStore.DatabaseName := FDatabaseName;
      FindStore.Prepare;

      FindStore.ParamByName('AnUserKey').AsInteger := -1;
      FindStore.ParamByName('AContext').AsInteger := -1;
      FindStore.ParamByName('ATableName').AsString := CurrStore.TableName;
      FindStore.ExecProc;

      CurrStore.StoreKey := FindStore.ParamByName('TheStoreKey').AsInteger;
      CurrStore.Exists := Boolean(FindStore.ParamByName('Exist').AsInteger);
    finally
      FindStore.Free;
    end;

    OpenStoreTable(True);
    CurrStore.ReadData;
    CloseStoreTable;
  end;
end;

{
  Считывает все начальные установки. 
}

procedure TmmRunTimeStore.ReadAllDefaults;
var
  I: Integer;
begin
  for I := 0 to FTables.Count - 1 do
    ReadDefaultSettings(FTables[I]);

  for I := 0 to FQueries.Count - 1 do
    ReadDefaultSettings(FQueries[I]);
end;

{
  **************************
  ***   Protected Part   ***
  **************************
}


{
  Загружаются свойства компоненты.
}

procedure TmmRunTimeStore.Loaded;
begin
  inherited Loaded;

  if not Enabled then Exit;

  // Если используем компоненту TUserLogin
  if FUseUserLogin and (CurrentUser <> nil) and not (csDesigning in ComponentState) then
    FUserKey := CurrentUser.UserKey;

  if not (csDesigning in ComponentState) then
  begin
    if Owner is TForm then
    begin
      OldOnCreateForm := (Owner as TForm).OnCreate;
      (Owner as TForm).OnCreate := DoOnCreateForm;

      OldOnDestroyForm := (Owner as TForm).OnDestroy;
      (Owner as TForm).OnDestroy := DoOnDestroyForm;
    end else if Owner is TDataModule then
    begin
      OldOnCreateForm := (Owner as TDataModule).OnCreate;
      (Owner as TDataModule).OnCreate := DoOnCreateForm;

      OldOnDestroyForm := (Owner as TDataModule).OnDestroy;
      (Owner as TDataModule).OnDestroy := DoOnDestroyForm;
    end;
  end;  
end;


{
  ************************
  ***   Private Part   ***
  ************************
}


{
  По созданию формы производим свой действия.
}

procedure TmmRunTimeStore.DoOnCreateForm(Sender: TObject);
var
  I, K, M: Integer;
  D: TDataSet;
  C: TComponent;
  Store: TRunTimeStore;

  // Есть ли дупликаты в базе
  function HasDuplicates(ADataSet: TDataSet; var Index: Integer): Boolean;
  var
    L: Integer;
  begin
    Result := False;
    Index := -1;
    if ADataSet = nil then Exit;

    for L := 0 to FStores.Count - 1 do
      if (TRunTimeStore(FStores[L]).FDataSet is TTable) and (ADataSet is TTable) and
        ((TRunTimeStore(FStores[L]).FDataSet as TTable).TableName = (ADataSet as TTable).TableName) then
      begin
        Result := True;
        Index := L;
        Break;
      end;
  end;

  // Есть ли ассоциируемые источники данных
  function HasAssociatedDataSource(ADataSet: TDataSet): Boolean;
  var
    L: Integer;
  begin
    Result := False;
    if ADataSet = nil then Exit;

    for L := 0 to Owner.ComponentCount - 1 do
      if (Owner.Components[L] is TDataSource) and
        ((Owner.Components[L] as TDataSource).DataSet = ADataSet) then
      begin
        Result := True;
        Break;
      end;
  end;

begin
  if Assigned(OldOnCreateForm) then OldOnCreateForm(Sender);

  // Удаляем пустые строчки
  for I := FTables.Count - 1 downto 0 do
    if (FTables[I] = '') or (FTables[I] = ' ') then FTables.Delete(I);

  // Удаляем пустые строчки
  for I := FQueries.Count - 1 downto 0 do
    if (FQueries[I] = '') or (FQueries[I] = ' ') then FQueries.Delete(I);

  // Производим поиск таблиц
  for I := 0 to FTables.Count - 1 do
    for K := 0 to Owner.ComponentCount - 1 do
      if (Owner.Components[K] is TTable) and
        (AnsiCompareText((Owner.Components[K] as TTable).TableName, FTables[I]) = 0) then
      with Owner do
      begin
        D := Components[K] as TDataSet;

        if D <> nil then
        begin
          if HasDuplicates(D, M) then
          begin
            if not HasAssociatedDataSource(D) then
              Continue
            else begin
              TRunTimeStore(FStores[M]).DataSet := D;
            end;
          end else begin
            Store := TRunTimeStore.Create(Self);
            Store.DataSet := D;
            FStores.Add(Store);
          end;
        end;
      end;

  // Производим поиск запросов и др.
  for I := 0 to FQueries.Count - 1 do
    with Owner as TComponent do
    begin
      C := FindComponent(FQueries[I]);

      if C is TDataSet then
      begin
        D := C as TDataSet;

        if D <> nil then
        begin
          Store := TRunTimeStore.Create(Self);
          Store.DataSet := D;
          FStores.Add(Store);
        end;
      end else if C is TmmDBGridTreeEx then
      begin
        Store := TRunTimeStore.Create(Self);
        Store.DataSet := (C as TmmDBGridTreeEx).Tree;
        Store.Grid := (C as TDBGrid);
        FStores.Add(Store);
      end else if C is TxDBLookupCombo2 then
      begin
        Store := TRunTimeStore.Create(Self);
        Store.DataSet := (C as TxDBLookupCombo2).LookupQuery;
        Store.Grid := (C as TxDBLookupCombo2).LookupGrid;
        FStores.Add(Store);
      end else if C is TmmDBGridTree then
      begin
        Store := TRunTimeStore.Create(Self);
        Store.DataSet := (C as TmmDBGridTree).Tree;
        Store.Grid := (C as TDBGrid);
        FStores.Add(Store);
      end;
    end;

  // Производим ассоциацию Grid-ов
  AssociateGrids;

  // Считываем данные
  ReadStoreKeys;

  if Assigned(FOnCustomGrid) then FOnCustomGrid(Self);

  // Производим загрузку данных
  OpenStoreTable(True);
  for I := 0 to FStores.Count - 1 do TRunTimeStore(FStores[I]).ReadData;
  CloseStoreTable;
end;

{
  По уничтожению формы производим запись данных.
}

procedure TmmRunTimeStore.DoOnDestroyForm(Sender: TObject);
var
  I: Integer;
begin
  if Assigned(OldOnDestroyForm) then OldOnDestroyForm(Sender);

  // Производим запись данных
//  OpenStoreTable(False);
  for I := 0 to FStores.Count - 1 do TRunTimeStore(FStores[I]).SaveData;
  CloseStoreTable;
end;

{
  Производит открытие таблицы для сохранения данных.
}

procedure TmmRunTimeStore.OpenStoreTable(Reading: Boolean);
begin
  try
    FStoreTable.DatabaseName := FDatabaseName;
    FStoreTable.TableName := FTableName;
    FStoreTable.IndexFieldNames := F_StoreKey;
    FStoreTable.Open;

    FStoreFields.DatabaseName := FDatabaseName;
    FStoreFields.TableName := FTableFieldName;

    if Reading then // При считывании данных
      FStoreFields.IndexFieldNames := FF_StoreKey
    else // При их записи
      FStoreFields.IndexFieldNames := FF_FieldKey;

    FStoreFields.Open;

    FStoreProc.Close;
    FStoreProc.DatabaseName := FDatabaseName;
    FStoreProc.StoredProcName := SP_STOREKEY;
  except
    raise EDatabaseError.Create('Таблица настроек не найдена!');
  end;
end;

{
  Закрывает таблицы данных для сохранения настроек.
}

procedure TmmRunTimeStore.CloseStoreTable;
begin
  FStoreFields.Close;
  FStoreTable.Close;
end;

{
  Производит считывание информации в память по выборке.
}

procedure TmmRunTimeStore.ReadStoreKeys;
var
  I: Integer;
  CurrStore: TRunTimeStore;
  FindStore: TStoredProc;
begin
  FindStore := TStoredProc.Create(Self);
  try
    FindStore.DatabaseName := FDatabaseName;
    FindStore.StoredProcName := 'fin_p_rts_findstore';
    FindStore.Prepare;

    for I := 0 to FStores.Count - 1 do
    begin
      CurrStore := FStores[I];
      FindStore.ParamByName('AnUserKey').AsInteger := FUserKey;
      FindStore.ParamByName('AContext').AsInteger := FContext;
      FindStore.ParamByName('ATableName').AsString := CurrStore.TableName;
      FindStore.ExecProc;

      if FindStore.ParamByName('TheStoreKey').IsNull then
        CurrStore.StoreKey := -1
      else
        CurrStore.StoreKey := FindStore.ParamByName('TheStoreKey').AsInteger;

      CurrStore.Exists := Boolean(FindStore.ParamByName('Exist').AsInteger);
    end;

  finally
    FindStore.Free;
  end;
end;

{
  Получаем список таблиц.
}

procedure TmmRunTimeStore.SetTables(const Value: TStringList);
begin
  FTables.Assign(Value);
end;

{
  Производим поиск ассоциируемых Grid-ов.
}

procedure TmmRunTimeStore.AssociateGrids;
var
  I: Integer;
  Grid: TDBGrid;

  // Производит поиск grid-ов с указанными таблицами или др. данными
  function FindGrid(TableCompName: String; var FoundGrid: TDBGrid): Boolean;
  var
    K: Integer;
    C: TComponent;
  begin
    Result := False;

    for K := 0 to (Owner as TComponent).ComponentCount - 1 do
    begin
      C := (Owner as TComponent).Components[K];

      if (C is TxDBLookupCombo) then
        C := (C as TxDBLookupCombo).LookupGrid;

      if (C <> nil) and (C is TDBGrid) then
      begin
        if (C is TmmDBGridTree) and ((C as TmmDBGridTree).DataSource <> nil) and
          ((C as TmmDBGridTree).DataSource.DataSet <> nil) and
          (AnsiCompareText((C as TmmDBGridTree).DataSource.DataSet.Name, TableCompName) = 0) then
        begin
          Result := True;
          FoundGrid := C as TDBGrid;
          Break;
        end else if ((C as TDBGrid).DataSource <> nil) and
          ((C as TDBGrid).DataSource.DataSet <> nil) and
          (AnsiCompareText((C as TDBGrid).DataSource.DataSet.Name, TableCompName) = 0) then
        begin
          Result := True;
          FoundGrid := C as TDBGrid;
          Break;
        end;
      end;  
    end;
  end;

begin
  for I := 0 to FStores.Count - 1 do
    if (TRunTimeStore(FStores[I]).DataSet.Name <> '')
      and FindGrid(TRunTimeStore(FStores[I]).DataSet.Name, Grid) then
    begin
      // На случай, если у нас дерево
      if Grid is TmmDBGridTree then
        TRunTimeStore(FStores[I]).DataSet := Grid.DataSource.DataSet;

      TRunTimeStore(FStores[I]).Grid := Grid;
    end;
end;

{
  Получаем список запросов.
}

procedure TmmRunTimeStore.SetQueries(const Value: TStringList);
begin
  FQueries.Assign(Value);
end;

{
  Возвращает флаг состояния таблицы (открыта она или нет). 
}

function TmmRunTimeStore.GetActiveStoreTable: Boolean;
begin
  if FStoreTable <> nil then
    Result := FStoreTable.Active
   else
     Result := False;
end;

{
  Производит поиск необходимой записи по названию таблицы.
}

function TmmRunTimeStore.FindStoreByName(ATableName: String; var Index: Integer): Boolean;
var
  I: Integer;
begin
  Index := -1;
  Result := False;

  for I := 0 to FStores.Count - 1 do
    if AnsiCompareText(TRunTimeStore(FStores[I]).TableName, ATableName) = 0 then
    begin
      Result := True;
      Index := I;
      Break;
    end;
end;

end.

