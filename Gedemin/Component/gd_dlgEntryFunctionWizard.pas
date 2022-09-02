// ShlTanya, 11.02.2019

unit gd_dlgEntryFunctionWizard;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, Db, IBCustomDataSet, gdcBase, gdcCustomFunction, gdcFunction,
  StdCtrls, ExtCtrls, gdcAcctEntryRegister, gdcAcctTransaction,
  gdcClasses_interface, gdcClasses, Mask, DBCtrls, IBSQL, Grids, contnrs,
  ComCtrls, Buttons, BtnEdit, at_classes, gd_dlgQuantityEntryEdit,
  gd_dlgEntryFunctionEdit, gdcAttrUserDefined, DBGrids, gsIBLookupComboBox,
  IBDatabase, Spin, xCalculatorEdit, rf_Control;

const
  cwHeader = 'шапка';
  cwLine   = 'позиция';
  cCurrStr = '%s: %s(%s)';

type
  TUnitType = (utRUID, utKey);

  TQuantObject = class(TObject)
  private
    FUnitStr: String;
    FQuant: String;
    FUnitType: TUnitType;
    procedure SetQuant(const Value: String);
    procedure SetUnitStr(const Value: String);
    procedure SetUnitType(const Value: TUnitType);
  public
    procedure Assign(Source: TQuantObject);

    property Quant: String read FQuant write SetQuant;
    property UnitStr: String read FUnitStr write SetUnitStr;
    property UnitType: TUnitType read FUnitType write SetUnitType;
  end;

type
  TAccountType = (atDebit, atCredit);

  TAnalyticItem = class
    FieldName: String;
    LName: String;
    JoinField: String;
    RelationField: TatRelationField;
  end;

  TAnalyticList = class(TObject)
  private
    FList: TObjectList;
    function GetCount: Integer;
    function GetItems(Index: Integer): TAnalyticItem;

  public
    constructor Create;
    destructor  Destroy; override;

    function  AddAnalytic(const ARelationField: TatRelationField): Integer;
    procedure Clear;
    procedure Delete(Index: Integer);

    property  Count: Integer read GetCount;
    property  Items[Index: Integer]: TAnalyticItem read GetItems; default;
  end;


type
  TdlgEntryFunctionWizard = class(TForm)
    pnlMain: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    gdcFunction: TgdcFunction;
    alMain: TActionList;
    edtSFName: TDBEdit;
    lblSFName: TLabel;
    dsFunction: TDataSource;
    gbEntrySign: TGroupBox;
    lblDocName: TLabel;
    lblDocTitle: TLabel;
    lblAccountTypeTitle: TLabel;
    lblAccountType: TLabel;
    lblCurrSignTitle: TLabel;
    lblCurrSign: TLabel;
    lblDocType: TLabel;
    cbDocumentPart: TComboBox;
    Bevel1: TBevel;
    lblNCUSumm: TLabel;
    gbAnalytics: TGroupBox;
    pnlCurr: TPanel;
    lblCURRSum: TLabel;
    cbCurKey: TComboBox;
    lblCurrTitle: TLabel;
    lvAnalytics: TListView;
    btnJoin: TBitBtn;
    btnDelJoin: TBitBtn;
    dsAcctTransactionEntry: TDataSource;
    edtEditNCUF: TBtnEdit;
    edtEditCURF: TBtnEdit;
    cbxAccount: TCheckBox;
    cbAccountKey: TComboBox;
    btnEditDBP: TButton;
    btnQuantity: TButton;
    pcAnalyticsValue: TPageControl;
    tsFields: TTabSheet;
    lvDocFields: TListView;
    tsKeys: TTabSheet;
    actAnalytics: TAction;
    IBTransaction: TIBTransaction;
    rfcValue: TrfControl;
    procedure cbDocumentPartChange(Sender: TObject);
    procedure btnJoinClick(Sender: TObject);
    procedure btnDelJoinClick(Sender: TObject);
    procedure actEditSumFuncExecute(Sender: TObject);
    procedure edtEditBtnOnClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure lvAnalyticsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure cbxAccountClick(Sender: TObject);
    procedure btnEditDBPClick(Sender: TObject);
    procedure btnQuantityClick(Sender: TObject);
    procedure actAnalyticsUpdate(Sender: TObject);
    procedure tsKeysShow(Sender: TObject);
    procedure tsFieldsShow(Sender: TObject);
  private
    FgdcTransactionEntry: TgdcAcctTransactionEntry;
    FgdcDocumentHead: TgdcBase;
    FgdcDocumentLine: TgdcBase;
    FDocumentType: TID;
    FReadIBSQL: TIBSQL;
    FAccountType: TAccountType;
    FMultyCurr: Boolean;
    FDocPart: TgdcDocumentClassPart;
    FAnalyticList: TAnalyticList;
    FIsWizardActive: Boolean;
    FdlgQuantityEntryEdit: TdlgQuantityEntryEdit;
    FQuantList: TObjectList;

    function  CreateScript(out Comment: String): String;
    function  GetScrDocField(const DocField, AsType: String): String;

    procedure ActivateWizard;
    procedure CreateNewFunction;
    procedure EnableCompWithChild(const Comp: TControl; const Flag: Boolean);
    procedure EnableEntryComponents(const Flag: Boolean);

    procedure EnablePnlCurr(const CurrFlag: Boolean);
    procedure FillCurrKey;
    procedure FillAccountKey;

    procedure CreateFullAnalyticList(const AnList: TAnalyticList);

    function  LoadFunction: Boolean;
    procedure SaveFunction;

    procedure SetgdcTransactionEntry(const Value: TgdcAcctTransactionEntry);
    procedure SetDocumentType(const Value: TID);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

    function  ShowModal: Integer; override;

    property  DocumentType: TID read FDocumentType write SetDocumentType;
    property  gdcTransactionEntry: TgdcAcctTransactionEntry read FgdcTransactionEntry write SetgdcTransactionEntry;
  end;

function  GetFieldFromCB(const CBText: String): String;

implementation

uses
  gd_Security, gdcBaseInterface, gd_security_operationconst,
  gdcDelphiObject, gdcEvent
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

const
  csComp = '[comp]';
  cBeginAnalytics = '*BeginAnalytics*';
  cEndAnalytics   = '*EndAnalytics*';
  cBeginQuantity  = '*BeginQuantity*';
  cEndQuantity    = '*EndQuantity*';
  cQuantStr       = '%d%s%s%s%s';
  cQuantSepar     = ';';
  cSubItem = '*SubItem*';

type
  TAnalyticsType = (antEmpty, antReference, antUserValue, antRUID);

  TItemData = class(TObject)
  public
    RelationField: TatRelationField;
    AnalyticsType: TAnalyticsType;
  public
    constructor Create;
  end;

{$R *.DFM}

function  GetFieldFromCB(const CBText: String): String;
var
  GI: Integer;
begin
  Result := '';
  for GI := Length(CBText) downto 1 do
  begin
    if CBText[GI] = ')' then
    begin
      Result := Copy(CBText, 1, GI - 1);
      Break;
    end;
  end;
  for GI := Length(Result) downto 1 do
  begin
    if CBText[GI] = '(' then
    begin
      Result := Copy(Result, GI + 1, Length(Result));
      Break;
    end;
  end;

  if Copy(CBText, 1, Length(cwHeader)) = cwHeader then
  begin
    Result :=
      Format(feFieldSynt, [prHead, Result]);
  end else
    if Copy(CBText, 1, Length(cwLine)) = cwLine then
    begin
      Result :=
        Format(feFieldSynt, [prLine, Result]);
    end;
