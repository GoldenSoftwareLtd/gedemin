unit FileView;

// -----------------------------------------------------------------------------
// Application:     TextDiff                                                   .
// Module:          FileView                                                   .
// Version:         4.1                                                        .
// Date:            16-JAN-2004                                                .
// Target:          Win32, Delphi 7                                            .
// Author:          Angus Johnson - angusj-AT-myrealbox-DOT-com                .
// Copyright;       © 2003-2004 Angus Johnson                                  .
// -----------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, {$IFNDEF VER130}Variants,{$ENDIF} Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, CodeEditor, ToolWin, Clipbrd, Searches, FindReplace,
  Main, HashUnit, DiffUnit, Menus, ComCtrls;

type
  TFilesFrame = class(TFrame)
    pnlMain: TPanel;
    Splitter1: TSplitter;
    pnlLeft: TPanel;
    pnlCaptionLeft: TPanel;
    pnlRight: TPanel;
    pnlCaptionRight: TPanel;
    pnlDisplay: TPanel;
    pbDiffMarker: TPaintBox;
    pbScrollPosMarker: TPaintBox;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    FontDialog1: TFontDialog;
    StatusBar1: TStatusBar;
    procedure pbScrollPosMarkerPaint(Sender: TObject);
    procedure pbDiffMarkerPaint(Sender: TObject);
    procedure FrameResize(Sender: TObject);
  private
    Diff: TDiff;
    Lines1, Lines2: TStrings;
    fStatusbarStr: string;
    CaretPosY: integer;
    pbDiffMarkerBmp: TBitmap;
    Search: TSearch;
    FindInfo: TFindInfo;
    FShowDiffsOnly: Boolean;
    procedure UpdateDiffMarkerBmp;
    procedure PaintLeftMargin(Sender: TObject; Canvas: TCanvas;
      MarginRec: TRect; LineNo, Tag: integer);
    procedure SyncScroll(Sender: TObject);
    procedure CodeEditOnEnter(Sender: TObject);
    procedure CodeEditOnExit(Sender: TObject);
    procedure ToggleLinkedScroll(IsLinked: boolean);
    procedure CodeEditOnCaretPtChange(Sender: TObject);
    procedure ReplaceDown(CodeEdit: TCodeEdit);
    procedure ReplaceUp(CodeEdit: TCodeEdit);
    function GetChangeCount: Integer;
//    procedure CancelClick(Sender: TObject);
//    procedure HorzSplitClick(Sender: TObject);

  public
    CodeEdit1: TCodeEdit;
    CodeEdit2: TCodeEdit;
    FilesCompared: boolean;
    destructor Destroy; override;

    procedure Setup;
    procedure Cleanup;
    procedure SetMenuEventsToFileView;
    procedure DisplayDiffs;
    procedure Compare(const S1, S2: String);
    procedure NextClick;
    procedure PrevClick;
    procedure FindClick(AOwner: TCustomForm);
    procedure HorzSplit(Checked: Boolean);
{ TODO -oAlexander :
FindReplace - нарисовать формы дл€ поиска и замены, 
или использовать стандартные √едеминовские. }
    procedure FindNextClick(AOwner: TCustomForm);
    procedure ReplaceClick(AOwner: TCustomForm);
    function FindNext(CodeEdit: TCodeEdit): boolean;
    function FindPrevious(CodeEdit: TCodeEdit): boolean;
    function CaretInClrBlk(CodeEdit: TCodeEdit): boolean;
    property ShowDiffsOnly: Boolean read FShowDiffsOnly write FShowDiffsOnly default false;
    property ChangeCount: Integer read GetChangeCount;
  end;

const
  ISMODIFIED_COLOR = $CCE0E0;

implementation

{$R *.dfm}

const
  addClr: TColor = $BB77FF;
  delClr: TColor = $F0CCA8;
  modClr: TColor = $6FFB8A;

//------------------------------------------------------------------------------
// TFilesFrame methods
//------------------------------------------------------------------------------

