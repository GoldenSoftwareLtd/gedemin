
{******************************************}
{                                          }
{     FastReport v2.5 - Dialog designer    }
{         Standard Dialog controls         }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_DCtrl;

interface

{$I FR.inc}
{$IFDEF RX}
  {$DEFINE DateEdit}
{$ENDIF}
{$IFNDEF Delphi2}
  {$DEFINE DateEdit}
{$ENDIF}


uses
  Windows, Messages, SysUtils, Classes, Graphics, FR_Class, StdCtrls,
  Controls, Forms, Menus, Dialogs
{$IFDEF RX}
, Mask, DateUtil, ToolEdit
{$ELSE}
, Comctrls
{$ENDIF};

type
  TfrDialogControls = class(TComponent) // fake component
  end;

  TfrStdControl = class(TfrControl)
  private
    procedure FontEditor(Sender: TObject);
    procedure OnClickEditor(Sender: TObject);
    procedure OnClick(Sender: TObject);
  protected
    procedure SetPropValue(Index: String; Value: Variant); override;
    function GetPropValue(Index: String): Variant; override;
    function DoMethod(MethodName: String; Par1, Par2, Par3: Variant): Variant; override;
  public
    procedure AssignControl(AControl: TControl);
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure SaveToFR3Stream(Stream: TStream); override;
    procedure DefineProperties; override;
    procedure ShowEditor; override;
  end;

  TfrLabelControl = class(TfrStdControl)
  private
    FLabel: TLabel;
  protected
    procedure SetPropValue(Index: String; Value: Variant); override;
    function GetPropValue(Index: String): Variant; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Draw(Canvas: TCanvas); override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure SaveToFR3Stream(Stream: TStream); override;
    procedure DefineProperties; override;
    property LabelCtl: TLabel read FLabel;
  end;

  TfrEditControl = class(TfrStdControl)
  private
    FEdit: TEdit;
  protected
    procedure SetPropValue(Index: String; Value: Variant); override;
    function GetPropValue(Index: String): Variant; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure SaveToFR3Stream(Stream: TStream); override;
    procedure DefineProperties; override;
    property Edit: TEdit read FEdit;
  end;

  TfrMemoControl = class(TfrStdControl)
  private
    FMemo: TMemo;
    procedure LinesEditor(Sender: TObject);
  protected
    procedure SetPropValue(Index: String; Value: Variant); override;
    function GetPropValue(Index: String): Variant; override;
    function DoMethod(MethodName: String; Par1, Par2, Par3: Variant): Variant; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure SaveToFR3Stream(Stream: TStream); override;
    procedure DefineProperties; override;
    property MemoCtl: TMemo read FMemo;
  end;

  TfrButtonControl = class(TfrStdControl)
  private
    FButton: TButton;
  protected
    procedure SetPropValue(Index: String; Value: Variant); override;
    function GetPropValue(Index: String): Variant; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure SaveToFR3Stream(Stream: TStream); override;
    procedure DefineProperties; override;
    property Button: TButton read FButton;
  end;

  TfrCheckBoxControl = class(TfrStdControl)
  private
    FCheckBox: TCheckBox;
  protected
    procedure SetPropValue(Index: String; Value: Variant); override;
    function GetPropValue(Index: String): Variant; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure SaveToFR3Stream(Stream: TStream); override;
    procedure DefineProperties; override;
    property CheckBox: TCheckBox read FCheckBox;
  end;

  TfrRadioButtonControl = class(TfrStdControl)
  private
    FRadioButton: TRadioButton;
  protected
    procedure SetPropValue(Index: String; Value: Variant); override;
    function GetPropValue(Index: String): Variant; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure SaveToFR3Stream(Stream: TStream); override;
    procedure DefineProperties; override;
    property RadioButton: TRadioButton read FRadioButton;
  end;

  TfrListBoxControl = class(TfrStdControl)
  private
    FListBox: TListBox;
    procedure LinesEditor(Sender: TObject);
  protected
    procedure SetPropValue(Index: String; Value: Variant); override;
    function GetPropValue(Index: String): Variant; override;
    function DoMethod(MethodName: String; Par1, Par2, Par3: Variant): Variant; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure SaveToFR3Stream(Stream: TStream); override;
    procedure DefineProperties; override;
    property ListBox: TListBox read FListBox;
  end;

  TfrComboBoxControl = class(TfrStdControl)
  private
    FComboBox: TComboBox;
    procedure ComboBoxDrawItem(Control: TWinControl;
     Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure LinesEditor(Sender: TObject);
    procedure OnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  protected
    procedure SetPropValue(Index: String; Value: Variant); override;
    function GetPropValue(Index: String): Variant; override;
    function DoMethod(MethodName: String; Par1, Par2, Par3: Variant): Variant; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure SaveToFR3Stream(Stream: TStream); override;
    procedure DefineProperties; override;
    property ComboBox: TComboBox read FComboBox;
  end;

{$IFDEF DateEdit}
  TfrDateEditControl = class(TfrStdControl)
  private
{$IFDEF RX}
    FDateEdit: TDateEdit;
{$ELSE}
    FDateEdit: TDateTimePicker;
{$ENDIF}
  protected
    procedure SetPropValue(Index: String; Value: Variant); override;
    function GetPropValue(Index: String): Variant; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
{$IFNDEF RX}
    procedure SaveToFR3Stream(Stream: TStream); override;
{$ENDIF}
    procedure DefineProperties; override;
{$IFDEF RX}
    property DateEdit: TDateEdit read FDateEdit;
{$ELSE}
    property DateEdit: TDateTimePicker read FDateEdit;
{$ENDIF}
  end;
{$ENDIF}

const
  csLookup = csOwnerDrawFixed;

function frGetShortCuts: String;


implementation

uses FR_Utils, FR_Const, FR_LEdit
{$IFDEF Delphi6}
, Variants
{$ENDIF};

{$R FR_DCtrl.RES}
{$R FR_Lng4.RES}

type
  THackControl = class(TControl)
  end;


const
  ShortCuts: array[0..81] of TShortCut = (
    Byte('A') or scCtrl,
    Byte('B') or scCtrl,
    Byte('C') or scCtrl,
    Byte('D') or scCtrl,
    Byte('E') or scCtrl,
    Byte('F') or scCtrl,
    Byte('G') or scCtrl,
    Byte('H') or scCtrl,
    Byte('I') or scCtrl,
    Byte('J') or scCtrl,
    Byte('K') or scCtrl,
    Byte('L') or scCtrl,
    Byte('M') or scCtrl,
    Byte('N') or scCtrl,
    Byte('O') or scCtrl,
    Byte('P') or scCtrl,
    Byte('Q') or scCtrl,
    Byte('R') or scCtrl,
    Byte('S') or scCtrl,
    Byte('T') or scCtrl,
    Byte('U') or scCtrl,
    Byte('V') or scCtrl,
    Byte('W') or scCtrl,
    Byte('X') or scCtrl,
    Byte('Y') or scCtrl,
    Byte('Z') or scCtrl,
    VK_F1,
    VK_F2,
    VK_F3,
    VK_F4,
    VK_F5,
    VK_F6,
    VK_F7,
    VK_F8,
    VK_F9,
    VK_F10,
    VK_F11,
    VK_F12,
    VK_F1 or scCtrl,
    VK_F2 or scCtrl,
    VK_F3 or scCtrl,
    VK_F4 or scCtrl,
    VK_F5 or scCtrl,
    VK_F6 or scCtrl,
    VK_F7 or scCtrl,
    VK_F8 or scCtrl,
    VK_F9 or scCtrl,
    VK_F10 or scCtrl,
    VK_F11 or scCtrl,
    VK_F12 or scCtrl,
    VK_F1 or scShift,
    VK_F2 or scShift,
    VK_F3 or scShift,
    VK_F4 or scShift,
    VK_F5 or scShift,
    VK_F6 or scShift,
    VK_F7 or scShift,
    VK_F8 or scShift,
    VK_F9 or scShift,
    VK_F10 or scShift,
    VK_F11 or scShift,
    VK_F12 or scShift,
    VK_F1 or scShift or scCtrl,
    VK_F2 or scShift or scCtrl,
    VK_F3 or scShift or scCtrl,
    VK_F4 or scShift or scCtrl,
    VK_F5 or scShift or scCtrl,
    VK_F6 or scShift or scCtrl,
    VK_F7 or scShift or scCtrl,
    VK_F8 or scShift or scCtrl,
    VK_F9 or scShift or scCtrl,
    VK_F10 or scShift or scCtrl,
    VK_F11 or scShift or scCtrl,
    VK_F12 or scShift or scCtrl,
    VK_INSERT,
    VK_INSERT or scShift,
    VK_INSERT or scCtrl,
    VK_DELETE,
    VK_DELETE or scShift,
    VK_DELETE or scCtrl,
    VK_BACK or scAlt,
    VK_BACK or scShift or scAlt);


function frGetShortCuts: String;
var
  i: Word;
begin
  Result := frLoadStr(SNotAssigned);
  for i := Low(ShortCuts) to High(ShortCuts) do
    Result := Result + ';' + ShortCutToText(ShortCuts[i]);
  SetLength(Result, Length(Result) - 1);
end;


{ TfrStdControl }

procedure TfrStdControl.DefineProperties;
begin
  inherited DefineProperties;
  AddProperty('Color', [frdtColor], nil);
  AddProperty('Enabled', [frdtBoolean], nil);
  AddProperty('Font', [frdtHasEditor], FontEditor);
  AddProperty('Font.Name', [], nil);
  AddProperty('Font.Size', [], nil);
  AddProperty('Font.Style', [], nil);
  AddProperty('Font.Color', [], nil);
  AddProperty('OnClick', [frdtHasEditor, frdtOneObject], OnClickEditor);
end;

procedure TfrStdControl.SetPropValue(Index: String; Value: Variant);
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
  SetFontProp(THackControl(Control).Font, Index, Value);
  if Index = 'COLOR' then
    THackControl(Control).Color := Value
  else if Index = 'ENABLED' then
    Control.Enabled := Value
  else if Index = 'LEFT' then
  begin
    if DocMode = dmPrinting then
      Control.Left := Value;
  end
  else if Index = 'TOP' then
  begin
    if DocMode = dmPrinting then
      Control.Top := Value;
  end
  else if Index = 'WIDTH' then
  begin
    if DocMode = dmPrinting then
      Control.Width := Value;
  end
  else if Index = 'HEIGHT' then
  begin
    if DocMode = dmPrinting then
      Control.Height := Value;
  end
  else if Index = 'VISIBLE' then
  begin
    if DocMode = dmPrinting then
      Control.Visible := Value;
  end
end;

function TfrStdControl.GetPropValue(Index: String): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := inherited GetPropValue(Index);
  if Result <> Null then Exit;
  Result := GetFontProp(THackControl(Control).Font, Index);
  if Index = 'COLOR' then
    Result := THackControl(Control).Color
  else if Index = 'ENABLED' then
    Result := Control.Enabled
end;

function TfrStdControl.DoMethod(MethodName: String; Par1, Par2, Par3: Variant): Variant;
begin
  Result := inherited DoMethod(MethodName, Par1, Par2, Par3);
  if MethodName = 'SETFOCUS' then
    if Control is TWinControl then
      TWinControl(Control).SetFocus;
end;

procedure TfrStdControl.LoadFromStream(Stream: TStream);
begin
  inherited LoadFromStream(Stream);
  THackControl(Control).Color := frReadInteger(Stream);
  Control.Enabled := frReadBoolean(Stream);
  frReadFont(Stream, THackControl(Control).Font);
end;

procedure TfrStdControl.SaveToStream(Stream: TStream);
begin
  inherited SaveToStream(Stream);
  frWriteInteger(Stream, THackControl(Control).Color);
  frWriteBoolean(Stream, Control.Enabled);
  frWriteFont(Stream, THackControl(Control).Font);
end;

procedure TfrStdControl.ShowEditor;
begin
  frMemoEditor(nil);
end;

procedure TfrStdControl.FontEditor(Sender: TObject);
var
  i: Integer;
  t: TfrView;
  fd: TFontDialog;
begin
  fd := TFontDialog.Create(nil);
  with fd do
  begin
    Font.Assign(THackControl(Control).Font);
    if Execute then
    begin
      frDesigner.BeforeChange;
      for i := 0 to frDesigner.Page.Objects.Count - 1 do
      begin
        t := frDesigner.Page.Objects[i];
        if t.Selected and (t is TfrStdControl) then
          if (t.Restrictions and frrfDontModify) = 0 then
            THackControl(TfrStdControl(t).Control).Font.Assign(Font);
      end;
      frDesigner.AfterChange;
    end;
  end;
  fd.Free;
end;

procedure TfrStdControl.OnClickEditor(Sender: TObject);
begin
  ShowEditor;
end;

procedure TfrStdControl.OnClick(Sender: TObject);
var
  sl, sl1: TStringList;
begin
  if DocMode = dmDesigning then Exit;
  CurView := Self;
  sl := TStringList.Create;
  sl1 := TStringList.Create;
  frInterpretator.PrepareScript(Script, sl, sl1);
  frInterpretator.DoScript(sl);
  sl.Free;
  sl1.Free;
end;

procedure TfrStdControl.AssignControl(AControl: TControl);
begin
  FControl := AControl;
  THackControl(Control).OnClick := OnClick;
end;

procedure TfrStdControl.SaveToFR3Stream(Stream: TStream);
var
  fs: Integer;

  procedure WriteStr(const s: String);
  begin
    Stream.Write(s[1], Length(s));
  end;

begin
  inherited;

  fs := 0;
  if fsBold in THackControl(Control).Font.Style then
    fs := fs or 1;
  if fsItalic in THackControl(Control).Font.Style then
    fs := fs or 2;
  if fsUnderline in THackControl(Control).Font.Style then
    fs := fs or 4;
  if fsStrikeout in THackControl(Control).Font.Style then
    fs := fs or 8;

  WriteStr(' Font.Name="' + THackControl(Control).Font.Name +
    '" Font.Height="' + IntToStr(THackControl(Control).Font.Height) +
    '" Font.Color="' + IntToStr(THackControl(Control).Font.Color) +
    '" Font.Style="' + IntToStr(fs) +
    '" Color="' + IntToStr(THackControl(Control).Color) + '"');

  if not THackControl(Control).Enabled then
    WriteStr(' Enabled="False"');
end;

{ TfrLabelControl }

constructor TfrLabelControl.Create;
begin
  inherited Create;
  FLabel := TLabel.Create(nil);
  FLabel.Parent := frDialogForm;
  FLabel.Caption := 'Label';
  AssignControl(FLabel);
  BaseName := 'Label';

  frConsts['taLeftJustify'] := taLeftJustify;
  frConsts['taRightJustify'] := taRightJustify;
  frConsts['taCenter'] := taCenter;
end;

destructor TfrLabelControl.Destroy;
begin
  FLabel.Free;
  inherited Destroy;
end;

procedure TfrLabelControl.DefineProperties;
begin
  inherited DefineProperties;
  AddEnumProperty('Alignment',
    'taLeftJustify;taRightJustify;taCenter',
    [taLeftJustify,taRightJustify,taCenter]);
  AddProperty('AutoSize', [frdtBoolean], nil);
  AddProperty('Caption', [frdtString], nil);
  AddProperty('WordWrap', [frdtBoolean], nil);
end;

procedure TfrLabelControl.SetPropValue(Index: String; Value: Variant);
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
  if Index = 'ALIGNMENT' then
    FLabel.Alignment := Value
  else if Index = 'AUTOSIZE' then
    FLabel.AutoSize := Value
  else if Index = 'CAPTION' then
    FLabel.Caption := Value
  else if Index = 'WORDWRAP' then
    FLabel.WordWrap := Value
end;

function TfrLabelControl.GetPropValue(Index: String): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := inherited GetPropValue(Index);
  if Result <> Null then Exit;
  if Index = 'ALIGNMENT' then
    Result := FLabel.Alignment
  else if Index = 'AUTOSIZE' then
    Result := FLabel.AutoSize
  else if Index = 'CAPTION' then
    Result := FLabel.Caption
  else if Index = 'WORDWRAP' then
    Result := FLabel.WordWrap
end;

procedure TfrLabelControl.Draw(Canvas: TCanvas);
begin
  BeginDraw(Canvas);
  if Prop['AutoSize'] = True then
  begin
    dx := FLabel.Width;
    dy := FLabel.Height;
  end
  else
  begin
    FLabel.Width := dx;
    FLabel.Height := dy;
  end;
  CalcGaps;
  PaintDesignControl;
  RestoreCoord;
end;

procedure TfrLabelControl.LoadFromStream(Stream: TStream);
begin
  inherited LoadFromStream(Stream);
  FLabel.Alignment := TAlignment(frReadByte(Stream));
  FLabel.AutoSize := frReadBoolean(Stream);
  FLabel.Caption := frReadString(Stream);
  FLabel.WordWrap := frReadBoolean(Stream);
  if Prop['AutoSize'] = True then
  begin
    dx := FLabel.Width;
    dy := FLabel.Height;
  end;
end;

procedure TfrLabelControl.SaveToStream(Stream: TStream);
begin
  inherited SaveToStream(Stream);
  frWriteByte(Stream, Byte(FLabel.Alignment));
  frWriteBoolean(Stream, FLabel.AutoSize);
  frWriteString(Stream, FLabel.Caption);
  frWriteBoolean(Stream, FLabel.WordWrap);
end;

procedure TfrLabelControl.SaveToFR3Stream(Stream: TStream);

  procedure WriteStr(const s: String);
  begin
    Stream.Write(s[1], Length(s));
  end;

begin
  inherited;

  WriteStr(' Alignment="' + IntToStr(Integer(FLabel.Alignment)) +
    '" AutoSize="' + IntToStr(Integer(FLabel.AutoSize)) +
    '" Caption="' + StrToXML(FLabel.Caption) +
    '" WordWrap="' + IntToStr(Integer(FLabel.WordWrap)) + '"');
end;


{ TfrEditControl }

constructor TfrEditControl.Create;
begin
  inherited Create;
  FEdit := TEdit.Create(nil);
  FEdit.Parent := frDialogForm;
  FEdit.Text := 'Edit';
  AssignControl(FEdit);
  BaseName := 'Edit';
  dx := 121; dy := 21;
end;

destructor TfrEditControl.Destroy;
begin
  FEdit.Free;
  inherited Destroy;
end;

procedure TfrEditControl.DefineProperties;
begin
  inherited DefineProperties;
  AddProperty('Text', [frdtString], nil);
  AddProperty('ReadOnly', [frdtBoolean], nil);
end;

procedure TfrEditControl.SetPropValue(Index: String; Value: Variant);
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
  if Index = 'TEXT' then
    FEdit.Text := Value
  else if Index = 'READONLY' then
    FEdit.ReadOnly := Value
end;

function TfrEditControl.GetPropValue(Index: String): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := inherited GetPropValue(Index);
  if Result <> Null then Exit;
  if Index = 'TEXT' then
    Result := FEdit.Text
  else if Index = 'READONLY' then
    Result := FEdit.ReadOnly
end;

procedure TfrEditControl.LoadFromStream(Stream: TStream);
begin
  inherited LoadFromStream(Stream);
  FEdit.Text := frReadString(Stream);
  FEdit.ReadOnly := frReadBoolean(Stream);
end;

procedure TfrEditControl.SaveToStream(Stream: TStream);
begin
  inherited SaveToStream(Stream);
  frWriteString(Stream, FEdit.Text);
  frWriteBoolean(Stream, FEdit.ReadOnly);
end;

procedure TfrEditControl.SaveToFR3Stream(Stream: TStream);

  procedure WriteStr(const s: String);
  begin
    Stream.Write(s[1], Length(s));
  end;

begin
  inherited;

  WriteStr(' Text="' + StrToXML(FEdit.Text) +
    '" ReadOnly="' + IntToStr(Integer(FEdit.ReadOnly)) + '"');
end;


{ TfrMemoControl }

constructor TfrMemoControl.Create;
begin
  inherited Create;
  FMemo := TMemo.Create(nil);
  FMemo.Parent := frDialogForm;
  FMemo.Text := 'Memo';
  AssignControl(FMemo);
  BaseName := 'Memo';
  dx := 185; dy := 89;
end;

destructor TfrMemoControl.Destroy;
begin
  FMemo.Free;
  inherited Destroy;
end;

procedure TfrMemoControl.DefineProperties;
begin
  inherited DefineProperties;
  AddProperty('Lines', [frdtHasEditor, frdtOneObject], LinesEditor);
  AddProperty('Lines.Count', [], nil);
  AddProperty('ReadOnly', [frdtBoolean], nil);
  AddProperty('Text', [], nil);
end;

procedure TfrMemoControl.SetPropValue(Index: String; Value: Variant);
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
  if Index = 'READONLY' then
    FMemo.ReadOnly := Value
  else if Index = 'TEXT' then
    FMemo.Text := Value
end;

function TfrMemoControl.GetPropValue(Index: String): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := inherited GetPropValue(Index);
  if Result <> Null then Exit;
  if Index = 'READONLY' then
    Result := FMemo.ReadOnly
  else if Index = 'LINES.COUNT' then
    Result := FMemo.Lines.Count
  else if Index = 'TEXT' then
    Result := FMemo.Text
end;

function TfrMemoControl.DoMethod(MethodName: String; Par1, Par2, Par3: Variant): Variant;
begin
  Result := inherited DoMethod(MethodName, Par1, Par2, Par3);
  if Result = Null then
    Result := LinesMethod(FMemo.Lines, MethodName, 'LINES', Par1, Par2, Par3);
end;

procedure TfrMemoControl.LoadFromStream(Stream: TStream);
begin
  inherited LoadFromStream(Stream);
  FMemo.Text := frReadString(Stream);
  FMemo.ReadOnly := frReadBoolean(Stream);
end;

procedure TfrMemoControl.SaveToStream(Stream: TStream);
begin
  inherited SaveToStream(Stream);
  frWriteString(Stream, FMemo.Text);
  frWriteBoolean(Stream, FMemo.ReadOnly);
end;

procedure TfrMemoControl.LinesEditor(Sender: TObject);
begin
  with TfrLinesEditorForm.Create(nil) do
  begin
    M1.Text := FMemo.Text;
    if (ShowModal = mrOk) and ((Restrictions and frrfDontModify) = 0) then
    begin
      frDesigner.BeforeChange;
      FMemo.Text := M1.Text;
      frDesigner.AfterChange;
    end;
    Free;
  end;
end;

procedure TfrMemoControl.SaveToFR3Stream(Stream: TStream);

  procedure WriteStr(const s: String);
  begin
    Stream.Write(s[1], Length(s));
  end;

begin
  inherited;

  WriteStr(' Lines.Text="' + StrToXML(FMemo.Text) +
    '" ReadOnly="' + IntToStr(Integer(FMemo.ReadOnly)) + '"');
end;


{ TfrButtonControl }

constructor TfrButtonControl.Create;
begin
  inherited Create;
  FButton := TButton.Create(nil);
  FButton.Parent := frDialogForm;
  FButton.Caption := 'Button';
  AssignControl(FButton);
  BaseName := 'Button';
  dx := 75; dy := 25;
end;

destructor TfrButtonControl.Destroy;
begin
  FButton.Free;
  inherited Destroy;
end;

procedure TfrButtonControl.DefineProperties;
begin
  inherited DefineProperties;
  AddProperty('Cancel', [], nil);
  AddProperty('Caption', [frdtString], nil);
  AddProperty('Default', [], nil);
  AddEnumProperty('ModalResult',
    'mrNone;mrOk;mrCancel',
    [mrNone,mrOk,mrCancel]);
end;

procedure TfrButtonControl.SetPropValue(Index: String; Value: Variant);
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
  if Index = 'CAPTION' then
    FButton.Caption := Value
  else if Index = 'MODALRESULT' then
  begin
    FButton.ModalResult := Value;
    FButton.Cancel := FButton.ModalResult = mrCancel;
    FButton.Default := FButton.ModalResult = mrOk;
  end
  else if Index = 'CANCEL' then
    FButton.Cancel := Value
  else if Index = 'DEFAULT' then
    FButton.Default := Value
end;

function TfrButtonControl.GetPropValue(Index: String): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := inherited GetPropValue(Index);
  if Result <> Null then Exit;
  if Index = 'CAPTION' then
    Result := FButton.Caption
  else if Index = 'MODALRESULT' then
    Result := FButton.ModalResult
  else if Index = 'CANCEL' then
    Result := FButton.Cancel
  else if Index = 'DEFAULT' then
    Result := FButton.Default
end;

procedure TfrButtonControl.LoadFromStream(Stream: TStream);
begin
  inherited LoadFromStream(Stream);
  FButton.Caption := frReadString(Stream);
  FButton.ModalResult := frReadWord(Stream);
  FButton.Cancel := FButton.ModalResult = mrCancel;
  FButton.Default := FButton.ModalResult = mrOk;
end;

procedure TfrButtonControl.SaveToStream(Stream: TStream);
begin
  inherited SaveToStream(Stream);
  frWriteString(Stream, FButton.Caption);
  frWriteWord(Stream, FButton.ModalResult);
end;

procedure TfrButtonControl.SaveToFR3Stream(Stream: TStream);

  procedure WriteStr(const s: String);
  begin
    Stream.Write(s[1], Length(s));
  end;

begin
  inherited;

  WriteStr(' Caption="' + StrToXML(FButton.Caption) +
    '" ModalResult="' + IntToStr(Integer(FButton.ModalResult)) + '"');

  if FButton.ModalResult=mrOk then
    WriteStr(' Default="True"')
  else if FButton.ModalResult=mrCancel then
    WriteStr(' Cancel="True"');
end;


{ TfrCheckBoxControl }

constructor TfrCheckBoxControl.Create;
begin
  inherited Create;
  FCheckBox := TCheckBox.Create(nil);
  FCheckBox.Parent := frDialogForm;
  FCheckBox.Caption := 'CheckBox';
  AssignControl(FCheckBox);
  BaseName := 'CheckBox';
  dx := 97; dy := 17;
end;

destructor TfrCheckBoxControl.Destroy;
begin
  FCheckBox.Free;
  inherited Destroy;
end;

procedure TfrCheckBoxControl.DefineProperties;
begin
  inherited DefineProperties;
  AddEnumProperty('Alignment',
    'taLeftJustify;taRightJustify',
    [taLeftJustify,taRightJustify]);
  AddProperty('Checked', [frdtBoolean], nil);
  AddProperty('Caption', [frdtString], nil);
end;

procedure TfrCheckBoxControl.SetPropValue(Index: String; Value: Variant);
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
  if Index = 'ALIGNMENT' then
    FCheckBox.Alignment := Value
  else if Index = 'CHECKED' then
    FCheckBox.Checked := Value
  else if Index = 'CAPTION' then
    FCheckBox.Caption := Value
end;

function TfrCheckBoxControl.GetPropValue(Index: String): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := inherited GetPropValue(Index);
  if Result <> Null then Exit;
  if Index = 'ALIGNMENT' then
    Result := FCheckBox.Alignment
  else if Index = 'CHECKED' then
    Result := FCheckBox.Checked
  else if Index = 'CAPTION' then
    Result := FCheckBox.Caption
end;

procedure TfrCheckBoxControl.LoadFromStream(Stream: TStream);
begin
  inherited LoadFromStream(Stream);
  FCheckBox.Alignment := TAlignment(frReadByte(Stream));
  FCheckBox.Checked := frReadBoolean(Stream);
  FCheckBox.Caption := frReadString(Stream);
end;

procedure TfrCheckBoxControl.SaveToStream(Stream: TStream);
begin
  inherited SaveToStream(Stream);
  frWriteByte(Stream, Byte(FCheckBox.Alignment));
  frWriteBoolean(Stream, FCheckBox.Checked);
  frWriteString(Stream, FCheckBox.Caption);
end;

procedure TfrCheckBoxControl.SaveToFR3Stream(Stream: TStream);

  procedure WriteStr(const s: String);
  begin
    Stream.Write(s[1], Length(s));
  end;

begin
  inherited;

  WriteStr(' Caption="' + StrToXML(FCheckBox.Caption) +
    '" Alignment="' + IntToStr(Integer(FCheckBox.Alignment)) +
    '" Checked="' + IntToStr(Integer(FCheckBox.Checked)) + '"');
end;


{ TfrRadioButtonControl }

constructor TfrRadioButtonControl.Create;
begin
  inherited Create;
  FRadioButton := TRadioButton.Create(nil);
  FRadioButton.Parent := frDialogForm;
  FRadioButton.Caption := 'RadioButton';
  AssignControl(FRadioButton);
  BaseName := 'RadioButton';
  dx := 113; dy := 17;
end;

destructor TfrRadioButtonControl.Destroy;
begin
  FRadioButton.Free;
  inherited Destroy;
end;

procedure TfrRadioButtonControl.DefineProperties;
begin
  inherited DefineProperties;
  AddEnumProperty('Alignment',
    'taLeftJustify;taRightJustify',
    [taLeftJustify,taRightJustify]);
  AddProperty('Checked', [frdtBoolean], nil);
  AddProperty('Caption', [frdtString], nil);
end;

procedure TfrRadioButtonControl.SetPropValue(Index: String; Value: Variant);
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
  if Index = 'ALIGNMENT' then
    FRadioButton.Alignment := Value
  else if Index = 'CHECKED' then
    FRadioButton.Checked := Value
  else if Index = 'CAPTION' then
    FRadioButton.Caption := Value
end;

function TfrRadioButtonControl.GetPropValue(Index: String): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := inherited GetPropValue(Index);
  if Result <> Null then Exit;
  if Index = 'ALIGNMENT' then
    Result := FRadioButton.Alignment
  else if Index = 'CHECKED' then
    Result := FRadioButton.Checked
  else if Index = 'CAPTION' then
    Result := FRadioButton.Caption
end;

procedure TfrRadioButtonControl.LoadFromStream(Stream: TStream);
begin
  inherited LoadFromStream(Stream);
  FRadioButton.Alignment := TAlignment(frReadByte(Stream));
  FRadioButton.Checked := frReadBoolean(Stream);
  FRadioButton.Caption := frReadString(Stream);
end;

procedure TfrRadioButtonControl.SaveToStream(Stream: TStream);
begin
  inherited SaveToStream(Stream);
  frWriteByte(Stream, Byte(FRadioButton.Alignment));
  frWriteBoolean(Stream, FRadioButton.Checked);
  frWriteString(Stream, FRadioButton.Caption);
end;

procedure TfrRadioButtonControl.SaveToFR3Stream(Stream: TStream);

  procedure WriteStr(const s: String);
  begin
    Stream.Write(s[1], Length(s));
  end;

begin
  inherited;

  WriteStr(' Caption="' + StrToXML(FRadioButton.Caption) +
    '" Alignment="' + IntToStr(Integer(FRadioButton.Alignment)) +
    '" Checked="' + IntToStr(Integer(FRadioButton.Checked)) + '"');
end;


{ TfrListBoxControl }

constructor TfrListBoxControl.Create;
begin
  inherited Create;
  FListBox := TListBox.Create(nil);
  FListBox.Parent := frDialogForm;
  AssignControl(FListBox);
  BaseName := 'ListBox';
  dx := 121; dy := 97;
end;

destructor TfrListBoxControl.Destroy;
begin
  FListBox.Free;
  inherited Destroy;
end;

procedure TfrListBoxControl.DefineProperties;
begin
  inherited DefineProperties;
  AddProperty('Items', [frdtHasEditor, frdtOneObject], LinesEditor);
  AddProperty('ItemIndex', [], nil);
  AddProperty('Items.Count', [], nil);
end;

procedure TfrListBoxControl.SetPropValue(Index: String; Value: Variant);
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
  if Index = 'ITEMINDEX' then
    FListBox.ItemIndex := Value
end;

function TfrListBoxControl.GetPropValue(Index: String): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := inherited GetPropValue(Index);
  if Result <> Null then Exit;
  if Index = 'ITEMINDEX' then
    Result := FListBox.ItemIndex
  else if Index = 'ITEMS.COUNT' then
    Result := FListBox.Items.Count
end;

function TfrListBoxControl.DoMethod(MethodName: String; Par1, Par2, Par3: Variant): Variant;
begin
  Result := inherited DoMethod(MethodName, Par1, Par2, Par3);
  if Result = Null then
    Result := LinesMethod(FListBox.Items, MethodName, 'ITEMS', Par1, Par2, Par3);
end;

procedure TfrListBoxControl.LoadFromStream(Stream: TStream);
begin
  inherited LoadFromStream(Stream);
  frReadMemo(Stream, FListBox.Items);
end;

procedure TfrListBoxControl.SaveToStream(Stream: TStream);
begin
  inherited SaveToStream(Stream);
  frWriteMemo(Stream, FListBox.Items);
end;

procedure TfrListBoxControl.LinesEditor(Sender: TObject);
begin
  with TfrLinesEditorForm.Create(nil) do
  begin
    M1.Lines := FListBox.Items;
    if (ShowModal = mrOk) and ((Restrictions and frrfDontModify) = 0) then
    begin
      frDesigner.BeforeChange;
      FListBox.Items := M1.Lines;
      frDesigner.AfterChange;
    end;
    Free;
  end;
end;

procedure TfrListBoxControl.SaveToFR3Stream(Stream: TStream);

  procedure WriteStr(const s: String);
  begin
    Stream.Write(s[1], Length(s));
  end;

begin
  inherited;

  WriteStr(' Items.Text="' + StrToXML(FListBox.Items.Text) + '"');
end;


{ TfrComboBoxControl }

constructor TfrComboBoxControl.Create;
begin
  inherited Create;
  FComboBox := TComboBox.Create(nil);
  FComboBox.Parent := frDialogForm;
  FComboBox.OnDrawItem := ComboBoxDrawItem;
  FComboBox.OnKeyDown := OnKeyDown;
  AssignControl(FComboBox);
  BaseName := 'ComboBox';
  dx := 145; dy := 21;

  frConsts['csDropDown'] := csDropDown;
  frConsts['csDropDownList'] := csDropDownList;
  frConsts['csLookup'] := csLookup;
end;

destructor TfrComboBoxControl.Destroy;
begin
  FComboBox.Free;
  inherited Destroy;
end;

procedure TfrComboBoxControl.OnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if FComboBox.Style = csDropDownList then
    if (Key = VK_DELETE) or (Key = VK_BACK) then FComboBox.ItemIndex := -1
end;

procedure TfrComboBoxControl.DefineProperties;
begin
  inherited DefineProperties;
  AddProperty('Items', [frdtHasEditor, frdtOneObject], LinesEditor);
  AddProperty('ItemIndex', [], nil);
  AddProperty('Items.Count', [], nil);
  AddEnumProperty('Style',
    'csDropDown;csDropDownList;csLookup', [csDropDown,csDropDownList,csLookup]);
  AddProperty('Text', [], nil);
end;

procedure TfrComboBoxControl.SetPropValue(Index: String; Value: Variant);
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
  if Index = 'ITEMINDEX' then
    FComboBox.ItemIndex := Value
  else if Index = 'STYLE' then
    FComboBox.Style := Value
end;

function TfrComboBoxControl.GetPropValue(Index: String): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := inherited GetPropValue(Index);
  if Result <> Null then Exit;
  if Index = 'ITEMINDEX' then
    Result := FComboBox.ItemIndex
  else if Index = 'STYLE' then
    Result := FComboBox.Style
  else if Index = 'TEXT' then
  begin
    Result := FComboBox.Text;
    if (FComboBox.Style = csOwnerDrawFixed) and (Pos(';', Result) <> 0) then
      Result := Trim(Copy(Result, Pos(';', Result) + 1, 255));
  end
  else if Index = 'ITEMS.COUNT' then
    Result := FComboBox.Items.Count
end;

function TfrComboBoxControl.DoMethod(MethodName: String; Par1, Par2, Par3: Variant): Variant;
begin
  Result := inherited DoMethod(MethodName, Par1, Par2, Par3);
  if Result = Null then
    Result := LinesMethod(FComboBox.Items, MethodName, 'ITEMS', Par1, Par2, Par3);
end;

procedure TfrComboBoxControl.LoadFromStream(Stream: TStream);
var
  b: Byte;
begin
  inherited LoadFromStream(Stream);
  frReadMemo(Stream, FComboBox.Items);
  if HVersion * 10 + LVersion > 10 then
  begin
    b := frReadByte(Stream);
    if (HVersion * 10 + LVersion <= 20) and (b > 0) then
      Inc(b);
    Prop['Style'] := b;
  end;
end;

procedure TfrComboBoxControl.SaveToStream(Stream: TStream);
begin
  LVersion := 1;
  inherited SaveToStream(Stream);
  frWriteMemo(Stream, FComboBox.Items);
  frWriteByte(Stream, Prop['Style']);
end;

procedure TfrComboBoxControl.ComboBoxDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  ComboBox: TComboBox;
  s: String;
begin
  ComboBox := Control as TComboBox;
  with ComboBox.Canvas do
  begin
    FillRect(Rect);
    s := ComboBox.Items[Index];
    if Pos(';', s) <> 0 then
      s := Copy(s, 1, Pos(';', s) - 1);
    TextOut(Rect.Left + 2, Rect.Top + 1, s);
  end;
end;

procedure TfrComboBoxControl.LinesEditor(Sender: TObject);
begin
  with TfrLinesEditorForm.Create(nil) do
  begin
    M1.Lines := FComboBox.Items;
    if (ShowModal = mrOk) and ((Restrictions and frrfDontModify) = 0) then
    begin
      frDesigner.BeforeChange;
      FComboBox.Items := M1.Lines;
      frDesigner.AfterChange;
    end;
    Free;
  end;
end;

procedure TfrComboBoxControl.SaveToFR3Stream(Stream: TStream);

  procedure WriteStr(const s: String);
  begin
    Stream.Write(s[1], Length(s));
  end;

begin
  inherited;

  WriteStr(' Items.Text="' + StrToXML(FComboBox.Items.Text) +
    '" Style="' + IntToStr(Integer(FComboBox.Style)) + '"');
end;


{$IFDEF DateEdit}

{ TfrDateEditControl }

constructor TfrDateEditControl.Create;
begin
  inherited Create;
{$IFDEF RX}
  FDateEdit := TDateEdit.Create(nil);
  FDateEdit.Parent := frDialogForm;
  FDateEdit.ButtonWidth := 19;
  AssignControl(FDateEdit);
  FDateEdit.OnButtonClick := OnClick;
  BaseName := 'DateEdit';
  dx := 145; dy := 21;

  frConsts['swMon'] := Mon;
  frConsts['swSun'] := Sun;
  frConsts['dyDefault'] := dyDefault;
  frConsts['dyFour'] := dyFour;
  frConsts['dyTwo'] := dyTwo;
{$ELSE}
  FDateEdit := TDateTimePicker.Create(nil);
  FDateEdit.Parent := frDialogForm;
  AssignControl(FDateEdit);
  BaseName := 'DateEdit';
  dx := 145; dy := 21;
  frConsts['dfShort'] := dfShort;
  frConsts['dfLong'] := dfLong;
{$ENDIF}
end;

destructor TfrDateEditControl.Destroy;
begin
  FDateEdit.Free;
  inherited Destroy;
end;

procedure TfrDateEditControl.DefineProperties;
begin
  inherited DefineProperties;
  AddProperty('Date', [], nil);
{$IFDEF RX}
  AddEnumProperty('ClickKey', frGetShortCuts, [Null]);
  AddEnumProperty('StartOfWeek', 'swMon;swSun', [Mon,Sun]);
  AddEnumProperty('YearDigits', 'dyDefault;dyFour;dyTwo', [dyDefault,dyFour,dyTwo]);
  AddProperty('Text', [], nil);
{$ELSE}
  AddEnumProperty('DateFormat', 'dfShort;dfLong', [dfShort,dfLong]);
{$ENDIF}
end;

procedure TfrDateEditControl.SetPropValue(Index: String; Value: Variant);
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
{$IFDEF RX}
  if Index = 'CLICKKEY' then
    FDateEdit.ClickKey := TextToShortCut(Value)
  else if Index = 'DATE' then
    FDateEdit.Date := Value
  else if Index = 'STARTOFWEEK' then
    FDateEdit.StartOfWeek := Value
  else if Index = 'TEXT' then
    FDateEdit.Text := Value
  else if Index = 'YEARDIGITS' then
    FDateEdit.YearDigits := Value
{$ELSE}
  if Index = 'DATE' then
    FDateEdit.Date := Value
  else if Index = 'DATEFORMAT' then
    FDateEdit.DateFormat := Value;
{$ENDIF}
end;

function TfrDateEditControl.GetPropValue(Index: String): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := inherited GetPropValue(Index);
  if Result <> Null then Exit;
{$IFDEF RX}
  if Index = 'CLICKKEY' then
    Result := ShortCutToText(FDateEdit.ClickKey)
  else if Index = 'DATE' then
    Result := FDateEdit.Date
  else if Index = 'TEXT' then
    Result := FDateEdit.Text
  else if Index = 'STARTOFWEEK' then
    Result := FDateEdit.StartOfWeek
  else if Index = 'YEARDIGITS' then
    Result := FDateEdit.YearDigits
{$ELSE}
  if Index = 'DATE' then
    Result := StrToDate(DateToStr(FDateEdit.Date))
  else if Index = 'DATEFORMAT' then
    Result := FDateEdit.DateFormat;
{$ENDIF}
end;

procedure TfrDateEditControl.LoadFromStream(Stream: TStream);
begin
  inherited LoadFromStream(Stream);
{$IFDEF RX}
  Prop['StartOfWeek'] := frReadByte(Stream);
  Prop['YearDigits'] := frReadByte(Stream);
  if HVersion * 10 + LVersion > 10 then
    FDateEdit.ClickKey := frReadByte(Stream);
{$ELSE}
  Prop['DateFormat'] := frReadByte(Stream);
{$ENDIF}
end;

procedure TfrDateEditControl.SaveToStream(Stream: TStream);
begin
  inherited SaveToStream(Stream);
{$IFDEF RX}
  frWriteByte(Stream, Prop['StartOfWeek']);
  frWriteByte(Stream, Prop['YearDigits']);
  frWriteByte(Stream, FDateEdit.ClickKey);
{$ELSE}
  frWriteByte(Stream, Prop['DateFormat']);
{$ENDIF}
end;
{$IFNDEF RX}
procedure TfrDateEditControl.SaveToFR3Stream(Stream: TStream);

  procedure WriteStr(const s: String);
  begin
    Stream.Write(s[1], Length(s));
  end;

begin
  inherited;

  WriteStr(' DateFormat="' + IntToStr(Integer(FDateEdit.DateFormat)) + '"');
end;
{$ENDIF}
{$ENDIF}


var
  Bmp: Array[0..8] of TBitmap;

initialization
  Bmp[0] := TBitmap.Create;
  Bmp[0].LoadFromResourceName(hInstance, 'FR_LABELCONTROL');
  frRegisterControl(TfrLabelControl, Bmp[0], IntToStr(SInsertLabel));
  Bmp[1] := TBitmap.Create;
  Bmp[1].LoadFromResourceName(hInstance, 'FR_EDITCONTROL');
  frRegisterControl(TfrEditControl, Bmp[1], IntToStr(SInsertEdit));
  Bmp[2] := TBitmap.Create;
  Bmp[2].LoadFromResourceName(hInstance, 'FR_MEMOCONTROL');
  frRegisterControl(TfrMemoControl, Bmp[2], IntToStr(SInsertMemo));
  Bmp[3] := TBitmap.Create;
  Bmp[3].LoadFromResourceName(hInstance, 'FR_BUTTONCONTROL');
  frRegisterControl(TfrButtonControl, Bmp[3], IntToStr(SInsertButton));
  Bmp[4] := TBitmap.Create;
  Bmp[4].LoadFromResourceName(hInstance, 'FR_CHECKBOXCONTROL');
  frRegisterControl(TfrCheckBoxControl, Bmp[4], IntToStr(SInsertCheckBox));
  Bmp[5] := TBitmap.Create;
  Bmp[5].LoadFromResourceName(hInstance, 'FR_RADIOBUTTONCONTROL');
  frRegisterControl(TfrRadioButtonControl, Bmp[5], IntToStr(SInsertRadioButton));
  Bmp[6] := TBitmap.Create;
  Bmp[6].LoadFromResourceName(hInstance, 'FR_LISTBOXCONTROL');
  frRegisterControl(TfrListBoxControl, Bmp[6], IntToStr(SInsertListBox));
  Bmp[7] := TBitmap.Create;
  Bmp[7].LoadFromResourceName(hInstance, 'FR_COMBOBOXCONTROL');
  frRegisterControl(TfrComboBoxControl, Bmp[7], IntToStr(SInsertComboBox));
{$IFDEF DateEdit}
  Bmp[8] := TBitmap.Create;
  Bmp[8].LoadFromResourceName(hInstance, 'FR_DATEEDITCONTROL');
  frRegisterControl(TfrDateEditControl, Bmp[8], IntToStr(SInsertDateEdit));
{$ENDIF}

finalization
  Bmp[0].Free; Bmp[1].Free;
  Bmp[2].Free; Bmp[3].Free;
  Bmp[4].Free; Bmp[5].Free;
  Bmp[6].Free; Bmp[7].Free;
{$IFDEF DateEdit}
  Bmp[8].Free;
{$ENDIF}

end.