end;

constructor TdlgEntryFunctionWizard.Create(AOwner: TComponent);
begin
  inherited;
  IBTransaction.DefaultDatabase := gdcBaseManager.Database;

  EnableEntryComponents(False);
  DocumentType := 0;

  FReadIBSQL := TIBSQL.Create(nil);
  FReadIBSQL.Transaction := gdcBaseManager.ReadTransaction;
  cbDocumentPart.Items.Clear;
  cbDocumentPart.Items.Add(cwHeader);
  cbDocumentPart.Items.Add(cwLine);

  FAnalyticList := TAnalyticList.Create;
  FIsWizardActive := False;

  FgdcDocumentHead := nil;
  FgdcDocumentLine := nil;

  ServFields := TStringList.Create;
  ServFields.Text := efServFields;
  FdlgQuantityEntryEdit := nil;
  FQuantList := TObjectList.Create(True);
end;

procedure TdlgEntryFunctionWizard.CreateFullAnalyticList(const AnList: TAnalyticList);
var
  atRelation: TatRelation;
  I: Integer;

begin
  AnList.Clear;
  atRelation := atDatabase.Relations.ByRelationName('AC_ENTRY');
  for I := 0 to atRelation.RelationFields.Count - 1 do
  with atRelation do
    if (Pos('USR$', RelationFields[I].FieldName) = 1) then
      AnList.AddAnalytic(RelationFields[I]);
end;

procedure TdlgEntryFunctionWizard.SetDocumentType(const Value: TID);
begin
  FDocumentType := Value;
end;

procedure TdlgEntryFunctionWizard.SetgdcTransactionEntry(
  const Value: TgdcAcctTransactionEntry);
begin
  FgdcTransactionEntry := Value;
end;

function TdlgEntryFunctionWizard.ShowModal: Integer;
var
  Str: String;
  FunctionKey: TID;
begin
  Result := mrAbort;
  if FIsWizardActive then
    Exit;

  if FgdcTransactionEntry = nil then
    raise Exception.Create('Не присвоен объект "проводка".');
  if DocumentType = 0 then
    raise Exception.Create('Не присвоен ключ типа документа.');

  if FReadIBSQL.Open then
    FReadIBSQL.Close;
  FReadIBSQL.SQL.Text := 'SELECT dt.name FROM GD_DOCUMENTTYPE dt WHERE id = :id';
  SetTID(FReadIBSQL.Params[0], DocumentType);
  FReadIBSQL.ExecQuery;
  if FReadIBSQL.Eof then
    raise Exception.Create('Не выбран тип документа.');

  lblDocName.Caption := FReadIBSQL.Fields[0].AsString;
  FReadIBSQL.Close;

  Str := gdcTransactionEntry.FieldByName('accountpart').AsString;
  if AnsiUpperCase(Trim(Str)) = 'C' then
    FAccountType := atCredit
  else
    if AnsiUpperCase(Trim(Str)) = 'D' then
      FAccountType := atDebit
    else
      raise Exception.Create('Не выбран счет.');

  case FAccountType of
    atDebit:  lblAccountType.Caption := 'дебетовый';
    atCredit: lblAccountType.Caption := 'кредитовый';
  end;

  if FReadIBSQL.Open then
    FReadIBSQL.Close;
  FReadIBSQL.SQL.Text := 'SELECT ac.* FROM ac_account ac WHERE id = :id';
  SetTID(FReadIBSQL.Params[0], gdcTransactionEntry.FieldByName('accountkey'));
  FReadIBSQL.ExecQuery;
  if FReadIBSQL.Eof then
    raise Exception.Create('Не выбран счет.');
  FMultyCurr := 1 = FReadIBSQL.FieldByName('multycurr').AsInteger;

  FunctionKey := GetTID(FgdcTransactionEntry.FieldByName('entryfunctionkey'));
  if FunctionKey > 0 then
  begin
    gdcFunction.SubSet	 := 'ByID';
    gdcFunction.ID := FunctionKey;
    gdcFunction.Open;
    gdcFunction.Edit;
    if not LoadFunction then
      Exit;
  end else
    CreateNewFunction;

  Result := inherited ShowModal;
end;

destructor TdlgEntryFunctionWizard.Destroy;
begin
  FQuantList.Free;
  FReadIBSQL.Free;
  FAnalyticList.Free;
  if FgdcDocumentLine <> nil then
    FreeAndNil(FgdcDocumentLine);
  if FgdcDocumentHead <> nil then
    FreeAndNil(FgdcDocumentHead);
  if ServFields <> nil then
    FreeAndNil(ServFields);

  inherited;
end;

procedure TdlgEntryFunctionWizard.cbDocumentPartChange(Sender: TObject);
var
  OldPart: TgdcDocumentClassPart;
  gdcFullClass: TgdcFullClass;
begin
  OldPart := FDocPart;
  if cbDocumentPart.Text = cwHeader then
    FDocPart := dcpHeader
  else
    if cbDocumentPart.Text = cwLine then
      FDocPart := dcpLine
    else
      raise Exception.Create('Неизвестный тип обработки документа.');

  EnableEntryComponents(True);
  if (OldPart <> FDocPart) or
    ((FgdcDocumentHead = nil) and (FgdcDocumentLine = nil)) then
  begin
    if FgdcDocumentHead <> nil then
      FreeAndNil(FgdcDocumentHead);
    if FgdcDocumentLine <> nil then
      FreeAndNil(FgdcDocumentLine);

    gdcFullClass := TgdcDocument.GetDocumentClass(
      FDocumentType, dcpHeader);
    if gdcFullClass.gdClass = nil then
      raise Exception.Create('Выбран некорректный документ.');

    FgdcDocumentHead := gdcFullClass.gdClass.Create(nil);
    FgdcDocumentHead.SubType := gdcFullClass.SubType;
    FgdcDocumentHead.Open;

    if FDocPart = dcpLine then
    begin
      gdcFullClass := TgdcDocument.GetDocumentClass(
        FDocumentType, dcpLine);
      FgdcDocumentLine := gdcFullClass.gdClass.Create(nil);
      FgdcDocumentLine.SubType := gdcFullClass.SubType;
      FgdcDocumentLine.Open;
    end;
  end;

  FillCurrKey;

  lvDocFields.Items.Clear;
  cbxAccountClick(cbxAccount);
end;

{ TAnalyticList }

function TAnalyticList.AddAnalytic(const ARelationField: TatRelationField): Integer;
begin
  Result := FList.Add(TAnalyticItem.Create);
  with TAnalyticItem(FList[Result]) do
  begin
    FieldName := ARelationField.FieldName;
    LName := ARelationField.LName;
    RelationField := ARelationField;
  end;
end;

procedure TAnalyticList.Clear;
begin
  FList.Clear;
end;

constructor TAnalyticList.Create;
begin
  FList := TObjectList.Create(True);
end;

procedure TAnalyticList.Delete(Index: Integer);
begin
  FList.Delete(Index);
end;

destructor TAnalyticList.Destroy;
begin
  FList.Free;

  inherited;
end;

function TAnalyticList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TAnalyticList.GetItems(Index: Integer): TAnalyticItem;
begin
  Result := TAnalyticItem(FList[Index]);
