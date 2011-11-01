unit gdc_dlgAcctBaseAccount_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, DBCtrls, ExtCtrls, Db, IBCustomDataSet, Grids, DBGrids,
  gsDBGrid, gsIBGrid, dmDatabase_unit, ActnList, at_sql_setup, IBDatabase,
  gsIBLookupComboBox, IBSQL, gdc_dlgG_unit, at_Container, gdc_dlgTRPC_unit,
  Menus, gd_KeyAssoc, ComCtrls;

type
  Tgdc_dlgAcctBaseAccount = class(Tgdc_dlgTRPC)
    pAccountInfo: TPanel;
    Label2: TLabel;
    GroupBox1: TGroupBox;
    dbcbCurrAccount: TDBCheckBox;
    dbcbOffBalance: TDBCheckBox;
    dbrgTypeAccount: TDBRadioGroup;
    gsiblcGroupAccount: TgsIBLookupComboBox;
    lblAlias: TLabel;
    lblName: TLabel;
    dbedAlias: TDBEdit;
    dbedName: TDBEdit;
    TabSheet1: TTabSheet;
    pnlAnalytics: TPanel;
    pnlMainAnalytic: TPanel;
    lbRelation: TLabel;
    gsibRelationFields: TgsIBLookupComboBox;
    Panel1: TPanel;
    Label1: TLabel;
    atContainer: TatContainer;
    lblValues: TLabel;
    sbValues: TScrollBox;
    DBMemo1: TDBMemo;
    Label3: TLabel;
    dbcbDisabled: TDBCheckBox;
    procedure actNewUpdate(Sender: TObject);
    procedure atContainerAdjustControl(Sender: TObject; Control: TControl);
    procedure atcMainAdjustControl(Sender: TObject; Control: TControl);
  private
    //Список ключей ед.измерения текущего счета с чек-боксом
    FValuesArray: TgdKeyObjectAssoc;

    procedure SetupValues;
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
  gd_ClassList;

type
  TValueCheckBox = class(TCheckBox);

procedure Tgdc_dlgAcctBaseAccount.actNewUpdate(Sender: TObject);
begin
  inherited;

  lbRelation.Visible := gdcObject.FieldByName('activity').AsString = 'B';
  gsibRelationFields.Visible := lbRelation.Visible;

  if lbRelation.Visible then
    pnlMainAnalytic.Height := gsibRelationFields.Height + 6
  else
    pnlMainAnalytic.Height := 0;
end;

constructor Tgdc_dlgAcctBaseAccount.Create(AnOwner: TComponent);
begin
  inherited;
  FValuesArray := TgdKeyObjectAssoc.Create;
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
        'INSERT INTO ac_accvalue (id, accountkey, valuekey) VALUES (:id, :accountkey, :valuekey)';
      for I := 0 to sbValues.ComponentCount - 1 do
        if (sbValues.Components[I] is TValueCheckBox) and
          (TValueCheckBox(sbValues.Components[I]).Checked and
           (FValuesArray.IndexOf(sbValues.Components[I].Tag) = -1))
        then
        begin
          ibsql.ParamByName('id').AsInteger := gdcObject.GetNextID;
          ibsql.ParamByName('accountkey').AsInteger := gdcObject.ID;
          ibsql.ParamByName('valuekey').AsInteger := sbValues.Components[I].Tag;
          ibsql.ExecQuery;
          ibsql.Close;
        end;
      ibsql.SQL.Text :=
        'DELETE FROM ac_accvalue WHERE accountkey = :accountkey AND valuekey = :valuekey';
      for I := 0 to sbValues.ComponentCount - 1 do
        if (sbValues.Components[I] is TValueCheckBox) and
          ((not TValueCheckBox(sbValues.Components[I]).Checked) and
           (FValuesArray.IndexOf(sbValues.Components[I].Tag) > -1))
        then
        begin
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

    ibsql.SQL.Text := 'SELECT * FROM gd_value';
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

procedure Tgdc_dlgAcctBaseAccount.atContainerAdjustControl(Sender: TObject;
  Control: TControl);
var
  LabelC: TComponent;
begin
  inherited;
  if not (Control is TDBCheckBox) then
  begin
    Control.Visible := False;
    LabelC := FindComponent(Control.Name + '_label');
    if Assigned(LabelC) then
      (LabelC as TLabel).Visible := False;
  end;    
end;

procedure Tgdc_dlgAcctBaseAccount.atcMainAdjustControl(Sender: TObject;
  Control: TControl);
begin
  inherited;
  if Control is TDBCheckBox then
    Control.Visible := False;
end;

procedure Tgdc_dlgAcctBaseAccount.HideLabels;
var
  i: Integer;
begin
  for i:= 0 to atContainer.ComponentCount - 1 do
    if atContainer.Components[i] is TLabel then
      (atContainer.Components[i] as TLabel).Visible := False;
end;

initialization
  RegisterFrmClass(Tgdc_dlgAcctBaseAccount);

finalization
  UnRegisterFrmClass(Tgdc_dlgAcctBaseAccount);

end.
