{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    ctl_frmCattle_unit.pas

  Abstract

    Window.

  Author

    Denis Romanosvki  (01.04.2001)

  Revisions history

    1.0    01.04.2001    Denis    Initial version.


--}

unit ctl_frmCattle_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_frmG_unit, ActnList,  ComCtrls, ToolWin, StdCtrls,
  ExtCtrls, Db, IBCustomDataSet, IBDatabase, Grids, DBGrids, gsDBGrid,
  gsIBGrid, gsIBLargeTreeView, ImgList, Mask, DBCtrls,
  ctl_CattleConstants_unit, gsIBCtrlGrid,  at_sql_setup, Menus,
  IBSQL, flt_sqlFilter, gsReportManager;

type
  Tctl_frmCattle = class(Tgd_frmG)
    tvCattle: TgsIBLargeTreeView;
    Splitter1: TSplitter;
    dsCattle: TDataSource;
    ibtrCattle: TIBTransaction;
    ibdsCattle: TIBDataSet;
    ilCattle: TImageList;
    pnlGood: TPanel;
    ibdsDiscount: TIBDataSet;
    dsDiscount: TDataSource;
    ibgrdCattle: TgsIBCtrlGrid;
    dbeDiscount: TDBEdit;
    ToolButton1: TToolButton;
    actSetup: TAction;
    atSQLSetup: TatSQLSetup;
    ibsqlGood: TIBSQL;
    dbeMinWeight: TDBEdit;
    dbeMaxWeight: TDBEdit;
    ibdsGoodGroup: TIBDataSet;
    dsGoodGroup: TDataSource;
    dbeCoeff: TDBEdit;
    pmFilter: TPopupMenu;
    gsQueryFilter: TgsQueryFilter;
    gsReportManager: TgsReportManager;

    procedure FormCreate(Sender: TObject);
    procedure tvCattleChange(Sender: TObject; Node: TTreeNode);

    procedure actNewExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure ibdsDiscountAfterEdit(DataSet: TDataSet);
    procedure ibdsDiscountAfterInsert(DataSet: TDataSet);
    procedure ibdsDiscountAfterPost(DataSet: TDataSet);
    procedure actSetupExecute(Sender: TObject);
    procedure ibdsGoodGroupAfterEdit(DataSet: TDataSet);
    procedure ibdsGoodGroupAfterInsert(DataSet: TDataSet);
    procedure ibdsGoodGroupAfterPost(DataSet: TDataSet);
    procedure dbeDiscountExit(Sender: TObject);

  private
    FBranch: String;
    FLB, FRB: String;

  public
    constructor Create(AnOwner: TComponent); override;

    function Get_SelectedKey: OleVariant; override;

    procedure LoadSettings; override;
    procedure SaveSettings; override;

    class function CreateAndAssign(AnOwner: TComponent): TForm; override;

  end;

  Ectl_frmCattle = class(Exception);

var
  ctl_frmCattle: Tctl_frmCattle;

implementation

uses
  dmDataBase_unit, ctl_dlgSetupPrice_unit, ctl_ChooseCattleBranch_unit, gsStorage,
  ctl_dlgSetupCattle_unit, Storages;

{$R *.DFM}

function Tctl_frmCattle.Get_SelectedKey: OleVariant;
var
  A: Variant;
  I: Integer;
  Mark: TBookmark;
  GroupKey: Integer;

begin
  if tvCattle.Selected <> nil then
    GroupKey := StrToInt(TgsIBTreeNode(tvCattle.Selected.Data).ID)
  else
    GroupKey := 0;

  if (ibdsCattle.Active and (ibdsCattle.RecordCount > 0)) then
    if ibgrdCattle.SelectedRows.Count = 0 then
      A := VarArrayOf([ibdsCattle.FieldByName('id').AsInteger])
    else
    begin
      A := VarArrayCreate([0, ibgrdCattle.SelectedRows.Count - 1], varVariant);
      Mark := ibdsCattle.GetBookmark;
      ibdsCattle.DisableControls;

      for I := 0 to ibgrdCattle.SelectedRows.Count - 1 do
      begin
        ibdsCattle.GotoBookMark(Pointer(ibgrdCattle.SelectedRows.Items[I]));
        A[I] := ibdsCattle.FieldByName('id').AsInteger;
      end;
      ibdsCattle.GotoBookMark(Mark);
      ibdsCattle.EnableControls;
    end;

  Result := VarArrayOf([GroupKey, A])
end;

class function Tctl_frmCattle.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(ctl_frmCattle) then
    ctl_frmCattle := Tctl_frmCattle.Create(AnOwner);
  Result := ctl_frmCattle;
end;

constructor Tctl_frmCattle.Create(AnOwner: TComponent);
var
  F: TgsStorageFolder;
