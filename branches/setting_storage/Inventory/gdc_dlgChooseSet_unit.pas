unit gdc_dlgChooseSet_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  TB2Item, TB2Dock, TB2Toolbar, Grids, DBGrids, gsDBGrid, gsIBGrid,
  StdCtrls, ExtCtrls, Db, ActnList, gdcBaseInterface, IBCustomDataSet,
  ComCtrls, gsDBTreeView, at_Classes, DBClient, ibsql, gd_security;

type

  TChooseViewType = (cvtAuto, cvtTree, cvtGrid);

  Tdlg_ChooseSet = class(TForm)
    alMain: TActionList;
    actFind: TAction;
    actFilter: TAction;
    actSearchMain: TAction;
    actSearchMainClose: TAction;
    actOnlySelected: TAction;
    actAddToSelected: TAction;
    actRemoveFromSelected: TAction;
    actChooseOk: TAction;
    actDeleteChoose: TAction;
    actSelectAll: TAction;
    actUnSelectAll: TAction;
    actUnChooseAll: TAction;
    dsMain: TDataSource;
    dsChoose: TDataSource;
    pnlWorkArea: TPanel;
    spChoose: TSplitter;
    pnlMain: TPanel;
    pnChoose: TPanel;
    pnButtonChoose: TPanel;
    btnCancelChoose: TButton;
    btnOkChoose: TButton;
    btnDeleteChoose: TButton;
    pnlChooseCaption: TPanel;
    TBDockTop: TTBDock;
    tbMainToolbar: TTBToolbar;
    tbiFind: TTBItem;
    TBDockLeft: TTBDock;
    TBDockBottom: TTBDock;
    TBDockRight: TTBDock;
    ibgrMain: TgsIBGrid;
    ibdsMain: TIBDataSet;
    dbtvMain: TgsDBTreeView;
    cdsChoose: TClientDataSet;
    Button1: TButton;
    TBItem1: TTBItem;
    TBItem2: TTBItem;
    TBItem3: TTBItem;
    actChooseAll: TAction;
    TBItem4: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    TBSeparatorItem2: TTBSeparatorItem;
    Bevel1: TBevel;
    actAsTree: TAction;
    actAsGrid: TAction;
    actAuto: TAction;
    tbiAsTree: TTBItem;
    tbiAsGrid: TTBItem;
    TBSeparatorItem3: TTBSeparatorItem;
    tbiAuto: TTBItem;
    dbgrChoose: TgsDBGrid;
    actClearChoose: TAction;
    actCompanyFilter: TAction;
    tbiCompanyFilter: TTBItem;
    procedure FormCreate(Sender: TObject);
    procedure actChooseOkExecute(Sender: TObject);
    procedure ibgrMainClickedCheck(Sender: TObject; CheckID: String;
      Checked: Boolean);
    procedure actDeleteChooseExecute(Sender: TObject);
    procedure actClearChooseExecute(Sender: TObject);
    procedure actSelectAllExecute(Sender: TObject);
    procedure actUnSelectAllExecute(Sender: TObject);
    procedure actSelectAllUpdate(Sender: TObject);
    procedure actChooseAllExecute(Sender: TObject);
    procedure actAutoExecute(Sender: TObject);
    procedure actAsTreeExecute(Sender: TObject);
    procedure actAsGridExecute(Sender: TObject);
    procedure actAsTreeUpdate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure actCompanyFilterExecute(Sender: TObject);
    procedure ibdsMainFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure cdsChooseBeforeDelete(DataSet: TDataSet);
  private
    FCondition: string;
    FKeyField: string;
    FListField: string;
    FListTable: string;
    FViewType: TChooseViewType;
    FJoinCondition: string;
    FLB: integer;
    FRB: integer;
    procedure SetListTable(const Value: string);
    procedure SetKeyField(const Value: string);
    procedure SetListField(const Value: string);
    procedure SetViewType(const Value: TChooseViewType);
    function GetIDs: string;
    procedure SetIDs(const Value: string);
    procedure SelectAllChild(Node: TTreeNode; bSel: boolean);
    function  IsTree: boolean;
    function  IsStandartTree: boolean;
    function  IsLBRBTree: boolean;
  public
    property ViewType: TChooseViewType read FViewType write SetViewType default cvtAuto;
    property KeyField: string read FKeyField write SetKeyField;
    property ListField: string read FListField write SetListField;
    property ListTable: string read FListTable write SetListTable;
    property Condition: string read FCondition write FCondition;
    property JoinCondition: string read FJoinCondition write FJoinCondition;
    procedure CreateList(const IDs: string);
    property  ChoosenIDs: string read GetIDs write SetIDs;
  end;