procedure TFilesFrame.Setup;
begin
  //the diff engine ...
  Diff := TDiff.create(self);

  //lines1 & lines2 contain the unmodified files
  Lines1 := TStringList.create;
  Lines2 := TStringList.create;

  //edit windows where color highlighing of diffs and changes are displayed ...
  CodeEdit1 := TCodeEdit.create(self);
  with CodeEdit1 do
  begin
    parent := pnlLeft;
    Align := alClient;
    OnCaretPtChange := CodeEditOnCaretPtChange;
    OnPaintLeftMargin := PaintLeftMargin;
    OnEnter := CodeEditOnEnter;
    OnExit := CodeEditOnExit;
    Font := FontDialog1.Font;
  end;
  CodeEdit2 := TCodeEdit.create(self);
  with CodeEdit2 do
  begin
    parent := pnlRight;
    Align := alClient;
    OnCaretPtChange := CodeEditOnCaretPtChange;
    OnPaintLeftMargin := PaintLeftMargin;
    OnEnter := CodeEditOnEnter;
    OnExit := CodeEditOnExit;
    Font := FontDialog1.Font;
  end;
  Search := TSearch.Create(self);

  CaretPosY := -1;
  pbScrollPosMarker.Canvas.Pen.Color := clBlack;
  pbScrollPosMarker.Canvas.Pen.Width := 2;

  pbDiffMarkerBmp := TBitmap.create;
  pbDiffMarkerBmp.Canvas.Brush.Color := clWindow;
end;
//------------------------------------------------------------------------------

procedure TFilesFrame.Cleanup;
begin
  Diff.free;
  Lines1.free;
  Lines2.free;
  pbDiffMarkerBmp.free;
end;
//------------------------------------------------------------------------------

procedure TFilesFrame.SetMenuEventsToFileView;
begin
  if FilesCompared then Statusbar1.Panels[3].text := fStatusbarStr
  else Statusbar1.Panels[3].text := '';
end;
//------------------------------------------------------------------------------

procedure TFilesFrame.FrameResize(Sender: TObject);
begin
  pnlLeft.width := pnlMain.ClientWidth div 2 -1;
end;
//------------------------------------------------------------------------------

procedure TFilesFrame.HorzSplit(Checked: Boolean);
begin
  if Checked then
  begin
    pnlLeft.Align := alTop;
    pnlLeft.Height := pnlMain.ClientHeight div 2 -1;
    Splitter1.Align := alTop;
    Splitter1.cursor := crVSplit;
  end else
  begin
    pnlLeft.Align := alLeft;
    pnlLeft.Width := pnlMain.ClientWidth div 2 -1;
    Splitter1.Align := alLeft;
    Splitter1.Left := 10;
    Splitter1.cursor := crHSplit;
  end;
  if Screen.ActiveControl is TCodeEdit then
    TCodeEdit(Screen.ActiveControl).ScrollCaretIntoView;
end;

{procedure TFilesFrame.HorzSplitClick(Sender: TObject);
begin
  if True then
  begin
    pnlLeft.Align := alTop;
    pnlLeft.Height := pnlMain.ClientHeight div 2 -1;
    Splitter1.Align := alTop;
    Splitter1.cursor := crVSplit;
  end else
  begin
    pnlLeft.Align := alLeft;
    pnlLeft.Width := pnlMain.ClientWidth div 2 -1;
    Splitter1.Align := alLeft;
    Splitter1.Left := 10;
    Splitter1.cursor := crHSplit;
  end;
  if Screen.ActiveControl is TCodeEdit then
    TCodeEdit(Screen.ActiveControl).ScrollCaretIntoView;
end;  }
//---------------------------------------------------------------------

procedure TFilesFrame.Compare(const S1, S2: String);
var
  i: integer;
  HashList1,HashList2: TList;
  CodeEdit: TCodeEdit;
