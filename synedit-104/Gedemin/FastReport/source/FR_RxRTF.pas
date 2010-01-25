
{******************************************}
{                                          }
{             FastReport v2.53             }
{          RxRich Add-In Object            }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_RxRTF;

interface

{$I FR.inc}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Menus,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls,
  FR_DBRel, FR_Class, RichEdit, RxRiched, FR_Ctrls, FR_Combo;

type
  TfrRxRichObject = class(TComponent)  // fake component
  end;

  TfrRxRichView = class(TfrStretcheable)
  private
    CurChar, LastChar, CharFrom: Integer;
    Flag: Boolean;
    procedure P1Click(Sender: TObject);
    procedure GetRichData(ASource: TCustomMemo);
    function DoCalcHeight: Integer;
    procedure ShowRich(Render: Boolean);
    procedure RichEditor(Sender: TObject);
  protected
    procedure SetPropValue(Index: String; Value: Variant); override;
    function GetPropValue(Index: String): Variant; override;
  public
    RichEdit: TRxRichEdit;
    constructor Create; override;
    destructor Destroy; override;
    procedure Draw(Canvas: TCanvas); override;
    procedure StreamOut(Stream: TStream); override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure GetBlob(b: TfrTField); override;
    function CalcHeight: Integer; override;
    function MinHeight: Integer; override;
    function LostSpace: Integer; override;
    procedure DefinePopupMenu(Popup: TPopupMenu); override;
    procedure DefineProperties; override;
    procedure ShowEditor; override;
  end;

  TfrRxRichForm = class(TForm)
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    SpeedBar: TPanel;
    OpenButton: TfrSpeedButton;
    SaveButton: TfrSpeedButton;
    UndoButton: TfrSpeedButton;
    Ruler: TPanel;
    FontDialog1: TFontDialog;
    FirstInd: TLabel;
    LeftInd: TLabel;
    RulerLine: TBevel;
    RightInd: TLabel;
    BoldButton: TfrSpeedButton;
    ItalicButton: TfrSpeedButton;
    LeftAlign: TfrSpeedButton;
    CenterAlign: TfrSpeedButton;
    RightAlign: TfrSpeedButton;
    UnderlineButton: TfrSpeedButton;
    BulletsButton: TfrSpeedButton;
    RichEdit1: TRxRichEdit;
    SpeedButton1: TfrSpeedButton;
    CancBtn: TfrSpeedButton;
    OkBtn: TfrSpeedButton;
    SpeedButton2: TfrSpeedButton;
    Image1: TImage;
    Bevel1: TBevel;
    HelpBtn: TfrSpeedButton;
    FontName: TfrFontComboBox;
    FontSize: TfrComboBox;

    procedure SelectionChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FileOpen(Sender: TObject);
    procedure FileSaveAs(Sender: TObject);
    procedure EditUndo(Sender: TObject);
    procedure SelectFont(Sender: TObject);
    procedure RulerResize(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure BoldButtonClick(Sender: TObject);
    procedure AlignButtonClick(Sender: TObject);
    procedure FontNameChange(Sender: TObject);
    procedure BulletsButtonClick(Sender: TObject);
    procedure RulerItemMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RulerItemMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FirstIndMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LeftIndMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RightIndMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CancBtnClick(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FontSizeChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FUpdating: Boolean;
    FDragOfs: Integer;
    FDragging: Boolean;
    function CurrText: TRxTextAttributes;
    procedure SetupRuler;
    procedure SetEditRect;
    procedure Localize;
  public
  end;


implementation

uses FR_Pars, FR_Intrp, FR_Utils, FR_Const, Printers
{$IFDEF Delphi6}
, Variants
{$ENDIF};

const
  RulerAdj = 4/3;
  GutterWid = 6;

{$R *.DFM}


var
  SRichEdit: TRxRichEdit; // temporary rich used during TRichView drawing
  frRxRichForm: TfrRxRichForm;

procedure AssignRich(Rich1, Rich2: TRxRichEdit);
var
  st: TMemoryStream;
begin
  st := TMemoryStream.Create;
  Rich2.Lines.SaveToStream(st);
  st.Position := 0;
  Rich1.Lines.LoadFromStream(st);
  st.Free;
end;

{----------------------------------------------------------------------------}
constructor TfrRxRichView.Create;
begin
  inherited Create;
  RichEdit := TRxRichEdit.Create(nil);
  RichEdit.Parent := frRxRichForm;
  RichEdit.Visible := False;
  BaseName := 'RxRich';
end;

destructor TfrRxRichView.Destroy;
begin
  if frRxRichForm <> nil then RichEdit.Free;
  inherited Destroy;
end;

procedure TfrRxRichView.DefineProperties;
begin
  inherited DefineProperties;
  AddProperty('Lines', [frdtHasEditor, frdtOneObject], RichEditor);
  AddProperty('Stretched', [frdtBoolean], nil);
  AddProperty('TextOnly', [frdtBoolean], nil);
  AddProperty('GapX', [frdtInteger], nil);
  AddProperty('GapY', [frdtInteger], nil);
  AddProperty('DataField', [frdtOneObject, frdtHasEditor, frdtString], frFieldEditor);
end;

procedure TfrRxRichView.SetPropValue(Index: String; Value: Variant);
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
  if Index = 'TEXTONLY' then
    Flags := (Flags and not flTextOnly) or Word(Boolean(Value)) * flTextOnly
end;

function TfrRxRichView.GetPropValue(Index: String): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := inherited GetPropValue(Index);
  if Result <> Null then Exit;
  if Index = 'TEXTONLY' then
    Result := (Flags and flTextOnly) <> 0
end;

function GetSpecial(const s: String; Pos: Integer): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to Pos do
    if s[i] in [#10, #13] then
      Inc(Result);
end;

procedure TfrRxRichView.GetRichData(ASource: TCustomMemo);
var
  R, S: String;
  i, j: Integer;
begin
  CurView := Self;
  with ASource do
  try
    Lines.BeginUpdate;
    i := Pos('[', Text);
    while i > 0 do
    begin
      SelStart := i - 1 - GetSpecial(Text, i) div 2;
      R := GetBrackedVariable(Text, i, j);
      CurReport.InternalOnGetValue(R, S);
      SelLength := j - i + 1;
      SelText := S;
      i := Pos('[', Text);
    end;
  finally
    Lines.EndUpdate;
  end;
end;

function TfrRxRichView.DoCalcHeight: Integer;
var
  Range: TFormatRange;
  MaxLen, LogX, LogY: Integer;
begin
  FillChar(Range, SizeOf(TFormatRange), 0);
  with Range do
  begin
    hdc := GetDC(0);
    hdcTarget := hdc;
    LogX := Screen.PixelsPerInch;
    LogY := LogX;

    rc := Rect(0, 0, Round((DX - GapX * 2) * 1440 / LogX), Round(1000000 * 1440.0 / LogY));
    rcPage := rc;
    LastChar := CharFrom;
    MaxLen := SRichEdit.GetTextLen;
    chrg.cpMin := LastChar;
    chrg.cpMax := -1;
    SRichEdit.Perform(EM_FORMATRANGE, 0, Integer(@Range));
    ReleaseDC(0, hdc);
    if MaxLen = 0 then
      Result := 0
    else
    begin
      if (rcPage.bottom <> rc.bottom) then
        Result := Round(rc.bottom / (1440.0 / LogY)) + 2 * GapY else
        Result := 0;
    end;
  end;
  SRichEdit.Perform(EM_FORMATRANGE, 0, 0);
end;

{$WARNINGS OFF}
procedure TfrRxRichView.ShowRich(Render: Boolean);
var
  Range: TFormatRange;
  LogX, LogY, mm: Integer;
  EMF: TMetafile;
  EMFCanvas: TMetafileCanvas;
  re: TRxRichEdit;
  BMP: TBitmap;
begin
  if Render then
    re := RichEdit else
    re := SRichEdit;
  FillChar(Range, SizeOf(TFormatRange), 0);
  with Range do
  begin
    if Render then
      hdc := Canvas.Handle else
      hdc := GetDC(0);
    if Render then
      if IsPrinting then
      begin
        LogX := GetDeviceCaps(hdc, LOGPIXELSX);
        LogY := GetDeviceCaps(hdc, LOGPIXELSY);
        rc := Rect(DRect.Left * 1440 div LogX, DRect.Top * 1440 div LogY,
                   DRect.Right * 1440 div LogX, Round(DRect.Bottom * 1440 / LogY));
      end
      else
      begin
        LogX := Screen.PixelsPerInch;
        LogY := LogX;
        rc := Rect(0, 0, Round((SaveDX - SaveGX * 2) * 1440 / LogX),
          Round((SaveDY - SaveGY * 2) * 1440 / LogY));
        EMF := TMetafile.Create;
        EMF.Width := SaveDX - SaveGX * 2;
        EMF.Height := SaveDY - SaveGY * 2;
        EMFCanvas := TMetafileCanvas.Create(EMF, 0);
        EMFCanvas.Brush.Style := bsClear;
        hdc := EMFCanvas.Handle;
      end
    else
    begin
      LogX := Screen.PixelsPerInch;
      LogY := LogX;
      rc := Rect(0, 0, Round((DX - GapX * 2) * 1440 / LogX),
        Round((DY - GapY * 2) * 1440 / LogY));
    end;
    hdcTarget := hdc;
    rcPage := rc;
    LastChar := CharFrom;
    chrg.cpMin := LastChar;
    chrg.cpMax := -1;
    mm := SetMapMode(hdc, MM_TEXT);
    LastChar := re.Perform(EM_FORMATRANGE, Integer(Render), Integer(@Range));
    SetMapMode(hdc, mm);
  end;
  re.Perform(EM_FORMATRANGE, 0, 0);
  if not Render then
    ReleaseDC(0, Range.hdc)
  else if not IsPrinting then
  begin
    EMFCanvas.Free;
    if DocMode <> dmDesigning then
      Canvas.StretchDraw(DRect, EMF)
    else
    begin
      BMP := TBitmap.Create;
      BMP.Width := DRect.Right - DRect.Left + 1;
      BMP.Height := DRect.Bottom - DRect.Top + 1;
      BMP.Canvas.StretchDraw(Rect(0, 0, BMP.Width, BMP.Height), EMF);
      Canvas.Draw(DRect.Left, DRect.Top, BMP);
      BMP.Free;
    end;
    EMF.Free;
  end;
end;
{$WARNINGS ON}

procedure TfrRxRichView.Draw(Canvas: TCanvas);
begin
  BeginDraw(Canvas);
  CalcGaps;
  with Canvas do
  begin
    ShowBackground;
    CharFrom := 0;
    InflateRect(DRect, -gapx, -gapy);
    if (dx > 0) and (dy > 0) then
      ShowRich(True);
    ShowFrame;
  end;
  RestoreCoord;
end;

procedure TfrRxRichView.StreamOut(Stream: TStream);
var
  SaveTag: String;
  n: Integer;
begin
  BeginDraw(Canvas);
  Memo1.Assign(Memo);
  CurReport.InternalOnEnterRect(Memo1, Self);
  frInterpretator.DoScript(Script);
  if not Visible then Exit;

  SaveTag := Tag;
  if (Tag <> '') and (Pos('[', Tag) <> 0) then
    ExpandVariables(Tag);

  AssignRich(SRichEdit, RichEdit);
  if (Flags and flTextOnly) = 0 then
    GetRichData(SRichEdit);

  if DrawMode = drPart then
  begin
    CharFrom := LastChar;
    ShowRich(False);
    n := SRichEdit.GetTextLen - LastChar + 1;
    if n > 0 then
    begin
      SRichEdit.SelStart := LastChar;
      SRichEdit.SelLength := n;
      SRichEdit.SelText := '';
    end;

    SRichEdit.SelStart := 0;
    SRichEdit.SelLength := CurChar;
    SRichEdit.SelText := '';

    CurChar := LastChar;
  end;

  Stream.Write(Typ, 1);
  frWriteString(Stream, ClassName);
  Flag := True;
  SaveToStream(Stream);
  Flag := False;

  Tag := SaveTag;
end;

function TfrRxRichView.CalcHeight: Integer;
begin
  LastChar := 0;
  CurChar := 0;
  Result := 0;
  frInterpretator.DoScript(Script);
  if not Visible then Exit;

  Memo1.Assign(Memo);
  CurReport.InternalOnEnterRect(Memo1, Self);
  AssignRich(SRichEdit, RichEdit);
  if (Flags and flTextOnly) = 0 then
    GetRichData(SRichEdit);
  CharFrom := 0;
  Result := DoCalcHeight;
end;

function TfrRxRichView.MinHeight: Integer;
begin
  Result := 8;
end;

function TfrRxRichView.LostSpace: Integer;
var
  n, lc, cc: Integer;
begin
  AssignRich(SRichEdit, RichEdit);
  if (Flags and flTextOnly) = 0 then
    GetRichData(SRichEdit);

  lc := LastChar;
  cc := CurChar;
  CharFrom := 0;

  SRichEdit.SelStart := 0;
  SRichEdit.SelLength := LastChar;
  SRichEdit.SelText := '';

  ShowRich(False);
  n := SRichEdit.GetTextLen - LastChar + 1;
  if n > 0 then
  begin
    SRichEdit.SelStart := LastChar;
    SRichEdit.SelLength := n;
    SRichEdit.SelText := '';
  end;

  CharFrom := 0;
  n := DoCalcHeight;
  if n < dy then
    n := dy;
  Result := Round(Abs(dy - n)) + gapy * 2 + Round(FrameWidth * 2);
  LastChar := lc;
  CurChar := cc;
end;

procedure TfrRxRichView.LoadFromStream(Stream: TStream);
var
  b: Byte;
  n: Integer;
begin
  inherited LoadFromStream(Stream);
  Stream.Read(b, 1);
  Stream.Read(n, 4);
  if b <> 0 then RichEdit.Lines.LoadFromStream(Stream);
  Stream.Seek(n, soFromBeginning);
end;

procedure TfrRxRichView.SaveToStream(Stream: TStream);
var
  b: Byte;
  n, o: Integer;
  re: TRxRichEdit;
begin
  inherited SaveToStream(Stream);
  re := RichEdit;
  if Flag then
    re := SRichEdit;
  b := 0;
  if re.Lines.Count <> 0 then b := 1;
  Stream.Write(b, 1);
  n := Stream.Position;
  Stream.Write(n, 4);
  if b <> 0 then re.Lines.SaveToStream(Stream);
  o := Stream.Position;
  Stream.Seek(n, soFromBeginning);
  Stream.Write(o, 4);
  Stream.Seek(0, soFromEnd);
end;

procedure TfrRxRichView.GetBlob(b: TfrTField);
var
  s: TMemoryStream;
begin
  s := TMemoryStream.Create;
  frAssignBlobTo(b, s);
  RichEdit.Lines.LoadFromStream(s);
  s.Free;
end;

procedure TfrRxRichView.ShowEditor;
begin
  with frRxRichForm do
  begin
    AssignRich(RichEdit1, RichEdit);
    if ShowModal = mrOk then
    begin
      frDesigner.BeforeChange;
      AssignRich(RichEdit, RichEdit1);
    end;
    RichEdit1.Lines.Clear;
  end;
end;

procedure TfrRxRichView.RichEditor(Sender: TObject);
begin
  ShowEditor;
end;

procedure TfrRxRichView.DefinePopupMenu(Popup: TPopupMenu);
var
  m: TMenuItem;
begin
  inherited DefinePopupMenu(Popup);

  m := TMenuItem.Create(Popup);
  m.Caption := frLoadStr(STextOnly);
  m.OnClick := P1Click;
  m.Checked := (Flags and flTextOnly) <> 0;
  Popup.Items.Add(m);
end;

procedure TfrRxRichView.P1Click(Sender: TObject);
var
  i: Integer;
  t: TfrView;
begin
  frDesigner.BeforeChange;
  with Sender as TMenuItem do
  begin
    Checked := not Checked;
    for i := 0 to frDesigner.Page.Objects.Count - 1 do
    begin
      t := frDesigner.Page.Objects[i];
      if t.Selected and ((t.Restrictions and frrfDontModify) = 0) then
        t.Flags := (t.Flags and not flTextOnly) + Word(Checked) * flTextOnly;
    end;
  end;
  frDesigner.AfterChange;
end;

{------------------------------------------------------------------------}
procedure TfrRxRichForm.SelectionChange(Sender: TObject);
begin
  with RichEdit1.Paragraph do
  try
    FUpdating := True;
    FirstInd.Left := Trunc(FirstIndent * RulerAdj) - 4 + GutterWid;
    LeftInd.Left := Trunc((LeftIndent + FirstIndent) * RulerAdj) - 4 + GutterWid;
    RightInd.Left := Ruler.ClientWidth - 6 - Trunc((RightIndent + GutterWid) * RulerAdj);
    BoldButton.Down := fsBold in RichEdit1.SelAttributes.Style;
    ItalicButton.Down := fsItalic in RichEdit1.SelAttributes.Style;
    UnderlineButton.Down := fsUnderline in RichEdit1.SelAttributes.Style;
    BulletsButton.Down := Boolean(Numbering);
    FontSize.Text := IntToStr(RichEdit1.SelAttributes.Size);
    FontName.Text := RichEdit1.SelAttributes.Name;
    case Ord(Alignment) of
      0: LeftAlign.Down := True;
      1: RightAlign.Down := True;
      2: CenterAlign.Down := True;
    end;
  finally
    FUpdating := False;
  end;
end;

function TfrRxRichForm.CurrText: TRxTextAttributes;
begin
  if RichEdit1.SelLength > 0 then
    Result := RichEdit1.SelAttributes else
    Result := RichEdit1.DefAttributes;
end;

procedure TfrRxRichForm.SetupRuler;
var
  I: Integer;
  S: String;
begin
  SetLength(S, 201);
  I := 1;
  while I < 200 do
  begin
    S[I] := #9;
    S[I+1] := '|';
    Inc(I, 2);
  end;
  Ruler.Caption := S;
end;

procedure TfrRxRichForm.SetEditRect;
var
  R: TRect;
begin
  with RichEdit1 do
  begin
    R := Rect(GutterWid, 0, ClientWidth - GutterWid, ClientHeight);
    SendMessage(Handle, EM_SETRECT, 0, Longint(@R));
  end;
end;

{ Event Handlers }

procedure TfrRxRichForm.FormResize(Sender: TObject);
begin
  SetEditRect;
  SelectionChange(Sender);
end;

procedure TfrRxRichForm.FormPaint(Sender: TObject);
begin
  SetEditRect;
end;

procedure TfrRxRichForm.FileOpen(Sender: TObject);
begin
  OpenDialog.Filter := frLoadStr(SRTFFile) + ' (*.rtf)|*.rtf';
  if OpenDialog.Execute then
  begin
    RichEdit1.Lines.LoadFromFile(OpenDialog.FileName);
    RichEdit1.SetFocus;
    SelectionChange(Self);
  end;
end;

procedure TfrRxRichForm.FileSaveAs(Sender: TObject);
begin
  SaveDialog.Filter := frLoadStr(SRTFFile) + ' (*.rtf)|*.rtf|' +
                       frLoadStr(STextFile) + ' (*.txt)|*.txt';
  if SaveDialog.Execute then
    RichEdit1.Lines.SaveToFile(SaveDialog.FileName);
end;

procedure TfrRxRichForm.EditUndo(Sender: TObject);
begin
  with RichEdit1 do
    if HandleAllocated then SendMessage(Handle, EM_UNDO, 0, 0);
end;

procedure TfrRxRichForm.SelectFont(Sender: TObject);
begin
  FontDialog1.Font.Assign(RichEdit1.SelAttributes);
  if FontDialog1.Execute then
    CurrText.Assign(FontDialog1.Font);
  RichEdit1.SetFocus;
end;

procedure TfrRxRichForm.RulerResize(Sender: TObject);
begin
  RulerLine.Width := Ruler.ClientWidth - RulerLine.Left * 2;
end;

procedure TfrRxRichForm.BoldButtonClick(Sender: TObject);
var
  s: TFontStyles;
begin
  if FUpdating then Exit;
  s := [];
  if BoldButton.Down then s := s + [fsBold];
  if ItalicButton.Down then s := s + [fsItalic];
  if UnderlineButton.Down then s := s + [fsUnderline];
  CurrText.Style := s;
end;

procedure TfrRxRichForm.AlignButtonClick(Sender: TObject);
begin
  if FUpdating then Exit;
  case TControl(Sender).Tag of
    312: RichEdit1.Paragraph.Alignment := paLeftJustify;
    313: RichEdit1.Paragraph.Alignment := paCenter;
    314: RichEdit1.Paragraph.Alignment := paRightJustify;
  end;
end;

procedure TfrRxRichForm.FontNameChange(Sender: TObject);
begin
  if FUpdating then Exit;
  CurrText.Name := FontName.Text;
end;

procedure TfrRxRichForm.BulletsButtonClick(Sender: TObject);
begin
  if FUpdating then Exit;
  RichEdit1.Paragraph.Numbering := TRxNumbering(BulletsButton.Down);
end;

{ Ruler Indent Dragging }

procedure TfrRxRichForm.RulerItemMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FDragOfs := (TLabel(Sender).Width div 2);
  TLabel(Sender).Left := TLabel(Sender).Left + X - FDragOfs;
  FDragging := True;
end;

procedure TfrRxRichForm.RulerItemMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if FDragging then
    TLabel(Sender).Left :=  TLabel(Sender).Left + X - FDragOfs
end;

procedure TfrRxRichForm.FirstIndMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FDragging := False;
  RichEdit1.Paragraph.FirstIndent :=
    Trunc((FirstInd.Left + FDragOfs - GutterWid) / RulerAdj);
  LeftIndMouseUp(Sender, Button, Shift, X, Y);
end;

procedure TfrRxRichForm.LeftIndMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FDragging := False;
  RichEdit1.Paragraph.LeftIndent :=
    Trunc((LeftInd.Left + FDragOfs - GutterWid) / RulerAdj) - RichEdit1.Paragraph.FirstIndent;
  SelectionChange(Sender);
end;

procedure TfrRxRichForm.RightIndMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FDragging := False;
  RichEdit1.Paragraph.RightIndent :=
    Trunc((Ruler.ClientWidth - RightInd.Left + FDragOfs - 2) / RulerAdj) - 2 * GutterWid;
  SelectionChange(Sender);
end;

procedure TfrRxRichForm.CancBtnClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrRxRichForm.OkBtnClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrRxRichForm.SpeedButton2Click(Sender: TObject);
var
  s: String;
begin
  s := frDesigner.InsertExpression;
  if s <> '' then
    RichEdit1.SelText := s;
end;

procedure TfrRxRichForm.FontSizeChange(Sender: TObject);
begin
  CurrText.Size := StrToInt(FontSize.Text);
  RichEdit1.SetFocus;
end;

procedure TfrRxRichForm.FormActivate(Sender: TObject);
begin
  RichEdit1.SetFocus;
end;

procedure TfrRxRichForm.Localize;
begin
  Caption := frLoadStr(frRes + 560);
  OpenButton.Hint := frLoadStr(frRes + 561);
  SaveButton.Hint := frLoadStr(frRes + 562);
  UndoButton.Hint := frLoadStr(frRes + 563);
  BoldButton.Hint := frLoadStr(frRes + 564);
  ItalicButton.Hint := frLoadStr(frRes + 565);
  LeftAlign.Hint := frLoadStr(frRes + 566);
  CenterAlign.Hint := frLoadStr(frRes + 567);
  RightAlign.Hint := frLoadStr(frRes + 568);
  UnderlineButton.Hint := frLoadStr(frRes + 569);
  BulletsButton.Hint := frLoadStr(frRes + 570);
  SpeedButton1.Hint := frLoadStr(frRes + 571);
  HelpBtn.Hint := frLoadStr(frRes + 032);
  CancBtn.Hint := frLoadStr(frRes + 572);
  OkBtn.Hint := frLoadStr(frRes + 573);
  SpeedButton2.Hint := frLoadStr(frRes + 575);
  FontName.Hint := frLoadStr(frRes + 576);
  FontSize.Hint := frLoadStr(frRes + 577);
  if frDesignerClass <> nil then
  begin
    BoldButton.Glyph.Handle := frLocale.LoadBmp('FR_BOLD');
    ItalicButton.Glyph.Handle := frLocale.LoadBmp('FR_ITALIC');
    UnderlineButton.Glyph.Handle := frLocale.LoadBmp('FR_UNDRLINE');
  end;
end;

procedure TfrRxRichForm.FormCreate(Sender: TObject);
begin
  OpenDialog.InitialDir := ExtractFilePath(ParamStr(0));
  SaveDialog.InitialDir := OpenDialog.InitialDir;
  SetupRuler;
  SelectionChange(Self);
end;

procedure TfrRxRichForm.FormShow(Sender: TObject);
begin
  Localize;
end;


type
  THackBtn = class(TfrSpeedButton)
  end;

procedure TfrRxRichForm.HelpBtnClick(Sender: TObject);
begin
  Screen.Cursor := crHelp;
  SetCapture(Handle);
  THackBtn(HelpBtn).FMouseInControl := False;
  HelpBtn.Invalidate;
end;

procedure TfrRxRichForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  c: TControl;
begin
  HelpBtn.Down := False;
  Screen.Cursor := crDefault;
  c := frControlAtPos(Self, Point(X, Y));
  if (c <> nil) and (c <> HelpBtn) then
    Application.HelpCommand(HELP_CONTEXTPOPUP, c.Tag);
end;


initialization
  frRxRichForm := TfrRxRichForm.Create(nil);
  SRichEdit := frRxRichForm.RichEdit1;
  frRegisterObject(TfrRxRichView, frRxRichForm.Image1.Picture.Bitmap,
    IntToStr(SInsRich2Object));

finalization
  frRxRichForm.Free;
  frRxRichForm := nil;


end.

