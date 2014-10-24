unit gdc_dlgAcctBaseAccount_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, DBCtrls, ExtCtrls, Db, IBCustomDataSet, Grids, DBGrids,
  gsDBGrid, gsIBGrid, dmDatabase_unit, ActnList, at_sql_setup, IBDatabase,
  gsIBLookupComboBox, IBSQL, gdc_dlgG_unit, at_Container, gdc_dlgTRPC_unit,
  Menus, gd_KeyAssoc, ComCtrls, Buttons;

type
  Tgdc_dlgAcctBaseAccount = class(Tgdc_dlgTRPC)
    pAccountInfo: TPanel;
    GroupBox1: TGroupBox;
    dbcbCurrAccount: TDBCheckBox;
    dbcbOffBalance: TDBCheckBox;
    dbrgTypeAccount: TDBRadioGroup;
    lblAlias: TLabel;
    lblName: TLabel;
    dbedAlias: TDBEdit;
    dbedName: TDBEdit;
    TabSheet1: TTabSheet;
    dbcbDisabled: TDBCheckBox;
    actSelectedAnalytics: TAction;
    actSelectedValues: TAction;
    DBMemo1: TDBMemo;
    lbRelation: TLabel;
    gsibRelationFields: TgsIBLookupComboBox;
    bbAnalyze: TBitBtn;
    actAnalyze: TAction;
    actValues: TAction;
    sbAnalyze: TScrollBox;
    sbValues: TScrollBox;
    bbValues: TBitBtn;
    Label2: TLabel;
    gsiblcGroupAccount: TgsIBLookupComboBox;
    procedure actAnalyzeExecute(Sender: TObject);
    procedure actValuesExecute(Sender: TObject);
    procedure actNewUpdate(Sender: TObject);

  private
    //Список ключей ед.измерения текущего счета с чек-боксом
    FValuesArray: TgdKeyObjectAssoc;

    procedure SetupValues;
    procedure SetupAnalyze;
    procedure HideLabels;

  protected
    function DlgModified: Boolean; override;

    function NeedVisibleTabSheet(const ARelationName: String): Boolean; override;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor  Destroy; override;

    procedure Post; override;
    procedure SetupRecord; override;
  end;

var
  gdc_dlgAcctBaseAccount: Tgdc_dlgAcctBaseAccount;

implementation

{$R *.DFM}


uses
  gd_ClassList, at_classes, gdcMetaData, gdcGood;

const 
  All = 'Все';
  OnlySelected = 'Только отмеченные';

type
  TValueCheckBox = class(TCheckBox);

constructor Tgdc_dlgAcctBaseAccount.Create(AnOwner: TComponent);
begin
  inherited;
  FValuesArray := TgdKeyObjectAssoc.Create;

  if not (csDesigning in ComponentState) then
  begin
    actSelectedAnalytics.Caption := OnlySelected;
    actSelectedValues.Caption := OnlySelected;
  end;
end;

destructor Tgdc_dlgAcctBaseAccount.Destroy;
begin
  FValuesArray.Free;
  inherited;        
end;

function Tgdc_dlgAcctBaseAccount.DlgModified: Boolean;
var
  I: Integer;
begin
  Result := inherited DlgModified;

  if not Result then
  for I := 0 to sbValues.ComponentCount - 1 do
    if (sbValues.Components[I] is TValueCheckBox) and
      (TValueCheckBox(sbValues.Components[I]).Checked and
       (FValuesArray.IndexOf(sbValues.Components[I].Tag) = -1)) or
      ((not TValueCheckBox(sbValues.Components[I]).Checked) and
       (FValuesArray.IndexOf(sbValues.Components[I].Tag) > -1))
    then
    begin
      Result := True;
      Break;
    end;
end;