begin
  FilesCompared := false;
  ToggleLinkedScroll(false);

  CodeEdit := CodeEdit1;
  Lines1.Text := S1;
  CodeEdit.Lines.Assign(Lines1);
  CodeEdit := CodeEdit2;
  Lines2.Text := S2;
  CodeEdit.Lines.Assign(Lines2);
  CodeEdit.AutoLineNum := true;
  pnlDisplay.visible := false;

  if (Lines1.Count = 0) or (Lines2.Count = 0) then exit;

  if (CodeEdit1.Lines.Modified) or (CodeEdit2.Lines.Modified) then
  begin
    if application.MessageBox(
      'Changes will be lost if you proceed with this compare.'#10+
      'Continue? ...',pchar(application.title),
      MB_YESNO or MB_ICONSTOP or MB_DEFBUTTON2) <> IDYES then exit;
  end;

  CodeEdit1.Color := clWindow;
  CodeEdit2.Color := clWindow;

  //THIS PROCEDURE IS WHERE ALL THE HEAVY LIFTING (COMPARING) HAPPENS ...

  HashList1 := TList.create;
  HashList2 := TList.create;
  try
    //Create the hash lists used to compare line differences.
    //nb - there is a small possibility of different lines hashing to the
    //same value. However the probability of an invalid match occuring
    //in proximity to its invalid partner is remote. Ideally, these hash
    //collisions should be managed by ? incrementing the hash value.
    HashList1.capacity := Lines1.Count;
    HashList2.capacity := Lines2.Count;
    begin
      for i := 0 to Lines1.Count-1 do
        HashList1.add(HashLine(Lines1[i],{mnuIgnoreCase.checked}False,{mnuIgnoreBlanks.checked}False));
      for i := 0 to Lines2.Count-1 do
        HashList2.add(HashLine(Lines2[i],{mnuIgnoreCase.checked}False,{mnuIgnoreBlanks.checked}False));
      //CALCULATE THE DIFFS HERE ...
      if not Diff.Execute(PIntArray(HashList1.List),PIntArray(HashList2.List),
        HashList1.count, HashList2.count) then exit;
      FilesCompared := true;
      DisplayDiffs;
      ToggleLinkedScroll(true);
    end;
  finally
    HashList1.Free;
    HashList2.Free;
  end;
end;
//---------------------------------------------------------------------

//---------------------------------------------------------------------

{procedure TFilesFrame.CancelClick(Sender: TObject);
begin
  Diff.Cancel;
  Statusbar1.Panels[3].text := 'Compare cancelled.'
end; }
//---------------------------------------------------------------------

procedure TFilesFrame.DisplayDiffs;
var
  i,j,k: integer;
  linesAdd, linesMod, linesDel: integer;

  procedure AddAndFormat(CodeEdit: TCodeEdit; const Text: string;
    Color: TColor; num: longint);
  var
    i: integer;
  begin
    i := CodeEdit.Lines.Add(Text);
    with CodeEdit.Lines.LineObj[i] do
    begin
      BackClr := Color;
      Tag := num;
    end;
  end;

