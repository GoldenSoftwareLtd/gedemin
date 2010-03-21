unit rp_frmRegistryForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, Db, IBCustomDataSet, IBQuery, at_sql_setup, 
  IBDatabase, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid, ExtCtrls,
  ComCtrls, ToolWin, gd_security, IBUpdateSQL, IBSQL, gd_createable_form;

type
  TfrmRegistryForm = class(TCreateableForm)
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

  public
    procedure ShowForm(AGroupID: Integer);

    procedure LoadSettings; override;
    procedure SaveSettings; override;
  end;

var
  frmRegistryForm: TfrmRegistryForm;

implementation

{$R *.DFM}

uses
  rp_dlgRegistryForm_unit, gsDesktopManager, 
  Storages
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

procedure TfrmRegistryForm.ShowForm(AGroupID: Integer);
begin
  FGroupID := AGroupID;
  IBTransaction.StartTransaction;
  IBSQL.ParamByName('ID').AsInteger := FGroupID;
  IBSQL.ExecQuery;

  Assert(IBSQL.RecordCount > 0, 'Такой группы не существует.');
  FIsQuick := IBSQL.FieldByName('ISQUICK').AsInteger;

  qryReportRegistry.ParamByName('parent').AsInteger := AGroupID;
  qryReportRegistry.Open;
  ShowModal;
end;

procedure TfrmRegistryForm.LoadSettings;
begin
  inherited;
  if Assigned(UserStorage) then
    UserStorage.LoadComponent(dbgReportRegistry,
        dbgReportRegistry.LoadFromStream);
end;

procedure TfrmRegistryForm.SaveSettings;
begin
  inherited;
  if Assigned(UserStorage) then
    UserStorage.SaveComponent(dbgReportRegistry,
        dbgReportRegistry.SaveToStream);
end;

procedure TfrmRegistryForm.actAddExecute(Sender: TObject);
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

procedure TfrmRegistryForm.actEditExecute(Sender: TObject);
begin
  with TdlgRegistryForm.Create(Self) do
  try
    if Edit(qryReportRegistry.FieldByName('ID').AsInteger) then
      qryReportRegistry.Refresh;
  finally
    Free;
  end;
end;

procedure TfrmRegistryForm.actDeleteExecute(Sender: TObject);
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
