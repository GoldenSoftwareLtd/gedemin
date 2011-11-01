{******************************************}
{                                          }
{             FastReport v2.53             }
{           Images export filter           }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit frexpimg;

interface

{$I Fr.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, extctrls, Clipbrd, Printers, FR_Class
{$IFDEF Delphi6}
, Variants
{$ENDIF},
  FR_Progr, FR_Ctrls
{$IFDEF JPEG}
, jpeg
{$ENDIF};

type
  PDirEntry = ^TDirEntry;
  TDirEntry = record
    _Tag: Word;
    _Type: Word;
    _Count: LongInt;
    _Value: LongInt;
  end;

type
  TfrImgFltSet = class(TForm)
    OK: TButton;
    Cancel: TButton;
    GroupPageRange: TGroupBox;
    Label7: TLabel;
    E_Range: TEdit;
    Label1: TLabel;
    GroupBox1: TGroupBox;
    CropPage: TCheckBox;
    Label2: TLabel;
    Quality: TEdit;
    Mono: TCheckBox;
    procedure FormCreate(Sender: TObject);
  private
    procedure Localize;
  end;

  TfrImgFltExport = class(TfrExportFilter)
  private
    CurrentPage: integer;
    Canvas: TBitmap;
    MaxX, MaxY: Integer;
    MinX, MinY: Integer;
    frExportSet: TfrImgFltSet;
    pgList: TStringList;
    JPGQuality: integer;
    Crop: Boolean;
    FMono: Boolean;
    procedure AfterExport(const FileName: string);
    procedure Save; virtual; abstract;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ShowModal: Word; override;
    procedure OnBeginDoc; override;
    procedure OnEndPage; override;
    procedure OnBeginPage; override;
    procedure OnData(x, y: Integer; View: TfrView); override;
  published
    property Quality: integer read JPGQuality write JPGQuality default 90;
    property CropImages: Boolean read Crop write Crop default True;
    property Monochrome: Boolean read FMono write FMono default False;
  end;

  TfrBMPExport = class(TfrImgFltExport)
  private
    procedure Save; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property CropImages;
    property Monochrome;
  end;

  TfrTIFFExport = class(TfrImgFltExport)
  private
    procedure Save; override;
    procedure SaveTiffToStream(Stream: TStream; Bitmap: TBitmap);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property CropImages;
    property Monochrome;
  end;

{$IFDEF JPEG}
  TfrJPEGExport = class(TfrImgFltExport)
  private
    procedure Save; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Quality;
    property CropImages;
    property Monochrome;
  end;
{$ENDIF}

implementation

uses FR_Const, FR_Utils;

{$R *.dfm}

const
  TifHeader: array[0..7] of Byte = (
    $49, $49, $2A, $00, $08, $00, $00, $00);

  NoOfDirs: array[0..1] of Byte = ($0F, $00);

var
  D_BW: array[0..13] of TDirEntry = (
    (_Tag: $00FE; _Type: $0004; _Count: $00000001; _Value: $00000000),
    (_Tag: $0100; _Type: $0003; _Count: $00000001; _Value: $00000000),
    (_Tag: $0101; _Type: $0003; _Count: $00000001; _Value: $00000000),
    (_Tag: $0102; _Type: $0003; _Count: $00000001; _Value: $00000001),
    (_Tag: $0103; _Type: $0003; _Count: $00000001; _Value: $00000001),
    (_Tag: $0106; _Type: $0003; _Count: $00000001; _Value: $00000001),
    (_Tag: $0111; _Type: $0004; _Count: $00000001; _Value: $00000000),
    (_Tag: $0115; _Type: $0003; _Count: $00000001; _Value: $00000001),
    (_Tag: $0116; _Type: $0004; _Count: $00000001; _Value: $00000000),
    (_Tag: $0117; _Type: $0004; _Count: $00000001; _Value: $00000000),
    (_Tag: $011A; _Type: $0005; _Count: $00000001; _Value: $00000000),
    (_Tag: $011B; _Type: $0005; _Count: $00000001; _Value: $00000000),
    (_Tag: $0128; _Type: $0003; _Count: $00000001; _Value: $00000002),
    (_Tag: $0131; _Type: $0002; _Count: $0000000A; _Value: $00000000));