begin

  //THIS IS WHERE THE TDIFF RESULT IS CONVERTED INTO COLOR HIGHLIGHTING ...

  linesAdd := 0; linesMod := 0; linesDel := 0;
  CodeEdit1.Lines.BeginUpdate;
  CodeEdit2.Lines.BeginUpdate;
  try
    CodeEdit1.Lines.Clear;
    CodeEdit2.Lines.Clear;
    CodeEdit1.AutoLineNum := false;
    CodeEdit2.AutoLineNum := false;
    CodeEdit1.GutterWidth := CodeEdit1.CharWidth*(Log10(Lines1.Count)+1);
    CodeEdit2.GutterWidth := CodeEdit2.CharWidth*(Log10(Lines2.Count)+1);

    ////////////////////////////////////////////////////////////////////////
    j := 0; k := 0;
    with {MainForm,} Diff do
    for i := 0 to ChangeCount-1 do
      with Changes[i] do
      begin
        //first add preceeding unmodified lines...
        if ShowDiffsOnly then
          inc(k, x - j)
        else
          while j < x do
          begin
             AddAndFormat(CodeEdit1, lines1[j],clWindow,j+1);
             AddAndFormat(CodeEdit2, lines2[k],clWindow,k+1);
             inc(j); inc(k);
          end;
        if Kind = ckAdd then
        begin
          for j := k to k+Range-1 do
          begin
           AddAndFormat(CodeEdit1, '',addClr,0);
           AddAndFormat(CodeEdit2,lines2[j],addClr,j+1);
           inc(linesDel);
          end;
          j := x;
          k := y+Range;
        end else if Kind = ckModify then
        begin
          for j := 0 to Range-1 do
          begin
           AddAndFormat(CodeEdit1, lines1[x+j],modClr,x+j+1);
           AddAndFormat(CodeEdit2,lines2[k+j],modClr,k+j+1);
           inc(linesMod);
          end;
          j := x+Range;
          k := y+Range;
        end else
        begin
          for j := x to x+Range-1 do
          begin
           AddAndFormat(CodeEdit1, lines1[j],delClr,j+1);
           AddAndFormat(CodeEdit2,'',delClr,0);
           inc(linesAdd);
          end;
          j := x+Range;
        end;
      end;
    //add remaining unmodified lines...
    if not ShowDiffsOnly then
      while j < lines1.count do
      begin
         AddAndFormat(CodeEdit1,lines1[j],clWindow,j+1);
         AddAndFormat(CodeEdit2,lines2[k],clWindow,k+1);
         inc(j); inc(k);
      end;
  finally
    CodeEdit1.Lines.EndUpdate;
    CodeEdit2.Lines.EndUpdate;
    CodeEdit1.Lines.Modified := false;
    CodeEdit2.Lines.Modified := false;
    UpdateDiffMarkerBmp;
    pbScrollPosMarker.Repaint;
  end;

  fStatusbarStr := '';
  {
  if MainForm.mnuIgnoreCase.checked then
    fStatusbarStr := 'Case Ignored';
  if MainForm.mnuIgnoreBlanks.checked then
    if fStatusbarStr = '' then
      fStatusbarStr := 'Blanks Ignored' else
      fStatusbarStr := fStatusbarStr + ', Blanks Ignored';}
  if fStatusbarStr <> '' then
    fStatusbarStr := '  ('+fStatusbarStr+')';

  if (linesAdd = 0) and (linesMod = 0) and (linesDel = 0) then
    fStatusbarStr := format('  Ќет различий.  %s', [ fStatusbarStr])
  else
    fStatusbarStr :=
      format('  %d строк добавлено, %d строк изменено, %d строк удалено.  %s',
        [ linesAdd, linesMod, linesDel, fStatusbarStr]);
  Statusbar1.Panels[3].text := fStatusbarStr;
end;
//---------------------------------------------------------------------

//Syncronise scrolling of both CodeEdits (once files are compared)...
var IsSyncing: boolean;

procedure TFilesFrame.SyncScroll(Sender: TObject);
begin
  if IsSyncing or not (Sender is TCodeEdit) then exit;
  IsSyncing := true; //stops recursion
  try
    if Sender = CodeEdit1 then
      CodeEdit2.TopVisibleLine := CodeEdit1.TopVisibleLine else
      CodeEdit1.TopVisibleLine := CodeEdit2.TopVisibleLine;
  finally
    IsSyncing := false;
  end;
  pbScrollPosMarkerPaint(self);
end;
//---------------------------------------------------------------------


//detect whenever the caret is moved into a colored difference block
function TFilesFrame.CaretInClrBlk(CodeEdit: TCodeEdit): boolean;
begin
  with CodeEdit do
    result := FilesCompared and (CaretPt.Y < lines.Count) and
      (lines.LineObj[CaretPt.Y].BackClr <> color);
end;
//---------------------------------------------------------------------

