
{++

  Copyright (c) 1998-99 by Golden Software of Belarus

  Module

    mmIBRunTimeStore.pas (ex-mmVisualDataSettings)

  Abstract

    A non-visual component, which stores all user's visual setings in a database.

  Author

    Smirnov Anton (1-11-98), Romanovski Denis (06.03.99)

  Revisions history

    Version 2.0    25-01-00    Dennis   Everything's changed to IB components.

    Version 2.1    21.02.00    Dennis   Some bugs fixed with current user.
--}

{
  ��������! (Delphi 4.3)

  ��� ���������� ������ ������ ���������� ���������� ���������� ������ ����
  � ����� DBGrids.pas, � ������ TColumn, � ������ DefaultWidth ���

  Result := Field.DisplayWidth * (Canvas.TextWidth('0') - TM.tmOverhang) + TM.tmOverhang + 4;

  �� ���

  Result := Field.DisplayWidth * TM.tmAveCharWidth - (TM.tmAveCharWidth div 2) + TM.tmOverhang + 3;

  ����� ����� �������� � ���������� ������������� �������� �������.

  P.S. ��� ������� � ���, ��� Borland ����������� ������������ ������� �������!
}

unit mmIBRunTimeStore;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExList, DB, IBTable, IBQuery, IBStoredProc, IBBlob, IBDatabase, DBClient,
  DBGrids, IBCustomDataSet, IBSQL, boSecurity;

const
  DefUserKey = -1;
  DefContext = -1;

type
  TmmIBRunTimeStore = class(TComponent)
  private
    FTableName, FTableFieldName: String; // ������������ ������� ������
    FContext: Integer; // ��������
    FUserKey: Integer; // ���� ������������

    FUseUserLogin: Boolean; // ������������ �� ���������� ����������� �� ������
    FDatabase: TIBDatabase; // ������������ ���� ������
    FEnabled: Boolean; // ����� ���������/����������

    FTables: TStringList; // ������ ����������� ������
    FQueries: TStringList; // ������ ����������� ��������

    FStores: TExList; // ������ ����������� ���������

    FStoreDataSet, FFieldsDataSet: TIBDataSet; // ������� ����������� ��������

    FStoreProc: TIBStoredProc; // ���������� �����
    FStoreDataSetTrans: TIBtransaction;

    OldOnCreateForm, OldOnDestroyForm: TNotifyEvent; // Event ��������, ����������� �����-�������� ������ ����������

    FOnCustomGrid: TNotifyEvent; // Eevent Grid-�� ������������

    procedure DoOnCreateForm(Sender: TObject);
    procedure DoOnDestroyForm(Sender: TObject);

    procedure OpenStoreTable(Reading: Boolean);
    procedure CloseStoreTable;

    procedure ReadStoreKeys;
    procedure AssociateGrids;

    procedure SeTTables(const Value: TStringList);
    procedure SetQueries(const Value: TStringList);

    function GetActiveStoreTable: Boolean;
    function FindStoreByName(ATableName: String; var Index: Integer): Boolean;

  protected
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure AddGridToStore(TableName: String; G: TDBGrid);
    procedure ReadDefaultSettings(TableName: String);
    procedure ReadAllDefaults;

    // ������� �� ������� ���������� ��������
    property ActiveStoreTable: Boolean read GetActiveStoreTable;

  published
    // �������, �� ������� ����� ������, � ������� ���������� ������
    property TableName: String read FTableName write FTableName;
    // �������, �� ������� ����� ������, � ������� ���������� ������ �� �����
    property TableFieldName: String read FTableFieldName write FTableFieldName;
    // ��������, �� �������� ����������� ������� ����������� ������
    property Context: Integer read FContext write FContext default DefContext;
    // ��������, ��������� ������ ����������
    property Enabled: Boolean read FEnabled write FEnabled default True;
    // ���� UserKey, �� �������� ����������� ������� ����������� ������
    property UserKey: Integer read FUserKey write FUserKey default DefUserKey;
    // ������������ �� ���������� ����������� �� ������
    property UseUserLogin: Boolean read FUseUserLogin write FUseUserLogin default True;
    // ������������ ���� ������
    property Database: TIBDatabase read FDatabase write FDatabase;
    // ������ ����������� ������
    property Tables: TStringList read FTables write SeTTables;
    // ������ ����������� ��������
    property Queries: TStringList read FQueries write SetQueries;
    // Event �� �������� Grid-�� ������������
    property OnCustomGrid: TNotifyEvent read FOnCustomGrid write FOnCustomGrid;

  end;

implementation

uses
  Ternaries, mmDBGrid, mmDBGridTree, mmDBGridTreeEx, xDBLookU, xDBLookupStored,
  gsMultilingualSupport;

{
  ++++++++++++++++++++++++++++++++++++
  +++   ��������� �������� �����   +++
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
  SP_FINDSTORE = 'FIN_P_RTS_FINDSTORE';

{
  +++++++++++++++++++++++++++++++++++++++++++
  +++   Common Procedures and Functions   +++
  +++++++++++++++++++++++++++++++++++++++++++
}


// ����� ������ � ������ ��������.
function FontStyleToStr(Style: TFontStyles): String;
begin
  Result := Format('%s%s%s%s', [
    Ternary(fsBold in Style, 'B', ''),
    Ternary(fsItalic in Style, 'I', ''),
    Ternary(fsUnderline in Style, 'U', ''),
    Ternary(fsStrikeout in Style, 'S', '')]);
end;

// ��������� ����� ������ �� ������ � ��������.
function StrToFontStyle(const S: String): TFontStyles;
begin
  Result := [];
  if Pos('B', S) > 0 then Result := Result + [fsBold];
  if Pos('I', S) > 0 then Result := Result + [fsItalic];
  if Pos('U', S) > 0 then Result := Result + [fsUnderline];
  if Pos('S', S) > 0 then Result := Result + [fsStrikeout];
end;

// ��������� ������ � ����.
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

// ������������ ������� � ��� Char.
function AlToStr(const Align: TAlignment): Char;
begin
  case Align of
    taCenter: Result := 'C';
    taRightJustify: Result := 'R';
  else
    Result := 'L';
  end;
end;

// ���������� �� Char-� ������������.
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

// ���������� ����� ������� � Grid-� �� ��������� �� ����.
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


// ���������� ����� ����� ���� �� ��� �����.
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
    FFieldName: String; // ��� ����

    FTitleFont: TFontRecord; // ����� �������� �������
    FFont: TFontRecord; // ����� �������

    FTitleAlignment: TAlignment; // ������������ ��������� �������
    FTitleColor: TColor; // ���� �������� �������
    FColor: TColor; // ���� �������

    FFieldOrder: Integer; // ������ ����
    FVisible: Boolean; // �������� �� ��������� ������������
    FDisplayLabel: String; // ������������
    FDisplayWidth: Integer; // ������
    FDisplayFormat: String; // ������ �����������
    FAlignment: TAlignment; // ������������ �������
    FEditMask: String; // ����� ��������������

    FWorkWithColumn: Boolean; // ���� �� � ������� ���� ������������� �������
    FClear: Boolean; // �������� �� ������ ������ ������
    FFieldKey: Integer; // ���� �� ����
  public
    constructor Create(AClear: Boolean);
  end;

// ���������� ����� Cache �� ��������� ����
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
    FStoreKey: Integer; // ��������� ���� ������
    FExists: Boolean; // ������� �� ������ ��� ������ UserKey, Context

    FDataSet: TDataSet; // ������� ��� ������
    FTreeSet: TDataSet; // �� ������ ������������� ������!

    FGrid: TDBGrid; // ��������� � ��� Grid

    OldAfterOpen, OldBeforeClose: TDataSetNotifyEvent; // Event-� �������
    OldAfterOpenTree: TDataSetNotifyEvent; // Event-� �������-������

    FRTS: TmmIBRunTimeStore; // ������ �� ������� �����

    FFastCachedStores: TExList; // ��� �� ��������� ��������� ��� ����� ������� ������
    FFullStores: TExList; // ��� �� ��� ���� ��� ���������
    FFullLoad: Boolean; // ���� �� ����������� ������ �������� ������

    FFont: TFontRecord; // ����� �������
    FTitleFont: TFontRecord; // ����� ��������
    FColor: TColor; // ���� �������
    FTitleColor: TColor; // ���� ��������
    FColorSelected: TColor; // ���� ���������� ������
    FStriped: Boolean; // �����������
    FStripeOne: TColor; // ������ ������
    FStripeTwo: TColor; // ������ ������
    FScaleColumns: Boolean; // ������������
    FCondFormat: Boolean; // �������� ��������������
    FShowLines: Boolean; // ��������� �����������

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
    constructor Create(ARTS: TmmIBRunTimeStore);
    destructor Destroy; override;

    procedure ClearData;
    procedure SaveData;
    procedure ReadData;

    // ��������� ����
    property StoreKey: Integer read FStoreKey write FStoreKey;
    // ������� ��� ������
    property DataSet: TDataSet read FDataSet write SetDataSet;
    // ������������� Grid
    property Grid: TDBGrid read FGrid write FGrid;
    // ���������� �� ����������� �������� �� ������ �������
    property Exists: Boolean read FExists write FExists;
    // ��� ������� ��� ��� ���������� �������
    property TableName: String read GetTableName;
    // �������� �� ������ ��������
    property IsTable: Boolean read GetIsTable;
    // �������� �� Grid �������
    property IsTree: Boolean read GetIsTree;
    // �������� �� Grid ����������� �������
    property IsTreeEx: Boolean read GetIsTreeEx;

  end;

{
  ------------------------
  ---   TCachedStore   ---
  ------------------------
}

{
  ������ ��������� ���������.
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
  ������ ��������� ���������.
}

constructor TRunTimeStore.Create(ARTS: TmmIBRunTimeStore);
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
  ������������ ������.
}

