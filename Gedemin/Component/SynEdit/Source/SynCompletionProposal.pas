{-------------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: SynCompletionProposal.pas, released 2000-04-11.
The Original Code is based on mwCompletionProposal.pas by Cyrille de Brebisson,
part of the mwEdit component suite.
Portions created by Cyrille de Brebisson are Copyright (C) 1999
Cyrille de Brebisson. All Rights Reserved.

Contributors to the SynEdit and mwEdit projects are listed in the
Contributors.txt file.

Alternatively, the contents of this file may be used under the terms of the
GNU General Public License Version 2 or later (the "GPL"), in which case
the provisions of the GPL are applicable instead of those above.
If you wish to allow use of your version of this file only under the terms
of the GPL and not to allow others to use your version of this file
under the MPL, indicate your decision by deleting the provisions above and
replace them with the notice and other provisions required by the GPL.
If you do not delete the provisions above, a recipient may use your version
of this file under either the MPL or the GPL.

$Id: SynCompletionProposal.pas,v 1.12 2001/10/21 16:42:52 jrx Exp $

You may retrieve the latest version of this file at the SynEdit home page,
located at http://SynEdit.SourceForge.net

Known Issues:

The Caret hides when scrolling with the scroll bar on the completion proposal
-------------------------------------------------------------------------------}

unit SynCompletionProposal;

{$I SynEdit.inc}

interface

uses
  SysUtils, Classes, extctrls,
{$IFDEF SYN_KYLIX}
  Qt, Types, QControls, QGraphics, QForms, QStdCtrls, QMenus,
{$ELSE}
  Windows, Messages, Graphics, Forms, Controls, StdCtrls, Menus,
{$ENDIF}
 SynEditTypes, SynEditKeyCmds, SynEditHighlighter, SynEditKbdHandler, SynEdit;

type
  SynCompletionType = (ctCode, ctHint, ctParams);

  TSynForm = {$IFDEF SYN_DELPHI_3}TCustomForm{$ELSE}TForm{$ENDIF};

  TSynBaseCompletionProposalPaintItem = function(AKey: string; ACanvas: TCanvas;
    X, Y: integer): boolean of object;

  TCodeCompletionEvent = procedure(var Value: string; Shift: TShiftState)
    of object;

  TValidateEvent = procedure(Sender: TObject; Shift: TShiftState) of object;

  TCompletionParameter = procedure(Sender : TObject; CurrentIndex : Integer;
    VAR Level, IndexToDisplay : Integer; VAR Key : Char;
    VAR DisplayString : String) of object;

  TCompletionExecute = procedure(Kind : SynCompletionType; Sender : TObject;
    VAR AString : String; x, y : Integer; var CanExecute : Boolean) of object;

  TSynBaseCompletionProposalForm = class(TSynForm)
  protected
    FCurrentString  : string;
    FOnKeyPress     : TKeyPressEvent;
    FOnKeyDelete    : TNotifyEvent;
    FOnPaintItem    : TSynBaseCompletionProposalPaintItem;
    FItemList       : TStrings;
    FInsertList     : TStrings;
    FAssignedList   : TStrings;
    FPosition       : Integer;
    FNbLinesInWindow: Integer;
    FFontHeight     : integer;
    Scroll          : TScrollBar;
    FOnValidate     : TValidateEvent;
    FOnCancel       : TNotifyEvent;
    FClSelect       : TColor;
    fClText         : TColor;
    fClSelectText   : TColor;
    fClBackGround   : TColor;
    FAnsi           : boolean;
    fCase           : boolean;
    fShrink         : Boolean;
    FMouseWheelAccumulator: integer;
    FDisplayKind    : SynCompletionType;
    FParameterToken : TCompletionParameter;
    FCurrentIndex   : Integer;
    FCurrentLevel   : Integer;
    FDefaultKind    : SynCompletionType;
    FUsePrettyText  : Boolean;
    FUseBuiltInTimer: Boolean;
    FBiggestWord    : string;
    FMatchText      : Boolean;
    FEndOfTokenChr  : String;
    OldShowCaret    : Boolean;
    //!!!
    FHint           : THintWindow;
    FTriggerChars   : String;
    //!!!
    procedure SetCurrentString(const Value: string);
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: char); override;
    procedure Paint; override;
    //!!!
    function IndexOf(S: String): integer;
    //!!!
    procedure ScrollGetFocus(Sender: TObject);
    procedure Activate; override;
    procedure Deactivate; override;
    procedure MoveLine (cnt: Integer);
    procedure ScrollChange(Sender: TObject);
    procedure ScrollOnScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
    procedure SetItemList(const Value: TStrings);
    procedure SetInsertList(const Value: TStrings);
    procedure SetPosition(const Value: Integer);
    procedure SetNbLinesInWindow(const Value: Integer);
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    //!!!
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    //!!!
    procedure WMMouseWheel(var Msg: TMessage); message WM_MOUSEWHEEL;
    procedure StringListChange(Sender: TObject);
    procedure DoDoubleClick(Sender : TObject);
    function intLowerCase (s: string): string;
    procedure DoFormShow(Sender: TObject);
    procedure DoFormHide(Sender: TObject);
    //!!!
    function CanResize(var NewWidth, NewHeight: Integer): Boolean; override;
    procedure Resize; override;
    //!!!
  private
    Bitmap: TBitmap; // used for drawing
    fCurrentEditor: TComponent;
    FUseInsertList: boolean;
    FAPosition: Integer;
    procedure SetShrink(const Value: Boolean);
    procedure WMActivate (var Message: TWMActivate); message WM_ACTIVATE;
    procedure SetAPosition(const Value: Integer);
    procedure SetDispalyKind(const Value: SynCompletionType);
    procedure WMNCPAINT (var Msg: TMessage); message WM_NCPAINT;
    //!!!
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    //!!!
  public
    constructor Create(AOwner: Tcomponent); override;
    procedure CreateParams (var Params: TCreateParams); override;
    destructor destroy; override;
    property DisplayType : SynCompletionType read FDisplayKind write SetDispalyKind;
    property DefaultType : SynCompletionType read FDefaultKind write FDefaultKind;