var
  dlg_ChooseSet: Tdlg_ChooseSet;

implementation

{$R *.DFM}

{ Tdlg_ChooseSet }

procedure Tdlg_ChooseSet.FormCreate(Sender: TObject);
begin
  ibdsMain.Transaction:= gdcBaseManager.ReadTransaction;
  cdsChoose.CreateDataSet;
end;

procedure Tdlg_ChooseSet.actChooseOkExecute(Sender: TObject);
begin
  ModalResult:= mrOk;
end;

function Tdlg_ChooseSet.IsTree: boolean;
begin
  Result:= IsLBRBTree or IsStandartTree;
end;

function Tdlg_ChooseSet.IsLBRBTree: boolean;
begin
  with atDataBase.Relations do
    Result:= (ByRelationName(FListTable) <> nil)
      and ByRelationName(FListTable).IsLBRBTreeRelation;
end;

function Tdlg_ChooseSet.IsStandartTree: boolean;
begin
  with atDataBase.Relations do
    Result:= (ByRelationName(FListTable) <> nil)
      and ByRelationName(FListTable).IsStandartTreeRelation;
end;

procedure Tdlg_ChooseSet.actAutoExecute(Sender: TObject);
begin
  ViewType:= cvtAuto;
  tbiAuto.Checked:= True;
end;

procedure Tdlg_ChooseSet.actAsTreeExecute(Sender: TObject);
begin
  ViewType:= cvtTree;
  tbiAsTree.Checked:= True;
end;

procedure Tdlg_ChooseSet.actAsTreeUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled:= IsTree;
end;

procedure Tdlg_ChooseSet.actAsGridExecute(Sender: TObject);
begin
  ViewType:= cvtGrid;
  tbiAsGrid.Checked:= True;
end;

procedure Tdlg_ChooseSet.SetListTable(const Value: string);
begin
  FListTable:= AnsiUpperCase(Value);
  if IsTree and (ViewType = cvtAuto) then
    dbtvMain.DataSource:= dsMain;
  if IsTree and (ViewType = cvtAuto) then begin
    ibgrMain.Visible:= False;
    dbtvMain.Visible:= True;
  end
  else begin
    ibgrMain.Visible:= True;
    dbtvMain.Visible:= False;
  end;
  if Assigned(atDataBase.Relations.ByRelationName(FListTable)) then
    if FListTable = 'GD_CONTACT' then
      tbiCompanyFilter.Visible:= True
{    else if Assigned(atDataBase.Relations.ByRelationName(FListTable)) then
      tbiCompanyFilter.Visible:= Assigned(atDataBase.Relations.ByRelationName(FListTable).RelationFields.ByFieldName('COMPANYKEY'))}
  else
    tbiCompanyFilter.Visible:= False;
end;

procedure Tdlg_ChooseSet.SetKeyField(const Value: string);
begin
  FKeyField := Value;
end;

procedure Tdlg_ChooseSet.SetListField(const Value: string);
begin
  FListField := AnsiUpperCase(Value);
end;

procedure Tdlg_ChooseSet.SetViewType(const Value: TChooseViewType);
begin
  if FListTable = '' then Exit;
  if (Value = cvtTree) and not IsTree then
    raise Exception.Create('Таблица не является деревом.');
  if Value = cvtAuto then begin
    dbtvMain.Visible:= IsTree;
    ibgrMain.Visible:= not IsTree;
  end
  else begin
    ibgrMain.Visible:= (Value = cvtGrid);
    dbtvMain.Visible:= (Value = cvtTree);
  end;
  FViewType := Value;
end;

