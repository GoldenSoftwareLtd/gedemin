
{******************************************}
{                                          }
{             FastReport v2.53             }
{            RTF export filter             }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_E_RTF;

interface

{$I FR.inc}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Forms, StdCtrls, ComCtrls,
  FR_Class, FR_E_TXT, Controls;

type
  TfrRTFExport = class(TfrTextExport)
  private
    FExportBitmaps, FConvertToTable: Boolean;
    TempStream: TStream;
    FontTable, ColorTable: TStringList;
    DataList: TList;
    NewPage: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    function ShowModal: Word; override;
    procedure OnEndPage; override;
    procedure OnData(x, y: Integer; View: TfrView); override;
    procedure OnBeginDoc; override;
    procedure OnEndDoc; override;
  published
    property ExportBitmaps: Boolean read FExportBitmaps write FExportBitmaps default False;
    property ConvertToTable: Boolean read FConvertToTable write FConvertToTable default False;
  end;

  TfrRTFExportForm = class(TForm)
    GroupBox1: TGroupBox;
    CB1: TCheckBox;
    Label1: TLabel;
    E1: TEdit;
    Button1: TButton;
    Button2: TButton;
    CB5: TCheckBox;
    Label2: TLabel;
    Label3: TLabel;
    E2: TEdit;
    CB2: TCheckBox;
    CB3: TCheckBox;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
  end;


implementation

uses FR_Const, FR_Utils;

{$R *.DFM}


{ TfrRTFExport }

constructor TfrRTFExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  frRegisterExportFilter(Self, frLoadStr(SRTFFile) + ' (*.rtf)', '*.rtf');
  ShowDialog := True;
  ScaleX := 1;
  ScaleY := 1;
  KillEmptyLines := True;
  ExportBitmaps := False;
  ConvertToTable := False;
  PageBreaks := True;
  ScaleX := 1.3;
end;

procedure TfrRTFExport.OnBeginDoc;
var
  s: String;
begin
  NewPage := False;
  FontTable := TStringList.Create;
  ColorTable := TStringList.Create;
  DataList := TList.Create;
  TempStream := TMemoryStream.Create;
  s := '{\rtf1\ansi' + #13#10 + '\margl600\margr600\margt600\margb600' + #13#10;
  Stream.Write(s[1], Length(s));
end;

procedure TfrRTFExport.OnEndDoc;
var
  i, c: Integer;
  s, s1: String;
begin
  s := '\par}';
  TempStream.Write(s[1], Length(s));
  s := '{\fonttbl';
  for i := 0 to FontTable.Count - 1 do
  begin
    s1 := '{\f' + IntToStr(i) + ' ' + FontTable[i] + '}';
    if Length(s + s1) < 255 then
      s := s + s1
    else
    begin
      s := s + #13#10;
      Stream.Write(s[1], Length(s));
      s := s1;
    end;
  end;
  s := s + '}' + #13#10;
  Stream.Write(s[1], Length(s));

  s := '{\colortbl;';
  for i := 0 to ColorTable.Count - 1 do
  begin
    c := StrToInt(ColorTable[i]);
    s1 := '\red' + IntToStr(GetRValue(c)) +
          '\green' + IntToStr(GetGValue(c)) +
          '\blue' + IntToStr(GetBValue(c)) + ';';
    if Length(s + s1) < 255 then
      s := s + s1
    else
    begin
      s := s + #13#10;
      Stream.Write(s[1], Length(s));
      s := s1;
    end;
  end;
  s := s + '}' + #13#10;
  Stream.Write(s[1], Length(s));

  Stream.CopyFrom(TempStream, 0);
  TempStream.Free;
  FontTable.Free;
  ColorTable.Free;
  DataList.Free;
end;

function TfrRTFExport.ShowModal: Word;
begin
  if not ShowDialog then
    Result := mrOk
  else with TfrRTFExportForm.Create(nil) do
  begin
    CB1.Checked := KillEmptyLines;
    CB2.Checked := ExportBitmaps;
    CB3.Checked := ConvertToTable;
    CB5.Checked := PageBreaks;
    E1.Text := FloatToStr(ScaleX);
    E2.Text := FloatToStr(ScaleY);

    Result := ShowModal;
    try
      ScaleX := frStrToFloat(E1.Text);
    except
      ScaleX := 1;
    end;
    try
      ScaleY := frStrToFloat(E2.Text);
    except
      ScaleY := 1;
    end;
    KillEmptyLines := CB1.Checked;
    ExportBitmaps := CB2.Checked;
    ConvertToTable := CB3.Checked;
    PageBreaks := CB5.Checked;
    Free;
  end;