//  published
    property CurrentString  : string read FCurrentString write SetCurrentString;
    Property CurrentIndex   : Integer read FCurrentIndex write FCurrentIndex;
    Property CurrentLevel   : Integer read FCurrentLevel write FCurrentLevel;
    Property OnParameterToken : TCompletionParameter read FParameterToken write FParameterToken;
    property OnKeyPress     : TKeyPressEvent read FOnKeyPress write FOnKeyPress;
    property OnKeyDelete    : TNotifyEvent read FOnKeyDelete write FOnKeyDelete;
    property OnPaintItem    : TSynBaseCompletionProposalPaintItem read FOnPaintItem
      write FOnPaintItem;
    property OnValidate     : TValidateEvent read FOnValidate write FOnValidate;
    property OnCancel       : TNotifyEvent read FOnCancel write FOnCancel;
    property ItemList       : TStrings   read FItemList write SetItemList;
    Property InsertList     : TStrings   read FInsertList write SetInsertList;
    property AssignedList   : TStrings   read FAssignedList write FAssignedList;
    property Position       : Integer    read FPosition write SetPosition;
    property APosition: Integer read FAPosition write SetAPosition;
    property NbLinesInWindow: Integer    read FNbLinesInWindow
      write SetNbLinesInWindow;
    property BiggestWord    : string     read FBiggestWord write FBiggestWord;
    property ClSelect       : TColor     read FClSelect write FClSelect;
    property ClSelectedText : TColor     read fClSelectText write fClSelectText;
    property ClText         : TColor     read fClText write fClText;
    property ClBackground   : TColor     read fClBackGround write fClBackGround;
    property UsePrettyText  : boolean    read FUsePrettyText write FUsePrettyText default False;
    property UseBuiltInTimer: boolean    read FUseBuiltInTimer write FUseBuiltInTimer default False;
    property UseInsertList  : boolean    read FUseInsertList write FUseInsertList default False;
    property AnsiStrings    : boolean    read fansi write fansi;
    property CaseSensitive  : Boolean    read fCase write fCase;
    property CurrentEditor  : TComponent read fCurrentEditor write fCurrentEditor;
    property MatchText      : Boolean    read fMatchText write fMatchText;
    property EndOfTokenChr  : String     read FEndOfTokenChr write FEndOfTokenChr;
    property ShrinkList: Boolean read fShrink write SetShrink;
    //
    property TriggerChars   : String     read FTriggerChars write FTriggerChars;
  end;

  TSynBaseCompletionProposal = class(TComponent)
  private
    FForm: TSynBaseCompletionProposalForm;
    FOnExecute: TCompletionExecute;
    FWidth: Integer;
    FBiggestWord: string;
    FUsePrettyText: Boolean;
    FUseBuiltInTimer: Boolean;
    FDotOffset : Integer;
    FOldPos : Integer;
    FOldLeft: Integer;
    FOldStr : String;
    FUseInsertList: boolean;
    FEndOfTokenChr: string;
    function GetClSelect: TColor;
    procedure SetClSelect(const Value: TColor);
    function GetCurrentString: string;
    function GetItemList: TStrings;
    function GetInsertList: TStrings;
    function GetNbLinesInWindow: Integer;
    function GetOnCancel: TNotifyEvent;
    function GetOnKeyPress: TKeyPressEvent;
    function GetOnPaintItem: TSynBaseCompletionProposalPaintItem;
    function GetOnValidate: TValidateEvent;
    function GetPosition: Integer;
    procedure SetCurrentString(const Value: string);
    procedure SetItemList(const Value: TStrings);
    procedure SetInsertList(const Value: TStrings);
    procedure SetNbLinesInWindow(const Value: Integer);
    procedure SetOnCancel(const Value: TNotifyEvent);
    procedure SetOnKeyPress(const Value: TKeyPressEvent);
    procedure SetOnPaintItem(const Value: TSynBaseCompletionProposalPaintItem);
    procedure SetPosition(const Value: Integer);
    procedure SetOnValidate(const Value: TValidateEvent);
    function GetOnKeyDelete: TNotifyEvent;
    procedure SetOnKeyDelete(const Value: TNotifyEvent);
    procedure RFAnsi(const Value: boolean);
    function SFAnsi: boolean;
    procedure SetWidth(Value: Integer);
    function GetDisplayKind: SynCompletionType;
    procedure SetDisplayKind(const Value: SynCompletionType);
    function GetParameterToken: TCompletionParameter;
    procedure SetParameterToken(const Value: TCompletionParameter);
    function GetDefaultKind: SynCompletionType;
    procedure SetDefaultKind(const Value: SynCompletionType);
    procedure SetUsePrettyText(const Value: Boolean);
    procedure SetUseBiggestWord(const Value: String);
    procedure SetUseInsertList(const Value: boolean);
    function IsEndToken(AChar : Char) : Boolean;
    function GetCase: boolean;
    procedure SetCase(const Value: boolean);
    function GetClBack: TColor;
    procedure SetClBack(const Value: TColor);
    function GetClText: TColor;
    procedure SetClText(const Value: TColor);
    function GetClSelectedText: TColor;
    procedure SetClSelectedText(const Value: TColor);
    function GetMatchText: Boolean;
    procedure SetMatchText(const Value: Boolean);
    procedure SetEndOfTokenChar(const Value: string);
    function GetShrink: Boolean;
    procedure SetShrink(const Value: Boolean);
    //
    function GetTriggerChars: String;
    procedure SetTriggerChars(const Value: String);
  protected
    procedure loaded; override;
  public
    constructor Create(Aowner: TComponent); override;
    destructor Destroy; override;
    procedure Execute(s: string; x, y: integer);
    procedure ExecuteEx(s: string; x, y: integer; Kind : SynCompletionType
      {$IFDEF SYN_COMPILER_4_UP} = ctCode {$ENDIF});
    procedure Activate;
    procedure Deactivate;
    property OnKeyPress: TKeyPressEvent read GetOnKeyPress write SetOnKeyPress;
    property OnKeyDelete: TNotifyEvent read GetOnKeyDelete write SetOnKeyDelete;
    property OnValidate: TValidateEvent read GetOnValidate write SetOnValidate;
    property OnCancel: TNotifyEvent read GetOnCancel write SetOnCancel;
    property CurrentString: string read GetCurrentString write SetCurrentString;
    property DotOffset : Integer read FDotOffset write FDotOffset;
    property DisplayType : SynCompletionType read GetDisplayKind write SetDisplayKind;
    property Form: TSynBaseCompletionProposalForm read FForm write FForm;
  published
    property DefaultType : SynCompletionType read GetDefaultKind write SetDefaultKind;
    property OnExecute: TCompletionExecute read FOnExecute write FOnExecute;
    property OnParameterToken: TCompletionParameter read GetParameterToken
      write SetParameterToken;
    property OnPaintItem: TSynBaseCompletionProposalPaintItem
      read GetOnPaintItem write SetOnPaintItem;
    procedure ClearList;
    function DisplayItem(AIndex : Integer) : String;
    function InsertItem(AIndex : Integer) : String;
    Procedure AddItemAt(Where : Integer; ADisplayText, AInsertText : String);
    Procedure AddItem(ADisplayText, AInsertText : String);
    property ItemList: TStrings read GetItemList write SetItemList;
    procedure ResetAssignedList;
    property InsertList: TStrings read GetInsertList write SetInsertList;
    property Position: Integer read GetPosition write SetPosition;
    property NbLinesInWindow: Integer read GetNbLinesInWindow
      write SetNbLinesInWindow;
    property ClSelect: TColor read GetClSelect write SetClSelect;
    property ClText: TColor read GetClText write SetClText;
    property ClSelectedText: TColor read GetClSelectedText write SetClSelectedText;
    property ClBackground: TColor read GetClBack write SetClBack;
    property AnsiStrings: boolean read SFAnsi write RFAnsi;
    property CaseSensitive: boolean read GetCase write SetCase;
    property ShrinkList: Boolean read GetShrink write SetShrink;
    property Width: Integer read FWidth write SetWidth;
    property BiggestWord: string read FBiggestWord write SetUseBiggestWord;
    property UsePrettyText: boolean read FUsePrettyText write SetUsePrettyText default False;
    property UseInsertList: boolean read FUseInsertList write SetUseInsertList default False;
    property EndOfTokenChr: string read FEndOfTokenChr write SetEndOfTokenChar;
    property LimitToMatchedText: Boolean read GetMatchText write SetMatchText;
    //
    property TriggerChars: String read GetTriggerChars write SetTriggerChars;
  end;

  TSynCompletionProposal = class(TSynBaseCompletionProposal)
  private
    FShortCut: TShortCut;
    fEditor: TCustomSynEdit;
    fKeyDownProc: TKeyDownProc;
    fKeyPressProc: TKeyPressProc;
    //Alexander
    FTimer: TTimer;
    FTimerInterval: Integer;
    //!!!
//    FEndOfTokenChr: string;
    //!!!
    fNoNextKey: Boolean;
    FOnCodeCompletion: TCodeCompletionEvent;
    procedure SetEditor(const Value: TCustomSynEdit);
    procedure backspace(Sender: TObject);
    procedure Cancel(Sender: TObject);
    procedure Validate(Sender: TObject; Shift: TShiftState);
    procedure KeyPress(Sender: TObject; var Key: Char);
    procedure EditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditorKeyPress(Sender: TObject; var Key: char);
    function GetPreviousToken(FEditor: TCustomSynEdit): string;
    //
    procedure TimerExecute(Sender: TObject);
    function GetTimerInterval: Integer;
    procedure SetTimerInterval(const Value: Integer);
    procedure SetUseBuiltInTimer(const Value: Boolean);
    //
  protected
    procedure DoExecute(AEditor: TCustomSynEdit); virtual;
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;
    procedure SetShortCut(Value: TShortCut);
  public
    constructor Create(AOwner: TComponent); override;
    destructor destroy; override;
    function RemoveEditor(Editor: TCustomSynEdit): boolean;
    //
    procedure ActivateTimer(ACurrentEditor: TCustomSynEdit);
    procedure DeactivateTimer;
    //
  published
    property ShortCut: TShortCut read FShortCut write SetShortCut;
    property Editor: TCustomSynEdit read fEditor write SetEditor;

//!!!
//    property EndOfTokenChr: string read FEndOfTokenChr write FEndOfTokenChr;
//!!!
    property OnCodeCompletion: TCodeCompletionEvent
      read FOnCodeCompletion write FOnCodeCompletion;
    //
    property TimerInterval: Integer read GetTimerInterval write SetTimerInterval default 1000;
    property UseBuiltInTimer: boolean read FUseBuiltInTimer write SetUseBuiltInTimer default False;
    //
  end;

  TSynAutoComplete = class(TComponent)
  private
    FShortCut: TShortCut;
    fEditor: TCustomSynEdit;
    fAutoCompleteList: TStrings;
    fKeyDownProc : TKeyDownProc;
    fKeyPressProc : TKeyPressProc;
    fNoNextKey : Boolean;
    FEndOfTokenChr: string;
    procedure SetAutoCompleteList(List: TStrings);
    procedure SetEditor(const Value: TCustomSynEdit);
  protected
    procedure SetShortCut(Value: TShortCut);
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;
    procedure EditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
      virtual;
    procedure EditorKeyPress(Sender: TObject; var Key: char); virtual;
    function GetPreviousToken(Editor: TCustomSynEdit): string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor destroy; override;
    procedure Execute(token: string; Editor: TCustomSynEdit);
    function RemoveEditor(Editor: TCustomSynEdit): boolean;
    function GetTokenList: string;
    function GetTokenValue(Token: string): string;
  published
    property AutoCompleteList: TStrings read fAutoCompleteList
      write SetAutoCompleteList;
    property EndOfTokenChr: string read FEndOfTokenChr write FEndOfTokenChr;
    property Editor: TCustomSynEdit read fEditor write SetEditor;
    property ShortCut: TShortCut read FShortCut write SetShortCut;
  end;

  Procedure PrettyTextOut(c: TCanvas; x, y: integer; s: String; DoAlign: Boolean; BiggestWord: String);

type
  TCrackCustomSynEdit = class(TCustomSynEdit);

implementation

uses
  SynEditKeyConst, SynEditStrConst, SynEditTextBuffer, SynEditMiscProcs;

{ TSynBaseCompletionProposalForm }

constructor TSynBaseCompletionProposalForm.Create(AOwner: TComponent);
begin
{$IFDEF SYN_CPPB_1}
  CreateNew(AOwner, 0);
{$ELSE}
  CreateNew(AOwner);
{$ENDIF}
  FItemList := TStringList.Create;
  FInsertList := TStringList.Create;
  fAssignedList := TStringList.Create;
  FMatchText := False;
  {$IFDEF SYN_KYLIX}
  BorderStyle := fbsNone;
  {$ELSE}
  BorderStyle := bsNone;
  {$ENDIF}
  Scroll := TScrollBar.Create(self);
  Scroll.Kind := sbVertical;
  {$IFNDEF SYN_KYLIX}
  Scroll.ParentCtl3D := False;
  {$ENDIF}
  Scroll.OnChange := ScrollChange;
  Scroll.OnScroll := ScrollOnScroll;
  Scroll.Parent := self;
  Scroll.OnEnter := ScrollGetFocus;
  Visible := false;
  FFontHeight := Canvas.TextHeight('Cyrille de Brebisson');
  ClSelect := clHighlight;
  ClSelectedText := clHighlightText;
  ClBackground := clWindow;
  ClText := clWindowText;
  CaseSensitive := false;
  ShrinkList := true;
  TStringList(FItemList).OnChange := StringListChange;
  bitmap := TBitmap.Create;
  NbLinesInWindow := 8;
  Canvas.Font.Name := 'Arial';
  Canvas.Font.Size := 8;
  OnDblClick := DoDoubleClick;

  OnShow := DoFormShow;
  OnHide := DoFormHide;