end;

procedure TdlgEntryFunctionWizard.btnJoinClick(Sender: TObject);
var
  ListItem: TListItem;
  Field: TField;

const
  jcValue = '%s(%s)';

begin
  if (lvAnalytics.Selected = nil) or
    ((lvAnalytics.Selected <> nil) and (lvAnalytics.Selected.SubItems.Count < 2)) then
    Exit;

  ListItem := lvAnalytics.Selected;
  case pcAnalyticsValue.ActivePageIndex of
    0:
    begin
      if (lvDocFields.Selected <> nil) and (lvDocFields.Selected.Data <> nil) then
      begin
        Field := TObject(lvDocFields.Selected.Data) as TField;
        if Field.DataSet = FgdcDocumentHead then
          ListItem.SubItems[1] := Format(feFieldSynt, [prHead, Field.FieldName]);
        if Field.DataSet = FgdcDocumentLine then
          ListItem.SubItems[1] := Format(feFieldSynt, [prLine, Field.FieldName]);
        TItemData(ListItem.Data).AnalyticsType := antReference;
      end;
    end;
    1:
    begin
      if TItemData(lvAnalytics.Selected.Data).RelationField.References <> nil then
      try
      ListItem.SubItems[1] := gdcBaseManager.GetRUIDStringByID(GetTID(rfcValue.CurrentValue));
      TItemData(ListItem.Data).AnalyticsType := antRUID;
      except
        ListItem.SubItems[1] := rfcValue.CurrentValue;
        TItemData(ListItem.Data).AnalyticsType := antUserValue;
      end else
        begin
          ListItem.SubItems[1] := rfcValue.CurrentValue;
          TItemData(ListItem.Data).AnalyticsType := antUserValue;
        end;
    end;
  end;

end;

procedure TdlgEntryFunctionWizard.btnDelJoinClick(Sender: TObject);
begin
  if (lvAnalytics.Selected <> nil) and (lvAnalytics.Selected.SubItems.Count > 1) then
  begin
    lvAnalytics.Selected.SubItems[1] := '';
  end;

end;

procedure TdlgEntryFunctionWizard.actEditSumFuncExecute(Sender: TObject);
var
  BtnEdit: TBtnEdit;
begin
  if Self.ActiveControl.InheritsFrom(TBtnEdit) then
    BtnEdit := TBtnEdit(Self.ActiveControl)
  else
    if Sender.InheritsFrom(TEditSButton) then
      BtnEdit := TEditSButton(Sender).Edit
    else
      Exit;

  if (BtnEdit = edtEditNCUF) or (BtnEdit = edtEditCURF) then
    with TdlgEntryFunctionEdit.Create(Self) do
    try
      gdcBaseHead := FgdcDocumentHead;
      gdcBaseLine := FgdcDocumentLine;
      FunctionText := BtnEdit.Text;
      if ShowModal = idOk then
        BtnEdit.Text := FunctionText;
    finally
      Free;
    end;
end;

procedure TdlgEntryFunctionWizard.edtEditBtnOnClick(Sender: TObject);
var
  BtnEdit: TBtnEdit;
begin
  if not Sender.InheritsFrom(TEditSButton) then
    Exit;

  BtnEdit := TEditSButton(Sender).Edit;
  if (BtnEdit = edtEditNCUF) or (BtnEdit = edtEditCURF) then
    with TdlgEntryFunctionEdit.Create(Self) do
    try
      gdcBaseHead := FgdcDocumentHead;
      gdcBaseLine := FgdcDocumentLine;
      FunctionText := BtnEdit.Text;
      if ShowModal = idOk then
        BtnEdit.Text := FunctionText;
    finally
      Free;
    end;
end;

procedure TdlgEntryFunctionWizard.EnableEntryComponents(
  const Flag: Boolean);

begin
  EnableCompWithChild(gbEntrySign, Flag);
  EnableCompWithChild(gbAnalytics, Flag);
  if Flag then
    ActivateWizard;
end;

function TdlgEntryFunctionWizard.CreateScript(out Comment: String): String;
var
  AliasStr: String;
  I: Integer;
  AnalyticsCommentIns: Boolean;
  QuantObject: TQuantObject;
  tmpStrings: TStrings;
const
  cHeadComment =
    '  '' Функция проводки'#13#10 +
    '  '' по документу %s'#13#10 +
    '  '' проводка для счета %s.'#13#10 +
    '  '' gdcEntry - Строка формируемой проводки '#13#10 +
    '  '' gdcDocument - документ или позиция документа, по которому формируется проводка.'#13#10#13#10;
  cAccountKey =
    '  '' Ключ счета.'#13#10;
  cSumNCUComment =
    '  '' Сумма по проводке в НДЕ.'#13#10;
  cCurKeyComment =
    '  '' Ключ валюты.'#13#10;
  cSumCurComment =
    '  '' Сумма по проводке в валюте.'#13#10;
  cAnalyticsComment =
    '  '' Значение по аналитике %s'#13#10;
  cQuantityComment =
    '  '' Количественные показатели проводки.'#13#10;

  cSubBegin = 'Sub %s(gdcEntry, gdcDocument)'#13#10;
  cSubEnd   = 'End Sub'#13#10;

  cCurStr = '  gdcEntry.FieldByName("%s").AsCurrency = %s'#13#10;
  cVarStr = '  gdcEntry.FieldByName("%s").AsVariant  = %s'#13#10;
  cIntStr = '  gdcEntry.FieldByName("%s").AsInteger  = %s'#13#10;
  cIntRUIDStr = '  gdcEntry.FieldByName("%s").AsInteger  = gdcBaseManager.GetIDByRUIDString("%s")'#13#10;

  cAsCur  = 'AsCurrency';
  cAsVar  = 'AsVariant';
  cIsNull = 'IsNull';

  cWithCondition =
  '  If %s Then'#13#13 +
  '    %s'#13#10 +
  '  End If'#13#10;

  cqIntField = '  gdcEntry.gdcQuantity.FieldByName("%s").AsInteger  = gdcBaseManager.GetIDByRUIDString("%s")'#13#10;
  cqVarField = '  gdcEntry.gdcQuantity.FieldByName("%s").AsVariant  = %s'#13#10;
  cqCurStr   = '  gdcEntry.gdcQuantity.FieldByName("%s").AsCurrency = %s'#13#10;
  cqAppend   = '  gdcEntry.gdcQuantity.Append'#13#10;
  cqPost     = '  gdcEntry.gdcQuantity.Post'#13#10;
  cqQF       = 'quantity';
  cqVF       = 'valuekey';
  cqIF       = '  If Not %s Then'#13#10;
  cqENDIF    = '  End If'#13#10;

  procedure AddText(var ScriptText: String; const MaskStr, FieldName: String; const AdditList: TStrings);
  var
    AI: Integer;
  begin
    if AdditList.Count = 0 then
      Exit;

    if AdditList.Count = 1 then
    begin
      ScriptText :=
        ScriptText + Format(MaskStr, [FieldName, '"' + AdditList[0] + '"']);
      Exit;
    end;

    ScriptText :=
      ScriptText + Format(MaskStr, [FieldName, '"' + AdditList[0] + '" + Chr(13) + Chr(10) + _']);
    for AI := 1 to AdditList.Count - 2 do
      ScriptText := ScriptText + '    "' + AdditList[AI] + '" + Chr(13) + Chr(10)  + _'#13#10;
    ScriptText := ScriptText + '    "' + AdditList[AdditList.Count - 1] + '"'#13#10;;
  end;