destructor TRunTimeStore.Destroy;
begin
  FFastCachedStores.Free;
  FFullStores.Free;

  inherited Destroy;
end;

{
  ���������� ������� ������.
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
  ��������� ������.
}

procedure TRunTimeStore.SaveData;
begin
  CompareAndWrite;
  FExists := True;
end;

{
  ��������� ������.
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
      // ��������� ����, �� ������� ��� �� ���� ��������� ������
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
  ���������� ������ ������� ��������� � ������.
}

procedure TRunTimeStore.ReadSettings;
var
  F: TField;
  I, K: Integer;
  C: TColumn;
  FO: TFieldOption;
  Found: Boolean;
  CurrStore: TCachedStore;

  BlobStream: TStream;
  CurrCondition: TCondition;

  AColor: TColor;
  ABool: Boolean;
  ASize: Integer;
  AnOperation: TConditionOperation;

  // ���������� ���������� ������ �� ������
  function ReadString: String;
  var
    L: Integer;
  begin
    BlobStream.Read(L, SizeOf(Integer));
    SetString(Result, PChar(nil), L);
    BlobStream.Read(Pointer(Result)^, L);
  end;

begin
  // ���� ���� ���������� �� ���������� ������� �� ����.
  if FStoreKey >= 0 then
  with FRTS do
  begin
    // �������� ������� ���������
    FStoreDataSet.Close;
    FStoreDataSet.Params.ByName('THESTOREKEY').AsInteger := FStoreKey;
    FStoreDataSet.Open;

    // �������� ������ ����� �� ������� ���������
    FFieldsDataSet.Close;
    FFieldsDataSet.Params.ByName('THESTOREKEY').AsInteger := FStoreKey;
    FFieldsDataSet.Open;
    FFieldsDataSet.FieldByName(FF_FieldKey).Required := False;

    if FStoreDataSet.RecordCount = 0 then
      raise Exception.Create('������ �������� �� �������!');

    // ������� ������ ���������
    for I := 0 to FFullStores.Count - 1 do FFullStores.DeleteAndFree(0);

    while not FFieldsDataSet.EOF do
    begin
      F := DataSet.FindField(FFieldsDataSet.FieldByName(FF_FIELDNAME).AsString);

      if F <> nil then
      begin
        CurrStore := TCachedStore.Create(False);
        CurrStore.FFieldKey := FFieldsDataSet.FieldByName(FF_FIELDKEY).AsInteger;
        CurrStore.FFieldName := FFieldsDataSet.FieldByName(FF_FIELDNAME).AsString;
        FFullStores.Add(CurrStore);

        CurrStore.FFieldOrder := FFieldsDataSet.FieldByName(FF_FieldOrder).AsInteger;
        CurrStore.FVisible := Boolean(FFieldsDataSet.FieldByName(FF_Visible).AsInteger)
          or FFieldsDataSet.FieldByName(FF_Visible).IsNull;
        CurrStore.FDisplayLabel := FFieldsDataSet.FieldByName(FF_DisplayLabel).AsString;
        CurrStore.FDisplayFormat := FFieldsDataSet.FieldByName(FF_DisplayFormat).AsString;

        CurrStore.FAlignment :=  StrToAl(FFieldsDataSet.FieldByName(FF_Alignment).AsString);
        CurrStore.FEditMask := FFieldsDataSet.FieldByName(FF_EditMask).AsString;

        // ���� ���� ������������� Grid
        if FGrid <> nil then
        begin
          CurrStore.FWorkWithColumn := FindColumn(FGrid, F, C);

          CurrStore.FTitleFont.Color := StringToColorEx(FFieldsDataSet.FieldByName(FF_TitleFontColor).AsString,
            FGrid.TitleFont.Color);

          if FFieldsDataSet.FieldByName(FF_TitleFontSize).AsInteger <= 0 then
            CurrStore.FTitleFont.Size := FGrid.TitleFont.Size
          else
            CurrStore.FTitleFont.Size := FFieldsDataSet.FieldByName(FF_TitleFontSize).AsInteger;

          CurrStore.FTitleFont.Style := StrToFontStyle(FFieldsDataSet.FieldByName(FF_TitleFontStyle).AsString);

          if FFieldsDataSet.FieldByName(FF_TitleFontName).AsString = '' then
            CurrStore.FTitleFont.Name := FGrid.TitleFont.Name
          else
            CurrStore.FTitleFont.Name := FFieldsDataSet.FieldByName(FF_TitleFontName).AsString;

          CurrStore.FTitleAlignment := StrToAl(FFieldsDataSet.FieldByName(FF_TitleAlignment).AsString);
          CurrStore.FTitleColor := StringToColorEx(FFieldsDataSet.FieldByName(FF_TitleColor).AsString,
            FGrid.FixedColor);

          CurrStore.FFont.Color := StringToColorEx(FFieldsDataSet.FieldByName(FF_FontColor).AsString,
            FGrid.Font.Color);

          if FFieldsDataSet.FieldByName(FF_FontSize).AsInteger <= 0 then
            CurrStore.FFont.Size := FGrid.Font.Size
          else
            CurrStore.FFont.Size := FFieldsDataSet.FieldByName(FF_FontSize).AsInteger;

          CurrStore.FFont.Style := StrToFontStyle(FFieldsDataSet.FieldByName(FF_FontStyle).AsString);

          if FFieldsDataSet.FieldByName(FF_FontName).AsString = '' then
            CurrStore.FFont.Name := FGrid.Font.Name
          else
            CurrStore.FFont.Name := FFieldsDataSet.FieldByName(FF_FontName).AsString;

          CurrStore.FColor := StringToColorEx(FFieldsDataSet.FieldByName(FF_Color).AsString, FGrid.Color);

          // ���� ������ Grid �������� TmmDBGrid
          // ������ ���������� ����� ��������� � Grid
          if FGrid is TmmDBGrid then
          begin
            Found := FindFieldOption(FGrid as TmmDBGrid, F.FieldName, FO);
            if not Found then FO := TFieldOption.Create;

            FO.FieldName := F.FieldName;

            if FFieldsDataSet.FieldByName(FF_Resizeable).IsNull then
              FO.Scaled := True
            else
              FO.Scaled := Boolean(FFieldsDataSet.FieldByName(FF_Resizeable).AsInteger);

            if FFieldsDataSet.FieldByName(FF_MaxWidth).IsNull then
              FO.MaxWidth := -1
            else
              FO.MaxWidth := FFieldsDataSet.FieldByName(FF_MaxWidth).AsInteger;

            if FFieldsDataSet.FieldByName(FF_MinWidth).IsNull then
              FO.MinWidth := -1
            else
              FO.MinWidth := FFieldsDataSet.FieldByName(FF_MinWidth).AsInteger;

            if not Found then TmmDBGrid(FGrid).FieldOptions.Add(FO);
          end;
        end;

        CurrStore.FDisplayWidth := FFieldsDataSet.FieldByName(FF_DisplayWidth).AsInteger;
      end;

      FFieldsDataSet.Next;
    end;

    // ��������� �� �������������� Grid-�
    if FGrid <> nil then
    begin
      FFont.Color := StringToColorEx(FStoreDataSet.FieldByName(F_FontColor).AsString, FGrid.Font.Color);
      FGrid.Font.Color := FFont.Color;
      if Assigned(TranslateBase) then
        FGrid.Font.Charset := TranslateBase.CharSet;

      if FStoreDataSet.FieldByName(F_FontSize).AsInteger <= 0 then
        FFont.Size := FGrid.Font.Size
      else
        FFont.Size := FStoreDataSet.FieldByName(F_FontSize).AsInteger;

      FGrid.Font.Size := FFont.Size;

      FFont.Style := StrToFontStyle(FStoreDataSet.FieldByName(F_FontStyle).AsString);
      FGrid.Font.Style := FFont.Style;

      if FStoreDataSet.FieldByName(F_FontName).AsString = '' then
        FFont.Name := FGrid.Font.Name
      else
        FFont.Name := FStoreDataSet.FieldByName(F_FontName).AsString;
      FGrid.Font.Name := FFont.Name;

      FTitleFont.Color := StringToColorEx(FStoreDataSet.FieldByName(F_TitleFontColor).AsString,
        FGrid.TitleFont.Color);
      FGrid.TitleFont.Color := FTitleFont.Color;
      if Assigned(TranslateBase) then
        FGrid.TitleFont.Charset := TranslateBase.CharSet;

      if FStoreDataSet.FieldByName(F_TitleFontSize).AsInteger <= 0 then
        FTitleFont.Size := FGrid.Font.Size
      else
        FTitleFont.Size := FStoreDataSet.FieldByName(F_TitleFontSize).AsInteger;
      FGrid.TitleFont.Size := FTitleFont.Size;

      FTitleFont.Style := StrToFontStyle(FStoreDataSet.FieldByName(F_TitleFontStyle).AsString);
      FGrid.TitleFont.Style := FTitleFont.Style;

      if FStoreDataSet.FieldByName(F_TitleFontName).AsString = '' then
        FTitleFont.Name := FGrid.TitleFont.Name
      else
        FTitleFont.Name := FStoreDataSet.FieldByName(F_TitleFontName).AsString;
      FGrid.TitleFont.Name := FTitleFont.Name;

      FColor := StringToColorEx(FStoreDataSet.FieldByName(F_Color).AsString, FGrid.Color);
      FGrid.Color := FColor;

      FTitleColor := StringToColorEx(FStoreDataSet.FieldByName(F_TitleColor).AsString, FGrid.FixedColor);
      FGrid.FixedColor := FTitleColor;

      // ���� ������������� Grid �������� TmmDBGrid
      if FGrid is TmmDBGrid then
      begin
        FColorSelected := StringToColorEx(FStoreDataSet.FieldByName(F_ColorSelected).AsString,
          (FGrid as TmmDBGrid).ColorSelected);
        (FGrid as TmmDBGrid).ColorSelected  := FColorSelected;

        FStriped := Boolean(FStoreDataSet.FieldByName(F_Striped).AsInteger) or
          FStoreDataSet.FieldByName(F_Striped).IsNull;
        (FGrid as TmmDBGrid).Striped := FStriped;

        FStripeOne := StringToColorEx(FStoreDataSet.FieldByName(F_StripeOne).AsString,
          (FGrid as TmmDBGrid).StripeOne);
        (FGrid as TmmDBGrid).StripeOne := FStripeOne;

        FStripeTwo := StringToColorEx(FStoreDataSet.FieldByName(F_StripeTwo).AsString,
          (FGrid as TmmDBGrid).StripeTwo);
        (FGrid as TmmDBGrid).StripeTwo := FStripeTwo;

        if FStoreDataSet.FieldByName(F_ScaleColumns).IsNull then
          FScaleColumns := (FGrid as TmmDBGrid).ScaleColumns
        else  
          FScaleColumns := Boolean(FStoreDataSet.FieldByName(F_ScaleColumns).AsInteger);
          
        (FGrid as TmmDBGrid).ScaleColumns := FScaleColumns;

        FCondFormat := Boolean(FStoreDataSet.FieldByName(F_CondFormat).AsInteger);
        (FGrid as TmmDBGrid).ConditionalFormatting := FCondFormat;

        FShowLines := Boolean(FStoreDataSet.FieldByName(F_ShowLines).AsInteger);
        (FGrid as TmmDBGrid).ShowLines := FShowLines;

        /////////////////////////////////////////////////
        //                                             //
        //   B L O B - � � � � �  � � � � � � � � �!   //
        //                                             //
        /////////////////////////////////////////////////

        if not FStoreDataSet.FieldByName(F_Settings).IsNULL then
        begin
          // ������� ����� ��� ������ ������ �� ���������������
          BlobStream := FStoreDataSet.
            CreateBlobStream(FStoreDataSet.FieldByName(F_Settings), bmRead);

          BlobStream.Seek(0, soFromBeginning);

          try
            with FGrid as TmmDBGrid do
            begin
              // � � � � � � � �  � � � � � � � � � � � � � �

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

    // ��������� ������ �� �������� �� ���������� ����
    ReadCache(FFullStores, True);
  end;

  // ��������� ����, �� ������� ��� �� ���� ��������� ������
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
  ��������� ������� ��������� � ������.
}

