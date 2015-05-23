{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    ctl_frmClient_unit.pas

  Abstract

    Window.

  Author

    Denis Romanosvki  (01.04.2001)

  Revisions history

    1.0    01.04.2001    Denis    Initial version.


--}

unit ctl_frmClient_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_frmG_unit, Grids, DBGrids, gsDBGrid, gsIBGrid, gsIBCtrlGrid, ExtCtrls,
  ComCtrls, gsIBLargeTreeView, ActnList,  ToolWin, StdCtrls,
  Db, IBCustomDataSet, Mask, DBCtrls, IBDatabase,  at_sql_setup,
  Menus, flt_sqlFilter, gsReportManager;

type
  Tctl_frmClient = class(Tgd_frmG)
    tvClient: TgsIBLargeTreeView;
    Splitter1: TSplitter;
    ibgrdClient: TgsIBCtrlGrid;
    ibdsClient: TIBDataSet;
    dsClient: TDataSource;
    ibdsClientData: TIBDataSet;
    dsClientData: TDataSource;
    ibtrClient: TIBTransaction;
    atSQLSetup: TatSQLSetup;
    ToolButton1: TToolButton;
    actSetup: TAction;
    pmFilter: TPopupMenu;
    gsQueryFilter: TgsQueryFilter;
    gsReportManager: TgsReportManager;

    procedure FormCreate(Sender: TObject);

    procedure tvClientChange(Sender: TObject; Node: TTreeNode);
    procedure ibdsClientDataAfterInsert(DataSet: TDataSet);
    procedure ibdsClientDataAfterEdit(DataSet: TDataSet);
    procedure ibdsClientDataAfterPost(DataSet: TDataSet);
    procedure actSetupExecute(Sender: TObject);

  private
    procedure DoOnExitControl(Sender: TObject);

  public
    function Get_SelectedKey: OleVariant; override;

    procedure LoadSettings; override;
    procedure SaveSettings; override;

    class function CreateAndAssign(AnOwner: TComponent): TForm; override;

  end;

var
  ctl_frmClient: Tctl_frmClient;

implementation

uses
  dmDataBase_unit, at_classes, ctl_dlgSetupCattle_unit,
  Storages;

{$R *.DFM}

function Tctl_frmClient.Get_SelectedKey: OleVariant;
var
  A: Variant;
  I: Integer;
  Mark: TBookmark;
  GroupKey: Integer;

begin
  if tvClient.Selected <> nil then
    GroupKey := StrToInt(TgsIBTreeNode(tvClient.Selected.Data).ID)
  else
    GroupKey := 0;

  if (ibdsClient.Active and (ibdsClient.RecordCount > 0)) then
    if ibgrdClient.SelectedRows.Count = 0 then
      A := VarArrayOf([ibdsClient.FieldByName('id').AsInteger])
    else
    begin
      A := VarArrayCreate([0, ibgrdClient.SelectedRows.Count - 1], varVariant);
      Mark := ibdsClient.GetBookmark;
      ibdsClient.DisableControls;

      for I := 0 to ibgrdClient.SelectedRows.Count - 1 do
      begin
        ibdsClient.GotoBookMark(Pointer(ibgrdClient.SelectedRows.Items[I]));
        A[I] := ibdsClient.FieldByName('id').AsInteger;
      end;
      ibdsClient.GotoBookMark(Mark);
      ibdsClient.EnableControls;
    end;

  Result := VarArrayOf([GroupKey, A])
end;

class function Tctl_frmClient.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(ctl_frmClient) then
    ctl_frmClient := Tctl_frmClient.Create(AnOwner);
  Result := ctl_frmClient;
end;

procedure Tctl_frmClient.FormCreate(Sender: TObject);
var
  OldOnExit: TNotifyEvent;
  OldOnKeyDown: TKeyEvent;

  Relation: TatRelation;
  I: Integer;
  Edit: TDBEdit;
begin
  inherited;

  Relation := atDatabase.Relations.ByRelationName('GD_CONTACTPROPS');
  if not Assigned(Relation) then Exit;

  for I := 0 to Relation.RelationFields.Count - 1 do
  begin
    if not Relation.RelationFields[I].IsUserDefined then Continue;

    Edit := TDBEdit.Create(Self);

    Edit.DataSource := dsClientData;
    Edit.DataField := Relation.RelationFields[I].FieldName;
    Edit.Visible := False;
    Edit.OnExit := DoOnExitControl;

    pnlMain.InsertControl(Edit);

    OldOnExit := Edit.OnExit;
    OldOnKeyDown := Edit.OnKeyDown;

    ibgrdClient.AddControl(Relation.RelationFields[I].FieldName, Edit,
      OldOnExit, OldOnKeyDown);

    Edit.OnExit := OldOnExit;
    Edit.OnKeyDown := OldOnKeyDown;
  end;
end;

procedure Tctl_frmClient.tvClientChange(Sender: TObject; Node: TTreeNode);
begin
  if not Assigned(tvClient.Selected) then Exit;

  if not ibtrClient.Active then
    ibtrClient.StartTransaction;

  ibdsClient.DisableControls;

  ibdsClient.Close;
  ibdsClient.ParamByName('LB').AsString :=
    (tvClient.Selected as TgsIBTreeNode).LB;
  ibdsClient.ParamByName('RB').AsString :=
    (tvClient.Selected as TgsIBTreeNode).RB;
  ibdsClient.Open;

  ibdsClient.EnableControls;

  if not ibdsClientData.Active then
    ibdsClientData.Open;
end;

procedure Tctl_frmClient.ibdsClientDataAfterInsert(DataSet: TDataSet);
begin
  if ibdsClient.IsEmpty then
    ibdsClientData.Cancel
  else
    ibdsClientData.FieldByName('CONTACTKEY').AsInteger :=
      ibdsClient.FieldByName('ID').AsInteger;
end;

procedure Tctl_frmClient.ibdsClientDataAfterEdit(DataSet: TDataSet);
begin
  if ibdsClient.IsEmpty then
    ibdsClientData.Cancel
  else
    ibdsClientData.FieldByName('CONTACTKEY').AsInteger :=
      ibdsClient.FieldByName('ID').AsInteger;
end;

procedure Tctl_frmClient.ibdsClientDataAfterPost(DataSet: TDataSet);
begin
  ibtrClient.CommitRetaining;
  ibdsClient.Refresh;
end;

procedure Tctl_frmClient.actSetupExecute(Sender: TObject);
begin
  with Tctl_dlgSetupCattle.Create(Self) do
  try
    Execute(Now);
  finally
    Free;
  end;
end;

procedure Tctl_frmClient.DoOnExitControl(Sender: TObject);
var
  F: TField;
begin
  F := ibdsClient.FindField((Sender as TDBEdit).DataField);

  if Assigned(F) then
  begin
    ibdsClient.Edit;
    F.AsString := (Sender as TDBEdit).Text;
    ibdsClient.Post;
  end;
end;

procedure Tctl_frmClient.LoadSettings;
begin
  inherited;
  UserStorage.LoadComponent(ibgrdClient, ibgrdClient.LoadFromStream);
end;

procedure Tctl_frmClient.SaveSettings;
begin
  inherited;
  UserStorage.SaveComponent(ibgrdClient, ibgrdClient.SaveToStream);
end;

initialization

  ctl_frmClient := nil;
  RegisterClass(Tctl_frmClient);

end.

