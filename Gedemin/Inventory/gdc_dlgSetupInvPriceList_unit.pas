
{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gdc_dlgSetupInvPriceList_unit.pas

  Abstract

    Part of a business class.
    Price list document Setup.

  Author

    Romanovski Denis (22-09-2001)

  Revisions history

    Initial  22-09-2001  Dennis  Initial version.

--}

unit gdc_dlgSetupInvPriceList_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, ComCtrls, ExtCtrls, Db, ActnList, StdCtrls, Mask, DBCtrls,
  ImgList, TB2Item, TB2Dock, TB2Toolbar, IBCustomDataSet, gdcInvPriceList_unit,
  at_Classes, gdcInvConsts_unit, Contnrs, at_sql_metadata,
  gdcBase, IBSQL, gsIBLookupComboBox, gdc_dlgTR_unit, IBDatabase, gdcCurr,
  Grids, DBGrids, gsDBGrid, gsIBGrid, gdcMetaData, Menus;

type
  TinvPriceListField = class;

  TdlgSetupInvPriceList = class(Tgdc_dlgTR)
    pnlMain: TPanel;
    pcMain: TPageControl;
    tsCommon: TTabSheet;
    tsHeader: TTabSheet;
    tsLine: TTabSheet;
    lblDocumentName: TLabel;
    lblComment: TLabel;
    edDocumentName: TDBEdit;
    lvMasterAvailable: TListView;
    actAddMasterField: TAction;
    actEditMasterField: TAction;
    actDeleteMasterField: TAction;
    actSelectMasterField: TAction;
    actSelectMasterAllFields: TAction;
    actDeselectMasterField: TAction;
    actDeselectMasterAllFields: TAction;
    edDescription: TDBMemo;
    lvMasterUsed: TListView;
    btnMasterAdd: TButton;
    btnMasterAddAll: TButton;
    btnMasterRemove: TButton;
    btnMasterRemoveAll: TButton;
    lvDetailAvailable: TListView;
    lvDetailUsed: TListView;
    btnDetailAdd: TButton;
    btnDetailAddAll: TButton;
    btnDetailRemove: TButton;
    btnDetailRemoveAll: TButton;
    memoLineInfo: TMemo;
    memoHeaderInfo: TMemo;
    actSelectDetailField: TAction;
    actSelectDetailAllFields: TAction;
    actDeselectDetailField: TAction;
    actDeselectDetailAllFields: TAction;
    actAddDetailField: TAction;
    actEditDetailField: TAction;
    actDeleteDetailField: TAction;
    dsDetailRelationField: TDataSource;
    dsMasterRelationField: TDataSource;
    lblCurrency: TLabel;
    luCurrency: TgsIBLookupComboBox;
    lblContact: TLabel;
    luContact: TgsIBLookupComboBox;
    gdcPriceTableField: TgdcTableField;
    gdcPriceLineTableField: TgdcTableField;
    gdcHeaderTable: TgdcTable;
    gdcLineTable: TgdcTable;
    dsHeader: TDataSource;
    dsLine: TDataSource;
    Label1: TLabel;
    iblcHeaderTable: TgsIBLookupComboBox;
    Label2: TLabel;
    iblcLineTable: TgsIBLookupComboBox;
    lblExplorer: TLabel;
    ibcmbExplorer: TgsIBLookupComboBox;
    dbcbIsCommon: TDBCheckBox;
    lblParent: TLabel;
    edParentName: TEdit;
    lbEnglishName: TLabel;
    edEnglishName: TEdit;

    procedure pcMainChange(Sender: TObject);
    procedure pcMainChanging(Sender: TObject; var AllowChange: Boolean);

    procedure actSelectMasterFieldExecute(Sender: TObject);
    procedure actSelectMasterAllFieldsExecute(Sender: TObject);
    procedure actDeselectMasterFieldExecute(Sender: TObject);
    procedure actDeselectMasterAllFieldsExecute(Sender: TObject);

    procedure actSelectMasterFieldUpdate(Sender: TObject);
    procedure actSelectMasterAllFieldsUpdate(Sender: TObject);
    procedure actDeselectMasterFieldUpdate(Sender: TObject);
    procedure actDeselectMasterAllFieldsUpdate(Sender: TObject);

    procedure lvMasterUsedSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure lvDetailUsedDeletion(Sender: TObject; Item: TListItem);
    procedure lvDetailAvailableSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure lvDetailAvailableDeletion(Sender: TObject; Item: TListItem);
    procedure actSelectDetailFieldUpdate(Sender: TObject);
    procedure actSelectDetailFieldExecute(Sender: TObject);
    procedure actDeselectDetailFieldExecute(Sender: TObject);
    procedure iblcHeaderTableCreateNewObject(Sender: TObject;
      ANewObject: TgdcBase);
    procedure iblcLineTableCreateNewObject(Sender: TObject;
      ANewObject: TgdcBase);

  private
    FOperationCount: Integer; // Список операций по созданию полей с переподключением
    FMetaChangeCount: Integer; // Кол-во изменений в метаданных

    FHeaderFields, FLineFields: TObjectList; // Список выбранных полей прайс-листа

    FCurrency, FContact: TIBSQL; // запросы для валюты и контактов

    procedure UpdateInsertingSettings;
    procedure UpdateEditingSettings;

    procedure SetupCommonTab;
    procedure SetupHeaderTab;
    procedure SetupDetailTab;

    procedure TestLines;

    procedure PrepareDialog;

    function GetDocument: TgdcInvPriceListType;

    function GetPrice: TatRelation;
    function GetPriceLine: TatRelation;

    class function FindPriceField(AField: String; List: TObjectList): TinvPriceListField;
    procedure CreatePriceFieldObjects;

    procedure AddFeature(UsedFeatures, Features: TListView; IsDetail: Boolean);
    procedure RemoveFeature(UsedFeatures, Features: TListView);

  protected
    procedure ReadOptions(Stream: TStream);
    procedure WriteOptions(Stream: TStream);

    procedure BeforePost; override;

    property Price: TatRelation read GetPrice;
    property PriceLine: TatRelation read GetPriceLine;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetupDialog; override;
    procedure SetupRecord; override;

    function TestCorrect: Boolean; override;

    property Document: TgdcInvPriceListType read GetDocument;

  end;

  TinvPriceListField = class
  private
    FPriceField: TgdcInvPriceField;
    FLName: String;
    FFieldSource: String;

    FRelation: TatRelation;
    FIsUsed: Boolean;

    function Get_atField: TatField;

  protected

  public
    constructor Create(AFieldName, ALName, AFieldSource: String;
      ARelation: TatRelation);
    destructor Destroy; override;

    procedure ClearValues;
    procedure AssignValues(APriceField: TgdcInvPriceField;
      const AnIsUsed: Boolean = False);

    function CanBeUsedAsCurrency: Boolean;

    property LName: String read FLName;

    property FieldSource: String read FFieldSource;
    property atField: TatField read Get_atField;

    property PriceField: TgdcInvPriceField read FPriceField;
    property IsUsed: Boolean read FIsUsed;

  end;

  EdlgSetupInvPriceList = class(Exception);


