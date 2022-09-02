// ShlTanya, 11.03.2019

unit gp_dlgFormatDemand_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  xCalculatorEdit, StdCtrls, DBCtrls, Mask, xDateEdits, gsIBLookupComboBox,
  ExtCtrls, ComCtrls, Buttons, dmDatabase_unit, IBDatabase, at_Classes,
  IBHeader, ActnList, gsStorage, gd_Security, gsTransactionComboBox,
  gsTransaction;

type
  TDemandFormatField = class
    FShortName: String;
    FFieldName: String;
    FTableName: String;
    constructor Create(const aShortName, aFieldName, aTableName: String);
  end;    

type
  TdlgFormatDemand = class(TForm)
    IBTransaction: TIBTransaction;
    pnlMain: TPanel;
    Bevel2: TBevel;
    Bevel1: TBevel;
    Bevel3: TBevel;
    Label17: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label12: TLabel;
    Label10: TLabel;
    Label16: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label11: TLabel;
    Label18: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label19: TLabel;
    sbSum: TSpeedButton;
    sbContract: TSpeedButton;
    sbBill: TSpeedButton;
    sbDestanation: TSpeedButton;
    dbeDest: TgsIBLookupComboBox;
    cbPayer: TComboBox;
    edSum: TEdit;
    cbCargoSender: TComboBox;
    cbCargoReceiver: TComboBox;
    cbDocumentDate: TComboBox;
    cbDateShip: TComboBox;
    cbDateSend: TComboBox;
    edContract: TEdit;
    edOper: TEdit;
    edOperKind: TEdit;
    edQueue: TEdit;
    edTerm: TEdit;
    gsiblcOurAccount: TgsIBLookupComboBox;
    edPaper: TEdit;
    edPaymentDestination: TEdit;
    bOk: TButton;
    bCancel: TButton;
    Bevel4: TBevel;
    sbDatePayment: TSpeedButton;
    cbUnionBill: TCheckBox;
    cbUseReturn: TCheckBox;
    Label1: TLabel;
    gsiblcTransaction: TgsIBLookupComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure bOkClick(Sender: TObject);
    procedure sbSumClick(Sender: TObject);
    procedure sbContractClick(Sender: TObject);
    procedure sbBillClick(Sender: TObject);
    procedure sbDatePaymentClick(Sender: TObject);
    procedure sbDestanationClick(Sender: TObject);
  private
    { Private declarations }
    procedure MakeField;
    procedure AddVariable(Edit: TEdit);
    function Save: Boolean;
    procedure Read;
  public
    { Public declarations }
  end;

var
  dlgFormatDemand: TdlgFormatDemand;

implementation

{$R *.DFM}

uses
  gp_dlgChooseField_unit, Storages;

{ TDemandFormatField }

constructor TDemandFormatField.Create(const aShortName, aFieldName,
  aTableName: String);
begin
  FShortName := aShortName;
  FFieldName := aFieldName;
  FTableName := aTableName;
end;


{ TfrmFormatDemand }

procedure TdlgFormatDemand.MakeField;

procedure SetComboItems(R: TatRelation);
var
  i: Integer;
begin
  if Assigned(R) and Assigned(R.RelationFields) then
  begin
    for i:= 0 to R.RelationFields.Count - 1 do
    begin
      if not Assigned(R.RelationFields[i].References) then

      begin
        if R.RelationFields[i].SQLType = blr_sql_date then
        begin
          cbDocumentDate.Items.AddObject(R.RelationFields[i].LShortName,
            TDemandFormatField.Create(R.RelationFields[i].LShortName,
            R.RelationFields[i].FieldName, R.RelationName));
          cbDateShip.Items.AddObject(R.RelationFields[i].LShortName,
            TDemandFormatField.Create(R.RelationFields[i].LShortName,
            R.RelationFields[i].FieldName, R.RelationName));
          cbDateSend.Items.AddObject(R.RelationFields[i].LShortName,
            TDemandFormatField.Create(R.RelationFields[i].LShortName,
            R.RelationFields[i].FieldName, R.RelationName));
        end;
      end

      else

        if R.RelationFields[i].References.RelationName = 'GD_CONTACT' then
        begin
          cbPayer.Items.AddObject(R.RelationFields[i].LShortName,
            TDemandFormatField.Create(R.RelationFields[i].LShortName,
              R.RelationFields[i].FieldName, R.RelationName));
          cbCargoSender.Items.AddObject(R.RelationFields[i].LShortName,
            TDemandFormatField.Create(R.RelationFields[i].LShortName,
              R.RelationFields[i].FieldName, R.RelationName));
          cbCargoReceiver.Items.AddObject(R.RelationFields[i].LShortName,
            TDemandFormatField.Create(R.RelationFields[i].LShortName,
              R.RelationFields[i].FieldName, R.RelationName));
        end;

    end;
  end;

