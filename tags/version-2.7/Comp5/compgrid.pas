unit CompGrid;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids, DB, DBGrids, ExList, mmDBGrid;

type

  TxCompDBGrid = class(TmmDBGrid)
  private
    { Private declarations }
    ListEdit: TExList;
    FCurrentControl: TWinControl;
    FCurrentNum: Integer;
    FViewOtherEdit: Boolean;
    FCancelPress: Boolean;
    FOnSetEdit: TNotifyEvent;

    function SearchField(aNameField: String): TWinControl;
    function ShowOtherEditor: Boolean;
    procedure MakeOnExit(Sender: TObject);
    procedure MakeOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure WMChar(var Message: TWMChar);
      message WM_CHAR;
    procedure CMExit(var Message: TMessage);
      message CM_EXIT;
  protected
    { Protected declarations }
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      override;
  public
    { Public declarations }
    constructor Create(aOwner: TComponent);
      override;
    procedure AddEditControl(aNameField: string; aControl: TWinControl;
       var ControlOnExit: TNotifyEvent; var ControlOnKeyDown: TKeyEvent);
    property ViewOtherEdit: Boolean read FViewOtherEdit;
    property CancelPress: Boolean read FCancelPress;
  published
    destructor Destroy; override;
    { Published declarations }
    property OnSetEdit: TNotifyEvent read FOnSetEdit write FOnSetEdit;
  end;

implementation

type
  TEditInfo = class
    NameField: String;
    Component: TWinControl;
    OldControlExit: TNotifyEvent;
    OldControlKeyDown: TKeyEvent;
    constructor Create(aNameField: string; aComponent: TWinControl;
      ControlOnExit: TNotifyEvent; ControlOnKeyDown: TKeyEvent);
  end;

{ TEditInfo --------------------------------------------------------- }

constructor TEditInfo.Create(aNameField: string; aComponent: TWinControl;
      ControlOnExit: TNotifyEvent; ControlOnKeyDown: TKeyEvent);
begin
  NameField:= aNameField;
  Component:= aComponent;
  OldControlExit:= ControlOnExit;
  OldControlKeyDown:= ControlOnKeyDown;
end;

{ TxCompDBGrid ------------------------------------------------------ }

{ public part }

constructor TxCompDBGrid.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  ListEdit:= TExList.Create;
  FCurrentControl:= nil;
  FCurrentNum:= -1;
  FCancelPress:= False;
end;

procedure TxCompDBGrid.AddEditControl(aNameField: string; aControl: TWinControl;
       var ControlOnExit: TNotifyEvent; var ControlOnKeyDown: TKeyEvent);
begin
  ListEdit.Add(TEditInfo.Create(aNameField, aControl, ControlOnExit, ControlOnKeyDown));
  ControlOnExit:= MakeOnExit;
  ControlOnKeyDown:= MakeOnKeyDown;
end;

{ protected part }

destructor TxCompDBGrid.Destroy;
begin
  ListEdit.Free;
  ListEdit:= nil;
  inherited Destroy;
end;

procedure TxCompDBGrid.Notification(AComponent: TComponent; Operation: TOperation);

function SearchComponent: Integer;
var
  i: Integer;
begin
  Result:= -1;
  for i:= 0 to ListEdit.Count - 1 do begin
    if TEditInfo(ListEdit[i]).Component = AComponent then
    begin
      Result:= i;
      Break;
    end;
  end;
end;

var
  Nom: Integer;

begin
  inherited Notification(aComponent, Operation);
  if (Operation = opRemove) and (ListEdit <> nil) then begin
    Nom:= SearchComponent;
    if Nom <> -1 then
      ListEdit.DeleteAndFree(Nom);
  end;
end;

procedure TxCompDBGrid.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  R: TGridCoord;
begin
  if dgEditing in Options then begin
    R:= MouseCoord(X, Y);
    if (R.Y = Row) and (R.X = Col) and
       (SearchField(Fields[R.X - Integer(dgIndicator in Options)].FieldName) <> nil) then
      ShowOtherEditor
    else
      inherited MouseDown(Button, Shift, X, Y);
  end
  else
    inherited MouseDown(Button, Shift, X, Y);
end;

{ private part }

function TxCompDBGrid.SearchField(aNameField: String): TWinControl;
var
  i: Integer;
begin
  Result:= nil;
  for i:= 0 to ListEdit.Count - 1 do
    if CompareText(TEditInfo(ListEdit[i]).NameField, aNameField) = 0 then begin
      Result:= TEditInfo(ListEdit[i]).Component;
      FCurrentNum:= i;
      Break;
    end;
end;

function TxCompDBGrid.ShowOtherEditor: Boolean;
var
  R: TRect;
begin
  FCancelPress:= False;
  Result:= false;
  FCurrentControl:= SearchField(Fields[Col - Integer(dgIndicator in Options)].FieldName);
  if FCurrentControl <> nil then begin
    if Assigned(FOnSetEdit) then FOnSetEdit(Self);
    FViewOtherEdit:= true;
    FCurrentControl.Visible:= true;
    R:= CellRect(Col, Row);
    MapWindowPoints(HANDLE, FCurrentControl.Parent.HANDLE, R, 2);
    if HiByte(LoWord(GetVersion)) > 11 then
      FCurrentControl.SetBounds(R.left, R.top, R.right - R.left, R.bottom - R.top)
    else
      FCurrentControl.SetBounds(R.left, R.top, R.right - R.left, FCurrentControl.Height);
    FCurrentControl.BringToFront;
    FCurrentControl.SetFocus;
    Result:= true;
  end;
end;

procedure TxCompDBGrid.MakeOnExit(Sender: TObject);
begin
  if FCurrentControl <> nil then begin
    if Assigned(TEditInfo(ListEdit[FCurrentNum]).OldControlExit) then
      TEditInfo(ListEdit[FCurrentNum]).OldControlExit(Sender);
    FCurrentControl.SendToBack;
    FViewOtherEdit:= false;
    if GetParentForm(Self).Enabled and GetParentForm(Self).Visible then
      SetFocus;
  end;
end;

procedure TxCompDBGrid.MakeOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if FCurrentControl <> nil then begin
    if Assigned(TEditInfo(ListEdit[FCurrentNum]).OldControlKeyDown) then
      TEditInfo(ListEdit[FCurrentNum]).OldControlKeyDown(Sender, Key, Shift);
    if (Key = vk_Escape) or (Key = vk_Return) then begin
      if (Key = vk_Escape) and (DataSource.State in [dsEdit, dsInsert]) then begin
        DataSource.DataSet.Cancel;
        FCancelPress:= True;
      end;
      FCurrentControl.SendToBack;
      SetFocus;
      try
        DataSource.DataSet.Refresh;
      except
      end; 
    end;
  end;
end;

procedure TxCompDBGrid.WMChar(var Message: TWMChar);
begin
  if not ShowOtherEditor then
    inherited
  else begin
    SendMessage(FCurrentControl.HANDLE, wm_Char, Message.CharCode, Message.KeyData);
  end;
end;

procedure TxCompDBGrid.CMExit(var Message: TMessage);
begin
  if not FViewOtherEdit then
    inherited;
end;

end.