begin
  inherited;

  //
  //  Если настройки ветки нет - осуществляем ее

  F := GlobalStorage.OpenFolder(FOLDER_CATTLE_SETTINGS, True, False);
  try
    if not F.ValueExists(VALUE_CATTLEBRANCH) then
    begin
      MessageBox(0,
        'Необходимо настроить ветку справочника товаров!',
        'Внимание!',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);

      with Tctl_ChooseCattleBranch.Create(Self) do
      try
        if Execute then
        begin
          F := GlobalStorage.OpenFolder(FOLDER_CATTLE_SETTINGS);
          try
            tvCattle.TopBranchID := F.ReadString(VALUE_CATTLEBRANCH, tvCattle.TopBranchID);
          finally
            GlobalStorage.CloseFolder(F);
          end;

          tvCattle.Items.BeginUpdate;

          tvCattle.Clear;
          tvCattle.LoadFromDatabase;

          tvCattle.Items.EndUpdate;
        end else
          raise Ectl_frmCattle.Create('Без настройки ветви справочника товаров ' +
            'окно не может быть открыто!');
      finally
        Free;
      end;
    end;
  finally
    GlobalStorage.CloseFolder(F, False);
  end;
end;

procedure Tctl_frmCattle.FormCreate(Sender: TObject);
var
  F: TgsStorageFolder;

  OldOnExit: TNotifyEvent;
  OldOnKeyDown: TKeyEvent;
begin
  inherited;

  OldOnExit := dbeDiscount.OnExit;
  OldOnKeyDown := dbeDiscount.OnKeyDown;

  ibgrdCattle.AddControl('DISCOUNT', dbeDiscount, OldOnExit, OldOnKeyDown);

  dbeDiscount.OnExit := OldOnExit;
  dbeDiscount.OnKeyDown := OldOnKeyDown;



  OldOnExit := dbeMinWeight.OnExit;
  OldOnKeyDown := dbeMinWeight.OnKeyDown;

  ibgrdCattle.AddControl('MINWEIGHT', dbeMinWeight, OldOnExit, OldOnKeyDown);

  dbeMinWeight.OnExit := OldOnExit;
  dbeMinWeight.OnKeyDown := OldOnKeyDown;



  OldOnExit := dbeMaxWeight.OnExit;
  OldOnKeyDown := dbeMaxWeight.OnKeyDown;

  ibgrdCattle.AddControl('MAXWEIGHT', dbeMaxWeight, OldOnExit, OldOnKeyDown);

  dbeMaxWeight.OnExit := OldOnExit;
  dbeMaxWeight.OnKeyDown := OldOnKeyDown;


  F := GlobalStorage.OpenFolder(FOLDER_CATTLE_SETTINGS);
  try
    tvCattle.TopBranchID := F.ReadString(VALUE_CATTLEBRANCH, tvCattle.TopBranchID);
    FBranch := F.ReadString(VALUE_CATTLEBRANCH, tvCattle.TopBranchID);
  finally
    GlobalStorage.CloseFolder(F);
  end;

  OldOnExit := dbeCoeff.OnExit;
  OldOnKeyDown := dbeCoeff.OnKeyDown;

{  dbeCoeff.DataField :=
    F.ReadString(VALUE_GOODGROUP_COEFFICIENT, '');}
  ibgrdCattle.AddControl('COEFF', dbeCoeff, OldOnExit, OldOnKeyDown);

  dbeCoeff.OnExit := OldOnExit;
  dbeCoeff.OnKeyDown := OldOnKeyDown;



  if not ibtrCattle.Active then
    ibtrCattle.StartTransaction;

  ibsqlGood.Close;
  ibsqlGood.ParamByName('ID').AsString := FBranch;
  ibsqlGood.ExecQuery;

  FLB := ibsqlGood.FieldByName('LB').AsString;
  FRB := ibsqlGood.FieldByName('RB').AsString;

  ibsqlGood.FreeHandle;

  tvCattle.LoadFromDatabase;

  if tvCattle.Items.Count > 0 then
    tvCattle.Items[0].Expand(False);
end;

procedure Tctl_frmCattle.tvCattleChange(Sender: TObject; Node: TTreeNode);
begin
  if not tvCattle.IsLoaded then Exit;

  if not ibtrCattle.Active then
    ibtrCattle.StartTransaction;

  ibdsCattle.DisableControls;

  ibdsCattle.Close;

  if not Assigned(tvCattle.Selected.Parent) then
  begin
    ibdsCattle.ParamByName('LB').AsString := FLB;
    ibdsCattle.ParamByName('RB').AsString := FRB;
  end else

  begin
    ibdsCattle.ParamByName('LB').AsString :=
      (tvCattle.Selected as TgsIBTreeNode).LB;
    ibdsCattle.ParamByName('RB').AsString :=
      (tvCattle.Selected as TgsIBTreeNode).RB;
  end;

  ibdsCattle.Open;
  ibdsGoodGroup.Open;

  ibdsCattle.EnableControls;

  if not ibdsDiscount.Active then
    ibdsDiscount.Open;
end;

procedure Tctl_frmCattle.actNewExecute(Sender: TObject);
{var
  Group: Integer;}
begin
  inherited;