var
  dlgSetupInvPriceList: TdlgSetupInvPriceList;

implementation

uses
  dmImages_unit, at_frmSQLProcess, Storages,  gd_ClassList, gdcExplorer, gdcClasses,
  gdcBaseInterface, gdcClasses_interface;

{$R *.DFM}

constructor TdlgSetupInvPriceList.Create(AOwner: TComponent);
begin
  inherited;

  FHeaderFields := TObjectList.Create;
  FLineFields := TObjectList.Create;

  FOperationCount := 0;
  FMetaChangeCount := 0;

  FCurrency := TIBSQL.Create(nil);
  FCurrency.SQL.Text := 'SELECT NAME FROM GD_CURR WHERE ID = :ID';

  FContact := TIBSQL.Create(nil);
  FContact.SQL.Text := 'SELECT NAME FROM GD_CONTACT WHERE ID = :ID';

end;

destructor TdlgSetupInvPriceList.Destroy;
begin
  FHeaderFields.Free;
  FLineFields.Free;

  FCurrency.Free;
  FContact.Free;

  inherited;
end;

function TdlgSetupInvPriceList.GetDocument: TgdcInvPriceListType;
begin
  Result := gdcObject as TgdcInvPriceListType;
end;

function TdlgSetupInvPriceList.GetPrice: TatRelation;
begin
  Result := atDatabase.Relations.ByRelationName('INV_PRICE');
  Assert(Result <> nil, 'Relation is not found');
end;

function TdlgSetupInvPriceList.GetPriceLine: TatRelation;
begin
  Result := atDatabase.Relations.ByRelationName('INV_PRICELINE');
  Assert(Result <> nil, 'Relation is not found');
end;

procedure TdlgSetupInvPriceList.pcMainChange(Sender: TObject);
begin
  if pcMain.ActivePage = tsCommon then
    SetupCommonTab else
  if pcMain.ActivePage = tsHeader then
    SetupHeaderTab else
  if pcMain.ActivePage = tsLine then
    SetupDetailTab;
end;

procedure TdlgSetupInvPriceList.pcMainChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  inherited;
//
end;

