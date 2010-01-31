unit syn_dlgOptionsManager_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, SynHighlighterSQL, SynHighlighterVBScript, SynEditHighlighter,
  SynHighlighterJScript, SynEdit, ExtCtrls, ColorGrd, ComCtrls, gsKeyStrokes,
  SynEditKeyCmdsEditor, ActnList, SynEditKeyCmds, SuperPageControl;

type
  TdlgOptionsManager = class(TForm)
    SynJScriptSyn1: TSynJScriptSyn;
    SynVBScriptSyn1: TSynVBScriptSyn;
    SynSQLSyn1: TSynSQLSyn;
    Panel1: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    FontDialog1: TFontDialog;
    btnFont: TButton;
    PageControl1: TPageControl;
    tsGeneral: TTabSheet;
    tsKeyMappings: TTabSheet;
    tsColors: TTabSheet;
    pnlTop: TPanel;
    cbLanguages: TComboBox;
    lbAttributes: TListBox;
    ColorGrid: TColorGrid;
    gbTextAttr: TGroupBox;
    cbBold: TCheckBox;
    cbItalic: TCheckBox;
    cbUnderLine: TCheckBox;
    cbStrikeOut: TCheckBox;
    gbNoneGround: TGroupBox;
    cbFont: TCheckBox;
    cbBack: TCheckBox;
    seTestScript: TSynEdit;
    GroupBox1: TGroupBox;
    cbAutoIndentMode: TCheckBox;
    cbInsertMode: TCheckBox;
    cbSmartTab: TCheckBox;
    cbGroupUndo: TCheckBox;
    cbCursorBeyondEOF: TCheckBox;
    cbUndoAfterSave: TCheckBox;
    cbKeepTrailingBlanks: TCheckBox;
    cbFindTextAtCursor: TCheckBox;
    cbUseSyntaxHighLight: TCheckBox;
    Label1: TLabel;
    cbEditorSpeedSettings: TComboBox;
    Label3: TLabel;
    cbUndoLimit: TComboBox;
    Label4: TLabel;
    cbTabStops: TComboBox;
    Panel2: TPanel;
    Label5: TLabel;
    lbKeyMapping: TListBox;
    Default: TgsKeyStrokes;
    Classic: TgsKeyStrokes;
    NewClassic: TgsKeyStrokes;
    ActionList: TActionList;
    actEditKeystrokes: TAction;
    Button1: TButton;
    VisualStudio: TgsKeyStrokes;
    cbTabToSpaces: TCheckBox;
    GroupBox2: TGroupBox;
    cbVisibleRightMargine: TCheckBox;
    cbVisibleGutter: TCheckBox;
    cbRightMargin: TComboBox;
    Label6: TLabel;
    cbGutterWidth: TComboBox;
    Label7: TLabel;
    Button2: TButton;
    actResetKeystrokes: TAction;
    procedure cbLanguagesChange(Sender: TObject);
    procedure lbAttributesClick(Sender: TObject);
    procedure ColorGridChange(Sender: TObject);
    procedure cbFontClick(Sender: TObject);
    procedure cbBackClick(Sender: TObject);
    procedure cbBoldClick(Sender: TObject);
    procedure cbItalicClick(Sender: TObject);
    procedure cbUnderLineClick(Sender: TObject);
    procedure cbStrikeOutClick(Sender: TObject);
    procedure btnFontClick(Sender: TObject);
    procedure seTestScriptSpecialLineColors(Sender: TObject; Line: Integer;
      var Special: Boolean; var FG, BG: TColor);
    procedure actEditKeystrokesUpdate(Sender: TObject);
    procedure actEditKeystrokesExecute(Sender: TObject);
    procedure lbKeyMappingClick(Sender: TObject);
    procedure cbEditorSpeedSettingsChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure actResetKeystrokesExecute(Sender: TObject);
  private
    FSynHighLighter: TSynCustomHighLighter;
    FLastIndex: Integer;
    FKeystrokes: TSynEditKeyStrokes;
    FKeyStrokesIndex: Integer;

    procedure SetChildEnabled(const AnEnabled: Boolean; const AnWinControl: TWinControl);
    procedure SelectColorChange(Sender: TObject);
    procedure SetKeystrokes(const Value: TSynEditKeyStrokes);

    function GetKeyStrokesIntex(KeyStrokes: TSynEditKeyStrokes): Integer;
    procedure SetKeyStrokesIndex(const Value: Integer);
    function GetKeyStrokes(Index: Integer): TSynEditKeyStrokes;
    property Keystrokes: TSynEditKeyStrokes read FKeystrokes write SetKeystrokes;
  public
    function Execute: Boolean;

    property KeyStrokesIndex: Integer read FKeyStrokesIndex write SetKeyStrokesIndex;
  end;

  procedure ResetDefaultDefaults(K: TSynEditKeyStrokes);
  procedure ResetClassicDefaults(K: TSynEditKeyStrokes);