//change menu options depending on whether caret is in a diff color block or not
procedure TFilesFrame.CodeEditOnCaretPtChange(Sender: TObject);
//var
//  caretInClrBlock: boolean;
begin
  if not FilesCompared or not TCodeEdit(Sender).Focused then exit;
//  caretInClrBlock := CaretInClrBlk(TCodeEdit(Sender)); //ie calls function once
end;
//---------------------------------------------------------------------

procedure TFilesFrame.CodeEditOnEnter(Sender: TObject);
begin
  //keep compared text carets roughly in sync ...
  if FilesCompared and (CaretPosY >= 0) then
    with TCodeEdit(Sender) do CaretPt := Point(0,CaretPosY);
end;
//---------------------------------------------------------------------

procedure TFilesFrame.CodeEditOnExit(Sender: TObject);
begin
  //keep compared text carets roughly in sync too ...
  with TCodeEdit(Sender) do
    if (CaretPt.Y >= TopVisibleLine) and
      (CaretPt.Y <= TopVisibleLine + VisibleLines) then
      CaretPosY := CaretPt.Y
    else
      CaretPosY := -1;
end;
//---------------------------------------------------------------------

procedure TFilesFrame.ToggleLinkedScroll(IsLinked: boolean);
begin
  if IsLinked then //FilesCompared = true
  begin
    CodeEdit1.OnScroll := SyncScroll;
    CodeEdit2.OnScroll := SyncScroll;
    SyncScroll(CodeEdit1);
    pnlDisplay.visible := true;
  end else
  begin
    CodeEdit1.OnScroll := nil;
    CodeEdit2.OnScroll := nil;
    pnlDisplay.visible := false;
  end;
end;
//---------------------------------------------------------------------

procedure TFilesFrame.pbScrollPosMarkerPaint(Sender: TObject);
var
  yPos: integer;
begin
  //paint a marker indicating the vertical scroll position relative to change map
  if CodeEdit1.Lines.Count = 0 then exit;
  with pbScrollPosMarker do
  begin
    Canvas.Brush.Color := clWindow;
    Canvas.FillRect(ClientRect);
    with CodeEdit1 do
      yPos := TopVisibleLine + (ClientHeight div LineHeight) div 2;
    yPos := clientHeight*ypos div CodeEdit1.Lines.Count;
    Canvas.MoveTo(0,yPos);
    Canvas.LineTo(ClientWidth,yPos);
  end;
end;
//---------------------------------------------------------------------

procedure TFilesFrame.pbDiffMarkerPaint(Sender: TObject);
begin
  with pbDiffMarker do
    Canvas.StretchDraw(Rect(0,0,width,Height),pbDiffMarkerBmp);
end;
//---------------------------------------------------------------------

procedure TFilesFrame.UpdateDiffMarkerBmp;
var
  i,y: integer;
  clr: TColor;
  HeightRatio: single;
begin
  //draws a map of the differences ...
  if (CodeEdit1.Lines.Count = 0) or (CodeEdit2.Lines.Count = 0) then exit;
  HeightRatio := Screen.Height/CodeEdit1.Lines.Count;

  pbDiffMarkerBmp.Height := Screen.Height;
  pbDiffMarkerBmp.Width := pbDiffMarker.ClientWidth;
  pbDiffMarkerBmp.Canvas.Pen.Width := 2;
  with pbDiffMarkerBmp do Canvas.FillRect(Rect(0,0,width,height));
  with CodeEdit1 do
  begin
    for i := 0 to Lines.Count-1 do
    begin
      clr := CodeEdit1.lines.lineobj[i].BackClr;
      if clr = clWindow then continue;
      pbDiffMarkerBmp.Canvas.Pen.Color := clr;
      y := trunc(i*HeightRatio);
      pbDiffMarkerBmp.Canvas.MoveTo(0,y);
      pbDiffMarkerBmp.Canvas.LineTo(pbDiffMarkerBmp.Width,y);
    end;
  end;
  pbDiffMarker.Invalidate;
end;
//---------------------------------------------------------------------

