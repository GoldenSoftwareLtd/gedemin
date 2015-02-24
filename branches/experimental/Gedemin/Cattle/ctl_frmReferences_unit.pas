{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    ctl_frmReferences_unit.pas

  Abstract

    Window.

  Author

    Denis Romanosvki  (01.04.2001)

  Revisions history

    1.0    01.04.2001    Denis    Initial version.


--}

unit ctl_frmReferences_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_frmG_unit, ActnList,  ComCtrls, ToolWin, StdCtrls,
  ExtCtrls, gsIBLargeTreeView, Menus, Grids, DBGrids, gsDBGrid, gsIBGrid,
  IBDatabase, IBSQL, Db, IBCustomDataSet, ctl_CattleConstants_unit,
  flt_sqlFilter;

type
  Tctl_frmReferences = class(Tgd_frmG)
    ibtrReference: TIBTransaction;
    ibsqlDelete: TIBSQL;
    ibdsDelivery: TIBDataSet;
    dsDelivery: TDataSource;
    pcReferences: TPageControl;
    tsDeliveryKind: TTabSheet;
    tsDestinationKind: TTabSheet;
    ibgrdDeliveryKind: TgsIBGrid;
    ibgrdDestinationKind: TgsIBGrid;
    dsDestination: TDataSource;
    ibdsDestination: TIBDataSet;
    pmFilterDeliveri: TPopupMenu;
    gsQueryFilterDeliveri: TgsQueryFilter;
    pmFileterDestination: TPopupMenu;
    gsQueryFilterDestination: TgsQueryFilter;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure actNewExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);

    procedure actNewUpdate(Sender: TObject);
    procedure actEditUpdate(Sender: TObject);
    procedure actDeleteUpdate(Sender: TObject);
    procedure ibdsDeliveryAfterPost(DataSet: TDataSet);
    procedure ibdsDestinationAfterPost(DataSet: TDataSet);
    procedure ibdsDeliveryPostError(DataSet: TDataSet; E: EDatabaseError;
      var Action: TDataAction);
    procedure ibdsDestinationPostError(DataSet: TDataSet;
      E: EDatabaseError; var Action: TDataAction);
    procedure ibdsDeliveryAfterOpen(DataSet: TDataSet);
    procedure ibdsDestinationAfterOpen(DataSet: TDataSet);
    procedure ibdsDeliveryBeforePost(DataSet: TDataSet);
    procedure ibdsDestinationBeforePost(DataSet: TDataSet);
    procedure pcReferencesChange(Sender: TObject);
    procedure actFilterExecute(Sender: TObject);

  private
    procedure CheckForMainBranches;

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;

  end;

var
  ctl_frmReferences: Tctl_frmReferences;

implementation

uses
  dmDatabase_unit, Storages, gdcBaseInterface;

{$R *.DFM}

{
  Осуществляем проверку наличия главных веток.
  Эти ветки зарезервированы системой.
}

procedure Tctl_frmReferences.CheckForMainBranches;
var
  ibsql: TIBSQL;
  DeliveryExists, DestinationExists, DiscountExists: Boolean;
begin
  if not ibtrReference.Active then
    ibtrReference.StartTransaction;

  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := ibtrReference;

    //
    //  Осуществляем проверку наличия ветвей

    ibsql.SQL.Text := 'SELECT 1 FROM RDB$DATABASE RD WHERE EXISTS' +
      '(SELECT CTLR.ID FROM CTL_REFERENCE CTLR WHERE CTLR.ID = :ID)';

    ibsql.Prepare;

    ibsql.ParamByName('ID').AsInteger := DELIVERY_BRANCH;
    ibsql.ExecQuery;
    DeliveryExists := ibsql.RecordCount > 0;

    ibsql.Close;
    ibsql.ParamByName('ID').AsInteger := DESTINATION_BRANCH;
    ibsql.ExecQuery;
    DestinationExists := ibsql.RecordCount > 0;

    ibsql.Close;
    ibsql.ParamByName('ID').AsInteger := DISCOUNT_BRANCH;
    ibsql.ExecQuery;
    DiscountExists := ibsql.RecordCount > 0;

    //
    //  Осуществляем создание ветвей, которые отсутствуют

    if not DeliveryExists or not DestinationExists or not DiscountExists then
    begin
      ibsql.Close;
      ibsql.SQL.Text := 'INSERT INTO CTL_REFERENCE (ID, PARENT, NAME, ALIAS) VALUES' +
        '(:ID, NULL, :NAME, :ALIAS)';
      ibsql.Prepare;

      if not DeliveryExists then
      begin
        ibsql.ParamByName('ID').AsInteger := DELIVERY_BRANCH;
        ibsql.ParamByName('NAME').AsString := 'Вид приемки';
        ibsql.ParamByName('ALIAS').AsString := 'Приемка';
        ibsql.ExecQuery;
      end;

      if not DestinationExists then
      begin
        ibsql.Close;
        ibsql.ParamByName('ID').AsInteger := DESTINATION_BRANCH;
        ibsql.ParamByName('NAME').AsString := 'Вид доставки';
        ibsql.ParamByName('ALIAS').AsString := 'Доставка';
        ibsql.ExecQuery;
      end;

      if not DiscountExists then
      begin
        ibsql.Close;
        ibsql.ParamByName('ID').AsInteger := DISCOUNT_BRANCH;
        ibsql.ParamByName('NAME').AsString := 'Справочник скидок/наценок';
        ibsql.ParamByName('ALIAS').AsString := 'Скидки';
        ibsql.ExecQuery;
      end;
    end;
  finally
    ibsql.Free;
  end;
