
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
    FGrid: TDBGrid; // DBGrid, � ������� ����� ������������� �����
    FSearchOptions: TSearchOptions; // ��������� ������ � DBgrid-�
    FSearchDirection: TSearchDirection; // ��� ������
    FColorDialog: TColor; // ���� �������
    FSearchDataLink: TFieldDataLink; // ����� ����� � DataSet-��, ��� ����� ������������� �����
    FCustomSearch: Boolean; // ����� ������������ ������������� ����������
    FOnCustomSearch: TOnCustomSearchEvent; // ������� �� ����������������� ������

    DBFindDlg: TfrmDBFindDlg; // ������ ����� ���������� ������
    SearchText: String; // �����, ����� �������� ����� �������������
    UseDoubleValue: Boolean; // ������������ �� �������� �������� ��� ���������
    SearchDouble: Double; // ���� ������� �������� �������� ������ ��� �����

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
    // ������������ �� ����� ����� ������������� ���������� (��� ������������� �������������)
    property CustomSearch: Boolean read FCustomSearch write FCustomSearch;
    // ����, �� �������� ����� ������������� �����
    property DataField: String read GetDataField write SetDataField;
    // �������� ������, � �� �������� ����� ������������� �����
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    // DBGrid, � ������� ����� ������������� �����
    property Grid: TDBGrid read FGrid write FGrid;
    // ��������� ������ � DBgrid-�
    property SearchOptions: TSearchOptions read FSearchOptions write FSearchOptions;
    // ��� ������ (�����, ������, ����� (�.�. � ������)
    property SearchDirection: TSearchDirection read FSearchDirection write FSearchDirection;
    // ���� �������
    property ColorDialog: TColor read FColorDialog write FColorDialog;
    // ������� �� ����������������� ������
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
  ������ ��������� ���������.
}

constructor TmmDBSearch.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  // ��������� ���������
  FGrid := nil;
  FSearchOptions := [];
  FSearchDirection := sdAll; 
  FColorDialog := $00E8F3F7;
  FOnCustomSearch := nil;

  DBFindDlg := nil;
  SearchText := '';
  SearchDouble := 0;
  UseDoubleValue := False;

  // ������� ����� ������ � ����� �������
  FSearchDataLink := TFieldDataLink.Create;
  FSearchDataLink.FieldName := '';
  FSearchDataLink.DataSource := nil;

  // ������� ���������� ����
  if not (csDesigning in ComponentState) then
  begin
    DBFindDlg := TfrmDBFindDlg.Create(Self);
    DBFindDlg.btnFind.OnClick := StartSearch;
    DBFindDlg.btnCancel.OnClick := EndSearch;
    DBFindDlg.OnClose := CloseDialog;
  end;
end;
                        
{
  ������������ ������.
}                           

destructor TmmDBSearch.Destroy;
begin
  // ������ ������, ���� �� ��� �����������
  if (DBFindDlg <> nil) and DBFindDlg.Visible then DBFindDlg.Hide;

  // ������� �� ������ ���������� ������ � �����
  if FSearchDataLink <> nil then
  begin
    FSearchDataLink.Free;
    FSearchDataLink := nil;
  end;

  inherited Destroy;
end;

{
  ���������� ��������� ����������� ���� ������ ��� ���������� ���������� ������.
}