end;

procedure TSynBaseCompletionProposalForm.CreateParams (var Params: TCreateParams);
const
  ThickFrames: array[Boolean] of DWORD = (0, WS_THICKFRAME);
begin
  inherited;

  with Params do begin
    Style := WS_POPUP;
    ExStyle := WS_EX_TOOLWINDOW;
  end;
end;

procedure TSynBaseCompletionProposalForm.Activate;
begin
  Visible := True;
  if DefaultType = ctCode then
    TCustomSynEdit (CurrentEditor).AddFocusControl(self);
end;

procedure TSynBaseCompletionProposalForm.Deactivate;
begin
  if FormStyle = fsNormal then
  begin
    try
      if (DefaultType = ctCode) then
        TCustomSynEdit (CurrentEditor).RemoveFocusControl(self);
    except
      on exception do;
    end;
    Visible := False;
  end;
end;

destructor TSynBaseCompletionProposalForm.destroy;
begin
  bitmap.free;
//  Scroll.Free;                                                                //DDH The form will free this
  FItemList.Free;
  FInsertList.Free;
  fAssignedList.Free;
  FHint.Free;
  inherited destroy;
end;

procedure TSynBaseCompletionProposalForm.KeyDown(var Key: Word;
  Shift: TShiftState);
var
  X: Integer;
  BeginPos, EndPos: Integer;
  Line: string;
  OB, CB: Integer;
begin
  if DisplayType = ctCode then
  begin
    case Key of
      SYNEDIT_RETURN : if Assigned(OnValidate) then OnValidate(Self, Shift);
      SYNEDIT_ESCAPE : if Assigned(OnCancel) then OnCancel(Self);
      SYNEDIT_PRIOR  : MoveLine (NbLinesInWindow * -1);
      SYNEDIT_NEXT   : MoveLine (NbLinesInWindow);
      SYNEDIT_END    : Position := ItemList.count - 1;
      SYNEDIT_HOME   : Position := 0;
      SYNEDIT_UP     : if ssCtrl in Shift then
                         Position := 0
                       else MoveLine (-1);
      SYNEDIT_DOWN   : if ssCtrl in Shift then
                         Position := ItemList.count - 1
                       else MoveLine (1);
      SYNEDIT_BACK   : if (Shift = []) and (Length(CurrentString) > 0) then
                       begin
                         CurrentString := Copy(CurrentString, 1, Length(CurrentString) - 1);
                         if Assigned (OnKeyDelete) then OnKeyDelete(Self);
                       end;
    end;
  end else if DisplayType = ctParams then
  begin
    case Key of
      SYNEDIT_RETURN : begin
                         Top := Top + TCustomSynEdit(CurrentEditor).LineHeight;
                       end;
      SYNEDIT_ESCAPE:
      begin
        if Assigned(OnCancel) then OnCancel(Self);
        Exit;
      end;
      VK_LEFT, VK_RIGHT, VK_HOME, VK_END, SYNEDIT_UP, SYNEDIT_DOWN:
      begin
        //Проверям находится ли курсор между двуми скобками
        if Assigned(CurrentEditor) then
        begin
          TCrackCustomSynEdit(CurrentEditor).KeyDown(Key, Shift);
          X := TCustomSynEdit(CurrentEditor).CaretX;
          Line := TCustomSynEdit(CurrentEditor).LineText;
          BeginPos := X;
          EndPos := X;
          OB := 0;
          CB := 0;
          while (BeginPos > 0) and ((Line[BeginPos] <> '(') or
            ((Line[BeginPos] = '(') and (CB > 0))) do
          begin
            if Line[BeginPos] = ')' then
              Inc(CB);
            if Line[BeginPos] = '(' then
              Dec(CB);
            Dec(BeginPos);
          end;
          while (EndPos < Length(Line)) and ((Line[EndPos] <> ')') or
            ((Line[EndPos] = ')') and (OB > 0))) do
          begin
            if Line[BeginPos] = ')' then
              Dec(OB);
            if Line[BeginPos] = '(' then
              Inc(OB);
            Inc(EndPos);
          end;

          if not ((BeginPos < EndPos) and (Line[BeginPos] = '(') and
            (Line[EndPos] = ')')) then
          begin
            if Assigned(OnCancel) then OnCancel(Self);
            Exit;
          end;
        end else
        begin
          if Assigned(OnCancel) then OnCancel(Self);
          Exit;
       end;
      end;
      SYNEDIT_BACK   : if Assigned(OnKeyDelete) then OnKeyDelete(Self);
    end;
  //!!!
  end else if DisplayType = ctHint then
  begin
    Hide;
  end;
  //!!!
  Invalidate;
end;

procedure TSynBaseCompletionProposalForm.KeyPress(var Key: char);
VAR TmpIndex, TmpLevel : Integer;
    TmpStr : String;
begin
  if DisplayType = ctCode then
  begin
    case key of    //
      #32     : begin
                  OnValidate(Self, []);
                  Key := #0;
                end;
      #33..'z': Begin
                  if Pos(Key, FEndOfTokenChr) <> 0 then
                    OnValidate(Self, []);

                  CurrentString:= CurrentString+key;
                  if Assigned(OnKeyPress) then
                    OnKeyPress(self, Key);
                end;
      #8: if Assigned(OnKeyPress) then OnKeyPress(self, Key);
      else if Assigned(OnCancel) then OnCancel(Self);
    end;    // case
  end else if DisplayType = ctHint then
  begin
    if Assigned(OnKeyPress) then OnKeyPress(self, Key);
    if Assigned(OnCancel) then OnCancel(Self);
    Hide;
  end else begin
    case key of
      ',','(',')' : Begin
                      if Assigned(FParameterToken) then
                      begin
                        TmpIndex := CurrentIndex;
                        TmpLevel := CurrentLevel;
                        TmpStr := CurrentString;
                        OnParameterToken(self, CurrentIndex, TmpLevel, TmpIndex, key, TmpStr);
                        CurrentIndex := TmpIndex;
                        CurrentLevel := TmpLevel;
                        CurrentString := TmpStr;
                      end;
                      if Assigned(OnKeyPress) then
                        OnKeyPress(self, Key);
                    end;
      #27     : begin
                  Hide;
                  if Assigned(OnCancel) then OnCancel(Self);
                  Exit;
                end;
      #33..'''',
      '*','+',
      '-'..'z', ' ':
      begin
        if Assigned(OnKeyPress) then
          OnKeyPress(self, Key);
      end;
      #8: if Assigned(OnKeyPress) then OnKeyPress(self, Key);
    end;
  end;
  Invalidate;
end;

procedure TSynBaseCompletionProposalForm.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  y := (y - 1) div FFontHeight;
  Position := Scroll.Position + y;
  TCustomSynEdit(CurrentEditor).UpdateCaret;
end;

procedure TSynBaseCompletionProposalForm.Paint;
var
  i: integer;
  R: TRect;

  function Min(a, b: integer): integer;
  begin
    if a < b then
      Result := a
    else
      Result := b;
  end;
begin
//There are now multiple kinds of painting.
//this is for code completion

// draw a rectangle around the window
  Canvas.Brush.Color:= ClBlack;
  Canvas.FrameRect(Rect(0,0, Width, Height));

  if FDisplayKind = ctCode then
  begin
    // update scroll bar
    if ItemList.Count - NbLinesInWindow < 0 then
      Scroll.Max := 0
    else
      Scroll.Max := ItemList.Count - NbLinesInWindow;
    Scroll.LargeChange := NbLinesInWindow;

    with bitmap do
    begin
      canvas.pen.color := fClBackGround;
      canvas.brush.color := fClBackGround;
      canvas.Rectangle(0, 0, Width, Height);
      for i := 0 to min(NbLinesInWindow - 1, ItemList.Count - 1) do
      begin
        if i + Scroll.Position = Position then
        begin
          //!!!
          if APosition = Position then
          begin
          //!!!
            Canvas.Brush.Color := fClSelect;
            Canvas.Pen.Color   := fClSelect;
            Canvas.Rectangle(0, FFontHeight * i, width, FFontHeight * (i + 1));
            Canvas.Pen.Color   := fClSelectText;
            Canvas.Font.Color  := fClSelectText;
          //!!!
          end else
          begin
            Canvas.Brush.Color := fclBackground;
            Canvas.Pen.Color   := fClBackGround;
            Canvas.Font.Color  := fClText;
          end;
          //!!!
        end else
        begin
          Canvas.Brush.Color := fclBackground;
          Canvas.Pen.Color   := fClBackGround;
          Canvas.Font.Color  := fClText;
        end;

        if not Assigned(OnPaintItem)
          or not OnPaintItem(ItemList[Scroll.Position + i], Canvas, 0, FFontHeight * i) then
        begin
          if FUsePrettyText then
            PrettyTextOut( Canvas, 1, FFontHeight*i, ItemList[Scroll.Position+i], True, FBiggestWord)
          else Canvas.TextOut(2, FFontHeight * i, ItemList[Scroll.Position + i]);
        end;
        //!!!
        if i + Scroll.Position = Position then
        begin
          R.Left := 0;
          R.Top := FFontHeight * i;
          R.Right := Width;
          R.Bottom := FFontHeight * (i + 1);
          Canvas.DrawFocusRect(R);
        end;
        //!!!
      end;
    end;
    canvas.Draw(1, 1, bitmap);
    //This is to try and reduce flickering, but doesn't reduce it