end;

begin
  cbDocumentDate.Items.AddObject('Текущая дата',
    TDemandFormatField.Create('Текущая дата', 'ТекДата', ''));
  cbDateShip.Items.AddObject('Текущая дата',
    TDemandFormatField.Create('Текущая дата', 'ТекДата', ''));
  cbDateSend.Items.AddObject('Текущая дата',
    TDemandFormatField.Create('Текущая дата', 'ТекДата', ''));

  cbCargoSender.Items.AddObject('Он же',
    TDemandFormatField.Create('Он же', 'Он же', ''));
  cbCargoReceiver.Items.AddObject('Он же',
    TDemandFormatField.Create('Он же', 'Он же', ''));

  SetComboItems(atDatabase.Relations.ByRelationName('GD_DOCUMENT'));
  SetComboItems(atDatabase.Relations.ByRelationName('GD_DOCREALIZATION'));
  SetComboItems(atDatabase.Relations.ByRelationName('GD_DOCREALINFO'));

end;

procedure TdlgFormatDemand.FormCreate(Sender: TObject);
begin
  gsiblcOurAccount.Condition := Format('COMPANYKEY = %d', [IBLogin.CompanyKey]);
  MakeField;
  Read;
end;

procedure TdlgFormatDemand.AddVariable(Edit: TEdit);
begin
  if not Assigned(dlgChooseField) then
    dlgChooseField := TdlgChooseField.Create(Self);

  if dlgChooseField.ShowModal = mrOk then
    Edit.Text := Edit.Text + dlgChooseField.Variable;
end;

procedure TdlgFormatDemand.FormDestroy(Sender: TObject);
var
  i, j: Integer;
begin
  for i:= 0 to ComponentCount - 1 do
  begin
    if Components[i] is TComboBox then
    begin
      for j:= 0 to (Components[i] as TComboBox).Items.Count - 1 do
        if Assigned((Components[i] as TComboBox).Items.Objects[j]) then
          (Components[i] as TComboBox).Items.Objects[j].Free;
    end;
  end;
  if Assigned(dlgChooseField) then
    FreeAndNil(dlgChooseField);
end;

function TdlgFormatDemand.Save: Boolean;
var
  i: Integer;
begin
  Result := True;
  try
    if gsiblcOurAccount.CurrentKey = '' then
    begin
      Result := False;
      exit;
    end;

    GlobalStorage.WriteString('gp_DemandFormat', 'OURACCOUNTKEY',
      gsiblcOurAccount.CurrentKey);
    GlobalStorage.WriteString('gp_DemandFormat', 'OURACCOUNTNAME',
      gsiblcOurAccount.Text);
      
    GlobalStorage.WriteString('gp_DemandFormat', 'DEST',
      dbeDest.CurrentKey);
    GlobalStorage.WriteString('gp_DemandFormat', 'DESTNAME',
      dbeDest.Text);
    GlobalStorage.WriteString('gp_DemandFormat', 'Transaction',
      gsiblcTransaction.CurrentKey);


    for i:= 0 to ComponentCount - 1 do
    begin
      if Components[i] is TEdit then
      begin
        GlobalStorage.WriteString('gp_DemandFormat', (Components[i] as TEdit).Name,
            Format('%s{%s}', [(Components[i] as TEdit).Text, (Components[i] as TEdit).Hint]))
      end
      else
        if Components[i] is TComboBox then
        begin
          if ((Components[i] as TComboBox).ItemIndex >= 0) and
             Assigned((Components[i] as TComboBox).Items.Objects[(Components[i] as TComboBox).ItemIndex])
          then
            GlobalStorage.WriteString('gp_DemandFormat', (Components[i] as TComboBox).Name,
              Format('[%s(%s%%%s)]{%s}',
              [(Components[i] as TComboBox).Text,
               TDemandFormatField(
               (Components[i] as TComboBox).Items.Objects[(Components[i] as TComboBox).ItemIndex]).FFieldName,
               TDemandFormatField(
               (Components[i] as TComboBox).Items.Objects[(Components[i] as TComboBox).ItemIndex]).FTableName,
               (Components[i] as TComboBox).Hint
              ]));
        end;
    end;
    GlobalStorage.WriteInteger('gp_DemandFormat', 'UnionBill', Integer(cbUnionBill.Checked));
    GlobalStorage.WriteInteger('gp_DemandFormat', 'UseReturn', Integer(cbUseReturn.Checked));
  except
    Result := False;
  end;
