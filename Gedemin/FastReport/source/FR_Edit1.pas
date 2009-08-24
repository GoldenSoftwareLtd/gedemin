
{******************************************}
{                                          }
{             FastReport v2.53             }
{   Memo editor without syntax highlight   }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_Edit1;

interface

{$I FR.inc}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, FR_Class, ExtCtrls, FR_Ctrls
{$IFDEF MWEDIT}
, mwHighlighter, mwPasSyn, mwCustomEdit
{$ENDIF};

type
  TfrEditorForm1 = class(TfrObjEditorForm)
    ScriptPanel: TPanel;
    MemoPanel: TPanel;
    M1: TMemo;
    Splitter: TPanel;
    Panel1: TPanel;
    OkBtn: TfrSpeedButton;
    CancelBtn: TfrSpeedButton;
    Bevel2: TBevel;
    InsExprBtn: TfrSpeedButton;
    InsDBBtn: TfrSpeedButton;
    WordWrapBtn: TfrSpeedButton;
    ScriptBtn: TfrSpeedButton;
    Panel2: TPanel;
    Bevel1: TBevel;
    ErrorPanel: TPanel;
    CutBtn: TfrSpeedButton;
    CopyBtn: TfrSpeedButton;
    PasteBtn: TfrSpeedButton;
    procedure M1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure M1Enter(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SplitterMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SplitterMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure SplitterMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure InsExprBtnClick(Sender: TObject);
    procedure InsDBBtnClick(Sender: TObject);
    procedure WordWrapBtnClick(Sender: TObject);
    procedure ScriptBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure CutBtnClick(Sender: TObject);
    procedure CopyBtnClick(Sender: TObject);
    procedure PasteBtnClick(Sender: TObject);
  private
    { Private declarations }
{$IFDEF MWEDIT}
    M2: TmwCustomEdit;
{$ELSE}
    M2: TMemo;
{$ENDIF}
    FActiveMemo: TWinControl;
    FDown: Boolean;
    FLastY: Integer;
    FView: TfrView;
    FShowScript: Boolean;
    FSplitterPos: Integer;
    procedure SetSelText(s: String);
    procedure Localize;
  public
    { Public declarations }
    function ShowEditor(View: TfrView): TModalResult; override;
  end;


implementation

{$R *.DFM}

uses
  Registry, FR_Dock, FR_Desgn, FR_Expr, FR_Fmted, FR_Flds, FR_Const,
  FR_Utils;


function TfrEditorForm1.ShowEditor(View: TfrView): TModalResult;
var
  EmptyScript: Boolean;
  ScriptText: String;
  Ini: TRegIniFile;
  Nm: String;
  isMemoEditor: Boolean;
begin
  RestoreFormPosition(Self);
  Ini := TRegIniFile.Create(RegRootKey);
  Nm := rsForm + frDesigner.ClassName;
  FView := View;
  isMemoEditor := not ((View is TfrControl) or (View is TfrBandView));

  ErrorPanel.Hide;
  WordWrapBtnClick(nil);
  M1.Lines.Assign(FView.Memo);
  M2.Lines.Assign(FView.Script);
  if FView.Script.Text = '' then
    M2.Text := 'begin' + #13#10 + '  ' + #13#10 + 'end';

  M1.Font.Name := Ini.ReadString(Nm, 'TextFontName', 'Arial');
  M1.Font.Size := Ini.ReadInteger(Nm, 'TextFontSize', 10);
  M2.Font.Name := Ini.ReadString(Nm, 'ScriptFontName', 'Courier New');
  M2.Font.Size := Ini.ReadInteger(Nm, 'ScriptFontSize', 10);
  FSplitterPos := Ini.ReadInteger(Nm, 'SplitterPos', 100);

  if (FView is TfrMemoView) and Ini.ReadBool(Nm, 'UseDefaultFont', True) then
  begin
    M1.Font.Name := TfrMemoView(FView).Font.Name;
    M1.Font.Size := 10;
  end;
{$IFNDEF Delphi2}
  if View is TfrMemoView then
    M1.Font.Charset := TfrMemoView(View).Font.Charset else
    M1.Font.Charset := frCharset;
  M2.Font.Charset := frCharset;
{$ENDIF}
  M1.ReadOnly := (FView.Restrictions and frrfDontEditMemo) <> 0;
  M2.ReadOnly := (FView.Restrictions and frrfDontEditScript) <> 0;

  MemoPanel.Align := alNone;
  MemoPanel.SetBounds(0, 0, 10, 10);
  Splitter.Align := alNone;
  Splitter.SetBounds(0, 20, 10, 2);
  ScriptPanel.Align := alNone;
  ScriptPanel.SetBounds(0, 40, 10, 10);

  ScriptBtn.Down := True;
  if isMemoEditor then
  begin
    MemoPanel.Show;
    Splitter.Visible := FShowScript;
    ScriptPanel.Visible := FShowScript;
    ScriptBtn.Down := FShowScript;
    ScriptPanel.Align := alBottom;
    Splitter.Align := alBottom;
    MemoPanel.Align := alClient;
    ScriptPanel.Height := ClientHeight - FSplitterPos - 2;
  end
  else
  begin
    MemoPanel.Hide;
    Splitter.Hide;
    ScriptPanel.Show;
    ScriptPanel.Align := alClient;
  end;

  if MemoPanel.Visible then
    FActiveMemo := M1 else
    FActiveMemo := M2;

  M1.Perform(EM_SETSEL, 0, 0); M1.Perform(EM_SCROLLCARET, 0, 0);
  Result := ShowModal;
  if Result = mrOk then
  begin
    frDesigner.BeforeChange;
    M1.WordWrap := False;
    FView.Memo.Text := M1.Text;
    EmptyScript := (M2.Lines.Count = 3) and
      (Trim(M2.Lines[0]) = 'begin') and
      (Trim(M2.Lines[1]) = '') and
      (Trim(M2.Lines[2]) = 'end');
    if EmptyScript then
      ScriptText := '' else
      ScriptText := M2.Text;
    if not EmptyScript or (FView.Script.Text <> '') then
      FView.Script.Text := ScriptText;
  end;
  if isMemoEditor then
    FShowScript := ScriptBtn.Down;
  Ini.WriteInteger(Nm, 'SplitterPos', FSplitterPos);
  Ini.Free;
  SaveFormPosition(Self);
end;

procedure TfrEditorForm1.FormShow(Sender: TObject);
begin
  if MemoPanel.Visible then
    M1.SetFocus else
    M2.SetFocus;
end;

procedure TfrEditorForm1.SetSelText(s: String);
begin
  if FActiveMemo = M1 then
    M1.SelText := s else
    M2.SelText := s;
end;

procedure TfrEditorForm1.InsExprBtnClick(Sender: TObject);
var
  s: String;
begin
  s := frDesigner.InsertExpression;
  if s <> '' then
    SetSelText(s);
end;

procedure TfrEditorForm1.InsDBBtnClick(Sender: TObject);
var
  s: String;
begin
  s := frDesigner.InsertDBField;
  if s <> '' then
    SetSelText(s);
end;

procedure TfrEditorForm1.M1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  ErrorPanel.Hide;
  if (Key = vk_Insert) and (Shift = []) then InsDBBtnClick(Self);
  if Key = vk_Escape then ModalResult := mrCancel;
end;

procedure TfrEditorForm1.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #10 then
  begin
    Key := #0;
    OkBtnClick(nil);
  end;
end;

procedure TfrEditorForm1.M1Enter(Sender: TObject);
begin
  FActiveMemo := Sender as TWinControl;
end;

procedure TfrEditorForm1.WordWrapBtnClick(Sender: TObject);
begin
  M1.WordWrap := WordWrapBtn.Down;
end;

procedure TfrEditorForm1.ScriptBtnClick(Sender: TObject);
begin
  if (FView is TfrControl) or (FView is TfrBandView) then
  begin
    ScriptBtn.Down := True;
    Exit;
  end;
  if ScriptBtn.Down then
    ScriptPanel.Top := MemoPanel.Top + 1;
  ScriptPanel.Visible := ScriptBtn.Down;
  Splitter.Visible := ScriptBtn.Down;
  Splitter.Top := MemoPanel.Top + 1;
  if ScriptPanel.Visible then
    Splitter.Cursor := crVSplit else
    Splitter.Cursor := crDefault;
end;

procedure TfrEditorForm1.Localize;
begin
  Caption := frLoadStr(frRes + 060);
  InsExprBtn.Hint := frLoadStr(frRes + 061);
  InsDBBtn.Hint := frLoadStr(frRes + 062);
  CutBtn.Hint := frLoadStr(frRes + 091);
  CopyBtn.Hint := frLoadStr(frRes + 092);
  PasteBtn.Hint := frLoadStr(frRes + 093);
  WordWrapBtn.Hint := frLoadStr(frRes + 063);
  ScriptBtn.Hint := frLoadStr(frRes + 064);
  OkBtn.Hint := frLoadStr(SOk);
  CancelBtn.Hint := frLoadStr(SCancel);
end;

procedure TfrEditorForm1.FormCreate(Sender: TObject);
{$IFDEF MWEDIT}
var
  SynParser: TmwPasSyn;
{$ENDIF}
begin
  Localize;
  FShowScript := True;
  FSplitterPos := Height div 2;

{$IFDEF MWEDIT}
  M2 := TmwCustomEdit.Create(Self);
  SynParser := TmwPasSyn.Create(Self);
  {$I *.inc}
{$ELSE}
  M2 := TMemo.Create(Self);
  M2.WordWrap := False;
{$ENDIF}
  M2.Parent := ScriptPanel;
  M2.Align := alClient;
  M2.HelpContext := 20;
  M2.ScrollBars := ssBoth;
  M2.Font.Name := 'Courier New';
  M2.Font.Size := 10;
  M2.OnEnter := M1Enter;
  M2.OnKeyDown := M1KeyDown;
{$IFDEF MWEDIT}
  M2.Highlighter := SynParser;
  M2.Gutter.Visible := False;
{$ENDIF}
end;

procedure TfrEditorForm1.SplitterMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FDown := True;
  FLastY := Y;
end;

procedure TfrEditorForm1.SplitterMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if FDown then
  begin
    ScriptPanel.Height := ScriptPanel.Height - (Y - FLastY);
    Splitter.Top := Splitter.Top + Y - FLastY;
    FSplitterPos := Splitter.Top;
  end;
end;

procedure TfrEditorForm1.SplitterMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FDown := False;
end;

procedure TfrEditorForm1.CancelBtnClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

{$HINTS OFF}
procedure TfrEditorForm1.OkBtnClick(Sender: TObject);
var
  sl1, sl2: TStringList;

  procedure ErrorPosition;
  var
    s: String;
    i, n, n1, n2: Integer;
  begin
    s := sl2.Text;
    n := 0;
    n1 := 1;
    if Pos('/', s) <> 0 then
    begin
      n := StrToInt(Copy(s, 6, Pos('/', s) - 6));
      n1 := StrToInt(Copy(s, Pos('/', s) + 1, Pos(':', s) - Pos('/', s) - 1));
    end;

    n2 := 0;
    for i := 0 to n - 2 do
      Inc(n2, Length(M2.Lines[i]) + 2);
    Inc(n2, n1 - 1);
    M2.SetFocus;
{$IFDEF MWEDIT}
    M2.CaretXY := Point(n1, n);
{$ELSE}
    M2.Perform(EM_SETSEL, n2, n2); M2.Perform(EM_SCROLLCARET, 0, 0);
{$ENDIF}
  end;

begin
  sl1 := TStringList.Create;
  sl2 := TStringList.Create;
  frInterpretator.PrepareScript(M2.Lines, sl1, sl2);
  if sl2.Count > 0 then
  begin
    ErrorPanel.Caption := ' ' + sl2.Text;
    ErrorPanel.Show;
    ErrorPosition;
  end
  else
    ModalResult := mrOk;
  sl1.Free;
  sl2.Free;
end;
{$HINTS ON}

procedure TfrEditorForm1.FormResize(Sender: TObject);
begin
  ErrorPanel.Hide;
  if MemoPanel.Visible then
    if ScriptPanel.Height > ClientHeight - 40 then
      ScriptPanel.Height := ClientHeight div 2;
end;

procedure TfrEditorForm1.CutBtnClick(Sender: TObject);
begin
  if FActiveMemo = M1 then
    M1.CutToClipboard else
    M2.CutToClipboard;
end;

procedure TfrEditorForm1.CopyBtnClick(Sender: TObject);
begin
  if FActiveMemo = M1 then
    M1.CopyToClipboard else
    M2.CopyToClipboard;
end;

procedure TfrEditorForm1.PasteBtnClick(Sender: TObject);
begin
  if FActiveMemo = M1 then
    M1.PasteFromClipboard else
    M2.PasteFromClipboard;
end;


end.