end;

procedure TfrRTFExport.OnEndPage;
var
  i, j, n, n1, x, x1, y, dx, dy: Integer;
  p: PfrTextRec;
  s0, s, s1: String;
  fSize, fStyle, fColor: Integer;
  fName: String;
  Str: TStream;
  bArr: Array[0..1023] of Byte;
  IsEmpty: Boolean;

  function GetFontStyle(f: Integer): String;
  begin
    Result := '';
    if (f and $1) <> 0 then Result := '\i';
    if (f and $2) <> 0 then Result := Result + '\b';
    if (f and $4) <> 0 then Result := Result + '\ul';
  end;

  function GetFontColor(f: String): String;
  var
    i: Integer;
  begin
    i := ColorTable.IndexOf(f);
    if i <> -1 then
      Result := IntToStr(i + 1)
    else
    begin
      ColorTable.Add(f);
      Result := IntToStr(ColorTable.Count);
    end;
  end;

  function GetFontName(f: String): String;
  var
    i: Integer;
  begin
    i := FontTable.IndexOf(f);
    if i <> -1 then
      Result := IntToStr(i)
    else
    begin
      FontTable.Add(f);
      Result := IntToStr(FontTable.Count - 1);
    end;
  end;

begin
  if NewPage and PageBreaks then
  begin
    s := '\page' + #13#10;
    TempStream.Write(s[1], Length(s));
  end;

  if ExportBitmaps then
    for i := 0 to DataList.Count - 1 do
    begin
      Str := TStream(DataList[i]);
      Str.Position := 0;
      Str.Read(x, 4);
      Str.Read(y, 4);
      Str.Read(dx, 4);
      Str.Read(dy, 4);
      s := '\pard\phmrg\posx' + IntToStr(Round(x / (1.3 / ScaleX) * 20)) +
           '\posy' + IntToStr(Round(y * 20 / 1.3)) +
           '\absh' + IntToStr(dy * 20) +
           '\absw' + IntToStr(dx * 20) +
           '{\pict\wmetafile8\picw' + IntToStr(Round(dx * 26.46875)) +
           '\pich' + IntToStr(Round(dy * 26.46875)) + ' \picbmp\picbpp4' + #13#10;
      TempStream.Write(s[1], Length(s));
  // shit begins
      Str.Read(dx, 4);
      Str.Read(dy, 4);
      Str.Read(n, 2);
      Str.Read(n, 4);
      n := n div 2 + 7;
      s0 := IntToHex(n + $24, 8);
      s := '010009000003' + Copy(s0, 7, 2) + Copy(s0, 5, 2) +
           Copy(s0, 3, 2) + Copy(s0, 1, 2) + '0000';
      s0 := IntToHex(n, 8);
      s1 := Copy(s0, 7, 2) + Copy(s0, 5, 2) + Copy(s0, 3, 2) + Copy(s0, 1, 2);
      s := s + s1 + '0000050000000b0200000000050000000c02';
      s0 := IntToHex(dy, 4);
      s := s + Copy(s0, 3, 2) + Copy(s0, 1, 2);
      s0 := IntToHex(dx, 4);
      s := s + Copy(s0, 3, 2) + Copy(s0, 1, 2) +
           '05000000090200000000050000000102ffffff000400000007010300' + s1 +
           '430f2000cc000000';
      s0 := IntToHex(dy, 4);
      s := s + Copy(s0, 3, 2) + Copy(s0, 1, 2);
      s0 := IntToHex(dx, 4);
      s := s + Copy(s0, 3, 2) + Copy(s0, 1, 2) + '00000000';
      s0 := IntToHex(dy, 4);
      s := s + Copy(s0, 3, 2) + Copy(s0, 1, 2);
      s0 := IntToHex(dx, 4);
      s := s + Copy(s0, 3, 2) + Copy(s0, 1, 2) + '00000000' + #13#10;
      TempStream.Write(s[1], Length(s));
  // shit ends

      Str.Read(bArr[0], 8);
      n1 := 0; s := '';
      repeat
        n := Str.Read(bArr[0], 1024);
        for j := 0 to n - 1 do
        begin
          s := s + IntToHex(bArr[j], 2);
          Inc(n1);
          if n1 > 63 then
          begin
            n1 := 0;
            s := s + #13#10;
            TempStream.Write(s[1], Length(s));
            s := '';
          end;
        end;
      until n < 1024;
      Str.Free;
      if n1 <> 0 then
        TempStream.Write(s[1], Length(s));

      s := '030000000000}\par' + #13#10;
      TempStream.Write(s[1], Length(s));
    end;

  n := Lines.Count - 1;
  while n >= 0 do
  begin
    if Lines[n] <> nil then break;
    Dec(n);
  end;

  for i := 0 to n do
  begin
    p := PfrTextRec(Lines[i]);
    s := '';
    fSize := -1; fStyle := -1; fColor := -1; fName := '';
    if ConvertToTable then
      s0 := '\trowd \trgaph108' else
      s0 := '\pard';
    IsEmpty := True;
    x1 := 0;

    while p <> nil do
    begin
      IsEmpty := False;
      if ConvertToTable then
      begin
        if p <> PfrTextRec(Lines[i]) then
          s0 := s0 + '\cellx' + IntToStr(Round(p^.X / (1.3 / ScaleX) * 20));
      end
      else
      begin
        if p^.Alignment = frtaRight then
          s0 := s0 + '\tqr';
        s0 := s0 + '\tx' + IntToStr(Round(p^.X / (1.3 / ScaleX) * 20));
      end;
      s1 := '';
      if p^.FontColor = clWhite then
        p^.FontColor := clBlack;
      if (fName <> p^.FontName) or ConvertToTable then
        s1 := '\f' + GetFontName(p^.FontName);
      if (fSize <> p^.FontSize) or ConvertToTable then
        s1 := s1 + '\fs' + IntToStr(p^.FontSize * 2);
      if (fStyle <> p^.FontStyle) or ConvertToTable then
        s1 := s1 + GetFontStyle(p^.FontStyle);
      if (fColor <> p^.FontColor) or ConvertToTable then
        s1 := s1 + '\cf' + GetFontColor(IntToStr(p^.FontColor));

      if ConvertToTable then
        s := s + '{' + s1 + ' ' + p^.Text + '}\cell ' else
        s := s + '\tab' + s1 + ' ' + p^.Text;

      fSize := p^.FontSize; fStyle := p^.FontStyle;
      fColor := p^.FontColor; fName := p^.FontName;
      x1 := Round(p^.DrawRect.Right / (1.3 / ScaleX) * 20);
      p := p^.Next;
    end;

    if not KillEmptyLines or not IsEmpty then
    begin
      p := PfrTextRec(Lines[i]);
      if p <> nil then
        if ConvertToTable then
        begin
          s0 := s0 + '\cellx' + IntToStr(x1) + ' \trleft' +
            IntToStr(Round(p^.X / (1.3 / ScaleX) * 20));
          s := s0 + ' \pard \intbl ' + s + '\pard \intbl \row' + #13#10;
        end
        else
          s := s0 + '{' + s + '\par}' + #13#10;
      if s = '' then
        s := '{\pard \par}' + #13#10;
      TempStream.Write(s[1], Length(s));
    end;
  end;

  if ConvertToTable then
  begin
    s := '\pard' + #13#10;
    TempStream.Write(s[1], Length(s));
  end;
  NewPage := True;
  DataList.Clear;
end;

procedure TfrRTFExport.OnData(x, y: Integer; View: TfrView);
var
  Str: TStream;
  n: Integer;
  Graphic: TGraphic;
begin
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
      n := Graphic.Width;
      Str.Write(n, 4);
      n := Graphic.Height;
      Str.Write(n, 4);
      Graphic.SaveToStream(Str);
      DataList.Add(Str);
    end;
  end;
end;

procedure TfrRTFExportForm.Localize;
begin
  Caption := frLoadStr(frRes + 1820);
  CB1.Caption := frLoadStr(frRes + 1801);
  CB2.Caption := frLoadStr(frRes + 1821);
  CB3.Caption := frLoadStr(frRes + 1822);
  CB5.Caption := frLoadStr(frRes + 1805);
  Label1.Caption := frLoadStr(frRes + 1806);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);
end;

procedure TfrRTFExportForm.FormCreate(Sender: TObject);
begin
  Localize;
end;


end.
