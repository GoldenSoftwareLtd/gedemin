unit MessageForm;

{$mode objfpc}{$H+}

interface

uses
  Windows, Classes, SysUtils, forms, Dialogs, LCLStrConsts, Controls,
  Graphics, ExtCtrls, StdCtrls, LCLProc;



  function CreateMessageDialog(const Msg, ACaption: string; DlgType: TMsgDlgType;
    Buttons: TMsgDlgButtons): TForm;

  function MessageDlg(const Msg, ACaption: string; DlgType: TMsgDlgType;
    Buttons: TMsgDlgButtons): Integer;

implementation

var
  CreationControl: TCommonDialog = nil;
  HelpMsg: Cardinal;
  FindMsg: Cardinal;
  WndProcPtrAtom: TAtom = 0;

type
  TMessageForm = class(TForm)
  private
    FMsg: AnsiString;

    procedure HelpButtonClick(Sender: TObject);
  public
    constructor CreateNew(AOwner: TComponent); reintroduce;
  end;

constructor TMessageForm.CreateNew(AOwner: TComponent);
var
  NonClientMetrics: TNonClientMetrics;
begin
  inherited CreateNew(AOwner);
  NonClientMetrics.cbSize := sizeof(NonClientMetrics);
  if SystemParametersInfo(SPI_GETNONCLIENTMETRICS, 0, @NonClientMetrics, 0) then
    Font.Handle := CreateFontIndirect(NonClientMetrics.lfMessageFont);
end;

procedure TMessageForm.HelpButtonClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

var
  Captions: array[TMsgDlgType] of Pointer = (@rsMtWarning, @rsMtError,
    @rsMtInformation, @rsMtConfirmation, nil);
  IconIDs: array[TMsgDlgType] of PWideChar = (IDI_EXCLAMATION, IDI_HAND,
    IDI_ASTERISK, IDI_QUESTION, nil);
  ButtonNames: array[TMsgDlgBtn] of string = (
    'Yes', 'No', 'OK', 'Cancel', 'Abort', 'Retry', 'Ignore', 'All', 'NoToAll',
    'YesToAll', 'Help', 'Close');
  ButtonCaptions: array[TMsgDlgBtn] of Pointer = (
    @rsMbYes, @rsMbNo, @rsMbOK, @rsMbCancel, @rsMbAbort,
    @rsMbRetry, @rsMbIgnore, @rsMbAll, @rsMbNoToAll, @rsMbYesToAll,
    @rsMbHelp, @rsMbClose);
  ModalResults: array[TMsgDlgBtn] of Integer = (
    mrYes, mrNo, mrOk, mrCancel, mrAbort, mrRetry, mrIgnore, mrAll, mrNoToAll,
    mrYesToAll, 0, 0);
var
  ButtonWidths : array[TMsgDlgBtn] of integer;

function GetAveCharSize(Canvas: TCanvas): TPoint;
var
  I: Integer;
  Buffer: array[0..51] of WideChar;
begin
  for I := 0 to 25 do Buffer[I] := WideChar(I + Ord('A'));
  for I := 0 to 25 do Buffer[I + 26] := WideChar(I + Ord('a'));
  GetTextExtentPoint(Canvas.Handle, Buffer, 52, @TSize(Result));
  Result.X := Result.X div 52;
end;

function MulDiv2(Number, Numerator, Denominator: Integer): Integer;
begin
  Result := round(Number*Numerator/Denominator);
end;

function Max2(I, J: Integer): Integer;
begin
  if I > J then Result := I else Result := J;
end;


function CreateMessageDialog(const Msg, ACaption: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons): TForm;
const
  mcHorzMargin = 8;
  mcVertMargin = 8;
  mcHorzSpacing = 10;
  mcVertSpacing = 10;
  mcButtonWidth = 40;
  mcButtonHeight = 14;
  mcButtonSpacing = 4;
var
  DialogUnits: TPoint;
  HorzMargin, VertMargin, HorzSpacing, VertSpacing, ButtonWidth,
  ButtonHeight, ButtonSpacing, ButtonCount, ButtonGroupWidth,
  IconTextWidth, IconTextHeight, X, ALeft: Integer;
  B, DefaultButton, CancelButton: TMsgDlgBtn;
  TextRect: TRect;
  Flag: Cardinal;
  i, h, pos: Integer;
  s1: String;
  Temps: String;
