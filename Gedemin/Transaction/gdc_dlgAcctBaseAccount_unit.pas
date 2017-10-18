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
    bbAnalyze: TBitBtn;
    actAnalyze: TAction;
    actValues: TAction;
    sbAnalyze: TScrollBox;
    sbValues: TScrollBox;
    bbValues: TBitBtn;
    Label2: TLabel;
    gsiblcGroupAccount: TgsIBLookupComboBox;
    bbAnalyzeExt: TBitBtn;
    sbAnalyzeExt: TScrollBox;
    actAnalyzeExt: TAction;
    actSelectedAnalyticsExt: TAction;
    procedure actAnalyzeExecute(Sender: TObject);
    procedure actValuesExecute(Sender: TObject);
    procedure actNewUpdate(Sender: TObject);
    procedure actAnalyzeExtExecute(Sender: TObject);

  private
    //Список ключей ед.измерения текущего счета с чек-боксом
    FValuesArray: TgdKeyObjectAssoc;

    // Список ключей аналитик для разв. сальдо текущего счета с чек-боксом
    FAnalyzeExtArray: TgdKeyObjectAssoc;

    procedure SetupValues;
    procedure SetupAnalyze;
    procedure SetupAnalyzeExt;
    procedure CheckAnalyzeExt;
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
  gd_ClassList, at_classes, gdcMetaData, gdcGood, gdcBaseInterface;

const 
  All = 'Все';
  OnlySelected = 'Только отмеченные';

type
  TValueCheckBox = class(TCheckBox);
  TAnalyzeExtCheckBox = class(TCheckBox);

constructor Tgdc_dlgAcctBaseAccount.Create(AnOwner: TComponent);
begin
  inherited;
  FValuesArray := TgdKeyObjectAssoc.Create;
  FAnalyzeExtArray := TgdKeyObjectAssoc.Create;

  if not (csDesigning in ComponentState) then
  begin
    actSelectedAnalytics.Caption := OnlySelected;
    actSelectedValues.Caption := OnlySelected;
    actSelectedAnalyticsExt.Caption := OnlySelected;
  end;
end;

destructor Tgdc_dlgAcctBaseAccount.Destroy;
begin
  FValuesArray.Free;
  FAnalyzeExtArray.Free;
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
  q: TIBSQL;
  Tr: TIBTransaction;
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

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := gdcBaseManager.Database;
    Tr.StartTransaction;

    q.Transaction := Tr;

    q.SQL.Text :=
      'DELETE FROM ac_accvalue WHERE accountkey = :accountkey ';
    q.ParamByName('accountkey').AsInteger := gdcObject.ID;
    q.ExecQuery;

    q.SQL.Text :=
      'INSERT INTO ac_accvalue (id, accountkey, valuekey) VALUES (:id, :accountkey, :valuekey)';
    for I := 0 to sbValues.ComponentCount - 1 do
      if (sbValues.Components[I] is TValueCheckBox) and TValueCheckBox(sbValues.Components[I]).Checked then
      begin
        q.ParamByName('id').AsInteger := gdcObject.GetNextID;
        q.ParamByName('accountkey').AsInteger := gdcObject.ID;
        q.ParamByName('valuekey').AsInteger := sbValues.Components[I].Tag;
        q.ExecQuery;
      end;

    q.SQL.Text :=
      'DELETE FROM ac_accanalyticsext WHERE accountkey = :accountkey ';
    q.ParamByName('accountkey').AsInteger := gdcObject.ID;
    q.ExecQuery;

    if dbrgTypeAccount.Value = 'B' then
    begin
      q.SQL.Text :=
        'INSERT INTO ac_accanalyticsext (id, accountkey, valuekey) VALUES (:id, :accountkey, :valuekey)';

      for I := 0 to sbAnalyzeExt.ComponentCount - 1 do
        if (sbAnalyzeExt.Components[I] is TAnalyzeExtCheckBox) and TAnalyzeExtCheckBox(sbAnalyzeExt.Components[I]).Checked then
        begin
          q.ParamByName('id').AsInteger := gdcObject.GetNextID;
          q.ParamByName('accountkey').AsInteger := gdcObject.ID;
          q.ParamByName('valuekey').AsInteger := sbAnalyzeExt.Components[I].Tag;
          q.ExecQuery;
        end;
    end;

    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGACCTBASEACCOUNT', 'POST', KEYPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGACCTBASEACCOUNT', 'POST', KEYPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgAcctBaseAccount.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
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
  SetupAnalyzeExt;

  tbsAttr.TabVisible := False;

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
      exit;

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
  F: TField;
