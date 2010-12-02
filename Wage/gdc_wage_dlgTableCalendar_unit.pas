
unit gdc_wage_dlgTableCalendar_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTRPC_unit, IBDatabase, Menus, Db, ActnList, at_Container, DBCtrls,
  StdCtrls, ComCtrls, Mask, CheckLst, IBCustomDataSet, gdcBase,
  gdcTableCalendar, xDateEdits, Grids, DBGrids, gsDBGrid, gsIBGrid;

type
  Tgdc_wage_dlgTableCalendar = class(Tgdc_dlgTRPC)
    Label1: TLabel;
    dbedName: TDBEdit;
    actCalcSchedule: TAction;
    GroupBox1: TGroupBox;
    cbHolidayIsWork: TDBCheckBox;
    Button1: TButton;
    Label2: TLabel;
    Label13: TLabel;
    tc: TTabControl;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    chbxWD: TDBCheckBox;
    xdeE3: TxDateDBEdit;
    xdeE2: TxDateDBEdit;
    xdeE4: TxDateDBEdit;
    xdeE1: TxDateDBEdit;
    xdeB2: TxDateDBEdit;
    xdeB3: TxDateDBEdit;
    xdeB4: TxDateDBEdit;
    xdeB1: TxDateDBEdit;
    xdeDB: TxDateEdit;
    xdeDE: TxDateEdit;
    TabSheet1: TTabSheet;
    ibgrTblCalDay: TgsIBGrid;
    dsTableCalendarDay: TDataSource;
    gdcTableCalendarDay: TgdcTableCalendarDay;
    xdeOffset: TDBEdit;
    Label11: TLabel;
    procedure actCalcScheduleUpdate(Sender: TObject);
    procedure actCalcScheduleExecute(Sender: TObject);
    procedure tcChange(Sender: TObject);
    procedure tcChanging(Sender: TObject; var AllowChange: Boolean);

  private
    FIsModified: Boolean;

  protected
    function DlgModified: Boolean; override;

  public
    procedure SetupRecord; override;

    procedure LoadSettings; override;
    procedure SaveSettings; override;

  end;

var
  gdc_wage_dlgTableCalendar: Tgdc_wage_dlgTableCalendar;

implementation

{$R *.DFM}

uses
  gd_ClassList, Storages;

{ Tgdc_wage_dlgTableCalendar }

procedure Tgdc_wage_dlgTableCalendar.actCalcScheduleUpdate(
  Sender: TObject);
begin
  actCalcSchedule.Enabled := Assigned(gdcObject) and
    (gdcObject.State in [dsEdit, dsBrowse]);
end;

procedure Tgdc_wage_dlgTableCalendar.actCalcScheduleExecute(
  Sender: TObject);
begin
  (gdcObject as TgdcTableCalendar).CalcSchedule(xdeDB.Date,
    xdeDE.Date, cbHolidayIsWork.Checked);
  FIsModified := True;  
end;

procedure Tgdc_wage_dlgTableCalendar.tcChange(Sender: TObject);
begin
  xdeOffset.DataField := Format('w%d_offset', [tc.TabIndex + 1]);
  xdeB1.DataField := Format('w%d_start1', [tc.TabIndex + 1]);
  xdeB2.DataField := Format('w%d_start2', [tc.TabIndex + 1]);
  xdeB3.DataField := Format('w%d_start3', [tc.TabIndex + 1]);
  xdeB4.DataField := Format('w%d_start4', [tc.TabIndex + 1]);

  xdeE1.DataField := Format('w%d_end1', [tc.TabIndex + 1]);
  xdeE2.DataField := Format('w%d_end2', [tc.TabIndex + 1]);
  xdeE3.DataField := Format('w%d_end3', [tc.TabIndex + 1]);
  xdeE4.DataField := Format('w%d_end4', [tc.TabIndex + 1]);

  case tc.TabIndex of
    0: chbxWD.DataField := 'mon';
    1: chbxWD.DataField := 'tue';
    2: chbxWD.DataField := 'wed';
    3: chbxWD.DataField := 'thu';
    4: chbxWD.DataField := 'fri';
    5: chbxWD.DataField := 'sat';
    6: chbxWD.DataField := 'sun';
    7: chbxWD.DataField := '';
  end;

  chbxWD.Visible := chbxWD.DataField > '';
end;

procedure Tgdc_wage_dlgTableCalendar.tcChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  inherited;
  if Assigned(gdcObject.FindField(chbxWD.DataField)) then
    gdcObject.FieldByName(chbxWD.DataField).AsInteger := Integer(chbxWD.Checked);
end;

function Tgdc_wage_dlgTableCalendar.DlgModified: Boolean;
begin
  Result := inherited DlgModified or FIsModified;
end;

procedure Tgdc_wage_dlgTableCalendar.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_WAGE_DLGTABLECALENDAR', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_WAGE_DLGTABLECALENDAR', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_WAGE_DLGTABLECALENDAR') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_WAGE_DLGTABLECALENDAR',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_WAGE_DLGTABLECALENDAR' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FIsModified := False;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_WAGE_DLGTABLECALENDAR', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_WAGE_DLGTABLECALENDAR', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_wage_dlgTableCalendar.LoadSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_WAGE_DLGTABLECALENDAR', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_WAGE_DLGTABLECALENDAR', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_WAGE_DLGTABLECALENDAR') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_WAGE_DLGTABLECALENDAR',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_WAGE_DLGTABLECALENDAR' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if Assigned(UserStorage) then
    UserStorage.LoadComponent(ibgrTblCalDay, ibgrTblCalDay.LoadFromStream);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_WAGE_DLGTABLECALENDAR', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_WAGE_DLGTABLECALENDAR', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_wage_dlgTableCalendar.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_WAGE_DLGTABLECALENDAR', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin                                            
  {M}      SetFirstMethodAssoc('TGDC_WAGE_DLGTABLECALENDAR', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_WAGE_DLGTABLECALENDAR') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_WAGE_DLGTABLECALENDAR',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_WAGE_DLGTABLECALENDAR' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if Assigned(UserStorage) then
    SaveGrid(ibgrTblCalDay);

  inherited;
                                                                 
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_WAGE_DLGTABLECALENDAR', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_WAGE_DLGTABLECALENDAR', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_wage_dlgTableCalendar);

finalization
  UnRegisterFrmClass(Tgdc_wage_dlgTableCalendar);

end.
