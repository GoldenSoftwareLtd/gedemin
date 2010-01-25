{++

  Components 
  Copyright c) 1996 - 98 by Golden Software

  Module

    xRTFView.pas

  Abstract

    Component to show and print RTF file.

  Author

    Vladimir Belyi (April, 1997)

  Contact address

    andreik@gs.minsk.by

  Uses

    Units:

      xRTF - classes to hold RTF files in memory

    Forms:

      xRTFDatF
      xRTFFFF - RTF FormField edit Form

    Other files:

  Revisions history

    1.00   5-apr-1997  belyi   Initial version.
    1.01   7-apr-1997  belyi   ExchangeData procedure.
    1.02  14-nov-1997  belyi   Bug with second assignment
    1.03  11-mar-1998  belyi   Bug with NT redrawing seems to vanish.

    2.00  10-jul-1998  vbelyi  32 bit works 

  Known bugs

    -

  Wishes

    -

  Notes/comments

    -

--}

unit xRTFView;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, DsgnIntF, StdCtrls, Menus,
  xBasics, xRTF, xRTFSubs;

type
  TStoreOption = (soFileData, soFileReference);

  TxOffset = (xoVert, xoHorz);
  TxOffsets = set of TxOffset;

  TxRTFViewer = class(TCustomControl)
  private
    { Private declarations }
    HaveScrollers: Boolean;
    CursorPos: LongInt;
    SuppressDrawingDepth: Integer;
    FStoreOption: TStoreOption;
    FDataFileName: string;
    FPreviewOptions: TxRTFPreviewOptions;
    FHShift: LongInt;
    FAutoLoadAtDesign: Boolean;
    FileIsLoaded: Boolean;
    FStoreShifts: Boolean;
    function RunDraw(Opt: TDrawOptions): TDrawresult;
    procedure SetDataFileName(Value: string);
    procedure SetPreviewOptions(Value: TxRTFPreviewOptions);
    procedure SetHShift(Value: LongInt);
    procedure SetVShift(Value: LongInt);
    function GetFormFields: TList;
    procedure SetFormFields(Value: TList);
    procedure SetAutoLoadAtDesign(Value: Boolean);
    procedure SetStoreOption(Value: TStoreOption);
    procedure SetRTFData(Value: TxRTFFile);
    function GetScale: Double;
    procedure SetScale(Value: Double);
  protected
    { Protected declarations }
    procedure Paint; override;
    procedure KeyPress(var Key: Char); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure RefreshRTF; { appends RTF connection }
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DefineProperties(Filer: TFiler); override;
    procedure ReadRTFData(Reader: TReader);
    procedure WriteRTFData(Writer: TWriter);
    procedure SetDefaultOffsets(Value: TxOffsets);
    procedure SetScrollers;
    {procedure Loaded; override;}
    procedure WMSize(var Message: TWMSize);
      message WM_SIZE;
    procedure WMGetDlgCode(var Message: TMessage);
      message WM_GETDLGCODE;
    procedure WMRedrawImage(var Message: TMessage);
      message WM_REDRAWIMAGE;
    procedure WMSysCommand(var Message: TWMSysCommand);
      message WM_SYSCOMMAND;
    procedure WMVScroll(var Message: TWMVScroll);
      message WM_VSCROLL;
    procedure WMHScroll(var Message: TWMHScroll);
      message WM_HSCROLL;
    procedure WMMouseActivate(var Message: TMessage);
      message WM_MOUSEACTIVATE;
    procedure WMActivate(var Message: TWMActivate);
      message WM_ACTIVATE;
  public
    { Public declarations }
    FVShift: LongInt;
    RTFFile: TxRTFFile;
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
    procedure GoPageDown;
    procedure GoPageUp;
    procedure Asg(Cnv: TCanvas);
    procedure PaintCnv(Hn: THandle);
    function LoadRTF(FileName: string): Boolean;
    function SaveRTF(FileName: string): Boolean;
    procedure RedrawImage;
    procedure SuppressDrawing;
    procedure UnsuppressDrawing;
    procedure Clear;
    procedure PrintFile;
    procedure PaintHnd;
    procedure ExchangeData(var AData: TxRTFFile); { exchanges the current
      data with the one given by AData. Be sure to manually delete the data
      which will be returned by this procedure! }
  published
    { Published declarations }
    property Align;
    property TabStop;
    property TabOrder;
    property PreviewOptions: TxRTFPreviewOptions read FPreviewOptions
      write SetPreviewOptions;

    { next four properies should be in the order they are here }
    property AutoLoadAtDesign: Boolean read FAutoLoadAtDesign
      write SetAutoLoadAtDesign;
    property StoreOption: TStoreOption read FStoreOption
      write SetStoreOption;
    property DataFileName: string read FDataFileName write SetDataFileName;
    property Data: TxRTFFile read RTFFile write SetRTFData stored false;

    property StoreShifts: Boolean read FStoreShifts write FStoreShifts;
    property HShift: LongInt read FHShift write SetHShift
      stored FStoreShifts;
    property VShift: LongInt read FVShift write SetVShift
      stored FStoreShifts;
    property FormFields: TList read GetFormFields write SetFormFields
      stored false;
    property Scale: Double read GetScale write SetScale;
    property PopupMenu;
  end;

  TxRTFScaleCombo = class(TCustomComboBox)
  private
    FRTFViewer: TxRTFViewer;
  protected
    procedure Click; override;
    procedure Loaded; override;
    procedure KeyDown(var Key: word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(AnOwner: TComponent); override;
  published
    property RTFViewer: TxRTFViewer read FRTFViewer write FRTFViewer;
  end;

procedure Register;

implementation

uses
  xRTFDatF, xRTFFFF;

{ ================ TxRTFViewer ========================= }

constructor TxRTFViewer.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  ControlStyle := [csClickEvents, csOpaque];

  Width := DefWidth;
  Height := DefHeight;
  CursorPos := 0;
  FVShift := 0;
  FHShift := 0;

  RTFFile := TxRTFFile.Create;
  FPreviewOptions := RTFFile.Options;

  TabStop := true;
  SuppressDrawingDepth := 0;

  FStoreOption := soFileReference;
  FDataFileName := '';
  FileIsLoaded := false;
  FAutoLoadAtDesign := false;

  FStoreShifts := false;
end;

destructor TxRTFViewer.Destroy;
begin
  RTFFile.Free;
  inherited Destroy;
end;

procedure TxRTFViewer.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or WS_HSCROLL or WS_VSCROLL;
end;

procedure TxRTFViewer.PaintHnd;
begin
  Paint;
end;

procedure TxRTFViewer.SetScrollers;
begin
  if FileIsLoaded then
   begin
     SetScrollRange(Handle, SB_VERT, 0, RTFFile.LinesCount - 1, False);
     SetScrollRange(Handle, SB_HORZ, 0,
       MaxInt(RTFFile.ScaleMe(RTFFile.PageFullWidth) - ClientWidth, 0), False);
   end
  else
   begin
     SetScrollRange(Handle, SB_VERT, 0, 0, False);
     SetScrollRange(Handle, SB_HORZ, 0, 0, False);
   end;
end;

procedure TxRTFViewer.SetDefaultOffsets(Value: TxOffsets);
begin
  SetScrollers;
  if xoVert in Value then
   begin
     FVShift := 0;
     SetScrollPos(Handle, SB_VERT, FVShift, True);
   end;
  if xoHorz in Value then
   begin
     if FileIsLoaded then
      begin
        FHShift := MaxInt(RTFFile.ScaleMe(RTFFile.PageFullWidth) - ClientWidth, 0) div 2;
        FHShift := MinInt(RTFFile.LeftMargin, FHShift);
        FHShift := MaxInt(FHShift, 0);
      end
     else
       FHShift := 0;
     SetScrollPos(Handle, SB_HORZ, FHShift, True);
   end;
end;

procedure TxRTFViewer.Asg(Cnv: TCanvas);
begin
  Canvas.Handle := Cnv.Handle;
end;

function TxRTFViewer.LoadRTF(FileName: string): Boolean;
begin
  FDataFileName := '';
  SuppressDrawing;
  try
    RTFFile.Clear;
    FileIsLoaded := RTFFile.LoadRTF(FileName);
    FDataFileName := FileName;
    RefreshRTF;
    HaveScrollers := false;
    {SetDefaultOffsets([xoVert, xoHorz]);}
  finally
    UnsuppressDrawing;
  end;

  Result := FileIsLoaded;
end;

function TxRTFViewer.SaveRTF(FileName: string): Boolean;
begin
  Result := RTFFile.SaveRTF(FileName);
end;

procedure TxRTFViewer.SetRTFData(Value: TxRTFFile);
begin
  RTFFile.Clear;
  FDataFileName := '';
  if Value <> nil then
   begin
     RTFFile.Assign(Value);
     FileIsLoaded := true;
     RefreshRTF;
     RTFFile.RefreshMargins;
     SetDefaultOffsets([xoHorz, xoVert]);
   end;
  invalidate;
end;

procedure TxRTFViewer.SetDataFileName(Value: string);
begin
  if Value = '' then
   begin
     FDataFileName := '';
     if soFileReference = FStoreOption then Clear;
     exit;
   end;

  if ( (FStoreOption = soFileReference) and
       (FAutoLoadAtDesign or not(csDesigning in ComponentState)) )
    or
     ( (FStoreOption = soFileData) and
       not(csLoading in ComponentState) )
  then
   begin
     if Value <> FDataFileName then
       LoadRTF(Value);
   end
  else
   begin
     Clear;
     FDataFileName := Value;
{     RTFFile.AddParagraph('File is not really loaded at Design.');
     RTFFile.AddParagraph('Use AutoLoadAtDesign property if you want ' +
       'your file to be loaded every time you open this form.');}
     RefreshRTF;
     RTFFile.CheckIsBuilt;
     SetDefaultOffsets([xoVert, xoHorz]);
   end;
end;

procedure TxRTFViewer.SetAutoLoadAtDesign(Value: Boolean);
begin
  if Value <> FAutoLoadAtDesign then
   begin
     FAutoLoadAtDesign := Value;
     if Value and not(FileIsLoaded) and (FDataFileName <> '') then
       LoadRTF(FDataFileName);
   end;
end;

procedure TxRTFViewer.RefreshRTF;
begin
  RTFFile.RegisterCanvas(Canvas);
end;

function TxRTFViewer.RunDraw(Opt: TDrawOptions): TDrawresult;
begin
  RefreshRTF;
  if not HaveScrollers then
   begin
     SetDefaultOffsets([xoVert, xoHorz]);
     HaveScrollers := true;
   end;

  SetRect(Opt.DrawRect, 0, 0, ClientWidth, ClientHeight);
  Opt.HShift :=
    FHShift + MinInt(RTFFile.ScaleMe(RTFFile.PageFullWidth) - ClientWidth, 0) div 2;
  Result := RTFFile.DrawRTF(Opt, false);
end;

procedure TxRTFViewer.GoPageDown;
var
  H: LongInt;
  Line: LongInt;
begin
  if FVShift >= RTFFile.LinesCount then exit;

  Line := FVShift + 1;
  H := RTFFile.LineHeight(FVShift);

  while (Line < RTFFile.LinesCount) and (H <= ClientHeight) do
   begin
     H := H + RTFFile.LineHeight(Line);
     inc(Line);
   end;
  dec(Line, 2);
  if Line <= FVShift then Line := FVShift + 1;

  VShift := Line;
end;

procedure TxRTFViewer.GoPageUp;
var
  H: LongInt;
  Line: LongInt;
begin
  if FVShift <= 0 then exit;

  Line := FVShift - 1;
  H := 0;

  while (Line >= 0) and (H <= ClientHeight) do
   begin
     H := H + RTFFile.LineHeight(Line);
     dec(Line);
   end;

  if Line >=0 then
    inc(Line, 2)
  else
    Line := 0;
  if Line >= FVShift then Line := FVShift - 1;

  VShift := Line;
end;

procedure TxRTFViewer.KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    40{down}: VShift := VShift + 1;
    38{up}: VShift := VShift - 1;
    36{home}: VShift := 0;
    33{PageUp}: GoPageUp;
    34{PageDown}: GoPageDown;
    35{End}: VShift := RTFFile.LinesCount;
    37{left}: HShift := HShift - ClientWidth div 10;
    39{right}: HShift := HShift + ClientWidth div 10;
    else
      inherited KeyDown(Key, Shift);
  end;
end;

procedure TxRTFViewer.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
end;

procedure TxRTFViewer.PaintCnv(Hn: THandle);
begin
  RTFFile.RegisterCanvasHandle(Hn);
  Paint;
end;

procedure TxRTFViewer.RedrawImage;
var
  Opt: TDrawOptions;
begin
  if RTFFile.ProhibitDrawing then exit;
  if (SuppressDrawingDepth = 0) then
   begin
     Opt.From := FVShift;
     Opt.Cmd := dcDrawWhole;
     RunDraw(Opt);
   end;
end;

procedure TxRTFViewer.Paint;
const
  Inside: Boolean = false;
begin
  if Inside then exit;

  Inside := true;
  try
    inherited Paint;
    RedrawImage;
  finally
    Inside := false;
  end;
end;

procedure TxRTFViewer.WMSize(var Message: TWMSize);
begin
  inherited;
  if not(csLoading in ComponentState) then
   begin
     if Width > RTFFile.ScaleMe(RTFFile.PageFullWidth) then
       SetDefaultOffsets([xoHorz])
     else
      begin
        SetScrollers;
        HShift := FHShift;
      end;
     { to update some inner variables }
     VShift := FVShift;
   end;
end;

procedure TxRTFViewer.WMGetDlgCode(var Message: TMessage);
begin
  Message.Result := DLGC_WANTARROWS;
end;

procedure TxRTFViewer.WMRedrawImage(var Message: TMessage);
begin
  RedrawImage;
end;

procedure TxRTFViewer.SuppressDrawing;
begin
  inc(SuppressDrawingDepth);
end;

procedure TxRTFViewer.UnsuppressDrawing;
begin
  dec(SuppressDrawingDepth);
  if SuppressDrawingDepth = 0 then
    Invalidate;
end;

procedure TxRTFViewer.WMSysCommand(var Message: TWMSysCommand);
begin
  inherited;
end;

procedure TxRTFViewer.WMVScroll(var Message: TWMVScroll);
begin
  inherited;
  case Message.ScrollCode of
    SB_LINEDOWN: VShift := FVShift + 1;
    SB_LINEUP: VShift := FVShift - 1;
    SB_PAGEDOWN: GoPageDown;
    SB_PAGEUP: GoPageUp;
    SB_THUMBPOSITION: VShift := Message.Pos;
  end;
end;

procedure TxRTFViewer.WMHScroll(var Message: TWMHScroll);
begin
  inherited;
  case Message.ScrollCode of
    SB_LINEDOWN: HShift := FHShift + ClientWidth div 30;
    SB_LINEUP: HShift := FHShift - ClientWidth div 30;
    SB_PAGEDOWN: HShift := FHShift + ClientWidth * 20 div 30;
    SB_PAGEUP: HShift := FHShift - ClientWidth * 20 div 30;
    SB_THUMBPOSITION: HShift := Message.Pos;
  end;
end;

procedure TxRTFViewer.SetVShift(Value: LongInt);
begin
  if csLoading in ComponentState then
   begin
     FVShift := Value;
     exit;
   end;
  Value := MinInt(Value, RTFFile.LinesCount - 1);
  Value := MaxInt(0, Value);
  if Value <> FVShift then
   begin
     FVShift := Value;
     SetScrollPos(Handle, SB_VERT, FVShift, True);
     invalidate;
   end;
end;

procedure TxRTFViewer.SetHShift(Value: LongInt);
var
  ExtraWidth: LongInt;
begin
  if {csLoading in ComponentState} not FileIsLoaded then
   begin
     FHShift := Value;
     exit;
   end;
  ExtraWidth := MaxInt(RTFFile.ScaleMe(RTFFile.PageFullWidth) - ClientWidth, 0);
  Value := MinInt(Value, ExtraWidth);
  Value := MaxInt(0, Value);
  if Value <> FHShift then
   begin
     FHShift := Value;
     SetScrollPos(Handle, SB_HORZ, FHShift, True);
     invalidate;
   end;
end;

procedure TxRTFViewer.WMMouseActivate(var Message: TMessage);
begin
  inherited;
  if not(csDesigning in ComponentState) then
   begin
     Message.Result := MA_ACTIVATE;
     SetFocus;
   end;
end;

procedure TxRTFViewer.Clear;
begin
  RTFFile.Clear;
  FileIsLoaded := false;
  FDataFileName := '';
  SetDefaultOffsets([xoVert, xoHorz]);
  Invalidate;
end;

procedure TxRTFViewer.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineProperty('RTFData', ReadRTFData, WriteRTFData, true);
end;

procedure TxRTFViewer.ReadRTFData(Reader: TReader);
var
  Ver: Integer;
begin
  Reader.ReadListBegin;
  if FStoreOption = soFileData then
   begin
     Ver := Reader.ReadInteger;
     if not(ver in SupportedVersions) then
       raise ExRTF.Create('Can not load data file from the stream - ' +
        'wrong data version!');
     Clear;
     RTFFile.ReadData(Reader);
   end;
  Reader.ReadListEnd;
end;

procedure TxRTFViewer.WriteRTFData(Writer: TWriter);
begin
  Writer.WriteListBegin; { leave this outside if structure -
                           this stabilizes Delphi }
  if FStoreOption = soFileData then
   begin
     Writer.WriteInteger(DataFileVersion);
     RTFFile.WriteData(Writer);
   end;
  Writer.WriteListEnd;
end;

procedure TxRTFViewer.SetPreviewOptions(Value: TxRTFPreviewOptions);
begin
  if FPreviewOptions <> Value then
   begin
     FPreviewOptions := Value;
     RTFFile.Options := Value;
     SetDefaultOffsets([xoHorz]);
     { to update some inner variables }
     VShift := FVShift;
     invalidate;
   end;
end;

procedure TxRTFViewer.WMActivate(var Message: TWMActivate);
begin
  inherited;
end;

function TxRTFViewer.GetFormFields: TList;
begin
  Result := RTFFile.FormFields;
end;

procedure TxRTFViewer.SetFormFields(Value: TList);
begin
 { ignore - can not assign  }
end;

procedure TxRTFViewer.SetStoreOption(Value: TStoreOption);
begin
  {$IFDEF BETA}
  if (csDesigning in ComponentState) and
     not(csLoading in ComponentState) and
     (Value = soFileData)
  then
   begin
     if MessageDlg('This is a beta version of TxRTFViewer. ' +
       'Thus, soFileData option may not work properly as well as ' +
       'the file format created by it might not be supported by ' +
       'future versions of the component. Continue?',
       mtConfirmation, [mbYes, mbNo], 0) = mrYes
     then
       FStoreoption := Value;
   end
  else
    FStoreoption := Value;

  {$ELSE}
  FStoreOption := Value;
  {$ENDIF}
end;

procedure TxRTFViewer.PrintFile;
begin
  Data.PrintRTF2;
  invalidate;
end;

procedure TxRTFViewer.ExchangeData(var AData: TxRTFFile);
var
  SwapRTF: TxRTFFile;
begin
  SwapRTF := RTFFile;
  RTFFile := AData;
  AData := SwapRTF;

  FileIsLoaded := true;
  RTFFile.Options := FPreviewOptions;
  FDataFileName := '';
  FVShift := 0;
  FHShift := 0;

  {RefreshRTF;}
  RTFFile.RegisterCanvasHandle(AData.CanvasHandle);
  {SetDefaultOffsets([xoVert, xoHorz]);}
  invalidate;
  HaveScrollers := false;
end;

function TxRTFViewer.GetScale: Double;
begin
  Result := RTFFile.Scale;
end;

procedure TxRTFViewer.SetScale(Value: Double);
begin
  RTFFile.Scale := Value;
{  RefreshRTF;
  RTFFile.ViewChanged;}
//  RTFFile.ProceedHandleChange;
  Repaint;

  if not(csLoading in ComponentState) then
   begin
     if Width > RTFFile.ScaleMe(RTFFile.PageFullWidth) then
       SetDefaultOffsets([xoHorz])
     else
      begin
        SetScrollers;
        HShift := FHShift;
      end;
     { to update some inner variables }
     VShift := FVShift;
   end;
end;

{ =========== TxRTFScaleCombo ========= }

constructor TxRTFScaleCombo.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FRTFViewer := nil;
  Text := '100%';
end;

procedure TxRTFScaleCombo.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or ES_MULTILINE or WS_CLIPCHILDREN;
end;

procedure TxRTFScaleCombo.Loaded;
begin
  Items.Clear;
  Items.Add('10%');
  Items.Add('25%');
  Items.Add('50%');
  Items.Add('75%');
  Items.Add('100%');
  Items.Add('150%');
  Items.Add('200%');
  Items.Add('500%');
  Text := '100%';
  inherited Loaded;
end;

procedure TxRTFScaleCombo.Click;
var
  Value: Double;
begin
  try
    Value := xStrToFloat(Text);
  except
    Value := 100;
  end;

  if Assigned(FRTFViewer) and (Value > 0) then
    FRTFViewer.Scale := Value / 100;

  Text := FloatToStr(Value) + '%';

  inherited Click;
end;

procedure TxRTFScaleCombo.KeyDown(var Key: word; Shift: TShiftState);
begin
  if Key = 13 then
   begin
     Click;
     Key := 0;
   end
  else
   inherited KeyDown(Key, Shift);
end;

procedure TxRTFScaleCombo.KeyPress(var Key: Char);
begin
  if Key = #13 then
    Abort; { Delphi сволочь - не вызывает WM_KEYDOWN и пищит }
  inherited KeyPress(Key);
end;


{ ======== TxDataFileProperty ========= }

type
  TxDataFileProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
  end;

function TxDataFileProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paMultiSelect];
end;

