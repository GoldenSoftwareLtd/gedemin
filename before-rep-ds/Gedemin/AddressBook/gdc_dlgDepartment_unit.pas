
unit gdc_dlgDepartment_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTRPC_unit, StdCtrls, Mask, DBCtrls, IBDatabase, Menus, Db,
  ActnList, at_Container, ComCtrls, gsIBLookupComboBox, gdcBase;

type
  Tgdc_dlgDepartment = class(Tgdc_dlgTRPC)
    Label1: TLabel;
    dbedName: TDBEdit;
    iblkupCompany: TgsIBLookupComboBox;
    iblkupDepartment: TgsIBLookupComboBox;
    Label2: TLabel;
    Label3: TLabel;
    Label9: TLabel;
    gsiblkupAddress: TgsIBLookupComboBox;
    Label4: TLabel;
    DBEdit2: TDBEdit;
    DBEdit3: TDBEdit;
    DBEdit4: TDBEdit;
    Label13: TLabel;
    Label5: TLabel;
    DBEdit5: TDBEdit;
    Label6: TLabel;
    Label31: TLabel;
    dbmAddress: TDBMemo;
    Label10: TLabel;
    dbeZIP: TDBEdit;
    Label7: TLabel;
    dbePbox: TDBEdit;
    Label11: TLabel;
    dbeEmail: TDBEdit;
    Label17: TLabel;
    dbedWWW: TDBEdit;
    Label66: TLabel;
    dbePhone: TDBEdit;
    Label67: TLabel;
    dbeFax: TDBEdit;
    dbcbDisabled: TDBCheckBox;
    procedure iblkupCompanyChange(Sender: TObject);
    procedure iblkupDepartmentCreateNewObject(Sender: TObject;
      ANewObject: TgdcBase);
    procedure iblkupDepartmentAfterCreateDialog(Sender: TObject;
      ANewObject: TgdcBase);

  protected
    function NeedVisibleTabSheet(const ARelationName: String): Boolean; override;

  public
    procedure SyncControls; override;
    procedure SetupRecord; override;
    procedure BeforePost; override;
  end;

var
  gdc_dlgDepartment: Tgdc_dlgDepartment;

implementation

{$R *.DFM}

uses
  IBSQL, gd_ClassList, gdcBaseInterface;

procedure Tgdc_dlgDepartment.BeforePost;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGDEPARTMENT', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGDEPARTMENT', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGDEPARTMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGDEPARTMENT',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGDEPARTMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if gdcObject.FieldByName('parent').IsNull then
  begin
    if iblkupCompany.CurrentKey > '' then
      gdcObject.FieldByName('parent').AsInteger := iblkupCompany.CurrentKeyInt;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGDEPARTMENT', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGDEPARTMENT', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgDepartment.iblkupCompanyChange(Sender: TObject);
begin
  if iblkupCompany.CurrentKey > '' then
  begin
    iblkupDepartment.Condition := Format('contacttype=4 AND lb > (SELECT c1.lb FROM gd_contact c1 WHERE c1.id = %d) AND rb <= (SELECT c1.rb FROM gd_contact c1 WHERE c1.id = %d)',
      [iblkupCompany.CurrentKeyInt, iblkupCompany.CurrentKeyInt]);
    iblkupDepartment.CurrentKey := iblkupDepartment.CurrentKey;
  end;
end;

function Tgdc_dlgDepartment.NeedVisibleTabSheet(
  const ARelationName: String): Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_DLGTRPC_NEEDVISIBLETABSHEET('TGDC_DLGDEPARTMENT', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGDEPARTMENT', KEYNEEDVISIBLETABSHEET);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYNEEDVISIBLETABSHEET]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGDEPARTMENT') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), ARelationName]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGDEPARTMENT',
  {M}        'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = varBoolean then
  {M}          Result := Boolean(LResult);
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGDEPARTMENT' then
  {M}      begin
  {M}        Result := Inherited NeedVisibleTabSheet(ARelationName);
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  if AnsiCompareText(ARelationName, 'GD_HOLDING') = 0 then
    Result := False
  else if AnsiCompareText(ARelationName, 'GD_CONTACTLIST') = 0 then
    Result := False
  else
    Result := inherited NeedVisibleTabSheet(ARelationName);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGDEPARTMENT', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGDEPARTMENT', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgDepartment.SetupRecord;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}

  q: TIBSQL;
  P: Integer;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGDEPARTMENT', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGDEPARTMENT', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGDEPARTMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGDEPARTMENT',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGDEPARTMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if gdcObject.Transaction.InTransaction then
  begin
    if iblkupCompany.Transaction <> gdcObject.Transaction then
    begin
      iblkupCompany.Transaction := gdcObject.Transaction;
    end;
  end;

  inherited;

  if not gdcObject.FieldByName('parent').IsNull then
  begin
    q := TIBSQL.Create(nil);
    try
      if gdcObject.Transaction.InTransaction then
        q.Transaction := gdcObject.Transaction
      else
        q.Transaction := gdcBaseManager.ReadTransaction;
      q.SQL.Text := 'SELECT id, parent, lb, rb, contacttype FROM gd_contact WHERE id = :ID';
      q.ParamByName('id').AsInteger := gdcObject.FieldByName('parent').AsInteger;
      q.ExecQuery;

      if q.FieldByName('contacttype').AsInteger <> 4 then
        gdcObject.FieldByName('parent').Clear;

      while
        (not q.EOF)
        and (q.FieldByName('contacttype').AsInteger = 4)
        and (not q.FieldByName('parent').IsNull) do
      begin
        P := q.FieldByName('parent').AsInteger;
        q.Close;
        q.ParamByName('id').AsInteger := P;
        q.ExecQuery;
      end;

      if not q.EOF then
      begin
        if q.FieldByName('contacttype').AsInteger <> 4 then
          iblkupCompany.CurrentKeyInt := q.FieldByName('id').AsInteger
        else
          iblkupDepartment.Condition := Format('contacttype=4 AND lb > (SELECT c1.lb FROM gd_contact c1 WHERE c1.id=%d) AND rb <= (SELECT c2.rb FROM gd_contact c2 WHERE c2.id=%d)',
            [q.FieldByName('id').Asinteger, q.FieldByName('id').AsInteger]);
      end else
      begin
        iblkupDepartment.Condition := 'contacttype=4';
      end;
    finally
      q.Free;
    end;
  end;

  iblkupCompany.ReadOnly := iblkupCompany.CurrentKey > '';

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGDEPARTMENT', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGDEPARTMENT', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;


procedure Tgdc_dlgDepartment.iblkupDepartmentCreateNewObject(
  Sender: TObject; ANewObject: TgdcBase);
begin
  if iblkupCompany.CurrentKey > '' then
    ANewObject.FieldByName('parent').AsInteger := iblkupCompany.CurrentKeyInt;
end;

procedure Tgdc_dlgDepartment.iblkupDepartmentAfterCreateDialog(
  Sender: TObject; ANewObject: TgdcBase);
begin
  iblkupCompanyChange(nil);
end;

procedure Tgdc_dlgDepartment.SyncControls;
begin
  inherited;
  iblkupDepartment.Color := clWindow;
end;

initialization
  RegisterFrmClass(Tgdc_dlgDepartment);

finalization
  UnRegisterFrmClass(Tgdc_dlgDepartment);
end.
