
{++

  Copyright (c) 1999 by Golden Software of Belarus

  Module

    mmDBSearch.pas

  Abstract

    Search in DataBase tables, queries which are connected to dbgrids and other...

  Author

    Romanovski Denis (15-04-99)

  Revisions history

    15.04.1999     Dennis      Initial version. Remaking component on the basis of TDBSearchField.

    19.04.1999     Dennis      Beta 1. Everything works.

--}

unit mmDBSearch;

interface

uses
  Windows,        Messages,       SysUtils,       Classes,        Graphics,
  Controls,       Forms,          Dialogs,        DBGrids,        DB,
  DBCtrls,        mmDBFindDlg;

type
  TSearchDirection = (sdUp, sdDown, sdAll);

  TSearchOption = (soCaseSensitive, soWholeWordsOnly, soWholeFieldOnly);
  TSearchOptions = set of TSearchOption;

  TOnCustomSearchEvent = procedure (Sender: TObject; Text: String; var Custom, Found: Boolean) of object;

type
  TmmDBSearch = class(TComponent)
  private
    FGrid: TDBGrid; // DBGrid, в котором будет произвлдиться поиск
    FSearchOptions: TSearchOptions; // Параметры поиска в DBgrid-е
    FSearchDirection: TSearchDirection; // Вид поиска
    FColorDialog: TColor; // Цвет диалога
    FSearchDataLink: TFieldDataLink; // Класс связи с DataSet-ом, где будет производиться поиск
    FCustomSearch: Boolean; // Поиск определяется поьлзователем компоненты
    FOnCustomSearch: TOnCustomSearchEvent; // Событие по пользовательскому поиску

    DBFindDlg: TfrmDBFindDlg; // Диалог ввода параметров поиска
    SearchText: String; // Текст, поиск которого будет производиться
    UseDoubleValue: Boolean; // Использовать ли числовое значение для сравнения
    SearchDouble: Double; // Если искомое значение является числом или датой

    procedure StartSearch(Sender: TObject);
    procedure EndSearch(Sender: TObject);
    procedure CloseDialog(Sender: TObject; var Active: TCloseAction);

    procedure PrepareValue;
    function FindValue: Boolean;
    function CompareCurrValues: Boolean;

    function GetDataField: String;
    function GetDataSource: TDataSource;

    procedure SetDataField(const Value: String);
    procedure SetDataSource(const Value: TDataSource);

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure ExecuteDialog;

  published
    // Определяется ли поиск самим пользователем компоненты (или определеяется автоматически)
    property CustomSearch: Boolean read FCustomSearch write FCustomSearch;
    // Поле, по которому будет производиться поиск
    property DataField: String read GetDataField write SetDataField;
    // исчтоник данных, в по которому будет производиться поиск
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    // DBGrid, в котором будет производиться поиск
    property Grid: TDBGrid read FGrid write FGrid;
    // Параметры поиска в DBgrid-е
    property SearchOptions: TSearchOptions read FSearchOptions write FSearchOptions;
    // Вид поиска (назад, вперед, везде (т.е. с начала)
    property SearchDirection: TSearchDirection read FSearchDirection write FSearchDirection;
    // Цвет диалога
    property ColorDialog: TColor read FColorDialog write FColorDialog;
    // Событие по пользовательскому поиску
    property OnCustomSearch: TOnCustomSearchEvent read FOnCustomSearch write FOnCustomSearch;

  end;

implementation

uses mmDBGrid, mmDBGridTree, xAppReg, gsMultilingualSupport;

{
  ***********************
  ***   Public Part   ***
  ***********************
}


{
  Делаем начальные установки.
}

constructor TmmDBSearch.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  // Начальные установки
  FGrid := nil;
  FSearchOptions := [];
  FSearchDirection := sdAll; 
  FColorDialog := $00E8F3F7;
  FOnCustomSearch := nil;

  DBFindDlg := nil;
  SearchText := '';
  SearchDouble := 0;
  UseDoubleValue := False;

  // Создаем класс работы с полем таблицы
  FSearchDataLink := TFieldDataLink.Create;
  FSearchDataLink.FieldName := '';
  FSearchDataLink.DataSource := nil;

  // Создаем диалоговое окно
  if not (csDesigning in ComponentState) then
  begin
    DBFindDlg := TfrmDBFindDlg.Create(Self);
    DBFindDlg.btnFind.OnClick := StartSearch;
    DBFindDlg.btnCancel.OnClick := EndSearch;
    DBFindDlg.OnClose := CloseDialog;
  end;