procedure TxDataFileProperty.Edit;
var
  Comp: TxRTFViewer;
  i: Integer;
begin
  Application.CreateForm(TxRTFDataForm, xRTFDataForm);
  try
    Comp := GetComponent(0) as TxRTFViewer;
    xRTFDataForm.MainViewer := Comp;
    xRTFDataForm.OpenDialog.FileName := Comp.DataFileName;
    if xRTFDataForm.OpenDialog.Execute then
     begin
       for i := 0 to PropCount - 1 do
         (GetComponent(i) as TxRTFViewer).DataFileName :=
           xRTFDataForm.OpenDialog.FileName;
       Modified;
     end;
  finally
    xRTFDataForm.Free;
  end;
end;

{ ======== TxRTFFileProperty ========= }

type
  TxRTFFileProperty = class(TxDataFileProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: string; override;
    procedure Edit; override;
  end;

function TxRTFFileProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paMultiSelect, paReadOnly];
end;

function TxRTFFileProperty.GetValue: string;
begin
  Result := 'TxRTFFile';
end;

procedure TxRTFFileProperty.Edit;
var
  Comp: TxRTFViewer;
  i: Integer;
begin
  Application.CreateForm(TxRTFDataForm, xRTFDataForm);
  try
    Comp := GetComponent(0) as TxRTFViewer;
    xRTFDataForm.MainViewer := Comp;
    xRTFDataForm.RTFViewer.DataFileName := Comp.DataFileName;
    if xRTFDataForm.ShowModal = mrOk then
     begin
       for i := 0 to PropCount - 1 do
        begin
          (GetComponent(i) as TxRTFViewer).Data :=
            xRTFDataForm.RTFViewer.Data;
          (GetComponent(i) as TxRTFViewer).DataFileName :=
            xRTFDataForm.RTFViewer.DataFileName;
        end;
       Modified;
     end;
  finally
    xRTFDataForm.Free;
  end;
