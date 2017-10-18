
unit gdcc_frmMain_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, gdccConst, Menus, gsTrayIcon, ActnList, TB2Dock, TB2Item,
  ComCtrls, TB2Toolbar, ExtCtrls, ImgList;

type
  Tgdcc_frmMain = class(TForm)
    gsTrayIcon: TgsTrayIcon;
    pmTray: TPopupMenu;
    Item1: TMenuItem;
    al: TActionList;
    actShowOrHide: TAction;
    actClose: TAction;
    tbDockTop: TTBDock;
    tbMenu: TTBToolbar;
    tbConnections: TTBToolbar;
    pc: TPageControl;
    tsLog: TTabSheet;
    TBItem1: TTBItem;
    pnlLog: TPanel;
    il: TImageList;
    lvLog: TListView;
    SplitLog: TSplitter;
    mLog: TMemo;
    pnlSB: TPanel;
    sb: TStatusBar;
    actSetLogFilter: TAction;
    actClearLogFilter: TAction;
    TBSubmenuItem1: TTBSubmenuItem;
    actSaveLogToFile: TAction;
    TBItem5: TTBItem;
    TBSeparatorItem5: TTBSeparatorItem;
    TBSubmenuItem2: TTBSubmenuItem;
    actViewLog: TAction;
    actViewProfiler: TAction;
    TBItem2: TTBItem;
    TBSeparatorItem6: TTBSeparatorItem;
    TBItem6: TTBItem;
    TBItem7: TTBItem;
    tsProfiler: TTabSheet;
    actAutoUpdate: TAction;
    TBSeparatorItem7: TTBSeparatorItem;
    TBItem8: TTBItem;
    pnlProfiler: TPanel;
    SplitProfiler: TSplitter;
    lvProfiler: TListView;
    mProfiler: TMemo;
    tbdLog: TTBDock;
    tbCommands: TTBToolbar;
    TBControlItem1: TTBControlItem;
    TBControlItem2: TTBControlItem;
    TBSeparatorItem1: TTBSeparatorItem;
    TBControlItem3: TTBControlItem;
    TBControlItem8: TTBControlItem;
    TBControlItem5: TTBControlItem;
    TBSeparatorItem3: TTBSeparatorItem;
    TBControlItem6: TTBControlItem;
    TBSeparatorItem2: TTBSeparatorItem;
    TBControlItem7: TTBControlItem;
    TBSeparatorItem4: TTBSeparatorItem;
    TBItem4: TTBItem;
    TBItem3: TTBItem;
    Label1: TLabel;
    Label2: TLabel;
    edLogFilter: TEdit;
    chbxError: TCheckBox;
    chbxWarning: TCheckBox;
    chbxInfo: TCheckBox;
    cbLogSources: TComboBox;
    tbdProfiler: TTBDock;
    tbProfiler: TTBToolbar;
    TBControlItem4: TTBControlItem;
    TBControlItem9: TTBControlItem;
    TBSeparatorItem8: TTBSeparatorItem;
    TBControlItem10: TTBControlItem;
    TBControlItem11: TTBControlItem;
    TBSeparatorItem9: TTBSeparatorItem;
    TBSeparatorItem10: TTBSeparatorItem;
    TBSeparatorItem11: TTBSeparatorItem;
    TBItem9: TTBItem;
    TBItem10: TTBItem;
    Label3: TLabel;
    Label4: TLabel;
    edProfilerFilter: TEdit;
    cbProfilerSources: TComboBox;
    actSetProfilerFilter: TAction;
    actClearProfilerFilter: TAction;
    TBItem11: TTBItem;
    actAbout: TAction;
    actClearProfilerData: TAction;
    TBSeparatorItem12: TTBSeparatorItem;
    TBItem12: TTBItem;
    actClearLogData: TAction;
    TBItem13: TTBItem;
    TBSeparatorItem13: TTBSeparatorItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actShowOrHideUpdate(Sender: TObject);
    procedure actShowOrHideExecute(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure lvLogData(Sender: TObject; Item: TListItem);
    procedure lvLogDataHint(Sender: TObject; StartIndex, EndIndex: Integer);
    procedure actSetLogFilterExecute(Sender: TObject);
    procedure actSetLogFilterUpdate(Sender: TObject);
    procedure actClearLogFilterExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure lvLogSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure actSaveLogToFileExecute(Sender: TObject);
    procedure actSaveLogToFileUpdate(Sender: TObject);
    procedure actViewLogUpdate(Sender: TObject);
    procedure actViewLogExecute(Sender: TObject);
    procedure actViewProfilerUpdate(Sender: TObject);
    procedure actViewProfilerExecute(Sender: TObject);
    procedure actAutoUpdateExecute(Sender: TObject);
    procedure lvProfilerData(Sender: TObject; Item: TListItem);
    procedure lvProfilerDataHint(Sender: TObject; StartIndex,
      EndIndex: Integer);
    procedure lvProfilerSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure lvProfilerColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvProfilerResize(Sender: TObject);
    procedure lvLogResize(Sender: TObject);
    procedure actSetProfilerFilterExecute(Sender: TObject);
    procedure sbResize(Sender: TObject);
    procedure actClearLogFilterUpdate(Sender: TObject);
    procedure actClearProfilerFilterUpdate(Sender: TObject);
    procedure actClearProfilerFilterExecute(Sender: TObject);
    procedure actSetProfilerFilterUpdate(Sender: TObject);
    procedure actAboutExecute(Sender: TObject);
    procedure gsTrayIconClick(Sender: TObject);
    procedure actClearProfilerDataExecute(Sender: TObject);

  private
    FCurrentID: Integer;
    FUserActivated: Boolean;
    FCanClose: Boolean;
    FSD: TSaveDialog;

    procedure OnActExecute(Sender: TObject);
    procedure OnActUpdate(Sender: TObject);
    procedure WMQueryEndSession(var Message: TMessage);
      message WM_QUERYENDSESSION;
    procedure WMGDCCServerNotify(var Msg: TMessage);
      message WM_GDCC_SERVER_NOTIFY;
    procedure WMGDCCServerClose(var Msg: TMessage);
      message WM_GDCC_SERVER_CLOSE;
    procedure PrepareLogItem(LI: TListItem);
    procedure PrepareProfilerItem(LI: TListItem);
    procedure UpdateProfilerSB;
    procedure UpdateLogSB;
  end;

var
  gdcc_frmMain: Tgdcc_frmMain;

implementation

uses
  gdccServer_unit, at_Log, gd_common_functions;

{$R *.DFM}

function ShortenString(const S: String): String;
begin
  if Length(S) > 120 then
    Result := Copy(S, 1, 117) + '...'
  else
    Result := S;

  Result :=
    StringReplace(
      StringReplace(S,
        #13#10#32, #32, [rfReplaceAll]),
      #13#10, #32, [rfReplaceAll]);
end;

procedure Tgdcc_frmMain.FormCreate(Sender: TObject);
begin
  FCurrentID := -1;

  pc.ActivePage := tsLog;

  lvLog.Items.Count := 0;
  edLogFilter.Text := '';
  cbLogSources.Text := '';
  cbLogSources.Items.Clear;
  chbxInfo.Checked := True;
  chbxWarning.Checked := True;
  chbxError.Checked := True;

  lvProfiler.Items.Count := 0;
  edProfilerFilter.Text := '';
  cbProfilerSources.Text := '';
  cbProfilerSources.Items.Clear;

  sb.Panels[0].Text := '';
  sb.Panels[1].Text := '';
  sb.Panels[2].Text := '';

  gdccServer.NotifyHandle := Handle;
end;

procedure Tgdcc_frmMain.WMGDCCServerNotify(var Msg: TMessage);

  function GetCaption(const AConnID: Integer; const AHostName: String = ''): String;
  begin
    Result := '#' + IntToStr(AConnID);
    if AHostName > '' then
      Result := Result + ' ' + AHostName;
  end;

var
  Act: TAction;
  TBI: TTBItem;
  I, J: Integer;
  C: TgdccConnection;
  NewCount: Integer;
begin
  case Msg.WParam of
    gdcc_nConnect:
    begin
      if FCurrentID = -1 then
        FCurrentID := Msg.LParam;

      Act := TAction.Create(al);
      Act.Caption := GetCaption(Msg.LParam);
      Act.Tag := Msg.LParam;
      Act.OnExecute := OnActExecute;
      Act.OnUpdate := OnActUpdate;
      Act.ActionList := al;

      TBI := TTBItem.Create(tbConnections);
      TBI.Action := Act;
      tbConnections.Items.Add(TBI);

      pc.ActivePage := tsLog;
    end;

    gdcc_nDisconnect:
    begin
      for I := 0 to al.ActionCount - 1 do
      begin
        if al.Actions[I].Tag = Msg.LParam then
        begin
          if tbConnections.Items.Count > 10 then
          begin
            for J := 0 to tbConnections.Items.Count - 1 do
            begin
              if tbConnections.Items[J].Action = al.Actions[I] then
              begin
                tbConnections.Items[J].Free;
                break;
              end;
            end;
            al.Actions[I].Free;
            gdccServer.Connections.DeleteConnection(Msg.LParam);
          end else
            (al.Actions[I] as TAction).Caption := (al.Actions[I] as TAction).Caption + ' (disc)';

          break;
        end;
      end;
    end;

    gdcc_nHostName:
    begin
      for I := 0 to al.ActionCount - 1 do
      begin
        if al.Actions[I].Tag = Msg.LParam then
        begin
          if gdccServer.Connections.FindAndLock(Msg.LParam, C) then
          try
            (al.Actions[I] as TAction).Caption := GetCaption(C.ID, C.HostName);
          finally
            gdccServer.Connections.Unlock;
          end;
        end;
      end;
    end;

    gdcc_nLog:
    begin
      if (FSD <> nil) or (Msg.LParam <> FCurrentID) or (pc.ActivePage <> tsLog) then
        exit;

      if gdccServer.Connections.FindAndLock(FCurrentID, C) then
      try
        if (C.Log.FilteredCount < 40) or actAutoUpdate.Checked then
          NewCount := C.Log.FilteredCount
        else
          NewCount := -1;

        if C.Log.FilteredCount > 0 then
          sb.Panels[0].Text := ShortenString(C.Log.FilteredLogText[C.Log.FilteredCount - 1])
        else
          sb.Panels[0].Text := '';  

        if C.Log.WasError then
          sb.Panels[2].Text := 'Ошибка'
        else
          sb.Panels[2].Text := '';

        if cbLogSources.Items.Count <> C.Log.Sources.Count then
          cbLogSources.Items.Assign(C.Log.Sources);
      finally
        gdccServer.Connections.Unlock;
      end;

      if NewCount <> -1 then
      begin
        lvLog.Items.BeginUpdate;
        try
          lvLog.Items.Count := NewCount;
          if NewCount > 0 then
          begin
            lvLog.Items[NewCount - 1].Selected := True;
            lvLog.Items[NewCount - 1].MakeVisible(False);
          end;
        finally
          lvLog.Items.EndUpdate;
        end;
        actSetLogFilter.ImageIndex := -1;
      end else
        actSetLogFilter.ImageIndex := 1;

      UpdateLogSB;
    end;

    gdcc_nProc:
    begin
      if (FSD <> nil) or (Msg.LParam <> FCurrentID) or (pc.ActivePage <> tsProfiler) then
        exit;

      UpdateProfilerSB;
    end;

    gdcc_nShow:
    begin
      pc.ActivePage := tsLog;
      actClearLogFilter.Execute;
      WindowState := wsNormal;
      Show;
    end;

    gdcc_nUserShow:
    begin
      WindowState := wsNormal;
      Show;
      FUserActivated := True;
    end;
  end;
end;

procedure Tgdcc_frmMain.FormDestroy(Sender: TObject);
begin
  gdccServer.NotifyHandle := 0;
end;

procedure Tgdcc_frmMain.actShowOrHideUpdate(Sender: TObject);
begin
  if Visible then
    actShowOrHide.Caption := 'Скрыть GDCC'
  else
    actShowOrHide.Caption := 'Показать GDCC';
end;

procedure Tgdcc_frmMain.actShowOrHideExecute(Sender: TObject);
begin
  Visible := not Visible;
  FUserActivated := True;
end;

procedure Tgdcc_frmMain.actCloseExecute(Sender: TObject);
begin
  FCanClose := True;
  Close;
end;

procedure Tgdcc_frmMain.OnActExecute(Sender: TObject);
var
  C: TgdccConnection;
begin
  if FCurrentID = (Sender as TAction).Tag then
    exit;

  FCurrentID := (Sender as TAction).Tag;

  if gdccServer.Connections.FindAndLock(FCurrentID, C) then
  try
    if C.Log.WasError then
      sb.Panels[2].Text := 'Ошибка'
    else
      sb.Panels[2].Text := '';
  finally
    gdccServer.Connections.Unlock;
  end;

  sb.Panels[0].Text := '';

  if pc.ActivePage = tsLog then
    actSetLogFilter.Execute
  else
    actSetProfilerFilter.Execute;
end;

procedure Tgdcc_frmMain.OnActUpdate(Sender: TObject);
begin
  (Sender as TAction).Checked := (Sender as TAction).Tag = FCurrentID;
end;

procedure Tgdcc_frmMain.PrepareLogItem(LI: TListItem);
var
  LogRec: TatLogRec;
  C: TgdccConnection;
begin
  Assert(LI <> nil);

  if gdccServer.Connections.FindAndLock(FCurrentID, C) then
  try
    if LI.Index < C.Log.FilteredCount then
    begin
      LogRec := C.Log.FilteredLogRec[LI.Index];

      with LogRec do
      begin
        LI.Caption := FormatDateTime('hh:nn:ss', Logged);

        if Src > -1 then
          LI.SubItems.Add(C.Log.Source[Src])
        else
          LI.SubItems.Add('');

        LI.SubItems.Add(ShortenString(C.Log.FilteredLogText[LI.Index]));

        case LogType of
          atltError: LI.StateIndex := 0;
          atltWarning: LI.StateIndex := 1;
        else
          LI.StateIndex := 2;
        end;
      end;
    end;  
  finally
    gdccServer.Connections.Unlock;
  end;
end;

procedure Tgdcc_frmMain.lvLogData(Sender: TObject; Item: TListItem);
begin
  PrepareLogItem(Item);
end;

procedure Tgdcc_frmMain.lvLogDataHint(Sender: TObject; StartIndex,
  EndIndex: Integer);
var
  I: Integer;
begin
  for I := StartIndex to EndIndex do
    PrepareLogItem(lvLog.Items[I]);
end;

procedure Tgdcc_frmMain.WMGDCCServerClose(var Msg: TMessage);
begin
  if not FUserActivated then
  begin
    FCanClose := True;
    Close;
  end;
end;

procedure Tgdcc_frmMain.actSetLogFilterExecute(Sender: TObject);
var
  C: TgdccConnection;
  LT: TatLogTypes;
begin
  LT := [];
  if chbxInfo.Checked then Include(LT, atltInfo);
  if chbxWarning.Checked then Include(LT, atltWarning);
  if chbxError.Checked then Include(LT, atltError);

  if gdccServer.Connections.FindAndLock(FCurrentID, C) then
  try
    if (C.Log.FilterTypes <> LT) or (C.Log.FilterSrc <> cbLogSources.Text)
      or (C.Log.FilterStr <> edLogFilter.Text) then
    begin
      C.Log.FilterRecords(edLogFilter.Text, cbLogSources.Text, LT);
      lvLog.Items.Count := C.Log.FilteredCount;
    end
    else if lvLog.Items.Count <> C.Log.FilteredCount then
    begin
      lvLog.Items.Count := C.Log.FilteredCount;
    end;
  finally
    gdccServer.Connections.Unlock;
  end;
  if lvLog.Items.Count > 0 then
  begin
    lvLog.Items[lvLog.Items.Count - 1].Selected := True;
    lvLog.Items[lvLog.Items.Count - 1].MakeVisible(False);
  end;
  lvLog.Invalidate;
  UpdateLogSB;
  actSetLogFilter.ImageIndex := -1;
end;

procedure Tgdcc_frmMain.actSetLogFilterUpdate(Sender: TObject);
begin
  actSetLogFilter.Enabled := (FCurrentID > 0) and (pc.ActivePage = tsLog);
end;

procedure Tgdcc_frmMain.actClearLogFilterExecute(Sender: TObject);
begin
  edLogFilter.Text := '';
  cbLogSources.Text := '';
  chbxError.Checked := True;
  chbxWarning.Checked := True;
  chbxInfo.Checked := True;
  actSetLogFilter.Execute;
end;

procedure Tgdcc_frmMain.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if not FCanClose then
  begin
    Hide;
    CanClose := False;
  end;
end;

procedure Tgdcc_frmMain.lvLogSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  C: TgdccConnection;
begin
  UpdateLogSB;

  mLog.Lines.Clear;
  if (Item <> nil) and gdccServer.Connections.FindAndLock(FCurrentID, C) then
  try
    if Selected and (Item.Index < C.Log.FilteredCount) then
    begin
      mLog.Lines.Text :=
        FormatDateTime('dd.mm.yyyy hh:nn:ss', C.Log.FilteredLogRec[Item.Index].Logged) +
        #13#10#13#10 +
        C.Log.FilteredLogText[Item.Index];
    end;
  finally
    gdccServer.Connections.Unlock;
  end;
end;

procedure Tgdcc_frmMain.actSaveLogToFileExecute(Sender: TObject);
var
  C: TgdccConnection;
begin
  Assert(FSD = nil);
  FSD := TSaveDialog.Create(nil);
  try
    if pc.ActivePage = tsLog then
    begin
      FSD.Title := 'Сохранить лог в файл ';
      FSD.DefaultExt := 'txt';
      FSD.Filter := 'Текстовые файлы (*.txt)|*.txt|Файлы CSV (*.csv)|*.csv';
      FSD.FileName := 'log.txt';
      FSD.Options := [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofNoReadOnlyReturn, ofEnableSizing];
      if FSD.Execute and gdccServer.Connections.FindAndLock(FCurrentID, C) then
      try
        C.Log.SaveToFile(FSD.FileName);
      finally
        gdccServer.Connections.Unlock;
      end;
    end else
    begin
      FSD.Title := 'Сохранить данные о производительности в файл ';
      FSD.DefaultExt := 'csv';
      FSD.Filter := 'Файлы CSV (*.csv)|*.csv';
      FSD.FileName := 'profile.csv';
      FSD.Options := [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofNoReadOnlyReturn, ofEnableSizing];
      if FSD.Execute and gdccServer.Connections.FindAndLock(FCurrentID, C) then
      try
        C.Profiler.SaveToFile(FSD.FileName);
      finally
        gdccServer.Connections.Unlock;
      end;
    end;
  finally
    FreeAndNil(FSD);
  end;
end;

procedure Tgdcc_frmMain.UpdateProfilerSB;
var
  S: String;
  C: TgdccConnection;
begin
  if gdccServer.Connections.FindAndLock(FCurrentID, C) then
  try
    if C.Profiler.Count > 0 then
    begin
      if lvProfiler.Selected = nil then
        S := ''
      else
        S := FormatFloat('#,###', lvProfiler.Selected.Index + 1) + ' / ';

      if lvProfiler.Items.Count > 0 then
        S := S + FormatFloat('#,###', lvProfiler.Items.Count) + ' / ';

      sb.Panels[1].Text := S + FormatFloat('#,###', C.Profiler.Count);
    end else
      sb.Panels[1].Text := '';
  finally
    gdccServer.Connections.Unlock;
  end;
end;

procedure Tgdcc_frmMain.actSaveLogToFileUpdate(Sender: TObject);
begin
  actSaveLogToFile.Enabled := (FCurrentID > -1) and (FSD = nil);
end;

procedure Tgdcc_frmMain.actViewLogUpdate(Sender: TObject);
begin
  actViewLog.Checked := pc.ActivePage = tsLog;
end;

procedure Tgdcc_frmMain.actViewLogExecute(Sender: TObject);
begin
  pc.ActivePage := tsLog;
  actSetLogFilter.Execute;
end;

procedure Tgdcc_frmMain.actViewProfilerUpdate(Sender: TObject);
begin
  actViewProfiler.Checked := pc.ActivePage = tsProfiler;
end;

procedure Tgdcc_frmMain.actViewProfilerExecute(Sender: TObject);
begin
  pc.ActivePage := tsProfiler;
  actSetProfilerFilter.Execute;
end;

procedure Tgdcc_frmMain.actAutoUpdateExecute(Sender: TObject);
begin
  actAutoUpdate.Checked := not actAutoUpdate.Checked;
end;

procedure Tgdcc_frmMain.PrepareProfilerItem(LI: TListItem);

  function FormatTime(const T: Int64): String;
  begin
    if T < 100 then
      Result := '< 0.1 ms'
    else if T < 1000 then
      Result := '0.' + IntToStr(T) + ' ms'
    else if T < 100000 then
      Result := IntToStr(T div 1000) + ' ms'
    else if T < 100000000 then
      Result := FormatFloat('0.000', T / 1000000)
    else if T < 60 * 60 * Int64(1000000) then
      Result := FormatDateTime('nn:ss', T / 1000000 / 60 / 60 / 24)
    else
      Result := FormatDateTime('hh:nn:ss', T / 1000000 / 60 / 60 / 24);
  end;

var
  C: TgdccConnection;
  SP: TgdccProfilerObject;
begin
  if (LI <> nil) and gdccServer.Connections.FindAndLock(FCurrentID, C) then
  try
    if C.Profiler.GetByIndex(LI.Index, SP) then
    begin
      LI.Caption := SP.Src;
      LI.SubItems.Add(ShortenString(SP.Name));
      LI.SubItems.Add(FormatFloat('#,###', SP.Count));
      LI.SubItems.Add(FormatTime(SP.Avg));
      LI.SubItems.Add(FormatTime(SP.Max));
      LI.SubItems.Add(FormatTime(SP.Total));
    end;
  finally
    gdccServer.Connections.Unlock;
  end;
end;

procedure Tgdcc_frmMain.lvProfilerData(Sender: TObject; Item: TListItem);
begin
  PrepareProfilerItem(Item);
end;

procedure Tgdcc_frmMain.lvProfilerDataHint(Sender: TObject; StartIndex,
  EndIndex: Integer);
var
  I: Integer;
begin
  for I := StartIndex to EndIndex do
    PrepareProfilerItem(lvProfiler.Items[I]);
end;

procedure Tgdcc_frmMain.lvProfilerSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  C: TgdccConnection;
  SP: TgdccProfilerObject;
begin
  mProfiler.Lines.Clear;
  if (Item <> nil) and gdccServer.Connections.FindAndLock(FCurrentID, C) then
  try
    if C.Profiler.GetByIndex(Item.Index, SP) then
      mProfiler.Lines.Text := SP.Name;
  finally
    gdccServer.Connections.Unlock;
  end;
  UpdateProfilerSB;
end;

procedure Tgdcc_frmMain.lvProfilerColumnClick(Sender: TObject;
  Column: TListColumn);
var
  C: TgdccConnection;
  I: Integer;
begin
  lvProfiler.Items.BeginUpdate;
  try
    if gdccServer.Connections.FindAndLock(FCurrentID, C) then
    try
      case Column.Index of
        0: C.Profiler.SortBySrc(Column.Tag <> 0);
        1: C.Profiler.SortByName(Column.Tag <> 0);
        2: C.Profiler.SortByCount(Column.Tag <> 0);
        3: C.Profiler.SortByAvg(Column.Tag <> 0);
        4: C.Profiler.SortByMax(Column.Tag <> 0);
        5: C.Profiler.SortByTotal(Column.Tag <> 0);
      end;
    finally
      gdccServer.Connections.Unlock;
    end;

    if Column.Tag = 0 then
      Column.Tag := 1
    else
      Column.Tag := 0;

    for I := 0 to lvProfiler.Columns.Count - 1 do
      if I <> Column.Index then
        lvProfiler.Columns[I].Tag := 0;

    if lvProfiler.Items.Count > 0 then
    begin
      lvProfiler.Items[0].Selected := True;
      lvProfiler.Items[0].MakeVisible(False);
    end;
  finally
    lvProfiler.Items.EndUpdate;
  end;
end;

procedure Tgdcc_frmMain.lvProfilerResize(Sender: TObject);
begin
  lvProfiler.Columns[1].Width :=
    lvProfiler.Width -
    lvProfiler.Columns[0].Width -
    lvProfiler.Columns[2].Width -
    lvProfiler.Columns[3].Width -
    lvProfiler.Columns[4].Width -
    lvProfiler.Columns[5].Width - 22;
end;

procedure Tgdcc_frmMain.lvLogResize(Sender: TObject);
begin
  lvLog.Columns[2].Width :=
    lvLog.Width -
    lvLog.Columns[0].Width -
    lvLog.Columns[1].Width - 22;
end;

procedure Tgdcc_frmMain.actSetProfilerFilterExecute(Sender: TObject);
var
  C: TgdccConnection;
begin
  if gdccServer.Connections.FindAndLock(FCurrentID, C) then
  try
    lvProfiler.Items.Count := C.Profiler.Count;
  finally
    gdccServer.Connections.Unlock;
  end;

  lvProfiler.Invalidate;
  UpdateProfilerSB;
end;

procedure Tgdcc_frmMain.UpdateLogSB;
var
  S: String;
  C: TgdccConnection;
begin
  if gdccServer.Connections.FindAndLock(FCurrentID, C) then
  try
    if C.Log.Count > 0 then
    begin
      if lvLog.Selected = nil then
        S := ''
      else
        S := FormatFloat('#,###', lvLog.Selected.Index + 1) + ' / ';

      if lvLog.Items.Count > 0 then
        S := S + FormatFloat('#,###', lvLog.Items.Count) + ' / ';

      sb.Panels[1].Text := S + FormatFloat('#,###', C.Log.Count);
    end else
      sb.Panels[1].Text := '';
  finally
    gdccServer.Connections.Unlock;
  end;
end;

procedure Tgdcc_frmMain.sbResize(Sender: TObject);
begin
  sb.Panels[0].Width := Width - 150 - 80;
  sb.Panels[1].Width := 150;
  sb.Panels[2].Width := 80;
end;

procedure Tgdcc_frmMain.actClearLogFilterUpdate(Sender: TObject);
begin
  actClearLogFilter.Enabled := (FCurrentID > 0) and (pc.ActivePage = tsLog);
end;

procedure Tgdcc_frmMain.actClearProfilerFilterUpdate(Sender: TObject);
begin
  actClearProfilerFilter.Enabled := (FCurrentID > -1) and (pc.ActivePage = tsProfiler);
end;

procedure Tgdcc_frmMain.actClearProfilerFilterExecute(Sender: TObject);
begin
  edProfilerFilter.Text := '';
  cbProfilerSources.Text := '';
  actSetProfilerFilter.Execute;
end;

procedure Tgdcc_frmMain.actSetProfilerFilterUpdate(Sender: TObject);
begin
  actSetProfilerFilter.Enabled := (FCurrentID > -1) and (pc.ActivePage = tsProfiler);
end;

procedure Tgdcc_frmMain.actAboutExecute(Sender: TObject);
begin
  MessageBox(Handle,
    'GDCC -- Gedemin Control Center'#13#10 +
    'v2.9'#13#10#13#10 +
    'Copyright (c) 2016 by Golden Software of Belarus, Ltd'#13#10 +
    'All rights reserved.',
    'О программе',
    MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
end;

procedure Tgdcc_frmMain.gsTrayIconClick(Sender: TObject);
begin
  actShowOrHide.Execute;
end;

procedure Tgdcc_frmMain.WMQueryEndSession(var Message: TMessage);
begin
  FCanClose := True;
  inherited;
end;

procedure Tgdcc_frmMain.actClearProfilerDataExecute(Sender: TObject);
var
  C: TgdccConnection;
begin
  if gdccServer.Connections.FindAndLock(FCurrentID, C) then
  try
    C.Profiler.Clear;
  finally
    gdccServer.Connections.Unlock;
  end;

  actSetProfilerFilter.Execute;
end;

end.