function Tgdc_dlgAcctBaseAccount.NeedVisibleTabSheet(
  const ARelationName: String): Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_DLGTRPC_NEEDVISIBLETABSHEET('TGDC_DLGACCTBASEACCOUNT', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGACCTBASEACCOUNT', KEYNEEDVISIBLETABSHEET);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYNEEDVISIBLETABSHEET]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGACCTBASEACCOUNT') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), ARelationName]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGACCTBASEACCOUNT',
  {M}        'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = varBoolean then
  {M}          Result := Boolean(LResult);
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGACCTBASEACCOUNT' then
  {M}      begin
  {M}        Result := Inherited NeedVisibleTabSheet(ARelationName);
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  if ARelationName = 'AC_COMPANYACCOUNT' then
    Result := False
  else
    Result := inherited NeedVisibleTabSheet(ARelationName);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGACCTBASEACCOUNT', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGACCTBASEACCOUNT', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgAcctBaseAccount.Post;
var
  ibsql: TIBSQL;
  I: Integer;
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGACCTBASEACCOUNT', 'POST', KEYPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGACCTBASEACCOUNT', KEYPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGACCTBASEACCOUNT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGACCTBASEACCOUNT',
  {M}          'POST', KEYPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGACCTBASEACCOUNT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := TIBTransaction.Create(ibsql);
    ibsql.Transaction.DefaultDatabase :=  gdcObject.Transaction.DefaultDatabase;
    ibsql.Transaction.StartTransaction;
    try
      ibsql.SQL.Text :=
        'DELETE FROM ac_accvalue WHERE accountkey = :accountkey ';
      ibsql.ParamByName('accountkey').AsInteger := gdcObject.ID;
      ibsql.ExecQuery;

      ibsql.Close;

      ibsql.SQL.Text :=
        'INSERT INTO ac_accvalue (id, accountkey, valuekey) VALUES (:id, :accountkey, :valuekey)';
      for I := 0 to sbValues.ComponentCount - 1 do
        if (sbValues.Components[I] is TValueCheckBox) and
          (TValueCheckBox(sbValues.Components[I]).Checked )
        then
        begin
          ibsql.ParamByName('id').AsInteger := gdcObject.GetNextID;
          ibsql.ParamByName('accountkey').AsInteger := gdcObject.ID;
          ibsql.ParamByName('valuekey').AsInteger := sbValues.Components[I].Tag;
          ibsql.ExecQuery;
          ibsql.Close;
        end;

    finally
      ibsql.Transaction.Commit;
    end;
  finally
    ibsql.Free;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGACCTBASEACCOUNT', 'POST', KEYPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGACCTBASEACCOUNT', 'POST', KEYPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgAcctBaseAccount.SetupRecord;
   VAR
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
     tbsAttr: TComponent;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGACCTBASEACCOUNT', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGACCTBASEACCOUNT', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGACCTBASEACCOUNT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGACCTBASEACCOUNT',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGACCTBASEACCOUNT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  HideLabels;
  SetupValues;
  SetupAnalyze;

  lbRelation.Visible := gdcObject.FieldByName('activity').AsString = 'B';
  gsibRelationFields.Visible := lbRelation.Visible;

  tbsAttr := Self.FindComponent('tbsAttr');
  if Assigned(tbsAttr) then (tbsAttr as TTabSheet).TabVisible := False;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGACCTBASEACCOUNT', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGACCTBASEACCOUNT', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgAcctBaseAccount.SetupValues;
var
  ibsql: TIBSQL;
  CB: TCheckBox;
  CurrTop: Integer;
begin
  FValuesArray.Clear;
  while sbValues.ComponentCount > 0 do
    sbValues.Components[0].Free;

  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := gdcObject.ReadTransaction;
    ibsql.SQL.Text :=
      'SELECT * FROM ac_accvalue WHERE accountkey = ' + IntToStr(gdcObject.ID);
    ibsql.ExecQuery;
    while not ibsql.Eof do
    begin
      FValuesArray.AddObject(ibsql.FieldByName('valuekey').AsInteger, nil);
      ibsql.Next;
    end;

    ibsql.Close;

    ibsql.SQL.Text := 'SELECT v.name, v.id FROM ac_accvalue a JOIN gd_value v ON a.valuekey = v.id WHERE a.accountkey = ' + IntToStr(gdcObject.ID) + ' ORDER BY name ASC';
    ibsql.ExecQuery;
    if ibsql.Eof then
      Exit;

    CurrTop := 5;
    while not ibsql.Eof do
    begin
      CB := TValueCheckBox.Create(sbValues);
      CB.Left := 5;
      CB.Top := CurrTop;
      CB.Tag := ibsql.FieldByName('id').AsInteger;
      CB.Caption := ibsql.FieldByName('name').AsString;
      sbValues.InsertControl(CB);
      CurrTop := CurrTop + CB.Height + 2;
      if FValuesArray.IndexOf(ibsql.FieldByName('id').AsInteger) > -1 then
      begin
        CB.Checked := True;
        FValuesArray.ObjectByKey[ibsql.FieldByName('id').AsInteger] := CB;
      end;
      ibsql.Next;
    end;

  finally
    ibsql.Free;
  end;
