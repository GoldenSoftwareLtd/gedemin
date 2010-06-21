unit prp_dfWatchList_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, prp_DOCKFORM_unit, obj_i_Debugger,
  ActnList, Menus, prp_dlgWatchProperties_unit, contnrs, prp_WatchList,
  TB2Item, ExtCtrls, gdvParamPanel;

type
  TdfWatchList = class(TDockableForm)
    lvWatchList: TListView;
    actEditWatch: TAction;
    actAddWatch: TAction;
    actDeleteWatch: TAction;
    actDisable: TAction;
    actEnable: TAction;
    actDeleteAll: TAction;
    actDisableAll: TAction;
    actEnableAll: TAction;
    N1: TMenuItem;
    N2: TMenuItem;
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
    procedure actAddWatchExecute(Sender: TObject);
    procedure actEditWatchExecute(Sender: TObject);
    procedure actDeleteWatchExecute(Sender: TObject);
    procedure actEnableUpdate(Sender: TObject);
    procedure actEnableExecute(Sender: TObject);
    procedure actDisableUpdate(Sender: TObject);
    procedure actDisableExecute(Sender: TObject);
    procedure actEditWatchUpdate(Sender: TObject);
    procedure actDeleteAllExecute(Sender: TObject);
    procedure actEnableAllExecute(Sender: TObject);
    procedure actDisableAllExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lvWatchListCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure lvWatchListDblClick(Sender: TObject);
  private
    { Private declarations }
    function AddListItem(Caption: String): TListItem;
    procedure DeleteItem(LI: TListItem);
    procedure SetWatchesEnable(Value: Boolean);
  protected
    procedure VisibleChanging; override;
  public
    { Public declarations }
    procedure UpdateWatchList(ForceUpdate: Boolean = False);
  end;

var
  dfWatchList: TdfWatchList;

implementation
uses prp_frmGedeminProperty_Unit, prp_BaseFrame_unit;
{$R *.DFM}


{ TdfWatchList }

function TdfWatchList.AddListItem(Caption: String): TListItem;
begin
  Result := lvWatchList.Items.Add;
  Result.Caption := Caption;
end;

procedure TdfWatchList.DeleteItem(LI: TListItem);
begin
  if LI <> nil then
  begin
    WatchList.Delete(Li.Index);
    LI.Delete;
  end;
end;

procedure TdfWatchList.UpdateWatchList(ForceUpdate: Boolean = False);
var
  I: Integer;
  Str: string;
begin
  if (Debugger <> nil) and (ForceUpdate or FormVisible) then
  begin
    lvWatchList.Items.BeginUpdate;
    try
      lvWatchList.Items.Clear;
      CheckWatchList;
      for I := 0 to WatchList.Count - 1 do
      begin
        if WatchList[I].Enabled then
        begin
          if (Debugger <> nil) and Debugger.IsPaused then
            Str := Debugger.Eval(WatchList[I].Name, WatchList[I].AllowFunctionCall)
          else
            Str := '[process not accessible]';
        end else
          Str := '<disabled>';
        Str := WatchList[I].Name + ': ' + Str;
        AddListItem(Str);
      end;
    finally
      lvWatchList.Items.EndUpdate;
    end;
  end;
end;

procedure TdfWatchList.actAddWatchExecute(Sender: TObject);
var
  F: TdlgWatchProperties;
  W: TWatch;
begin
  CheckWatchList;
  F := TdlgWatchProperties.Create(Application);
  try
    W := TWatch.Create;
    try
      if TfrmGedeminProperty(DockForm).ActiveFrame <> nil then
      begin
        W.Name := TBaseFrame(TfrmGedeminProperty(DockForm).ActiveFrame).GetSelectedText;
        if W.Name = '' then
          W.Name := TBaseFrame(TfrmGedeminProperty(DockForm).ActiveFrame).GetCurrentWord;
      end;
      F.Watch := W;
      if F.ShowModal = mrOk then
      begin
        W.Assign(F.Watch);
        WatchList.Add(W);
        UpdateWatchList(True);
      end else
        W.Free;
    except
      W.Free;
    end;
  finally
    F.Free;
  end;
end;

procedure TdfWatchList.actEditWatchExecute(Sender: TObject);
var
  F: TdlgWatchProperties;
begin
  if lvWatchList.Selected <> nil then
  begin
    F := TdlgWatchProperties.Create(Application);
    try
      F.Watch := WatchList[lvWatchList.Selected.Index];
      if F.ShowModal = mrOk then
      begin
        WatchList[lvWatchList.Selected.Index].Assign(F.Watch);
        UpdateWatchList(True);
      end;
    finally
      F.Free;
    end;
  end;
end;

procedure TdfWatchList.actDeleteWatchExecute(Sender: TObject);
begin
  if lvWatchList.Selected <> nil then
  begin
    DeleteItem(lvWatchList.Selected);
    UpdateWatchList(True);
  end;
end;
procedure TdfWatchList.actEnableUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (lvWatchList.Selected <> nil) and
    not (WatchList[lvWatchList.Selected.Index].Enabled);
end;

procedure TdfWatchList.actEnableExecute(Sender: TObject);
begin
  if lvWatchList.Selected <> nil then
  begin
    WatchList[lvWatchList.Selected.Index].Enabled := True;
    UpdateWatchList(True);
  end;
end;

procedure TdfWatchList.actDisableUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (lvWatchList.Selected <> nil) and
    (WatchList[lvWatchList.Selected.Index].Enabled);
end;

procedure TdfWatchList.actDisableExecute(Sender: TObject);
begin
  if lvWatchList.Selected <> nil then
  begin
    WatchList[lvWatchList.Selected.Index].Enabled := False;
    UpdateWatchList(True);
  end;
end;

procedure TdfWatchList.actEditWatchUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := lvWatchList.Selected <> nil;
end;

procedure TdfWatchList.actDeleteAllExecute(Sender: TObject);
begin
  CheckWatchList;
  WatchList.Clear;
  UpdateWatchList(True);
end;

procedure TdfWatchList.actEnableAllExecute(Sender: TObject);
begin
  SetWatchesEnable(True);
  
end;

procedure TdfWatchList.actDisableAllExecute(Sender: TObject);
begin
  SetWatchesEnable(False);
end;

procedure TdfWatchList.SetWatchesEnable(Value: Boolean);
var
  I: Integer;
begin
  CheckWatchList;
  for I := 0 to WatchList.Count - 1 do
    WatchList[I].Enabled := Value;
  UpdateWatchList(True);
end;

procedure TdfWatchList.FormDestroy(Sender: TObject);
begin
  SaveAndDestroyWatchList;
  
  inherited;
end;

procedure TdfWatchList.lvWatchListCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if not WatchList[Item.Index].Enabled then
    Sender.Canvas.Font.Color := clGrayText;
end;

procedure TdfWatchList.lvWatchListDblClick(Sender: TObject);
begin
  if lvWatchList.Selected <> nil then
    actEditWatch.Execute;
end;

procedure TdfWatchList.VisibleChanging;
begin
  inherited;
  if not Visible then
    UpdateWatchList(True);
end;

end.