procedure TmmDBSearch.ExecuteDialog;
begin
  // ���������� ��� ������ ����������� �������� DBGrid
  if not CustomSearch then
  begin
    if (Owner as TForm).ActiveControl is TDBGrid then
    begin
      FGrid := (Owner as TForm).ActiveControl as TDBGrid;

      // ���� �������� � �������, �� �������� �������� ������ �����
      if (FGrid is TmmDBGridTree) then
        DataSource := (FGrid as TmmDBGridTree).DataSource
      else
        DataSource := FGrid.DataSource;

      DataField := FGrid.SelectedField.FieldName;
    end else
      FGrid := nil;
  // � ����� ������, ���� ����������� �������, �� ����������� ����
  end else if (DataField = '') and Assigned(FGrid) and Assigned(FGrid.SelectedField) then
  begin
    DataField := FGrid.SelectedField.FieldName;
  end;

  // ��������� �������, ���� ���� �������� ����
  if not CustomSearch and ((FGrid = nil) or ((FGrid <> nil) and (FGrid.SelectedField = nil))) then
    MessageDlg(TranslateText('������ ������ ���� ���������� �� ���� �� ����� �������.'),
      mtWarning, [mbOk], 0)
  else if (CustomSearch and Assigned(DataSource) and Assigned(DataSource.DataSet.FindField(DataField)))
    or not CustomSearch
  then
    with DBFindDlg do
    begin
      Caption := TranslateText('����� �� �������') + ' "' + FSearchDataLink.Field.DisplayLabel + '"';
      Color := FColorDialog;

      btnFind.Enabled := True;
      btnFind.Caption := '&�����';

      btnCancel.Enabled := True;
      btnCancel.Caption := '&�������';

      rgDirection.Enabled := True;
      gbParameters.Enabled := True;
      gbFind.Enabled := True;
      antFind.Active := False;

      // ������ ��������� � �������
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
  ������ ��������� �� nil ����� �� ��������.
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
  ���������� ��������� ������.
}

procedure TmmDBSearch.StartSearch(Sender: TObject);
var
  Found: Boolean;
  Custom: Boolean;
begin
  // ���������� ��������� ������
  with DBFindDlg do
  begin
    btnFind.Enabled := False;
    btnCancel.Enabled := False;

    antFind.Active := True;

    Application.ProcessMessages;

    // ��������� ����� � ������ ����� ������������ ��������� ������
    if (comboSearchText.Items.Count = 0) or (comboSearchText.Text <> comboSearchText.Items[0])then
      comboSearchText.Items.Insert(0, comboSearchText.Text);

    // ���������� ��������� ������
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

  // ���� �������� � �������, �� ���������� ������� �� �����. ������
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
    btnFind.Caption := '&�����';

    btnCancel.Enabled := True;
    btnCancel.Caption := '&�������';

    rgDirection.Enabled := True;
    gbParameters.Enabled := True;
    gbFind.Enabled := True;
    antFind.Active := False;
  end;

  Application.ProcessMessages;

  // ���� ������ �� �������, �� ���������� ���������� �� ���� ������������
  if not Found then
    MessageDlg(TranslateText('������ �� �������.'), mtInformation, [mbOk], 0)
  else begin
    // ���� ���� ����������� ������ "� ������", �� ���������� ���������� ����� "������"
    if DBFindDlg.rgDirection.ItemIndex = 2 then DBFindDlg.rgDirection.ItemIndex := 0;

    // ���� �������� � �������, �� ���������� ������� ��������� �������
    if (FGrid <> nil) and (FGrid is TmmDBGridTree) then
      (FGrid as TmmDBGridTree).
        OpenKey(DataSource.DataSet.FindField((FGrid as TmmDBGridTree).FieldKey).AsInteger);
  end;

  DBFindDlg.ActiveControl := DBFindDlg.comboSearchText;
end;

{
  ������������� �����.
}

procedure TmmDBSearch.EndSearch(Sender: TObject);
begin
  DBFindDlg.Close;
end;

{
  �� �������� ����������� ���� ���������� ���� ��������.
}

procedure TmmDBSearch.CloseDialog(Sender: TObject; var Active: TCloseAction);
var
  I: Integer;
begin
  try
    // ��������� ����� �������� �������� (������ ������ 5)
    for I := 5 to DBFindDlg.comboSearchText.Items.Count - 1 do
      DBFindDlg.comboSearchText.Items.Delete(5);

    AppRegistry.WriteString('Search_Settings', 'SearchValues', DBFindDlg.comboSearchText.Items.Text);
    if FGrid <> nil then FGrid.SetFocus;
  except
    // ���������� ���������� ���������� �� ������, ���� Grid �������� ���������
  end;  
end;

{
  ���������� �������� �������� ���� �� ������ ��������� ������ ��������� ���� �� �������,
  ������� ����� ����� ��������� � �����.
}

procedure TmmDBSearch.PrepareValue;
var
  T: TFieldType;
  D: Double;
begin
  T := FSearchDataLink.Field.DataType;
  SearchDouble := 0;

  // ���� �������� ��������
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
  // ���� ���� � (���) �����
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
  ���������� ����� ��������.
}