end;



procedure Tgdc_dlgAcctBaseAccount.HideLabels;
begin
end;

procedure Tgdc_dlgAcctBaseAccount.SetupAnalyze;
var
  CB: TDBCheckBox;
  CurrTop: Integer;
  gdcRelationFields: TgdcRelationField;
begin

  while sbAnalyze.ComponentCount > 0 do
    sbAnalyze.Components[0].Free;

  CurrTop := 5;
  gdcRelationFields := TgdcRelationField.Create(Self);
  try
    gdcRelationFields.ExtraConditions.Text := ' z.fieldname like ''USR$%'' and z.relationname = ''AC_ACCOUNT''';
    gdcRelationFields.Open;
    if not gdcRelationFields.EOF then
      gdcRelationFields.Sort(gdcRelationFields.FieldByName('lname'), true);
    while not gdcRelationFields.EOF do
    begin

      if gdcObject.FieldByName(gdcRelationFields.FieldByName('fieldname').AsString).AsInteger = 1 then
      begin
        CB := TDBCheckBox.Create(sbAnalyze);
        CB.Left := 5;
        CB.Top := CurrTop;
        CB.DataSource := dsgdcBase;
        CB.DataField := gdcRelationFields.FieldByName('fieldname').AsString;
        CB.ValueChecked := '1';
        CB.Width := sbAnalyze.Width - 10;
        CB.ValueUnChecked := '0';
        CB.Caption := gdcRelationFields.FieldByName('lname').AsString;
        CB.ReadOnly := True;
        sbAnalyze.InsertControl(CB);
        CurrTop := CurrTop + CB.Height + 2;
      end;
      gdcRelationFields.Next;
    end;
  finally
    gdcRelationFields.Free;
  end;

end;

procedure Tgdc_dlgAcctBaseAccount.actAnalyzeExecute(Sender: TObject);
var
  gdcRelationFields: TgdcRelationField;
  i: Integer;
  A: OleVariant;
  CB: TDBCheckBox;
  CurrTop: Integer;