end;
                        
{
  Высвобождаем память.
}                           

destructor TmmDBSearch.Destroy;
begin
  // Прячем диалог, если он еще активирован
  if (DBFindDlg <> nil) and DBFindDlg.Visible then DBFindDlg.Hide;

  // Удаляем из памяти компоненту работы с полем
  if FSearchDataLink <> nil then
  begin
    FSearchDataLink.Free;
    FSearchDataLink := nil;
  end;

  inherited Destroy;
end;

{
  Производит активацию диалогового окна поиска для считывания параметров поиска.
}

procedure TmmDBSearch.ExecuteDialog;
begin
  // Необходимо для работы обязательно получить DBGrid
  if not CustomSearch then
  begin
    if (Owner as TForm).ActiveControl is TDBGrid then
    begin
      FGrid := (Owner as TForm).ActiveControl as TDBGrid;

      // Если работаем с деревом, то получаем исчтоник данных иначе
      if (FGrid is TmmDBGridTree) then
        DataSource := (FGrid as TmmDBGridTree).DataSource
      else
        DataSource := FGrid.DataSource;

      DataField := FGrid.SelectedField.FieldName;
    end else
      FGrid := nil;
  // В любом случае, если установлена таблица, то присваиваем поле
  end else if (DataField = '') and Assigned(FGrid) and Assigned(FGrid.SelectedField) then
  begin
    DataField := FGrid.SelectedField.FieldName;
  end;

  // Активация диалога, если есть активное поле
  if not CustomSearch and ((FGrid = nil) or ((FGrid <> nil) and (FGrid.SelectedField = nil))) then
    MessageDlg(TranslateText('Курсор должен быть установлен на одно из полей таблицы.'),
      mtWarning, [mbOk], 0)
  else if (CustomSearch and Assigned(DataSource) and Assigned(DataSource.DataSet.FindField(DataField)))
    or not CustomSearch
  then
    with DBFindDlg do
    begin
      Caption := TranslateText('Поиск по колонке') + ' "' + FSearchDataLink.Field.DisplayLabel + '"';
      Color := FColorDialog;

      btnFind.Enabled := True;
      btnFind.Caption := '&Поиск';

      btnCancel.Enabled := True;
      btnCancel.Caption := '&Закрыть';

      rgDirection.Enabled := True;
      gbParameters.Enabled := True;
      gbFind.Enabled := True;
      antFind.Active := False;

      // Делаем установки в диалоге
      cbMatchCase.Checked := (soCaseSensitive in FSearchOptions);
      cbWholeField.Checked := (soWholeFieldOnly in FSearchOptions);
      rgDirection.ItemIndex := 2;

      comboSearchText.Items.Text := AppRegistry.ReadString('Search_Settings', 'SearchValues', '');
      comboSearchText.Text := '';
      ActiveControl := comboSearchText;

      Show;
    end;
end;

{
  **************************
  ***   Protected Part   ***
  **************************
}

{
  Ставим указатели на nil после их удаления.
}

procedure TmmDBSearch.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if Operation = opRemove then
  begin
    if AComponent = DataSource then
    begin
      DataField := '';
      DataSource := nil;
    end else if AComponent = FGrid then
      FGrid := nil;
  end;
end;

{
  ************************
  ***   Private Part   ***
  ************************
}

{
  Производит активацию поиска.
}

procedure TmmDBSearch.StartSearch(Sender: TObject);
var
  Found: Boolean;
  Custom: Boolean;