procedure Tdlg_ChooseSet.CreateList(const IDs: string);
begin
  with ibdsMain do begin
    Close;
    SelectSQL.Clear;
    if IsTree then begin
      SelectSQL.Add('SELECT z.' + FListField + ' AS name, ' + ' z.parent, z.' + FKeyField + ' AS id ');
      if ISLBRBTree then
        SelectSQL.Text:= SelectSQL.Text + ', z.lb AS zlb, z.rb AS zrb ';
    end
    else
      SelectSQL.Add('SELECT ' + FListField + ' AS name, ' + FKeyField + ' AS id ');
    SelectSQL.Add('FROM ' + FListTable + ' AS z ');
    if FJoinCondition <> '' then
      SelectSQL.Add(FJoinCondition);
    if FCondition <> '' then
      SelectSQL.Add('WHERE ' + FCondition);
    SelectSQL.Add('ORDER BY z.' + FListField + ' ASC');
    try
      Open;
      dbgrChoose.Columns.Items[1].Visible:= False;
      ibgrMain.CheckBox.FieldName:= FKeyField;
      ibgrMain.CheckBox.DisplayField:= FListField;
      ChoosenIDs:= IDs;
    except
      on E: Exception do
        ShowMessage(E.Message);
    end;
  end;
end;

procedure Tdlg_ChooseSet.ibgrMainClickedCheck(Sender: TObject;
  CheckID: String; Checked: Boolean);
begin
  if dbtvMain.Visible then
    ibdsMain.Locate('id', StrToInt(CheckID), []);
  if Checked then begin
    if Sender is TgsDBTreeView then
      ibgrMain.CheckBox.AddCheck(ibdsMain.FieldByName('id').AsInteger)
    else if IsTree then
      dbtvMain.AddCheck(ibdsMain.FieldByName('id').AsInteger);
    if cdsChoose.Locate('id', CheckID, []) then Exit;
    cdsChoose.Insert;
    cdsChoose.FieldByName('id').AsInteger:= ibdsMain.FieldByName('id').AsInteger;
    cdsChoose.FieldByName('name').AsString:= ibdsMain.FieldByName('name').AsString;
    cdsChoose.Post;
  end
  else begin
    if cdsChoose.Locate('id', ibdsMain.FieldByName('id').AsInteger, []) then
      cdsChoose.Delete;
  end;
end;

function Tdlg_ChooseSet.GetIDs: string;
begin
  Result:= '';
  cdsChoose.First;
  while not cdsChoose.Eof do begin
    if Result <> '' then
      Result:= Result + ', ';
    Result:= Result + cdsChoose.FieldByName('id').AsString;
    cdsChoose.Next;
  end;
end;

procedure Tdlg_ChooseSet.SetIDs(const Value: string);
var
  s: string;
  ID, iRec: integer;
begin
  iRec:= ibdsMain.RecNo;
  ibdsMain.DisableControls;
  try
    if Value <> '' then
      s:= Value + ',';
    while (Pos(',', s) > 0) and (s <> '') do begin
      ID:= StrToInt(Copy(s, 1, Pos(',', s) - 1));
      System.Delete(s, 1, Pos(',', s));
      s:= TrimLeft(s);
      if not ibdsMain.Locate('id', ID, []) then
        Continue;
      ibgrMain.CheckBox.AddCheck(ID);
      if IsTree then
        dbtvMain.AddCheck(ID);
    end;
  finally
    ibdsMain.RecNo:= iRec;
    ibdsMain.EnableControls;
  end;
end;

procedure Tdlg_ChooseSet.actDeleteChooseExecute(Sender: TObject);
begin
  cdsChoose.Delete;
end;

procedure Tdlg_ChooseSet.actClearChooseExecute(Sender: TObject);
var
  C: TCursor;
  iRec: integer;
begin
  C := Screen.Cursor;
  Screen.Cursor := crHourglass;
  iRec:= ibdsMain.RecNo;
  cdsChoose.DisableControls;
  ibdsMain.DisableControls;
  try
    cdsChoose.First;
    while cdsChoose.RecordCount > 0 do
      cdsChoose.Delete;
  finally
    ibdsMain.EnableControls;
    cdsChoose.EnableControls;
    Screen.Cursor := C;
    ibdsMain.RecNo:= iRec;
  end;