begin
  Result := TMessageForm.CreateNew(Application);
  with Result do
  begin
    ControlStyle:= ControlStyle-[csSetCaption];
    PopupMode := pmAuto;
    BorderStyle := bsDialog;
    SetInitialBounds(0,0,230,100);
    BiDiMode := Application.BiDiMode;
    Canvas.Font := Font;
    DialogUnits := GetAveCharSize(Canvas);
    HorzMargin := MulDiv2(mcHorzMargin, DialogUnits.X, 4);
    VertMargin := MulDiv2(mcVertMargin, DialogUnits.Y, 8);
    HorzSpacing := MulDiv2(mcHorzSpacing, DialogUnits.X, 4);
    VertSpacing := MulDiv2(mcVertSpacing, DialogUnits.Y, 8);
    ButtonWidth := MulDiv2(mcButtonWidth, DialogUnits.X, 4);

    TextRect := Rect(0, 0, 220, 50);

    ButtonCount := 0;
    for B := Low(TMsgDlgBtn) to High(TMsgDlgBtn) do
      if B in Buttons then Inc(ButtonCount);

  //  if ButtonCount = 3 then
   //   ButtonWidth := 0;

    for B := Low(TMsgDlgBtn) to High(TMsgDlgBtn) do
    begin
      if B in Buttons then
      begin
        ButtonWidths[B] := Canvas.TextWidth(LoadResString(ButtonCaptions[B])) + 4;
        if ButtonWidths[B] > ButtonWidth then
          ButtonWidth := ButtonWidths[B];
      end;
    end;
    ButtonHeight := MulDiv2(mcButtonHeight, DialogUnits.Y, 8);
    ButtonSpacing := MulDiv2(mcButtonSpacing, DialogUnits.X, 4);

    SetRect(TextRect, 0, 0, 220, 0);

    IconTextWidth := 0;
    IconTextHeight := TextRect.Bottom;

    ButtonGroupWidth := 0;
    if ButtonCount <> 0 then
      ButtonGroupWidth := ButtonWidth * ButtonCount +
        ButtonSpacing * (ButtonCount - 1);

    Caption := ACaption;


    with TLabel.Create(Result) do
    begin
      Name := 'Message';
      Parent := Result;
      AutoSize := False;
      WordWrap := True;
      BoundsRect := TextRect;
      BiDiMode := Result.BiDiMode;
      Canvas.Font := Font;
      s1 := '';
      pos := 0;
      h := 0;

      for i:= 1 to length(msg) do
      begin
        if Canvas.TextWidth(s1 + msg[i]) > abs(BoundsRect.Left-BoundsRect.Right) then
        begin
          if s1[Length(s1)] <> ' ' then
            s1 := copy(s1, pos + 1, Length(s1) - pos)
          else
            s1 := '';
          inc(h);
        end;
          s1 := s1 + msg[i];
          if msg[i] = ' ' then
            pos := Length(s1);
      end;
      if s1 <> '' then
        inc(h);
      Caption := msg;

      Height := h * Canvas.TextHeight(msg);


      SetBounds(0, VertMargin,
        TextRect.Right, Height);

      IconTextHeight := Height;
    end;

    ClientHeight := IconTextHeight + ButtonHeight + VertSpacing +
       VertMargin * 2;


    if mbOk in Buttons then DefaultButton := mbOk else
      if mbYes in Buttons then DefaultButton := mbYes else
        DefaultButton := mbRetry;
    if mbCancel in Buttons then CancelButton := mbCancel else
      if mbNo in Buttons then CancelButton := mbNo else
        CancelButton := mbOk;
    X := (ClientWidth - ButtonGroupWidth) div 2;

    for B := Low(TMsgDlgBtn) to High(TMsgDlgBtn) do
      if B in Buttons then
        with TButton.Create(Result) do
        begin
          Name := ButtonNames[B];
          Parent := Result;
          Caption := LoadResString(ButtonCaptions[B]);
          ModalResult := ModalResults[B];
          if B = DefaultButton then Default := True;
          if B = CancelButton then Cancel := True;
          SetBounds(X, IconTextHeight + VertMargin + VertSpacing,
            ButtonWidth, ButtonHeight);
          Inc(X, ButtonWidth + ButtonSpacing);
          if B = mbHelp then
            OnClick := @TMessageForm(Result).HelpButtonClick;
        end;
  end;

end;

function MessageDlg(const Msg, ACaption: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons): Integer;
begin
  with CreateMessageDialog(Msg, ACaption, DlgType, Buttons) do
    try
      Position := poScreenCenter;
      Result := ShowModal;
    finally
      Free;
    end;
end;

procedure InitGlobals;
var
  AtomText: array[0..31] of Char;
begin
  HelpMsg := RegisterWindowMessage(HelpMsgString);
  FindMsg := RegisterWindowMessage(FindMsgString);
  WndProcPtrAtom := GlobalAddAtom(pWideChar(StrFmt(@AtomText,
    'WndProcPtr%.8X%.8X', [HInstance, GetCurrentThreadID])));
end;

initialization
  InitGlobals;
finalization
  if WndProcPtrAtom <> 0 then GlobalDeleteAtom(WndProcPtrAtom);

end.