procedure TFilesFrame.PaintLeftMargin(Sender: TObject; Canvas: TCanvas;
  MarginRec: TRect; LineNo, Tag: integer);
var
  numStr: string;
begin
  //custom numbering of lines based on Tag (tag == 0 means no number) ...
  if tag = 0 then exit;
  numStr := inttostr(tag);
  Canvas.TextOut(MarginRec.Left + TCodeEdit(Sender).GutterWidth -
    Canvas.textwidth(numStr)-4, MarginRec.Top, numStr);
end;
//---------------------------------------------------------------------

function TFilesFrame.FindNext(CodeEdit: TCodeEdit): boolean;
var
  i, PatLen, fndOffset: integer;

  function IsWholeWord(const line: string; xOffset, wordLen: integer): boolean;
  begin
    result := ((xOffset = 0) or not
      (line[xOffset] in ['A'..'Z','a'..'z','0'..'9'])) and
      ((xOffset + wordLen >= length(line)) or not
      (line[xOffset + wordLen +1] in ['A'..'Z','a'..'z','0'..'9']));
  end;

begin
  result := false;
  with CodeEdit do
  begin
    if CaretPt.Y >= lines.Count then exit;
    PatLen := length(Search.Pattern);
    Search.SetData(pchar(lines[CaretPt.Y]),lines.LineObj[CaretPt.Y].LineLen);
    i := CaretPt.Y;
    //search the first line, making sure we've gone beyond the caret ...
    fndOffset := Search.FindFirst;
    repeat
     if (fndOffset < 0) then break //not found
     else if (fndOffset < CaretPt.X) then fndOffset := Search.FindNext
     else if not FindInfo.wholeWords or
       IsWholeWord(lines[CaretPt.Y], fndOffset, PatLen) then break //found!!
     else fndOffset := Search.FindNext;
    until false;
    //if not found, search each subsequent line...
    while (fndOffset < 0) and (i < lines.Count-1) do
    begin
     inc(i);
     Search.SetData(pchar(lines[i]),lines.LineObj[i].LineLen);
     fndOffset := Search.FindFirst;
     if (fndOffset >= 0) and FindInfo.wholeWords then
       while (fndOffset >= 0) and not IsWholeWord(lines[i], fndOffset, PatLen) do
         fndOffset := Search.FindNext;
    end;
    if fndOffset < 0 then exit; //not found
    CaretPt := Point(fndOffset,i);
    SelLength := length(Search.Pattern);
    ScrollCaretIntoView;
    result := true;
  end;
end;
//------------------------------------------------------------------------------

function TFilesFrame.FindPrevious(CodeEdit: TCodeEdit): boolean;
var
  i, PatLen, fndOffset, lastFoundXPos: integer;

  function IsWholeWord(const line: string; xOffset, wordLen: integer): boolean;
  begin
    result := ((xOffset = 0) or not
      (line[xOffset] in ['A'..'Z','a'..'z','0'..'9'])) and
      ((xOffset + wordLen >= length(line)) or not
      (line[xOffset + wordLen +1] in ['A'..'Z','a'..'z','0'..'9']));
  end;

begin
  result := false;
  with CodeEdit do
  begin
    if CaretPt.Y >= lines.Count then exit;
    PatLen := length(Search.Pattern);
    //search the first line, going as close to but not beyond the caret ...
    lastFoundXPos := -1;
    fndOffset := Search.FindFirst;
    //avoid finding the same result with repeated searches ...
    while (fndOffset >= 0) and (fndOffset < CaretPt.X - PatLen) do
    begin
     if not FindInfo.wholeWords or
       IsWholeWord(lines[CaretPt.Y], fndOffset, PatLen) then
         lastFoundXPos := fndOffset;
     fndOffset := Search.FindNext;
    end;
    i := CaretPt.Y;
    //if not found, search each preceeding line...
    while (lastFoundXPos < 0) and (i > 0) do
    begin
     dec(i);
     Search.SetData(pchar(lines[i]),lines.LineObj[i].LineLen);
     fndOffset := Search.FindFirst;
     while (fndOffset >= 0) do
     begin
       if not FindInfo.wholeWords or IsWholeWord(lines[i], fndOffset, PatLen) then
         lastFoundXPos := fndOffset;
       fndOffset := Search.FindNext;
     end;
    end;
    if lastFoundXPos < 0 then exit; //not found
    CaretPt := Point(lastFoundXPos,i);
    SelLength := length(Search.Pattern);
    ScrollCaretIntoView;
    result := true;
  end;