begin
  if Length(Trim(edtEditNCUF.Text)) = 0 then
  begin
    edtEditNCUF.SetFocus;
    raise Exception.Create('Не заполнено поле "Сумма в рублях"');
  end;

  AliasStr := gdcTransactionEntry.FieldByName('accountpart').AsString;
  if AnsiUpperCase(Trim(AliasStr)) = 'C' then
    AliasStr := gdcTransactionEntry.FieldByName('creditalias').AsString
  else
    if AnsiUpperCase(Trim(AliasStr)) = 'D' then
      AliasStr := gdcTransactionEntry.FieldByName('debitalias').AsString
    else
      raise Exception.Create('Поле accountpart объекта gdcTransactionEntry содержит некорректные данные.');

  Result := Format(cSubBegin, [gdcFunction.FieldByName('name').AsString]);
  Comment := Format(cHeadComment, [lblDocName.Caption, AliasStr]);
  Result := Result + Comment;
  Result := Result + cSumNCUComment;

  case FAccountType of
    atDebit:
      Result := Result + Format(cCurStr, ['debitncu', GetScrDocField(edtEditNCUF.Text, cAsCur)]);
    atCredit:
      Result := Result + Format(cCurStr, ['creditncu', GetScrDocField(edtEditNCUF.Text, cAsCur)]);
  end;

  if cbxAccount.Checked and cbxAccount.Enabled then
  begin
    if Length(Trim(cbAccountKey.Text)) = 0 then
    begin
      cbAccountKey.SetFocus;
      raise Exception.Create('Не заполнено поле "Счет".');
    end;

    Result := Result + cAccountKey;

    Result := Result +
      Format(cWithCondition, [' not ' + GetScrDocField(GetFieldFromCB(cbAccountKey.Text), cIsNull),
        Format(cVarStr, ['accountkey', GetScrDocField(GetFieldFromCB(cbAccountKey.Text), cAsVar)])]);
  end;

  if cbCurKey.Enabled and edtEditCURF.Enabled and (Length(Trim(cbCurKey.Text)) > 0) then
  begin
    if Length(Trim(edtEditCURF.Text)) = 0 then
    begin
      edtEditCURF.SetFocus;
      raise Exception.Create('Не заполнено поле "Сумма в валюте."');
    end;

    Result := Result + cCurKeyComment;
    Result := Result + Format(cVarStr, ['currkey',
      GetScrDocField(GetFieldFromCB(cbCurKey.Text), cAsVar)]);


    Result := Result + cSumCurComment;
    case FAccountType of
      atDebit:
        Result := Result + Format(cCurStr, ['debitcurr', GetScrDocField(edtEditCURF.Text, cAsCur)]);
      atCredit:
        Result := Result + Format(cCurStr, ['creditcurr', GetScrDocField(edtEditCURF.Text, cAsCur)]);
    end;
  end;

  tmpStrings := TStringList.Create;
  try
    AnalyticsCommentIns := False;
    for I := 0 to lvAnalytics.Items.Count - 1 do
    begin
      if Length(Trim(lvAnalytics.Items[I].SubItems[1])) > 0 then
      begin
        if not AnalyticsCommentIns then
        begin
          Result := Result + cAnalyticsComment;
          AnalyticsCommentIns := True;
        end;
        case TItemData(lvAnalytics.Items[I].Data).AnalyticsType of
          antReference:
            Result := Result + Format(cVarStr, [lvAnalytics.Items[I].SubItems[0],
              GetScrDocField(lvAnalytics.Items[I].SubItems[1], cAsVar)]);
          antUserValue:
          begin
            tmpStrings.Clear;
            tmpStrings.Text := lvAnalytics.Items[I].SubItems[1];
            AddText(Result, cVarStr, lvAnalytics.Items[I].SubItems[0], tmpStrings)
          end;
          antRUID:
            Result := Result + Format(cIntRUIDStr, [lvAnalytics.Items[I].SubItems[0],
              lvAnalytics.Items[I].SubItems[1]]);
          else
            raise Exception.Create('Не соответсвие типа значения аналитики.');
        end;
      end;
    end;

    if FQuantList.Count > 0 then
    begin
      Result := Result + cQuantityComment;
      for I := 0 to FQuantList.Count - 1 do
      begin
        if FQuantList[I] = nil then
          Continue;

        QuantObject := TQuantObject(FQuantList[I]);
        if (Length(Trim(QuantObject.FUnitStr)) = 0) or
          (Length(Trim(QuantObject.FQuant)) = 0) then
          Continue;

        if QuantObject.FUnitType = utKey then
          Result := Result + Format(cqIF, [GetScrDocField(QuantObject.FUnitStr, cIsNull)]);

        Result := Result + cqAppend;
        case QuantObject.FUnitType of
          utRUID:
            Result := Result + Format(cqIntField, [cqVF, QuantObject.FUnitStr]);
          utKey:
            Result := Result + Format(cqVarField, [cqVF, GetScrDocField(QuantObject.FUnitStr, cAsVar)]);
        end;
        Result := Result + Format(cqCurStr, [cqQF, GetScrDocField(QuantObject.FQuant, cAsCur)]);
        Result := Result + cqPost;
        if QuantObject.FUnitType = utKey then
          Result := Result + cqENDIF;
      end;
    end;
  finally
    tmpStrings.Free;
  end;

  Result := Result + cSubEnd;
end;

procedure TdlgEntryFunctionWizard.ActivateWizard;
var
  I: Integer;
  ListItem: TListItem;
begin
  EnablePnlCurr(FMultyCurr);

  CreateFullAnalyticList(FAnalyticList);
  I := 0;
  while I < FAnalyticList.Count do
  begin
    if (FReadIBSQL.FieldIndex[FAnalyticList[I].FieldName] > -1) and
      (FReadIBSQL.FieldByName(FAnalyticList[I].FieldName).AsInteger = 1) then
      Inc(I)
    else
      FAnalyticList.Delete(I);
  end;
  lvAnalytics.Items.Clear;

  EnableCompWithChild(gbAnalytics, FAnalyticList.Count > 0);
  for I := 0 to FAnalyticList.Count - 1 do
  begin
    ListItem := lvAnalytics.Items.Add;
    ListItem.Caption := FAnalyticList[I].LName;
    ListItem.SubItems.Add(FAnalyticList[I].FieldName);
    ListItem.SubItems.Add('');
    ListItem.Data := TItemData.Create;
    TItemData(ListItem.Data).RelationField := FAnalyticList[I].RelationField;
  end;

  FReadIBSQL.Close;
  FIsWizardActive := True;
  btnQuantity.Enabled := True;
end;

procedure TdlgEntryFunctionWizard.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);

begin
  if ModalResult = idOk then
  begin
    if dsEdit <> FgdcTransactionEntry.State then
      FgdcTransactionEntry.Edit;
    SetTID(FgdcTransactionEntry.FieldByName('entryfunctionkey'), gdcFunction.ID);
    FgdcTransactionEntry.FieldByName('functionname').AsString :=
      gdcFunction.FieldByName('name').AsString;
    SaveFunction;

    if gdcFunction.Active then
      gdcFunction.Close;
  end;
end;

