unit cmp_dlgDataBaseCompare;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  SuperPageControl, ExtCtrls, ComCtrls, gdc_createable_form, Db, Grids,
  DBGrids, gsDBGrid, gsIBGrid, IBCustomDataSet, IBDatabase, contnrs,
  SynEditHighlighter, SynHighlighterSQL, SynEdit, SynMemo, gsIBCtrlGrid,
  StdCtrls;

type
  TTriggerInfo = class
  private
    FTriggerName: String;
    FTriggerBody: String;
    FTriggerType: Integer;
    FID: Integer;
  public
    constructor Create(const anID: Integer; const aTriggerName, aTriggerBody: String;
      const aTriggerType: Integer);

    property ID: Integer read FID;
    property TriggerName: String read FTriggerName write FTriggerName;
    property TriggerType: Integer read FTriggerType write FTriggerType;
    property TriggerBody: String read FTriggerBody write FTriggerBody;
  end;

  TExtTriggerInfo = class(TTriggerInfo)
  end;

type
  Tdlg_DataBaseCompare = class(TgdcCreateableForm)
    pnlMain: TPanel;
    pcMain: TSuperPageControl;
    tsTable: TSuperTabSheet;
    tsFields: TSuperTabSheet;
    tsTriggers: TSuperTabSheet;
    tsCheck: TSuperTabSheet;
    sbDBCompare: TStatusBar;
    pnTblLeft: TPanel;
    spTable: TSplitter;
    pnTblRight: TPanel;
    pnFieldLeft: TPanel;
    spField: TSplitter;
    pnFieldRight: TPanel;
    pnCheckLeft: TPanel;
    Splitter1: TSplitter;
    pnCheckRight: TPanel;
    ibdsFieldLeft: TIBDataSet;
    ibgrFieldLeft: TgsIBGrid;
    dsFieldLeft: TDataSource;
    ExtTr: TIBTransaction;
    ibgrFieldRight: TgsIBGrid;
    dsFieldRight: TDataSource;
    ibdsFieldRight: TIBDataSet;
    ibgrCheckLeft: TgsIBGrid;
    dsCheckLeft: TDataSource;
    ibdsCheckLeft: TIBDataSet;
    ibgrCheckRight: TgsIBGrid;
    dsCheckRight: TDataSource;
    ibdsCheckRight: TIBDataSet;
    tsIndices: TSuperTabSheet;
    pnIndicesLeft: TPanel;
    Splitter4: TSplitter;
    pnIndicesRight: TPanel;
    ibgrIndicesLeft: TgsIBGrid;
    ibgrIndicesRight: TgsIBGrid;
    dsIndicesLeft: TDataSource;
    ibdsIndicesLeft: TIBDataSet;
    dsIndicesRight: TDataSource;
    ibdsIndicesRight: TIBDataSet;
    pnTriggerMain: TPanel;
    pnTriggerTop: TPanel;
    Splitter2: TSplitter;
    pnTriggerLeft: TPanel;
    tvTriggerLeft: TTreeView;
    pnTriggerRight: TPanel;
    tvTriggerRight: TTreeView;
    Splitter3: TSplitter;
    pnTriggerBottom: TPanel;
    edRelationNameLeft: TEdit;
    edLNameLeft: TEdit;
    edLShortNameLeft: TEdit;
    edDescriptionLeft: TEdit;
    edListFieldLeft: TEdit;
    edExtendedFieldLeft: TEdit;
    lblRelationNameLeft: TLabel;
    lblLNameLeft: TLabel;
    lblShotNameLeft: TLabel;
    lblDescriptionLeft: TLabel;
    lblListFieldLeft: TLabel;
    lblExtendedFieldLeft: TLabel;
    lblRelationNameRight: TLabel;
    edRelationNameRight: TEdit;
    lblLNameRight: TLabel;
    edLNameRight: TEdit;
    lblShotNameRight: TLabel;
    edLShortNameRight: TEdit;
    lblDescriptionRight: TLabel;
    edDescriptionRight: TEdit;
    lblListFieldRight: TLabel;
    edListFieldRight: TEdit;
    lblExtendedFieldRight: TLabel;
    edExtendedFieldRight: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tvTriggerLeftChange(Sender: TObject; Node: TTreeNode);
    procedure tvTriggerRightChange(Sender: TObject; Node: TTreeNode);
    procedure tvTriggerLeftCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
  private
    FMiddleWidth: Integer; //при изменении размера экрана устанавливаем ширину панели
    FID: Integer;          //ID таблицы из AT_RELATION
    FExtID: Integer;       //ID внешней таблицы
    TriggerList: TObjectList;
    FileView: TFrame;

    procedure StatusCaption(const S1, S2: String);

    {заполнение данных о таблицах}
    procedure FillRelationsData;
    {заполенение дерева триггеров}
    procedure FillTriggerTree;
    procedure AddTriggerName(const AnID: Integer; const TriggerName, TriggerBody: String; const TriggerType: Integer;
      const TriggerInactive: Integer; var tvTriggers: TTreeView);
    function GetTypeTriggerFromTree(TreeNode: TTreeNode): Integer;  
  public

    procedure InitDlg(const ID, ExtID: Integer; DB, ExtDB: TIBDatabase);
    procedure LoadSettings; override;
    procedure SaveSettings; override;
  end;