end;

class function Tctl_frmReferences.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(ctl_frmReferences) then
    ctl_frmReferences := Tctl_frmReferences.Create(AnOwner);
  Result := ctl_frmReferences;
end;

procedure Tctl_frmReferences.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  inherited;

  UserStorage.LoadComponent(ibgrdDeliveryKind, ibgrdDeliveryKind.LoadFromStream);
  UserStorage.LoadComponent(ibgrdDestinationKind, ibgrdDestinationKind.LoadFromStream);

  //
  //  вид приемки
  //  вид назначения
  //  скидки

  CheckForMainBranches;

  if not ibtrReference.Active then
    ibtrReference.StartTransaction;

  ibdsDelivery.Close;
  ibdsDelivery.ParamByName('ID').AsInteger := DELIVERY_BRANCH;
  ibdsDelivery.Open;

  for I := 0 to ibdsDelivery.FieldCount - 1 do
    ibdsDelivery.Fields[I].Required := False;

  ibdsDestination.Close;
  ibdsDestination.ParamByName('ID').AsInteger := DESTINATION_BRANCH;
  ibdsDestination.Open;

  for I := 0 to ibdsDestination.FieldCount - 1 do
    ibdsDestination.Fields[I].Required := False;
end;

procedure Tctl_frmReferences.FormDestroy(Sender: TObject);
begin
  UserStorage.SaveComponent(ibgrdDeliveryKind, ibgrdDeliveryKind.SaveToStream);
  UserStorage.SaveComponent(ibgrdDestinationKind, ibgrdDestinationKind.SaveToStream);

  inherited;
end;

procedure Tctl_frmReferences.actNewExecute(Sender: TObject);
begin
  if pcReferences.ActivePage = tsDeliveryKind then
  begin
    if ibdsDelivery.IsEmpty then Exit;
    ibdsDelivery.Insert;
    ibgrdDeliveryKind.EditorMode := True;
  end else

  if pcReferences.ActivePage = tsDestinationKind then
  begin
    if ibdsDestination.IsEmpty then Exit;
    ibdsDestination.Insert;
    ibgrdDestinationKind.EditorMode := True;
  end;
end;

procedure Tctl_frmReferences.actEditExecute(Sender: TObject);
begin
  if pcReferences.ActivePage = tsDeliveryKind then
  begin
    if ibdsDelivery.IsEmpty then Exit;
    ibdsDelivery.Edit;
    ibgrdDeliveryKind.EditorMode := True;
  end else

  if pcReferences.ActivePage = tsDestinationKind then
  begin
    if ibdsDestination.IsEmpty then Exit;
    ibdsDestination.Edit;
    ibgrdDestinationKind.EditorMode := True;
  end;
end;

procedure Tctl_frmReferences.actDeleteExecute(Sender: TObject);
begin
  if pcReferences.ActivePage = tsDeliveryKind then
  begin
    if ibdsDelivery.IsEmpty then Exit;

    if MessageBox(Handle, 'Удалить вид поставки?', 'Внимание!',
      MB_YESNO or MB_ICONQUESTION) = ID_YES then
    begin
      ibdsDelivery.Delete;
      ibtrReference.CommitRetaining;
    end;
  end else

  if pcReferences.ActivePage = tsDestinationKind then
  begin
    if ibdsDestination.IsEmpty then Exit;

    if MessageBox(Handle, 'Удалить назначения?', 'Внимание!',
      MB_YESNO or MB_ICONQUESTION) = ID_YES then
    begin
      ibdsDestination.Delete;
      ibtrReference.CommitRetaining;
    end;
  end;
end;

