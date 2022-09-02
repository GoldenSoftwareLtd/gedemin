// ShlTanya, 20.02.2019, #4135

unit gsReportManager;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IBDatabase, DB, Menus, Contnrs, IBSQL, {xfReport,}
  Printers, rp_ReportClient, gdcBaseInterface;

type
  TMenuType = (mtSubMenu, mtSeparator);

  TOnBeforePrint = procedure(Sender: TObject; isRegistry, isQuick: Boolean) of object;

  TgsReportManager = class(TComponent)
  private
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;
    FPopupMenu: TPopupMenu;
    FMenuType: TMenuType;
    FCaption: String;
    FGroupID: TID;
    FComponentList: TComponentList;
    FOnBeforePrint: TOnBeforePrint;

    procedure SetDatabase(const Value: TIBDatabase);
    procedure SetTransaction(const Value: TIBTransaction);
    procedure SetPopupMenu(Value: TPopupMenu);

    // Вызов списка отчетов
    procedure DoOnReportListClick(Sender: TObject);
    // Печать отчета. OnClick - в PopupMenu
    procedure DoOnReportClick(Sender: TObject);
    // Печать отчета
    procedure PrintReport(const ID: TID);

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Loaded; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    // Формирование списка меню
    procedure MakeMenu;

  published
    property DataBase: TIBDataBase read FDataBase write SetDataBase;
    property Transaction: TIBTransaction read FTransaction write SetTransaction;
    property PopupMenu: TPopupMenu read FPopupMenu write SetPopupMenu;
    property MenuType: TMenuType read FMenuType write FMenuType;
    property Caption: String read FCaption write FCaption;
    property GroupID: TID read FGroupID write FGroupID;

    property OnBeforePrint: TOnBeforePrint read FOnBeforePrint write FOnBeforePrint;
  end;

procedure Register;

implementation

uses
  {rp_PrintReport_unit, }rp_frmRegistryForm_unit, msg_attachment, gd_resourcestring;

const
  def_caption = 'Печать реестра';
  def_registrylist = 'Список форм ...';

constructor TgsReportManager.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FMenuType := mtSubMenu;
  FCaption := def_caption;
  FComponentList := TComponentList.Create;
  FOnBeforePrint := nil;
end;

destructor TgsReportManager.Destroy;
begin
  FComponentList.Free;
  inherited Destroy;
end;

// Вызов списка отчетов
procedure TgsReportManager.DoOnReportListClick(Sender: TObject);
begin
  ClientReport.Execute(FGroupID);
end;

// Выбор отчета для печати
procedure TgsReportManager.DoOnReportClick(Sender: TObject);
begin
  PrintReport(GetTID((Sender as TMenuItem).Tag, cEmptyContext));
end;

// Формирование меню
procedure TgsReportManager.MakeMenu;
var
  IBSQL: TIBSQL;
  MenuItem: TMenuItem;
  SubMenu: TMenuItem;

  // Добавляем элемент в меню
  function AddItem(Group: TMenuItem; S: String): TMenuItem;
  begin
    Result := TMenuItem.Create(Self);
    Result.Caption := S;
    Group.Add(Result);
  end;

begin
  Assert(FDataBase <> nil, 'Не подключен DataBase.');
  Assert(FTransaction <> nil, 'Не подключен Transaction.');

  if FPopupMenu <> nil then
  begin
    if not FTransaction.InTransaction then
      FTransaction.StartTransaction;

    FComponentList.Clear;
    IBSQL := TIBSQL.Create(Self);
    try
      IBSQL.Database := FDataBase;
      IBSQL.Transaction := FTransaction;

      if FMenuType = mtSubMenu then
      begin
        SubMenu := AddItem(FPopupMenu.Items, FCaption);
        FComponentList.Add(SubMenu);
      end
      else
      begin
        if FPopupMenu.Items.Count <> 0 then
        begin
          MenuItem := AddItem(FPopupMenu.Items, '-');
          FComponentList.Add(MenuItem);
        end;
        SubMenu := FPopupMenu.Items;
      end;

      MenuItem := AddItem(SubMenu, def_registrylist);
      FComponentList.Add(MenuItem);
      MenuItem.OnClick := DoOnReportListClick;

      IBSQL.SQL.Text := Format(
        'SELECT id, name FROM rp_reportlist r WHERE r.reportgroupkey = %d ', [TID264(FGroupID)]);
      IBSQL.ExecQuery;

      while not IBSQL.Eof do
      begin
        MenuItem := AddItem(SubMenu, IBSQL.FieldByName('Name').AsString);
        FComponentList.Add(MenuItem);
        MenuItem.Tag := TID2Tag(GetTID(IBSQL.FieldByName('ID')), cEmptyContext);
        MenuItem.OnClick := DoOnReportClick;

        IBSQL.Next;
      end;
    finally
      IBSQL.Free;
    end;
  end;
end;

procedure TgsReportManager.PrintReport(const ID: TID);
begin
  Assert(ClientReport <> nil, 'Не подключен сервер отчетов');

  ClientReport.BuildReport(Unassigned, ID);
end;

procedure TgsReportManager.SetPopupMenu(Value: TPopupMenu);
begin
  if FPopupMenu <> Value then
  begin
    if FPopupMenu <> nil then
      FPopupMenu.RemoveFreeNotification(Self);
    FPopupMenu := Value;
    if FPopupMenu <> nil then
      FPopupMenu.FreeNotification(Self);
  end;

  if not (csDesigning in ComponentState) then
    FComponentList.Clear;
end;

procedure TgsReportManager.SetDatabase(const Value: TIBDatabase);
begin
  if FDatabase <> Value then
  begin
    if FDatabase <> nil then
      FDatabase.RemoveFreeNotification(Self);
    FDatabase := Value;
    if FDatabase <> nil then
      FDatabase.FreeNotification(Self);
  end;
end;

procedure TgsReportManager.SetTransaction(const Value: TIBTransaction);
begin
  if FTransaction <> Value then
  begin
    if FTransaction <> nil then FTransaction.RemoveFreeNotification(Self);
    FTransaction := Value;
    if FTransaction <> nil then FTransaction.FreeNotification(Self);
  end;
end;

procedure TgsReportManager.Loaded; 
begin
  inherited Loaded;

  if not (csDesigning in ComponentState) then
    MakeMenu;
end;

procedure TgsReportManager.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if Operation = opRemove then
  begin
    if AComponent = FDatabase then
      FDatabase := nil;

    if AComponent = FTransaction then
      FTransaction := nil;

    if AComponent = FPopupMenu then
      FPopupMenu := nil;
  end;
end;

procedure Register;
begin
  RegisterComponents('gsNew', [TgsReportManager]);
end;

end.