procedure TdlgEntryFunctionWizard.lvAnalyticsSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  RfEntry, RFDoc: TatRelationField;
  Str: String;

  procedure AddDocField(const AdditField: TField);
  var
    AdListItem: TListItem;
    AdStr: String;
  begin
    if (AdditField <> nil) and
      (ServFields.IndexOf(AdditField.FieldName) = -1) then
    begin
      if AdditField.DataSet = FgdcDocumentHead then
        AdStr := cwHeader
      else
        if AdditField.DataSet = FgdcDocumentLine then
          AdStr := cwLine
        else
          Exit;

      AdListItem := lvDocFields.Items.Add;
      AdListItem.Caption := AdStr;
      AdListItem.SubItems.Add(AdditField.FieldName);
      AdListItem.SubItems.Add(AdditField.DisplayName);
      AdListItem.Data := AdditField;
    end;
  end;

  procedure AddDoc(const gdcDoc: TgdcBase);
  var
    AI: Integer;

  begin
    for AI := 0 to gdcDoc.Fields.Count - 1 do
      if not gdcDoc.Fields[AI].Calculated then
      begin
        Str := gdcDoc.RelationByAliasName(gdcDoc.Fields[AI].FieldName);
        RFDoc := atDatabase.FindRelationField(Str,
          GetOriginFieldName(gdcDoc.Fields[AI].Origin));
        if CheckRF(RFEntry, RFDoc) then
          AddDocField(gdcDoc.Fields[AI]);
      end;
  end;
begin
  if Selected then
  begin
    case TItemData(Item.Data).AnalyticsType of
      antUserValue, antRUID: pcAnalyticsValue.ActivePage := tsKeys;
      else
        pcAnalyticsValue.ActivePage := tsFields;
    end;
    case pcAnalyticsValue.ActivePageIndex of
      0: tsFieldsShow(Sender);
      1: tsKeysShow(Sender);
    end;
  end;
end;

function TdlgEntryFunctionWizard.GetScrDocField(
  const DocField, AsType: String): String;
var
  EPos, BPos, I: Integer;
  Str: String;
const
  cMaster   = 'gdcDocument.MasterSource.DataSet.FieldByName("%s").%s';
  cDocument = 'gdcDocument.FieldByName("%s").%s';

  function GetCorrectStr(ShStr: String): String;
  begin
    Result := Trim(ShStr);
    ShStr := Trim(Copy(Result, 2, Length(Result)));
    if ShStr[1] <> fwPoint then
      // сформировано с ошибками
      Exit;
    ShStr := Trim(Copy(ShStr, 2, Length(ShStr)));

    case Result[1] of
      prHead:
      begin
        if cbDocumentPart.Text = cwHeader then
          Result := Format(cDocument, [ShStr, AsType])
        else
          if cbDocumentPart.Text = cwLine then
            Result := Format(cMaster, [ShStr, AsType]);
      end;
      prLine:
      begin
        if cbDocumentPart.Text = cwLine then
          Result := Format(cDocument, [ShStr, AsType])
        else
          ;//  сформировано с ошибками
      end;
    end;
  end;

begin
  Result := '';
  Str := Trim(DocField);
  if Length(str) = 0 then
    Exit;

  EPos := 0;
  BPos := 0;
  I := 1;
  while I <= Length(Str) do
  try
    case Str[I] of
      fwBDecl:
      begin
       if EPos > 0 then
         Result := Result + Copy(Str, EPos, I - EPos)
       else
         Result := Copy(Str, 1, I - 1);
       BPos := I + 1;
      end;
      fwEDecl:
      begin
        EPos := I + 1;
        Result := Result + GetCorrectStr(Copy(Str, BPos, I - BPos));
      end;
      fw13:
      begin
        if ((I + 1) < Length(Str)) and (Str[I + 1] = fw10) then
        begin
          Str := Copy(Str, 1, I - 1) + Copy(Str, I + 2, Length(Str));
          Dec(I);
        end;
      end;
    end;
  finally
    Inc(I);
  end;
  if EPos < BPos then
    raise Exception.Create('Ошибка синтаксиса: не обнаружена завершающая скобка.')
  else
    Result := Result + Copy(Str, EPos + 1, Length(Str));

end;

procedure TdlgEntryFunctionWizard.FillCurrKey;
var
  RfEntry, RFDoc: TatRelationField;
  Str: String;

  procedure AddCurrKey(const gdcDoc: TgdcBase);
  var
    AI: Integer;

  begin
    for AI := 0 to gdcDoc.Fields.Count - 1 do
      if not gdcDoc.Fields[AI].Calculated then
      begin
        try
          Str := gdcDoc.RelationByAliasName(gdcDoc.Fields[AI].FieldName);
          if Length(Str) = 0 then
            Continue;
          RFDoc := atDatabase.FindRelationField(Str,
            GetOriginFieldName(gdcDoc.Fields[AI].Origin));
          if CheckRF(RFEntry, RFDoc) then
          begin
            if gdcDoc = FgdcDocumentHead then
              Str := Format(cCurrStr, [cwHeader, gdcDoc.Fields[AI].DisplayName, gdcDoc.Fields[AI].FieldName])
            else
              if gdcDoc = FgdcDocumentLine then
                Str := Format(cCurrStr, [cwLine, gdcDoc.Fields[AI].DisplayName, gdcDoc.Fields[AI].FieldName]);
            if ServFields.IndexOf(gdcDoc.Fields[AI].FieldName) = -1 then
              cbCurKey.Items.Add(Str);
          end;
        except
        end;
      end;
  end;

begin
  cbCurKey.Text := '';
  cbCurKey.Items.Clear;
  cbCurKey.Items.Add('');
  if not cbCurKey.Enabled then
    Exit;

  RFEntry := atDatabase.FindRelationField('ac_entry', 'currkey');
  if FgdcDocumentHead <> nil then
    AddCurrKey(FgdcDocumentHead);
  if FgdcDocumentLine <> nil then
    AddCurrKey(FgdcDocumentLine);
end;

procedure TdlgEntryFunctionWizard.EnableCompWithChild(const Comp: TControl;
  const Flag: Boolean);
var
  EI: Integer;
begin
  Comp.Enabled := Flag;
  if Comp.InheritsFrom(TWinControl) then
    for EI := 0 to TWinControl(Comp).ControlCount - 1 do
      EnableCompWithChild(TWinControl(Comp).Controls[EI], Flag);
end;

procedure TdlgEntryFunctionWizard.cbxAccountClick(Sender: TObject);
begin
  if Sender <> cbxAccount then
    Exit;

  if cbxAccount.Checked then
  begin
    cbAccountKey.Enabled := True;
    lblCurrSignTitle.Enabled := False;
    lblCurrSign.Enabled := False;
    EnablePnlCurr(False);
  end else
    begin
      cbAccountKey.Enabled := False;
      lblCurrSignTitle.Enabled := True;
      lblCurrSign.Enabled := True;
      EnablePnlCurr(True);
    end;
  FillAccountKey;
end;

procedure TdlgEntryFunctionWizard.FillAccountKey;
var
  RFDoc: TatRelationField;
  atForeignKey: TatForeignKey;
  Str: String;