procedure TdlgSetupInvPriceList.PrepareDialog;
begin
  gdcHeaderTable.ID := Price.ID;
  gdcHeaderTable.Open;

  gdcLineTable.ID := PriceLine.ID;
  gdcLineTable.Open;

  FCurrency.Database := Document.Database;
  FCurrency.Transaction := Document.ReadTransaction;

  FContact.Database := Document.Database;
  FContact.Transaction := Document.ReadTransaction;

  pcMain.ActivePage := tsCommon;
  CreatePriceFieldObjects;
end;

procedure TdlgSetupInvPriceList.ReadOptions(Stream: TStream);
var
  Version: String;
  NewField: TgdcInvPriceField;
  PriceField: TinvPricelistField;
begin
  with TReader.Create(Stream, 1024) do
  try
    // Версия потока
    Version := ReadString;

    if Version <> gdcInvPrice_Version1_2 then
    // Тип документа считываем
      ReadInteger;

    // Ключ группы отчетов
    if (Version = gdcInvPrice_Version1_1) or
      (Version = gdcInvPrice_Version1_2) then
      {FReportGroupKey := ReadInteger
    else
      FReportGroupKey := -1;}
      ReadInteger;

    // Настройки шапки прайс-листа

    ReadListBegin;
    while not EndOfList do
    begin
      Read(NewField, SizeOf(TgdcInvPriceField));
      PriceField := FindPriceField(NewField.FieldName, FHeaderFields);

      if Assigned(PriceField) then
        PriceField.AssignValues(NewField, True);
    end;
    ReadListEnd;

    // Настройки позиции прайс-листа

    ReadListBegin;
    while not EndOfList do
    begin
      Read(NewField, SizeOf(TgdcInvPriceField));
      PriceField := FindPriceField(NewField.FieldName, FLineFields);

      if Assigned(PriceField) then
        PriceField.AssignValues(NewField, True);
    end;
    ReadListEnd;
  finally
    Free;
  end;
end;

procedure TdlgSetupInvPriceList.SetupCommonTab;
begin
  //
end;

procedure TdlgSetupInvPriceList.SetupDetailTab;
var
  Item: TListItem;
  I: Integer;
  CurrField: TinvPriceListField;
begin
  lblCurrency.Enabled := False;
  luCurrency.Enabled := False;

  lblContact.Enabled := False;
  luContact.Enabled := False;

  lvDetailAvailable.Items.Clear;
  lvDetailUsed.Items.Clear;

  CreatePriceFieldObjects;  

  for I := 0 to FLineFields.Count - 1 do
  begin
    CurrField := FLineFields[I] as TinvPriceListField;

    if CurrField.IsUsed then
      Item := lvDetailUsed.Items.Add
    else
      Item := lvDetailAvailable.Items.Add;

    Item.Caption := Trim(CurrField.LName);
    Item.Data := CurrField;
  end;
end;

procedure TdlgSetupInvPriceList.SetupHeaderTab;
var
  Item: TListItem;
  I: Integer;
  CurrField: TinvPriceListField;
begin
  CreatePriceFieldObjects;
  lvMasterAvailable.Items.Clear;
  lvMasterUsed.Items.Clear;

  for I := 0 to FHeaderFields.Count - 1 do
  begin
    CurrField := FHeaderFields[I] as TinvPriceListField;

    if CurrField.IsUsed then
      Item := lvMasterUsed.Items.Add
    else
      Item := lvMasterAvailable.Items.Add;

    Item.Caption := Trim(CurrField.LName);
    Item.Data := CurrField;
  end;
end;

function TdlgSetupInvPriceList.TestCorrect: Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TDLGSETUPINVPRICELIST', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TDLGSETUPINVPRICELIST', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TDLGSETUPINVPRICELIST') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TDLGSETUPINVPRICELIST',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TDLGSETUPINVPRICELIST' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  Result := inherited TestCorrect;

  if Result then
  begin
    TestLines;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TDLGSETUPINVPRICELIST', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TDLGSETUPINVPRICELIST', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

procedure TdlgSetupInvPriceList.UpdateEditingSettings;
begin
  SetupHeaderTab;
  SetupDetailTab;
end;

procedure TdlgSetupInvPriceList.UpdateInsertingSettings;
begin
  SetupHeaderTab;
  SetupDetailTab;
end;

procedure TdlgSetupInvPriceList.WriteOptions(Stream: TStream);
var
  I: Integer;
  rpgroupkey: Integer;
