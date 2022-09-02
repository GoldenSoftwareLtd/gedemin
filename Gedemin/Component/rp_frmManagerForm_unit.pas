// ShlTanya, 20.02.2019

unit rp_frmManagerForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, Db, IBCustomDataSet, IBQuery, at_sql_setup, 
  IBDatabase, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid, ExtCtrls,
  ComCtrls, ToolWin, gd_security, IBUpdateSQL, IBSQL;

type
  TfrmManagerForm = class(TForm)
    pnlDemandPayment: TPanel;
    pnlDocument: TPanel;
    dbgReportRegistry: TgsIBGrid;
    alReportRegistry: TActionList;
    dsReportRegistry: TDataSource;
    IBTransaction: TIBTransaction;
    qryReportRegistry: TIBQuery;
    pmReportRegistry: TPopupMenu;
    ControlBar1: TControlBar;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    tbDelete: TToolButton;
    ToolBar2: TToolBar;
    actAdd: TAction;
    actEdit: TAction;
    actDelete: TAction;
    ibuReportRegistry: TIBUpdateSQL;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    actCopy: TAction;
    IBSQL: TIBSQL;
    procedure actAddExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
  private
    FGroupID: TID;
    FIsQuick: Integer;

  protected
    procedure LoadSettings; override;
    procedure SaveSettings; override;
    
  public
    procedure ShowForm(AGroupID: TID);
  end;

var
  frmManagerForm: TfrmManagerForm;

implementation

{$R *.DFM}

uses
  rp_dlgRegistryForm_unit, gsDesktopManager, dmDatabase_unit;

procedure TfrmManagerForm.ShowForm(AGroupID: TID);
begin
  FGroupID := AGroupID;
  IBTransaction.StartTransaction;
  SetTID(IBSQL.ParamByName('ID'), FGroupID);
  IBSQL.ExecQuery;

  Assert(IBSQL.RecordCount > 0, 'Такой группы не существует.');
  FIsQuick := IBSQL.FieldByName('ISQUICK').AsInteger;

  SetTID(qryReportRegistry.ParamByName('parent'), AGroupID);
  qryReportRegistry.Open;
  ShowModal;
end;

procedure TfrmManagerForm.LoadSettings;
  Sender: TObject);
begin
  inherited;
  if Assigned(UserStorage) then
    UserStorage.LoadComponent(dbgReportRegistry,
        dbgReportRegistry.LoadFromStream);
end;

procedure TfrmManagerForm.SaveSettings;
begin
  inherited;
  if Assigned(UserStorage) then
    UserStorage.SaveComponent(dbgReportRegistry,
        dbgReportRegistry.SaveToStream);
end;

procedure TfrmManagerForm.actAddExecute(Sender: TObject);
begin
  with TdlgRegistryForm.Create(Self) do
  try
    if Add(FGroupID, FIsQuick) <> -1 then
    begin
      qryReportRegistry.Close;
      qryReportRegistry.Open;
    end;
  finally
    Free;
  end;
end;

procedure TfrmManagerForm.actEditExecute(Sender: TObject);
begin
  with TdlgRegistryForm.Create(Self) do
  try
    if Edit(GetTID(qryReportRegistry.FieldByName('ID'))) then
      qryReportRegistry.Refresh;
  finally
    Free;
  end;
end;

procedure TfrmManagerForm.actDeleteExecute(Sender: TObject);
begin
  if MessageBox(Handle, PChar(Format('Удалить шаблон ''%s''?', [qryReportRegistry.FieldByName('name').AsString])),
    'Внимание', MB_YESNO +
    MB_ICONQUESTION) = mrYes then
  begin
    qryReportRegistry.Delete;
    IBTransaction.CommitRetaining;
  end;
end;

end.