  D_COL: array[0..14] of TDirEntry = (
    (_Tag: $00FE; _Type: $0004; _Count: $00000001; _Value: $00000000),
    (_Tag: $0100; _Type: $0003; _Count: $00000001; _Value: $00000000),
    (_Tag: $0101; _Type: $0003; _Count: $00000001; _Value: $00000000),
    (_Tag: $0102; _Type: $0003; _Count: $00000001; _Value: $00000008),
    (_Tag: $0103; _Type: $0003; _Count: $00000001; _Value: $00000001),
    (_Tag: $0106; _Type: $0003; _Count: $00000001; _Value: $00000003),
    (_Tag: $0111; _Type: $0004; _Count: $00000001; _Value: $00000000),
    (_Tag: $0115; _Type: $0003; _Count: $00000001; _Value: $00000001),
    (_Tag: $0116; _Type: $0004; _Count: $00000001; _Value: $00000000),
    (_Tag: $0117; _Type: $0004; _Count: $00000001; _Value: $00000000),
    (_Tag: $011A; _Type: $0005; _Count: $00000001; _Value: $00000000),
    (_Tag: $011B; _Type: $0005; _Count: $00000001; _Value: $00000000),
    (_Tag: $0128; _Type: $0003; _Count: $00000001; _Value: $00000002),
    (_Tag: $0131; _Type: $0002; _Count: $0000000A; _Value: $00000000),
    (_Tag: $0140; _Type: $0003; _Count: $00000300; _Value: $00000008));

  D_RGB: array[0..14] of TDirEntry = (
    (_Tag: $00FE; _Type: $0004; _Count: $00000001; _Value: $00000000),
    (_Tag: $0100; _Type: $0003; _Count: $00000001; _Value: $00000000),
    (_Tag: $0101; _Type: $0003; _Count: $00000001; _Value: $00000000),
    (_Tag: $0102; _Type: $0003; _Count: $00000003; _Value: $00000008),
    (_Tag: $0103; _Type: $0003; _Count: $00000001; _Value: $00000001),
    (_Tag: $0106; _Type: $0003; _Count: $00000001; _Value: $00000002),
    (_Tag: $0111; _Type: $0004; _Count: $00000001; _Value: $00000000),
    (_Tag: $0115; _Type: $0003; _Count: $00000001; _Value: $00000003),
    (_Tag: $0116; _Type: $0004; _Count: $00000001; _Value: $00000000),
    (_Tag: $0117; _Type: $0004; _Count: $00000001; _Value: $00000000),
    (_Tag: $011A; _Type: $0005; _Count: $00000001; _Value: $00000000),
    (_Tag: $011B; _Type: $0005; _Count: $00000001; _Value: $00000000),
    (_Tag: $011C; _Type: $0003; _Count: $00000001; _Value: $00000001),
    (_Tag: $0128; _Type: $0003; _Count: $00000001; _Value: $00000002),
    (_Tag: $0131; _Type: $0002; _Count: $0000000A; _Value: $00000000));

  NullString: array[0..3] of Byte = ($00, $00, $00, $00);
  X_Res_Value: array[0..7] of Byte = ($6D, $03, $00, $00, $0A, $00, $00, $00);
  Y_Res_Value: array[0..7] of Byte = ($6D, $03, $00, $00, $0A, $00, $00, $00);
  Software: array[0..9] of Char = ('F', 'a', 's', 't', 'R', 'e', 'p', 'o', 'r',
    't');
  BitsPerSample: array[0..2] of Word = ($0008, $0008, $0008);

constructor TfrImgFltExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  pgList := TStringList.Create;
  JPGQuality := 90;
  ShowDialog := True;
  Crop := True;
  Monochrome := False;
end;

constructor TfrBMPExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  frRegisterExportFilter(Self, frLoadStr(frRes + 1875), '*.bmp');
end;

constructor TfrTIFFExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  frRegisterExportFilter(Self, frLoadStr(frRes + 1876), '*.tif');
end;

destructor TfrImgFltExport.Destroy;
begin
  pgList.Destroy;
  inherited;
end;

destructor TfrBMPExport.Destroy;
begin
  frUnRegisterExportFilter(Self);
  inherited;
end;

destructor TfrTIFFExport.Destroy;
begin
  frUnRegisterExportFilter(Self);
  inherited;
end;

{$IFDEF JPEG}
constructor TfrJPEGExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  frRegisterExportFilter(Self, frLoadStr(frRes + 1877), '*.jpg');
end;

destructor TfrJPEGExport.Destroy;
begin
  frUnRegisterExportFilter(Self);
  inherited;
end;

procedure TfrJPEGExport.Save;
var
  Image: TJPEGImage;
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(ChangeFileExt(FileName, '_' +
    IntToStr(CurrentPage) + '.jpg'), fmCreate);
  Image := TJPEGImage.Create;
  Image.CompressionQuality := JPGQuality;
  Image.Assign(Canvas);
  Image.SaveToStream(Stream);
  Image.Free;
  Stream.Free;
end;
{$ENDIF}

function TfrImgFltExport.ShowModal: Word;
var
  PageNumbers: string;
  Res: integer;

