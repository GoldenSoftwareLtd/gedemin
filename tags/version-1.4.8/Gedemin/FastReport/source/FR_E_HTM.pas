
{******************************************}
{                                          }
{             FastReport v2.53             }
{            HTM export filter             }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_E_HTM;

interface

{$I FR.inc}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Forms, StdCtrls,
  FR_Class, FR_E_TXT, Controls;

type
  TfrHTMExport = class(TfrTextExport)
  private
    FExportPictures: Boolean;
    DataList: TList;
    ImgNumber: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    function ShowModal: Word; override;
    procedure OnEndPage; override;
    procedure OnData(x, y: Integer; View: TfrView); override;
    procedure OnBeginDoc; override;
    procedure OnEndDoc; override;
  published
    property ExportPictures: Boolean read FExportPictures write FExportPictures default False;
  end;

  TfrHTMExportForm = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    E2: TEdit;
    CB2: TCheckBox;
    Label3: TLabel;
    CB1: TCheckBox;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
  end;


implementation

uses FR_Utils, FR_Const {$IFDEF JPEG}, JPEG {$ENDIF};

{$R *.DFM}


{ TfrHTMExport }

constructor TfrHTMExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  frRegisterExportFilter(Self, frLoadStr(SHTMFile) + ' (*.htm)', '*.htm');
  ShowDialog := True;
  ScaleY := 1;
  KillEmptyLines := True;
  ExportPictures := False;
end;

procedure TfrHTMExport.OnBeginDoc;
var
  s: String;
begin
  DataList := TList.Create;
  s := '<HTML>'#13#10'<Body bgColor="#FFFFFF">'#13#10'<Table>'#13#10;
  Stream.Write(s[1], Length(s));
  ImgNumber := 0;
end;

procedure TfrHTMExport.OnEndDoc;
var
  s: String;
begin
  s := '</Table>'#13#10'</Body>'#13#10'</HTML>'#13#10;
  Stream.Write(s[1], Length(s));
  DataList.Free;
end;

function TfrHTMExport.ShowModal: Word;
begin
  if not ShowDialog then
    Result := mrOk
  else with TfrHTMExportForm.Create(nil) do
  begin
    CB1.Checked := KillEmptyLines;
    CB2.Checked := ExportPictures;
    E2.Text := FloatToStr(ScaleY);
    Result := ShowModal;
    try
      ScaleY := frStrToFloat(E2.Text);
    except
      ScaleY := 1;
    end;
    KillEmptyLines := CB1.Checked;
    ExportPictures := CB2.Checked;
    Free;
  end;
end;

procedure TfrHTMExport.OnEndPage;
var
  i, n: Integer;
  p: PfrTextRec;
  s, s1, s2: String;
  Str: TStream;
  Pict: TPicture;
  Graphic: TGraphic;
  x, y, dx, dy: Integer;
  b: Byte;
  IsEmpty: Boolean;

  function GetHTMLFontSize(Size: Integer): String;
  begin
    case Size of
      6, 7: Result := '1';
      8, 9: Result := '2';
      14..17: Result := '4';
      18..23: Result := '5';
      24..35: Result := '6'
    else
      Result := '7';
    end;
  end;

  function GetHTMLFontStyle(Style: Integer): String;
  begin
    Result := '';
    if (Style and $1) <> 0 then Result := '<i>';
    if (Style and $2) <> 0 then Result := Result + '<b>';
    if (Style and $4) <> 0 then Result := Result + '<u>';
  end;