begin
  with TWriter.Create(Stream, 1024) do
  try
    // Версия потока
    WriteString(gdcInvPrice_Version1_2);

    rpgroupkey := Document.FieldByName('reportgroupkey').AsInteger;
    if not Document.UpdateReportGroup(
      'Прайс-листы',
      Document.FieldByName('name').AsString, rpgroupkey, True)
    then
      raise EdlgSetupInvPriceList.Create('Report Group Key not created!');

    Document.FieldByName('reportgroupkey').AsInteger := rpgroupkey;
    // Ключ группы отчетов записываем
    WriteInteger(rpgroupkey);

    // Настройки шапки прайс-листа

    WriteListBegin;
    for I := 0 to lvMasterUsed.Items.Count - 1 do
      Write(TInvPriceListField(lvMasterUsed.Items[I].Data).FPriceField,
        SizeOf(TgdcInvPriceField));
    WriteListEnd;

    // Настройки позиции прайс-листа

    WriteListBegin;
    for I := 0 to lvDetailUsed.Items.Count - 1 do
      Write(TInvPriceListField(lvDetailUsed.Items[I].Data).FPriceField,
        SizeOf(TgdcInvPriceField));
    WriteListEnd;
  finally
    Free;
  end;
end;

{ TinvPriceListField }

procedure TinvPriceListField.AssignValues(APriceField: TgdcInvPriceField;
  const AnIsUsed: Boolean = False);
begin
  FPriceField.CurrencyKey := APriceField.CurrencyKey;
  FPriceField.ContactKey := APriceField.ContactKey;
  FisUsed := AnIsUsed;
end;

function TinvPriceListField.CanBeUsedAsCurrency: Boolean;
begin
  Result := (atField.FieldType in [ftSmallInt, ftInteger, ftBCD,
    ftFloat, ftLargeInt, ftCurrency])
      and
    not Assigned(atField.RefTable) and
    not Assigned(atField.SetTable);
end;

procedure TinvPriceListField.ClearValues;
begin
  FPriceField.CurrencyKey := -1;
  FPriceField.ContactKey := -1;
end;

constructor TinvPriceListField.Create(AFieldName, ALName, AFieldSource: String;
  ARelation: TatRelation);
begin
  FPriceField.FieldName := AFieldName;

  FLName := ALName;
  FFieldSource := AFieldSource;

  ClearValues;

  FRelation := ARelation;
end;

destructor TinvPriceListField.Destroy;
begin
  inherited;
end;

procedure TdlgSetupInvPriceList.TestLines;
begin
  if lvDetailUsed.Items.Count = 0 then
  begin
    pcMain.ActivePage := tsLine;
    raise EdlgSetupInvPriceList.Create(
      'Не указано ни одно поле для позиции прайс-листа!');
  end;
end;

procedure TdlgSetupInvPriceList.actSelectMasterFieldExecute(
  Sender: TObject);
begin
  if not actSelectMasterField.Enabled then
    exit;

  AddFeature(lvMasterUsed, lvMasterAvailable, False);
end;

procedure TdlgSetupInvPriceList.actSelectMasterAllFieldsExecute(
  Sender: TObject);
var
  I: Integer;
  Used, Available: TListView;
  CurrField: TinvPriceListField;
begin
  if Sender = actSelectMasterAllFields then
  begin
    Used := lvMasterUsed;
    Available := lvMasterAvailable;
  end else begin
    Used := lvDetailUsed;
    Available := lvDetailAvailable;
  end;

  for I := 0 to Available.Items.Count - 1 do
  with Used.Items.Add do
  begin
    Caption := Available.Items[I].Caption;
    Data := Available.Items[I].Data;
    CurrField := Data;
    CurrField.FIsUsed := True;

    if Sender = actSelectDetailAllFields then
    begin
      if CurrField.CanBeUsedAsCurrency then
        CurrField.FPriceField.CurrencyKey := luCurrency.CurrentKeyInt
      else
        CurrField.FPriceField.CurrencyKey := -1;

      if luContact.CurrentKey > '' then
        CurrField.FPriceField.ContactKey := luContact.CurrentKeyInt else
        CurrField.FPriceField.ContactKey := -1;
    end;
  end;
  Available.Items.Clear;
end;

procedure TdlgSetupInvPriceList.actDeselectMasterFieldExecute(
  Sender: TObject);
begin
  if not actDeselectMasterField.Enabled then
    exit;

  RemoveFeature(lvMasterUsed, lvMasterAvailable);
end;

procedure TdlgSetupInvPriceList.actDeselectMasterAllFieldsExecute(
  Sender: TObject);
var
  I: Integer;
  Used, Available: TListView;
  CurrField: TinvPriceListField;
begin
  if Sender = actDeselectMasterAllFields then
  begin
    Used := lvMasterUsed;
    Available := lvMasterAvailable;
  end else begin
    Used := lvDetailUsed;
    Available := lvDetailAvailable;
  end;

  for I := 0 to Used.Items.Count - 1 do
  with Available.Items.Add do
  begin
    Caption := Used.Items[I].Caption;
    Data := Used.Items[I].Data;
    CurrField := Data;

    if CurrField.atField.IsNullable then
      CurrField.FIsUsed := False;
  end;
  Used.Items.Clear;