  procedure ParsePageNumbers;
  var
    i, j, n1, n2: Integer;
    s: string;
    IsRange: Boolean;
  begin
    s := PageNumbers;
    while Pos(' ', s) <> 0 do
      Delete(s, Pos(' ', s), 1);
    if s = '' then
      Exit;
    s := s + ',';
    i := 1;
    j := 1;
    n1 := 1;
    IsRange := False;
    while i <= Length(s) do
    begin
      if s[i] = ',' then
      begin
        n2 := StrToInt(Copy(s, j, i - j));
        j := i + 1;
        if IsRange then
          while n1 <= n2 do
          begin
            pgList.Add(IntToStr(n1));
            Inc(n1);
          end
        else
          pgList.Add(IntToStr(n2));
        IsRange := False;
      end
      else if s[i] = '-' then
      begin
        IsRange := True;
        n1 := StrToInt(Copy(s, j, i - j));
        j := i + 1;
      end;
      Inc(i);
    end;
    pgList.Sort;
  end;

begin
  Res := mrOk;
  if ShowDialog then
  begin
    frExportSet := TfrImgFltSet.Create(nil);
    frExportSet.Quality.Text := IntToStr(JPGQuality);
    frExportSet.CropPage.Checked := Crop;
    frExportSet.Mono.Checked := Monochrome;
{$IFDEF JPEG}
    if Self is TfrJPEGExport then
      frExportSet.Quality.Enabled := true
    else
{$ENDIF}
      frExportSet.Quality.Enabled := false;
    Res := frExportSet.ShowModal;
    JPGQuality := StrToInt(frExportSet.Quality.Text);
    Crop := frExportSet.CropPage.Checked;
    PageNumbers := frExportSet.E_Range.Text;
    Monochrome := frExportSet.Mono.Checked;
    frExportSet.Destroy;
  end;
  pgList.Clear;
  ParsePageNumbers;
  Result := Res;
end;

procedure TfrImgFltExport.OnBeginDoc;
begin
  OnAfterExport := AfterExport;
  CurrentPage := 0;
end;

procedure TfrImgFltExport.OnBeginPage;
begin
  Inc(CurrentPage);
  Canvas := TBitmap.Create;
  Canvas.Canvas.Brush.Color := clWhite;
  if Monochrome then
    Canvas.Monochrome := true
  else
    Canvas.Monochrome := false;
  if not Crop then
  begin
    Canvas.Width := CurReport.EMFPages[CurrentPage - 1].PrnInfo.Pgw;
    Canvas.Height := CurReport.EMFPages[CurrentPage - 1].PrnInfo.Pgh;
  end;
  MaxX := 0;
  MaxY := 0;
  MinX := CurReport.EMFPages[CurrentPage - 1].PrnInfo.Pgw;
  MinY := CurReport.EMFPages[CurrentPage - 1].PrnInfo.Pgh;
end;

procedure TfrImgFltExport.OnData(x, y: Integer; View: TfrView);
var
  ind: integer;
begin
  ind := 0;
  if (pgList.Find(IntToStr(CurrentPage), ind)) or (pgList.Count = 0) then
  begin
    if View.x < MinX then
      MinX := View.x;
    if View.y < MinY then
      MinY := View.Y;
    if (View.x + View.dx) > MaxX then
      MaxX := View.x + View.dx + 1;
    if (View.y + View.dy) > MaxY then
      MaxY := View.y + View.dY + 1;
    if Crop then
    begin
      Canvas.Canvas.Brush.Color := clWhite;
      Canvas.Width := MaxX;
      Canvas.Height := MaxY
    end;
    View.Draw(Canvas.Canvas);
  end;
end;

procedure TfrImgFltExport.OnEndPage;
var
  ind: integer;
  RFrom, RTo: TRect;
begin
  ind := 0;
  if (pgList.Find(IntToStr(CurrentPage), ind)) or (pgList.Count = 0) then
  begin
    if Crop then
    begin
      RFrom := Rect(MinX, MinY, MaxX, MaxY);
      RTo := Rect(0, 0, MaxX - MinX, MaxY - MinY);
      Canvas.Canvas.CopyRect(RTo, Canvas.Canvas, RFrom);
      Canvas.Width := MaxX - MinX;
      Canvas.Height := MaxY - MinY;
    end;
    Save;
  end;
  Canvas.Free;
end;

procedure TfrBMPExport.Save;
begin
  Canvas.SaveToFile(ChangeFileExt(FileName, '_' + IntToStr(CurrentPage) +
    '.bmp'));
end;

procedure TfrTIFFExport.Save;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(ChangeFileExt(FileName, '_' +
    IntToStr(CurrentPage) + '.tif'), fmCreate);
  SaveTiffToStream(Stream, Canvas);
  Stream.Free;
end;

procedure TfrImgFltExport.AfterExport(const FileName: string);
begin
  frProgressForm.Close;
  DeleteFile(FileName);
end;

procedure TfrTIFFExport.SaveTIFFToStream(Stream: TStream; Bitmap: TBitmap);
var
  BM: HBitmap;
  Header, Bits, BitsPtr, TmpBitsPtr, NewBits: PChar;
  HeaderSize, BitsSize: DWORD;
  Width, Height, DataWidth, BitCount: Integer;
  MapRed, MapGreen, MapBlue: array[0..255, 0..1] of Byte;
  ColTabSize, i, k, BmpWidth: Integer;
  Red, Blue, Green: Char;
  O_XRes, O_YRes, O_Soft, O_Strip, O_Dir, O_BPS: LongInt;
  RGB: Word;

begin
  BM := Bitmap.Handle;
  if BM = 0 then
    exit;
  GetDIBSizes(BM, HeaderSize, BitsSize);
  GetMem(Header, HeaderSize + BitsSize);
  try
    Bits := Header + HeaderSize;
    if GetDIB(BM, Bitmap.Palette, Header^, Bits^) then
    begin
      Width := PBITMAPINFO(Header)^.bmiHeader.biWidth;
      Height := PBITMAPINFO(Header)^.bmiHeader.biHeight;
      BitCount := PBITMAPINFO(Header)^.bmiHeader.biBitCount;
      ColTabSize := (1 shl BitCount);
      BmpWidth := Trunc(BitsSize / Height);
      if BitCount = 1 then
      begin
        DataWidth := ((Width + 7) div 8);
        D_BW[1]._Value := LongInt(Width);
        D_BW[2]._Value := LongInt(abs(Height));
        D_BW[8]._Value := LongInt(abs(Height));
        D_BW[9]._Value := LongInt(DataWidth * abs(Height));
        Stream.Write(TifHeader, sizeof(TifHeader));
        O_XRes := Stream.Position;
        Stream.Write(X_Res_Value, sizeof(X_Res_Value));
        O_YRes := Stream.Position;
        Stream.Write(Y_Res_Value, sizeof(Y_Res_Value));
        O_Soft := Stream.Position;
        Stream.Write(Software, sizeof(Software));
        D_BW[6]._Value := 0;
        D_BW[10]._Value := O_XRes;
        D_BW[11]._Value := O_YRes;
        D_BW[13]._Value := O_Soft;
        O_Dir := Stream.Position;
        Stream.Write(NoOfDirs, sizeof(NoOfDirs));
        Stream.Write(D_BW, sizeof(D_BW));
        O_Strip := Stream.Position;
        if Height < 0 then
          for I := 0 to Height - 1 do
          begin
            BitsPtr := Bits + I * BmpWidth;
            Stream.Write(BitsPtr^, DataWidth);
          end
        else
          for I := 1 to Height do
          begin
            BitsPtr := Bits + (Height - I) * BmpWidth;
            Stream.Write(BitsPtr^, DataWidth);
          end;
        Stream.Write(NullString, sizeof(NullString));
        D_BW[6]._Value := O_Strip;
        Stream.Seek(O_Dir, soFromBeginning);
        Stream.Write(NoOfDirs, sizeof(NoOfDirs));
        Stream.Write(D_BW, sizeof(D_BW));
        Stream.Seek(4, soFromBeginning);
        Stream.Write(O_Dir, sizeof(O_Dir));
      end;
      if BitCount in [4, 8] then
      begin
        DataWidth := Width;
        if BitCount = 4 then
        begin
          Width := (Width div BitCount) * BitCount;
          if BitCount = 4 then
            DataWidth := Width div 2;
        end;
        D_COL[1]._Value := LongInt(Width);
        D_COL[2]._Value := LongInt(abs(Height));
        D_COL[3]._Value := LongInt(BitCount);
        D_COL[8]._Value := LongInt(Height);
        D_COL[9]._Value := LongInt(DataWidth * abs(Height));
        for I := 0 to ColTabSize - 1 do
        begin
          MapRed[I][1] := PBITMAPINFO(Header)^.bmiColors[I].rgbRed;
          MapRed[I][0] := 0;
          MapGreen[I][1] := PBITMAPINFO(Header)^.bmiColors[I].rgbGreen;
          MapGreen[I][0] := 0;
          MapBlue[I][1] := PBITMAPINFO(Header)^.bmiColors[I].rgbBlue;
          MapBlue[I][0] := 0;
        end;
        D_COL[14]._Count := LongInt(ColTabSize * 3);
        Stream.Write(TifHeader, sizeof(TifHeader));
        Stream.Write(MapRed, ColTabSize * 2);
        Stream.Write(MapGreen, ColTabSize * 2);
        Stream.Write(MapBlue, ColTabSize * 2);
        O_XRes := Stream.Position;
        Stream.Write(X_Res_Value, sizeof(X_Res_Value));
        O_YRes := Stream.Position;
        Stream.Write(Y_Res_Value, sizeof(Y_Res_Value));
        O_Soft := Stream.Position;
        Stream.Write(Software, sizeof(Software));
        O_Strip := Stream.Position;
        if Height < 0 then
          for I := 0 to Height - 1 do
          begin
            BitsPtr := Bits + I * BmpWidth;
            Stream.Write(BitsPtr^, DataWidth);
          end
        else
          for I := 1 to Height do
          begin
            BitsPtr := Bits + (Height - I) * BmpWidth;
            Stream.Write(BitsPtr^, DataWidth);
          end;
        D_COL[6]._Value := O_Strip;
        D_COL[10]._Value := O_XRes;
        D_COL[11]._Value := O_YRes;
        D_COL[13]._Value := O_Soft;
        O_Dir := Stream.Position;
        Stream.Write(NoOfDirs, sizeof(NoOfDirs));
        Stream.Write(D_COL, sizeof(D_COL));
        Stream.Write(NullString, sizeof(NullString));
        Stream.Seek(4, soFromBeginning);
        Stream.Write(O_Dir, sizeof(O_Dir));
      end;
      if BitCount=16 then
      begin
        D_RGB[1]._Value := LongInt(Width);
        D_RGB[2]._Value := LongInt(Height);
        D_RGB[8]._Value := LongInt(Height);
        D_RGB[9]._Value := LongInt(3 * Width * Height);
        Stream.Write(TifHeader, sizeof(TifHeader));
        O_XRes := Stream.Position;
        Stream.Write(X_Res_Value, sizeof(X_Res_Value));
        O_YRes := Stream.Position;
        Stream.Write(Y_Res_Value, sizeof(Y_Res_Value));
        O_BPS := Stream.Position;
        Stream.Write(BitsPerSample, sizeof(BitsPerSample));
        O_Soft := Stream.Position;
        Stream.Write(Software, sizeof(Software));
        O_Strip := Stream.Position;
        GetMem(NewBits, Width * Height * 3);
        for I := 0 to Height - 1 do
        begin
          BitsPtr := Bits + I * BmpWidth;
          TmpBitsPtr := NewBits + I * Width * 3;
          for K := 0 to Width - 1 do
          begin
            RGB := PWord(BitsPtr)^;
            Blue := Char((RGB and $1F) shl 3 or $7);
            Green := Char((RGB shr 5 and $1F) shl 3 or $7);
            Red := Char((RGB shr 10 and $1F) shl 3 or $7);
            PByte(TmpBitsPtr)^ :=  Byte(Red);
            PByte(TmpBitsPtr + 1)^ := Byte(Green);
            PByte(TmpBitsPtr + 2)^ := Byte(Blue);
            BitsPtr := BitsPtr + 2;
            TmpBitsPtr := TmpBitsPtr + 3;
          end;
        end;
        for I := 1 to Height do
        begin
          TmpBitsPtr := NewBits + (Height - I) * Width * 3;
          Stream.Write(TmpBitsPtr^, Width * 3);
        end;
        FreeMem(NewBits);
        D_RGB[3]._Value := O_BPS;
        D_RGB[6]._Value := O_Strip;
        D_RGB[10]._Value := O_XRes;
        D_RGB[11]._Value := O_YRes;
        D_RGB[14]._Value := O_Soft;
        O_Dir := Stream.Position;
        Stream.Write(NoOfDirs, sizeof(NoOfDirs));
        Stream.Write(D_RGB, sizeof(D_RGB));
        Stream.Write(NullString, sizeof(NullString));
        Stream.Seek(4, soFromBeginning);
        Stream.Write(O_Dir, sizeof(O_Dir));
      end;
      if BitCount in [24, 32] then
      begin
        D_RGB[1]._Value := LongInt(Width);
        D_RGB[2]._Value := LongInt(Height);
        D_RGB[8]._Value := LongInt(Height);
        D_RGB[9]._Value := LongInt(3 * Width * Height);
        Stream.Write(TifHeader, sizeof(TifHeader));
        O_XRes := Stream.Position;
        Stream.Write(X_Res_Value, sizeof(X_Res_Value));
        O_YRes := Stream.Position;
        Stream.Write(Y_Res_Value, sizeof(Y_Res_Value));
        O_BPS := Stream.Position;
        Stream.Write(BitsPerSample, sizeof(BitsPerSample));
        O_Soft := Stream.Position;
        Stream.Write(Software, sizeof(Software));
        O_Strip := Stream.Position;
        for I := 0 to Height - 1 do
        begin
          BitsPtr := Bits + I * BmpWidth;
          for K := 0 to Width - 1 do
          begin
            Blue := (BitsPtr)^;
            Red := (BitsPtr + 2)^;
            (BitsPtr)^ := Red;
            (BitsPtr + 2)^ := Blue;
            BitsPtr := BitsPtr + BitCount div 8;
          end;
        end;
        if BitCount = 32 then
          for I := 0 to Height - 1 do
          begin
            BitsPtr := Bits + I * BmpWidth;
            TmpBitsPtr := BitsPtr;
            for k := 0 to Width - 1 do
            begin
              (TmpBitsPtr)^ := (BitsPtr)^;
              (TmpBitsPtr + 1)^ := (BitsPtr + 1)^;
              (TmpBitsPtr + 2)^ := (BitsPtr + 2)^;
              TmpBitsPtr := TmpBitsPtr + 3;
              BitsPtr := BitsPtr + 4;
            end;
          end;
        BmpWidth := Trunc(BitsSize / Height);
        if Height < 0 then
          for I := 0 to Height - 1 do
          begin
            BitsPtr := Bits + I * BmpWidth;
            Stream.Write(BitsPtr^, Width * 3);
          end
        else
          for I := 1 to Height do
          begin
            BitsPtr := Bits + (Height - I) * BmpWidth;
            Stream.Write(BitsPtr^, Width * 3);
          end;
        D_RGB[3]._Value := O_BPS;
        D_RGB[6]._Value := O_Strip;
        D_RGB[10]._Value := O_XRes;
        D_RGB[11]._Value := O_YRes;
        D_RGB[14]._Value := O_Soft;
        O_Dir := Stream.Position;
        Stream.Write(NoOfDirs, sizeof(NoOfDirs));
        Stream.Write(D_RGB, sizeof(D_RGB));
        Stream.Write(NullString, sizeof(NullString));
        Stream.Seek(4, soFromBeginning);
        Stream.Write(O_Dir, sizeof(O_Dir));
      end;
    end;
  finally
    FreeMem(Header);
  end;
end;

procedure TfrImgFltSet.Localize;
begin
  Ok.Caption := frLoadStr(SOk);
  Cancel.Caption := frLoadStr(SCancel);
  Caption := frLoadStr(frRes + 1878);
  GroupPageRange.Caption := frLoadStr(frRes + 44);
  Label7.Caption := frLoadStr(frRes + 47);
  label1.Caption := frLoadStr(frRes + 48);
  GroupBox1.Caption := frLoadStr(frRes + 1879);
  Label2.Caption := frLoadStr(frRes + 1880);
  CropPage.Caption := frLoadStr(frRes + 1881);
  Mono.Caption := frLoadStr(frRes + 1882);
end;

procedure TfrImgFltSet.FormCreate(Sender: TObject);
begin
   Localize;
end;


end.

