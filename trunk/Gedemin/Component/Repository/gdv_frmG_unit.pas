unit gdv_frmG_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, DBGrids, gsDBGrid, gsIBGrid, ComCtrls, gsDBTreeView, ExtCtrls,
  TB2Dock, TB2Toolbar, gdc_Createable_Form, Db, IBCustomDataSet, gdcBase,
  gdcTree, gdcAcctAccount, IBDatabase, Buttons, StdCtrls, Mask, xDateEdits,
  TB2Item, ActnList, Menus, gd_MacrosMenu, gd_ReportMenu, flt_sqlFilter,
  gsPeriodEdit;

type
  Tgdv_frmG = class(TgdcCreateableForm)
    TBDock1: TTBDock;
    tbMainToolbar: TTBToolbar;
    Panel1: TPanel;
    TBDock2: TTBDock;
    TBDock3: TTBDock;
    TBDock4: TTBDock;
    dsMain: TDataSource;
    alMain: TActionList;
    actHlp: TAction;
    actPrint: TAction;
    actMacros: TAction;
    actFilter: TAction;
    actProperties: TAction;
    actQExport: TAction;
    actFilterQuery: TAction;
    TBItem1: TTBItem;
    tbiMacros: TTBItem;
    tbiPrint: TTBItem;
    TBToolbar2: TTBToolbar;
    Panel4: TPanel;
    TBControlItem1: TTBControlItem;
    lblPeriod: TLabel;
    SpeedButton1: TSpeedButton;
    actRun: TAction;
    gdMacrosMenu: TgdMacrosMenu;
    gdReportMenu: TgdReportMenu;
    gsQueryFilter: TgsQueryFilter;
    TBItem4: TTBItem;
    gsPeriodEdit: TgsPeriodEdit;
    procedure FormCreate(Sender: TObject);
    procedure actPrintExecute(Sender: TObject);
    procedure actMacrosExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actRunExecute(Sender: TObject);
    procedure actFilterExecute(Sender: TObject);
    procedure actHlpExecute(Sender: TObject);

  private
    { Private declarations }
    FShiftDown: Boolean;

    function GetDateBegin: TDateTime;
    function GetDateEnd: TDateTime;
    procedure SetDateBegin(const Value: TDateTime);
    procedure SetDateEnd(const Value: TDateTime);

  protected
    procedure WMClose(var Message: TMessage);
      message WM_Close;

  public
    { Public declarations }
    constructor Create(AnOwner: TComponent); override;

    procedure LoadSettings; override;
    procedure SaveSettings; override;

    property DateBegin: TDateTime read GetDateBegin write SetDateBegin;
    property DateEnd: TDateTime read GetDateEnd write SetDateEnd;
  end;

var
  gdv_frmG: Tgdv_frmG;

implementation

{$R *.DFM}

uses
  Storages, gd_ClassList, gd_security,
  gsStorage_CompPath, gd_directories_const, gd_createable_form;

procedure Tgdv_frmG.LoadSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDV_FRMG', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDV_FRMG', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDV_FRMG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDV_FRMG',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDV_FRMG' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if Assigned(gsPeriodEdit) then
  begin
     gsPeriodEdit.AssignPeriod(
       UserStorage.ReadString(BuildComponentPath(gsPeriodEdit), 'Period', ''));
  end;
  TBRegLoadPositions(Self, HKEY_CURRENT_USER, ClientRootRegistrySubKey + 'TB\' + Name);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDV_FRMG', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDV_FRMG', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;


procedure Tgdv_frmG.FormCreate(Sender: TObject);
begin
  gdMacrosMenu.ReloadGroup;
  FShiftDown := False;
end;

procedure Tgdv_frmG.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDV_FRMG', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDV_FRMG', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDV_FRMG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDV_FRMG',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDV_FRMG' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  UserStorage.WriteString(BuildComponentPath(gsPeriodEdit), 'Period', gsPeriodEdit.Text);
  TBRegSavePositions(Self, HKEY_CURRENT_USER, ClientRootRegistrySubKey + 'TB\' + Name);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDV_FRMG', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDV_FRMG', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdv_frmG.actPrintExecute(Sender: TObject);
var
  R: TRect;
begin
  with tbMainToolbar do
  begin
    R := View.Find(tbiPrint).BoundsRect;
    R.TopLeft := ClientToScreen(R.TopLeft);
    R.BottomRight := ClientToScreen(R.BottomRight);
  end;
  gdReportMenu.Popup(R.Left, R.Bottom);
end;

procedure Tgdv_frmG.actMacrosExecute(Sender: TObject);
var
  R: TRect;
begin
  with tbMainToolbar do
  begin
    R := View.Find(tbiMacros).BoundsRect;
    R.TopLeft := ClientToScreen(R.TopLeft);
    R.BottomRight := ClientToScreen(R.BottomRight);
  end;
  gdMacrosMenu.Popup(R.Left, R.Bottom);
end;

procedure Tgdv_frmG.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if (Action = caHide) and FShiftDown then
    Action := caFree;
end;

procedure Tgdv_frmG.WMClose(var Message: TMessage);
begin
  FShiftDown := GetAsyncKeyState(VK_SHIFT) shr 1 > 0;
  inherited;
end;


constructor Tgdv_frmG.Create(AnOwner: TComponent);
begin
  inherited;
  ShowSpeedButton := True;
end;

function Tgdv_frmG.GetDateBegin: TDateTime;
begin
  Result := gsPeriodEdit.Date;
end;

function Tgdv_frmG.GetDateEnd: TDateTime;
begin
  Result := gsPeriodEdit.EndDate;
end;

procedure Tgdv_frmG.SetDateBegin(const Value: TDateTime);
begin
  gsPeriodEdit.Date := Value;
end;

procedure Tgdv_frmG.SetDateEnd(const Value: TDateTime);
begin
  gsPeriodEdit.EndDate := Value;
end;

procedure Tgdv_frmG.actRunExecute(Sender: TObject);
begin
  if DateBegin > DateEnd then
    raise Exception.Create('Дата начала должна быть меньше либо равна дате окончания!');
end;

procedure Tgdv_frmG.actFilterExecute(Sender: TObject);
begin
  gsQueryFilter.PopupMenu;
end;

procedure Tgdv_frmG.actHlpExecute(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

initialization
  RegisterFrmClass(Tgdv_frmG);

finalization
  UnRegisterFrmClass(Tgdv_frmG);
end.