begin
  inherited;
  gdcRelationFields := TgdcRelationField.Create(Self);
  try
    gdcRelationFields.Open;

    for i := 0 to atDatabase.Relations.ByRelationName('AC_ACCOUNT').RelationFields.Count - 1 do
      if atDatabase.Relations.ByRelationName('AC_ACCOUNT').RelationFields[i].IsUserDefined and
        (atDatabase.Relations.ByRelationName('AC_ACCOUNT').RelationFields[i].Field.FieldName = 'DBOOLEAN') and
        (gdcObject.FieldByName(atDatabase.Relations.ByRelationName('AC_ACCOUNT').RelationFields[i].FieldName).AsInteger = 1) then
        gdcRelationFields.SelectedID.Add(atDatabase.Relations.ByRelationName('AC_ACCOUNT').RelationFields[i].ID);

    if gdcRelationFields.ChooseItems(A, '', '', 'z.relationname = ''AC_ACCOUNT'' and z.fieldname like ''USR$%'' and z.fieldsource = ''DBOOLEAN''') then
    begin

      if not (gdcObject.State in [dsEdit, dsInsert]) then
        gdcObject.Edit;

      for i := 0 to atDatabase.Relations.ByRelationName('AC_ACCOUNT').RelationFields.Count - 1 do
        if atDatabase.Relations.ByRelationName('AC_ACCOUNT').RelationFields[i].IsUserDefined and
          (atDatabase.Relations.ByRelationName('AC_ACCOUNT').RelationFields[i].Field.FieldName = 'DBOOLEAN') then
          gdcObject.FieldByName(atDatabase.Relations.ByRelationName('AC_ACCOUNT').RelationFields[i].FieldName).AsInteger := 0;

      gdcRelationFields.Close;
      gdcRelationFields.SubSet := 'OnlySelected';
      gdcRelationFields.Open;
      if not gdcRelationFields.EOF then
        gdcRelationFields.Sort(gdcRelationFields.FieldByName('lname'), True);
      gdcRelationFields.First;

      CurrTop := 5;
      while sbAnalyze.ComponentCount > 0 do
        sbAnalyze.Components[0].Free;

      while not gdcRelationFields.EOF do
      begin
        gdcObject.FieldByName(gdcRelationFields.FieldByName('FieldName').AsString).AsInteger := 1;
        CB := TDBCheckBox.Create(sbAnalyze);
        CB.Left := 5;
        CB.Top := CurrTop;
        CB.DataSource := dsgdcBase;
        CB.DataField := gdcRelationFields.FieldByName('FieldName').AsString;
        CB.ValueChecked := '1';
        CB.Width := sbAnalyze.Width - 10;
        CB.ValueUnChecked := '0';
        CB.Caption := gdcRelationFields.FieldByName('LName').AsString;
        CB.ReadOnly := True;
        sbAnalyze.InsertControl(CB);
        CurrTop := CurrTop + CB.Height + 2;

        gdcRelationFields.Next;
      end;
    end;

  finally
    gdcRelationFields.Free;
  end;
end;

procedure Tgdc_dlgAcctBaseAccount.actValuesExecute(Sender: TObject);
var
  gdcValue: TgdcValue;
  A: OleVariant;
  CB: TCheckBox;
  I, CurrTop: Integer;


begin
  inherited;
  gdcValue := TgdcValue.Create(Self);
  try
    gdcValue.Open;

    for I := 0 to sbValues.ComponentCount - 1 do
      if (sbValues.Components[I] is TValueCheckBox) and
        (TValueCheckBox(sbValues.Components[I]).Checked )
      then
        gdcValue.SelectedID.Add(sbValues.Components[I].Tag);


    if gdcValue.ChooseItems(A) then
    begin

      if not (gdcObject.State in [dsEdit, dsInsert]) then
        gdcObject.Edit;

      gdcObject.FieldByName('id').AsInteger := gdcObject.FieldByName('id').AsInteger;   

      FValuesArray.Clear;
      while sbValues.ComponentCount > 0 do
        sbValues.Components[0].Free;


      gdcValue.Close;
      gdcValue.SubSet := 'OnlySelected';
      gdcValue.Open;
      if not gdcValue.EOF then
        gdcValue.Sort(gdcValue.FieldByName('name'), True);
      gdcValue.First;

      CurrTop := 5;
      while not gdcValue.EOF do
      begin
        CB := TValueCheckBox.Create(sbValues);
        CB.Left := 5;
        CB.Top := CurrTop;
        CB.Tag := gdcValue.FieldByName('id').AsInteger;
        CB.Caption := gdcValue.FieldByName('name').AsString;
        sbValues.InsertControl(CB);
        CurrTop := CurrTop + CB.Height + 2;
        FValuesArray.AddObject(gdcValue.FieldByName('id').AsInteger, CB);
        CB.Checked := True;
        gdcValue.Next;
      end;

    end;

  finally
    gdcValue.Free;
  end;
end;

procedure Tgdc_dlgAcctBaseAccount.actNewUpdate(Sender: TObject);
begin
  inherited;
  
  if (gdcObject <> nil) and (not gdcObject.EOF) then
  begin
    lbRelation.Visible := dbrgTypeAccount.Value = 'B';
    gsibRelationFields.Visible := lbRelation.Visible;
  end;
end;

initialization
  RegisterFrmClass(Tgdc_dlgAcctBaseAccount);

finalization
  UnRegisterFrmClass(Tgdc_dlgAcctBaseAccount);
end.