end;

procedure TdlgSetupInvPriceList.actSelectMasterFieldUpdate(
  Sender: TObject);
begin
  actSelectMasterField.Enabled := lvMasterAvailable.Selected <> nil;
end;

procedure TdlgSetupInvPriceList.actSelectMasterAllFieldsUpdate(
  Sender: TObject);
begin
  if Sender = actSelectMasterAllFields then
    actSelectMasterAllFields.Enabled := lvMasterAvailable.Items.Count > 0
  else
    actSelectDetailAllFields.Enabled :=
      (lvDetailAvailable.Items.Count > 0) and (luCurrency.CurrentKey > '');
end;

procedure TdlgSetupInvPriceList.actDeselectMasterFieldUpdate(
  Sender: TObject);
begin
  if Sender = actDeselectMasterField then
    actDeselectMasterField.Enabled := lvMasterUsed.Selected <> nil
  else
    actDeselectDetailField.Enabled := lvDetailUsed.Selected <> nil;
end;

procedure TdlgSetupInvPriceList.actDeselectMasterAllFieldsUpdate(
  Sender: TObject);
begin
  if Sender = actDeselectMasterAllFields then
    actDeselectMasterAllFields.Enabled := lvMasterUsed.Items.Count > 0
  else
    actDeselectDetailAllFields.Enabled := lvDetailUsed.Items.Count > 0;
end;

procedure TdlgSetupInvPriceList.lvMasterUsedSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  Memo: TMemo;
  CurrField: TinvPriceListField;
begin
  if Sender = lvMasterUsed then
    Memo := memoHeaderInfo else
    Memo := memoLineInfo;

  memo.Lines.Clear;
  if (Item = nil) or not Selected then Exit;

  CurrField := Item.Data;
  memo.Lines.Add(Format('Поле "%s":', [Trim(CurrField.LName)]));

  if not CurrField.atField.IsNullable then
    memo.Lines.Add('является обязательным для заполнения')
  else
    memo.Lines.Add('не является обязательным для заполнения');

  if Sender = lvDetailUsed then
  begin
    if CurrField.PriceField.CurrencyKey <> -1 then
    begin
      FCurrency.ParamByName('ID').AsInteger := CurrField.PriceField.CurrencyKey;
      FCurrency.ExecQuery;
      memo.Lines.Add(Format('Валюта: %s', [FCurrency.Fields[0].AsString]));
      FCurrency.Close;
    end;

    if CurrField.PriceField.ContactKey <> -1 then
    begin
      FContact.ParamByName('ID').AsInteger := CurrField.PriceField.ContactKey;
      FContact.ExecQuery;
      memo.Lines.Add(Format('Контакт: %s', [FContact.Fields[0].AsString]));
      FContact.Close;
    end;
  end;
end;

function TinvPriceListField.Get_atField: TatField;
begin
  Result := atDatabase.Fields.ByFieldName(FFieldSource);
end;

procedure TdlgSetupInvPriceList.lvDetailUsedDeletion(Sender: TObject;
  Item: TListItem);
var
  Memo: TMemo;
begin
  if Sender = lvMasterUsed then
    Memo := memoHeaderInfo else
    Memo := memoLineInfo;

  with (Sender as TListView) do
  if (Selected = nil) or (Items.Count = 1) then
    Memo.Clear;
end;

