
{******************************************}
{                                          }
{             FastReport v2.53             }
{           Text export filter             }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_E_TXT;

interface

{$I FR.inc}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Forms, Dialogs, FR_Class,
  StdCtrls, Controls;

type
  TfrTextExport = class(TfrExportFilter)
  protected
    FScaleX, FScaleY: Double;
    FKillEmptyLines, FConvertToOEM, FExportFrames,
    FUsePseudographic, FPageBreaks: Boolean;
    Strings: TStringList;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ShowModal: Word; override;
    procedure OnEndPage; override;
    procedure OnBeginPage; override;
    procedure OnText(DrawRect: TRect; X, Y: Integer; const Text: String;
      FrameTyp: Integer; View: TfrView); override;
    procedure InsertTextRec(p: PfrTextRec; LineIndex: Integer);
  published
    property ScaleX: Double read FScaleX write FScaleX;
    property ScaleY: Double read FScaleY write FScaleY;
    property KillEmptyLines: Boolean read FKillEmptyLines write FKillEmptyLines default True;
    property ConvertToOEM: Boolean read FConvertToOEM write FConvertToOEM default False;
    property ExportFrames: Boolean read FExportFrames write FExportFrames default False;
    property UsePseudographic: Boolean read FUsePseudographic write FUsePseudographic default False;
    property PageBreaks: Boolean read FPageBreaks write FPageBreaks default True;
  end;

  TfrTXTExportForm = class(TForm)
    GroupBox1: TGroupBox;
    CB1: TCheckBox;
    CB2: TCheckBox;
    CB4: TCheckBox;
    Label1: TLabel;
    E1: TEdit;
    Button1: TButton;
    Button2: TButton;
    CB5: TCheckBox;
    CB3: TCheckBox;
    Label2: TLabel;
    Label3: TLabel;
    E2: TEdit;
    procedure CB3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
  end;

implementation

uses FR_Utils, FR_Const;

{$R *.DFM}

const
  Frames = '|-+++++++++';
  Pseudo = #179#196#218#191#192#217#193#195#194#180#197;
  PseudoHex = #5#10#6#12#3#9#11#7#14#13#15;


{ TfrTextExport }

constructor TfrTextExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  if ClassName = 'TfrTextExport' then
    frRegisterExportFilter(Self, frLoadStr(STextFile) + ' (*.txt)', '*.txt');
  Strings := TStringList.Create;
  ShowDialog := True;
  ScaleX := 1;
  ScaleY := 1;
  KillEmptyLines := True;
  ConvertToOEM := False;
  ExportFrames := False;
  UsePseudographic := False;
  PageBreaks := True;
end;

destructor TfrTextExport.Destroy;
begin
  Strings.Free;
  frUnRegisterExportFilter(Self);
  inherited Destroy;
end;

function TfrTextExport.ShowModal: Word;
begin
  if not ShowDialog then
    Result := mrOk
  else with TfrTXTExportForm.Create(nil) do
  begin
    CB1.Checked := KillEmptyLines;
    CB2.Checked := ConvertToOEM;
    CB3.Checked := ExportFrames;
    CB4.Checked := UsePseudoGraphic;
    CB5.Checked := PageBreaks;
    E1.Text := FloatToStr(ScaleX);
    E2.Text := FloatToStr(ScaleY);
    CB3Click(nil);
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
    ConvertToOEM := CB2.Checked;
    ExportFrames := CB3.Checked;
    UsePseudoGraphic := CB4.Checked;
    PageBreaks := CB5.Checked;
    Free;
  end;
end;