var
  dlg_DataBaseCompare: Tdlg_DataBaseCompare;

implementation

uses
  gdcBaseInterface, Storages, IBSQL, dmImages_unit, FileView;

{$R *.DFM}

procedure Tdlg_DataBaseCompare.FormCreate(Sender: TObject);
begin
  pcMain.ActivePageIndex := 0;
  TriggerList := TObjectList.Create;

  FileView := TFilesFrame.Create(Self);
  FileView.Parent := pnTriggerBottom;
  with TFilesFrame(FileView).FontDialog1.Font do
  begin
    Name := 'Courier New';
    Size := 10;
  end;
  TFilesFrame(FileView).Setup;
end;

procedure Tdlg_DataBaseCompare.FormResize(Sender: TObject);
begin
  FMiddleWidth := Width div 2;

  sbDBCompare.Panels[0].Width := FMiddleWidth - 2;
  pnTblLeft.Width := FMiddleWidth - 2;
  pnFieldLeft.Width := FMiddleWidth - 2;
  pnTriggerLeft.Width := FMiddleWidth - 2;
  pnCheckLeft.Width := FMiddleWidth - 2;
  pnIndicesLeft.Width := FMiddleWidth - 2;
end;



procedure Tdlg_DataBaseCompare.InitDlg(const ID, ExtID: Integer; DB, ExtDB: TIBDatabase);
begin
  FID := ID;
  FExtID := ExtID;

  StatusCaption(DB.DatabaseName, ExtDB.DatabaseName);

  ExtTr.DefaultDatabase := ExtDB;
  ExtTr.StartTransaction;

  {Поля}
  ibdsFieldLeft.Database := DB;
  ibdsFieldLeft.ReadTransaction := gdcBaseManager.ReadTransaction;
  ibdsFieldLeft.Params[0].AsInteger := FID;
  ibdsFieldLeft.Open;

  ibdsFieldRight.Database := ExtDB;
  ibdsFieldRight.Params[0].AsInteger := FExtID;
  ibdsFieldRight.Open;

  {триггеры}

  {ограничения}
  ibdsCheckLeft.Database := DB;
  ibdsCheckLeft.ReadTransaction := gdcBaseManager.ReadTransaction;
  ibdsCheckLeft.Params[0].AsInteger := FID;
  ibdsCheckLeft.Open;

  ibdsCheckRight.Database := ExtDB;
  ibdsCheckRight.Params[0].AsInteger := FExtID;
  ibdsCheckRight.Open;

  {индексы}
  ibdsIndicesLeft.Database := DB;
  ibdsIndicesLeft.ReadTransaction := gdcBaseManager.ReadTransaction;
  ibdsIndicesLeft.Params[0].AsInteger := FID;
  ibdsIndicesLeft.Open;

  ibdsIndicesRight.Database := ExtDB;
  ibdsIndicesRight.Params[0].AsInteger := FExtID;
  ibdsIndicesRight.Open;

  FillRelationsData;
  FillTriggerTree;
end;

procedure Tdlg_DataBaseCompare.LoadSettings;
begin
  inherited;

  if Assigned(UserStorage) then
  begin
    LoadGrid(ibgrFieldLeft);
    LoadGrid(ibgrFieldRight);
    LoadGrid(ibgrCheckLeft);
    LoadGrid(ibgrCheckRight);
    LoadGrid(ibgrIndicesLeft);
    LoadGrid(ibgrIndicesRight);
  end;