end;

{ ======== TFormFieldsProperty ========= }

type
  TFormFieldsProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
    function GetValue: string; override;
  end;

function TFormFieldsProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paReadOnly];
end;

procedure TFormFieldsProperty.Edit;
var
  Comp: TxRTFViewer;
  i: Integer;
begin
  Comp := GetComponent(0) as TxRTFViewer;

  { Check file is loaded and has form field: }
  if not(Comp.FileIsLoaded) and (Comp.FDataFileName <> '') then
    Comp.LoadRTF(Comp.FDataFileName);
  if not Comp.FileIsLoaded then
   begin
     MessageDlg('Failed to read RTF file to get form fields.',
       mtError, [mbOk], 0);
     exit;
   end;
  if Comp.FormFields.Count = 0 then
   begin
     MessageDlg('Your RTF file has no Form Fields. ' +
       'So, sorry, you have no chance to change/view their values...',
       mtInformation, [mbOk], 0);
     exit;
   end;

  { display form fields: }
  Application.CreateForm(TxRTFFFForm, xRTFFFForm);
  try
    xRTFFFForm.Grid.ColCount := 2;
    xRTFFFForm.Grid.DefaultColWidth :=
      xRTFFFForm.Grid.Width div xRTFFFForm.Grid.ColCount - 2;
    xRTFFFForm.Grid.RowCount := Comp.FormFields.Count + 1;
    xRTFFFForm.Grid.Cells[0, 0] := 'Field Name';
    xRTFFFForm.Grid.Cells[1, 0] := 'Current value';
    for i := 0 to Comp.FormFields.Count - 1 do
     begin
       xRTFFFForm.Grid.Cells[0, i + 1] := TxRTFField(Comp.FormFields[i]).DataField.Name;
       xRTFFFForm.Grid.Cells[1, i + 1] := StrPas(TxRTFField(Comp.FormFields[i]).FieldResult);
     end;
    if xRTFFFForm.ShowModal = mrOk then
     begin
       for i := 0 to Comp.FormFields.Count - 1 do
        TxRTFField(Comp.FormFields[i]).SetResult(xRTFFFForm.Grid.Cells[1, i + 1]);
       Designer.Modified;
       Comp.Refresh;
     end;
  finally
    xRTFDataForm.Free;
  end;
end;

function TFormFieldsProperty.GetValue: string;
begin
  Result := 'RTFFormFields';
end;

{ ============== registration section ============= }

procedure Register;
begin
  RegisterComponents('xStorm', [TxRTFViewer, TxRTFScaleCombo]);
  RegisterPropertyEditor(TypeInfo(TxRTFFile), TxRTFViewer, 'Data',
    TxRTFFileProperty);
  RegisterPropertyEditor(TypeInfo(string), TxRTFViewer, 'DataFileName',
    TxDataFileProperty);
  RegisterPropertyEditor(TypeInfo(TList), TxRTFViewer, 'FormFields',
    TFormFieldsProperty);
end;


end.