procedure TfrTextExport.OnEndPage;
var
  i, n, x, dx, x1, dx1, tc1: Integer;
  p: PfrTextRec;
  s: String;
  AddIndex: Integer;
  IsEmpty: Boolean;

  function Dup(Count: Integer): String;
  var
    i: Integer;
  begin
    Result := '';
    for i := 1 to Count do
      Result := Result + ' ';
  end;

  procedure CheckLine(Index: Integer);
  var
    i: Integer;
    s: String;
  begin
    s := Strings[Index];
    for i := 1 to Length(s) do
    begin
      if (Pos(s[i], PseudoHex) = 0) and (s[i] <> ' ') then
      begin
        Strings.Add('');
        AddIndex := Strings.Count;
        break;
      end;
    end;
  end;

  procedure FillLine(Index, x, dx: Integer; ch: Integer);
  var
    i, n: Integer;
    s: String;
  begin
    s := Strings[Index];
    if Length(s) < x + dx then
      s := s + Dup(x + dx - Length(s));
    for i := x to x + dx - 1 do
    begin
      n := Pos(s[i], PseudoHex);
      if n = 0 then
        s[i] := PseudoHex[ch] else
        s[i] := Chr(Ord(PseudoHex[n]) or Ord(PseudoHex[ch]));
    end;
    Strings[Index] := s;
  end;

  procedure AddLine(s: String);
  var
    i: Integer;
    s1: String;
  begin
    if AddIndex >= Strings.Count then
      Strings.Add(s)
    else
    begin
      s1 := Strings[AddIndex];
      if Length(s) > Length(s1) then
        s1 := s1 + Dup(Length(s) - Length(s1));
      for i := 1 to Length(s) do
        if s1[i] = ' ' then
          s1[i] := s[i];
      Strings[AddIndex] := s1;
    end;
  end;

  function ReplaceFrames(s: String): String;
  var
    i, n: Integer;
  begin
    for i := 1 to Length(s) do
    begin
      n := Pos(s[i], PseudoHex);
      if n <> 0 then
        if UsePseudoGraphic then
          s[i] := Pseudo[n] else
          s[i] := Frames[n];
    end;
    Result := s;
  end;

begin
  n := Lines.Count - 1;
  while n >= 0 do
  begin
    if Lines[n] <> nil then break;
    Dec(n);
  end;

  Strings.Clear;
  for i := 0 to n do
  begin
    s := '';
    tc1 := 0;
    p := PfrTextRec(Lines[i]);
    AddIndex := Strings.Count;
    IsEmpty := True;
    while p <> nil do
    begin
      IsEmpty := False;
      x := Round(p^.X / (6.5 / ScaleX));
      if p^.Alignment = frtaRight then
        Dec(x, Length(p^.Text));
      s := s + Dup(x - tc1) + p^.Text;
      tc1 := x + Length(p^.Text);
      if ExportFrames and (p^.FrameTyp <> 0) then
      begin
        x1 := Round(p^.DrawRect.Left / (6.5 / ScaleX));
        dx1 := Round(p^.DrawRect.Right / (6.5 / ScaleX)) - x1 + 1;
        if ((p^.FrameTyp and frftTop) <> 0) or
           ((p^.FrameTyp and frftBottom) <> 0) then
        begin
          if (p^.FrameTyp and frftTop) <> 0 then
            if Strings.Count = 0 then
            begin
              Strings.Add('');
              AddIndex := 1;
            end
            else
              CheckLine(AddIndex - 1);

          x := x1; dx := dx1;
          if (p^.FrameTyp and frftTop) <> 0 then
          begin
            if (p^.FrameTyp and frftLeft) <> 0 then
            begin
              FillLine(AddIndex - 1, x, 1, 3);
              Inc(x); Dec(dx);
            end;
            if (p^.FrameTyp and frftRight) <> 0 then
            begin
              FillLine(AddIndex - 1, x + dx - 1, 1, 4);
              Dec(dx);
            end;
            FillLine(AddIndex - 1, x, dx, 2);
          end;

          x := x1; dx := dx1;
          if (p^.FrameTyp and frftBottom) <> 0 then
          begin
            if AddIndex = Strings.Count then
            begin
              Strings.Add('');
              AddIndex := Strings.Count - 1;
              Strings.Add('');
            end
            else
            if AddIndex = Strings.Count - 1 then
              Strings.Add('');

            if (p^.FrameTyp and frftLeft) <> 0 then
            begin
              FillLine(AddIndex + 1, x, 1, 5);
              Inc(x); Dec(dx);
            end;
            if (p^.FrameTyp and frftRight) <> 0 then
            begin
              FillLine(AddIndex + 1, x + dx - 1, 1, 6);
              Dec(dx);
            end;
            FillLine(AddIndex + 1, x, dx, 2);
          end;
        end;

        x := x1; dx := dx1;
        if ((p^.FrameTyp and frftLeft) <> 0) or
           ((p^.FrameTyp and frftRight) <> 0) then
        begin
          if AddIndex >= Strings.Count then
          begin
            Strings.Add('');
            AddIndex := Strings.Count - 1;
          end;
          if (p^.FrameTyp and frftLeft) <> 0 then
            FillLine(AddIndex, x, 1, 1);
          if (p^.FrameTyp and frftRight) <> 0 then
            FillLine(AddIndex, x + dx - 1, 1, 1);
        end;
      end;
      p := p^.Next;
    end;
    if not KillEmptyLines or not IsEmpty then
      AddLine(s);
  end;
  if PageBreaks then
  begin
    s := #12;
    Strings.Add(s);
  end;

  for i := 0 to Strings.Count - 1 do
  begin
    s := Strings[i];
    if ConvertToOEM then
      CharToOEMBuff(@s[1], @s[1], Length(s));
    if s <> #12 then
      s := ReplaceFrames(s) + #13#10 else
      s := s + #13#10;
    Stream.Write(s[1], Length(s));
  end;