end;
//------------------------------------------------------------------------------

procedure TFilesFrame.ReplaceDown(CodeEdit: TCodeEdit);
var
  ReplaceType: TReplaceType;
  CaretCoord: TPoint;
begin
  if FindInfo.replacePrompt then
  begin
    ReplaceType := rtOK;
    while FindNext(CodeEdit) do
    begin
      if ReplaceType <> rtAll then
      begin
        //get the clientcoords of Caret ...
        CaretCoord := CodeEdit.ClientPtFromCharPt(CodeEdit.CaretPt);
        //convert CaretCoord to form's Coords ...
        CaretCoord := CodeEdit.ClientToScreen(CaretCoord);
        CaretCoord := self.ScreenToClient(CaretCoord);
        //now display the replace prompt dialog ...
        ReplaceType := ReplacePrompt(TForm(owner), CaretCoord);
      end;
      case ReplaceType of
        rtOK:
          begin
            CodeEdit.Selection := FindInfo.replaceStr;
            if not FindInfo.replaceAll then exit; //replace One
          end;
        rtSkip: ; //do nothing
        rtAll:  CodeEdit.Selection := FindInfo.replaceStr;
        rtCancel: exit;
      end;
    end;
  end
  else if FindInfo.replaceAll then
    while FindNext(CodeEdit) do
      CodeEdit.Selection := FindInfo.replaceStr
  else if FindNext(CodeEdit) then //replace One - no prompt
    CodeEdit.Selection := FindInfo.replaceStr;
end;
//------------------------------------------------------------------------------

procedure TFilesFrame.ReplaceUp(CodeEdit: TCodeEdit);
var
  ReplaceType: TReplaceType;
  CaretCoord: TPoint;
begin
  if FindInfo.replacePrompt then
  begin
    ReplaceType := rtOK;
    while FindPrevious(CodeEdit) do
    begin
      if ReplaceType <> rtAll then
      begin
        //get the clientcoords of Caret ...
        CaretCoord := CodeEdit.ClientPtFromCharPt(CodeEdit.CaretPt);
        //convert CaretCoord to form's Coords ...
        CaretCoord := CodeEdit.ClientToScreen(CaretCoord);
        CaretCoord := self.ScreenToClient(CaretCoord);
        //now display the replace prompt dialog ...
        ReplaceType := ReplacePrompt(TForm(owner), CaretCoord);
      end;
      case ReplaceType of
        rtOK:
          begin
            CodeEdit.Selection := FindInfo.replaceStr;
            if not FindInfo.replaceAll then exit; //replace One
          end;
        rtSkip: ; //do nothing
        rtAll:  CodeEdit.Selection := FindInfo.replaceStr;
        rtCancel: exit;
      end;
    end;
  end
  else if FindInfo.replaceAll then
    while FindPrevious(CodeEdit) do
      CodeEdit.Selection := FindInfo.replaceStr
  else if FindPrevious(CodeEdit) then //replace One - no prompt
    CodeEdit.Selection := FindInfo.replaceStr;
end;
//------------------------------------------------------------------------------

//go to next color block (only enabled if files have been compared)
procedure TFilesFrame.NextClick;
var
  i: integer;
  clr: TColor;
  CodeEdit: TCodeEdit;