procedure TRunTimeStore.CompareAndWrite;
var
  Compare, CompareField: Boolean;
  I: Integer;
  S: String;

  BlobStream: TStream;
  CurrCondition: TCondition;

  AColor: TColor;
  ASize: Integer;
  AName: String;
  AnAlignment: TAlignment;
  AStyle: TFontStyles;
  AnIndex: Integer;

  // ��������� � ����� ��������������
  procedure EnsureStoreTableEdit;
  begin
    if not (FRTS.FStoreDataSet.State in [dsEdit, dsInsert]) then
      FRTS.FStoreDataSet.Edit;
  end;

  // ���������� ����
  procedure WriteField(F: TField; FieldName: String; CS: TCachedStore);
  var
    C: TColumn;
    FastCS: TCachedStore;

    // ��������� � ����� ��������������
    procedure EnsureStoreFieldsEdit;
    begin
      if not (FRTS.FFieldsDataSet.State in [dsEdit, dsInsert]) then
      begin
        if FRTS.FFieldsDataSet.Locate(FF_FIELDKEY, CS.FFieldKey, []) then
          FRTS.FFieldsDataSet.Edit
        else
          raise Exception.Create('Field Key not Found');
      end;
    end;

  begin
    with FRTS do
    begin
      FastCS := nil;

      // ���� ���� ��� �������
      if (F = nil) and not FindCache(FFastCachedStores, FieldName, FastCS) then
        raise Exception.Create('������ ����� �������� ���� ������!');

      if F <> nil then
        AnIndex := F.Index
      else
        AnIndex := FastCS.FFieldOrder;

      // ������ �� ������� �����

      if not CompareField or (CompareField and (CS.FFieldOrder <> AnIndex)) then
      begin
        EnsureStoreFieldsEdit;
        FFieldsDataSet.FieldByName(FF_FieldOrder).AsInteger := AnIndex;
      end;

      if F <> nil then
        AnIndex := Integer(F.Visible)
      else
        AnIndex := Integer(FastCS.FVisible);

      if not CompareField or (CompareField and (Integer(CS.FVisible) <> AnIndex)) then
      begin
        EnsureStoreFieldsEdit;
        FFieldsDataSet.FieldByName(FF_Visible).AsInteger := AnIndex;
      end;

      if F <> nil then
        AName := F.DisplayLabel
      else
        AName := FastCS.FDisplayLabel;

      if not CompareField or (CompareField and (AnsiCompareText(CS.FDisplayLabel, AName) <> 0)) then
      begin
        EnsureStoreFieldsEdit;
        FFieldsDataSet.FieldByName(FF_DisplayLabel).AsString := AName;
      end;

      if F <> nil then
        AnIndex := F.DisplayWidth
      else
        AnIndex := FastCS.FDisplayWidth;

      if not CompareField or (CompareField and (CS.FDisplayWidth <> AnIndex)) then
      begin
        EnsureStoreFieldsEdit;
        FFieldsDataSet.FieldByName(FF_DisplayWidth).AsInteger := AnIndex;
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
          FFieldsDataSet.FieldByName(FF_DisplayFormat).AsString := S
        else if F is TDateTimeField then
          FFieldsDataSet.FieldByName(FF_DisplayFormat).AsString := S;
      end;

      if F <> nil then
        AnAlignment := F.Alignment
      else
        AnAlignment := FastCS.FAlignment;

      if not CompareField or (CompareField and (CS.FAlignment <> AnAlignment)) then
      begin
        EnsureStoreFieldsEdit;
        FFieldsDataSet.FieldByName(FF_Alignment).AsString := AlToStr(AnAlignment);
      end;

      if F <> nil then
        AName := F.EditMask
      else
        AName := FastCS.FEditMask;

      if not CompareField or (CompareField and (AnsiCompareText(CS.FEditMask, AName) <> 0)) then
      begin
        EnsureStoreFieldsEdit;
        FFieldsDataSet.FieldByName(FF_EditMask).AsString := AName;
      end;

      // ���� ���� ������������� Grid
      if (FGrid <> nil) and (FindColumn(FGrid, F, C) or (Assigned(FastCS) and FastCS.FWorkWithColumn)) then
      begin
        if C <> nil then
          AColor := C.Title.Font.Color
        else
          AColor := FastCS.FTitleFont.Color;

        if not CompareField or (CompareField and (CS.FTitleFont.Color <> AColor)) then
        begin
          EnsureStoreFieldsEdit;
          FFieldsDataSet.FieldByName(FF_TitleFontColor).AsString := ColorToString(AColor);
        end;

        if C <> nil then
          ASize := C.Title.Font.Size
        else
          ASize := FastCS.FTitleFont.Size;

        if not CompareField or (CompareField and (CS.FTitleFont.Size <> ASize)) then
        begin
          EnsureStoreFieldsEdit;
          FFieldsDataSet.FieldByName(FF_TitleFontSize).AsInteger := ASize;
        end;

        if C <> nil then
          AStyle := C.Title.Font.Style
        else
          AStyle := FastCS.FTitleFont.Style;

        if not CompareField or (CompareField and (CS.FTitleFont.Style <> AStyle)) then
        begin
          EnsureStoreFieldsEdit;
          FFieldsDataSet.FieldByName(FF_TitleFontStyle).AsString := FontStyleToStr(AStyle);
        end;

        if C <> nil then
          AName := C.Title.Font.Name
        else
          AName := FastCS.FTitleFont.Name;

        if not CompareField or (CompareField and (AnsiCompareText(CS.FTitleFont.Name, AName) <> 0)) then
        begin
          EnsureStoreFieldsEdit;
          FFieldsDataSet.FieldByName(FF_TitleFontName).AsString := AName;
        end;

        if C <> nil then
          AnAlignment := C.Title.Alignment
        else
          AnAlignment := FastCS.FTitleAlignment;

        if not CompareField or (CompareField and (CS.FTitleAlignment <> AnAlignment)) then
        begin
          EnsureStoreFieldsEdit;
          FFieldsDataSet.FieldByName(FF_TitleAlignment).AsString := AlToStr(AnAlignment);
        end;

        if C <> nil then
          AColor := C.Title.Color
        else
          AColor := FastCS.FTitleColor;

        if not CompareField or (CompareField and (CS.FTitleColor <> AColor)) then
        begin
          EnsureStoreFieldsEdit;
          FFieldsDataSet.FieldByName(FF_TitleColor).AsString := ColorToString(AColor);
        end;

        if C <> nil then
          AColor := C.Font.Color
        else
          AColor := FastCS.FFont.Color;

        if not CompareField or (CompareField and (CS.FFont.Color <> AColor)) then
        begin
          EnsureStoreFieldsEdit;
          FFieldsDataSet.FieldByName(FF_FontColor).AsString := ColorToString(AColor);
        end;

        if C <> nil then
          ASize := C.Font.Size
        else
          ASize := FastCS.FFont.Size;

        if not CompareField or (CompareField and (CS.FFont.Size <> ASize)) then
        begin
          EnsureStoreFieldsEdit;
          FFieldsDataSet.FieldByName(FF_FontSize).AsInteger := ASize;
        end;

        if C <> nil then
          AStyle := C.Font.Style
        else
          AStyle := FastCS.FFont.Style;

        if not CompareField or (CompareField and (CS.FFont.Style <> AStyle)) then
        begin
          EnsureStoreFieldsEdit;
          FFieldsDataSet.FieldByName(FF_FontStyle).AsString := FontStyleToStr(AStyle);
        end;

        if C <> nil then
          AName := C.Font.Name
        else
          AName := FastCS.FFont.Name;

        if not CompareField or (CompareField and (AnsiCompareText(CS.FFont.Name, AName) <> 0)) then
        begin
          EnsureStoreFieldsEdit;
          FFieldsDataSet.FieldByName(FF_FontName).AsString := AName;
        end;

        if C <> nil then
          AColor := C.Color
        else
          AColor := FastCS.FColor;

        if not CompareField or (CompareField and (CS.FColor <> AColor)) then
        begin
          EnsureStoreFieldsEdit;
          FFieldsDataSet.FieldByName(FF_Color).AsString := ColorToString(AColor);
        end;
      end;
    end;
  end;

  // ���������� ������ ������ � �����
  procedure WriteString(S: String);
  var
    L: Integer;
  begin
    L := Length(S);
    BlobStream.Write(L, SizeOf(Integer));
    BlobStream.Write(Pointer(S)^, L);
  end;

