
unit gdc_bug_frmBugBase_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, Db, Menus, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid,
  ToolWin, ComCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  IBCustomDataSet, gdcBase, gdcBugBase, gd_MacrosMenu, StdCtrls, DBCtrls;

type
  Tgdc_bug_frmBugBase = class(Tgdc_frmSGR)
    gdcBugBase: TgdcBugBase;
    actUpdateBugRecord: TAction;
    tbiUpdateBugRecord: TTBItem;
    DBComboBox1: TDBComboBox;
    TBControlItem1: TTBControlItem;

    procedure FormCreate(Sender: TObject);
    procedure actUpdateBugRecordExecute(Sender: TObject);
  private

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_bug_frmBugBase: Tgdc_bug_frmBugBase;

implementation

{$R *.DFM}

uses
  gd_security,  gd_ClassList
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{ Tgdc_bug_frmBugBase }

class function Tgdc_bug_frmBugBase.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_bug_frmBugBase) then
    gdc_bug_frmBugBase := Tgdc_bug_frmBugBase.Create(AnOwner);
  Result := gdc_bug_frmBugBase;
end;

procedure Tgdc_bug_frmBugBase.FormCreate(Sender: TObject);
begin
  gdcObject := gdcBugBase;
  inherited;
end;

procedure Tgdc_bug_frmBugBase.actUpdateBugRecordExecute(Sender: TObject);
begin
  Assert(IBLogin <> nil);
  if IBLogin.IsUserAdmin then
    gdcObject.EditMultiple2(Get_SelectedKey, 'Tgdc_bug_dlgUpdate')
  else
    MessageBox(Handle,
      'Только пользователь с правами Администратора может изменить статус записи.',
      'Нет прав доступа',
      MB_OK or MB_ICONHAND);
end;

initialization
  RegisterFrmClass(Tgdc_bug_frmBugBase);

finalization
  UnRegisterFrmClass(Tgdc_bug_frmBugBase);
end.