end;

procedure Tdlg_ChooseSet.actSelectAllExecute(Sender: TObject);
var
  iRec: integer;
begin
  iRec:= ibdsMain.RecNo;
  ibdsMain.DisableControls;
  dbtvMain.AddCheck(integer(dbtvMain.Selected.Data));
  SelectAllChild(dbtvMain.Selected.GetFirstChild, True);
  ibdsMain.RecNo:= iRec;
  ibdsMain.EnableControls;
end;

procedure Tdlg_ChooseSet.actUnSelectAllExecute(Sender: TObject);
var
  iRec: integer;
begin
  iRec:= ibdsMain.RecNo;
  ibdsMain.DisableControls;
  dbtvMain.AddCheck(integer(dbtvMain.Selected.Data));
  SelectAllChild(dbtvMain.Selected.GetFirstChild, False);
  ibdsMain.RecNo:= iRec;
  ibdsMain.EnableControls;
end;

procedure Tdlg_ChooseSet.actSelectAllUpdate(Sender: TObject);
begin
  (Sender as TAction).Visible:= dbtvMain.Visible;
end;

procedure Tdlg_ChooseSet.actChooseAllExecute(Sender: TObject);
var
  iRec: integer;
  C: TCursor;
begin
  C := Screen.Cursor;
  Screen.Cursor := crHourglass;
  try
    iRec:= ibdsMain.RecNo;
    ibdsMain.DisableControls;
    ibdsMain.First;
    while not ibdsMain.Eof do begin
      ibgrMain.AddCheck;
      ibdsMain.Next;
    end;
    ibdsMain.RecNo:= iRec;
    ibdsMain.EnableControls;
  finally
    Screen.Cursor := C;
  end;
end;

procedure Tdlg_ChooseSet.SelectAllChild(Node: TTreeNode; bSel: boolean);
begin
  if Node <> nil then begin
    if bSel then
      dbtvMain.AddCheck(integer(Node.Data))
    else
      dbtvMain.DeleteCheck(integer(Node.Data));
    if Node.HasChildren then
      SelectAllChild(Node.getFirstChild, bSel);
    SelectAllChild(Node.Parent.getNextChild(Node), bSel);
  end;
end;

procedure Tdlg_ChooseSet.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    ModalResult:= mrCancel; 
end;

procedure Tdlg_ChooseSet.actCompanyFilterExecute(Sender: TObject);
var
  ibsql: TIBSQL;
begin
  ibsql:= TIBSQL.Create(nil);
  ibsql.Transaction:= gdcBaseManager.ReadTransaction;
  ibsql.SQL.Text:=
    'SELECT Min(lb) lb, Max(rb) rb ' +
    'FROM gd_contact ' +
    'WHERE id IN (' + IBLogin.HoldingList + ')';
  try
    ibsql.ExecQuery;
    FLB:= ibsql.FieldByName('lb').AsInteger;
    FRB:= ibsql.FieldByName('rb').AsInteger;
    ibdsMain.Filtered:= tbiCompanyFilter.Checked;
    if dbtvMain.Visible then
      dbtvMain.Selected:= dbtvMain.Items[0]
    else
      ibdsMain.First;
  finally
    ibsql.Free;
  end;
end;

procedure Tdlg_ChooseSet.ibdsMainFilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
begin
  Accept:= tbiCompanyFilter.Checked and (ibdsMain.FieldByName('zlb').AsInteger >= FLB) and
    (ibdsMain.FieldByName('zrb').AsInteger <= FRB);
end;

procedure Tdlg_ChooseSet.cdsChooseBeforeDelete(DataSet: TDataSet);
var
  Event: TAfterCheckEvent;
begin
  Event:= ibgrMain.OnClickedCheck;
  ibgrMain.OnClickedCheck:= nil;
  dbtvMain.OnClickedCheck:= nil;
  ibgrMain.CheckBox.DeleteCheck(cdsChoose.FieldByName('id').AsInteger);
  dbtvMain.DeleteCheck(cdsChoose.FieldByName('id').AsInteger);
  ibgrMain.OnClickedCheck:= Event;
  dbtvMain.OnClickedCheck:= Event;
end;

end.
