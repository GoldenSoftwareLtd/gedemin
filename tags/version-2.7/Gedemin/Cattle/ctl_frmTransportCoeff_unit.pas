{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    ctl_frmTransportCoeff_unit.pas

  Abstract

    Window.

  Author

    Denis Romanosvki  (01.04.2001)

  Revisions history

    1.0    01.04.2001    Denis    Initial version.


--}

unit ctl_frmTransportCoeff_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_frmSIBF_unit, Menus, flt_sqlFilter, Db, IBCustomDataSet, IBDatabase,
  ActnList,   ComCtrls, ToolWin, StdCtrls,
  ExtCtrls, Grids, DBGrids, gsDBGrid, gsIBGrid, gsReportManager;

type
  Tctl_frmTransportCoeff = class(Tgd_frmSIBF)
    ToolButton1: TToolButton;
    actSetup: TAction;
    procedure actNewExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure ibdsMainAfterPost(DataSet: TDataSet);
    procedure actNewUpdate(Sender: TObject);
    procedure actEditUpdate(Sender: TObject);
    procedure actDeleteUpdate(Sender: TObject);
    procedure actSetupExecute(Sender: TObject);
  private

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;

  end;

var
  ctl_frmTransportCoeff: Tctl_frmTransportCoeff;

implementation

{$R *.DFM}

uses ctl_dlgSetupCattle_unit;

{ Tctl_frmTransportCoeff }

class function Tctl_frmTransportCoeff.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(ctl_frmTransportCoeff) then
    ctl_frmTransportCoeff := Tctl_frmTransportCoeff.Create(AnOwner);
  Result := ctl_frmTransportCoeff;
end;

procedure Tctl_frmTransportCoeff.actNewExecute(Sender: TObject);
begin
  ibdsMain.Insert;
end;

procedure Tctl_frmTransportCoeff.actEditExecute(Sender: TObject);
begin
  ibdsMain.Edit;
end;

procedure Tctl_frmTransportCoeff.actDeleteExecute(Sender: TObject);
begin
  if MessageBox(Handle, 'Удалить запись?', 'Внимание!',
    MB_ICONQUESTION or MB_YESNO) = ID_YES
  then begin
    ibdsMain.Delete;
    IBTransaction.CommitRetaining;
  end;
end;

procedure Tctl_frmTransportCoeff.ibdsMainAfterPost(DataSet: TDataSet);
begin
  IBTransaction.CommitRetaining;
end;

procedure Tctl_frmTransportCoeff.actNewUpdate(Sender: TObject);
begin
  actNew.Enabled := not (ibdsMain.State in dsEditModes);
end;

procedure Tctl_frmTransportCoeff.actEditUpdate(Sender: TObject);
begin
  actEdit.Enabled := not (ibdsMain.State in dsEditModes);
end;

procedure Tctl_frmTransportCoeff.actDeleteUpdate(Sender: TObject);
begin
  actDelete.Enabled := not (ibdsMain.State in dsEditModes);
end;

procedure Tctl_frmTransportCoeff.actSetupExecute(Sender: TObject);
begin
  with Tctl_dlgSetupCattle.Create(Self) do
  try
    Execute(Now);
  finally
    Free;
  end;
end;

initialization

  ctl_frmTransportCoeff := nil;
  RegisterClass(Tctl_frmTransportCoeff);

end.
