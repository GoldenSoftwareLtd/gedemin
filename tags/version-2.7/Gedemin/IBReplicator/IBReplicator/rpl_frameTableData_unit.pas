unit rpl_frameTableData_unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, ImgList, Grids, DBGrids, ComCtrls, TB2Item, StdCtrls,
  XPEdit, XPListView, TB2Dock, TB2Toolbar, ExtCtrls, DB, IBDataBase,
  rpl_frameFormView_unit, IBCustomDataSet, rpl_mnRelations_unit,
  rpl_ReplicationManager_unit, rpl_ResourceString_unit, rpl_BaseTypes_unit,
  xpDBGrid, rplDBGrid, DBCtrls;

type
  TframeTableData = class(TFrame)
    Panel5: TPanel;
    tcTypeView: TTabControl;
    pFilter: TPanel;
    Splitter2: TSplitter;
    Panel3: TPanel;
    TBToolbar2: TTBToolbar;
    TBItem6: TTBItem;
    TBItem5: TTBItem;
    TBItem4: TTBItem;
    lvFilter: TXPListView;
    Panel4: TPanel;
    Panel8: TPanel;
    mClause: TXPMemo;
    sFilter: TSplitter;
    Panel2: TPanel;
    Panel6: TPanel;
    TBToolbar1: TTBToolbar;
    TBItem3: TTBItem;
    TBItem2: TTBItem;
    TBItem1: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    pcData: TPageControl;
    tsGrid: TTabSheet;
    Panel7: TPanel;
    gData: TrplDBGrid;
    tsForm: TTabSheet;
    il16x16: TImageList;
    ActionList: TActionList;
    actFilterApply: TAction;
    actShowFilterPanel: TAction;
    actQuickAddFilterCriteria: TAction;
    actAddCondition: TAction;
    actDeleteCondition: TAction;
    DataSource: TDataSource;
    frameFormView: TframeFormView;
    TBItem7: TTBItem;
    TBItem8: TTBItem;
    TBItem9: TTBItem;
    TBItem10: TTBItem;
    TBItem11: TTBItem;
    TBItem12: TTBItem;
    TBItem13: TTBItem;
    actBof: TAction;
    actPrev: TAction;
    actNext: TAction;
    actEof: TAction;
    actAdd: TAction;
    actDel: TAction;
    actEdit: TAction;
    actSave: TAction;
    actCancel: TAction;
    TBItem14: TTBItem;
    procedure tcTypeViewChange(Sender: TObject);
    procedure actShowFilterPanelExecute(Sender: TObject);
    procedure actBofExecute(Sender: TObject);
    procedure actBofUpdate(Sender: TObject);
    procedure actPrevExecute(Sender: TObject);
    procedure actNextUpdate(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure actEofExecute(Sender: TObject);
    procedure actAddExecute(Sender: TObject);
    procedure actAddUpdate(Sender: TObject);
    procedure actDelExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actSaveUpdate(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actShowFilterPanelUpdate(Sender: TObject);
    procedure actFilterApplyUpdate(Sender: TObject);
    procedure actFilterApplyExecute(Sender: TObject);
  private
    FRelationName: string;
    FTransaction: TIBTransaction;
    FBaseQuery: String;

    procedure SetRelationName(const Value: string);
    procedure SetTransaction(const Value: TIBTransaction);

    procedure ShowFilterPanel(Show: Boolean);
    procedure ApplayFilter(Applay: Boolean); virtual;
    //procedure UpdateFilterRows;
    function GetDataSet: TDataSet;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure CancelFilter;

    property RelationName: string read FRelationName write SetRelationName;
    property Transaction: TIBTransaction read FTransaction write SetTransaction;
    property DataSet: TDataSet read GetDataSet;
  end;

implementation

{$R *.dfm}

type
  TCrackIBDataSet = class(TIBCustomDataSet);

constructor TframeTableData.Create(AOwner: TComponent);
begin
  inherited;
  frameFormView.DataSource := DataSource;
  pcData.ActivePage := tsGrid
end;

procedure TframeTableData.tcTypeViewChange(Sender: TObject);
begin
  case tcTypeView.TabIndex of
    0: pcData.ActivePage := tsGrid;
    1: pcData.ActivePage := tsForm;
  end;
end;

procedure TframeTableData.actShowFilterPanelExecute(Sender: TObject);
begin
  ShowFilterPanel(TAction(Sender).Checked);
end;

procedure TframeTableData.ShowFilterPanel(Show: Boolean);
begin
  sFilter.Height := 3;
  sFilter.Visible := Show;
  pFilter.Visible := Show;

  if Show then
  begin
    sFilter.Top := pFilter.Top + sFilter.Height;
  end;
end;
{
procedure TframeTableData.UpdateFilterRows;
var
  R: TmnRelation;

begin
  R := ReplicationManager.Relations.FindRelation(FRelationName);
  if R <> nil then
  begin
    lvFilter.Items.BeginUpdate;
    try
      lvFilter.Items.Clear;
    finally
      lvFilter.Items.EndUpdate;
    end;
  end else
    lvFilter.Items.Clear;
end;
}

procedure TframeTableData.actBofExecute(Sender: TObject);
begin
  DataSet.First
end;

procedure TframeTableData.actBofUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (DataSet <> nil) and not DataSet.Bof;
end;


procedure TframeTableData.actPrevExecute(Sender: TObject);
begin
  DataSet.Prior
end;

procedure TframeTableData.actNextUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (DataSet <> nil) and not DataSet.Eof;
end;

procedure TframeTableData.actNextExecute(Sender: TObject);
begin
  DataSet.Next
end;

procedure TframeTableData.actEofExecute(Sender: TObject);
begin
  DataSet.Last
end;


procedure TframeTableData.actAddExecute(Sender: TObject);
begin
  DataSet.Insert;
end;

procedure TframeTableData.actAddUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (DataSet <> nil) and (DataSet.State = dsBrowse);
end;

procedure TframeTableData.actDelExecute(Sender: TObject);
begin
  DataSet.Delete;
end;

procedure TframeTableData.actEditExecute(Sender: TObject);
begin
  DataSet.Edit;
end;

procedure TframeTableData.actSaveUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (DataSet <> nil) and (DataSet.State in [dsEdit, dsInsert]);
end;

procedure TframeTableData.actSaveExecute(Sender: TObject);
begin
  DataSet.Post
end;

procedure TframeTableData.actCancelExecute(Sender: TObject);
begin
  DataSet.Cancel
end;

procedure TframeTableData.SetRelationName(const Value: string);
begin
  FRelationName := Value;
  frameFormView.RelationName := Value;
  gData.RelationName := Value;
end;

procedure TframeTableData.SetTransaction(const Value: TIBTransaction);
begin
  FTransaction := Value;
end;

function TframeTableData.GetDataSet: TDataSet;
begin
  Result := DataSource.DataSet
end;

procedure TframeTableData.actShowFilterPanelUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := True;
end;

procedure TframeTableData.actFilterApplyUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (Trim(mClause.Lines.Text) > '') or TAction(Sender).Checked
end;

procedure TframeTableData.actFilterApplyExecute(Sender: TObject);
begin
  ApplayFilter(TAction(Sender).Checked)
end;

procedure TframeTableData.ApplayFilter(Applay: Boolean);
begin
  if Applay then
  begin
    if DataSet is TIBCustomDataSet then
    begin
      FBaseQuery := TCrackIBDataSet(DataSet).SelectSQL.Text;
      TCrackIBDataSet(DataSet).Close;
      TCrackIBDataSet(DataSet).SelectSQL.Text :=
        TCrackIBDataSet(DataSet).SelectSQL.Text +
        ' WHERE ' + mClause.Lines.Text;
      try
        DataSet.Open;
      except
        on E: Exception do
        begin
          ShowMessage(E.Message);
          DataSet.Close;
          TCrackIBDataSet(DataSet).SelectSQL.Text :=
            FBaseQuery;
          DataSet.Open;
        end;
      end;
    end else
    begin
      DataSet.Filter := mClause.Lines.Text;
      DataSet.Filtered := True;
    end;
  end else
  if DataSet is TIBCustomDataSet then
  begin
    DataSet.Close;
     TCrackIBDataSet(DataSet).SelectSQL.Text := FBaseQuery;
     DataSet.Open;
  end else
    DataSet.Filtered := False;
end;

procedure TframeTableData.CancelFilter;
begin
  actFilterApply.Checked := False;
end;

end.