var
  dlgOptionsManager: TdlgOptionsManager;

implementation

uses
  prp_MessageConst
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;
  
{$R *.DFM}

procedure ResetDefaultDefaults(K: TSynEditKeyStrokes);

  procedure AddKey(const ACmd: TSynEditorCommand; const AKey, AKey2: word;
     const AShift, AShift2: TShiftState);
  begin
    with K.Add do
    begin
      Key := AKey;
      Key2 := AKey2;
      Shift := AShift;
      Shift2 := AShift2;
      Command := ACmd;
    end;
  end;

begin
  if Assigned(K) then
  begin
    K.ResetDefaults;
    // Переопределяем значение по умолчанию
    K.Items[K.FindCommand(ecColumnSelect)].Shift := [ssCtrl, ssAlt];

    AddKey(ecFind, ord('F'), 0, [ssCtrl], []);
    AddKey(ecFindNext, ord('L'), 0, [ssCtrl], []);
    AddKey(ecFindNext, VK_F3, 0, [], []);
    AddKey(ecReplace, ord('R'), 0, [ssCtrl], []);
    AddKey(ecDeleteItem, ord('D'), 0, [ssCtrl], []);
    AddKey(ecCommit, ord('S'), 0, [ssCtrl], []);
    AddKey(ecDebugRun, VK_F9, 0, [], []);
    AddKey(ecDebugStepIn, VK_F7, 0, [], []);
    AddKey(ecDebugStepOut, VK_F8, 0, [], []);
    AddKey(ecDebugGotoCursor, VK_F4, 0, [], []);
    AddKey(ecProgramReset, VK_F2, 0, [ssCtrl], []);
    AddKey(ecToggleBreakPoint, VK_F5, 0, [], []);
    AddKey(ecPrepare, VK_F9, 0, [ssCtrl], []);
    AddKey(ecDebugStepOut, VK_F7, 0, [ssShift], []);
    AddKey(ecAddWatch, VK_F5, 0, [ssCtrl], []);
    AddKey(ecEvaluate, VK_F7, 0, [ssCtrl], []);
    AddKey(ecGotoToInclude, VK_RETURN, 0, [ssCtrl], []);
    AddKey(ecSelMoveRight, ord('K'), ord('I'), [ssCtrl], [ssCtrl]);
    AddKey(ecSelMoveLeft, ord('K'), ord('U'), [ssCtrl], [ssCtrl]);
    AddKey(ecComentBlock, ord('B'), ord('C'), [ssCtrl], [ssCtrl]);
    AddKey(ecUnComentBlock, ord('B'), ord('U'), [ssCtrl], [ssCtrl]);

    AddKey(ecSetMarker0, ord('K'), ord('0'), [ssCtrl], [ssCtrl]);
    AddKey(ecSetMarker1, ord('K'), ord('1'), [ssCtrl], [ssCtrl]);
    AddKey(ecSetMarker2, ord('K'), ord('2'), [ssCtrl], [ssCtrl]);
    AddKey(ecSetMarker3, ord('K'), ord('3'), [ssCtrl], [ssCtrl]);
    AddKey(ecSetMarker4, ord('K'), ord('4'), [ssCtrl], [ssCtrl]);
    AddKey(ecSetMarker5, ord('K'), ord('5'), [ssCtrl], [ssCtrl]);
    AddKey(ecSetMarker6, ord('K'), ord('6'), [ssCtrl], [ssCtrl]);
    AddKey(ecSetMarker7, ord('K'), ord('7'), [ssCtrl], [ssCtrl]);
    AddKey(ecSetMarker8, ord('K'), ord('8'), [ssCtrl], [ssCtrl]);
    AddKey(ecSetMarker9, ord('K'), ord('9'), [ssCtrl], [ssCtrl]);

    AddKey(ecSetMarker0, ord('K'), ord('0'), [ssCtrl], []);
    AddKey(ecSetMarker1, ord('K'), ord('1'), [ssCtrl], []);
    AddKey(ecSetMarker2, ord('K'), ord('2'), [ssCtrl], []);
    AddKey(ecSetMarker3, ord('K'), ord('3'), [ssCtrl], []);
    AddKey(ecSetMarker4, ord('K'), ord('4'), [ssCtrl], []);
    AddKey(ecSetMarker5, ord('K'), ord('5'), [ssCtrl], []);
    AddKey(ecSetMarker6, ord('K'), ord('6'), [ssCtrl], []);
    AddKey(ecSetMarker7, ord('K'), ord('7'), [ssCtrl], []);
    AddKey(ecSetMarker8, ord('K'), ord('8'), [ssCtrl], []);
    AddKey(ecSetMarker9, ord('K'), ord('9'), [ssCtrl], []);

    AddKey(ecGotoMarker0, ord('Q'), ord('0'), [ssCtrl], [ssCtrl]);
    AddKey(ecGotoMarker1, ord('Q'), ord('1'), [ssCtrl], [ssCtrl]);
    AddKey(ecGotoMarker2, ord('Q'), ord('2'), [ssCtrl], [ssCtrl]);
    AddKey(ecGotoMarker3, ord('Q'), ord('3'), [ssCtrl], [ssCtrl]);
    AddKey(ecGotoMarker4, ord('Q'), ord('4'), [ssCtrl], [ssCtrl]);
    AddKey(ecGotoMarker5, ord('Q'), ord('5'), [ssCtrl], [ssCtrl]);
    AddKey(ecGotoMarker6, ord('Q'), ord('6'), [ssCtrl], [ssCtrl]);
    AddKey(ecGotoMarker7, ord('Q'), ord('7'), [ssCtrl], [ssCtrl]);
    AddKey(ecGotoMarker8, ord('Q'), ord('8'), [ssCtrl], [ssCtrl]);
    AddKey(ecGotoMarker9, ord('Q'), ord('9'), [ssCtrl], [ssCtrl]);

    AddKey(ecGotoMarker0, ord('Q'), ord('0'), [ssCtrl], []);
    AddKey(ecGotoMarker1, ord('Q'), ord('1'), [ssCtrl], []);
    AddKey(ecGotoMarker2, ord('Q'), ord('2'), [ssCtrl], []);
    AddKey(ecGotoMarker3, ord('Q'), ord('3'), [ssCtrl], []);
    AddKey(ecGotoMarker4, ord('Q'), ord('4'), [ssCtrl], []);
    AddKey(ecGotoMarker5, ord('Q'), ord('5'), [ssCtrl], []);
    AddKey(ecGotoMarker6, ord('Q'), ord('6'), [ssCtrl], []);
    AddKey(ecGotoMarker7, ord('Q'), ord('7'), [ssCtrl], []);
    AddKey(ecGotoMarker8, ord('Q'), ord('8'), [ssCtrl], []);
    AddKey(ecGotoMarker9, ord('Q'), ord('9'), [ssCtrl], []);

    AddKey(ecCodeComplite, ord('C'), 0, [ssCtrl, ssShift], []);
    AddKey(ecCodeTemplate, ord('J'), 0, [ssCtrl], []);
  end;