{  if not Assigned(tvCattle.Selected) then
    Group := StrToInt(FBranch)
  else
    Group := StrToInt((tvCattle.Selected as TgsIBTreeNode).ID);}

{  if dgCattle.AddGood(Group) then
  begin
    ibdsCattle.DisableControls;
    ibdsCattle.Close;
    ibdsCattle.Open;
    ibdsCattle.EnableControls;
  end;}
end;

procedure Tctl_frmCattle.actEditExecute(Sender: TObject);
begin
  inherited;
  if ibdsCattle.IsEmpty then Exit;

{  if dgCattle.EditGood(ibdsCattle.FieldByName('ID').AsInteger) then
    ibdsCattle.Refresh;}
end;

procedure Tctl_frmCattle.actDeleteExecute(Sender: TObject);
begin
  inherited;
  if ibdsCattle.IsEmpty then Exit;

{  if
    (MessageBox(Handle, 'Удалить товар?', 'Внимание!',
      MB_ICONQUESTION or MB_YESNO) = ID_YES) and
    dgCattle.DeleteGood(ibdsCattle.FieldByName('ID').AsInteger) then
  begin
    ibdsCattle.DisableControls;
    ibdsCattle.Close;
    ibdsCattle.Open;
    ibdsCattle.EnableControls;
  end;}
end;

procedure Tctl_frmCattle.ibdsDiscountAfterEdit(DataSet: TDataSet);
begin
  if ibdsCattle.IsEmpty then
    ibdsDiscount.Cancel
  else
    ibdsDiscount.FieldByName('GOODKEY').AsInteger :=
      ibdsCattle.FieldByName('ID').AsInteger;
end;

procedure Tctl_frmCattle.ibdsDiscountAfterInsert(DataSet: TDataSet);
begin
  if ibdsCattle.IsEmpty then
    ibdsDiscount.Cancel
  else
    ibdsDiscount.FieldByName('GOODKEY').AsInteger :=
      ibdsCattle.FieldByName('ID').AsInteger;
end;

procedure Tctl_frmCattle.ibdsDiscountAfterPost(DataSet: TDataSet);
begin
  ibtrCattle.CommitRetaining;
end;

procedure Tctl_frmCattle.actSetupExecute(Sender: TObject);
var
  F: TgsStorageFolder;
begin
  with Tctl_dlgSetupCattle.Create(Self) do
  try
    Execute(Now);

    F := GlobalStorage.OpenFolder(FOLDER_CATTLE_SETTINGS);
    try
      tvCattle.TopBranchID := F.ReadString(VALUE_CATTLEBRANCH, tvCattle.TopBranchID);
      FBranch := F.ReadString(VALUE_CATTLEBRANCH, tvCattle.TopBranchID);
    finally
      GlobalStorage.CloseFolder(F);
    end;

    ibsqlGood.Close;
    ibsqlGood.ParamByName('ID').AsString := FBranch;
    ibsqlGood.ExecQuery;

    FLB := ibsqlGood.FieldByName('LB').AsString;
    FRB := ibsqlGood.FieldByName('RB').AsString;

    ibsqlGood.FreeHandle;


    GlobalStorage.CloseFolder(F);

    tvCattle.Items.BeginUpdate;

    tvCattle.Clear;
    tvCattle.LoadFromDatabase;

    tvCattle.Items.EndUpdate;

    if tvCattle.Items.Count > 0 then
      tvCattle.Items[0].Expand(False);

  finally
    Free;
  end;
end;

procedure Tctl_frmCattle.ibdsGoodGroupAfterEdit(DataSet: TDataSet);
begin
  if ibdsGoodGroup.IsEmpty then
    ibdsGoodGroup.Cancel;
end;

procedure Tctl_frmCattle.ibdsGoodGroupAfterInsert(DataSet: TDataSet);
begin
  ibdsGoodGroup.Cancel;
end;

procedure Tctl_frmCattle.ibdsGoodGroupAfterPost(DataSet: TDataSet);
begin
  ibtrCattle.CommitRetaining;
end;

procedure Tctl_frmCattle.dbeDiscountExit(Sender: TObject);
begin
  ibdsCattle.Edit;
  ibdsCattle.FieldByName('COEFF').AsString := dbeCoeff.Text;
  ibdsCattle.FieldByName('DISCOUNT').AsString := dbeDiscount.Text;
  ibdsCattle.FieldByName('MINWEIGHT').AsString := dbeMinWeight.Text;
  ibdsCattle.FieldByName('MAXWEIGHT').AsString := dbeMaxWeight.Text;
  ibdsCattle.Post;
end;

procedure Tctl_frmCattle.LoadSettings;
begin
  inherited;
  UserStorage.LoadComponent(ibgrdCattle, ibgrdCattle.LoadFromStream);
end;

procedure Tctl_frmCattle.SaveSettings;
begin
  inherited;
  UserStorage.SaveComponent(ibgrdCattle, ibgrdCattle.SaveToStream);
end;

initialization

  ctl_frmCattle := nil;
  RegisterClass(Tctl_frmCattle);


end.