const
  cAccountTable = 'AC_ACCOUNT';

  procedure AddAccountFields(const gdcDoc: TgdcBase);
  var
    AI: Integer;
  begin
    for AI := 0 to gdcDoc.Fields.Count - 1 do
      if not gdcDoc.Fields[AI].Calculated then
      begin
        try
          Str := gdcDoc.RelationByAliasName(gdcDoc.Fields[AI].FieldName);
        except
        end;
        if Length(Str) = 0 then
          Continue;
        RFDoc := atDatabase.FindRelationField(Str,
          GetOriginFieldName(gdcDoc.Fields[AI].Origin));
        if (RfDoc = nil) or (RFDoc.ForeignKey = nil) then
          Continue;

        while RFDoc.ForeignKey <> nil do
        begin
          atForeignKey := RFDoc.ForeignKey;
          RFDoc := atForeignKey.ReferencesField;
        end;

        if AnsiUpperCase(atForeignKey.ReferencesRelation.RelationName) = cAccountTable then
        begin
          if gdcDoc = FgdcDocumentHead then
            Str := Format(cCurrStr, [cwHeader, gdcDoc.Fields[AI].DisplayName, gdcDoc.Fields[AI].FieldName])
          else
            if gdcDoc = FgdcDocumentLine then
              Str := Format(cCurrStr, [cwLine, gdcDoc.Fields[AI].DisplayName, gdcDoc.Fields[AI].FieldName]);
          cbAccountKey.Items.Add(Str);
        end;
      end;
  end;

begin
  cbAccountKey.Text := '';
  cbAccountKey.Items.Clear;
  if not cbAccountKey.Enabled then
    Exit;

  if FgdcDocumentHead <> nil then
    AddAccountFields(FgdcDocumentHead);
  if FgdcDocumentLine <> nil then
    AddAccountFields(FgdcDocumentLine);
end;

procedure TdlgEntryFunctionWizard.EnablePnlCurr(const CurrFlag: Boolean);
var
  I: Integer;
begin
  if CurrFlag then
  begin
    lblCurrSign.Caption := 'рублевый';
    for I := 0 to pnlCurr.ControlCount - 1 do
      pnlCurr.Controls[I].Enabled := False;
  end else
    begin
      lblCurrSign.Caption := 'мультивалютный';
      for I := 0 to pnlCurr.ControlCount - 1 do
        pnlCurr.Controls[I].Enabled := True;
    end;
end;

procedure TdlgEntryFunctionWizard.SaveFunction;
var
  Str: String;
  I: Integer;
  D: TDateTime;
  QuantObject: TQuantObject;
  BlobStream: TStream;
//  AcctEntryScript: TgdcAcctEntryScript;

  procedure AddStrToStream(AdditStr: String);
  var
    AI: Integer;
  begin
    AI := Length(AdditStr);
    BlobStream.Write(AI, SizeOf(Integer));
    if AI > 0 then
      BlobStream.Write(AdditStr[1], AI);
  end;
begin
  gdcFunction.FieldByName('script').AsString := CreateScript(Str);
  gdcFunction.FieldByName('comment').AsString := Str;
  gdcFunction.Post;

  if FgdcTransactionEntry.State <> dsEdit then
    FgdcTransactionEntry.Edit;
  FgdcTransactionEntry.FieldByName('ENTRYFUNCTIONSTOR').Clear;
  BlobStream := FgdcTransactionEntry.CreateBlobStream(
    FgdcTransactionEntry.FieldByName('ENTRYFUNCTIONSTOR'), bmWrite);

  D := gdcFunction.FieldByName('editiondate').AsDateTime;
  BlobStream.Write(D, SizeOf(TDateTime));

  Str := cbDocumentPart.name;
  AddStrToStream(Str);
  Str := cbDocumentPart.Text;
  AddStrToStream(Str);

  Str := cbxAccount.name;
  AddStrToStream(Str);
  Str := IntToStr(Integer(cbxAccount.Checked));
  AddStrToStream(Str);

  Str := cbAccountKey.name;
  AddStrToStream(Str);
  Str := cbAccountKey.Text;
  AddStrToStream(Str);

  Str := edtEditNCUF.name;
  AddStrToStream(Str);
  Str := edtEditNCUF.Text;
  AddStrToStream(Str);

  Str := cbCurKey.name;
  AddStrToStream(Str);
  Str := cbCurKey.Text;
  AddStrToStream(Str);

  Str := edtEditCURF.name;
  AddStrToStream(Str);
  Str := edtEditCURF.Text;
  AddStrToStream(Str);

  if lvAnalytics.Items.Count > 0 then
  begin
    Str := cBeginAnalytics;
    AddStrToStream(Str);
    for I := 0 to lvAnalytics.Items.Count - 1 do
    begin
      Str := cSubItem;
      AddStrToStream(Str);
      BlobStream.Write(TItemData(lvAnalytics.Items[I].Data).AnalyticsType, SizeOf(TAnalyticsType));
      Str := lvAnalytics.Items[I].SubItems[0];
      AddStrToStream(Str);
      Str := lvAnalytics.Items[I].SubItems[1];
      AddStrToStream(Str);
    end;
    Str := cEndAnalytics;
    AddStrToStream(Str);
  end;

  if FQuantList.Count > 0 then
  begin
    Str := cBeginQuantity;
    AddStrToStream(Str);
    for I := 0 to FQuantList.Count - 1 do
    begin
      QuantObject := TQuantObject(FQuantList[I]);
      if (Length(Trim(QuantObject.FUnitStr)) = 0) or (Length(Trim(QuantObject.FQuant)) = 0) then
        Continue;

      Str := cSubItem;
      AddStrToStream(Str);
      BlobStream.Write(QuantObject.FUnitType, SizeOf(TUnitType));

      Str := QuantObject.FUnitStr;
      AddStrToStream(Str);
      Str := QuantObject.FQuant;
      AddStrToStream(Str);
    end;
    Str := cEndQuantity;
    AddStrToStream(Str);
  end;
end;