begin
  if ExportPictures then
    for i := 0 to DataList.Count - 1 do
    begin
      Str := TStream(DataList[i]);
      Str.Position := 0;
      Pict := TPicture.Create;
      Str.Read(x, 4);
      Str.Read(y, 4);
      Str.Read(dx, 4);
      Str.Read(dy, 4);
      Str.Read(b, 1);

      Graphic := TBitmap.Create;
      s := 'htm' + IntToStr(ImgNumber) + '.bmp';
      if b = 1 then
      begin
{$IFDEF JPEG}
        Graphic.Free;
        Graphic := TJPEGImage.Create;
        s := 'htm' + IntToStr(ImgNumber) + '.jpg';
{$ENDIF}
      end;
      Pict.Graphic := Graphic;
      Graphic.Free;
      Pict.Graphic.LoadFromStream(Str);
      Pict.Graphic.SaveToFile(ExtractFilePath(FileName) + s);

      GetMem(p, SizeOf(TfrTextRec));
      FillChar(p^, SizeOf(TfrTextRec), 0);
      p^.X := x;
      p^.Text := s;
      p^.DrawRect := Rect(x, y, dx, dy);
      p^.FrameTyp := -1;
      InsertTextRec(p, Round(y / (14 / ScaleY)));

      Pict.Free;
      Str.Free;
      Inc(ImgNumber);
    end;
  DataList.Clear;

  n := Lines.Count - 1;
  while n >= 0 do
  begin
    if Lines[n] <> nil then break;
    Dec(n);
  end;

  for i := 0 to n do
  begin
    p := PfrTextRec(Lines[i]);
    s := '<tr>';
    IsEmpty := True;
    while p <> nil do
    begin
      IsEmpty := False;
      s1 := ''; s2 := '';
      if p^.FrameTyp = -1 then
      begin
        s1 := '<img src="' + p^.Text + '" width="' +
          IntToStr(p^.DrawRect.Right) + '" height="' +
          IntToStr(p^.DrawRect.Bottom) + '">';
        s := s + '<td>' + s1 + '</td>';
      end
      else
      begin
        if (p^.FontColor = clWhite) or (p^.FontColor = clNone) then
          p^.FontColor := clBlack;
        if p^.FontColor <> clBlack then
        begin
          s1 := IntToHex(p^.FontColor, 6);
          s1 := 'Color="#' + Copy(s1, 5, 2) + Copy(s1, 3, 2) +
            Copy(s1, 1, 2) + '"';
        end;
        if not (p^.FontSize in [10..13]) then
          s1 := s1 + ' Size=' + GetHTMLFontSize(p^.FontSize);
        if p^.FontStyle <> 0 then
          s2 := GetHTMLFontStyle(p^.FontStyle);
        if s1 <> '' then s1 := '<Font ' + s1 + '>';
        s := s + '<td>' + s1 + s2 + p^.Text + '</td>';
      end;
      p := p^.Next;
    end;
    if not KillEmptyLines or not IsEmpty then
    begin
      s := s + '</tr>'#13#10;
      Stream.Write(s[1], Length(s));
    end;
  end;
end;

procedure TfrHTMExport.OnData(x, y: Integer; View: TfrView);
var
  Str: TStream;
  b: Byte;
  Graphic: TGraphic;
begin
  if ExportPictures then
    if View is TfrPictureView then
    begin
      Graphic := TfrPictureView(View).Picture.Graphic;
      if not ((Graphic = nil) or Graphic.Empty) then
      begin
        Str := TMemoryStream.Create;
        Str.Write(x, 4);
        Str.Write(y, 4);
        Str.Write(View.dx, 4);
        Str.Write(View.dy, 4);
        b := 0;
{$IFDEF JPEG}
        if Graphic is TJPEGImage then
          b := 1;
{$ENDIF}
        Str.Write(b, 1);
        Graphic.SaveToStream(Str);
        DataList.Add(Str);
      end;
    end;
end;


procedure TfrHTMExportForm.Localize;
begin
  Caption := frLoadStr(frRes + 1830);
  CB1.Caption := frLoadStr(frRes + 1801);
  CB2.Caption := frLoadStr(frRes + 1821);
  Label1.Caption := frLoadStr(frRes + 1806);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);
end;

procedure TfrHTMExportForm.FormCreate(Sender: TObject);
begin
  Localize;
end;


end.