begin
  // Определяем параметры поиска
  with DBFindDlg do
  begin
    btnFind.Enabled := False;
    btnCancel.Enabled := False;

    antFind.Active := True;

    Application.ProcessMessages;

    // Добавляем текст в список ранее производимых поисковых команд
    if (comboSearchText.Items.Count = 0) or (comboSearchText.Text <> comboSearchText.Items[0])then
      comboSearchText.Items.Insert(0, comboSearchText.Text);

    // Производим установки поиска
    FSearchOptions := [];
    if cbMatchCase.Checked then
      FSearchOptions := FSearchOptions + [soCaseSensitive]
    else
      FSearchOptions := FSearchOptions - [soCaseSensitive];

    if cbWholeField.Checked then
      FSearchOptions := FSearchOptions + [soWholeFieldOnly]
    else
      FSearchOptions := FSearchOptions - [soWholeFieldOnly];

    case rgDirection.ItemIndex of
      0: FSearchDirection := sdDown;
      1: FSearchDirection := sdUp;
      2: FSearchDirection := sdAll;
    end;

    SearchText := comboSearchText.Text;
  end;

  // Если работаем с деревом, то необходимо перейти на соотв. запись
  if (FGrid <> nil) and (FGrid is TmmDBGridTree) then
    (FGrid as TmmDBGridTree).DataSource.DataSet.Locate(
      (FGrid as TmmDBGridTree).FieldKey,
      FGrid.DataSource.DataSet.FieldByName((FGrid as TmmDBGridTree).FieldKey).AsInteger,
      []);

  Found := False;
  Custom := False;

  if Assigned(FOnCustomSearch) then
    FOnCustomSearch(Self, SearchText, Custom, Found);

  if not Custom then
    Found := FindValue;

  with DBFindDlg do
  begin
    btnFind.Enabled := True;
    btnFind.Caption := '&Поиск';

    btnCancel.Enabled := True;
    btnCancel.Caption := '&Закрыть';

    rgDirection.Enabled := True;
    gbParameters.Enabled := True;
    gbFind.Enabled := True;
    antFind.Active := False;
  end;

  Application.ProcessMessages;

  // Если запись не найдена, то необходимо оповестить об этом пользователя
  if not Found then
    MessageDlg(TranslateText('Запись не найдена.'), mtInformation, [mbOk], 0)
  else begin
    // Если было направление поиска "с начала", то необходимо установить режим "вперед"
    if DBFindDlg.rgDirection.ItemIndex = 2 then DBFindDlg.rgDirection.ItemIndex := 0;

    // Если работаем с деревом, то необходимо открыть найденный уровень
    if (FGrid <> nil) and (FGrid is TmmDBGridTree) then
      (FGrid as TmmDBGridTree).
        OpenKey(DataSource.DataSet.FindField((FGrid as TmmDBGridTree).FieldKey).AsInteger);
  end;

  DBFindDlg.ActiveControl := DBFindDlg.comboSearchText;
end;

{
  Останавливает поиск.
}

procedure TmmDBSearch.EndSearch(Sender: TObject);
begin
  DBFindDlg.Close;
end;

{
  По закрытию диалогового окна производим свои действия.
}

procedure TmmDBSearch.CloseDialog(Sender: TObject; var Active: TCloseAction);
var
  I: Integer;
begin
  try
    // Сохраняем ранее вводимые значения (только первые 5)
    for I := 5 to DBFindDlg.comboSearchText.Items.Count - 1 do
      DBFindDlg.comboSearchText.Items.Delete(5);

    AppRegistry.WriteString('Search_Settings', 'SearchValues', DBFindDlg.comboSearchText.Items.Text);
    if FGrid <> nil then FGrid.SetFocus;
  except
    // Необходимо остановить исключение на случай, если Grid является невидимым
  end;  
end;

{
  Производит проверку значения поля на случай сравнения данных числового поля со строкой,
  которую также можно перевести в число.
}

procedure TmmDBSearch.PrepareValue;
var
  T: TFieldType;
  D: Double;
begin
  T := FSearchDataLink.Field.DataType;
  SearchDouble := 0;

  // Если числовые значения
  if T in [ftString, ftSmallint, ftInteger, ftWord, ftFloat, ftCurrency,
    ftAutoInc, ftLargeint] then
  begin
    try
      D := StrToFloat(SearchText);
      SearchDouble := D;
      UseDoubleValue := True;
    except
      UseDoubleValue := False;
    end;
  // Если дата и (или) время
  end else if T in [ftDate, ftTime, ftDateTime] then
  begin
    try
      D := StrToDateTime(SearchText);
      SearchDouble := D;
      UseDoubleValue := True;
    except
      UseDoubleValue := False;
    end;
  end else
    UseDoubleValue := False;