function TdlgEntryFunctionWizard.LoadFunction: Boolean;
var
  Str: String;
  D: TDateTime;
  BlobStream: TStream;

  procedure RestoreCompState;
  var
    RI, RK: Integer;
    RStr: String;
    RQuantObject: TQuantObject;
    RAT: TAnalyticsType;
    RCheck: Boolean;

    // проверяет корректность строки
    procedure CheckCompName(CompName, FuncStorStr: String);
    begin
      if AnsiCompareText(FuncStorStr, CompName) <> 0 then
        raise EAbort.Create('Не совпадает имя компонента и имя в потоке.');
    end;

    procedure CheckQuantStr(SepPos: Integer);
    begin
      if SepPos = 0 then
        raise EAbort.Create('Ошибка восстановления количественных показателей.');
    end;

    procedure ReadStrFromStream;
    begin
      BlobStream.ReadBuffer(RI, SizeOf(Integer));
      if RI > (BlobStream.Size - BlobStream.Position) then
        raise EAbort.Create('Ошибка считывания из потока');
      SetLength(RStr, RI);
      if RI > 0 then
        BlobStream.ReadBuffer(RStr[1], RI);
    end;
  begin


    ReadStrFromStream;
    CheckCompName(cbDocumentPart.Name, RStr);
    ReadStrFromStream;
    RI := cbDocumentPart.Items.IndexOf(RStr);
    if RI = -1 then
      raise EAbort.Create('Некорректное значение.');
    cbDocumentPart.ItemIndex := RI;
    cbDocumentPartChange(cbDocumentPart);

    ReadStrFromStream;
    CheckCompName(cbxAccount.Name, RStr);
    ReadStrFromStream;
    cbxAccount.Checked := Boolean(StrToInt(RStr));
    cbxAccountClick(cbxAccount);

    ReadStrFromStream;
    CheckCompName(cbAccountKey.Name, RStr);
    ReadStrFromStream;
    if Length(RStr) > 0 then
    begin
      RI := cbAccountKey.Items.IndexOf(RStr);
      if RI = -1 then
        raise EAbort.Create('Некорректное значение.');
      cbAccountKey.ItemIndex := RI;
    end;

    ReadStrFromStream;
    CheckCompName(edtEditNCUF.Name, RStr);
    ReadStrFromStream;
    edtEditNCUF.Text := RStr;

    ReadStrFromStream;
    CheckCompName(cbCurKey.Name, RStr);
    ReadStrFromStream;
    if Length(RStr) > 0 then
    begin
      RI := cbCurKey.Items.IndexOf(RStr);
      if RI = -1 then
        raise EAbort.Create('Некорректное значение.');
      cbCurKey.ItemIndex := RI;
    end;

    ReadStrFromStream;
    CheckCompName(edtEditCURF.Name, RStr);
    ReadStrFromStream;
    edtEditCURF.Text := RStr;

    if BlobStream.Size = BlobStream.Position then
      Exit;

    ReadStrFromStream;
    if AnsiCompareText(RStr, cBeginAnalytics) = 0 then
    begin
      ReadStrFromStream;
      while (BlobStream.Size > BlobStream.Position) and (AnsiCompareText(RStr, cEndAnalytics) <> 0) do
      begin
        CheckCompName(cSubItem, RStr);

        BlobStream.ReadBuffer(RAT, SizeOf(TAnalyticsType));

        ReadStrFromStream;

        RCheck := False;
        for RK := 0 to lvAnalytics.Items.Count - 1 do
        begin
          if AnsiCompareText(lvAnalytics.Items[RK].SubItems[0], RStr) = 0 then
          begin
            ReadStrFromStream;
            lvAnalytics.Items[RK].SubItems[1] := RStr;
            TItemData(lvAnalytics.Items[RK].Data).AnalyticsType := RAT;
            RCheck := True;
            Break;
          end;
        end;
        if not RCheck then
          raise EAbort.Create('Ошибка восстановления аналитики.');
        ReadStrFromStream;
      end;
    end;

    if BlobStream.Size = BlobStream.Position then
      Exit;

    if AnsiCompareText(RStr, cBeginQuantity) <> 0 then
      ReadStrFromStream;
    if AnsiCompareText(RStr, cBeginQuantity) = 0 then
    begin
      ReadStrFromStream;
      while (BlobStream.Size > BlobStream.Position) and (AnsiCompareText(RStr, cEndQuantity) <> 0) do
      begin
        CheckCompName(cSubItem, RStr);

        RQuantObject := TQuantObject.Create;
        try
          // выделяем тип
          BlobStream.ReadBuffer(RQuantObject.FUnitType, SizeOf(TUnitType));
          ReadStrFromStream;
          RQuantObject.FUnitStr := RStr;
          ReadStrFromStream;
          RQuantObject.FQuant   := RStr;

          FQuantList.Add(RQuantObject);
        except
          RQuantObject.Free;
          FQuantList.Clear;
          raise EAbort.Create('Ошибка восстановления количественных показателей.');
        end;
        ReadStrFromStream;
      end;
    end;
  end;

begin
  FQuantList.Clear;

  BlobStream := FgdcTransactionEntry.CreateBlobStream(
    FgdcTransactionEntry.FieldByName('ENTRYFUNCTIONSTOR'), bmRead);
  if BlobStream.Size = 0 then
  begin
    Str :=
      'Функция ' + gdcFunction.FieldByName('name').AsString +  ' не была создана в конструкторе.'#13#10 +
      'Восстановление ее в конструктор не возможно.'#13#10#13#10 +
      'Создать новую функцию?';

    if MessageBox(Self.Handle, PChar(Str), PChar('Ошибка восстановления функции.'),
      MB_YESNO or MB_ICONERROR or MB_TOPMOST or MB_TASKMODAL) = IDYES then
    begin
      CreateNewFunction;
      Result := True;
    end else
      Result := False;

    Exit;
  end;

  try
    BlobStream := FgdcTransactionEntry.CreateBlobStream(
      FgdcTransactionEntry.FieldByName('ENTRYFUNCTIONSTOR'), bmRead);

    BlobStream.ReadBuffer(D, SizeOf(Double));
    if D <> gdcFunction.FieldByName('editiondate').AsDateTime then
    begin
      Str :=
        'Функция ' + gdcFunction.FieldByName('name').AsString +  ' была отредактирована вручную.'#13#10 +
        'Открытие и сохранние функции конструктором повлечет потерю'#13#10 +
        'изменений добавленных в ручном режиме.'#13#10#13#10 +
        'Все равно открыть функцию?';

      if MessageBox(Self.Handle, PChar(Str), PChar('Ошибка восстановления функции.'),
        MB_YESNO or MB_ICONERROR or MB_TOPMOST or MB_TASKMODAL) = IDNO then
      begin
        Str := 'Создать новую функцию?';
        if MessageBox(Self.Handle, PChar(Str), PChar('Редактирование функции.'),
          MB_YESNO or MB_ICONWARNING or MB_TOPMOST or MB_TASKMODAL) = IDYES then
        begin
          Result := True;
          CreateNewFunction;
        end else
          Result := False;

          Exit;
      end;
    end;

    RestoreCompState;
    Result := True;
  except
    Str :=
      'Ошибка восстановления функции ' + gdcFunction.FieldByName('name').AsString +  '.'#13#10 +
      'Открытие и сохранние функции конструктором приведет к потере'#13#10 +
      'текущей функции.'#13#10#13#10 +
      'Все равно открыть функцию?';

    if MessageBox(Self.Handle, PChar(Str), PChar('Ошибка восстановления функции.'),
      MB_YESNO or MB_ICONERROR or MB_TOPMOST or MB_TASKMODAL) = IDYES then
    begin
      Result := True;
      Str := 'Создать новую функцию?';
      if MessageBox(Self.Handle, PChar(Str), PChar('Редактирование функции.'),
        MB_YESNO or MB_ICONWARNING or MB_TOPMOST or MB_TASKMODAL) = IDYES then
      begin
        CreateNewFunction;
      end;
    end else
      Result := False;
  end;
end;

procedure TdlgEntryFunctionWizard.CreateNewFunction;
begin
  if gdcFunction.Active then
    gdcFunction.Close;
  gdcFunction.Open;
  gdcFunction.Insert;
  gdcFunction.FieldByName('module').AsString := 'ENTRY';
  gdcFunction.FieldByName('modulecode').AsInteger := OBJ_APPLICATION;
  gdcFunction.FieldByName('NAME').AsString := Format(erScriptName,
    [gdcFunction.FieldByName('ID').AsString, IBLogin.DBID]);
  gdcFunction.FieldByName('language').AsString := 'VBScript';
end;

procedure TdlgEntryFunctionWizard.btnEditDBPClick(Sender: TObject);
var
  ClassKey: TID;
  mtdFunctionKey: TID;
  gdcClass: TgdcFullClassName;
  gdcEvent: TgdcEvent;
  gdcMethodFunc: TgdcFunction;
