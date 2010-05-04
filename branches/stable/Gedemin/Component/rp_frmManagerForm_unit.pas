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
    FGroupID: Integer;
    FIsQuick: Integer;

  protected
    procedure LoadSettings; override;
    procedure SaveSettings; override;
    
  public
    procedure ShowForm(AGroupID: Integer);
  end;

var
  frmManagerForm: TfrmManagerForm;

implementation

{$R *.DFM}

uses
  rp_dlgRegistryForm_unit, gsDesktopManager, dmDatabase_unit;

procedure TfrmManagerForm.ShowForm(AGroupID: Integer);
begin
  FGroupID := AGroupID;
  IBTransaction.StartTransaction;
  IBSQL.ParamByName('ID').AsInteger := FGroupID;
  IBSQL.ExecQuery;

  Assert(IBSQL.RecordCount > 0, '����� ������ �� ����������.');
  FIsQuick := IBSQL.FieldByName('ISQUICK').AsInteger;

  qryReportRegistry.ParamByName('parent').AsInteger := AGroupID;
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
    if Edit(qryReportRegistry.FieldByName('ID').AsInteger) then
      qryReportRegistry.Refresh;
  finally
    Free;
  end;
end;

procedure TfrmManagerForm.actDeleteExecute(Sender: TObject);
begin
  if MessageBox(Handle, PChar(Format('������� ������ ''%s''?', [qryReportRegistry.FieldByName('name').AsString])),
    '��������', MB_YESNO +
    MB_ICONQUESTION) = mrYes then
  begin
    qryReportRegistry.Delete;
    IBTransaction.CommitRetaining;
  end;
end;

end.