procedure Tctl_frmReferences.actNewUpdate(Sender: TObject);
begin
  actNew.Enabled :=
    (pcReferences.ActivePage = tsDeliveryKind)
      and
    not (ibdsDelivery.State in dsEditModes)
      or
    (pcReferences.ActivePage = tsDestinationKind)
      and
    not (ibdsDestination.State in dsEditModes)
end;

procedure Tctl_frmReferences.actEditUpdate(Sender: TObject);
begin
  actEdit.Enabled :=
    (pcReferences.ActivePage = tsDeliveryKind)
      and
    not ibdsDelivery.IsEmpty
      and
    not (ibdsDelivery.State in dsEditModes)
      or
    (pcReferences.ActivePage = tsDestinationKind)
      and
    not ibdsDestination.IsEmpty
      and
    not (ibdsDestination.State in dsEditModes);
end;

procedure Tctl_frmReferences.actDeleteUpdate(Sender: TObject);
begin
  actDelete.Enabled :=
    (pcReferences.ActivePage = tsDeliveryKind)
      and
    not ibdsDelivery.IsEmpty
      and
    not (ibdsDelivery.State in dsEditModes)
      or
    (pcReferences.ActivePage = tsDestinationKind)
      and
    not ibdsDestination.IsEmpty
      and
    not (ibdsDestination.State in dsEditModes);
end;

procedure Tctl_frmReferences.ibdsDeliveryAfterPost(DataSet: TDataSet);
begin
  ibtrReference.CommitRetaining;
end;

procedure Tctl_frmReferences.ibdsDestinationAfterPost(DataSet: TDataSet);
begin
  ibtrReference.CommitRetaining;
end;

procedure Tctl_frmReferences.ibdsDeliveryPostError(DataSet: TDataSet;
  E: EDatabaseError; var Action: TDataAction);
begin
  MessageBox(
    Handle,
    'Указаны не все поля! Запись не может быть сохранена.',
    'Внимание', MB_OK or MB_ICONERROR
  );

  Action := daAbort;
end;

procedure Tctl_frmReferences.ibdsDestinationPostError(DataSet: TDataSet;
  E: EDatabaseError; var Action: TDataAction);
begin
  MessageBox(
    Handle,
    'Указаны не все поля! Запись не может быть сохранена.',
    'Внимание', MB_OK or MB_ICONERROR
  );
  
  Action := daAbort;
end;

procedure Tctl_frmReferences.ibdsDeliveryAfterOpen(DataSet: TDataSet);
var
  I: Integer;
begin
  for I := 0 to ibdsDelivery.FieldCount - 1 do
    ibdsDelivery.Fields[I].Required := False;
end;

procedure Tctl_frmReferences.ibdsDestinationAfterOpen(DataSet: TDataSet);
var
  I: Integer;
begin
  for I := 0 to ibdsDestination.FieldCount - 1 do
    ibdsDestination.Fields[I].Required := False;
end;

procedure Tctl_frmReferences.ibdsDeliveryBeforePost(DataSet: TDataSet);
begin
  DataSet.FieldByName('PARENT').AsInteger := DELIVERY_BRANCH;
  DataSet.FieldByName('ID').AsInteger := gdcBaseManager.GetNextID;

  DataSet.FieldByName('AFULL').AsInteger := -1;
  DataSet.FieldByName('ACHAG').AsInteger := -1;
  DataSet.FieldByName('AVIEW').AsInteger := -1;
end;

procedure Tctl_frmReferences.ibdsDestinationBeforePost(DataSet: TDataSet);
begin
  DataSet.FieldByName('PARENT').AsInteger := DESTINATION_BRANCH;
  DataSet.FieldByName('ID').AsInteger := gdcBaseManager.GetNextID;

  DataSet.FieldByName('AFULL').AsInteger := -1;
  DataSet.FieldByName('ACHAG').AsInteger := -1;
  DataSet.FieldByName('AVIEW').AsInteger := -1;
end;


procedure Tctl_frmReferences.pcReferencesChange(Sender: TObject);
begin
  if pcReferences.ActivePage = tsDeliveryKind then
    tbtFilter.DropdownMenu := pmFilterDeliveri
  else
    tbtFilter.DropdownMenu := pmFileterDestination;
end;

procedure Tctl_frmReferences.actFilterExecute(Sender: TObject);
begin
  if pcReferences.ActivePage = tsDeliveryKind then
    gsQueryFilterDeliveri.PopupMenu
  else
    gsQueryFilterDestination.PopupMenu;
end;

initialization

  ctl_frmReferences := nil;
  RegisterClass(Tctl_frmReferences);

end.