end;

procedure Tdlg_DataBaseCompare.SaveSettings;
begin
  inherited;

  if Assigned(UserStorage) then
  begin
    SaveGrid(ibgrFieldLeft);
    SaveGrid(ibgrFieldRight);
    SaveGrid(ibgrCheckLeft);
    SaveGrid(ibgrCheckRight);
    SaveGrid(ibgrIndicesLeft);
    SaveGrid(ibgrIndicesRight);
  end;
end;

procedure Tdlg_DataBaseCompare.StatusCaption(const S1, S2: String);
begin
  sbDBCompare.Panels[0].Text := S1;
  sbDBCompare.Panels[1].Text := S2;
end;

{ TTriggerInfo }

constructor TTriggerInfo.Create(const anID: Integer; const aTriggerName,
  aTriggerBody: String; const aTriggerType: Integer);
begin
  FID := anID;
  FTriggerName := aTriggerName;
  FTriggerBody := aTriggerBody;
  FTriggerType := aTriggerType;
end;

procedure Tdlg_DataBaseCompare.AddTriggerName(const AnID: Integer;
  const TriggerName, TriggerBody: String; const TriggerType,
  TriggerInactive: Integer; var tvTriggers: TTreeView);
var
  i, Num, F, S: Integer;
  tNode, tNodeSecond, tNodeThird: TTreeNode;

  procedure FillNode(var Node: TTreeNode; Num: Integer);
    var i: Integer;
  begin
    for i:= 0 to tvTriggers.Items.Count - 1 do
      if (tvTriggers.Items[i].Parent = nil) and (GetTypeTriggerFromTree(tvTriggers.Items[i]) = Num) then
      begin
        Node := tvTriggers.Items.AddChild(tvTriggers.Items[i], TriggerName);
        Node.StateIndex := TriggerInactive;
        Break;
      end;
  end;

begin
  F := 0;
  S := 0;
  Num := 1;
  tNode := nil;
  tNodeSecond := nil;
  tNodeThird := nil;
  if not (TriggerType > 6) then
  begin
    for i:= 0 to tvTriggers.Items.Count - 1 do
      if (tvTriggers.Items[i].Parent = nil) then
      begin
        if Num = TriggerType then
        begin
          tNode := tvTriggers.Items.AddChild(tvTriggers.Items[i], TriggerName);
          tNode.StateIndex := TriggerInactive;
          Break;
        end;
        Inc(Num);
      end;
  end
  else if not (TriggerType > 112) then
  begin
    case TriggerType of
    17:
      begin
        F := 1;
        S := 3;
      end;
    18:
      begin
        F := 2;
        S := 4;
      end;
    25:
      begin
        F := 1;
        S := 5;
      end;
    26:
      begin
        F := 2;
        S := 6;
      end;
    27:
      begin
        F := 3;
        S := 5;
      end;
    28:
      begin
        F := 4;
        S := 6;
      end;
    end;

    if (F <> 0) and (S <> 0) then
    begin
      FillNode(tNode, F);
      FillNode(TNodeSecond, S);
    end;
  end
  else
    begin
      case TriggerType of
      113:
        begin
          FillNode(tNode, 1);
          FillNode(tNodeSecond, 3);
          FillNode(tNodeThird, 5);
        end;
      114:
        begin
          FillNode(tNode, 2);
          FillNode(tNodeSecond, 4);
          FillNode(tNodeThird, 6);
        end;
      end;
    end;

  if tNode <> nil then
  begin
    TriggerList.Add(TTriggerInfo.Create(AnID, TriggerName, TriggerBody, TriggerType));
    tNode.Data := TriggerList.Items[TriggerList.Count - 1];
    if tNodeSecond <> nil then
    begin
      tNodeSecond.Data := tNode.Data;
      if tNodeThird <> nil then
        tNodeThird.Data := tNode.Data;
    end;
  end;
end;

function Tdlg_DataBaseCompare.GetTypeTriggerFromTree(
  TreeNode: TTreeNode): Integer;
var
  NodeText: String;
