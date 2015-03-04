
 {++
   Project ADDRESSBOOK
   Copyright © 2000- by Golden Software

   Модуль

     gdc_dlgCompany_unit

   Описание

     Окно для работы с компанией

   Автор

    Anton

   История

     ver    date    who    what
     1.00 - 25.06.2001 - anton - Первая версия

 --}


unit gdc_dlgOurCompany_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DBCtrls, StdCtrls, ComCtrls, Mask, gdc_dlgCustomCompany_unit, Db,
  IBCustomDataSet, gdcBase, gdcContacts, ActnList, at_Container,
  ToolWin, ExtCtrls, gsDBGrid, gsDBTreeView, gsIBLookupComboBox, Grids,
  DBGrids, Buttons, Menus, gsIBGrid, gdcAcctAccount,
  IBDatabase, gdcTree, TB2Item, TB2Dock, TB2Toolbar, JvDBImage;

type
  Tgdc_dlgOurCompany = class(Tgdc_dlgCustomCompany)
    actChooseAccount: TAction;
    actDeleteAccount: TAction;
    actActiveAccount: TAction;
    dsCompanyChart: TDataSource;
    TabSheet1: TTabSheet;
    dbgCompanyChart: TgsIBGrid;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    lbActive: TLabel;
    gdcAcctChart1: TgdcAcctChart;
    Button4: TButton;
    actEditChart: TAction;
    procedure actChooseAccountExecute(Sender: TObject);
    procedure actDeleteAccountUpdate(Sender: TObject);
    procedure actDeleteAccountExecute(Sender: TObject);
    procedure actActiveAccountExecute(Sender: TObject);
    procedure actEditChartUpdate(Sender: TObject);
    procedure actEditChartExecute(Sender: TObject);
    procedure gdcAcctChart1AfterOpen(DataSet: TDataSet);
  protected
    function NeedVisibleTabSheet(const ARelationName: String): Boolean; override;
  public
    procedure LoadSettings; override;
    procedure SaveSettings; override;
  end;

var
  gdc_dlgOurCompany: Tgdc_dlgOurCompany;

implementation

{$R *.DFM}

uses
  Storages,  gd_ClassList, gd_KeyAssoc;

procedure Tgdc_dlgOurCompany.LoadSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGOURCOMPANY', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGOURCOMPANY', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGOURCOMPANY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGOURCOMPANY',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGOURCOMPANY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if Assigned(UserStorage) then
    UserStorage.LoadComponent(dbgCompanyChart, dbgCompanyChart.LoadFromStream);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGOURCOMPANY', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGOURCOMPANY', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgOurCompany.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGOURCOMPANY', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGOURCOMPANY', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGOURCOMPANY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGOURCOMPANY',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGOURCOMPANY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if Assigned(UserStorage) then
    UserStorage.SaveComponent(dbgCompanyChart, dbgCompanyChart.SaveToStream);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGOURCOMPANY', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGOURCOMPANY', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgOurCompany.actChooseAccountExecute(Sender: TObject);
begin
  gdcAcctChart1.SetInclude(TgdcAcctChart.SelectObject('', '', 0, 'parent is null'));
end;

procedure Tgdc_dlgOurCompany.actDeleteAccountUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := gdcAcctChart1.RecordCount > 0;
end;

procedure Tgdc_dlgOurCompany.actDeleteAccountExecute(Sender: TObject);
begin
  gdcAcctChart1.SetExclude(True);
end;

procedure Tgdc_dlgOurCompany.actActiveAccountExecute(Sender: TObject);
begin
  gdcAcctChart1.Edit;
  try
    gdcAcctChart1.FieldByName('s$isactive').AsInteger := 1;
    gdcAcctChart1.Post;
  except
    gdcAcctChart1.Cancel;
    raise;
  end;
  lbActive.Caption := 'Активный план счетов: ' + gdcAcctChart1.FieldByName('name').AsString;
end;

procedure Tgdc_dlgOurCompany.actEditChartUpdate(Sender: TObject);
begin
  actEditChart.Enabled := not gdcAcctChart1.IsEmpty;
end;

procedure Tgdc_dlgOurCompany.actEditChartExecute(Sender: TObject);
begin
  gdcAcctChart1.EditMultiple(nil);
end;

procedure Tgdc_dlgOurCompany.gdcAcctChart1AfterOpen(DataSet: TDataSet);
begin
  DataSet.First;
  while not DataSet.Eof do
  begin
    if DataSet.FieldByName('s$isactive').AsInteger = 1 then
    begin
      lbActive.Caption := 'Активный план счетов: ' + DataSet.FieldByName('name').AsString;
      break;
    end;
    DataSet.Next;
  end;
  DataSet.First;
end;

function Tgdc_dlgOurCompany.NeedVisibleTabSheet(
  const ARelationName: String): Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_DLGTRPC_NEEDVISIBLETABSHEET('TGDC_DLGOURCOMPANY', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGOURCOMPANY', KEYNEEDVISIBLETABSHEET);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYNEEDVISIBLETABSHEET]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGOURCOMPANY') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), ARelationName]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGOURCOMPANY',
  {M}        'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = varBoolean then
  {M}          Result := Boolean(LResult);
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGOURCOMPANY' then
  {M}      begin
  {M}        Result := inherited NeedVisibleTabSheet(ARelationName);
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  if ARelationName = 'AC_COMPANYACCOUNT' then
    Result := False
  else
    Result := inherited NeedVisibleTabSheet(ARelationName);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGOURCOMPANY', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGOURCOMPANY', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgOurCompany);

finalization
  UnRegisterFrmClass(Tgdc_dlgOurCompany);
end.