procedure TdlgSetupInvPriceList.lvDetailAvailableSelectItem(
  Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  lblCurrency.Enabled := Selected and Assigned(Item);
  luCurrency.Enabled := Selected and Assigned(Item);

  lblContact.Enabled := Selected and Assigned(Item);
  luContact.Enabled := Selected and Assigned(Item);
end;

procedure TdlgSetupInvPriceList.lvDetailAvailableDeletion(Sender: TObject;
  Item: TListItem);
begin
  with (Sender as TListView) do
  begin
    lblCurrency.Enabled := (Items.Count > 1) and (Selected <> nil);
    luCurrency.Enabled := (Items.Count > 1) and (Selected <> nil);

    lblContact.Enabled := (Items.Count > 1) and (Selected <> nil);
    luContact.Enabled := (Items.Count > 1) and (Selected <> nil);
  end;
end;

class function TdlgSetupInvPriceList.FindPriceField(AField: String;
  List: TObjectList): TinvPriceListField;
var
  I: Integer;
begin
  for I := 0 to List.Count - 1 do
    if AnsiCompareText((List[I] as TinvPriceListField).PriceField.FieldName,
      AField) = 0 then
    begin
      Result := List[I] as TinvPriceListField;
      Exit;
    end;

  Result := nil;
end;

procedure TdlgSetupInvPriceList.CreatePriceFieldObjects;

  procedure CreateList(DataSet: TgdcBase; List: TObjectList; Relation: TatRelation);
  var
    Field: TinvPriceListField;
  begin
    DataSet.First;
    while not DataSet.EOF do
    begin
      if
        (AnsiPos(UserPrefix, DataSet.FieldByName('FIELDNAME').AsString) = 1) and
        (FindPriceField(DataSet.FieldByName('FIELDNAME').AsString, List) = nil)
      then begin
        Field := TinvPriceListField.Create(
          DataSet.FieldByName('FIELDNAME').AsString,
          DataSet.FieldByName('LNAME').AsString,
          DataSet.FieldByName('FIELDSOURCE').AsString,
          Relation
        );

        Field.FIsUsed := not Field.atField.IsNullable;
        List.Add(Field);
      end;

      DataSet.Next;
    end;
  end;
begin
  gdcLineTable.Close;
  gdcLineTable.Open;
  CreateList(gdcPriceTableField, FHeaderFields, Price);
  gdcHeaderTable.Close;
  gdcHeaderTable.Open;
  CreateList(gdcPriceLineTableField, FLineFields, PriceLine);
end;

procedure TdlgSetupInvPriceList.BeforePost;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Stream: TStringStream;
var
  gdcExplorer: TgdcExplorer;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TDLGSETUPINVPRICELIST', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TDLGSETUPINVPRICELIST', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TDLGSETUPINVPRICELIST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TDLGSETUPINVPRICELIST',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TDLGSETUPINVPRICELIST' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if ibcmbExplorer.Enabled then
  begin
    gdcExplorer := TgdcExplorer.CreateSubType(nil, '', 'ByID');
    try
      gdcExplorer.Transaction := gdcObject.Transaction;
      gdcExplorer.ReadTransaction := gdcObject.ReadTransaction;
      if (gdcObject.FieldByName('branchkey').IsNull) and
        (ibcmbExplorer.CurrentKeyInt > 0)
      then
      begin
        {если у нас не было ветки в исследователе и мы захотели ее создать}
        gdcExplorer.Open;
        gdcExplorer.Insert;
        gdcExplorer.FieldByName('parent').AsInteger := ibcmbExplorer.CurrentKeyInt;
        gdcExplorer.FieldByName('name').AsString := gdcObject.FieldByName('name').AsString;
        gdcExplorer.FieldByName('classname').AsString :=
          (gdcObject as TgdcDocumentType).GetHeaderDocumentClass.ClassName;
        gdcExplorer.FieldByName('subtype').AsString := gdcObject.FieldByName('ruid').AsString;
        gdcExplorer.FieldByName('cmd').AsString := gdcObject.FieldByName('ruid').AsString;
        gdcExplorer.FieldByName('cmdtype').AsInteger := cst_expl_cmdtype_class;
        gdcExplorer.Post;
        gdcObject.FieldByName('branchkey').AsInteger := gdcExplorer.ID;
      end
      else if (gdcObject.FieldByName('branchkey').AsInteger > 0) and
        (ibcmbExplorer.CurrentKeyInt = -1)
      then
      begin
        {если у нас была ветка в исследователе и мы захотели ее удалить}
        gdcExplorer.ID := gdcObject.FieldByName('branchkey').AsInteger;
        gdcExplorer.Open;
        if gdcExplorer.RecordCount > 0 then
        begin
          gdcExplorer.Delete;
        end;
        gdcObject.FieldByName('branchkey').Clear;
      end
      else if (gdcObject.FieldByName('branchkey').AsInteger > 0) and
        (ibcmbExplorer.CurrentKeyInt > 0)
      then
      begin
        {если у нас была ветка в исследователе, подредактируем ее и заменим наименование, родителя}
        gdcExplorer.ID := gdcObject.FieldByName('branchkey').AsInteger;
        gdcExplorer.Open;
        if (gdcExplorer.RecordCount = 0) or
          (gdcExplorer.FieldByName('subtype').AsString <> gdcObject.FieldByName('ruid').AsString) then
        begin
          gdcExplorer.Insert;
          gdcExplorer.FieldByName('parent').AsInteger := ibcmbExplorer.CurrentKeyInt;
          gdcExplorer.FieldByName('name').AsString := gdcObject.FieldByName('name').AsString;
          gdcExplorer.FieldByName('classname').AsString :=
            (gdcObject as TgdcDocumentType).GetHeaderDocumentClass.ClassName;
          gdcExplorer.FieldByName('subtype').AsString := gdcObject.FieldByName('ruid').AsString;
          gdcExplorer.FieldByName('cmd').AsString := gdcObject.FieldByName('ruid').AsString;
          gdcExplorer.FieldByName('cmdtype').AsInteger := cst_expl_cmdtype_class;
          gdcExplorer.Post;
          gdcObject.FieldByName('branchkey').AsInteger := gdcExplorer.ID;
        end else
        begin
          gdcExplorer.Edit;
          gdcExplorer.FieldByName('parent').AsInteger := ibcmbExplorer.CurrentKeyInt;
          gdcExplorer.FieldByName('name').AsString := gdcObject.FieldByName('name').AsString;
          gdcExplorer.Post;
        end;
      end;
    finally
      gdcExplorer.Free
    end;
  end;

  Stream := TStringStream.Create('');
  try
    WriteOptions(Stream);
    Document.FieldByName('OPTIONS').AsString := Stream.DataString;
  finally
    Stream.Free;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TDLGSETUPINVPRICELIST', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TDLGSETUPINVPRICELIST', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure TdlgSetupInvPriceList.SetupDialog;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TDLGSETUPINVPRICELIST', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TDLGSETUPINVPRICELIST', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TDLGSETUPINVPRICELIST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TDLGSETUPINVPRICELIST',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TDLGSETUPINVPRICELIST' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  
  gdcHeaderTable.QueryFiltered := False;
  gdcPriceTableField.QueryFiltered := False;

  PrepareDialog;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TDLGSETUPINVPRICELIST', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TDLGSETUPINVPRICELIST', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

procedure TdlgSetupInvPriceList.SetupRecord;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Stream: TStream;
  ibsql: TIBSQL;
  DE: TgdDocumentEntry;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TDLGSETUPINVPRICELIST', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TDLGSETUPINVPRICELIST', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TDLGSETUPINVPRICELIST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TDLGSETUPINVPRICELIST',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TDLGSETUPINVPRICELIST' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  ActivateTransaction(gdcObject.Transaction);
  edParentName.Text := '';

  edEnglishName.Text := '';
  edEnglishName.MaxLength := 14;

  if gdcObject.State = dsEdit then
  begin
    DE := gdClassList.FindDocByTypeID(gdcObject.FieldByName('id').AsInteger, dcpHeader);
    if DE <> nil then
      edEnglishName.Text := DE.HeaderRelName;
  end;


  DE := gdClassList.FindDocByTypeID(gdcObject.FieldByName('parent').AsInteger, dcpHeader);
  if DE = nil then
  begin
    iblcHeaderTable.CurrentKey := IntToStr(Price.ID);
    iblcHeaderTable.Condition := 'ID = ' + IntToStr(Price.ID);
    iblcLineTable.CurrentKey := IntToStr(PriceLine.ID);
    iblcLineTable.Condition := 'ID = ' + IntToStr(PriceLine.ID);
  end
  else
  begin
    edParentName.Text := DE.Caption;
    if gdcObject.State = dsInsert then
    begin
      gdcObject.FieldByName('name').AsString := 'Наследник ' + DE.Caption;
      gdcObject.FieldByName('branchkey').AsInteger := DE.BranchKey;
      gdcObject.FieldByName('headerrelkey').AsInteger := DE.HeaderRelKey;
      gdcObject.FieldByName('linerelkey').AsInteger := DE.LineRelKey;
      edEnglishName.Text := DE.HeaderRelName;
    end;

    iblcHeaderTable.gdClassName := 'TgdcInheritedTable';
    iblcLineTable.gdClassName := 'TgdcInheritedTable';
  end;

  if Document.State in [dsEdit, dsInsert] then
  begin
    if not Document.FieldByName('OPTIONS').IsNull then
    begin
      Stream := TStringStream.Create(Document.FieldByName('OPTIONS').AsString);
      try
        ReadOptions(Stream);
      finally
        Stream.Free;
      end;
    end;

    if Document.State = dsEdit then
      UpdateEditingSettings
    else
      UpdateInsertingSettings;
  end;

  //Выведем родителя нашей ветки в исследователе
  if (gdcObject.FieldByName('branchkey').AsInteger > 0) then
  begin
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.Transaction := gdcBaseManager.ReadTRansaction;
      ibsql.SQL.Text := 'SELECT parent FROM gd_command WHERE id = :id';
      ibsql.ParamByName('id').AsInteger := gdcObject.FieldByName('branchkey').AsInteger;
      ibsql.ExecQuery;

      if (ibsql.RecordCount > 0) and (ibsql.FieldByName('parent').AsInteger > 0) then
        ibcmbExplorer.CurrentKeyInt := ibsql.FieldByName('parent').AsInteger;
    finally
      ibsql.Free;
    end;
  end;

  //Для редактирования нескольких веток запрещаем изменении ветки исследователя
  ibcmbExplorer.Enabled := not (sMultiple in gdcObject.BaseState);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TDLGSETUPINVPRICELIST', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TDLGSETUPINVPRICELIST', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure TdlgSetupInvPriceList.actSelectDetailFieldUpdate(
  Sender: TObject);
begin
  actSelectDetailField.Enabled :=
    (lvDetailAvailable.Selected <> nil)
      and
    (
      not TinvPriceListField(lvDetailAvailable.Selected.Data).CanBeUsedAsCurrency
        or
      (luCurrency.CurrentKey > '')
    );
end;

procedure TdlgSetupInvPriceList.actSelectDetailFieldExecute(
  Sender: TObject);
begin
  if not actSelectDetailField.Enabled then
    exit;

  AddFeature(lvDetailUsed, lvDetailAvailable, True)
end;

procedure TdlgSetupInvPriceList.AddFeature(UsedFeatures,
  Features: TListView; IsDetail: Boolean);
var
  Used, Available: TListView;
  I: Integer;
  CurrField: TinvPriceListField;
begin
  Used := UsedFeatures;
  Available := Features;

  with Used.Items.Add do
  begin
    Caption := Available.Selected.Caption;
    Data := Available.Selected.Data;
    CurrField := Data;
    CurrField.FIsUsed := True;

    if IsDetail then
    begin
      CurrField.FPriceField.CurrencyKey := luCurrency.CurrentKeyInt;

      if luContact.CurrentKey > '' then
        CurrField.FPriceField.ContactKey := luContact.CurrentKeyInt else
        CurrField.FPriceField.ContactKey := -1;
    end;

    I := Available.Selected.Index;
    Available.Selected.Delete;

    if I < Available.Items.Count then
      Available.Selected := Available.Items[I]
    else
      Available.Selected := Available.Items[Available.Items.Count - 1];
  end;
end;

procedure TdlgSetupInvPriceList.actDeselectDetailFieldExecute(
  Sender: TObject);
begin
  if not actDeselectDetailField.Enabled then
    exit;

  RemoveFeature(lvDetailUsed, lvDetailAvailable)
end;

procedure TdlgSetupInvPriceList.RemoveFeature(UsedFeatures,
  Features: TListView);
var
  Used, Available: TListView;
  I: Integer;
  CurrField: TinvPriceListField;
begin
  Used := UsedFeatures;
  Available := Features;

  with Available.Items.Add do
  begin
    Caption := Used.Selected.Caption;
    Data := Used.Selected.Data;
    CurrField := Data;

    if not CurrField.atField.IsNullable then
      raise EdlgSetupInvPriceList.Create(
        'Поле является обязательным и должно присутствовать в прайс-листе!')
    else
      CurrField.FIsUsed := False;

    I := Used.Selected.Index;
    Used.Selected.Delete;

    if I < Used.Items.Count then
      Used.Selected := Used.Items[I]
    else
      Used.Selected := Used.Items[Used.Items.Count - 1];
  end;
end;

procedure TdlgSetupInvPriceList.iblcHeaderTableCreateNewObject(
  Sender: TObject; ANewObject: TgdcBase);
begin
  if not CheckEnName(edEnglishName.Text) then
  begin
    edEnglishName.Show;
    raise EgdcIBError.Create(
      'В наименовании на английском должны быть только латинские символы');
  end;

  if gdcObject.State <> dsInsert then
    abort
  else
  begin
    if Pos(UserPrefix, UpperCase(edEnglishName.Text)) = 0 then
      edEnglishName.Text := UserPrefix + edEnglishName.Text;
    aNewObject.FieldByName('relationname').AsString := edEnglishName.Text;
    aNewObject.FieldByName('lname').AsString := edDocumentName.Text;
    aNewObject.FieldByName('lshortname').AsString := aNewObject.FieldByName('lname').AsString;
  end;
end;

procedure TdlgSetupInvPriceList.iblcLineTableCreateNewObject(
  Sender: TObject; ANewObject: TgdcBase);
begin
  if not CheckEnName(edEnglishName.Text) then
  begin
    edEnglishName.Show;
    raise EgdcIBError.Create('В наименовании на английском должны быть только латинские символы');
  end;

  if Pos(UserPrefix, UpperCase(edEnglishName.Text)) = 0 then
    edEnglishName.Text := UserPrefix + edEnglishName.Text;
  aNewObject.FieldByName('relationname').AsString := edEnglishName.Text + 'LINE';
  aNewObject.FieldByName('lname').AsString := edDocumentName.Text + '(позиция)';
  aNewObject.FieldByName('lshortname').AsString := aNewObject.FieldByName('lname').AsString;
end;

initialization
  RegisterFrmClass(TdlgSetupInvPriceList);

finalization
  UnRegisterFrmClass(TdlgSetupInvPriceList);

end.

