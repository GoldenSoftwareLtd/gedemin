// ShlTanya, 25.02.2019, #4135

unit prp_dfMessages_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, prp_Messages, ActnList, Menus, prp_DOCKFORM_unit, contnrs,
  ExtCtrls, gd_i_ScriptFactory, IBSQL;

type
  TdfMessages = class(TDockableForm)
    lvMessages: TListView;
    actDelete: TAction;
    actClearErrorMessages: TAction;
    N1: TMenuItem;
    N2: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    actClearCompileMessages: TAction;
    procedure lvMessagesCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure lvMessagesDeletion(Sender: TObject; Item: TListItem);
    procedure lvMessagesExit(Sender: TObject);
    procedure actDeleteUpdate(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actClearErrorMessagesExecute(Sender: TObject);
    procedure lvMessagesDblClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lvMessagesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure pmMainPopup(Sender: TObject);
    procedure actClearCompileMessagesExecute(Sender: TObject);
    procedure lvMessagesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FSelListItem: TListItem;
    FRefMenuItem: TMenuItem;

    function AddErrorListItem(
      const ErrorItem: TgdErrorItem): TListItem;
//       Line: Integer; Caption: String; SFID: Integer): TListItem;
//    function CheckDestroing: Boolean;
    function ErrorCount: Integer;
    procedure DeleteSelectItem;
    procedure DeleteItem(LI: TListItem);
    procedure OpenSF(Sender: TObject);
    procedure UpdateVisible;
  public
    { Public declarations }
    procedure UpdateErrors;
    procedure ClearErrorResults;
    procedure ClearCompileResult;
    procedure GotoLastError;
    procedure SetErrorMessages(const ErrorList: TObjectList);
  end;

var
  dfMessages: TdfMessages;

implementation

uses
  obj_i_Debugger, prp_frmGedeminProperty_Unit, gdcBaseInterface;

const
  dfErrMessage = '%s (строка: %d)';

{$R *.DFM}

{ TdfMessages }

function TdfMessages.AddErrorListItem(const ErrorItem: TgdErrorItem): TListItem;
//Line: Integer;
//  Caption: String; SFID: Integer): TListItem;
var
  LI: TListItem;
  EM: TCustomMessageItem;
begin
  Result := nil;
  if ErrorItem.InheritsFrom(TgdCompileItem) or
    (not Assigned(Debugger) or (ErrorCount = 0)) then
  begin
    LI := lvMessages.Items.Add;
    if ErrorItem.InheritsFrom(TgdCompileItem) then
    begin
      EM := TCompileMessageItem.Create;
      TCompileMessageItem(EM).ReferenceToSF :=
        TgdCompileItem(ErrorItem).ReferenceToSF;
      TCompileMessageItem(EM).AutoClear :=
        TgdCompileItem(ErrorItem).AutoClear;
    end else
      EM := TErrorMessageItem.Create;
    LI.Data := EM;
//    EM.Message := Caption;
    EM.Node := nil;
    with ErrorItem do
    begin
      EM.Line := Line;
      EM.FunctionKey := SFID;
      LI.Caption := Format(dfErrMessage, [Msg, Line]);
    end;
    if not Visible then Visible := True;
    LI.MakeVisible(False);
    Result := LI;
  end;
end;

{function TdfMessages.CheckDestroing: Boolean;
begin
  Result := Application.Terminated or (csDestroying in ComponentState);
end;}

procedure TdfMessages.ClearErrorResults;
var
  I: Integer;
begin
  CheckHandle(Self);
  for I := lvMessages.Items.Count - 1 downto 0 do
  begin
    if Assigned(lvMessages.Items[I].Data) and
      ((TObject(lvMessages.Items[I].Data) is TErrorMessageItem) or
       ((TObject(lvMessages.Items[I].Data) is TCompileMessageItem) and
         TCompileMessageItem(lvMessages.Items[I].Data).AutoClear)) then
    begin
      DeleteItem(lvMessages.Items[I]);
    end;
  end;
  if lvMessages.Items.Count = 0 then Hide;
end;

procedure TdfMessages.GotoLastError;
var
  I: Integer;
begin
  CheckHandle(Self);
  for I := lvMessages.Items.Count - 1 downto 0 do
  begin
    if Assigned(lvMessages.Items[I].Data) and
      (TObject(lvMessages.Items[I].Data) is TErrorMessageItem) then
    begin
      lvMessages.Items[I].Selected := True;
      lvMessages.Items[I].MakeVisible(False);
      lvMessagesDblClick(lvMessages);
      Show;
      Break;
    end;
  end;
end;

procedure TdfMessages.UpdateErrors;
var
  I: Integer;
begin
  CheckHandle(Self);
  if Assigned(ScriptFactory) then
  begin
    ClearErrorResults;
    if ScriptFactory.GetErrorList.count >0 then
    begin
      if Assigned(Debugger) then
      begin
        AddErrorListItem(ScriptFactory.GetErrorList[0]);
{        AddErrorListItem(ScriptFactory.GetErrorList[0].Line,
          ScriptFactory.GeterrorList[0].Msg + '(строка: ' +
          IntToStr(ScriptFactory.GetErrorList[0].Line) + ')',
          ScriptFactory.GetErrorList[0].SFID);}
      end else
      for I := 0 to ScriptFactory.GetErrorList.count - 1 do
      begin
        AddErrorListItem(ScriptFactory.GetErrorList[I]);
{        AddErrorListItem(ScriptFactory.GetErrorList[I].Line,
          ScriptFactory.GeterrorList[I].Msg + '(строка: ' +
          IntToStr(ScriptFactory.GeterrorList[I].Line) + ')',
          ScriptFactory.GetErrorList[0].SFID);}
      end;
    end;
    if ErrorCount > 0 then
      GotoLastError
    else
      UpdateVisible;
  end;
end;

procedure TdfMessages.lvMessagesCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
var
  Str1, Str2: String;
  P: Integer;
  Rect: TRect;
begin
  if Assigned(Item.Data) and (TObject(Item.Data) is TCustomMessageItem) then
  begin
    Str1 := Item.Caption;
    P := System.Pos(#9, Str1);
    Sender.Canvas.Lock;
    try
//      if (cdsFocused in State) or (cdsMarked in State) then
      if FSelListItem = Item then
      begin
        Sender.Canvas.Font.Color := clHighlightText;
        Sender.Canvas.Brush.Color := clHighlight;
      end else
      begin
        Sender.Canvas.Font.Color :=  clWindowText;
        Sender.Canvas.Brush.Color := clWindow;
      end;

      Rect := Sender.ClientRect;
      Rect.Top := Item.Top;
      Rect.Bottom := Rect.Top + Sender.Canvas.TextHeight(Str1);
      { TODO :
      Непонятно почему но изменения свойств шрифта не действуют
      после функций TextOut, TextHeight }
      Sender.Canvas.FillRect(Rect);

      Sender.Canvas.MoveTo(Item.Left, Item.Top);
      while P > 0 do
      begin
      //if P > 0 then
      //begin
        Sender.Canvas.Font.Style := [fsBold];
        Str2 :=  System.Copy(Str1, 1, P - 1);
        Sender.Canvas.TextOut(Sender.Canvas.PenPos.X, Sender.Canvas.PenPos.Y, Str2);
        System.Delete(Str1, 1, P);
        P := System.Pos(#9, Str1);
        Str2 := System.Copy(Str1, 1, P - 1);
        Sender.Canvas.Font.Style := [fsBold];
        //Это необходимо чтобы изменения шрифра вступили в силу
        SelectObject(Sender.Canvas.Handle,  Sender.Canvas.Font.Handle);
        Sender.Canvas.TextOut(Sender.Canvas.PenPos.X, Sender.Canvas.PenPos.Y, Str2);
        Sender.Canvas.Font.Style := [];
        //Это необходимо чтобы изменения шрифра вступили в силу
        SelectObject(Sender.Canvas.Handle,  Sender.Canvas.Font.Handle);
        System.Delete(Str1, 1, P);
        P := System.Pos(#9, Str1);
      end;
        //Sender.Canvas.TextOut(Sender.Canvas.PenPos.X, Sender.Canvas.PenPos.Y, Str1);
      //end else
        Sender.Canvas.TextOut(Sender.Canvas.PenPos.X, Sender.Canvas.PenPos.Y, Str1);
      DefaultDraw := False;
    finally
      Sender.Canvas.Unlock;
    end;
  end else
    DefaultDraw := True;
end;

procedure TdfMessages.lvMessagesDeletion(Sender: TObject; Item: TListItem);
begin
//  if Assigned(Item) and Assigned(Item.Data) and not (csDocking in ControlState) then
//    TObject(Item.Data).Free;
end;

procedure TdfMessages.lvMessagesExit(Sender: TObject);
begin
  lvMessages.Selected := nil;
end;

function TdfMessages.ErrorCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for i := 0 to lvMessages.Items.Count -1 do
  begin
    if Assigned(lvMessages.Items[I].Data) and
      (TObject(lvMessages.Items[I].Data) is TErrorMessageItem) then
      Inc(Result);
  end;
end;

procedure TdfMessages.UpdateVisible;
begin
  if not Visible then
    Visible := lvMessages.Items.Count > 0
  else
    Visible := (ErrorCount = 0) and (lvMessages.Items.Count > 0)
end;

procedure TdfMessages.DeleteSelectItem;
begin
  if Assigned(lvMessages.Selected) then
  begin
    DeleteItem(lvMessages.Selected);
  end;
end;

procedure TdfMessages.actDeleteUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := lvMessages.Selected <> nil;
end;

procedure TdfMessages.actDeleteExecute(Sender: TObject);
begin
  DeleteSelectItem;
end;

procedure TdfMessages.actClearErrorMessagesExecute(Sender: TObject);
begin
  ClearErrorResults;
end;

procedure TdfMessages.lvMessagesDblClick(Sender: TObject);
begin
  if Assigned(lvMessages.Selected) and Assigned(lvMessages.Selected.Data) then
  begin
    case TCustomMessageItem(lvMessages.Selected.Data).MsgType of
      mtError, mtCompile:
        TfrmGedeminProperty(DockForm).FindAndEdit(
          TCustomMessageItem(lvMessages.Selected.Data).FunctionKey,
          TCustomMessageItem(lvMessages.Selected.Data).Line, 0,
          True);
    end;
  end;
end;

procedure TdfMessages.DeleteItem(LI: TListItem);
begin
  if LI <> nil then
  begin
    if LI.Data <> nil then TCustomMessageItem(LI.Data).Free;
    if FSelListItem = LI then FSelListItem := nil;
    LI.Delete;
  end;
end;

procedure TdfMessages.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  for I := lvMessages.Items.Count - 1 downto 0 do
    DeleteItem(lvMessages.Items[I]);
  inherited;
end;

procedure TdfMessages.FormCreate(Sender: TObject);
begin
  inherited;
  FSelListItem := nil;
  FRefMenuItem := nil;
end;

procedure TdfMessages.lvMessagesSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  inherited;
  FSelListItem := Item;
end;

procedure TdfMessages.SetErrorMessages(const ErrorList: TObjectList);
var
  I: Integer;
begin
  CheckHandle(Self);
  for I := 0 to ErrorList.count - 1 do
  begin
//    with TgdErrorItem(ErrorList[I]) do
    if ErrorList[I].InheritsFrom(TgdErrorItem) then
      AddErrorListItem(TgdErrorItem(ErrorList[I]));
//      AddErrorListItem(Line, Msg + '(строка: ' + IntToStr(Line) + ')', SFID);
  end;
  if ErrorCount > 0 then GotoLastError else UpdateVisible;
end;

procedure TdfMessages.ClearCompileResult;
var
  I: Integer;
begin
  CheckHandle(Self);
  for I := lvMessages.Items.Count - 1 downto 0 do
  begin
    if Assigned(lvMessages.Items[I].Data) and
      (TObject(lvMessages.Items[I].Data) is TCompileMessageItem) then
    begin
      DeleteItem(lvMessages.Items[I]);
    end;
  end;
  if lvMessages.Items.Count = 0 then Hide;
end;

procedure TdfMessages.pmMainPopup(Sender: TObject);
var
  ListItem: TListItem;
  LMenuItem: TMenuItem;
  I: Integer;
begin
  lvMessages.Refresh;
  ListItem := lvMessages.Selected;
  if ListItem <> nil then
  try
    if TObject(ListItem.Data).InheritsFrom(TCompileMessageItem) then
    begin
      if FRefMenuItem = nil then
      begin
        LMenuItem := TMenuItem.Create(pmMain);
        LMenuItem.Caption := '-';
        pmMain.Items.Insert(0, LMenuItem);

        FRefMenuItem := TMenuItem.Create(pmMain);
        FRefMenuItem.OnClick := OpenSF;
        pmMain.Items.Insert(0, FRefMenuItem);
      end;

      FRefMenuItem.Tag := TID2Tag(TCompileMessageItem(ListItem.Data).ReferenceToSF, Name);
      FRefMenuItem.Caption := 'Открыть СФ №' +
        TID2S(TCompileMessageItem(ListItem.Data).ReferenceToSF);
    end else
      begin
        if FRefMenuItem <> nil then
        begin
          I := pmMain.Items.IndexOf(FRefMenuItem);
          Inc(I);
          if (pmMain.Items.Count > I) and (pmMain.Items[I].Caption = '-') then
            pmMain.Items.Delete(I);
          pmMain.Items.Remove(FRefMenuItem);
          FRefMenuItem := nil;
        end;
      end;
  except
  end;
end;

procedure TdfMessages.OpenSF(Sender: TObject);
begin
  if (Sender = FRefMenuItem) and (GetTID(TMenuItem(Sender).Tag, Name) > 0) then
  begin
    TfrmGedeminProperty(DockForm).FindAndEdit(
      GetTID(TMenuItem(Sender).Tag, Name), 0, 0, False);
  end;
end;

procedure TdfMessages.actClearCompileMessagesExecute(Sender: TObject);
begin
  ClearCompileResult;
end;

procedure TdfMessages.lvMessagesKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;

  if Key = VK_RETURN then
    lvMessagesDblClick(Self);
end;

end.