end;

procedure ResetClassicDefaults(K: TSynEditKeyStrokes);
  procedure AddKey(const ACmd: TSynEditorCommand; const AKey, AKey2: word;
     const AShift, AShift2: TShiftState);
  begin
    with K.Add do
    begin
      Key := AKey;
      Key2 := AKey2;
      Shift := AShift;
      Shift2 := AShift2;
      Command := ACmd;
    end;
  end;

begin
  if Assigned(K) then
  begin
    K.ResetDefaults;
    // Переопределяем значение по умолчанию
    K.Items[K.FindCommand(ecColumnSelect)].Shift := [ssCtrl, ssAlt];

    AddKey(ecFind, ord('Q'), ord('F'), [ssCtrl], [ssCtrl]);
    AddKey(ecFindNext, ord('L'), 0, [ssCtrl], []);
    AddKey(ecReplace, ord('Q'), ord('R'), [ssCtrl], [ssCtrl]);
    AddKey(ecDeleteItem, ord('D'), 0, [ssCtrl], []);
    AddKey(ecCommit, VK_F2, 0, [], []);
    AddKey(ecDebugRun, VK_F9, 0, [], []);
    AddKey(ecDebugStepIn, VK_F7, 0, [], []);
    AddKey(ecDebugStepOut, VK_F8, 0, [], []);
    AddKey(ecDebugGotoCursor, VK_F4, 0, [], []);
    AddKey(ecProgramReset, VK_F2, 0, [ssCtrl], []);
    AddKey(ecToggleBreakPoint, VK_F8, 0, [ssCtrl], []);
    AddKey(ecAddWatch, VK_F7, 0, [ssCtrl], []);
    AddKey(ecPrepare, VK_F9, 0, [ssCtrl], []);
    AddKey(ecDebugStepOut, VK_F7, 0, [ssShift], []);
    AddKey(ecEvaluate, VK_F4, 0, [ssCtrl], []);
    AddKey(ecGotoToInclude, VK_RETURN, 0, [ssCtrl], []);
    AddKey(ecSelMoveRight, ord('K'), ord('I'), [ssCtrl], [ssCtrl]);
    AddKey(ecSelMoveLeft, ord('K'), ord('U'), [ssCtrl], [ssCtrl]);
    AddKey(ecComentBlock, ord('B'), ord('C'), [ssCtrl], [ssCtrl]);
    AddKey(ecUnComentBlock, ord('B'), ord('U'), [ssCtrl], [ssCtrl]);

    AddKey(ecSetMarker0, ord('K'), ord('0'), [ssCtrl], [ssCtrl]);
    AddKey(ecSetMarker1, ord('K'), ord('1'), [ssCtrl], [ssCtrl]);
    AddKey(ecSetMarker2, ord('K'), ord('2'), [ssCtrl], [ssCtrl]);
    AddKey(ecSetMarker3, ord('K'), ord('3'), [ssCtrl], [ssCtrl]);
    AddKey(ecSetMarker4, ord('K'), ord('4'), [ssCtrl], [ssCtrl]);
    AddKey(ecSetMarker5, ord('K'), ord('5'), [ssCtrl], [ssCtrl]);
    AddKey(ecSetMarker6, ord('K'), ord('6'), [ssCtrl], [ssCtrl]);
    AddKey(ecSetMarker7, ord('K'), ord('7'), [ssCtrl], [ssCtrl]);
    AddKey(ecSetMarker8, ord('K'), ord('8'), [ssCtrl], [ssCtrl]);
    AddKey(ecSetMarker9, ord('K'), ord('9'), [ssCtrl], [ssCtrl]);

    AddKey(ecSetMarker0, ord('K'), ord('0'), [ssCtrl], []);
    AddKey(ecSetMarker1, ord('K'), ord('1'), [ssCtrl], []);
    AddKey(ecSetMarker2, ord('K'), ord('2'), [ssCtrl], []);
    AddKey(ecSetMarker3, ord('K'), ord('3'), [ssCtrl], []);
    AddKey(ecSetMarker4, ord('K'), ord('4'), [ssCtrl], []);
    AddKey(ecSetMarker5, ord('K'), ord('5'), [ssCtrl], []);
    AddKey(ecSetMarker6, ord('K'), ord('6'), [ssCtrl], []);
    AddKey(ecSetMarker7, ord('K'), ord('7'), [ssCtrl], []);
    AddKey(ecSetMarker8, ord('K'), ord('8'), [ssCtrl], []);
    AddKey(ecSetMarker9, ord('K'), ord('9'), [ssCtrl], []);

    AddKey(ecGotoMarker0, ord('Q'), ord('0'), [ssCtrl], [ssCtrl]);
    AddKey(ecGotoMarker1, ord('Q'), ord('1'), [ssCtrl], [ssCtrl]);
    AddKey(ecGotoMarker2, ord('Q'), ord('2'), [ssCtrl], [ssCtrl]);
    AddKey(ecGotoMarker3, ord('Q'), ord('3'), [ssCtrl], [ssCtrl]);
    AddKey(ecGotoMarker4, ord('Q'), ord('4'), [ssCtrl], [ssCtrl]);
    AddKey(ecGotoMarker5, ord('Q'), ord('5'), [ssCtrl], [ssCtrl]);
    AddKey(ecGotoMarker6, ord('Q'), ord('6'), [ssCtrl], [ssCtrl]);
    AddKey(ecGotoMarker7, ord('Q'), ord('7'), [ssCtrl], [ssCtrl]);
    AddKey(ecGotoMarker8, ord('Q'), ord('8'), [ssCtrl], [ssCtrl]);
    AddKey(ecGotoMarker9, ord('Q'), ord('9'), [ssCtrl], [ssCtrl]);

    AddKey(ecGotoMarker0, ord('Q'), ord('0'), [ssCtrl], []);
    AddKey(ecGotoMarker1, ord('Q'), ord('1'), [ssCtrl], []);
    AddKey(ecGotoMarker2, ord('Q'), ord('2'), [ssCtrl], []);
    AddKey(ecGotoMarker3, ord('Q'), ord('3'), [ssCtrl], []);
    AddKey(ecGotoMarker4, ord('Q'), ord('4'), [ssCtrl], []);
    AddKey(ecGotoMarker5, ord('Q'), ord('5'), [ssCtrl], []);
    AddKey(ecGotoMarker6, ord('Q'), ord('6'), [ssCtrl], []);
    AddKey(ecGotoMarker7, ord('Q'), ord('7'), [ssCtrl], []);
    AddKey(ecGotoMarker8, ord('Q'), ord('8'), [ssCtrl], []);
    AddKey(ecGotoMarker9, ord('Q'), ord('9'), [ssCtrl], []);

    AddKey(ecCodeComplite, ord('C'), 0, [ssCtrl, ssShift], []);
  end;
