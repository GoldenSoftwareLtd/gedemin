
{******************************************}
{                                          }
{             FastReport v2.53             }
{         Checkbox Add-In Object           }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_ChBox;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Menus, FR_Class;

type
  TfrCheckBoxObject = class(TComponent)  // fake component
  end;

  TfrCheckBoxView = class(TfrView)
  private
    procedure DrawCheck(ARect: TRect; Checked: Boolean);
  protected
    procedure SetPropValue(Index: String; Value: Variant); override;
    function GetPropValue(Index: String): Variant; override;
  public
    CheckStyle: Byte;
    CheckColor: TColor;
    constructor Create; override;
    procedure Draw(Canvas: TCanvas); override;
    procedure StreamOut(Stream: TStream); override;
    procedure ExportData; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure SaveToFR3Stream(Stream: TStream); override;
    procedure DefinePopupMenu(Popup: TPopupMenu); override;
    procedure DefineProperties; override;
  end;


const
  csCross = 0;
  csCheck = 1;


implementation

uses FR_Intrp, FR_Pars, FR_Utils, FR_Const, FR_DBRel
{$IFDEF Delphi6}
, Variants
{$ENDIF};

{$R *.RES}

constructor TfrCheckBoxView.Create;
begin
  inherited Create;
  FrameWidth := 2;
  FrameTyp := 15;
  BaseName := 'Check';
  CheckStyle := 0;

  frConsts['csCross'] := csCross;
  frConsts['csCheck'] := csCheck;
end;

procedure TfrCheckBoxView.DefineProperties;
begin
  inherited DefineProperties;
  AddEnumProperty('CheckStyle', 'csCross;csCheck', [csCross,csCheck]);
  AddProperty('CheckColor', [frdtColor], nil);
  AddProperty('DataField', [frdtOneObject, frdtHasEditor, frdtString], frFieldEditor);
end;

procedure TfrCheckBoxView.SetPropValue(Index: String; Value: Variant);
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
  if Index = 'CHECKSTYLE' then
    CheckStyle := Value
  else if Index = 'CHECKCOLOR' then
    CheckColor := Value;
end;

function TfrCheckBoxView.GetPropValue(Index: String): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := inherited GetPropValue(Index);
  if Result <> Null then Exit;
  if Index = 'CHECKSTYLE' then
    Result := CheckStyle
  else if Index = 'CHECKCOLOR' then
    Result := CheckColor
end;

procedure TfrCheckBoxView.DrawCheck(ARect: TRect; Checked: Boolean);
var
  s: String;
begin
  if Checked then
  with Canvas, ARect do
  begin
    Font.Name := 'Wingdings';
    Font.Color := CheckColor;
    Font.Style := [];
    Font.Height := - (DRect.Bottom - DRect.Top);
{$IFNDEF Delphi2}
    Font.CharSet := DEFAULT_CHARSET;
{$ENDIF}
    if CheckStyle = 0 then
      s := #251 else
      s := #252;
    ExtTextOut(Handle, DRect.Left + (DRect.Right - DRect.Left - TextWidth(s)) div 2,
      DRect.Top, ETO_CLIPPED, @DRect, PChar(s), 1, nil);
  end;
end;

procedure TfrCheckBoxView.Draw(Canvas: TCanvas);
var
  Res: Boolean;
begin
  BeginDraw(Canvas);
  Memo1.Assign(Memo);
  CalcGaps;
  ShowBackground;
  Res := False;
  if (DocMode = dmPrinting) and (Memo1.Count > 0) and (Memo1[0] <> '') then
    Res := Memo1[0][1] <> '0';
  if DocMode = dmDesigning then
    Res := True;
  DrawCheck(DRect, Res);
  ShowFrame;
  RestoreCoord;
end;

procedure TfrCheckBoxView.StreamOut(Stream: TStream);
var
  SaveTag: String;
begin
  BeginDraw(Canvas);
  Memo1.Assign(Memo);
  CurReport.InternalOnEnterRect(Memo1, Self);
  frInterpretator.DoScript(Script);
  if not Visible then Exit;

  SaveTag := Tag;
  if (Tag <> '') and (Pos('[', Tag) <> 0) then
    ExpandVariables(Tag);

  if Memo1.Count > 0 then
    Memo1[0] := IntToStr(Trunc(frParser.Calc(Memo1[0])));
  Stream.Write(Typ, 1);
  frWriteString(Stream, ClassName);
  SaveToStream(Stream);

  Tag := SaveTag;
end;

procedure TfrCheckBoxView.ExportData;
var
  s: String;
begin
  inherited;
  s := '';
  if (Memo.Count > 0) and (Memo[0] <> '') then
    if Memo[0][1] <> '0' then
      s := 'X';
  CurReport.InternalOnExportText(DRect, x, y, s, 0{FrameTyp}, Self);
end;

procedure TfrCheckBoxView.DefinePopupMenu(Popup: TPopupMenu);
begin
  // no specific items in popup menu
end;

procedure TfrCheckBoxView.LoadFromStream(Stream: TStream);
begin
  inherited LoadFromStream(Stream);
  if frVersion > 23 then
  begin
    Stream.Read(CheckStyle, 1);
    Stream.Read(CheckColor, 4);
  end;
end;

procedure TfrCheckBoxView.SaveToStream(Stream: TStream);
begin
  inherited SaveToStream(Stream);
  Stream.Write(CheckStyle, 1);
  Stream.Write(CheckColor, 4);
end;

procedure TfrCheckBoxView.SaveToFR3Stream(Stream: TStream);
var
  ds: TfrTDataSet;
  fld: String;

  procedure WriteStr(const s: String);
  begin
    Stream.Write(s[1], Length(s));
  end;

begin
  inherited;

  WriteStr(' CheckStyle="' + IntToStr(CheckStyle) +
    '" CheckColor="' + IntToStr(CheckColor) + '"');

  if Memo.Count <> 0 then
  begin
    frGetDataSetAndField(Memo[0], ds, fld);
    if (ds <> nil) and (fld <> '') then
      WriteStr(' DataSet="' + ds.Owner.Name + '.' + ds.Name +
        '" DataField="' + StrToXML(fld) + '"');
    WriteStr(' Text="' + StrToXML(Memo[0]) + '"');
  end;
end;

var
  Bmp: TBitmap;

initialization
  Bmp := TBitmap.Create;
  Bmp.LoadFromResourceName(hInstance, 'FR_CHECKBOXVIEW');
  frRegisterObject(TfrCheckBoxView, Bmp, IntToStr(SInsCheckBox));

finalization
  Bmp.Free;

end.