const
  cMtdDisable =
    'Метод ''DoBeforePost'' класса ''%s'' отключен.'#13#10 +
    'Вызов метода не возможен.'#13#10#13#10 +
    'Обратитесь к администратору для подключения метода.';
  cMtdDisableWithSubType =
    'Метод ''DoBeforePost'' класса ''%s'''#13#10 +
    'подтип ''%s'' отключен.'#13#10 +
    'Вызов метода не возможен.'#13#10#13#10 +
    'Обратитесь к администратору для подключения метода.';

begin
  if Length(Trim(cbDocumentPart.Text)) = 0 then
  begin
    cbDocumentPart.SetFocus;
    raise Exception.Create('Не выбран тип обработки документа.');
  end;
  case FDocPart of
    dcpHeader:
    begin
      if FgdcDocumentHead = nil then
        Exit;
      gdcClass.gdClassName := FgdcDocumentHead.ClassName;
      gdcClass.SubType     := FgdcDocumentHead.SubType;
    end;
    dcpLine:
    begin
      if FgdcDocumentLine = nil then
        Exit;
      gdcClass.gdClassName := FgdcDocumentLine.ClassName;
      gdcClass.SubType     := FgdcDocumentLine.SubType;
    end;
  end;
  ClassKey := TgdcDelphiObject.AddClass(gdcClass);
  if ClassKey = -1 then
    raise Exception.Create('Не найден класс документа.');
  gdcEvent := TgdcEvent.Create(nil);
  try
    gdcEvent.SubSet := cByObjectKey;
    SetTID(gdcEvent.ParamByName('objectkey'), ClassKey);
    gdcEvent.Open;
    mtdFunctionKey := -1;
    while not gdcEvent.Eof do
    begin
      if AnsiCompareText(gdcEvent.FieldByName('eventname').AsString, 'DOBEFOREPOST') = 0 then
      begin
        if (not gdcEvent.FieldByName('disable').IsNull) and
          (gdcEvent.FieldByName('disable').AsInteger = 1) then
        begin
          if Length(Trim(gdcClass.SubType)) = 0 then
            raise Exception.Create(Format(cMtdDisable, [gdcClass.gdClassName]))
          else
            raise Exception.Create(Format(cMtdDisableWithSubType,
              [gdcClass.gdClassName, gdcEvent.SubType]));
        end;
        mtdFunctionKey := GetTID(gdcEvent.FieldByName('functionkey'));
        Break;
      end;
      gdcEvent.Next;
    end;

    gdcMethodFunc := TgdcFunction.Create(nil);
    try
      gdcMethodFunc.SubSet := 'ByID';
      gdcMethodFunc.ID := mtdFunctionKey;
      gdcMethodFunc.Open;
      if gdcMethodFunc.Eof then
      begin
        gdcMethodFunc.AddMethodFunction(ClassKey, 'DoBeforePost', gdcClass);
      end;
      gdcMethodFunc.EditDialog;
    finally
      gdcMethodFunc.Free;
    end;
  finally
    gdcEvent.Free;
  end;

end;

procedure TdlgEntryFunctionWizard.btnQuantityClick(Sender: TObject);
begin
  if FdlgQuantityEntryEdit = nil then
    FdlgQuantityEntryEdit := TdlgQuantityEntryEdit.Create(Self);

  FdlgQuantityEntryEdit.gdcBaseHead := FgdcDocumentHead;
  FdlgQuantityEntryEdit.gdcBaseline := FgdcDocumentLine;

  if FdlgQuantityEntryEdit.ShowQuantity(FQuantList) = idOk then
  begin
    FdlgQuantityEntryEdit.FillQuantList(FQuantList);
  end;
end;

{ TQuatObject }

procedure TQuantObject.Assign(Source: TQuantObject);
begin
  FUnitStr := Source.FUnitStr;
  FQuant := Source.FQuant;
  FUnitType := Source.FUnitType;
end;

procedure TQuantObject.SetQuant(const Value: String);
begin
  FQuant := Value;
end;

procedure TQuantObject.SetUnitStr(const Value: String);
begin
  FUnitStr := Value;
end;

procedure TQuantObject.SetUnitType(const Value: TUnitType);
begin
  FUnitType := Value;
end;

procedure TdlgEntryFunctionWizard.actAnalyticsUpdate(Sender: TObject);
begin
  if (lvAnalytics.Items.Count = 0) or (lvAnalytics.Selected = nil) then
    pcAnalyticsValue.Enabled := False
  else
    pcAnalyticsValue.Enabled := True;
end;

procedure TdlgEntryFunctionWizard.tsKeysShow(Sender: TObject);
var
  Key: TID;
begin
  if lvAnalytics.Selected = nil then
  begin
    Exit;
  end;
  if TItemData(lvAnalytics.Selected.Data).RelationField.References <> nil then
  begin
    try
      Key := gdcBaseManager.GetIDByRUIDString(lvAnalytics.Selected.SubItems[1])
    except
      Key := -1;
    end;
    rfcValue.CreateControl(TItemData(lvAnalytics.Selected.Data).RelationField,
      TID2S(Key));
  end else
    rfcValue.CreateControl(TItemData(lvAnalytics.Selected.Data).RelationField,
      lvAnalytics.Selected.SubItems[1]);
end;

procedure TdlgEntryFunctionWizard.tsFieldsShow(Sender: TObject);
var
  RfEntry, RFDoc: TatRelationField;
  Str: String;
  Item: TListItem;

  procedure AddDocField(const AdditField: TField);
  var
    AdListItem: TListItem;
    AdStr: String;
  begin
    if (AdditField <> nil) and
      (ServFields.IndexOf(AdditField.FieldName) = -1) then
    begin
      if AdditField.DataSet = FgdcDocumentHead then
        AdStr := cwHeader
      else
        if AdditField.DataSet = FgdcDocumentLine then
          AdStr := cwLine
        else
          Exit;

      AdListItem := lvDocFields.Items.Add;
      AdListItem.Caption := AdStr;
      AdListItem.SubItems.Add(AdditField.FieldName);
      AdListItem.SubItems.Add(AdditField.DisplayName);
      AdListItem.Data := AdditField;
    end;
  end;

  procedure AddDoc(const gdcDoc: TgdcBase);
  var
    AI: Integer;

  begin
    for AI := 0 to gdcDoc.Fields.Count - 1 do
    if not gdcDoc.Fields[AI].Calculated then
    begin
      Str := gdcDoc.RelationByAliasName(gdcDoc.Fields[AI].FieldName);
      RFDoc := atDatabase.FindRelationField(Str,
        GetOriginFieldName(gdcDoc.Fields[AI].Origin));
      if CheckRF(RFEntry, RFDoc) then
        AddDocField(gdcDoc.Fields[AI]);
    end;
  end;
begin
  lvDocFields.Items.Clear;

  if lvAnalytics.Selected = nil then
  begin
    Exit;
  end;

  Item := lvAnalytics.Selected;
  if (Item <> nil) and (Item.Data <> nil) then
    RFEntry := TItemData(Item.Data).RelationField;

  if FgdcDocumentHead <> nil then
    AddDoc(FgdcDocumentHead);
  if FgdcDocumentLine <> nil then
    AddDoc(FgdcDocumentLine);
end;

{ TItemData }

constructor TItemData.Create;
begin
  RelationField := nil;
  AnalyticsType := antEmpty;
end;

end.