begin
  Result := -1;

  if TreeNode = nil then
    Exit;

  if TreeNode.Parent <> nil then
    NodeText := AnsiUpperCase(Trim(TreeNode.Parent.Text))
  else
    NodeText := AnsiUpperCase(Trim(TreeNode.Text));

  if NodeText = 'BEFORE INSERT' then
    Result := 1
  else if NodeText = 'AFTER INSERT' then
    Result := 2
  else if NodeText = 'BEFORE UPDATE' then
    Result := 3
  else if NodeText = 'AFTER UPDATE' then
    Result := 4
  else if NodeText = 'BEFORE DELETE' then
    Result := 5
  else if NodeText = 'AFTER DELETE' then
    Result := 6;
end;

procedure Tdlg_DataBaseCompare.FormDestroy(Sender: TObject);
begin
  if Assigned(TriggerList) then
    FreeAndNil(TriggerList);
end;

procedure Tdlg_DataBaseCompare.FillTriggerTree;
var
  FSQL, FExtSQL: TIBSQL;
  S: String;
begin
  S := ' SELECT z.*, t.rdb$trigger_name, t.rdb$trigger_sequence, t.rdb$trigger_type, ' +
    ' t.rdb$trigger_source, t.rdb$trigger_blr, t.rdb$description, t.rdb$system_flag, ' +
    ' t.rdb$flags ' +
    ' FROM at_triggers z LEFT JOIN rdb$triggers t ON z.triggername = t.rdb$trigger_name ' +
    ' WHERE z.relationkey = :relationkey ';
  //текущая БД
  FSQL := TIBSQL.Create(nil);
  FSQL.Transaction := gdcBaseManager.ReadTransaction;
  FSQL.SQL.Text := S;
  FSQL.Params[0].AsInteger := FID;
  //внешняя БД
  FExtSQL := TIBSQL.Create(nil);
  FExtSQL.Transaction := ExtTr;
  FExtSQL.SQL.Text := S;
  FExtSQL.Params[0].AsInteger := FExtID;
  try
    FSQL.ExecQuery;
    FExtSQL.ExecQuery;

    while not FSQL.Eof do
    begin
      AddTriggerName(FSQL.FieldByName('id').AsInteger,
        FSQL.FieldByName('triggername').AsString,
        FSQL.FieldByName('rdb$trigger_source').AsString,
        FSQL.FieldByName('rdb$trigger_type').AsInteger,
        FSQL.FieldByName('trigger_inactive').AsInteger,
        tvTriggerLeft);

      FSQL.Next
    end;

    while not FExtSQL.Eof do
    begin
      AddTriggerName(FExtSQL.FieldByName('id').AsInteger,
        FExtSQL.FieldByName('triggername').AsString,
        FExtSQL.FieldByName('rdb$trigger_source').AsString,
        FExtSQL.FieldByName('rdb$trigger_type').AsInteger,
        FExtSQL.FieldByName('trigger_inactive').AsInteger,
        tvTriggerRight);

      FExtSQL.Next
    end;
  finally
    FSQL.Free;
    FExtSQL.Free;
  end;
end;

procedure Tdlg_DataBaseCompare.tvTriggerLeftChange(Sender: TObject;
  Node: TTreeNode);
var
  i: Integer;
  S: String;
begin
  if (Node.Parent <> nil) then
  begin
    S := '';
    for i := 0 to tvTriggerRight.Items.Count - 1 do
      if (tvTriggerRight.Items[i].Parent <> nil)
        and (tvTriggerRight.Items[i].Text = TTriggerInfo(Node.Data).TriggerName) then
        begin
          tvTriggerRight.Items[i].Selected := True;
          S := TTriggerInfo(tvTriggerRight.Items[i].Data).TriggerBody;
          Break;
        end;
    TFilesFrame(FileView).Compare(TTriggerInfo(Node.Data).TriggerBody, S);
  end else
    TFilesFrame(FileView).Compare('', '');
end;

procedure Tdlg_DataBaseCompare.tvTriggerRightChange(Sender: TObject;
  Node: TTreeNode);
var
  i: Integer;
  S: String;
begin
  if (Node.Parent <> nil) then
  begin
    S := '';
    for i := 0 to tvTriggerLeft.Items.Count - 1 do
      if (tvTriggerLeft.Items[i].Parent <> nil)
        and (tvTriggerLeft.Items[i].Text = TTriggerInfo(Node.Data).TriggerName) then
        begin
          tvTriggerLeft.Items[i].Selected := True;
          S := TTriggerInfo(tvTriggerLeft.Items[i].Data).TriggerBody;
          Break;
        end;
    TFilesFrame(FileView).Compare(S, TTriggerInfo(Node.Data).TriggerBody);
  end else
    TFilesFrame(FileView).Compare('', '');