//    Canvas.BrushCopy(Rect(1,1,Bitmap.Width + 1, Bitmap.Height + 1), Bitmap, Rect(0, 0, Bitmap.Width, Bitmap.Height), clBlack);
  end else if (FDisplayKind = ctHint) or (FDisplayKind = ctParams) then
  begin
    with bitmap do
    begin
      canvas.pen.color:= fClBackGround;
      canvas.brush.color:= fClBackGround;
      canvas.Rectangle(0,0,Width,Height);

      Canvas.Brush.Color := fClBackGround;
      Canvas.Font.Color  := fClText;
      if not Assigned(OnPaintItem) or not OnPaintItem(CurrentString, Canvas, 0, FFontHeight) then
      begin
        if UsePrettyText then
          PrettyTextOut( Canvas, 3, 1, CurrentString, False, FBiggestWord)
        else Canvas.TextOut( 4, 2, CurrentString);
      end;
    end;
    canvas.Draw(1, 1, bitmap);
  end;
end;

procedure TSynBaseCompletionProposalForm.ScrollChange(Sender: TObject);
begin
  if Position < Scroll.Position then
    Position := Scroll.Position
  else if Position > Scroll.Position + NbLinesInWindow - 1 then
    Position := Scroll.Position + NbLinesInWindow - 1;
  Invalidate;
end;

procedure TSynBaseCompletionProposalForm.ScrollOnScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
begin
  with TCustomSynEdit(CurrentEditor) do
  begin
    SetFocus;
    //I haven't figured out why carets hide when scrolling, but at least you can type now.
  end;
end;

procedure TSynBaseCompletionProposalForm.ScrollGetFocus(Sender: TObject);
begin
  ActiveControl := nil;
end;

procedure TSynBaseCompletionProposalForm.MoveLine (cnt: Integer);
begin
  if (cnt > 0) then begin
    if (Position < (ItemList.Count - cnt)) then
      Position := Position + cnt
    else
      Position := ItemList.Count - 1;
  end else begin
    if (Position + cnt) > 0 then
      Position := Position + cnt
    else
      Position := 0;
  end;
end;