end;

procedure TfrTextExport.OnBeginPage;
var
  i: Integer;
begin
  ClearLines;
  for i := 0 to 200 do Lines.Add(nil);
end;

procedure TfrTextExport.InsertTextRec(p: PfrTextRec; LineIndex: Integer);
var
  p1, p2: PfrTextRec;
begin
  p1 := PfrTextRec(Lines[LineIndex]);
  p^.Next := nil;
  if p1 = nil then
    Lines[LineIndex] := TObject(p)
  else
  begin
    p2 := p1;
    while (p1 <> nil) and (p1^.X < p^.X) do
    begin
      p2 := p1;
      p1 := p1^.Next;
    end;
    if p2 <> p1 then
    begin
      p2^.Next := p;
      p^.Next := p1;
    end
    else
    begin
      Lines[LineIndex] := TObject(p);
      p^.Next := p1;
    end;
  end;
end;

procedure TfrTextExport.OnText(DrawRect: TRect; X, Y: Integer;
  const Text: String; FrameTyp: Integer; View: TfrView);
var
  p: PfrTextRec;
begin
  if View = nil then Exit;
  Y := Round(Y / (14 / ScaleY));
  New(p);
  p^.X := X;
  p^.Text := Text;
  if View is TfrMemoView then
    with View as TfrMemoView do
    begin
      p^.FontName := Font.Name;
      p^.FontSize := Font.Size;
      p^.FontStyle := frGetFontStyle(Font.Style);
      p^.FontColor := Font.Color;
      p^.Alignment := Alignment;
      if Alignment = frtaRight then
        p^.X := DrawRect.Right;
{$IFNDEF Delphi2}
      p^.FontCharset := Font.Charset;
{$ENDIF}
    end;
  p^.DrawRect := DrawRect;
  p^.FrameTyp := FrameTyp;
  p^.FillColor := View.FillColor;
  InsertTextRec(p, Y);
end;



procedure TfrTXTExportForm.CB3Click(Sender: TObject);
begin
  CB4.Enabled := CB3.Checked;
end;

procedure TfrTXTExportForm.Localize;
begin
  Caption := frLoadStr(frRes + 1800);
  CB1.Caption := frLoadStr(frRes + 1801);
  CB2.Caption := frLoadStr(frRes + 1802);
  CB3.Caption := frLoadStr(frRes + 1803);
  CB4.Caption := frLoadStr(frRes + 1804);
  CB5.Caption := frLoadStr(frRes + 1805);
  Label1.Caption := frLoadStr(frRes + 1806);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);
end;

procedure TfrTXTExportForm.FormCreate(Sender: TObject);
begin
  Localize;
end;


end.
