// ShlTanya, 17.02.2019

unit gsdbLookupComboBox_dlgDropDown;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, DBGrids, gsDBGrid, Db, IBCustomDataSet, ExtCtrls,
  ComCtrls, ToolWin, Buttons, ActnList, gsdbLookupComboBoxInterface,
  gsDBTreeView;

type
  TdbdlgDropDown = class(TForm)
    ibdsList: TIBDataSet;
    dsList: TDataSource;
    pnlMain: TPanel;
    pnlToolbar: TPanel;
    sbNew: TSpeedButton;
    sbEdit: TSpeedButton;
    sbDelete: TSpeedButton;
    sbMerge: TSpeedButton;
    ActionList: TActionList;
    actNew: TAction;
    actEdit: TAction;
    actDelete: TAction;
    actMerge: TAction;
    SpeedButton5: TSpeedButton;
    sbGrow: TSpeedButton;
    actShrink: TAction;
    actGrow: TAction;
    gsDBGrid: TgsDBGrid;
    tv: TgsDBTreeView;
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure actNewExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actMergeExecute(Sender: TObject);
    procedure actShrinkExecute(Sender: TObject);
    procedure actGrowExecute(Sender: TObject);
    procedure actShrinkUpdate(Sender: TObject);
    procedure actGrowUpdate(Sender: TObject);
    procedure gsDBGridDblClick(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actEditUpdate(Sender: TObject);
    procedure actNewUpdate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tvKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure gsDBGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tvClick(Sender: TObject);
    procedure gsDBGridCellClick(Column: TColumn);

  private
    FMouseFlag: Boolean;
    
    procedure WMGetDlgCode(var Message: TWMGetDlgCode);
      message WM_GETDLGCODE;
    procedure CMDialogKey(var Message: TCMDialogKey);
      message CM_DIALOGKEY;

  public
    FIBLookup: IgsDBLookupComboBox;
    FWasTabKey: Boolean;
    FLastKey: Word;

    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.DFM}

var
  gsCOMBOHOOK: HHOOK = 0;

function gsComboHookProc(nCode: Integer; wParam: Integer; lParam: Integer): LResult; stdcall;
var
  P: TPoint;
begin
  Result := CallNextHookEx(gsCOMBOHOOK, nCode, wParam, lParam);

  if nCode = HC_ACTION then
  begin
    with PMouseHookStruct(lParam)^ do
    begin
      case wParam of
        WM_LBUTTONDOWN, WM_NCLBUTTONDOWN, WM_LBUTTONUP:
        begin
          if (Screen.ActiveForm is TdbdlgDropDown)
            and (GetForegroundWindow = Screen.ActiveForm.Handle) then
          with (Screen.ActiveForm as TdbdlgDropDown) do
          begin
            P := ScreenToClient(pt);
            if (P.X < 0) or (P.X > Width) or
              (P.Y < 0) or (P.Y > Height) then
            begin
              ModalResult := mrCancel;
              Result := 1;
            end else
            begin
              //SendMessage(Handle, wParam, 0, MakeLParam(pt.X, pt.Y)); // was PostMessage
              Result := 0;
            end;
          end
        end;
      end;
    end;
  end;
end;

procedure TdbdlgDropDown.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  Message.Result := Message.Result or DLGC_WANTALLKEYS;
end;

destructor TdbdlgDropDown.Destroy;
begin
  if gsCOMBOHOOK <> 0 then
  begin
    UnhookWindowsHookEx(gsCOMBOHOOK);
    gsCOMBOHOOK := 0;
  end;
  inherited;
end;

constructor TdbdlgDropDown.Create(AnOwner: TComponent);
begin
  inherited;
  gsDbGrid.ShowTotals := False;
  FWasTabKey := False;
  FLastKey := 0;
end;

procedure TdbdlgDropDown.FormShow(Sender: TObject);
var
  R: TRect;
  Pt: TPoint;
begin
  if gsCOMBOHOOK = 0 then
    gsCOMBOHOOK := SetWindowsHookEx(WH_MOUSE, @gsComboHookProc, HINSTANCE, GetCurrentThreadID);
  FWasTabKey := False;
  FLastKey := 0;

  GetWindowRect(gsdbGrid.Handle, R);
  GetCursorPos(Pt);
  FMouseFlag := (((GetAsyncKeyState(VK_LBUTTON)) shr 1) = 0)
    or (not PtInRect(R, Pt));
end;

procedure TdbdlgDropDown.FormHide(Sender: TObject);
begin
  if gsCOMBOHOOK <> 0 then
  begin
    UnhookWindowsHookEx(gsCOMBOHOOK);
    gsCOMBOHOOK := 0;
  end;

  if FIBLookup <> nil then
    FIBLookup.DropDownDialogWidth := Width;
