
{******************************************}
{                                          }
{             FastReport v2.53             }
{            OLE Add-In Object             }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_OLE;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OleCtnrs, StdCtrls, ExtCtrls, FR_DBRel, FR_Class,
{$IFDEF Delphi2}
  Ole2;
{$ELSE}
  ActiveX;
{$ENDIF}


type
  TfrOLEObject = class(TComponent)  // fake component
  end;

  TfrOLEView = class(TfrView)
  protected
    procedure GetBlob(b: TfrTField); override;
    procedure OLEEditor(Sender: TObject);
  protected
    procedure SetPropValue(Index: String; Value: Variant); override;
    function GetPropValue(Index: String): Variant; override;
  public
    OleContainer: TOleContainer;
    constructor Create; override;
    destructor Destroy; override;
    procedure Draw(Canvas: TCanvas); override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure Resized; override;
    procedure DefineProperties; override;
    procedure ShowEditor; override;
  end;

  TfrOleForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button4: TButton;
    OleContainer1: TOleContainer;
    Image1: TImage;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
  end;


procedure AssignOle(Cont1, Cont2: TOleContainer);

implementation

uses FR_Intrp, FR_Utils, FR_Const
{$IFDEF Delphi6}
, Variants
{$ENDIF};

{$R *.DFM}

var
  frOleForm: TfrOleForm;

procedure AssignOle(Cont1, Cont2: TOleContainer);
var
  st: TMemoryStream;
begin
  if Cont2.OleObjectInterface = nil then
  begin
    Cont1.DestroyObject;
    Exit;
  end;
  st := TMemoryStream.Create;
  Cont2.SaveToStream(st);
  st.Position := 0;
  Cont1.LoadFromStream(st);
  st.Free;
end;


{----------------------------------------------------------------------------}
constructor TfrOLEView.Create;
begin
  inherited Create;
  OleContainer := TOleContainer.Create(nil);
  with OleContainer do
  begin
    Parent := frOleForm;
    Visible := False;
    AllowInPlace := False;
    AutoVerbMenu := False;
    BorderStyle := bsNone;
    SizeMode := smClip;
  end;
  Flags := 1;
  BaseName := 'Ole';
end;

destructor TfrOLEView.Destroy;
begin
  if frOleForm <> nil then OleContainer.Free;
  inherited Destroy;
end;

procedure TfrOLEView.DefineProperties;
begin
  inherited DefineProperties;
  AddProperty('OLE', [frdtHasEditor, frdtOneObject], OLEEditor);
  AddProperty('Stretched', [frdtBoolean], nil);
  AddProperty('DataField', [frdtOneObject, frdtHasEditor, frdtString], frFieldEditor);
end;

procedure TfrOLEView.SetPropValue(Index: String; Value: Variant);
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
  if Index = 'STRETCHED' then
    Flags := (Flags and not flStretched) or Word(Boolean(Value)) * flStretched
end;

function TfrOLEView.GetPropValue(Index: String): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := inherited GetPropValue(Index);
  if Result <> Null then Exit;
  if Index = 'STRETCHED' then
    Result := (Flags and flStretched) <> 0
end;

procedure TfrOLEView.Draw(Canvas: TCanvas);
var
  Bmp: TBitmap;
begin
  BeginDraw(Canvas);
  CalcGaps;
  OleContainer.Width := dx;
  OleContainer.Height := dy;
  with Canvas do
  begin
    ShowBackground;
    if (dx > 0) and (dy > 0) then
      with OleContainer do
      if OleObjectInterface <> nil then
        OleDraw(OleObjectInterface, DVASPECT_CONTENT, Canvas.Handle, DRect)
      else
      begin
        Font.Name := 'Arial';
        Font.Size := 8;
        Font.Style := [];
        Font.Color := clBlack;
        TextRect(DRect, x + 20, y + 3, '[OLE]');
        Bmp := TBitmap.Create;
        Bmp.Handle := LoadBitmap(hInstance, 'FR_EMPTY');
        Draw(x + 1, y + 2, Bmp);
        Bmp.Free;
      end;
    ShowFrame;
  end;
  RestoreCoord;
end;

procedure TfrOLEView.LoadFromStream(Stream: TStream);
var
  b: Byte;
begin
  inherited LoadFromStream(Stream);
  Stream.Read(b, 1);
  if b <> 0 then
    OleContainer.LoadFromStream(Stream);
end;

procedure TfrOLEView.SaveToStream(Stream: TStream);
var
  b: Byte;
begin
  inherited SaveToStream(Stream);
  b := 0;
  if OleContainer.OleObjectInterface <> nil then
  begin
    b := 1;
    Stream.Write(b, 1);
    OleContainer.SaveToStream(Stream);
  end
  else
    Stream.Write(b, 1);
end;

procedure TfrOLEView.Resized;
var
  VS: TPoint;
begin
  if (Flags and flStretched) = 0 then
    with OleContainer do
    if OleObjectInterface <> nil then
    begin
      Run;
      VS.X := MulDiv(dx, 2540, Screen.PixelsPerInch);
      VS.Y := MulDiv(dy, 2540, Screen.PixelsPerInch);
      OleObjectInterface.SetExtent(DVASPECT_CONTENT, VS);
    end;
end;

procedure TfrOLEView.GetBlob(b: TfrTField);
var
  s: TMemoryStream;
begin
  s := TMemoryStream.Create;
  frAssignBlobTo(b, s);
  OleContainer.LoadFromStream(s);
  s.Free;
end;

procedure TfrOLEView.ShowEditor;
begin
  with frOleForm do
  begin
    AssignOle(OleContainer1, OleContainer);
    if ShowModal = mrOk then
    begin
      frDesigner.BeforeChange;
      AssignOle(OleContainer, OleContainer1);
    end;
    OleContainer1.DestroyObject;
  end;
end;

procedure TfrOLEView.OLEEditor(Sender: TObject);
begin
  ShowEditor;
end;

{----------------------------------------------------------------------------}
procedure TfrOleForm.Button1Click(Sender: TObject);
begin
  with OleContainer1 do
    if InsertObjectDialog then
      DoVerb(PrimaryVerb);
end;

procedure TfrOleForm.Button2Click(Sender: TObject);
begin
  if OleContainer1.OleObjectInterface <> nil then
    OleContainer1.DoVerb(ovPrimary);
end;

procedure TfrOleForm.Localize;
begin
  Caption := frLoadStr(frRes + 550);
  Button1.Caption := frLoadStr(frRes + 551);
  Button2.Caption := frLoadStr(frRes + 552);
  Button4.Caption := frLoadStr(frRes + 553);
end;

procedure TfrOleForm.FormShow(Sender: TObject);
begin
  Localize;
end;


initialization
  frOleForm := TfrOleForm.Create(nil);
  frRegisterObject(TfrOLEView, frOleForm.Image1.Picture.Bitmap,
    IntToStr(SInsOLEObject));

finalization
  frOleForm.Free;
  frOleForm := nil;

end.