end;

procedure Tdlg_DataBaseCompare.FillRelationsData;
var
  FSQL, FExtSQL: TIBSQL;
  S: String;
begin
  S := ' SELECT RELATIONNAME, LNAME, LSHORTNAME, DESCRIPTION, LISTFIELD, EXTENDEDFIELDS ' +
    ' FROM AT_RELATIONS ' +
    ' WHERE ID = :ID ';
  //текущая БД
  FSQL := TIBSQL.Create(nil);
  FSQL.Transaction := gdcBaseManager.ReadTransaction;
  FSQL.SQL.Text := S;
  FSQL.Params[0].AsInteger := FID;
  //внешняя БД
  FExtSQL := TIBSQL.Create(nil);
  FExtSQL.Transaction := ExtTr;
  FExtSQL.SQL.Text := S;
  FExtSQL.Params[0].AsInteger := FExtID;
  try
    FSQL.ExecQuery;
    FExtSQL.ExecQuery;

    while not FSQL.Eof do
    begin
      edRelationNameLeft.Text := FSQL.FieldByName('RELATIONNAME').AsString;
      edLNameLeft.Text := FSQL.FieldByName('LNAME').AsString;
      edLShortNameLeft.Text := FSQL.FieldByName('LSHORTNAME').AsString;
      edDescriptionLeft.Text := FSQL.FieldByName('DESCRIPTION').AsString;
      edListFieldLeft.Text := FSQL.FieldByName('LISTFIELD').AsString;
      edExtendedFieldLeft.Text := FSQL.FieldByName('EXTENDEDFIELDS').AsString;

      FSQL.Next
    end;

    while not FExtSQL.Eof do
    begin
      edRelationNameRight.Text := FExtSQL.FieldByName('RELATIONNAME').AsString;
      edLNameRight.Text := FExtSQL.FieldByName('LNAME').AsString;
      edLShortNameRight.Text := FExtSQL.FieldByName('LSHORTNAME').AsString;
      edDescriptionRight.Text := FExtSQL.FieldByName('DESCRIPTION').AsString;
      edListFieldRight.Text := FExtSQL.FieldByName('LISTFIELD').AsString;
      edExtendedFieldRight.Text := FExtSQL.FieldByName('EXTENDEDFIELDS').AsString;

      FExtSQL.Next
    end;

    if edRelationNameLeft.Text <> edRelationNameRight.Text then
    begin
      edRelationNameLeft.Color := clRed;
      edRelationNameRight.Color := clRed;
    end;
    if edLNameRight.Text <> edLNameLeft.Text then
    begin
      edLNameRight.Color := clRed;
      edLNameLeft.Color := clRed;
    end;
    if edLShortNameLeft.Text <> edLShortNameRight.Text then
    begin
      edLShortNameLeft.Color := clRed;
      edLShortNameRight.Color := clRed;
    end;
    if edDescriptionLeft.Text <> edDescriptionRight.Text then
    begin
      edDescriptionLeft.Color := clRed;
      edDescriptionRight.Color := clRed;
    end;
    if edListFieldLeft.Text <> edListFieldRight.Text then
    begin
      edListFieldLeft.Color := clRed;
      edListFieldRight.Color := clRed;
    end;
     if edExtendedFieldLeft.Text <> edExtendedFieldRight.Text then
    begin
      edExtendedFieldLeft.Color := clRed;
      edExtendedFieldRight.Color := clRed;
    end;
  finally
    FSQL.Free;
    FExtSQL.Free;
  end;
end;

procedure Tdlg_DataBaseCompare.tvTriggerLeftCustomDrawItem(
  Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  inherited;
  if Node.StateIndex > 0 then
  begin
    if Sender.Selected = Node then
      Sender.Canvas.Font.Style := [fsBold]
    else
      Sender.Canvas.Font.Color := clGray
  end;
end;

initialization
  RegisterClass(Tdlg_DataBaseCompare);

finalization
  UnRegisterClass(Tdlg_DataBaseCompare);

end.