function TmmDBSearch.FindValue: Boolean;
var
   BM: TBookMark;
begin
  Result := False;

  // ������������ ����� � ����� ������������ ���� � �� ����� ������������ ����������
  with FSearchDataLink.DataSource do
  begin
    // ���� �� ���������� ����� �� "����� ����", �� ���������� ���������� ����������
    // �������� �� ������ ����������� ����� �������� ���������
    if soWholeFieldOnly in FSearchOptions then PrepareValue;

    // ���� ����� ������������ � ������ �������
    // ���� ����� ������������ � �����-���� ����������� ������
    BM := DataSet.GetBookmark;
    DataSet.DisableControls;

    if FSearchDirection = sdAll then DataSet.First;

    // ���������� �����
    while ((FSearchDirection in [sdDown, sdAll]) and not DataSet.EOF) or
      ((FSearchDirection = sdUp) and not DataSet.BOF) do
    begin
      // ���� ���������� �����, �� ���������� ���������, ���� - ���, �� ������������� �����
      Application.ProcessMessages;

      // ���������� ��������� ������� �������� ���� � ��������� ����������
      if (FSearchDirection = sdAll) and DataSet.BOF and CompareCurrValues then
      begin
        Result := True;
        Break;
      end;

      // ���������� ������� �� ��������� ������
      // ����� ��� ���������� ������, ��� �������� �����
      if FSearchDirection in [sdDown, sdAll] then
        DataSet.Next
      else
        DataSet.Prior;

      // ���������� ��������� ������� �������� ���� � ��������� ����������
      if CompareCurrValues then
      begin
        Result := True;
        Break;
      end;
    end;

    if BM <> nil then
    begin
      // ���� ������ �� ���� ������� ������, �� ������������ �� ������ �������
      if not Result then DataSet.GotoBookmark(BM);
      DataSet.FreeBookmark(BM);
    end;

    // ���������� ������ ���������
    DataSet.EnableControls;
  end;
end;

{
  ���������� ��������� ������� �������� ���� � ���������� ��������.
  ���� ����������� ���������� ��������, �� ���������� ��������� �� ����.
}

function TmmDBSearch.CompareCurrValues: Boolean;
begin
  with FSearchDataLink do
  begin
    // ���� ����������� ��������� ���������
    if UseDoubleValue and (soWholeFieldOnly in FSearchOptions) then
    begin
      Result := DataSource.DataSet.FieldByName(FieldName).AsFloat = SearchDouble;
    end else begin // ���� ���������� ��������� ������, ��� �����
      // ���� ����� ����
      if soWholeFieldOnly in FSearchOptions then
        // ������� ����������� ��� ��������� �� ������ ����
        Result := SearchText = DataSource.DataSet.FieldByName(FieldName).DisplayText
      else begin // ���� ����� ����
        // ���� ����������� �������
        if soCaseSensitive in FSearchOptions then
          Result := AnsiPos(SearchText, DataSource.DataSet.FieldByName(FieldName).DisplayText) > 0
        else // ���� ������� �� �����������
          Result := AnsiPos(AnsiUpperCase(SearchText),
            AnsiUpperCase(DataSource.DataSet.FieldByName(FieldName).DisplayText)) > 0;
      end;
    end;
  end;
end;

{
  ���������� ��������� ������������� ���� ��� ������
}

function TmmDBSearch.GetDataField: String;
begin
  if FSearchDataLink <> nil then
    Result := FSearchDataLink.FieldName
  else
    Result := '';
end;

{
  ���������� ������������� ������������� �������� ������.
}

function TmmDBSearch.GetDataSource: TDataSource;
begin
  if FSearchDataLink <> nil then
    Result := FSearchDataLink.DataSource
  else
    Result := nil;
end;

{
  ������������� ����� ��������� ������������� ����.
}

procedure TmmDBSearch.SetDataField(const Value: String);
begin
  if FSearchDataLink <> nil then
    FSearchDataLink.FieldName := Value
end;

{
  ������������� ��������� ������������� �������� ������.
}

procedure TmmDBSearch.SetDataSource(const Value: TDataSource);
begin
  if FSearchDataLink <> nil then
    FSearchDataLink.DataSource := Value;
end;

end.