begin
  while sbAnalyze.ComponentCount > 0 do
    sbAnalyze.Components[0].Free;

  CurrTop := 5;
  gdcRelationFields := TgdcRelationField.Create(nil);
  try
    gdcRelationFields.ExtraConditions.Text := ' z.fieldname LIKE ''USR$%'' AND z.relationname = ''AC_ACCOUNT''';
    gdcRelationFields.Open;
    if not gdcRelationFields.EOF then
      gdcRelationFields.Sort(gdcRelationFields.FieldByName('lname'), True);
    while not gdcRelationFields.EOF do
    begin
      F := gdcObject.FindField(gdcRelationFields.FieldByName('fieldname').AsString);
      if (F <> nil) and (F is TNumericField) and (F.AsInteger = 1) then
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
        (gdcObject.FindField(atDatabase.Relations.ByRelationName('AC_ACCOUNT').RelationFields[i].FieldName) <> nil) and
        (gdcObject.FieldByName(atDatabase.Relations.ByRelationName('AC_ACCOUNT').RelationFields[i].FieldName).AsInteger = 1) then
        gdcRelationFields.SelectedID.Add(atDatabase.Relations.ByRelationName('AC_ACCOUNT').RelationFields[i].ID);

    if gdcRelationFields.ChooseItems(A, '', '', 'z.relationname = ''AC_ACCOUNT'' and z.fieldname like ''USR$%'' and z.fieldsource = ''DBOOLEAN''') then
    begin

      if not (gdcObject.State in [dsEdit, dsInsert]) then
        gdcObject.Edit;

      for i := 0 to atDatabase.Relations.ByRelationName('AC_ACCOUNT').RelationFields.Count - 1 do
        if atDatabase.Relations.ByRelationName('AC_ACCOUNT').RelationFields[i].IsUserDefined and
          (atDatabase.Relations.ByRelationName('AC_ACCOUNT').RelationFields[i].Field.FieldName = 'DBOOLEAN') and
          (gdcObject.FindField(atDatabase.Relations.ByRelationName('AC_ACCOUNT').RelationFields[i].FieldName) <> nil) then
        begin
          gdcObject.FieldByName(atDatabase.Relations.ByRelationName('AC_ACCOUNT').RelationFields[i].FieldName).AsInteger := 0;
        end;

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
        if gdcObject.FindField(gdcRelationFields.FieldByName('FieldName').AsString) <> nil then
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
        end;

        gdcRelationFields.Next;
      end;
    end;

  finally
    gdcRelationFields.Free;
  end;

  CheckAnalyzeExt;
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
    CheckAnalyzeExt;
  end;
end;

procedure Tgdc_dlgAcctBaseAccount.actAnalyzeExtExecute(Sender: TObject);
var
  gdcRelationFields: TgdcRelationField;
  i: Integer;
  A: OleVariant;
  CB: TCheckBox;
  CurrTop: Integer;
  strAnalyze, strAnalyzeID, strExtraConditions: string;
begin
  inherited;
  strAnalyze := '';
  strAnalyzeID := ';';
  gdcRelationFields := TgdcRelationField.Create(Self);
  try
    gdcRelationFields.Open;

    for I := 0 to sbAnalyzeExt.ComponentCount - 1 do
      if (sbAnalyzeExt.Components[I] is TAnalyzeExtCheckBox) and
        (TAnalyzeExtCheckBox(sbAnalyzeExt.Components[I]).Checked ) then
        begin
          gdcRelationFields.SelectedID.Add(sbAnalyzeExt.Components[I].Tag);
          strAnalyzeID := strAnalyzeID + inttostr(sbAnalyzeExt.Components[I].Tag) + ';';
        end;
        
  // формируем строку с выбранными по счету аналитиками
    for i := 0 to atDatabase.Relations.ByRelationName('AC_ACCOUNT').RelationFields.Count - 1 do
      if (atDatabase.Relations.ByRelationName('AC_ACCOUNT').RelationFields[i].IsUserDefined and
        (atDatabase.Relations.ByRelationName('AC_ACCOUNT').RelationFields[i].Field.FieldName = 'DBOOLEAN')) and
        ((gdcObject.FieldByName(atDatabase.Relations.ByRelationName('AC_ACCOUNT').RelationFields[i].FieldName).AsInteger = 1) or
        (AnsiPos(';' + inttostr(atDatabase.Relations.ByRelationName('AC_ACCOUNT').RelationFields[i].ID) + ';', strAnalyzeID) <> 0)) then
        begin
          if strAnalyze <> '' then
            strAnalyze := strAnalyze + ', ';
          strAnalyze := strAnalyze + '''' + atDatabase.Relations.ByRelationName('AC_ACCOUNT').RelationFields[i].FieldName + '''';
        end;

    if strAnalyze = '' then
    begin
      MessageDlg('По данному счету нет объектов аналитического учета', mtWarning,
        [mbOk], -1);
      Exit;
    end;

    strExtraConditions := 'z.relationname = ''AC_ACCOUNT'' and z.fieldname like ''USR$%'' and z.fieldsource = ''DBOOLEAN''';
    strExtraConditions := strExtraConditions +
      ' and z.fieldname in (' + strAnalyze + ')';

    if gdcRelationFields.ChooseItems(A, '', '', strExtraConditions) then
    begin

    if not (gdcObject.State in [dsEdit, dsInsert]) then
        gdcObject.Edit;

      gdcObject.FieldByName('id').AsInteger := gdcObject.FieldByName('id').AsInteger;

      FAnalyzeExtArray.Clear;
      while sbAnalyzeExt.ComponentCount > 0 do
        sbAnalyzeExt.Components[0].Free;

      gdcRelationFields.Close;
      gdcRelationFields.SubSet := 'OnlySelected';
      gdcRelationFields.Open;
      if not gdcRelationFields.EOF then
        gdcRelationFields.Sort(gdcRelationFields.FieldByName('lname'), True);
      gdcRelationFields.First;

      CurrTop := 5;
      while not gdcRelationFields.EOF do
      begin
        CB := TAnalyzeExtCheckBox.Create(sbAnalyzeExt);
        CB.Left := 5;
        CB.Top := CurrTop;
        CB.Tag := gdcRelationFields.FieldByName('id').AsInteger;
        CB.Caption := gdcRelationFields.FieldByName('lname').AsString;
        sbAnalyzeExt.InsertControl(CB);
        CurrTop := CurrTop + CB.Height + 2;
        FAnalyzeExtArray.AddObject(gdcRelationFields.FieldByName('id').AsInteger, CB);
        CB.Checked := True;
        gdcRelationFields.Next;
      end;
    end;

  finally
    gdcRelationFields.Free;
  end;

  CheckAnalyzeExt;
