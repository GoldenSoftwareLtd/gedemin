
{++

  Copyright (c) 2001-2015 by Golden Software of Belarus

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
  at_Classes, gdcInvConsts_unit, Contnrs, at_sql_metadata, gd_ClassList,
  gdcBase, IBSQL, gsIBLookupComboBox, gdc_dlgTR_unit, IBDatabase, gdcCurr,
  Grids, DBGrids, gsDBGrid, gsIBGrid, gdcMetaData, Menus;

type
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
    procedure edEnglishNameChange(Sender: TObject);

  private
    FHeaderFields, FLineFields: TObjectList; // ������ ��������� ����� �����-�����

    procedure SetupCommonTab;
    procedure SetupHeaderTab;
    procedure SetupDetailTab;

    function GetDocument: TgdcInvPriceListType;
    function GetPrice: TatRelation;
    function GetPriceLine: TatRelation;
    function GetIPDE: TgdInvPriceDocumentEntry;

    class function FindPriceField(AField: String; List: TObjectList): TinvPriceListField;
    procedure CreatePriceFieldObjects;

    procedure AddFeature(UsedFeatures, Features: TListView; IsDetail: Boolean);
    procedure RemoveFeature(UsedFeatures, Features: TListView);

  protected
    procedure ReadOptions;
    procedure WriteOptions(Stream: TStream);

    function DlgModified: Boolean; override;
    procedure BeforePost; override;
    procedure SetupDialog; override;
    procedure SetupRecord; override;
    function TestCorrect: Boolean; override;
    procedure Post; override;
    procedure AfterPost; override;

    property Price: TatRelation read GetPrice;
    property PriceLine: TatRelation read GetPriceLine;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Document: TgdcInvPriceListType read GetDocument;
  end;

  EdlgSetupInvPriceList = class(Exception);

var
  dlgSetupInvPriceList: TdlgSetupInvPriceList;

implementation

uses
  dmImages_unit, at_frmSQLProcess, Storages, gdcExplorer, gdcClasses,
  gdcBaseInterface, gdcClasses_interface;

{$R *.DFM}

constructor TdlgSetupInvPriceList.Create(AOwner: TComponent);
begin
  inherited;
  FHeaderFields := TObjectList.Create;
  FLineFields := TObjectList.Create;
end;

destructor TdlgSetupInvPriceList.Destroy;
begin
  FHeaderFields.Free;
  FLineFields.Free;
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

procedure TdlgSetupInvPriceList.ReadOptions;
var
  PriceField: TinvPricelistField;
  I: Integer;
  FIPDE: TgdInvPriceDocumentEntry;
begin
  CreatePriceFieldObjects;

  FIPDE := GetIPDE;

  if FIPDE = nil then
    exit;

  for I := Low(FIPDE.HeaderFields) to High(FIPDE.HeaderFields) do
  begin
    PriceField := FindPriceField(FIPDE.HeaderFields[I].FieldName, FHeaderFields);
    if PriceField <> nil then
      PriceField.AssignValues(FIPDE.HeaderFields[I], True);
  end;

  for I := Low(FIPDE.LineFields) to High(FIPDE.LineFields) do
  begin
    PriceField := FindPriceField(FIPDE.LineFields[I].FieldName, FLineFields);
    if PriceField <> nil then
      PriceField.AssignValues(FIPDE.LineFields[I], True);
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

    if CurrField.FIsUsed then
      Item := lvDetailUsed.Items.Add
    else
      Item := lvDetailAvailable.Items.Add;

    Item.Caption := Trim(CurrField.FLName);
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

    if CurrField.FIsUsed then
      Item := lvMasterUsed.Items.Add
    else
      Item := lvMasterAvailable.Items.Add;

    Item.Caption := Trim(CurrField.FLName);
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

  if gdClassList.OldOptions then
  begin
    MessageBox(Handle,
      '���������� ��������������� ��������� ���� ��������� � ����� ������!',
      '��������',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
    Result := False;
    exit;
  end;

  Result := inherited TestCorrect;

  if Result then
  begin
    if lvDetailUsed.Items.Count = 0 then
    begin
      pcMain.ActivePage := tsLine;
      raise EdlgSetupInvPriceList.Create(
        '�� ������� �� ���� ���� ��� ������� �����-�����!');
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TDLGSETUPINVPRICELIST', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TDLGSETUPINVPRICELIST', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

procedure TdlgSetupInvPriceList.WriteOptions(Stream: TStream);
var
  I: Integer;
  rpgroupkey: TID;
begin
  with TWriter.Create(Stream, 1024) do
  try
    // ������ ������
    WriteString(gdcInvPrice_Version1_2);

    rpgroupkey := GetTID(Document.FieldByName('reportgroupkey'));
    if not Document.UpdateReportGroup(
      '�����-�����',
      Document.FieldByName('name').AsString, rpgroupkey, True)
    then
      raise EdlgSetupInvPriceList.Create('Report Group Key not created!');

    SetTID(Document.FieldByName('reportgroupkey'), rpgroupkey);
    // ���� ������ ������� ����������
    WriteInteger(rpgroupkey);

    // ��������� ����� �����-�����

    WriteListBegin;
    for I := 0 to lvMasterUsed.Items.Count - 1 do
      Write(TInvPriceListField(lvMasterUsed.Items[I].Data).FPriceField,
        SizeOf(TgdcInvPriceField));
    WriteListEnd;

    // ��������� ������� �����-�����

    WriteListBegin;
    for I := 0 to lvDetailUsed.Items.Count - 1 do
      Write(TInvPriceListField(lvDetailUsed.Items[I].Data).FPriceField,
        SizeOf(TgdcInvPriceField));
    WriteListEnd;
  finally
    Free;
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
        CurrField.FPriceField.ContactKey := luContact.CurrentKeyInt
      else
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
  R: OleVariant;
begin
  if Sender = lvMasterUsed then
    Memo := memoHeaderInfo else
    Memo := memoLineInfo;

  memo.Lines.Clear;
  if (Item = nil) or not Selected then Exit;

  CurrField := Item.Data;
  memo.Lines.Add(Format('���� "%s":'#13#10, [CurrField.FLName]));

  if not CurrField.atField.IsNullable then
    memo.Lines.Add('����������� ��� ����������'#13#10)
  else
    memo.Lines.Add('�� ����������� ��� ����������'#13#10);

  if Sender = lvDetailUsed then
  begin
    if gdcBaseManager.ExecSingleQueryResult('SELECT name FROM gd_curr WHERE id = :id',
      TID2V(CurrField.FPriceField.CurrencyKey), R) then
    begin
      memo.Lines.Add('������: ' + R[0, 0] + #13#10);
    end;

    if gdcBaseManager.ExecSingleQueryResult('SELECT name FROM gd_contact WHERE id = :id',
      TID2V(CurrField.FPriceField.ContactKey), R) then
    begin
      memo.Lines.Add('�����������: ' + R[0, 0] + #13#10);
    end;
  end;
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
  List: TObjectList): TInvPriceListField;
var
  I: Integer;
begin
  for I := 0 to List.Count - 1 do
    if AnsiSameText((List[I] as TinvPriceListField).FPriceField.FieldName, AField) then
    begin
      Result := List[I] as TinvPriceListField;
      exit;
    end;

  Result := nil;
end;

procedure TdlgSetupInvPriceList.CreatePriceFieldObjects;

  procedure CreateList(List: TObjectList; Relation: TatRelation);
  var
    Field: TinvPriceListField;
    I: Integer;
  begin
    for I := 0 to Relation.RelationFields.Count - 1 do
    begin
      if Relation.RelationFields[I].IsUserDefined and
        (FindPriceField(Relation.RelationFields[I].FieldName, List) = nil) then
      begin
        Field := TinvPriceListField.Create(
          Relation.RelationFields[I].FieldName,
          Relation.RelationFields[I].LName,
          Relation.RelationFields[I].Field.FieldName,
          Relation
        );

        Field.FIsUsed := not Relation.RelationFields[I].IsNullable;
        List.Add(Field);
      end;
    end;
  end;

begin
  CreateList(FHeaderFields, Price);
  CreateList(FLineFields, PriceLine);
end;

procedure TdlgSetupInvPriceList.BeforePost;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
var
  gdcExplorer: TgdcExplorer;
  Stream: TStringStream;
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
        {���� � ��� �� ���� ����� � ������������� � �� �������� �� �������}
        gdcExplorer.Open;
        gdcExplorer.Insert;
        SetTID(gdcExplorer.FieldByName('parent'), ibcmbExplorer.CurrentKeyInt);
        gdcExplorer.FieldByName('name').AsString := gdcObject.FieldByName('name').AsString;
        gdcExplorer.FieldByName('classname').AsString :=
          (gdcObject as TgdcDocumentType).GetHeaderDocumentClass.ClassName;
        gdcExplorer.FieldByName('subtype').AsString := gdcObject.FieldByName('ruid').AsString;
        gdcExplorer.FieldByName('cmd').AsString := gdcObject.FieldByName('ruid').AsString;
        gdcExplorer.FieldByName('cmdtype').AsInteger := cst_expl_cmdtype_class;
        gdcExplorer.Post;
        SetTID(gdcObject.FieldByName('branchkey'), gdcExplorer.ID);
      end
      else if (GetTID(gdcObject.FieldByName('branchkey')) > 0) and
        (ibcmbExplorer.CurrentKeyInt = -1)
      then
      begin
        {���� � ��� ���� ����� � ������������� � �� �������� �� �������}
        gdcExplorer.ID := GetTID(gdcObject.FieldByName('branchkey'));
        gdcExplorer.Open;
        if gdcExplorer.RecordCount > 0 then
        begin
          gdcExplorer.Delete;
        end;
        gdcObject.FieldByName('branchkey').Clear;
      end
      else if (GetTID(gdcObject.FieldByName('branchkey')) > 0) and
        (ibcmbExplorer.CurrentKeyInt > 0)
      then
      begin
        {���� � ��� ���� ����� � �������������, �������������� �� � ������� ������������, ��������}
        gdcExplorer.ID := GetTID(gdcObject.FieldByName('branchkey'));
        gdcExplorer.Open;
        if (gdcExplorer.RecordCount = 0) or
          (gdcExplorer.FieldByName('subtype').AsString <> gdcObject.FieldByName('ruid').AsString) then
        begin
          gdcExplorer.Insert;
          SetTID(gdcExplorer.FieldByName('parent'), ibcmbExplorer.CurrentKeyInt);
          gdcExplorer.FieldByName('name').AsString := gdcObject.FieldByName('name').AsString;
          gdcExplorer.FieldByName('classname').AsString :=
            (gdcObject as TgdcDocumentType).GetHeaderDocumentClass.ClassName;
          gdcExplorer.FieldByName('subtype').AsString := gdcObject.FieldByName('ruid').AsString;
          gdcExplorer.FieldByName('cmd').AsString := gdcObject.FieldByName('ruid').AsString;
          gdcExplorer.FieldByName('cmdtype').AsInteger := cst_expl_cmdtype_class;
          gdcExplorer.Post;
          SetTID(gdcObject.FieldByName('branchkey'), gdcExplorer.ID);
        end else
        begin
          gdcExplorer.Edit;
          SetTID(gdcExplorer.FieldByName('parent'), ibcmbExplorer.CurrentKeyInt);
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
  DE: TgdDocumentEntry;
  R: OleVariant;
  IPDEParent: TgdInvPriceDocumentEntry;
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

  DE := gdClassList.FindDocByTypeID(GetTID(gdcObject.FieldByName('parent')), dcpHeader, True);
  if DE is TgdInvPriceDocumentEntry then
    IPDEParent := DE as TgdInvPriceDocumentEntry
  else
    IPDEParent := nil;

  ActivateTransaction(gdcObject.Transaction);

  if IPDEParent <> nil then
  begin
    edParentName.Text := IPDEParent.Caption;

    if gdcObject.State = dsInsert then
    begin
      gdcObject.FieldByName('name').AsString := '��������� ' + IPDEParent.Caption;
      SetTID(gdcObject.FieldByName('branchkey'), IPDEParent.BranchKey);
    end;
  end else
    edParentName.Text := '';

  edEnglishName.Text := Price.RelationName;
  iblcHeaderTable.CurrentKeyInt := Price.ID;
  iblcHeaderTable.Condition := 'ID = ' + IntToStr(Price.ID);
  iblcLineTable.CurrentKeyInt := PriceLine.ID;
  iblcLineTable.Condition := 'ID = ' + IntToStr(PriceLine.ID);

  if Document.State in [dsEdit, dsInsert] then
  begin
    ReadOptions;
    SetupHeaderTab;
    SetupDetailTab;
  end;

  //������� �������� ����� ����� � �������������
  if gdcBaseManager.ExecSingleQueryResult('SELECT parent FROM gd_command WHERE id = :id',
    TID2V(gdcObject.FieldByName('branchkey')), R) then
  begin
    ibcmbExplorer.CurrentKeyInt := GetTID(R[0, 0]);
  end;

  //��� �������������� ���������� ����� ��������� ��������� ����� �������������
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
        '���� �������� ������������ � ������ �������������� � �����-�����!')
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
      '� ������������ �� ���������� ������ ���� ������ ��������� �������');
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
    raise EgdcIBError.Create('� ������������ �� ���������� ������ ���� ������ ��������� �������');
  end;

  if Pos(UserPrefix, UpperCase(edEnglishName.Text)) = 0 then
    edEnglishName.Text := UserPrefix + edEnglishName.Text;
  aNewObject.FieldByName('relationname').AsString := edEnglishName.Text + 'LINE';
  aNewObject.FieldByName('lname').AsString := edDocumentName.Text + '(�������)';
  aNewObject.FieldByName('lshortname').AsString := aNewObject.FieldByName('lname').AsString;
end;

procedure TdlgSetupInvPriceList.edEnglishNameChange(Sender: TObject);
begin
  if (gdcObject <> nil) and (gdcObject.State = dsInsert) then
  begin
    iblcHeaderTable.CurrentKeyInt := 0;
    iblcLineTable.CurrentKeyInt := 0;
  end;
end;

procedure TdlgSetupInvPriceList.Post;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  RGKey: TID;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TDLGSETUPINVPRICELIST', 'POST', KEYPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TDLGSETUPINVPRICELIST', KEYPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TDLGSETUPINVPRICELIST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TDLGSETUPINVPRICELIST',
  {M}          'POST', KEYPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TDLGSETUPINVPRICELIST' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Assert(gdcObject.Transaction.InTransaction);

  RGKey := GetTID(gdcObject.FieldByName('reportgroupkey'));
  if not Document.UpdateReportGroup('�����-�����', gdcObject.FieldByName('name').AsString, RGKey, True) then
    raise EdlgSetupInvPriceList.Create('Report Group Key has not been created!');

  SetTID(gdcObject.FieldByName('reportgroupkey'), RGKey);

  inherited;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TDLGSETUPINVPRICELIST', 'POST', KEYPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TDLGSETUPINVPRICELIST', 'POST', KEYPOST);
  {M}end;
  {END MACRO}
end;

procedure TdlgSetupInvPriceList.AfterPost;
var
  DE: TgdDocumentEntry;
  IE: TgdInvPriceDocumentEntry;
begin
  inherited;

  Document.InitOpt;
  try
    DE := gdClassList.FindDocByTypeID(gdcObject.ID, dcpHeader, True);
    if DE is TgdInvPriceDocumentEntry then
      IE := DE as TgdInvPriceDocumentEntry
    else
      raise Exception.Create('Not an inventory price document type');

    Document.UpdateFields(lvMasterUsed, 'HF', Price, IE.HeaderFields);
    Document.UpdateFields(lvDetailUsed, 'LF', PriceLine, IE.LineFields);
  finally
    Document.DoneOpt;
  end;
end;

function TdlgSetupInvPriceList.DlgModified: Boolean;
begin
  Result := True;
end;

function TdlgSetupInvPriceList.GetIPDE: TgdInvPriceDocumentEntry;
var
  DE: TgdDocumentEntry;
begin
  DE := gdClassList.FindDocByTypeID(gdcObject.ID, dcpHeader, True);

  if DE = nil then
    DE := gdClassList.FindDocByTypeID((gdcObject as TgdcDocumentType).Parent, dcpHeader, True);

  if DE is TgdInvPriceDocumentEntry then
    Result := DE as TgdInvPriceDocumentEntry
  else
    Result := nil;
end;

initialization
  RegisterFrmClass(TdlgSetupInvPriceList);

finalization
  UnRegisterFrmClass(TdlgSetupInvPriceList);
end.