begin
  // ���������� ��� ���������! �� ���� �� ���������, �� ��������� �� ����!
  if not FFullLoad then Exit;

  Compare := (FStoreKey >= 0) and FExists;

  with FRTS do
  begin
    // ���� ���������� ������� ����� ������ �� �������
    if not Compare then
    begin
      try
        if not FRTS.FStoreDataSet.Prepared or not FRTS.FFieldsDataSet.Prepared then
          FRTS.OpenStoreTable(False);

        FStoreProc.ExecProc;
        FStoreKey := FStoreProc.ParamByName(F_STOREKEY).AsInteger;
        FStoreDataSet.Params.ByName('THESTOREKEY').AsInteger := 0;
        FStoreDataSet.Open;
        FStoreDataSet.Append;
        FStoreDataSet.FieldByName(F_StoreKey).AsInteger := FStoreKey;
        FStoreDataSet.FieldByName(F_UserKey).AsInteger := FUserKey;
        FStoreDataSet.FieldByName(F_Context).AsInteger := FContext;
        FStoreDataSet.FieldByName(F_TableName).AsString := Self.TableName;
        FStoreDataSet.Post;
        FStoreDataSet.Transaction.CommitRetaining;
        FStoreDataSet.Close;
        FStoreDataSet.Params.ByName('THESTOREKEY').AsInteger := FStoreKey;
        FStoreDataSet.Open;

        if FStoreDataSet.RecordCount = 0 then
          raise Exception.Create('������!');
      except
        Exit;
      end;
    end else begin
      if not FRTS.FStoreDataSet.Active or not FRTS.FFieldsDataSet.Active then
        FRTS.OpenStoreTable(False);

      try
        FStoreDataSet.Close;
        FStoreDataSet.Params.ByName('THESTOREKEY').AsInteger := FStoreKey;
        FStoreDataSet.Open;

        if FStoreDataSet.RecordCount = 0 then
          raise Exception.Create('������!');
      except
        Exit;
      end;
    end;

    FFieldsDataSet.Close;
    FFieldsDataSet.Params.ByName('THESTOREKEY').AsInteger := FStoreKey;
    FFieldsDataSet.Open;
    FFieldsDataSet.FieldByName(FF_FieldKey).Required := False;

    for I := 0 to FFullStores.Count - 1 do
    begin
      CompareField := (TCachedStore(FFullStores[I]).FFieldKey >= 0) and Exists;

      // ���� ������ ������ ��� �� �������
      if not CompareField then
      begin
        FFieldsDataSet.Append;
        FFieldsDataSet.FieldByName(FF_StoreKey).AsInteger := FStoreKey;
        FFieldsDataSet.FieldByName(FF_FieldName).AsString := TCachedStore(FFullStores[I]).FFieldName;
      end else
        FFieldsDataSet.Next;

      // ���� ���� ������� ������������� (�� � Design ������)
      if not FDataSet.Active and FDataSet.DefaultFields then
        WriteField(nil, TCachedStore(FFullStores[I]).FFieldName, FFullStores[I])
      else
        WriteField(FDataSet.FindField(TCachedStore(FFullStores[I]).FFieldName),
          TCachedStore(FFullStores[I]).FFieldName, FFullStores[I]);

      if FFieldsDataSet.State in [dsEdit, dsInsert] then FFieldsDataSet.Post;
    end;

    // ���� ���������� ������������� Grid
    if FGrid <> nil then
    begin
      if not Compare or (Compare and (FFont.Color <> FGrid.Font.Color)) then
      begin
        EnsureStoreTableEdit;
        FStoreDataSet.FieldByName(F_FontColor).AsInteger := FGrid.Font.Color;
      end;

      if not Compare or (Compare and (FFont.Size <> FGrid.Font.Size)) then
      begin
        EnsureStoreTableEdit;
        FStoreDataSet.FieldByName(F_FontSize).AsInteger := FGrid.Font.Size;
      end;

      if not Compare or (Compare and (FFont.Style <> FGrid.Font.Style)) then
      begin
        EnsureStoreTableEdit;
        FStoreDataSet.FieldByName(F_FontStyle).AsString := FontStyleToStr(FGrid.Font.Style);
      end;

      if not Compare or (Compare and (AnsiCompareText(FFont.Name, FGrid.Font.Name) <> 0)) then
      begin
        EnsureStoreTableEdit;
        FStoreDataSet.FieldByName(F_FontName).AsString := FGrid.Font.Name;
      end;

      if not Compare or (Compare and (FTitleFont.Color <> FGrid.TitleFont.Color)) then
      begin
        EnsureStoreTableEdit;
        FStoreDataSet.FieldByName(F_TitleFontColor).AsString := ColorToString(FGrid.TitleFont.Color);
      end;

      if not Compare or (Compare and (FTitleFont.Size <> FGrid.TitleFont.Size)) then
      begin
        EnsureStoreTableEdit;
        FStoreDataSet.FieldByName(F_TitleFontSize).AsInteger := FGrid.TitleFont.Size;
      end;

      if not Compare or (Compare and (FTitleFont.Style <> FGrid.TitleFont.Style)) then
      begin
        EnsureStoreTableEdit;
        FStoreDataSet.FieldByName(F_TitleFontStyle).AsString := FontStyleToStr(FGrid.TitleFont.Style);
      end;

      if not Compare or (Compare and (AnsiCompareText(FTitleFont.Name, FGrid.TitleFont.Name) <> 0)) then
      begin
        EnsureStoreTableEdit;
        FStoreDataSet.FieldByName(F_TitleFontName).AsString := FGrid.TitleFont.Name;
      end;

      if not Compare or (Compare and (FColor <> FGrid.Color)) then
      begin
        EnsureStoreTableEdit;
        FStoreDataSet.FieldByName(F_Color).AsString := ColorToString(FGrid.Color);
      end;

      if not Compare or (Compare and (FTitleColor <> FGrid.FixedColor)) then
      begin
        EnsureStoreTableEdit;
        FStoreDataSet.FieldByName(F_TitleColor).AsString := ColorToString(FGrid.FixedColor);
      end;

      // ���� ������������� Grid, �������� TmmDBGrid
      if FGrid is TmmDBGrid then
      begin
        if not Compare or (Compare and (FColorSelected <> (FGrid as TmmDBGrid).ColorSelected)) then
        begin
          EnsureStoreTableEdit;
          FStoreDataSet.FieldByName(F_ColorSelected).AsString :=
            ColorToString((FGrid as TmmDBGrid).ColorSelected);
        end;

        if not Compare or (Compare and (FStriped <> (FGrid as TmmDBGrid).Striped)) then
        begin
          EnsureStoreTableEdit;
          FStoreDataSet.FieldByName(F_Striped).AsInteger := Integer((FGrid as TmmDBGrid).Striped);
        end;

        if not Compare or (Compare and (FStripeOne <> (FGrid as TmmDBGrid).StripeOne)) then
        begin
          EnsureStoreTableEdit;
          FStoreDataSet.FieldByName(F_StripeOne).AsString := ColorToString((FGrid as TmmDBGrid).StripeOne);
        end;

        if not Compare or (Compare and (FStripeTwo <> (FGrid as TmmDBGrid).StripeTwo)) then
        begin
          EnsureStoreTableEdit;
          FStoreDataSet.FieldByName(F_StripeTwo).AsString := ColorToString((FGrid as TmmDBGrid).StripeTwo);
        end;

        if not Compare or (Compare and (FScaleColumns <> (FGrid as TmmDBGrid).ScaleColumns)) then
        begin
          EnsureStoreTableEdit;
          FStoreDataSet.FieldByName(F_ScaleColumns).AsInteger := Integer((FGrid as TmmDBGrid).ScaleColumns);
        end;

        if not Compare or (Compare and (FCondFormat <> (FGrid as TmmDBGrid).ConditionalFormatting)) then
        begin
          EnsureStoreTableEdit;
          FStoreDataSet.FieldByName(F_CondFormat).AsInteger := Integer((FGrid as TmmDBGrid).ConditionalFormatting);
        end;

        if not Compare or (Compare and (FShowLines <> (FGrid as TmmDBGrid).ShowLines)) then
        begin
          EnsureStoreTableEdit;
          FStoreDataSet.FieldByName(F_ShowLines).AsInteger := Integer((FGrid as TmmDBGrid).ShowLines);
        end;

        /////////////////////////////////////////////////
        //                                             //
        //   B L O B - � � � � �  � � � � � � � � �!   //
        //                                             //
        /////////////////////////////////////////////////

        // ���� ���� ����������� ���������
        if (FGrid as TmmDBGrid).UltraChanges or not Compare then
        begin
          EnsureStoreTableEdit;
          //FStoreDataSet.FieldByName(F_Settings).Clear;
          // ������� ����� ��� ������ ������ �� ���������������
          BlobStream := FStoreDataSet.
            CreateBlobStream(FStoreDataSet.FieldByName(F_Settings) as TBlobField, bmWrite);

          try
            //BlobStream.Seek(0, soFromBeginning);
            //BlobStream.Truncate;
            (BlobStream as TIBDSBlobStream).SetSize(0);

            with FGrid as TmmDBGrid do
            begin
              // � � � � � � � �  � � � � � � � � � � � � � �

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

    if FStoreDataSet.State in [dsEdit, dsInsert] then FStoreDataSet.Post;
  end;