end;

procedure TdbdlgDropDown.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Pt: TPoint;
begin
  if GetCursorPos(Pt)
    and (FindVCLWindow(Pt) <> pnlToolbar)
    and (FindVCLWindow(Pt) <> tv) then
  begin
    ModalResult := mrOk;
  end;
end;

procedure TdbdlgDropDown.actNewExecute(Sender: TObject);
begin
  SendMessage(gsdbGrid.Handle,  WM_KEYDOWN, VK_F2, 0);
end;

procedure TdbdlgDropDown.actDeleteExecute(Sender: TObject);
begin
  SendMessage(gsdbGrid.Handle,  WM_KEYDOWN, VK_F8, 0);
end;

procedure TdbdlgDropDown.actMergeExecute(Sender: TObject);
begin
  { TODO : поскольку мы поменяли коомбинацию на ктрл-р, то мы не можем так просто передать нажатие клавиши. }
  //SendMessage(gsdbGrid.Handle,  WM_KEYDOWN, VK_F6, 0);
end;

procedure TdbdlgDropDown.actShrinkExecute(Sender: TObject);
var
  Pt: TPoint;
begin
  Width := Width - 20;
  if GetCursorPos(Pt) then SetCursorPos(Pt.X - 20, Pt.Y);
end;

procedure TdbdlgDropDown.actGrowExecute(Sender: TObject);
var
  Pt: TPoint;
begin
  Width := Width + 20;
  if GetCursorPos(Pt) then SetCursorPos(Pt.X + 20, Pt.Y);
end;

procedure TdbdlgDropDown.actShrinkUpdate(Sender: TObject);
begin
  actShrink.Enabled := Width > 100;
end;

procedure TdbdlgDropDown.actGrowUpdate(Sender: TObject);
begin
  actGrow.Enabled := Left + Width < Screen.Width - 20;
end;


procedure TdbdlgDropDown.gsDBGridDblClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

{procedure TdbdlgDropDown.gsDBGridMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ModalResult := mrOk;
end;}

procedure TdbdlgDropDown.CMDialogKey(var Message: TCMDialogKey);
begin
  inherited;
  if Message.CharCode = VK_TAB then
  begin
    FWasTabKey := True;
    ModalResult := mrOk;
  end;
end;

procedure TdbdlgDropDown.actEditExecute(Sender: TObject);
begin
  SendMessage(gsdbGrid.Handle,  WM_KEYDOWN, VK_F4, 0);
end;

procedure TdbdlgDropDown.actEditUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := ibdsList.RecordCount > 0;
end;

procedure TdbdlgDropDown.actNewUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := False;
end;

procedure TdbdlgDropDown.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key in [VK_RETURN, VK_TAB, VK_F4, {VK_F5, VK_F6,} VK_F8] then
    ModalResult := mrOk
  else if Key in [VK_ESCAPE, VK_F2, VK_F3, VK_F7] then
    ModalResult := mrCancel;
  if Key in [VK_F2, VK_F3, VK_F4, {VK_F5, VK_F6,} VK_F7, VK_F8] then
    FLastKey := Key
end;

procedure TdbdlgDropDown.tvKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key in [VK_RETURN, VK_TAB, VK_F4, {VK_F5, VK_F6,} VK_F8] then
    ModalResult := mrOk
  else if Key in [VK_ESCAPE, VK_F2, VK_F3, VK_F7] then
    ModalResult := mrCancel;
  if Key in [VK_F2, VK_F3, VK_F4, {VK_F5, VK_F6,} VK_F7, VK_F8] then
    FLastKey := Key
end;

procedure TdbdlgDropDown.gsDBGridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key in [VK_RETURN, VK_TAB, VK_F4, {VK_F5, VK_F6,} VK_F8] then
    ModalResult := mrOk
  else if Key in [VK_ESCAPE, VK_F2, VK_F3, VK_F7] then
    ModalResult := mrCancel;
  if Key in [VK_F2, VK_F3, VK_F4, {VK_F5, VK_F6,} VK_F7, VK_F8] then
    FLastKey := Key
end;

{procedure TdbdlgDropDown.tvMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if htOnItem in tv.GetHitTestInfoAt(X, Y)  then
    ModalResult := mrOk;
end;}

procedure TdbdlgDropDown.tvClick(Sender: TObject);
var
  P: TPoint;
begin
  P := tv.ScreenToClient(Mouse.CursorPos);

  if (htOnItem in tv.GetHitTestInfoAt(P.X, P.Y)) and (tv.Selected <> nil) then
    ModalResult := mrOk;
end;

procedure TdbdlgDropDown.gsDBGridCellClick(Column: TColumn);
begin
  if FMouseFlag then
    ModalResult := mrOk
  else
    FMouseFlag := True;
end;

end.