procedure TSynBaseCompletionProposalForm.SetCurrentString(const Value: string);
var i: integer;
    cs: string;

  function MatchItem (item: string): Boolean;
  var
    ci: string;
    TmpStr: String;
  begin
    if UsePrettyText then
    begin
      if pos(#9, item) <> 0 then
        TmpStr := Copy(Item, pos(#9, item) + 1, length(item))
      else
        TmpStr := Item;
    end else
      TmpStr := Item;

    ci := intLowerCase (Copy (TmpStr,1,Length (Value)));

    if fAnsi then
      Result := (AnsiCompareText (ci,cs) = 0)
    else
      Result := (CompareText (ci,cs) = 0);
  end;

  procedure RecalcList;
  var idx: Integer;
  begin
    if FMatchText then
    begin
      with fAssignedList do
        if (FItemList.Count > Count) then
          Assign (FItemList);

      ItemList.Clear;

      for idx := 0 to fAssignedList.Count - 1 do begin
        if MatchItem (fAssignedList[idx]) then
          ItemList.AddObject(fAssignedList[idx], TObject(idx));
      end;
    end;
  end;
begin
  FCurrentString := Value;
  i:= 0;
  cs := intLowerCase (Value);
  if fShrink then
    RecalcList;
  while (i <= ItemList.count-1) and not MatchItem (ItemList[i]) do
    Inc (i);
  if (i <= ItemList.Count-1) then
  begin
    Position:= i;
    APosition := i;
  end
  //!!!
    else APosition := - 1;
  //!!!
end;

procedure TSynBaseCompletionProposalForm.SetItemList(const Value: TStrings);
begin
  FItemList.Assign(Value);
  fAssignedList.Assign(Value);
  CurrentString := CurrentString;
end;

procedure TSynBaseCompletionProposalForm.SetInsertList(const Value: TStrings);
begin
  FInsertList.Assign(Value);
end;

procedure TSynBaseCompletionProposalForm.SetNbLinesInWindow(
  const Value: Integer);
begin
  FNbLinesInWindow := Value;

 Height := fFontHeight * NbLinesInWindow + 2;
  if Scroll <> nil then
  begin
    Scroll.Top := 1;
    Scroll.Left := ClientWidth - Scroll.Width - 1;
    Scroll.Height := Height - 2;
    if Bitmap <> nil then
    begin
      Bitmap.Width := Scroll.Left - 2;
      Bitmap.Height := Height - 2;
    end;
  end;
end;

procedure TSynBaseCompletionProposalForm.DoDoubleClick(Sender: TObject);
begin
//we need to do the same as the enter key;
  if DefaultType = ctCode then
    if Assigned(OnValidate) then OnValidate(Self, []);
end;

procedure TSynBaseCompletionProposalForm.SetPosition(const Value: Integer);
begin
  if ((Value <= 0) and (FPosition = 0)) or
     (FPosition = Value) then exit;

  if Value <= ItemList.Count - 1 then
  begin
    if FPosition <> Value then
    begin
      FPosition := Value;
      //!!!
      FAPosition := Value;
      //!!!
      if Position < Scroll.Position then
        Scroll.Position := Position
      else if Scroll.Position < Position - NbLinesInWindow + 1 then
        Scroll.Position := Position - NbLinesInWindow + 1;
      invalidate;
    end;
  end;
end;

procedure TSynBaseCompletionProposalForm.StringListChange(Sender: TObject);
begin
  if ItemList.Count - NbLinesInWindow < 0 then
    Scroll.Max := 0
  else
    Scroll.Max := ItemList.Count - NbLinesInWindow;
  Scroll.Position := Position;
end;

procedure TSynBaseCompletionProposalForm.WMMouseWheel(var Msg: TMessage);
var
  nDelta: integer;
  nWheelClicks: integer;
{$IFNDEF SYN_COMPILER_4_UP}
const
  LinesToScroll = 3;
  WHEEL_DELTA = 120;
  WHEEL_PAGESCROLL = MAXDWORD;
{$ENDIF}
begin
  if csDesigning in ComponentState then exit;

{$IFDEF SYN_COMPILER_4_UP}
  if GetKeyState(VK_CONTROL) >= 0 then nDelta := Mouse.WheelScrollLines
{$ELSE}
  if GetKeyState(VK_CONTROL) >= 0 then nDelta := LinesToScroll
{$ENDIF}
    else nDelta := FNbLinesInWindow;

  Inc(fMouseWheelAccumulator, SmallInt(Msg.wParamHi));
  nWheelClicks := fMouseWheelAccumulator div WHEEL_DELTA;
  fMouseWheelAccumulator := fMouseWheelAccumulator mod WHEEL_DELTA;
  if (nDelta = integer(WHEEL_PAGESCROLL)) or (nDelta > FNbLinesInWindow) then
    nDelta := FNbLinesInWindow;

  Position := Position - (nDelta * nWheelClicks);

end;

function TSynBaseCompletionProposalForm.intLowerCase (s: string): string;
begin
  if fCase then Result := s
    else Result := LowerCase (s);
end;

procedure TSynBaseCompletionProposalForm.SetShrink(const Value: Boolean);
begin
  fShrink := Value;
  with FItemList do
    if (Count < fAssignedList.Count) then
      Assign(fAssignedList);
end;

function GetMDIParent (const Form: TSynForm): TSynForm;
{ Returns the parent of the specified MDI child form. But, if Form isn't a
  MDI child, it simply returns Form. }
var
  I, J: Integer;
begin
  Result := Form;
  if Form = nil then Exit;
  if {$IFDEF SYN_DELPHI_3} (Form is TForm) and {$ENDIF}
     (TForm(Form).FormStyle = fsMDIChild) then
    for I := 0 to Screen.FormCount-1 do
      with Screen.Forms[I] do begin
        if FormStyle <> fsMDIForm then Continue;
        for J := 0 to MDIChildCount-1 do
          if MDIChildren[J] = Form then begin
            Result := Screen.Forms[I];
            Exit;
          end;
      end;
end;

procedure TSynBaseCompletionProposalForm.WMActivate(var Message: TWMActivate);
var
  ParentForm: TSynForm;
begin
  if csDesigning in ComponentState then begin
    inherited;
    Exit;
  end;
     {Owner of the component that created me}
  if Owner.Owner is TSynForm then
    ParentForm := GetMDIParent(TSynForm(Owner.Owner))
  else ParentForm := nil;

  if Assigned(ParentForm) and ParentForm.HandleAllocated then
    SendMessage (ParentForm.Handle, WM_NCACTIVATE, Ord(Message.Active <> WA_INACTIVE), 0);
end;

procedure TSynBaseCompletionProposalForm.DoFormHide(Sender: TObject);
begin
  if CurrentEditor <> nil then
  begin
    TCustomSynEdit(CurrentEditor).AlwaysShowCaret := OldShowCaret;
    TCustomSynEdit(CurrentEditor).UpdateCaret;
  end;
//!!!
  if FHint <> nil then
  begin
    FHint.Free;
    FHint := nil;
  end;
//!!!
end;

procedure TSynBaseCompletionProposalForm.DoFormShow(Sender: TObject);
begin
  if CurrentEditor <> nil then
  begin
    OldShowCaret := TCustomSynEdit(CurrentEditor).AlwaysShowCaret;

    TCustomSynEdit(CurrentEditor).AlwaysShowCaret := True;
    TCustomSynEdit(CurrentEditor).UpdateCaret;
  end;
end;

function TSynBaseCompletionProposalForm.IndexOf(S: String): integer;
var
  I: Integer;
begin
  Result := - 1;
  S := UpperCase(S);
  for I := 0 to FItemList.Count -1 do
  begin
    if Pos(S, UpperCase(FItemList[I])) = 1 then
    begin
      Result := I;
      Break;
    end;
  end;
end;

procedure TSynBaseCompletionProposalForm.SetAPosition(
  const Value: Integer);
begin
  FAPosition := Value;
end;


procedure TSynBaseCompletionProposalForm.SetDispalyKind(
  const Value: SynCompletionType);
{var
  Style: LongInt;}
begin
//  if FDisplayKind <> Value then
//  begin
    FDisplayKind := Value;
{    Style := GetWindowLong(Handle, GWL_STYLE);
    if FDisplayKind = ctCode then
      Style := Style or WS_SIZEBOX
    else
      Style := Style and not WS_SIZEBOX;
    SetWindowLong(Handle, GWL_STYLE, Style);
    SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_FRAMECHANGED);}
//  end;
end;


function TSynBaseCompletionProposalForm.CanResize(var NewWidth,
  NewHeight: Integer): Boolean;
begin
{  if FDisplayKind = ctCode then
    NbLinesInWindow := Round((NewHeight - 2) / FFontHeight);}
  Result := inherited CanResize(NewWidth, NewHeight);
end;

procedure TSynBaseCompletionProposalForm.Resize;
begin
  inherited;

{  Invalidate;}
end;

procedure TSynBaseCompletionProposalForm.WMNCPAINT(var Msg: TMessage);
//var
//  DC: HDC;
begin
{  DC := GetDCex(Handle, HRGN(Msg.WParam), DCX_WINDOW or DCX_INTERSECTRGN);
  try
    Rectangle(DC, Left, Top, Left + Width, Top + Height);
  finally
    ReleaseDC(Handle, DC);
  end;
  Msg.Result := 0;}
  inherited;
end;

procedure TSynBaseCompletionProposalForm.MouseMove(Shift: TShiftState; X,
  Y: Integer);
var
  TextWidth: Integer;
  I: Integer;
  H: String;
  R: TRect;
  P: TPoint;

  procedure MoveRect(var Rect: TRect; X, Y: Integer);
  var
    Width, Height: Integer;
  begin
    with Rect do
    begin
      Width := Right - Left;
      Height :=  Bottom - Top;
      Left := X;
      Top := Y;
      Right := Left + Width;
      Bottom := Top + Height;
    end;
  end;

  function GetPrettyText(C: TCanvas; var Str: String): Integer;
  var
    i: integer;
    b: TBrush;
    f: TFont;
    InBold : Boolean;
    DidAlign : Boolean;
    S: string;
  Begin
    b:= TBrush.Create;
    b.Assign(c.Brush);
    f:= TFont.Create;
    f.Assign(c.Font);
    InBold := False;
    DidAlign := False;
    Result := 0;
    S := Str;
    Str := '';
    try
      i:= 1;
      while i<=Length(s) do
        case s[i] of
          #1: inc(i, 4);
          #2: inc(i, 1);
          #3: begin
                case s[i+1] of
                  'B': c.Font.Style:= c.Font.Style+[fsBold];
                  'b': c.Font.Style:= c.Font.Style-[fsBold];
                  'U': c.Font.Style:= c.Font.Style+[fsUnderline];
                  'u': c.Font.Style:= c.Font.Style-[fsUnderline];
                  'I': c.Font.Style:= c.Font.Style+[fsItalic];
                  'i': c.Font.Style:= c.Font.Style-[fsItalic];
                end;
                inc(i, 2);
              end;
          #9: begin
                InBold := not(InBold);

                if InBold then
                  c.Font.Style:= c.Font.Style+[fsBold]
                else begin
                  c.Font.Style:= c.Font.Style-[fsBold];
                  Result := Result + 1;  //spacing issue
                end;

                if not(DidAlign) then
                begin
                  Result := 1 + c.TextWidth(BiggestWord);
                  Str := Str + ' ';
                  DidAlign := True;
                end;
                inc(i);
              end;

          else
            if (not(DidAlign) and (Result < c.TextWidth(BiggestWord)) and (pos(#9, s) <> 0)) or
//               ((pos(#9, s) <> 0) and not(DoAlign)) or
               (pos(#9, s) = 0) or
               (DidAlign) then
            begin
              Str := Str + s[i];
              Result := Result + c.TextWidth(s[i])
            end;

            {$IFNDEF SYN_KYLIX}
            if Win32Platform <> VER_PLATFORM_WIN32_NT then
              if InBold then Result := Result - 1; //spacing issue, need to verify on WINNT
            {$ENDIF}

            inc(i);
        end;
    except
    end;
    c.Font.Assign(f);
    f.Free;
    c.Brush.Assign(b);
    b.Free;
  end;

begin
  inherited;
  ShowHint := False;
  if FDisplayKind = ctCode then
  begin
    I := (y - 1) div FFontHeight + Scroll.Position;
    if I < ItemList.Count then
    begin
      H := ItemList[I];
      if UsePrettyText then
        TextWidth := GetPrettyText(Canvas, H)
      else
        TextWidth := Canvas.TextWidth(H);
          
      if TextWidth > Width - 2 - Scroll.Width then
      begin
//        ShowHint := True;
        if FHint = nil then
        begin
          FHint := THintWindow.Create(Self);
          Fhint.Color := clInfoBk;
        end;
        P.X := 1;
        P.Y := ((y - 1) div FFontHeight) * FFontHeight + 1;
        P := ClientToScreen(P);
        R := FHint.CalcHintRect(Screen.Width - P.X, H, nil);
        MoveRect(R, P.X, P.Y);
        FHint.ActivateHint(R, H);
      end else
      begin
        if FHint <> nil then
        begin
          FHint.Free;
          FHint := nil;
        end;
      end;
    end;
  end;
end;

procedure TSynBaseCompletionProposalForm.CMMouseLeave(
  var Message: TMessage);
begin
  inherited;
  if FHint <> nil then
  begin
    FHint.Free;
    FHint := nil;
  end;
end;

{ TSynBaseCompletionProposal }

constructor TSynBaseCompletionProposal.Create(Aowner: TComponent);
begin
  FWidth := 262;
  FBiggestWord := 'CONSTRUCTOR';
  inherited Create(AOwner);
  Form := TSynBaseCompletionProposalForm.Create(Self);
  Form.Width := FWidth;
  Form.UsePrettyText := FUsePrettyText;
  Form.EndOfTokenChr := FEndOfTokenChr;
  FDotOffset := 0;
  FOldPos := 0;
  FOldLeft := 0;
  FOldStr := '';
end;

destructor TSynBaseCompletionProposal.Destroy;
begin
  FreeAndNil(Fform);
  inherited Destroy;
end;

procedure TSynBaseCompletionProposal.Execute(s: string; x, y: integer);
begin
  ExecuteEx(s, x, y, ctCode);
end;

procedure TSynBaseCompletionProposal.ExecuteEx(s: string; x, y: integer; Kind : SynCompletionType);
VAR
  CanExecute : Boolean;
  TmpOffset  : Integer;
//  ScrOffset: Integer;
  TextWidth: Integer;
  Divide: Integer;
  TextLen: Integer;
  I: Integer;
begin
  DisplayType := Kind;

  CanExecute := True;
  if assigned(OnExecute) then
    OnExecute(Kind, Self, s, x, y, CanExecute);

  if not(CanExecute) then
    exit;

  if Kind = ctParams then
  begin
    Form.FormStyle := fsStayOnTop;
  end else begin
    Form.FormStyle := fsNormal;
    FOldPos := -1;
    FOldLeft := -1;
    FOldStr := '';
  end;

  if form.CurrentEditor <> nil then
  begin
    TmpOffset := TCustomSynEdit(form.CurrentEditor).Canvas.TextWidth(copy(s, 1, DotOffset));
    if Kind = ctHint then
    begin
      TextWidth := TCustomSynEdit(form.CurrentEditor).Canvas.TextWidth(S);
      TextLen := Length(S);
      if TextWidth > Screen.Width then
      begin
        Divide := TextWidth div Screen.Width;
        TextLen := Length(S) div Divide;
        for I := 1 to Divide do
        begin
          System.Insert(#10#13, S, TextLen * I + (I - 1) * 2);
        end
      end;
      TmpOffset := (x + TCustomSynEdit(form.CurrentEditor).Canvas.TextWidth(
        copy(s, DotOffset, TextLen - DotOffset))) - Screen.Width;
      if TmpOffset < 0 then
        TmpOffset := 0;
    end else
      if DotOffset > 1 then TmpOffset := TmpOffset + (3 * (DotOffset - 1))
  end else TmpOffset := 0;

  if (FOldStr <> s) or (FOldStr = '') then
  begin
    form.height := 0;
    form.width := 0;
    FOldStr := s;
  end;

  form.top:= y;
  form.left:= x - TmpOffset;

  if kind = ctParams then
    if length(s) > 0 then  //this is for spacing stuff later on;
      if IsEndToken(s[length(s)]) then
        s := copy(s,1,length(s) - 1);

  CurrentString:= s;

  if Kind = ctCode then
  begin
    with form do
    begin
      width:=262;
      Color := CLBackground;
      Height:= fFontHeight * NbLinesInWindow + 2;
      bitmap.Width:= Scroll.left - 2;
      bitmap.height:= Height-2;
      Scroll.Visible := True;
//!!!
      if Left + Width >= Screen.Width then
        Left := Left - Width;

      if Top + Height >= Screen.Height then
        Top := Top - Height - fFontHeight - 2;
//!!!
      Show;
    end;
  end else begin
    with form do
    begin
      form.Invalidate;
      Canvas.Font.Style := [fsBold];
      width := Canvas.TextWidth(s);
      Canvas.Font.Style := [];
      TmpOffset := Canvas.TextWidth(copy(s,1, pos(#9,s) - 1));

      if Top <> y then Top := y;

      if (TmpOffset <> FOldPos) or (kind = ctParams) then
      begin
        left := Left - TmpOffset;
        FOldPos := TmpOffset;
        FOldLeft := Left;
      end else Left := FOldLeft;
      Height := FFontHeight + 4;

      if (Width - 2 < 1) or
         (Height - 2 < 1) then
      begin
        //There is nothing to display
        exit;
      end;
      bitmap.Width := width - 2;

      bitmap.height:= Height - 2;

      Color := ClBackground;
      Scroll.Visible := False;

      try
        form.Show;
      except
        on exception do ;
      end;

//      if Kind = ctParams then
//        TCustomSynEdit(form.CurrentEditor).SetFocus;

    end;
  end;
end;

function TSynBaseCompletionProposal.GetCurrentString: string;
begin
  result := Form.CurrentString;
end;

function TSynBaseCompletionProposal.GetItemList: TStrings;
begin
  result := Form.ItemList;
end;

function TSynBaseCompletionProposal.GetInsertList: TStrings;
begin
  result := Form.InsertList;
end;

function TSynBaseCompletionProposal.GetNbLinesInWindow: Integer;
begin
  Result := Form.NbLinesInWindow;
end;

function TSynBaseCompletionProposal.GetOnCancel: TNotifyEvent;
begin
  Result := Form.OnCancel;
end;

function TSynBaseCompletionProposal.GetOnKeyPress: TKeyPressEvent;
begin
  Result := Form.OnKeyPress;
end;

function TSynBaseCompletionProposal.GetOnPaintItem: TSynBaseCompletionProposalPaintItem;
begin
  Result := Form.OnPaintItem;
end;

function TSynBaseCompletionProposal.GetOnValidate: TValidateEvent;
begin
  Result := Form.OnValidate;
end;

function TSynBaseCompletionProposal.GetPosition: Integer;
begin
  Result := Form.Position;
end;

procedure TSynBaseCompletionProposal.SetCurrentString(const Value: string);
begin
  form.CurrentString := Value;
end;

procedure TSynBaseCompletionProposal.SetItemList(const Value: TStrings);
begin
  form.ItemList := Value;
end;

procedure TSynBaseCompletionProposal.SetInsertList(const Value: TStrings);
begin
  form.InsertList := Value;
end;

procedure TSynBaseCompletionProposal.SetNbLinesInWindow(const Value: Integer);
begin
  form.NbLinesInWindow := Value;
end;

procedure TSynBaseCompletionProposal.SetOnCancel(const Value: TNotifyEvent);
begin
  form.OnCancel := Value;
end;

procedure TSynBaseCompletionProposal.SetOnKeyPress(const Value: TKeyPressEvent);
begin
  form.OnKeyPress := Value;
end;

procedure TSynBaseCompletionProposal.SetOnPaintItem(const Value:
  TSynBaseCompletionProposalPaintItem);
begin
  form.OnPaintItem := Value;
end;

procedure TSynBaseCompletionProposal.SetPosition(const Value: Integer);
begin
  form.Position := Value;
end;

procedure TSynBaseCompletionProposal.SetOnValidate(const Value: TValidateEvent);
begin
  form.OnValidate := Value;
end;

function TSynBaseCompletionProposal.GetClSelect: TColor;
begin
  Result := Form.ClSelect;
end;

procedure TSynBaseCompletionProposal.SetClSelect(const Value: TColor);
begin
  Form.ClSelect := Value;
end;

function TSynBaseCompletionProposal.GetOnKeyDelete: TNotifyEvent;
begin
  result := Form.OnKeyDelete;
end;

procedure TSynBaseCompletionProposal.SetOnKeyDelete(const Value: TNotifyEvent);
begin
  form.OnKeyDelete := Value;
end;

procedure TSynBaseCompletionProposal.RFAnsi(const Value: boolean);
begin
  form.AnsiStrings := value;
end;

function TSynBaseCompletionProposal.SFAnsi: boolean;
begin
  result := form.AnsiStrings;
end;

function TSynBaseCompletionProposal.GetCase: boolean;
begin
  result := form.CaseSensitive;
end;

procedure TSynBaseCompletionProposal.SetCase(const Value: boolean);
begin
  form.CaseSensitive := Value;
end;

procedure TSynBaseCompletionProposal.SetWidth(Value: Integer);
begin
  FWidth := Value;
  Form.Width := FWidth;
  Form.SetNbLinesInWindow(Form.FNbLinesInWindow);
end;

procedure TSynBaseCompletionProposal.Activate;
begin
  if Assigned(Form) then Form.Activate;
end;

procedure TSynBaseCompletionProposal.Deactivate;
begin
  if Assigned(Form) then Form.Deactivate;
end;

function TSynBaseCompletionProposal.GetClBack: TColor;
begin
  Result := form.ClBackground;
end;

procedure TSynBaseCompletionProposal.SetClBack(const Value: TColor);
begin
  form.ClBackground := Value
end;

function TSynBaseCompletionProposal.GetClText: TColor;
begin
  Result := form.ClText;
end;

procedure TSynBaseCompletionProposal.SetClText(const Value: TColor);
begin
  form.ClText := Value;
end;

function TSynBaseCompletionProposal.GetClSelectedText: TColor;
begin
  Result := form.ClSelectedText;
end;

procedure TSynBaseCompletionProposal.SetClSelectedText(const Value: TColor);
begin
  form.ClSelectedText := Value;
end;

function TSynBaseCompletionProposal.GetShrink: Boolean;
begin
  Result := form.ShrinkList;
end;

procedure TSynBaseCompletionProposal.SetShrink(const Value: Boolean);
begin
  form.ShrinkList := Value;
end;

Procedure PrettyTextOut(c: TCanvas; x, y: integer; s: String; DoAlign: Boolean; BiggestWord: String);
var
  i: integer;
  b: TBrush;
  f: TFont;
  InBold : Boolean;
  DidAlign : Boolean;
  Color: TColor;
Begin
  b:= TBrush.Create;
  b.Assign(c.Brush);
  f:= TFont.Create;
  f.Assign(c.Font);
  InBold := False;
  DidAlign := False;
  Color := C.Font.Color;
  try
    i:= 1;
    while i<=Length(s) do
      case s[i] of
//maybe in the future, but for right now, no colors
        #1: Begin
              C.Font.Color:= Ord(s[i+3]) shl 16 + Ord(s[i+2]) shl 8 + Ord(s[i+1]);
              inc(i, 4);
            end;
        #2: Begin
              C.Font.Color:= Color;
              inc(i, 1);
            end;
        #3: Begin
              case s[i+1] of
                'B': c.Font.Style:= c.Font.Style+[fsBold];
                'b': c.Font.Style:= c.Font.Style-[fsBold];
                'U': c.Font.Style:= c.Font.Style+[fsUnderline];
                'u': c.Font.Style:= c.Font.Style-[fsUnderline];
                'I': c.Font.Style:= c.Font.Style+[fsItalic];
                'i': c.Font.Style:= c.Font.Style-[fsItalic];
              end;
              inc(i, 2);
            end;
        #9: Begin
              InBold := not(InBold);

              if InBold then
                c.Font.Style:= c.Font.Style+[fsBold]
              else begin
                c.Font.Style:= c.Font.Style-[fsBold];
                x := x + 1;  //spacing issue
              end;

              if not(DidAlign) and DoAlign then
              begin
                x := 1 + c.TextWidth(BiggestWord);
                DidAlign := True;
              end;
              inc(i);
            end;

        else
          if (not(DidAlign) and (x < c.TextWidth(BiggestWord)) and (pos(#9, s) <> 0) and DoAlign) or
             ((pos(#9, s) <> 0) and not(DoAlign)) or
             (pos(#9, s) = 0) or
             (DidAlign) then
          begin
            C.TextOut(x, y, s[i]);
            x:= x+c.TextWidth(s[i])
          end;

          {$IFNDEF SYN_KYLIX}
          if Win32Platform <> VER_PLATFORM_WIN32_NT then
            if InBold then x := x - 1; //spacing issue, need to verify on WINNT
          {$ENDIF}

          inc(i);
      end;
  except
  end;
  c.Font.Assign(f);
  f.Free;
  c.Brush.Assign(b);
  b.Free;
end;

procedure TSynBaseCompletionProposal.AddItem(ADisplayText, AInsertText: String);
begin
  GetInsertList.Add(AInsertText);
  GetItemList.Add(ADisplayText);
end;

procedure TSynBaseCompletionProposal.AddItemAt(Where : Integer; ADisplayText, AInsertText: String);
begin
  try
    GetInsertList.Insert(Where, AInsertText);
    GetItemList.Insert(Where, ADisplayText);
  except
    on exception do Exception.Create('Cannot insert item at position ' + IntToStr(Where) + '.');
  end;
end;


procedure TSynBaseCompletionProposal.ClearList;
begin
  GetInsertList.Clear;
  GetItemList.Clear;
end;

function TSynBaseCompletionProposal.DisplayItem(AIndex : Integer): String;
begin
  Result := GetItemList[AIndex];
end;

function TSynBaseCompletionProposal.InsertItem(AIndex : Integer): String;
begin
  Result := GetInsertList[AIndex];
end;

function TSynBaseCompletionProposal.GetDisplayKind: SynCompletionType;
begin
  result := form.DisplayType;
end;

procedure TSynBaseCompletionProposal.SetDisplayKind(const Value: SynCompletionType);
begin
  form.DisplayType := Value;
end;

function TSynBaseCompletionProposal.GetParameterToken: TCompletionParameter;
begin
  Result := Form.OnParameterToken;
end;

procedure TSynBaseCompletionProposal.SetParameterToken(
  const Value: TCompletionParameter);
begin
  Form.OnParameterToken := Value;
end;

function TSynBaseCompletionProposal.GetDefaultKind: SynCompletionType;
begin
  result := Form.DefaultType;
end;

procedure TSynBaseCompletionProposal.SetDefaultKind(const Value: SynCompletionType);
begin
  Form.DefaultType := Value;
end;

procedure TSynBaseCompletionProposal.SetUsePrettyText(const Value: Boolean);
begin
  FUsePrettyText := Value;
  Form.UsePrettyText := Value;
end;

procedure TSynBaseCompletionProposal.SetUseBiggestWord(const Value: String);
begin
  FBiggestWord := Value;
  Form.BiggestWord := Value;
end;

procedure TSynBaseCompletionProposal.SetUseInsertList(
  const Value: boolean);
begin
  FUseInsertList := Value;
  Form.UseInsertList := Value;
end;

function TSynBaseCompletionProposal.IsEndToken(AChar: Char): Boolean;
var i : Integer;
begin
  Result := False;
  i := 1;
  while i < length(FEndOfTokenChr) do
    if AChar = FEndOfTokenChr[i] then
    begin
      Result := True;
      break;
    end else inc(i);
end;

procedure TSynBaseCompletionProposal.SetEndOfTokenChar(
  const Value: string);
begin
  if FEndOfTokenChr <> Value then
  begin
    FEndOfTokenChr := Value;
    Form.EndOfTokenChr := Value;
  end;
end;

function TSynBaseCompletionProposal.GetTriggerChars: String;
begin
  Result := Form.TriggerChars;
end;

procedure TSynBaseCompletionProposal.SetTriggerChars(const Value: String);
begin
  Form.TriggerChars := Value;
end;

{ TSynCompletionProposal }

procedure TSynCompletionProposal.backspace(Sender: TObject);
var
  F: TSynBaseCompletionProposalForm;
begin
  F := Sender as TSynBaseCompletionProposalForm;
  if F.CurrentEditor <> nil then begin
    (F.CurrentEditor as TCustomSynEdit).CommandProcessor(ecDeleteLastChar, #0,
      nil);
  end;
end;

procedure TSynCompletionProposal.Cancel(Sender: TObject);
var
  F: TSynBaseCompletionProposalForm;
begin
  F := Sender as TSynBaseCompletionProposalForm;
  if F.CurrentEditor <> nil then begin
    if (F.CurrentEditor as TCustomSynEdit).Owner is TWinControl then
      TWinControl((F.CurrentEditor as TCustomSynEdit).Owner).SetFocus;
    (F.CurrentEditor as TCustomSynEdit).SetFocus;
  end;
  F.Hide;
end;

procedure TSynCompletionProposal.Validate(Sender: TObject; Shift: TShiftState);
var
  F: TSynBaseCompletionProposalForm;
  Value: string;
  TmpChr : Char;
  Pos: TPoint;
begin
  F := Sender as TSynBaseCompletionProposalForm;

  if F.CurrentEditor <> nil then
    with F.CurrentEditor as TCustomSynEdit do begin
      if F.APosition > -1 then
      begin
        BlockBegin := Point(CaretX - length(CurrentString), CaretY);
        BlockEnd := Point(CaretX, CaretY);

        //when there is a dot at the end, then GetSelstart = the first letter of
        //the thing we will replace
        //when there is *NO* dot at the end, getselstart refers to the dot
        if length(CurrentString) <> 0 then
        begin

          if IsEndToken(Text[SelStart]) then
          begin
            BlockBegin:= Point(CaretX - length(CurrentString) + 1, CaretY);
            BlockEnd:= Point(CaretX + 1, CaretY);
          end;
        end;

        if FUseInsertList then
        begin
          if LimitToMatchedText then
            Value := InsertList[Integer(ItemList.Objects[position])]
          else Value := InsertList[position]
        end else Value := ItemList[position];

        if Assigned(FOnCodeCompletion) then
        begin
          FOnCodeCompletion(Value, Shift);
          SelText := Value;
        end else begin
          SelText := Value;
        end;

        CurrentString := SelText;
        if length(Text) <> SelEnd + length(CurrentString) + 1 then
          if IsEndToken(Text[SelEnd + length(CurrentString)]) then
          begin
            TmpChr := Text[SelEnd + length(CurrentString)];
            SelEnd := (length(CurrentString) + SelEnd);
            SelStart := (length(CurrentString) + SelEnd + 1);
            SelText := TmpChr;
          end;
      end;

      with Editor do begin
        Pos := CaretXY;
        {*****************}
        {$IFNDEF SYN_KYLIX}
        Perform(WM_MBUTTONDOWN, 0, 0);
        {$ENDIF}
        Application.ProcessMessages;
        CaretXY := Pos;
        BlockBegin := CaretXY;
        BlockEnd := CaretXY;
      end;
//      SetFocus;
    end;
end;

procedure TSynCompletionProposal.KeyPress(Sender: TObject; var Key: Char);
var
  F: TSynBaseCompletionProposalForm;
begin
  F := Sender as TSynBaseCompletionProposalForm;
  if F.CurrentEditor <> nil then begin
    with F.CurrentEditor as TCustomSynEdit do
      CommandProcessor(ecChar, Key, nil);
  end;
end;

procedure TSynCompletionProposal.SetEditor(const Value: TCustomSynEdit);
begin
  if (fEditor <> nil) then
  begin
    RemoveEditor(fEditor);
    fEditor := nil;
  end;
  fEditor := Value;
  Form.CurrentEditor := Value;

  if (fEditor <> nil) then
  begin
    with fEditor do
    begin
      AddKeyDownHandler(fKeyDownProc);
      AddKeyPressHandler(fKeyPressProc);
    end;
    fEditor.FreeNotification(Self);
  end;
end;

procedure TSynCompletionProposal.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent is TCustomSynEdit) then
  begin
    RemoveEditor(AComponent as TCustomSynEdit);
    Editor := nil;
  end;
  inherited Notification(AComponent, Operation);
end;

constructor TSynCompletionProposal.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Form.OnKeyPress := KeyPress;
  Form.OnKeyDelete := backspace;
  Form.OnValidate := validate;
  Form.OnCancel := Cancel;
  EndOfTokenChr := '()[].';
  fKeyDownProc := TKeyDownProc.Create (EditorKeyDown);
  fKeyPressProc := TKeyPressProc.Create (EditorKeyPress);
  fEditor := nil;
  fNoNextKey := false;
  TriggerChars := '.';
  fTimerInterval:= 1000;
  {$IFDEF SYN_KYLIX}
  fShortCut := QMenus.ShortCut(Ord(' '), [ssCtrl]);
  {$ELSE}
  fShortCut := Menus.ShortCut(Ord(' '), [ssCtrl]);
  {$ENDIF}
end;

procedure TSynCompletionProposal.SetShortCut(Value: TShortCut);
begin
  FShortCut := Value;
end;

procedure TSynCompletionProposal.EditorKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  p             : TPoint;
  ShortCutKey   : Word;
  ShortCutShift : TShiftState;
begin
  ShortCutToKey (fShortCut,ShortCutKey,ShortCutShift);
  with sender as TCustomSynEdit do begin
    if not ReadOnly and (Shift = ShortCutShift) and (Key = ShortCutKey) then begin
      p := ClientToScreen(Point(CaretXPix, CaretYPix+LineHeight));
      Form.CurrentEditor:= Sender as TCustomSynEdit;
      ExecuteEx(GetPreviousToken (Sender as TCustomSynEdit),p.x,p.y, DefaultType);
      fNoNextKey := true;
      Key := 0;
      Shift := [];
    end;
  end;
end;

function TSynCompletionProposal.GetPreviousToken(FEditor: TCustomSynEdit): string;
var
  s: string;
  i: integer;
begin
  Result := '';
  if FEditor <> nil then begin
    s := FEditor.LineText;
    i := FEditor.CaretX - 1;
    if i <= length(s) then begin
      while (i > 0) and (s[i] > ' ') and (pos(s[i], FEndOfTokenChr) = 0) do
        dec(i);
      result := copy(s, i + 1, FEditor.CaretX - i - 1);
    end;
  end;
end;

procedure TSynCompletionProposal.EditorKeyPress(Sender: TObject; var Key: char);
begin
  if fNoNextKey then
  begin
    fNoNextKey := false;
    Key := #0;
  end else
  if Assigned(FTimer) then
  begin
    if (Pos(Key, TriggerChars) <> 0) then
      ActivateTimer(Sender as TCustomSynEdit)
    else
      DeactivateTimer;
  end;
end;

destructor TSynCompletionProposal.destroy;
begin
  // necessary to get Notification called before fEditors is freed
  Form.Free;
  Form := nil;

  RemoveEditor(fEditor);
  fKeyDownProc.Free;
  fKeyPressProc.Free;

  inherited;
end;

function TSynCompletionProposal.RemoveEditor(Editor: TCustomSynEdit): boolean;
begin
  Result := Assigned(Editor);
  if Result then
  begin
    Editor.RemoveKeyDownHandler(fKeyDownProc);
    Editor.RemoveKeyPressHandler(fKeyPressProc);
  end;
end;

function TSynBaseCompletionProposal.GetMatchText: Boolean;
begin
  Result := Form.MatchText;
end;

procedure TSynBaseCompletionProposal.SetMatchText(const Value: Boolean);
begin
  Form.MatchText := Value;
end;

procedure TSynBaseCompletionProposal.loaded;
begin
  inherited;
  Form.AssignedList.Assign(ItemList);
end;

procedure TSynBaseCompletionProposal.ResetAssignedList;
begin
  Form.AssignedList.Assign(ItemList);
end;

procedure TSynCompletionProposal.ActivateTimer(
  ACurrentEditor: TCustomSynEdit);
begin
  if Assigned(FTimer) then
  begin
    Form.CurrentEditor := ACurrentEditor;
    FTimer.Enabled := True;
  end;
end;

procedure TSynCompletionProposal.DeactivateTimer;
begin
  if Assigned(FTimer) then
  begin
    FTimer.Enabled := False;
  end;
end;

function TSynCompletionProposal.GetTimerInterval: Integer;
begin
  Result := FTimerInterval;
end;

procedure TSynCompletionProposal.SetTimerInterval(const Value: Integer);
begin
  FTimerInterval := Value;
  if Assigned(FTimer) then
    FTimer.Interval := Value;
end;

procedure TSynCompletionProposal.TimerExecute(Sender: TObject);
begin
  if not Assigned(FTimer) then exit;
  FTimer.Enabled := False; //GBN 13/11/2001  
  if Application.Active then
  begin
    DoExecute(Form.CurrentEditor as TCustomSynEdit);
    FNoNextKey := False;
  end else if Form.Visible then Form.Hide;
end;

procedure TSynCompletionProposal.DoExecute(AEditor: TCustomSynEdit);
var
  p: TPoint;
begin
  with AEditor do
  begin
    if (DefaultType <> ctCode) or not(ReadOnly) then
    begin
      p := ClientToScreen(Point(CaretXPix, CaretYPix + LineHeight));
      Form.CurrentEditor := AEditor;
      ExecuteEx(GetPreviousToken(AEditor), p.x, p.y, DefaultType);
      FNoNextKey := (DefaultType = ctCode) and Form.Visible;
    end;
  end;
end;

procedure TSynCompletionProposal.SetUseBuiltInTimer(const Value: Boolean);
begin
  FUseBuiltInTimer := Value;
  Form.FUseBuiltInTimer := Value;

  if Value then
  begin
    if not(Assigned(FTimer)) then
    begin
      FTimer := TTimer.Create(Self);
      FTimer.Enabled := False;
      FTimer.Interval := FTimerInterval;
      FTimer.OnTimer := TimerExecute;
    end;
  end else begin
    if Assigned(FTimer) then
    begin
      FreeAndNil(FTimer);
    end;
  end;
end;

{ TSynAutoComplete }

constructor TSynAutoComplete.Create(AOwner: TComponent);
begin
  inherited;

  FEndOfTokenChr := '()[].';
  fAutoCompleteList := TStringList.Create;
  fKeyDownProc := TKeyDownProc.Create (EditorKeyDown);
  fKeyPressProc := TKeyPressProc.Create (EditorKeyPress);
  fNoNextKey := false;
  {$IFDEF SYN_KYLIX}
  fShortCut := QMenus.ShortCut(Ord(' '), [ssShift]);
  {$ELSE}
  fShortCut := Menus.ShortCut(Ord(' '), [ssShift]);
  {$ENDIF}
end;

procedure TSynAutoComplete.SetShortCut(Value: TShortCut);
begin
  FShortCut := Value;
end;

destructor TSynAutoComplete.destroy;
begin
  RemoveEditor (fEditor);
  fKeyDownProc.Free;
  fKeyPressProc.Free;
  fAutoCompleteList.free;
  inherited;
end;

procedure TSynAutoComplete.EditorKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  ShortCutKey   : Word;
  ShortCutShift : TShiftState;
begin
  ShortCutToKey (fShortCut,ShortCutKey,ShortCutShift);
  if not (Sender as TCustomSynEdit).ReadOnly and
    (Shift = ShortCutShift) and (Key = ShortCutKey) then begin
    Execute(GetPreviousToken (Sender as TCustomSynEdit),Sender as TCustomSynEdit);
    fNoNextKey := true;
    Key := 0;
  end;
end;

procedure TSynAutoComplete.EditorKeyPress(Sender: TObject; var Key: char);
begin
  if fNoNextKey then begin
    fNoNextKey := false;
    Key := #0;
  end;
end;

procedure TSynAutoComplete.Execute(token: string; Editor: TCustomSynEdit);
var
  Temp: string;
  i, j, prevspace: integer;
  StartOfBlock: tpoint;
  ChangedIndent   : Boolean;
  ChangedTrailing : Boolean;
  TmpOptions : TSynEditorOptions;
  OrigOptions: TSynEditorOptions;
  BeginningSpaceCount : Integer;
begin
  i := AutoCompleteList.IndexOf(token);

  if (i <> -1) then
  begin
    TmpOptions := Editor.Options;
    OrigOptions:= Editor.Options;
    ChangedIndent   := eoAutoIndent in TmpOptions;
    ChangedTrailing := eoTrimTrailingSpaces in TmpOptions;

    if ChangedIndent then Exclude(TmpOptions, eoAutoIndent);
    if ChangedTrailing then Exclude(TmpOptions, eoTrimTrailingSpaces);

    if ChangedIndent or ChangedTrailing then
      Editor.Options := TmpOptions;

    Editor.UndoList.AddChange(crAutoCompleteBegin, StartOfBlock, StartOfBlock, '',
      smNormal);

    fNoNextKey := true;
    for j := 1 to length(token) do
      Editor.CommandProcessor(ecDeleteLastChar, ' ', nil);
    BeginningSpaceCount := Editor.CaretX - 1;
    inc(i);
    StartOfBlock := Point(-1, -1);
    while (i < AutoCompleteList.Count) and
          (length(AutoCompleteList[i]) > 0) and
          (AutoCompleteList[i][1] = '=') do
    begin
{      for j := 0 to PrevSpace - 1 do
        Editor.CommandProcessor(ecDeleteLastChar, ' ', nil);}
      Temp := AutoCompleteList[i];
      PrevSpace := 0;
      while (length(temp) >= PrevSpace + 2) and (temp[PrevSpace + 2] <= ' ') do
        inc(PrevSpace);
      for j := 2 to length(Temp) do begin
        Editor.CommandProcessor(ecChar, Temp[j], nil);
        if (Temp[j] = '|') then
          StartOfBlock := Editor.CaretXY
      end;
      inc(i);
      if (i < AutoCompleteList.Count) and
         (length(AutoCompleteList[i]) > 0) and
         (AutoCompleteList[i][1] = '=') then
      begin
         Editor.CommandProcessor (ecLineBreak,' ',nil);
         for j := 0 to BeginningSpaceCount  - 1do
           Editor.CommandProcessor (ecChar, ' ', nil);
      end;
    end;
    if (StartOfBlock.x <> -1) and (StartOfBlock.y <> -1) then begin
      Editor.CaretXY := StartOfBlock;
      Editor.CommandProcessor(ecDeleteLastChar, ' ', nil);
    end;

    if ChangedIndent or ChangedTrailing then Editor.Options := OrigOptions;

    Editor.UndoList.AddChange(crAutoCompleteEnd, StartOfBlock, StartOfBlock, '',
      smNormal);

  end;
end;

function TSynAutoComplete.GetPreviousToken(Editor: TCustomSynEdit): string;
var
  s: string;
  i: integer;
begin
  Result := '';
  if Editor <> nil then begin
    s := Editor.LineText;
    i := Editor.CaretX - 1;
    if i <= Length (s) then begin
      while (i > 0) and (s[i] > ' ') and (pos(s[i], FEndOfTokenChr) = 0) do
        Dec(i);
      Result := copy(s, i + 1, Editor.CaretX - i - 1);
    end;
  end
end;

procedure TSynAutoComplete.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent is TCustomSynEdit) then
    RemoveEditor(AComponent as TCustomSynEdit);
  inherited Notification(AComponent, Operation);
end;

function TSynAutoComplete.RemoveEditor(Editor: TCustomSynEdit): boolean;
begin
  Result := Assigned (Editor);
  if Result then begin
    Editor.RemoveKeyDownHandler (fKeyDownProc);
    Editor.RemoveKeyPressHandler (fKeyPressProc);
  end;
end;

procedure TSynAutoComplete.SetAutoCompleteList(List: TStrings);
begin
  fAutoCompleteList.Assign(List);
end;

procedure TSynAutoComplete.SetEditor(const Value: TCustomSynEdit);
begin
  if (fEditor <> nil) then begin
    RemoveEditor (fEditor);
    fEditor := nil;
  end;
  fEditor := Value;
  if (fEditor <> nil) then
    with fEditor do begin
      AddKeyDownHandler (fKeyDownProc);
      AddKeyPressHandler (fKeyPressProc);
    end;
end;

function TSynAutoComplete.GetTokenList: string;
var
  List: TStringList;
  i: integer;
begin
  Result := '';
  if AutoCompleteList.Count < 1 then Exit;
  List := TStringList.Create;
  i := 0;
  while (i < AutoCompleteList.Count) do begin
    if (length(AutoCompleteList[i]) > 0) and (AutoCompleteList[i][1] <> '=') then
      List.Add(Trim(AutoCompleteList[i]));
    inc(i);
  end;
  Result := List.Text;
  List.Free;
end;

function TSynAutoComplete.GetTokenValue(Token: string): string;
var
  i: integer;
  List: TStringList;
begin
  Result := '';
  i := AutoCompleteList.IndexOf(Token);
  if i <> -1 then begin
    List := TStringList.Create;
    Inc(i);
    while (i < AutoCompleteList.Count) and
      (length(AutoCompleteList[i]) > 0) and
      (AutoCompleteList[i][1] = '=') do begin
      if Length(AutoCompleteList[i]) = 1 then
        List.Add('')
      else
        List.Add(Copy(AutoCompleteList[i], 2, Length(AutoCompleteList[i])));
      inc(i);
    end;
    Result := List.Text;
    List.Free;
  end;
end;

end.