end;

procedure Tgdc_dlgAcctBaseAccount.SetupAnalyzeExt;
var
  ibsql: TIBSQL;
  CB: TCheckBox;
  CurrTop: Integer;
begin
  FAnalyzeExtArray.Clear;
  while sbAnalyzeExt.ComponentCount > 0 do
    sbAnalyzeExt.Components[0].Free;

  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := gdcObject.ReadTransaction;
    ibsql.SQL.Text :=
      'SELECT * FROM ac_accanalyticsext WHERE accountkey = ' + IntToStr(gdcObject.ID);
    ibsql.ExecQuery;
    while not ibsql.Eof do
    begin
      FAnalyzeExtArray.AddObject(ibsql.FieldByName('valuekey').AsInteger, nil);
      ibsql.Next;
    end;

    ibsql.Close;

    ibsql.SQL.Text := 'SELECT r.lname, r.id FROM ac_accanalyticsext a JOIN at_relation_fields r ON a.valuekey = r.id WHERE a.accountkey = ' + IntToStr(gdcObject.ID) + ' ORDER BY lname ASC';
    ibsql.ExecQuery;
    if ibsql.Eof then
      exit;

    CurrTop := 5;
    while not ibsql.Eof do
    begin
      CB := TAnalyzeExtCheckBox.Create(sbAnalyzeExt);
      CB.Left := 5;
      CB.Top := CurrTop;
      CB.Tag := ibsql.FieldByName('id').AsInteger;
      CB.Caption := ibsql.FieldByName('lname').AsString;
      sbAnalyzeExt.InsertControl(CB);
      CurrTop := CurrTop + CB.Height + 2;
      if FAnalyzeExtArray.IndexOf(ibsql.FieldByName('id').AsInteger) > -1 then
      begin
        CB.Checked := True;
        FAnalyzeExtArray.ObjectByKey[ibsql.FieldByName('id').AsInteger] := CB;
      end;
      ibsql.Next;
    end;
  finally
    ibsql.Free;
  end;

  CheckAnalyzeExt;
end;

procedure Tgdc_dlgAcctBaseAccount.CheckAnalyzeExt;
var   i, j: Integer;
      Find : boolean;
begin
  bbAnalyzeExt.Enabled := dbrgTypeAccount.Value = 'B';

  //проверяем присутствует ли аналитика для разверн. сальдо в списке аналитики по счету

  for I := 0 to sbAnalyzeExt.ComponentCount - 1 do
    if (sbAnalyzeExt.Components[I] is TAnalyzeExtCheckBox) then
      begin
        Find := false;
        (sbAnalyzeExt.Components[I] as TAnalyzeExtCheckBox).Enabled := bbAnalyzeExt.Enabled;
        for J := 0 to sbAnalyze.ComponentCount - 1 do
          if (sbAnalyze.Components[J] is TDBCheckBox) then
            if (sbAnalyzeExt.Components[I] as TAnalyzeExtCheckBox).Caption = (sbAnalyze.Components[J] as TDBCheckBox).Caption then
              Find := true;
        if not Find then
          (sbAnalyzeExt.Components[I] as TAnalyzeExtCheckBox).Font.Color := clRed
        else
          (sbAnalyzeExt.Components[I] as TAnalyzeExtCheckBox).Font.Color := clWindowText;
      end;
end;

initialization
  RegisterFrmClass(Tgdc_dlgAcctBaseAccount);

finalization
  UnRegisterFrmClass(Tgdc_dlgAcctBaseAccount);
end.