end;

{
  ����� ��������� ������� ���������� ���������� ����������.
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
      if not FRTS.FStoreDataSet.Active then FRTS.OpenStoreTable(True);
      ReadSettings;
      FRTS.CloseStoreTable;
    end else // ���� ����� ������ � ������� �� �����������, �� ��������� �� ����
    begin
      // ��������� ����, �� ������� ��� �� ���� ��������� ������
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
  ����� ��������� ������� ���������� ������ ����������.
}

procedure TRunTimeStore.DoBeforeClose(DataSet: TDataSet);
begin
  if Assigned(OldBeforeClose) then OldBeforeClose(DataSet);

  SaveCache(FFastCachedStores, False);
end;

{
  ��������� ������ �� Cache.
}

procedure TRunTimeStore.ReadCache(Cache: TExList; All: Boolean);
var
  I: Integer;
  C: TColumn;
  Z: Integer;
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
    // ���� ��� ����, �� ���������� ���
    if (All and FClear) or (FDataSet.FindField(FFieldName) = nil) then Continue;

    // ���� ���������� �������
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

    // ���� ���� ��������� �� ���������
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

      Z := FDisplayWidth;

      if Z > 0 then
        FDataSet.FieldByName(FFieldName).DisplayWidth := Z;

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
  ���������� ������ � Cache.
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

      // ���� ������� �������
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

      // ���� ������� ��������� �� ���������
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
  ������������ ���������� ������ � ������ ��������������� ��������.
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

  // Event-� �������� � �������� �������: �������� �� � ��������� ������
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
  ���������� ������������ �������.
}

