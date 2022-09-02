// ShlTanya, 27.02.2019, #4135

unit rp_vwReport_unit;

interface

uses
  Windows, Forms, rp_BaseReport_unit, IBDatabase, Db, IBCustomDataSet, IBQuery,
  Classes, ActnList, ComCtrls, StdCtrls, Controls, ExtCtrls, SysUtils,
  ToolWin, ImgList, Menus, rp_report_const, IBSQL, Dialogs, FrmPlSvr;

type
  TOnSignal = function(const AnKey: TID; const AnAction: TActionType): Boolean of object;

type
  TvwReport = class(TForm)
    lvReport: TListView;
    ActionList1: TActionList;
    actAddReport: TAction;
    actEditReport: TAction;
    actDelReport: TAction;
    ibtrReportList: TIBTransaction;
    actBuildReport: TAction;
    actDefaultServer: TAction;
    tvReportGroup: TTreeView;
    Splitter1: TSplitter;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    tbtnClose: TToolButton;
    ImageList1: TImageList;
    tbtnAddGroup: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    actAddGroup: TAction;
    actEditGroup: TAction;
    actDelGroup: TAction;
    pmGroupTree: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    ImageList2: TImageList;
    ToolButton10: TToolButton;
    actRefresh: TAction;
    actClose: TAction;
    actRebuildReport: TAction;
    ibqryReport: TIBQuery;
    ibqryGroup: TIBQuery;
    ToolButton11: TToolButton;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    ToolButton18: TToolButton;
    ToolButton19: TToolButton;
    ToolButton21: TToolButton;
    ToolButton22: TToolButton;
    ibsqlWork: TIBSQL;
    actCreateFromFile: TAction;
    actSaveToFile: TAction;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    actEditParamFunction: TAction;
    actEditMainFunction: TAction;
    actEditEventFunction: TAction;
    actEditTemplate: TAction;
    FormPlaceSaver1: TFormPlaceSaver;
    pmGroup: TPopupMenu;
    pmReport: TPopupMenu;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;
    N14: TMenuItem;
    N15: TMenuItem;
    N16: TMenuItem;
    procedure actEditReportExecute(Sender: TObject);
    procedure actDelReportExecute(Sender: TObject);
    procedure actAddReportExecute(Sender: TObject);
    procedure actBuildReportExecute(Sender: TObject);
    procedure actDefaultServerExecute(Sender: TObject);
    procedure tvReportGroupExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure actAddGroupExecute(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure tvReportGroupChanging(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure actEditGroupExecute(Sender: TObject);
    procedure actDelGroupExecute(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure actRebuildReportExecute(Sender: TObject);
    procedure tvReportGroupDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure tvReportGroupDragDrop(Sender, Source: TObject; X,
      Y: Integer);
    procedure lvReportKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvReportKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure actCreateFromFileExecute(Sender: TObject);
    procedure actSaveToFileExecute(Sender: TObject);
    procedure actEditParamFunctionExecute(Sender: TObject);
    procedure actEditMainFunctionExecute(Sender: TObject);
    procedure actEditEventFunctionExecute(Sender: TObject);
    procedure actEditTemplateExecute(Sender: TObject);
    procedure actEditReportUpdate(Sender: TObject);
    procedure actEditGroupUpdate(Sender: TObject);
    procedure lvReportResize(Sender: TObject);
    procedure lvReportDblClick(Sender: TObject);
  private
    FGlobalResult: Boolean;
    FDatabase: TIBDatabase;
    FExecuteFunction: TExecuteFunction;
    FExecuteReport: TExecuteReport;
    FBuildReport: TBuildReport;
    FViewResult: TViewReport;
    FSaveFile: TSaveReportFile;
    FLoadFile: TLoadReportFile;
    FRefreshReportData: TRefreshReportData;
    FChangingTree: Boolean;
    FGroupKey: TID;
    FCtrlDown: Boolean;

    procedure ShowGroups(AnParentNode: TTreeNode; const AnParentList: TList = nil);
    procedure ShowReports(AnGroupKey: TID);
    function AddGroup(const AnParent: TTreeNode): Boolean;
    procedure BuildReport(const AnIsRebuild: Boolean = False);
  public
    destructor Destroy; override;
    property vwExecuteFunction: TExecuteFunction read FExecuteFunction write FExecuteFunction;
    property vwExecuteReport: TExecuteReport read FExecuteReport write FExecuteReport;
    property vwViewResult: TViewReport read FViewResult write FViewResult;
    property vwRefreshReportData: TRefreshReportData read FRefreshReportData write FRefreshReportData;
    property vwBuildReport: TBuildReport read FBuildReport write FBuildReport;
    property vwSaveFile: TSaveReportFile read FSaveFile write FSaveFile;
    property vwLoadFile: TLoadReportFile read FLoadFile write FLoadFile;
    procedure Execute(const AnGroupKey: TID; const AnDatabase: TIBDatabase);
    function EventAction(const AnKey: TID; const AnAction: TActionType): Boolean;
  end;

var
  vwReport: TvwReport;

implementation         

uses
  rp_dlgEditReport_unit, gd_SetDatabase, rp_dlgDefaultServer_unit,
  rp_dlgEditReportGroup_unit;

{$R *.DFM}

procedure TvwReport.ShowReports(AnGroupKey: TID);
var
  L: TListItem;
  LastReportKey: TID;
begin
  ibqryReport.Close;
  ibqryReport.Database := FDatabase;
  SetTID(ibqryReport.Params[0], AnGroupKey);
  ibqryReport.Open;
  lvReport.Items.BeginUpdate;
  try
    if lvReport.Selected <> nil then
      LastReportKey := GetTID(lvReport.Selected.Data, Name)
    else
      LastReportKey := 0;

    lvReport.Items.Clear;
    while not ibqryReport.Eof do
    begin
      L := lvReport.Items.Add;
      L.Caption := ibqryReport.FieldByName('name').AsString;
      L.Data := TID2Pointer(GetTID(ibqryReport.FieldByName('id')), Name);
      L.ImageIndex := 2;
      if GetTID(ibqryReport.FieldByName('id')) = LastReportKey then
        L.Selected := True;

      ibqryReport.Next;
    end;
    if (lvReport.Selected = nil) and (lvReport.Items.Count > 0) then
      lvReport.Items[0].Selected := True;
  finally
    lvReport.Items.EndUpdate;
    ibqryReport.Close;
  end;
end;

procedure TvwReport.ShowGroups(AnParentNode: TTreeNode; const AnParentList: TList = nil);
var
  TN: TTreeNode;
  LastGroupKey: TList;
  TempTreeNode: TTreeNode;
  TempIBQuery: TIBSQL;
  TrState: Boolean;
  I: Integer;
begin
  TrState := ibtrReportList.InTransaction;
  if not TrState then
    ibtrReportList.StartTransaction;

  tvReportGroup.Items.BeginUpdate;
  try
    LastGroupKey := TList.Create;
    try
      FChangingTree := True;
      TempTreeNode := tvReportGroup.Selected;
      if AnParentList <> nil then
        for I := 0 to AnParentList.Count - 1 do
          LastGroupKey.Add(AnParentList.Items[I])
      else
        while TempTreeNode <> nil do
        begin
          LastGroupKey.Add(TempTreeNode.Data);
          TempTreeNode := TempTreeNode.Parent;
        end;

      TempIBQuery := TIBSQL.Create(Self);
      try
        TempIBQuery.Database := FDatabase;
        TempIBQuery.Transaction := ibtrReportList;
        TempIBQuery.SQL.Text := ibqryGroup.SQL.Text;
        TempIBQuery.SQL.Delete(ibqryGroup.SQL.Count - 1);
        if AnParentNode = nil then
        begin
          tvReportGroup.Items.Clear;
          if FGroupKey = 0 then
            TempIBQuery.SQL.Add('rg.parent IS NULL ORDER BY rg.name')
          else
            TempIBQuery.SQL.Add('rg.id = ' + TID2S(FGroupKey) + ' ORDER BY rg.name');
        end else
        begin
          AnParentNode.DeleteChildren;
          TempIBQuery.SQL.Add('rg.parent = ' + TID2S(GetTID(AnParentNode.Data, Name)) +
           ' ORDER BY rg.name');
        end;

        TempIBQuery.ExecQuery;
        while not TempIBQuery.Eof do
        begin
          TN := tvReportGroup.Items.AddChild(AnParentNode, TempIBQuery.FieldByName('name').AsString);
          TN.HasChildren := TempIBQuery.FieldByName('haschildren').AsInteger <> 0;
          TN.Data := TID2Pointer(GetTID(TempIBQuery.FieldByName('id')), Name);
          TN.ImageIndex := 0;
          TN.SelectedIndex := 1;
          if (LastGroupKey.Count > 0) and (LastGroupKey.IndexOf(TN.Data) <> -1) then
          begin
            TN.Selected := True;
            LastGroupKey.Delete(LastGroupKey.IndexOf(TN.Data));
            ShowGroups(TN, LastGroupKey);
          end;
          TempIBQuery.Next;
        end;

      finally
        TempIBQuery.Close;
        TempIBQuery.Free;
      end;

      if AnParentNode <> nil then
        AnParentNode.Expand(False);
    finally
      LastGroupKey.Free;
    end;
  finally
    if not TrState then
      ibtrReportList.Commit;
    FChangingTree := False;
    tvReportGroup.Items.EndUpdate;
  end;
end;

procedure TvwReport.Execute(const AnGroupKey: TID; const AnDatabase: TIBDatabase);
begin
  FGroupKey := AnGroupKey;
  FDatabase := AnDatabase;
  SetDatabase(Self, FDatabase);

  ShowGroups(nil);
  if (tvReportGroup.Selected = nil) and (tvReportGroup.Items.Count > 0) then
    tvReportGroup.Items[0].Selected := True;
  Show;
end;

procedure TvwReport.actEditReportExecute(Sender: TObject);
var
  F: TdlgEditReport;
begin
  FGlobalResult := False;
  if lvReport.Selected = nil then
    Exit;
  F := TdlgEditReport.Create(Self);
  try
    SetDatabase(F, FDatabase);
    F.ExecuteFunction := FExecuteFunction;
    if F.EditReport(GetTID(lvReport.Selected.Data, Name)) then
    begin
      ShowReports(GetTID(tvReportGroup.Selected.Data, Name));
      FGlobalResult := True;
    end;
  finally
    F.Free;
  end;
end;

procedure TvwReport.actDelReportExecute(Sender: TObject);
var
  F: TdlgEditReport;
begin
  FGlobalResult := False;
  if lvReport.Selected = nil then
    Exit;
  F := TdlgEditReport.Create(Self);
  try
    SetDatabase(F, FDatabase);
    if F.DeleteReport(GetTID(lvReport.Selected.Data, Name)) then
    begin
      ShowReports(GetTID(tvReportGroup.Selected.Data, Name));
      FGlobalResult := True;
    end;
  finally
    F.Free;
  end;
end;

procedure TvwReport.actAddReportExecute(Sender: TObject);
var
  F: TdlgEditReport;
begin
  FGlobalResult := False;
  if tvReportGroup.Selected <> nil then
  begin
    F := TdlgEditReport.Create(Self);
    try
      SetDatabase(F, FDatabase);
      F.ExecuteFunction := FExecuteFunction;
      if F.AddReport(GetTID(tvReportGroup.Selected.Data, Name)) then
      begin
        ShowReports(GetTID(tvReportGroup.Selected.Data, Name));
        FGlobalResult := True;
      end;
    finally
      F.Free;
    end;
  end else
    MessageBox(Self.Handle, 'Не выбрана группа в которую будет входить отчет.', 'Внимание', MB_OK or MB_ICONWARNING);
end;

procedure TvwReport.BuildReport(const AnIsRebuild: Boolean = False);
begin
  if lvReport.Selected = nil then
  begin
    MessageBox(Handle, 'Не выбран отчет для построения', 'Внимание', MB_OK or MB_ICONWARNING);
    Exit;
  end;
  if Assigned(FBuildReport) then
  begin
    FBuildReport(GetTID(lvReport.Selected.Data, Name), AnIsRebuild);
  end else
    raise Exception.Create('Не задано событие построения отчета.');
end;

procedure TvwReport.actBuildReportExecute(Sender: TObject);
begin
  BuildReport;
end;

procedure TvwReport.actDefaultServerExecute(Sender: TObject);
var
  F: TdlgDefaultServer;
  StateDB, StateTR: Boolean;
begin
  F := TdlgDefaultServer.Create(Self);
  try
    StateDB := FDatabase.Connected;
    StateTR := ibtrReportList.InTransaction;
    try
      if not StateDB then
        FDatabase.Connected := True;
      if not StateTR then
        ibtrReportList.StartTransaction;

      SetDatabaseAndTransaction(F, FDatabase, ibtrReportList);
      if F.SetDefaultServer then
        MessageBox(Self.Handle, 'Новые настройки вступят в силу после перезапуска программы.',
         'Внимание!', MB_OK or MB_ICONINFORMATION);
    finally
      if not StateTR then
        ibtrReportList.Commit;
      if not StateDB then
        FDatabase.Connected := False;
    end;
  finally
    F.Free;
  end;
end;

procedure TvwReport.tvReportGroupExpanding(Sender: TObject;
  Node: TTreeNode; var AllowExpansion: Boolean);
begin
  if Node.HasChildren and (Node.Count = 0) then
    ShowGroups(Node);
end;

function TvwReport.AddGroup(const AnParent: TTreeNode): Boolean;
var
  F: TdlgEditReportGroup;
  StateDB, StateTR: Boolean;
begin
  F := TdlgEditReportGroup.Create(Self);
  try
    StateDB := FDatabase.Connected;
    StateTR := ibtrReportList.InTransaction;
    try
      if not StateDB then
        FDatabase.Connected := True;
      if not StateTR then
        ibtrReportList.StartTransaction;

      SetDatabaseAndTransaction(F, FDatabase, ibtrReportList);
      if AnParent <> nil then
        Result := F.AddGroup(GetTID(AnParent.Data, Name))
      else
        Result := F.AddGroup(Null);
      if Result then
        ShowGroups(AnParent);
    finally
      if not StateTR then
        ibtrReportList.Commit;
      if not StateDB then
        FDatabase.Connected := False;
    end;
  finally
    F.Free;
  end;
end;

procedure TvwReport.actAddGroupExecute(Sender: TObject);
var
  P: TPoint;
begin
  P := ClientToScreen(Point(tbtnAddGroup.Left, tbtnAddGroup.Top + tbtnAddGroup.Height));
  pmGroupTree.Popup(P.x, P.y);
end;

procedure TvwReport.N2Click(Sender: TObject);
begin
  if tvReportGroup.Selected <> nil then
    FGlobalResult := AddGroup(tvReportGroup.Selected)
  else
    MessageBox(Self.Handle, 'Не выбранна родительская группа.', 'Внимание', MB_OK or MB_ICONWARNING);
end;

procedure TvwReport.N1Click(Sender: TObject);
begin
  if tvReportGroup.Selected <> nil then
    FGlobalResult := AddGroup(tvReportGroup.Selected.Parent)
  else
    FGlobalResult := AddGroup(nil);
end;

procedure TvwReport.tvReportGroupChanging(Sender: TObject; Node: TTreeNode;
  var AllowChange: Boolean);
begin
  if not FChangingTree then
    ShowReports(GetTID(Node.Data, Name));
end;

procedure TvwReport.FormCreate(Sender: TObject);
begin
  FChangingTree := False;
  FCtrlDown := False;
end;

procedure TvwReport.actEditGroupExecute(Sender: TObject);
var
  F: TdlgEditReportGroup;
  StateDB, StateTR: Boolean;
begin
  FGlobalResult := False;
  if tvReportGroup.Selected <> nil then
  begin
    F := TdlgEditReportGroup.Create(Self);
    try
      StateDB := FDatabase.Connected;
      StateTR := ibtrReportList.InTransaction;
      try
        if not StateDB then
          FDatabase.Connected := True;
        if not StateTR then
          ibtrReportList.StartTransaction;

        SetDatabaseAndTransaction(F, FDatabase, ibtrReportList);
        if F.EditGroup(GetTID(tvReportGroup.Selected.Data, Name)) then
        begin
          ShowGroups(tvReportGroup.Selected.Parent);
          FGlobalResult := True;
        end;
      finally
        if not StateTR then
          ibtrReportList.Commit;
        if not StateDB then
          FDatabase.Connected := False;
      end;
    finally
      F.Free;
    end;
  end else
    MessageBox(Self.Handle, 'Не выбрана группа для редактирования.', 'Внимание',
     MB_OK or MB_ICONWARNING);
end;

procedure TvwReport.actDelGroupExecute(Sender: TObject);
var
  F: TdlgEditReportGroup;
  StateDB, StateTR: Boolean;
begin
  FGlobalResult := False;
  if tvReportGroup.Selected <> nil then
  begin
    F := TdlgEditReportGroup.Create(Self);
    try
      StateDB := FDatabase.Connected;
      StateTR := ibtrReportList.InTransaction;
      try
        if not StateDB then
          FDatabase.Connected := True;
        if not StateTR then
          ibtrReportList.StartTransaction;

        SetDatabaseAndTransaction(F, FDatabase, ibtrReportList);
        if F.DeleteGroup(GetTID(tvReportGroup.Selected.Data, Name)) then
        begin
          ShowGroups(tvReportGroup.Selected.Parent);
          FGlobalResult := True;
        end;
      finally
        if not StateTR then
          ibtrReportList.Commit;
        if not StateDB then
          FDatabase.Connected := False;
      end;
    finally
      F.Free;
    end;
  end else
    MessageBox(Self.Handle, 'Не выбрана группа для удаления.', 'Внимание',
     MB_OK or MB_ICONWARNING);
end;

procedure TvwReport.actRefreshExecute(Sender: TObject);
begin
  tvReportGroup.Items.BeginUpdate;
  tvReportGroup.Enabled := False;
  try
    if Assigned(FRefreshReportData) then
      FRefreshReportData;
    ShowGroups(nil);
  finally
    tvReportGroup.Enabled := True;
    tvReportGroup.Items.EndUpdate;
  end;
end;

procedure TvwReport.actCloseExecute(Sender: TObject);
begin
  Close;
end;

procedure TvwReport.actRebuildReportExecute(Sender: TObject);
begin
  BuildReport(True);
end;

function TvwReport.EventAction(const AnKey: TID; const AnAction: TActionType): Boolean;
begin
  case AnAction of
    atAddGroup: actAddGroup.Execute;
    atEditGroup: actEditGroup.Execute;
    atDelGroup: actDelGroup.Execute;
    atAddReport: actAddReport.Execute;
    atEditReport: actEditReport.Execute;
    atDelReport: actDelReport.Execute;
    atDefServer: actDefaultServer.Execute;
  end;
  Result := FGlobalResult;
end;

procedure TvwReport.tvReportGroupDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
//
end;

procedure TvwReport.tvReportGroupDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  TempNode: TTreeNode;
  StateTR: Boolean;
begin
  try
    StateTR := ibtrReportList.InTransaction;
    if not StateTR then
      ibtrReportList.StartTransaction;
    try
      TempNode := (Sender as TTreeView).GetNodeAt(X, Y);
      if TempNode <> nil then
        if (Source as TListView).Selected <> nil then
        begin
          ibsqlWork.Close;
          ibsqlWork.SQL.Text := Format('UPDATE rp_reportlist SET reportgroupkey = %d WHERE id = %d',
           [TID264(GetTID(TempNode.Data, Name)), TID264(GetTID((Source as TListView).Selected.Data, Name))]);
          ibsqlWork.ExecQuery;

          if (Sender as TTreeView).Selected <> nil then
            ShowReports(GetTID((Sender as TTreeView).Selected.Data, Name));
        end;
    finally
      ibtrReportList.Commit;
      if StateTR then
        ibtrReportList.StartTransaction;
    end;
  except
    on E: Exception do
      MessageBox(Handle, PChar('Произошла ошибка при попытке переноса:'#13#10 + E.Message), 'Ошибка', MB_OK or MB_ICONERROR);
  end;
end;

procedure TvwReport.lvReportKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_CONTROL then
    FCtrlDown := True;
end;

procedure TvwReport.lvReportKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_CONTROL then
    FCtrlDown := False;
end;

procedure TvwReport.actCreateFromFileExecute(Sender: TObject);
begin
  if tvReportGroup.Selected = nil then
    raise Exception.Create('Не выбрана группа для нового отчета.');

  if Assigned(FLoadFile) then
  begin
    if OpenDialog1.Execute then
      if FLoadFile(GetTID(tvReportGroup.Selected.Data, Name), OpenDialog1.FileName) then
        ShowReports(GetTID(tvReportGroup.Selected.Data, Name));
  end else
    raise Exception.Create('Не задано событие построения отчета.');
end;

procedure TvwReport.actSaveToFileExecute(Sender: TObject);
begin
  if lvReport.Selected = nil then
  begin
    MessageBox(Handle, 'Не выбран отчет для сохранения', 'Внимание', MB_OK or MB_ICONWARNING);
    Exit;
  end;
  if Assigned(FSaveFile) then
  begin
    if SaveDialog1.Execute then
      FSaveFile(GetTID(lvReport.Selected.Data, Name), SaveDialog1.FileName);
  end else
    raise Exception.Create('Не задано событие для сохранения отчета.');
end;

procedure TvwReport.actEditParamFunctionExecute(Sender: TObject);
var
  F: TdlgEditReport;
begin
  FGlobalResult := False;
  if lvReport.Selected = nil then
    Exit;
  F := TdlgEditReport.Create(Self);
  try
    SetDatabase(F, FDatabase);
    F.ExecuteFunction := FExecuteFunction;
    if F.PrepareReport(GetTID(lvReport.Selected.Data, Name)) then
    try
      F.actSelectParamFunc.Execute;
    finally
      F.UnPrepareReport;
    end;
  finally
    F.Free;
  end;
end;

procedure TvwReport.actEditMainFunctionExecute(Sender: TObject);
var
  F: TdlgEditReport;
begin
  FGlobalResult := False;
  if lvReport.Selected = nil then
    Exit;
  F := TdlgEditReport.Create(Self);
  try
    SetDatabase(F, FDatabase);
    F.ExecuteFunction := FExecuteFunction;
    if F.PrepareReport(GetTID(lvReport.Selected.Data, Name)) then
    try
      F.actSelectMainFunc.Execute;
    finally
      F.UnPrepareReport;
    end;
  finally
    F.Free;
  end;
end;

procedure TvwReport.actEditEventFunctionExecute(Sender: TObject);
var
  F: TdlgEditReport;
begin
  FGlobalResult := False;
  if lvReport.Selected = nil then
    Exit;
  F := TdlgEditReport.Create(Self);
  try
    SetDatabase(F, FDatabase);
    F.ExecuteFunction := FExecuteFunction;
    if F.PrepareReport(GetTID(lvReport.Selected.Data, Name)) then
    try
        F.actSelectEventFunc.Execute;
    finally
      F.UnPrepareReport;
    end;
  finally
    F.Free;
  end;
end;

procedure TvwReport.actEditTemplateExecute(Sender: TObject);
var
  F: TdlgEditReport;
begin
  FGlobalResult := False;
  if lvReport.Selected = nil then
    Exit;
  F := TdlgEditReport.Create(Self);
  try
    SetDatabase(F, FDatabase);
    F.ExecuteFunction := FExecuteFunction;
    if F.PrepareReport(GetTID(lvReport.Selected.Data, Name)) then
    try
      F.actSelectTemplate.Execute;
    finally
      F.UnPrepareReport;
    end;
  finally
    F.Free;
  end;
end;

procedure TvwReport.actEditReportUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := lvReport.Selected <> nil;
end;

procedure TvwReport.actEditGroupUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := tvReportGroup.Selected <> nil;
end;

procedure TvwReport.lvReportResize(Sender: TObject);
begin
  lvReport.Columns[0].Width := lvReport.Width - 4;
end;

procedure TvwReport.lvReportDblClick(Sender: TObject);
begin
  actBuildReport.Execute;
end;

destructor TvwReport.Destroy;
begin
  {$IFDEF ID64}
  FreeConvertContext(Name);
  {$ENDIF}
  inherited;
end;

end.