begin
  if CodeEdit1.Focused then
    CodeEdit := CodeEdit1
  else if CodeEdit2.Focused then
    CodeEdit := CodeEdit2
  else begin
    CodeEdit1.SetFocus;
    CodeEdit := CodeEdit1;
  end;

  //get next colored block ...
  with CodeEdit do
  begin
    if lines.Count = 0 then exit;
    i := CaretPt.Y;
    clr := lines.LineObj[i].BackClr;
    repeat
      inc(i);
    until (i = Lines.Count) or (lines.LineObj[i].BackClr <> clr);
    if (i = Lines.Count) then //do nothing here
    else if lines.LineObj[i].BackClr = color then
    repeat
      inc(i);
    until (i = Lines.Count) or (lines.LineObj[i].BackClr <> color);
    if (i = Lines.Count) then
    begin
      beep;  //not found
      exit;
    end;
    CaretPt := Point(0,i);
    //now make sure as much of the block as possible is visible ...
    clr := lines.LineObj[i].BackClr;
    repeat
      inc(i);
    until(i = Lines.Count) or (lines.LineObj[i].BackClr <> clr);
    if i >= TopVisibleLine + visibleLines then TopVisibleLine := CaretPt.Y;
  end;
end;
//---------------------------------------------------------------------

//go to previous color block (only enabled if files have been compared)
procedure TFilesFrame.PrevClick;
var
  i: integer;
  clr: TColor;
  CodeEdit: TCodeEdit;
label notFound;
begin
  if CodeEdit1.Focused then
    CodeEdit := CodeEdit1
  else if CodeEdit2.Focused then
    CodeEdit := CodeEdit2
  else begin
    CodeEdit1.SetFocus;
    CodeEdit := CodeEdit1;
  end
  ;

  //get prev colored block ...
  with CodeEdit do
  begin
    i := CaretPt.Y;
    if i = Lines.count then goto notFound;
    clr := lines.LineObj[i].BackClr;
    repeat
      dec(i);
    until (i < 0) or (lines.LineObj[i].BackClr <> clr);
    if i < 0 then goto notFound;
    if lines.LineObj[i].BackClr = Color then
    repeat
      dec(i);
    until (i < 0) or (lines.LineObj[i].BackClr <> Color);
    if i < 0 then goto notFound;
    clr := lines.LineObj[i].BackClr;
    while (i > 0) and (lines.LineObj[i-1].BackClr = clr) do dec(i);
    //'i' now at the beginning of the previous color block.
    CaretPt := Point(0,i);
    exit;
  end;

notFound: beep;
end;
//---------------------------------------------------------------------

destructor TFilesFrame.Destroy;
begin
  CleanUp;
  inherited;
end;

procedure TFilesFrame.FindClick(AOwner: TCustomForm);
begin
  if not GetFindInfo(AOwner, FindInfo) then exit;
  Search.Pattern := FindInfo.findStr;
  Search.CaseSensitive := not FindInfo.ignoreCase;
  FindNextClick(nil);
end;

procedure TFilesFrame.FindNextClick(AOwner: TCustomForm);
var
  codeEdit: TCodeEdit;
begin
  if FindInfo.findStr = '' then
    FindClick(AOwner)
  else
  begin
    if codeEdit2 = Screen.activeControl then
      codeEdit := codeEdit2 else
      codeEdit := codeEdit1;
    if FindInfo.directionDown then
    begin
      if not FindNext(CodeEdit) then beep;
    end else
      if not FindPrevious(CodeEdit) then beep;
  end;
end;

procedure TFilesFrame.ReplaceClick(AOwner: TCustomForm);
var
  codeEdit: TCodeEdit;
begin
  if not GetReplaceInfo(AOwner, FindInfo) then exit;
  Search.Pattern := FindInfo.findStr;
  Search.CaseSensitive := not FindInfo.ignoreCase;
  if codeEdit2 = Screen.activeControl then
    codeEdit := codeEdit2 else
    codeEdit := codeEdit1;
  if FindInfo.directionDown then
    ReplaceDown(CodeEdit) else
    ReplaceUp(CodeEdit);
end;

function TFilesFrame.GetChangeCount: Integer;
begin
  Result := Diff.ChangeCount;
end;

end.