end;

procedure TdlgFormatDemand.bOkClick(Sender: TObject);
begin
  if Save then
    ModalResult := mrOk;
end;

procedure TdlgFormatDemand.Read;
var
  F: TgsStorageFolder;
  i: Integer;
  C: TComponent;
  S: String;

function GetComponent(const aName: String): TComponent;
var
  j: Integer;
begin
  Result := nil;

  for j:= 0 to ComponentCount - 1 do
    if Components[j].Name = aName then
    begin
      Result := Components[j];
      Break;
    end;
    
end;

function SearchInStrings(const aStr: String; Items: TStrings): Integer;
var
  j: Integer;
  aFieldName: String;
  aTableName: String;
begin
  Result := -1;
  aFieldName := copy(aStr, 1, Pos('{', aStr) - 1);
  aFieldName := copy(aStr, Pos('(', aStr) + 1, Pos(')', aStr) - Pos('(', aStr) - 1);
  aTableName := copy(aFieldName, Pos('%', aFieldName) + 1, Length(aFieldName));
  aFieldName := copy(aFieldName, 1, Pos('%', aFieldName) - 1);
  for j:= 0 to Items.Count - 1 do
  begin
    if Assigned(Items.Objects[j]) and
      (TDemandFormatField(Items.Objects[j]).FFieldName = aFieldName) and
      (TDemandFormatField(Items.Objects[j]).FTableName = aTableName)
    then
    begin
      Result := j;
      Break;
    end;
  end;
end;

begin
  F := GlobalStorage.OpenFolder('gp_DemandFormat');
  if Assigned(F) then
  try
    for i:= 0 to F.ValuesCount - 1 do
    begin
      C := GetComponent(F.Values[i].Name);
      if Assigned(C) then
      begin
        S := F.Values[i].AsString;
        if C is TEdit then
          (C as TEdit).Text := copy(S, 1, Pos('{', S) - 1)
        else
          if C is TComboBox then
            (C as TComboBox).ItemIndex := SearchInStrings(S, (C as TComboBox).Items);
      end;
    end;
    gsiblcOurAccount.CurrentKey := GlobalStorage.ReadString('gp_DemandFormat', 'OURACCOUNTKEY',
                gsiblcOurAccount.CurrentKey);
    dbeDest.CurrentKey := GlobalStorage.ReadString('gp_DemandFormat', 'DEST',
                dbeDest.CurrentKey);
    gsiblcTransaction.CurrentKey := GlobalStorage.ReadString('gp_DemandFormat', 'Transaction', '');
  finally
    GlobalStorage.CloseFolder(nil);
  end;

  cbUnionBill.Checked := GlobalStorage.ReadInteger('gp_DemandFormat', 'UnionBill', 1) = 1;
  cbUseReturn.Checked := GlobalStorage.ReadInteger('gp_DemandFormat', 'UseReturn', 1) = 1;
end;

procedure TdlgFormatDemand.sbSumClick(Sender: TObject);
begin
  AddVariable(edSum);
end;

procedure TdlgFormatDemand.sbContractClick(Sender: TObject);
begin
  AddVariable(edContract);
end;

procedure TdlgFormatDemand.sbBillClick(Sender: TObject);
begin
  AddVariable(edPaper);
end;

procedure TdlgFormatDemand.sbDatePaymentClick(Sender: TObject);
begin
  AddVariable(edTerm);
end;

procedure TdlgFormatDemand.sbDestanationClick(Sender: TObject);
begin
  AddVariable(edPaymentDestination);
end;

end.