function TRunTimeStore.GetTableName: String;
var
  D: TDataSet;
begin
  // ���� ������� ������
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
      // ���� ������ ����� ���������������� �������
      if (FGrid as TmmDBGridTree).IsCustomTree then
      begin
        Result := FGrid.Name;
      end else begin
        D := (FGrid as TmmDBGridTree).DataSource.DataSet;

        if D is TIBTable then
          Result := (D as TIBTable).TableName
        else
          Result := D.Name;
      end;
    end;  
  // ���� ����������� ������
  end else if (FGrid <> nil) and (FGrid is TmmDBGridTreeEx) then
  begin
    Result := FGrid.Name;
  // ���� lookup combo ����� store-���������
  end else if (FGrid <> nil) and (FGrid is TxLookupGridStored) then
  begin
    Result := (FGrid.Parent as TxDBLookupCombo2).Name;
  // � ����� ������ ������
  end else if FDataSet <> nil then
  begin
    if FDataSet is TIBTable then
      Result := (FDataSet as TIBTable).TableName
    else if (FDataSet is TIBQuery) or (FDataSet is TClientDataSet) then
      Result := FDataSet.Name;
  end else
    Result := '';
end;

{
  �������� ������ DataSet �������� ������.
}

function TRunTimeStore.GetIsTable: Boolean;
begin
  Result := (FDataSet <> nil) and (FDataSet is TIBTable);
end;

{
  �������� �� Grid �������.
}

function TRunTimeStore.GetIsTree: Boolean;
begin
  Result := (FGrid <> nil) and (FGrid is TmmDBGridTree);
end;

{
  �������� �� Grid ����������� �������.
}


function TRunTimeStore.GetIsTreeEx: Boolean;
begin
  Result := (FGrid <> nil) and (FGrid is TmmDBGridTreeEx);
end;

{
  ---------------------------
  ---                     ---
  ---   TmmIBRunTimeStore   ---
  ---                     ---
  ---------------------------
}


{
  ***********************
  ***   Public Part   ***
  ***********************
}


{
  ������ ��������� ���������.
}

