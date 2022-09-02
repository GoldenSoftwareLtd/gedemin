// ShlTanya, 20.02.2019

unit prpDBComboBox;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBCtrls, prpDBComboBox_dlgDropDown;

type
  TOnNewRecord = procedure (Sender: TObject) of object;
  TOnSelChange = procedure (Sender: TObject) of object;

  TprpDBComboBox = class(TDBComboBox)
  private
    FOnNewRecord: TOnNewRecord;
    FOnSelChange: TOnSelChange;
    FOnSetFocus: TNotifyEvent;
    FOnDeleteRecord: TNotifyEvent;
    FOnUpdateRecord: TNotifyEvent;
    procedure SetOnNewRecord(const Value: TOnNewRecord);
    procedure SetOnSelChange(const Value: TOnSelChange);
    procedure SetOnSetFocus(const Value: TNotifyEvent);
    procedure SetOnDeleteRecord(const Value: TNotifyEvent);
    { Private declarations }
    procedure SetupDropDownDialog;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
    procedure SetOnUpdateRecord(const Value: TNotifyEvent);
  protected
    { Protected declarations }
    FDropDown: TprpDropDown;
    FDropDownDialogWidth: Integer;
    procedure WndProc(var Message: TMessage); override;
    procedure DoSelChange;
    procedure DoSetFocus;
    procedure DoNewRecord;
    procedure DoDeleteRecord;

    procedure DropDown; override;
    procedure ShowDropDownDialog;
    procedure AssignDropDownDialogSize;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property OnNewRecord: TOnNewRecord read FOnNewRecord write SetOnNewRecord;
    property OnSelChange: TOnSelChange read FOnSelChange write SetOnSelChange;
    property OnSetFocus: TNotifyEvent read FOnSetFocus write SetOnSetFocus;
    property OnDeleteRecord: TNotifyEvent read FOnDeleteRecord write SetOnDeleteRecord;
    property OnUpdateRecord: TNotifyEvent read FOnUpdateRecord write SetOnUpdateRecord;
  end;

procedure Register;

implementation
uses Math;

procedure Register;
begin
  RegisterComponents('Data Controls', [TprpDBComboBox]);
end;

{ TprpDBComboBox }

procedure TprpDBComboBox.AssignDropDownDialogSize;
var
  Hg, Rc: Integer;
begin
  if Assigned(Parent) and (Parent is TControl) then
  begin
    FDropDown.Left := (Parent as TControl).ClientToScreen(Point(Left, Top + Height)).X;
    FDropDown.Top := (Parent as TControl).ClientToScreen(Point(Left, Top + Height)).Y;
  end;
  if FDropDownDialogWidth = -1 then FDropDown.Width := Width - 1;
  if Items.Count > DropDownCount then
    Rc := DropDownCount
  else
    Rc := Max(Items.Count, 1);

  Hg := Rc * FDropDown.lbItems.ItemHeight  + 18;
  if Hg + FDropDown.Top + 28 > Screen.Height then
    FDropDown.Height := Screen.Height - FDropDown.Top - 28
  else
    FDropDown.ClientHeight := Hg;
end;

procedure TprpDBComboBox.CMExit(var Message: TCMExit);
begin
  if Assigned(FOnUpDateRecord) then
    FOnUpdateRecord(Self);
  inherited;
end;

constructor TprpDBComboBox.Create(AOwner: TComponent);
begin
  inherited;
  FDropDownDialogWidth := - 1;
  Hint := 'Используйте клавиши: '#13#10 +
          '  F1 -- вызов справки '#13#10 +
          '  F2 -- создание нового объекта '#13#10 +
          '  F8 -- удаление выбранного объекта ';
  ShowHint := True;        
end;

destructor TprpDBComboBox.Destroy;
begin
  FDropDown.Free;
  inherited;
end;

procedure TprpDBComboBox.DoDeleteRecord;
begin
  if Assigned(FOnDeleterecord) then
    FOnDeleteRecord(Self);
end;

procedure TprpDBComboBox.DoNewRecord;
begin
  ItemIndex := -1;
  if Assigned(FOnNewRecord) then
    FOnNewRecord(Self);
end;

procedure TprpDBComboBox.DoSelChange;
begin
  if Assigned(FOnSelChange) then
    FOnSelChange(Self);
end;

procedure TprpDBComboBox.DoSetFocus;
begin
  if Assigned(FOnSetFocus) then
    FOnSetFocus(Self);
end;

procedure TprpDBComboBox.DropDown;
begin
  inherited;
  ShowDropDownDialog;
  Abort;
end;


procedure TprpDBComboBox.KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_F2:
      begin
        DoNewRecord;
        Key := 0;
      end;
    VK_F8:
      begin
        DoDeleteRecord;
        Key := 0;
      end;
    else
     inherited ;
  end;
end;

procedure TprpDBComboBox.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if Operation = opRemove then
    if AComponent = FDropDown then FDropDown := nil;
end;

procedure TprpDBComboBox.SetOnDeleteRecord(const Value: TNotifyEvent);
begin
  FOnDeleteRecord := Value;
end;

procedure TprpDBComboBox.SetOnNewRecord(const Value: TOnNewRecord);
begin
  FOnNewRecord := Value;
end;

procedure TprpDBComboBox.SetOnSelChange(const Value: TOnSelChange);
begin
  FOnSelChange := Value;
end;

procedure TprpDBComboBox.SetOnSetFocus(const Value: TNotifyEvent);
begin
  FOnSetFocus := Value;
end;

procedure TprpDBComboBox.SetOnUpdateRecord(const Value: TNotifyEvent);
begin
  FOnUpdateRecord := Value;
end;

procedure TprpDBComboBox.SetupDropDownDialog;
var
  I: Integer;
begin
  if FDropDown = nil then
  begin
    FDropDown := TprpDropDown.Create(Self);
    FDropDown.ComboBox := Self;
  end;
  with FDropdown do
  begin
    lbItems.Clear;
    for I := 0 to Items.Count - 1 do
    begin
      lbItems.Items.Add(Items[I]);
      if Text = Items[I] then
        lbItems.ItemIndex := I;
    end;
    actNew.Enabled := Assigned(FOnNewRecord);
    actdelete.Enabled := Assigned(FOnDeleteRecord);
  end;
end;

procedure TprpDBComboBox.ShowDropDownDialog;
begin
  SetupDropDownDialog;
  AssignDropDownDialogSize;
  if FDropDown.ShowModal = mrOk then
  begin
    ItemIndex := FDropDown.lbItems.ItemIndex;
    SendMessage(Self.Handle, WM_COMMAND, CBN_SELCHANGE shl 16, 0);
  end;
  PostMessage(Handle, CB_SHOWDROPDOWN, 0, 0);
  FDropDownDialogWidth := FDropDown.Width;
  Repaint;
end;

procedure TprpDBComboBox.WndProc(var Message: TMessage);
begin
  if not (csDesigning in ComponentState) then
    if Message.Msg = WM_COMMAND then
      if TWMCommand(Message).NotifyCode = CBN_SELCHANGE then
      begin
        DoSelChange
      end else
        if TWMCommand(Message).NotifyCode = EN_SETFOCUS then
          DoSetFocus;

  inherited WndProc(Message);
end;

end.
