//

unit gdc_frmMDHGRAccount_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDHGR_unit, Db, flt_sqlFilter, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, ComCtrls, ToolWin, ExtCtrls, IBDatabase,
  IBCustomDataSet, gdcBase, gdcBaseBank, StdCtrls,
  gsIBLookupComboBox, gd_security, gd_security_body, FrmPlSvr, gdcConst,
  TB2Item, TB2Dock, TB2Toolbar, gd_MacrosMenu;

type
  Tgdc_frmMDHGRAccount = class(Tgdc_frmMDHGR)
    SelfTransaction: TIBTransaction;
    TBControlItem1: TTBControlItem;
    ibcmbAccount: TgsIBLookupComboBox;
    MainMenu1: TMainMenu;
    TBControlItem2: TTBControlItem;
    lblAcct: TLabel;
    TBControlItem3: TTBControlItem;
    ibcmbComp: TgsIBLookupComboBox;
    TBControlItem4: TTBControlItem;
    lblComp: TLabel;
    procedure ibcmbAccountChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ibcmbCompChange(Sender: TObject); virtual;
    procedure ibcmbAccountCreateNewObject(Sender: TObject;
      ANewObject: TgdcBase);

  public
    procedure LoadSettings; override;
    procedure SaveSettings; override;
  end;

var
  gdc_frmMDHGRAccount: Tgdc_frmMDHGRAccount;

implementation

uses
  Storages, gd_ClassList, IBSQL, gdcBaseInterface;

{$R *.DFM}

procedure Tgdc_frmMDHGRAccount.ibcmbAccountChange(Sender: TObject);
var
  WasActive: Boolean;
begin
  if (gdcObject <> nil) and (gdcDetailObject <> nil) then
  begin
    if (ibcmbAccount.CurrentKey > '')
      and (gdcObject.HasSubSet('ByAccount'))
      and (gdcObject.ParamByName('accountkey').AsInteger = ibcmbAccount.CurrentKeyInt) then
    begin
      exit;
    end;

    if (ibcmbAccount.CurrentKey = '')
      and (not gdcObject.HasSubSet('ByAccount')) then
    begin
      exit;
    end;

    WasActive := gdcObject.Active;
    gdcObject.Close;
    if ibcmbAccount.CurrentKey > '' then
    begin
      gdcObject.AddSubSet('ByAccount');
      gdcObject.ParamByName('accountkey').AsInteger := ibcmbAccount.CurrentKeyInt;
    end else
    begin
      gdcObject.RemoveSubSet('ByAccount');
    end;
    gdcObject.Active := WasActive;
  end;
end;

procedure Tgdc_frmMDHGRAccount.LoadSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMMDHGRACCOUNT', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMMDHGRACCOUNT', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMMDHGRACCOUNT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMMDHGRACCOUNT',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMMDHGRACCOUNT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if Assigned(CompanyStorage) and Assigned(IBLogin) then
  begin
    CompanyStorage.LoadComponent(ibcmbComp, ibcmbComp.LoadFromStream);
    if not IBLogin.IsHolding then
    begin
      ibcmbComp.Enabled := False;
      ibcmbComp.CurrentKeyInt := IBLogin.CompanyKey;
    end else
    begin
      ibcmbComp.Enabled := True;
      ibcmbComp.CurrentKeyInt := CompanyStorage.ReadInteger('Bank', 'CurrentComp', IBLogin.CompanyKey);
    end;

    CompanyStorage.LoadComponent(ibcmbAccount, ibcmbAccount.LoadFromStream);
    ibcmbAccount.CurrentKeyInt := CompanyStorage.ReadInteger('Bank', 'CurrentAccount', -1);
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMMDHGRACCOUNT', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMMDHGRACCOUNT', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmMDHGRAccount.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMMDHGRACCOUNT', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMMDHGRACCOUNT', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMMDHGRACCOUNT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMMDHGRACCOUNT',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMMDHGRACCOUNT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if Assigned(CompanyStorage) then
  begin
    CompanyStorage.SaveComponent(ibcmbComp, ibcmbComp.SaveToStream);
    CompanyStorage.WriteInteger('Bank', 'CurrentComp', ibcmbComp.CurrentKeyInt);

    CompanyStorage.SaveComponent(ibcmbAccount, ibcmbAccount.SaveToStream);
    CompanyStorage.WriteInteger('Bank', 'CurrentAccount', ibcmbAccount.CurrentKeyInt);
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMMDHGRACCOUNT', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMMDHGRACCOUNT', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmMDHGRAccount.FormCreate(Sender: TObject);
begin
  ibcmbCompChange(nil);
  ibcmbAccountChange(nil);

  inherited;
end;

procedure Tgdc_frmMDHGRAccount.ibcmbCompChange(Sender: TObject);
var
  q: TIBSQL;
begin
  if ibcmbComp.CurrentKey = '' then
    ibcmbAccount.Condition := ' (gd_companyaccount.disabled IS NULL OR ' +
      ' gd_companyaccount.disabled = 0) AND ' +
      ' (gd_companyaccount.companykey in (' + IBLogin.HoldingList + ')) '
  else
    ibcmbAccount.Condition := ' (gd_companyaccount.disabled IS NULL ' +
      ' OR gd_companyaccount.disabled = 0) AND ' +
      ' (gd_companyaccount.companykey = ' + ibcmbComp.CurrentKey + ') ';

  ibcmbAccount.CurrentKey := ibcmbAccount.CurrentKey;

  if (ibcmbComp.CurrentKey > '') and (ibcmbAccount.CurrentKey = '') then
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;
      q.SQL.Text := 'SELECT companyaccountkey FROM gd_company WHERE contactkey = :CK';
      q.ParamByName('CK').AsInteger := ibcmbComp.CurrentKeyInt;
      q.ExecQuery;
      if (not q.EOF) and (not q.Fields[0].IsNull) then
        ibcmbAccount.CurrentKeyInt := q.Fields[0].AsInteger;
    finally
      q.Free;
    end;
  end;
end;

procedure Tgdc_frmMDHGRAccount.ibcmbAccountCreateNewObject(Sender: TObject;
  ANewObject: TgdcBase);
begin
  if ibcmbComp.CurrentKeyInt > 0 then
    ANewObject.FieldByName('companykey').AsInteger := ibcmbComp.CurrentKeyInt;
end;

initialization
  RegisterFrmClass(Tgdc_frmMDHGRAccount);

finalization
  UnRegisterFrmClass(Tgdc_frmMDHGRAccount);
end.