constructor TmmIBRunTimeStore.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  // �� ��������� ������� ������ fin_store
  FTableName := 'fin_rts';
  FTableFieldName := 'fin_rtsfield';

  // ������ ��������� �� ���������
  FContext := DefContext;
  FEnabled := True;
  FUserKey := DefUserKey;
  FUseUserLogin := True;
  FDatabase := nil;

  FTables := TStringList.Create;
  FQueries := TStringList.Create;

  FStores := TExList.Create;

  FOnCustomGrid := nil;

  if not (csDesigning in ComponentState) then
  begin
    FStoreProc := TIBStoredProc.Create(nil);

    FStoreDataSet := TIBDataSet.Create(nil);

    FStoreDataSet.SelectSQL.Text := 'SELECT * FROM FIN_RTS WHERE STOREKEY = :THESTOREKEY';

    FStoreDataSet.RefreshSQL.Text := 'SELECT * FROM FIN_RTS WHERE STOREKEY = :STOREKEY';

    FStoreDataSet.ModifySQL.Text :=
      'UPDATE FIN_RTS SET STOREKEY = :STOREKEY, ' +
      'USERKEY = :USERKEY, CONTEXT = :CONTEXT, TABLENAME = :TABLENAME, ' +
      'FONTCOLOR = :FONTCOLOR, FONTSIZE = :FONTSIZE, FONTSTYLE = :FONTSTYLE, ' +
      'FONTNAME = :FONTNAME, TITLEFONTCOLOR = :TITLEFONTCOLOR, TITLEFONTSIZE = :TITLEFONTSIZE, ' +
      'TITLEFONTSTYLE = :TITLEFONTSTYLE, TITLEFONTNAME = :TITLEFONTNAME, COLOR = :COLOR, ' +
      'TITLECOLOR = :TITLECOLOR, COLORSELECTED = :COLORSELECTED, STRIPED = :STRIPED, ' +
      'STRIPEONE = :STRIPEONE, STRIPETWO = :STRIPETWO, SCALECOLUMNS = :SCALECOLUMNS, ' +
      'CONDFORMAT = :CONDFORMAT, SHOWLINES = :SHOWLINES, SETTINGS = :SETTINGS ' +
      'WHERE STOREKEY = :OLD_STOREKEY';

    FStoreDataSet.InsertSQL.Text :=
      'INSERT INTO FIN_RTS' +
      '(STOREKEY, USERKEY, CONTEXT, TABLENAME, FONTCOLOR, FONTSIZE, FONTSTYLE, ' +
      'FONTNAME, TITLEFONTCOLOR, TITLEFONTSIZE, TITLEFONTSTYLE, TITLEFONTNAME, ' +
      'COLOR, TITLECOLOR, COLORSELECTED, STRIPED, STRIPEONE, STRIPETWO, SCALECOLUMNS, ' +
      'CONDFORMAT, SHOWLINES, SETTINGS) ' +
      'VALUES (:STOREKEY, :USERKEY, :CONTEXT, :TABLENAME, :FONTCOLOR, :FONTSIZE, ' +
      ':FONTSTYLE, :FONTNAME, :TITLEFONTCOLOR, :TITLEFONTSIZE, :TITLEFONTSTYLE, ' +
      ':TITLEFONTNAME, :COLOR, :TITLECOLOR, :COLORSELECTED, :STRIPED, :STRIPEONE, ' +
      ':STRIPETWO, :SCALECOLUMNS, :CONDFORMAT, :SHOWLINES, :SETTINGS) ';

    FStoreDataSet.DeleteSQL.Text := 'DELETE FROM FIN_RTS WHERE STOREKEY = :OLD_STOREKEY';


    FFieldsDataSet := TIBDataSet.Create(nil);

    FFieldsDataSet.SelectSQL.Text :=
      'SELECT * FROM FIN_RTSFIELD WHERE STOREKEY = :THESTOREKEY';

    FFieldsDataSet.RefreshSQL.Text :=
      'SELECT FIELDKEY, STOREKEY, FIELDNAME, FIELDORDER, VISIBLE, DISPLAYLABEL, ' +
      'DISPLAYWIDTH, RESIZEABLE, MAXWIDTH, MINWIDTH, DISPLAYFORMAT, ALIGNMENT, ' +
      'EDITMASK, TITLEFONTCOLOR, TITLEFONTSIZE, TITLEFONTSTYLE, TITLEFONTNAME, ' +
      'TITLEALIGNMENT, TITLECOLOR, FONTCOLOR, FONTSIZE, FONTSTYLE, FONTNAME, ' +
      'COLOR FROM FIN_RTSFIELD WHERE FIELDKEY = :FIELDKEY';

    FFieldsDataSet.ModifySQL.Text :=
      'UPDATE FIN_RTSFIELD SET FIELDKEY = :FIELDKEY, STOREKEY = :STOREKEY, ' +
      'FIELDNAME = :FIELDNAME, FIELDORDER = :FIELDORDER, VISIBLE = :VISIBLE, ' +
      'DISPLAYLABEL = :DISPLAYLABEL, DISPLAYWIDTH = :DISPLAYWIDTH, ' +
      'RESIZEABLE = :RESIZEABLE, MAXWIDTH = :MAXWIDTH, MINWIDTH = :MINWIDTH, ' +
      'DISPLAYFORMAT = :DISPLAYFORMAT, ALIGNMENT = :ALIGNMENT, EDITMASK = :EDITMASK, ' +
      'TITLEFONTCOLOR = :TITLEFONTCOLOR, TITLEFONTSIZE = :TITLEFONTSIZE, ' +
      'TITLEFONTSTYLE = :TITLEFONTSTYLE, TITLEFONTNAME = :TITLEFONTNAME, ' +
      'TITLEALIGNMENT = :TITLEALIGNMENT, TITLECOLOR = :TITLECOLOR, FONTCOLOR = :FONTCOLOR, ' +
      'FONTSIZE = :FONTSIZE, FONTSTYLE = :FONTSTYLE, FONTNAME = :FONTNAME, ' +
      'COLOR = :COLOR WHERE FIELDKEY = :OLD_FIELDKEY';

    FFieldsDataSet.DeleteSQL.Text :=
      'DELETE FROM FIN_RTSFIELD WHERE FIELDKEY = :OLD_FIELDKEY';

    FFieldsDataSet.InsertSQL.Text :=
      'INSERT INTO FIN_RTSFIELD (FIELDKEY, STOREKEY, FIELDNAME, FIELDORDER, VISIBLE, ' +
      'DISPLAYLABEL, DISPLAYWIDTH, RESIZEABLE, MAXWIDTH, MINWIDTH, DISPLAYFORMAT, ALIGNMENT, ' +
      'EDITMASK, TITLEFONTCOLOR, TITLEFONTSIZE, TITLEFONTSTYLE, TITLEFONTNAME, ' +
      'TITLEALIGNMENT, TITLECOLOR, FONTCOLOR, FONTSIZE, FONTSTYLE, FONTNAME, COLOR) ' +
      'VALUES (:FIELDKEY, :STOREKEY, :FIELDNAME, :FIELDORDER, :VISIBLE, ' +
      ':DISPLAYLABEL, :DISPLAYWIDTH, :RESIZEABLE, :MAXWIDTH, :MINWIDTH, :DISPLAYFORMAT, :ALIGNMENT, ' +
      ':EDITMASK, :TITLEFONTCOLOR, :TITLEFONTSIZE, :TITLEFONTSTYLE, :TITLEFONTNAME, ' +
      ':TITLEALIGNMENT, :TITLECOLOR, :FONTCOLOR, :FONTSIZE, :FONTSTYLE, :FONTNAME, :COLOR)';

    FStoreDataSetTrans := TIBTransaction.Create(nil);

    FStoreDataSet.Transaction := FStoreDataSetTrans;
    FFieldsDataSet.Transaction := FStoreDataSetTrans;
  end else begin
    FStoreDataSet := nil;
    FFieldsDataSet := nil;
    FStoreProc := nil;

    FStoreDataSetTrans := nil;
  end;
end;

{
  ������������ ������.
}

destructor TmmIBRunTimeStore.Destroy;
begin
  FTables.Free;
  FQueries.Free;
  FStores.Free;

  if not (csDesigning in ComponentState) then
  begin
    if FStoreDataSet <> nil then FStoreDataSet.Free;
    if FFieldsDataSet <> nil then FFieldsDataSet.Free;
    if FStoreProc <> nil then FStoreProc.Free;
    if FStoreDataSetTrans <> nil then FStoreDataSetTrans.Free;
  end;

  inherited Destroy;      
end;

{
  ��������� grid � ���������. ���� ���������� ���������� ����� ������������� (��� DataModule).
}

procedure TmmIBRunTimeStore.AddGridToStore(TableName: String; G: TDBGrid);
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
  ���������� ���������� ������� ���������.
}

procedure TmmIBRunTimeStore.ReadDefaultSettings(TableName: String);
var
  I, K: Integer;
  CurrStore: TRunTimeStore;
  FindStore: TIBStoredProc;