end;

{
  Производит поиск значения.
}

function TmmDBSearch.FindValue: Boolean;
var
   BM: TBookMark;
begin
  Result := False;

  // Производится поиск в ранее определенном поле и по ранее определенным параметрам
  with FSearchDataLink.DataSource do
  begin
    // Если мы производим поиск по "всего поля", то необходимо произвести подготовку
    // значения на случай возможности более быстрого сравнения
    if soWholeFieldOnly in FSearchOptions then PrepareValue;

    // Если поиск производится с начала таблицы
    // Если поиск производится с какой-либо пределенной записи
    BM := DataSet.GetBookmark;
    DataSet.DisableControls;

    if FSearchDirection = sdAll then DataSet.First;

    // Производим поиск
    while ((FSearchDirection in [sdDown, sdAll]) and not DataSet.EOF) or
      ((FSearchDirection = sdUp) and not DataSet.BOF) do
    begin
      // Если происходит поиск, то пропускаем сообщения, если - нет, то останавливаем поиск
      Application.ProcessMessages;

      // Производит сравнение текущих значений поля и поисковых параметров
      if (FSearchDirection = sdAll) and DataSet.BOF and CompareCurrValues then
      begin
        Result := True;
        Break;
      end;

      // Производим переход на следующую запись
      // Далем это специально раньше, чем начинаем поиск
      if FSearchDirection in [sdDown, sdAll] then
        DataSet.Next
      else
        DataSet.Prior;

      // Производит сравнение текущих значений поля и поисковых параметров
      if CompareCurrValues then
      begin
        Result := True;
        Break;
      end;
    end;

    if BM <> nil then
    begin
      // Если запись не была найдена запись, то возвращаемся на старую позицию
      if not Result then DataSet.GotoBookmark(BM);
      DataSet.FreeBookmark(BM);
    end;

    // Возвращает старые параметры
    DataSet.EnableControls;
  end;
end;

{
  Производит сравнение текущих значений поля и поискового значения.
  Если произведена подготовка знечения, то производим сравнение по типу.
}

function TmmDBSearch.CompareCurrValues: Boolean;
begin
  with FSearchDataLink do
  begin
    // Если проихзводим потиповое сравнение
    if UseDoubleValue and (soWholeFieldOnly in FSearchOptions) then
    begin
      Result := DataSource.DataSet.FieldByName(FieldName).AsFloat = SearchDouble;
    end else begin // Если производим сравнение данных, как строк
      // Если целое поле
      if soWholeFieldOnly in FSearchOptions then
        // Регистр учитывается при сравнении по целому полю
        Result := SearchText = DataSource.DataSet.FieldByName(FieldName).DisplayText
      else begin // Если часть поля
        // Если учитывается регистр
        if soCaseSensitive in FSearchOptions then
          Result := AnsiPos(SearchText, DataSource.DataSet.FieldByName(FieldName).DisplayText) > 0
        else // Если регистр не учитывается
          Result := AnsiPos(AnsiUpperCase(SearchText),
            AnsiUpperCase(DataSource.DataSet.FieldByName(FieldName).DisplayText)) > 0;
      end;
    end;
  end;
end;

{
  Возвращает выбранное пользователем поле для поиска
}

function TmmDBSearch.GetDataField: String;
begin
  if FSearchDataLink <> nil then
    Result := FSearchDataLink.FieldName
  else
    Result := '';
end;

{
  Возвращаем установленный пользователем исчтоник данных.
}

function TmmDBSearch.GetDataSource: TDataSource;
begin
  if FSearchDataLink <> nil then
    Result := FSearchDataLink.DataSource
  else
    Result := nil;
end;

{
  Устанавливаем новое выбранное пользователем поле.
}

procedure TmmDBSearch.SetDataField(const Value: String);
begin
  if FSearchDataLink <> nil then
    FSearchDataLink.FieldName := Value
end;

{
  Устанавливаем выбранный пользователем исчтоник данных.
}

procedure TmmDBSearch.SetDataSource(const Value: TDataSource);
begin
  if FSearchDataLink <> nil then
    FSearchDataLink.DataSource := Value;
end;

end.