end;

{ TdlgOptionsManager }

function TdlgOptionsManager.Execute: Boolean;
begin
  cbLanguages.ItemIndex := 0;
  cbLanguagesChange(nil);
  Result := ShowModal = mrOk;
end;

procedure TdlgOptionsManager.cbLanguagesChange(Sender: TObject);
var
  I: Integer;
begin
  ColorGrid.ClickEnablesColor := False;
  ColorGrid.ForegroundEnabled := False;
  ColorGrid.BackgroundEnabled := False;
  SetChildEnabled(False, gbNoneGround);
  SetChildEnabled(False, gbTextAttr);
  case cbLanguages.ItemIndex of
    0:
    begin
      FSynHighLighter := SynVBScriptSyn1;
      seTestScript.Highlighter := SynVBScriptSyn1;
      seTestScript.Lines.Clear;
      seTestScript.Lines.Add(''' Comment');
      seTestScript.Lines.Add('function TestFunction(StartDate, FinishDate)');
      seTestScript.Lines.Add('  a = 324234');
      seTestScript.Lines.Add('  b = "Test String"');
      seTestScript.Lines.Add('  c = a + b '' Execution point');
      seTestScript.Lines.Add('  TestFunction = OtherFunction(c)');
      seTestScript.Lines.Add('TestFunction = TestFunction + OtherFunction1 '' Enable breakpoint');
      seTestScript.Lines.Add(''' Invalid breakpoint');
      seTestScript.Lines.Add('  a = 1/0  ''Error line');
      seTestScript.Lines.Add('end function');
      seTestScript.BlockBegin := Point(3, 6);
      seTestScript.BlockEnd := Point(15, 6);
      TSynVBScriptSyn(FSynHighLighter).MarkBlockAttri.OnChange :=
        SelectColorChange;
    end;
    1:
    begin
      FSynHighLighter := SynJScriptSyn1;
      seTestScript.Highlighter := SynJScriptSyn1;
      seTestScript.Lines.Clear;
      seTestScript.Lines.Add('// Comment');
      seTestScript.Lines.Add('function TestFunction()');
      seTestScript.Lines.Add('{');
      seTestScript.Lines.Add('  a = ''Test string'';');
      seTestScript.Lines.Add('  b = 123123;');
      seTestScript.Lines.Add('  c = a + b;');
      seTestScript.Lines.Add('  OtherProperty = OtherFunction(c)');
      seTestScript.Lines.Add('  Return(OtherProperty)');
      seTestScript.Lines.Add('}');
    end;
    2:
    begin
      FSynHighLighter := SynSQLSyn1;
      seTestScript.Highlighter := SynSQLSyn1;
      seTestScript.Lines.Clear;
      seTestScript.Lines.Add('/* Comment */');
      seTestScript.Lines.Add('SELECT');
      seTestScript.Lines.Add('  *');
      seTestScript.Lines.Add('FROM');
      seTestScript.Lines.Add('  gd_contact');
      seTestScript.Lines.Add('WHERE');
      seTestScript.Lines.Add('  id IN (147, 148)');
      seTestScript.Lines.Add('  AND parent IS NULL');
      seTestScript.Lines.Add('  AND name LIKE "Golden"');
    end;
  else
    Assert(False);
  end;
  lbAttributes.Items.Clear;
  for I := 0 to FSynHighLighter.AttrCount - 1 do
    lbAttributes.Items.Add(FSynHighLighter.Attribute[I].Name);
  SelectColorChange(nil);
end;

procedure TdlgOptionsManager.lbAttributesClick(Sender: TObject);
begin
  ColorGrid.ClickEnablesColor := True;
  SetChildEnabled(True, gbNoneGround);
  SetChildEnabled(True, gbTextAttr);
  ColorGrid.BackgroundEnabled := FSynHighLighter.Attribute[lbAttributes.ItemIndex].Background <> clNone;
  ColorGrid.ForegroundEnabled := FSynHighLighter.Attribute[lbAttributes.ItemIndex].Foreground <> clNone;
  ColorGrid.BackgroundIndex := ColorGrid.ColorToIndex(FSynHighLighter.Attribute[lbAttributes.ItemIndex].Background);
  ColorGrid.ForegroundIndex := ColorGrid.ColorToIndex(FSynHighLighter.Attribute[lbAttributes.ItemIndex].Foreground);
  cbBold.Checked := fsBold in FSynHighLighter.Attribute[lbAttributes.ItemIndex].Style;
  cbItalic.Checked := fsItalic in FSynHighLighter.Attribute[lbAttributes.ItemIndex].Style;
  cbUnderLine.Checked := fsUnderLine in FSynHighLighter.Attribute[lbAttributes.ItemIndex].Style;
  cbStrikeOut.Checked := fsStrikeOut in FSynHighLighter.Attribute[lbAttributes.ItemIndex].Style;
  cbFont.Checked := not ColorGrid.ForegroundEnabled;
  cbBack.Checked := not ColorGrid.BackgroundEnabled;
  FLastIndex := lbAttributes.ItemIndex;
end;

procedure TdlgOptionsManager.ColorGridChange(Sender: TObject);
begin
  if Assigned(FSynHighLighter) and (lbAttributes.ItemIndex = FLastIndex) then
  begin
    if ColorGrid.BackgroundEnabled then
      FSynHighLighter.Attribute[FLastIndex].Background := ColorGrid.BackgroundColor;
    if ColorGrid.ForegroundEnabled then
      FSynHighLighter.Attribute[FLastIndex].Foreground := ColorGrid.ForegroundColor;
    cbBack.Checked := not ColorGrid.BackgroundEnabled;
    cbFont.Checked := not ColorGrid.ForegroundEnabled;
  end;
end;

procedure TdlgOptionsManager.cbFontClick(Sender: TObject);
begin
  if Assigned(FSynHighLighter) and (lbAttributes.ItemIndex = FLastIndex) then
  begin
    ColorGrid.ForegroundEnabled := not cbFont.Checked;
    if not ColorGrid.ForegroundEnabled then
      FSynHighLighter.Attribute[FLastIndex].Foreground := clNone;
  end;
end;

procedure TdlgOptionsManager.cbBackClick(Sender: TObject);
begin
  if Assigned(FSynHighLighter) and (lbAttributes.ItemIndex = FLastIndex) then
  begin
    ColorGrid.BackgroundEnabled := not cbBack.Checked;
    if not ColorGrid.BackgroundEnabled then
      FSynHighLighter.Attribute[FLastIndex].Background := clNone;
  end;
end;

procedure TdlgOptionsManager.cbBoldClick(Sender: TObject);
begin
  if Assigned(FSynHighLighter) and (lbAttributes.ItemIndex = FLastIndex) then
  begin
    if cbBold.Checked then
      FSynHighLighter.Attribute[FLastIndex].Style :=
       FSynHighLighter.Attribute[FLastIndex].Style + [fsBold]
    else
      FSynHighLighter.Attribute[FLastIndex].Style :=
       FSynHighLighter.Attribute[FLastIndex].Style - [fsBold]
  end;
end;

procedure TdlgOptionsManager.cbItalicClick(Sender: TObject);
begin
  if Assigned(FSynHighLighter) and (lbAttributes.ItemIndex = FLastIndex) then
  begin
    if cbItalic.Checked then
      FSynHighLighter.Attribute[FLastIndex].Style :=
       FSynHighLighter.Attribute[FLastIndex].Style + [fsItalic]
    else
      FSynHighLighter.Attribute[FLastIndex].Style :=
       FSynHighLighter.Attribute[FLastIndex].Style - [fsItalic]
  end;
end;

procedure TdlgOptionsManager.cbUnderLineClick(Sender: TObject);
begin
  if Assigned(FSynHighLighter) and (lbAttributes.ItemIndex = FLastIndex) then
  begin
    if cbUnderLine.Checked then
      FSynHighLighter.Attribute[FLastIndex].Style :=
       FSynHighLighter.Attribute[FLastIndex].Style + [fsUnderLine]
    else
      FSynHighLighter.Attribute[FLastIndex].Style :=
       FSynHighLighter.Attribute[FLastIndex].Style - [fsUnderLine]
  end;
end;

procedure TdlgOptionsManager.cbStrikeOutClick(Sender: TObject);
begin
  if Assigned(FSynHighLighter) and (lbAttributes.ItemIndex = FLastIndex) then
  begin
    if cbStrikeOut.Checked then
      FSynHighLighter.Attribute[FLastIndex].Style :=
       FSynHighLighter.Attribute[FLastIndex].Style + [fsStrikeOut]
    else
      FSynHighLighter.Attribute[FLastIndex].Style :=
       FSynHighLighter.Attribute[FLastIndex].Style - [fsStrikeOut]
  end;
end;

procedure TdlgOptionsManager.SetChildEnabled(const AnEnabled: Boolean;
  const AnWinControl: TWinControl);
var
  I: Integer;
begin           
  AnWinControl.Enabled := AnEnabled;
  for I := 0 to AnWinControl.ControlCount - 1 do
    if AnWinControl.Controls[I] is TWinControl then
      SetChildEnabled(AnEnabled, AnWinControl.Controls[I] as TWinControl);
end;

procedure TdlgOptionsManager.btnFontClick(Sender: TObject);
begin
  FontDialog1.Font.Assign(seTestScript.Font);
  if FontDialog1.Execute then
    seTestScript.Font.Assign(FontDialog1.Font);
end;

procedure TdlgOptionsManager.seTestScriptSpecialLineColors(Sender: TObject;
  Line: Integer; var Special: Boolean; var FG, BG: TColor);
begin
  if FSynHighLighter is TSynVBScriptSyn then
  begin
    case Line of
      5:
        begin
          Special := TRUE;
          FG := TSynVBScriptSyn(FSynHighLighter).ExecutionPointAttri.Foreground;
          BG := TSynVBScriptSyn(FSynHighLighter).ExecutionPointAttri.Background;
        end;
      7:
        begin
          Special := TRUE;
          FG := TSynVBScriptSyn(FSynHighLighter).EnableBreakPointAttri.Foreground;
          BG := TSynVBScriptSyn(FSynHighLighter).EnableBreakPointAttri.Background;
        end;
      8:
        begin
          Special := TRUE;
          FG := TSynVBScriptSyn(FSynHighLighter).InvalidBreakPointAttri.Foreground;
          BG := TSynVBScriptSyn(FSynHighLighter).InvalidBreakPointAttri.Background;
        end;
      9:
        begin
          Special := TRUE;
          FG := TSynVBScriptSyn(FSynHighLighter).ErrorLineAttri.Foreground;
          BG := TSynVBScriptSyn(FSynHighLighter).ErrorLineAttri.Background;
        end;
    end;
  end;
end;

procedure TdlgOptionsManager.SelectColorChange(Sender: TObject);
begin
  if FSynHighLighter is TSynVBScriptSyn then
  begin
    seTestScript.SelectedColor.Foreground :=
      TSynVBScriptSyn(FSynHighLighter).MarkBlockAttri.Foreground;
    seTestScript.SelectedColor.Background :=
      TSynVBScriptSyn(FSynHighLighter).MarkBlockAttri.Background;
  end else
  begin
    seTestScript.SelectedColor.Foreground := clHighlightText;
    seTestScript.SelectedColor.Background := clHighlight;
  end;
end;

procedure TdlgOptionsManager.actEditKeystrokesUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := lbKeyMapping.ItemIndex > - 1;
end;

procedure TdlgOptionsManager.actEditKeystrokesExecute(Sender: TObject);
begin
  if lbKeyMapping.ItemIndex > - 1 then
  begin
    with TSynEditKeystrokesEditorForm.Create(nil) do
    try
      Keystrokes := GetKeyStrokes(lbKeyMapping.ItemIndex);
      if ShowModal = mrOk then
      begin
        case lbKeyMapping.ItemIndex of
          0: Default.KeyStrokes.Assign(Keystrokes);
          1: Classic.KeyStrokes.Assign(Keystrokes);
          2: NewClassic.KeyStrokes.Assign(Keystrokes);
          3: VisualStudio.KeyStrokes.Assign(KeyStrokes);
        end;
      end;
    finally
      Free;
    end;
  end;
end;

procedure TdlgOptionsManager.lbKeyMappingClick(Sender: TObject);
begin
  KeystrokesIndex := lbKeymapping.ItemIndex;
end;

function TdlgOptionsManager.GetKeyStrokes(
  Index: Integer): TSynEditKeyStrokes;
begin
  Result := nil;
  if (Index > - 1) and (Index < 4) then
  begin
    case Index of
      0: Result := Default.KeyStrokes;
      1: Result := Classic.KeyStrokes;
      2: Result := NewClassic.KeyStrokes;
      3: Result := VisualStudio.KeyStrokes;
    end;
  end;
end;

procedure TdlgOptionsManager.SetKeystrokes(
  const Value: TSynEditKeyStrokes);
begin
  FKeystrokes := Value;
  cbEditorSpeedSettings.ItemIndex := GetKeyStrokesIntex(Value);
  lbKeyMapping.ItemIndex := cbEditorSpeedSettings.ItemIndex;
end;

function TdlgOptionsManager.GetKeyStrokesIntex(
  KeyStrokes: TSynEditKeyStrokes): Integer;
begin
  Result := - 1;
  if Assigned(KeyStrokes) then
  begin
    if KeyStrokes = Default.KeyStrokes then
      Result := 0
    else
    if KeyStrokes = Classic.KeyStrokes then
      Result := 1
    else
    if KeyStrokes = NewClassic.KeyStrokes then
      Result := 2
    else
    if KeyStrokes = VisualStudio.KeyStrokes then
      Result := 3;
  end;
end;

procedure TdlgOptionsManager.cbEditorSpeedSettingsChange(Sender: TObject);
begin
  KeystrokesIndex := cbEditorSpeedSettings.ItemIndex;
end;

procedure TdlgOptionsManager.SetKeyStrokesIndex(const Value: Integer);
begin
  FKeyStrokesIndex := Value;
  Keystrokes := GetKeyStrokes(Value);
end;

procedure TdlgOptionsManager.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := True;
  if ModalResult = mrOk then
  begin
    try
      StrToInt(cbRightMargin.Text);
    except
      on E: EConvertError do
      begin
        MessageBox(Handle, 'Неправильное значение поля Right margin', MSG_ERROR,
          MB_OK or MB_ICONERROR);
        CanClose := False;
        Exit;
      end;
    end;

    try
      StrToInt(cbGutterWidth.Text);
    except
      on E: EConvertError do
      begin
        MessageBox(Handle, 'Неправильное значение поля Gutter width', MSG_ERROR,
          MB_OK or MB_ICONERROR);
        CanClose := False;
        Exit;
      end;
    end;

    try
      StrToInt(cbUndoLimit.Text);
    except
      on E: EConvertError do
      begin
        MessageBox(Handle, 'Неправильное значение поля Undo limit', MSG_ERROR,
          MB_OK or MB_ICONERROR);
        CanClose := False;
        Exit;
      end;
    end;

    try
      StrToInt(cbTabStops.Text);
    except
      on E: EConvertError do
      begin
        MessageBox(Handle, 'Неправильное значение поля Tab stops', MSG_ERROR,
          MB_OK or MB_ICONERROR);
        CanClose := False;
        Exit;
      end;
    end;
  end;
end;

procedure TdlgOptionsManager.actResetKeystrokesExecute(Sender: TObject);
begin
  if lbKeyMapping.ItemIndex > - 1 then
  begin
    case lbKeyMapping.ItemIndex of
      0: ResetDefaultDefaults(Default.KeyStrokes);
      1: ResetClassicDefaults(Classic.KeyStrokes);
//      2: NewClassic.KeyStrokes.Assign(Keystrokes);
//      3: VisualStudio.KeyStrokes.Assign(KeyStrokes);
    end;
  end;
end;

end.