begin
  if FindStoreByName(TableName, I) then
  begin
    CurrStore := FStores[I];

    // ������� ������ ������
    if ((FUserKey <> -1) or (FContext <> -1)) and CurrStore.FExists then
    begin
      OpenStoreTable(False);

      for K := 0 to CurrStore.FFullStores.Count - 1 do
        if
          (TCachedStore(CurrStore.FFullStores[K]).FFieldKey >= 0)
            and
          (
            (FFieldsDataSet.FieldByName(FF_FieldKey).AsInteger =
              TCachedStore(CurrStore.FFullStores[K]).FFieldKey)
              or
            FFieldsDataSet.Locate(FF_FieldKey, TCachedStore(CurrStore.FFullStores[K]).FFieldKey, [])
          )
        then
          FFieldsDataSet.Delete;

      if
        (
          (FStoreDataSet.FieldByName(FF_StoreKey).AsInteger = CurrStore.FStoreKey)
            or
          FStoreDataSet.Locate(FF_StoreKey, CurrStore.FStoreKey, [])
        )
      then
        FStoreDataSet.Delete;

      CloseStoreTable;
    end;

    CurrStore.ClearData;

    // ��������� �����
    FindStore := TIBStoredProc.Create(Self);
    try
      FindStore.Database := FDatabase;
      FindStore.StoredProcName := SP_FINDSTORE;
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
  ��������� ��� ��������� ���������. 
}

procedure TmmIBRunTimeStore.ReadAllDefaults;
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
  ����������� �������� ����������.
}

procedure TmmIBRunTimeStore.Loaded;
begin
  inherited Loaded;

  if not Enabled then Exit;

  // ���� ���������� ���������� TUserLogin
  if FUseUserLogin and (Security <> nil) and not (csDesigning in ComponentState) then
    FUserKey := Security.UserKey;

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

procedure TmmIBRunTimeStore.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then
  begin
    if (FDatabase <> nil) and (AComponent = FDatabase) then
    begin
      Database := nil;
    end;
  end;
end;


{
  ************************
  ***   Private Part   ***
  ************************
}


{
  �� �������� ����� ���������� ���� ��������.
}

procedure TmmIBRunTimeStore.DoOnCreateForm(Sender: TObject);
var
  I, K, M: Integer;
  D: TDataSet;
  C: TComponent;
  Store: TRunTimeStore;

  // ���� �� ��������� � ����
  function HasDuplicates(ADataSet: TDataSet; var Index: Integer): Boolean;
  var
    L: Integer;
  begin
    Result := False;
    Index := -1;
    if ADataSet = nil then Exit;

    for L := 0 to FStores.Count - 1 do
      if (TRunTimeStore(FStores[L]).FDataSet is TIBTable) and (ADataSet is TIBTable) and
        ((TRunTimeStore(FStores[L]).FDataSet as TIBTable).TableName = (ADataSet as TIBTable).TableName) then
      begin
        Result := True;
        Index := L;
        Break;
      end;
  end;

  // ���� �� ������������� ��������� ������
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

  // ������� ������ �������
  for I := FTables.Count - 1 downto 0 do
    if (FTables[I] = '') or (FTables[I] = ' ') then FTables.Delete(I);

  // ������� ������ �������
  for I := FQueries.Count - 1 downto 0 do
    if (FQueries[I] = '') or (FQueries[I] = ' ') then FQueries.Delete(I);

  // ���������� ����� ������
  for I := 0 to FTables.Count - 1 do
    for K := 0 to Owner.ComponentCount - 1 do
      if (Owner.Components[K] is TIBTable) and
        (AnsiCompareText((Owner.Components[K] as TIBTable).TableName, FTables[I]) = 0) then
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

  // ���������� ����� �������� � ��.
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

  // ���������� ���������� Grid-��
  AssociateGrids;

  // ��������� ������
  ReadStoreKeys;

  if Assigned(FOnCustomGrid) then FOnCustomGrid(Self);

  // ���������� �������� ������
  OpenStoreTable(True);
  for I := 0 to FStores.Count - 1 do TRunTimeStore(FStores[I]).ReadData;
  CloseStoreTable;
end;

{
  �� ����������� ����� ���������� ������ ������.
}

procedure TmmIBRunTimeStore.DoOnDestroyForm(Sender: TObject);
var
  I: Integer;
begin
  if Assigned(OldOnDestroyForm) then OldOnDestroyForm(Sender);

  // ���������� ������ ������
  OpenStoreTable(False);
  for I := 0 to FStores.Count - 1 do TRunTimeStore(FStores[I]).SaveData;
  CloseStoreTable;
end;

{
  ���������� �������� ������� ��� ���������� ������.
}

procedure TmmIBRunTimeStore.OpenStoreTable(Reading: Boolean);
begin
  try
    if not FStoreDataSetTrans.InTransaction then
    begin
      FStoreDataSet.Database := FDatabase;
      FFieldsDataSet.Database := FDatabase;
      FStoreDataSetTrans.DefaultDatabase := FDatabase;

      FStoreDataSet.Close;
      FFieldsDataSet.Close;

      if not FStoreDataSetTrans.InTransaction then
        FStoreDataSetTrans.StartTransaction;

      {if FStoreDataSet.UniDirectional <> Reading then
      begin
        if FStoreDataSet.Prepared then FStoreDataSet.UnPrepare;
        if FFieldsDataSet.Preparedd then FFieldsDataSet.UnPrepare;

        FStoreDataSet.UniDirectional := Reaing;
        FFieldsDataSet.UniDirectional := Reading;
      end;}

      if not FStoreDataSet.Prepared then FStoreDataSet.Prepare;
      if not FFieldsDataSet.Prepared then FFieldsDataSet.Prepare;

      FStoreProc.Close;
      FStoreProc.Database := FDatabase;
      FStoreProc.StoredProcName := SP_STOREKEY;
    end;
  except
    // Nothing
  end;
end;

{
  ��������� ������� ������ ��� ���������� ��������.
}

procedure TmmIBRunTimeStore.CloseStoreTable;
begin
  FStoreDataSetTrans.Commit;

  FStoreDataSet.Close;
  FFieldsDataSet.Close;

//  if FStoreDataSet.Prepared then FStoreDataSet.UnPrepare;
//  if FFieldsDataSet.Prepared then FFieldsDataSet.UnPrepare;
end;

{
  ���������� ���������� ���������� � ������ �� �������.
}

procedure TmmIBRunTimeStore.ReadStoreKeys;
var
  I: Integer;
  CurrStore: TRunTimeStore;
  FindStore: TIBStoredProc;
begin
  FindStore := TIBStoredProc.Create(Self);
  try
    FindStore.Database := FDatabase;
    FindStore.StoredProcName := SP_FINDSTORE;
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
  �������� ������ ������.
}

procedure TmmIBRunTimeStore.SeTTables(const Value: TStringList);
begin
  FTables.Assign(Value);
end;

{
  ���������� ����� ������������� Grid-��.
}

procedure TmmIBRunTimeStore.AssociateGrids;
var
  I: Integer;
  Grid: TDBGrid;

  // ���������� ����� grid-�� � ���������� ��������� ��� ��. �������
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
      // �� ������, ���� � ��� ������
      if Grid is TmmDBGridTree then
        TRunTimeStore(FStores[I]).DataSet := Grid.DataSource.DataSet;

      TRunTimeStore(FStores[I]).Grid := Grid;
    end;
end;

{
  �������� ������ ��������.
}

procedure TmmIBRunTimeStore.SetQueries(const Value: TStringList);
begin
  FQueries.Assign(Value);
end;

{
  ���������� ���� ��������� ������� (������� ��� ��� ���). 
}

function TmmIBRunTimeStore.GetActiveStoreTable: Boolean;
begin
  if FStoreDataSet <> nil then
    Result := FStoreDataSet.Active
   else
     Result := False;
end;

{
  ���������� ����� ����������� ������ �� �������� �������.
}

function TmmIBRunTimeStore.FindStoreByName(ATableName: String; var Index: Integer): Boolean;
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

