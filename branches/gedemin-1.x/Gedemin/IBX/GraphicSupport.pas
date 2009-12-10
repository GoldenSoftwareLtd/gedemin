{********************************************************}
{                                                        }
{   JPEG-Support for Delphi (Design- and Runtime)        }
{   For DB.pas users                                     }
{                                                        }
{   Copyright (c) 2002 Robert Kuhlmann, Bremen, Germany  }
{        with quotations from unit DB.pas (VCL sources)  }
{        copyright (c) 1995, 02 Borland Corporation      }
{                                                        }
{    For questions or comments please contact            }
{    robert.kuhlmann1@ewetel.net                         }
{                                                        }
{********************************************************}

unit GraphicSupport;

interface

uses
  Classes, //TPersistent, TStrings and TComponent
  DB,      //where all TField descendants come from
  JPEG,    //the unit with TJPEGImage in it
  graphics;//to get access to TGraphic, TPicture and TBitmap

type
  { TEnhBlobField invents JPEG-support to TBlobField }
  TEnhBlobField = class(TBlobField)
  private
    { Check if blob contains a JPEG-Image }
    function GetHeader : Word;

    { This one enables JPEG-Images to be displayed in Components that expect
      a TBitmap as a result. }
    procedure SaveJPEGToBitmap(Bitmap : TBitmap);

    function GetGraphicClass : TGraphicClass;
  public
    { These two copied from the original TBlobField }
    procedure SaveToStrings(Strings: TStrings);
    procedure SaveToBitmap(Bitmap : TBitmap);

    { Modified AssignTo for JPEG support }
    procedure AssignTo(Dest: TPersistent); override;

    { SaveToPicture is new and handles both, bitmaps and JPEG }
    procedure SaveToPicture(Picture : TPicture); virtual;
    procedure SaveToAnyImage(aGraphic : TGraphic); virtual;
    constructor Create(AOwner: TComponent); override;
  end;

  { TEnhGraphicField is identical to TGraphicsField but iherits from
    TEnhBlobField instead of TBlobField }
  TEnhGraphicField = class(TEnhBlobField)
  public
    constructor Create(AOwner: TComponent); override;
  end;

procedure Register;

implementation

uses
  extctrls; //because we need to use TImage

type
  { TGraphic is a 100% copy from the Borland sources, with respect to their
    copyright: (c) 1995,99 Borland Corporation }
  TBGraphicHeader = record
    Count: Word;                { Fixed at 1 }
    HType: Word;                { Fixed at $0100 }
    Size: Longint;              { Size not including header }
  end;

procedure Register;
begin
  { Register gets called by the IDE, when the package is loaded via LoadPackage,
    so the replacement can happen here to ensure JPEG support at designtime. }
  TFieldClass(Pointer(@DefaultFieldClasses[ftBlob])^) := TEnhBlobField;
  TFieldClass(Pointer(@DefaultFieldClasses[ftGraphic])^) := TEnhGraphicField;
  RegisterClass(TEnhBlobField);
  RegisterClass(TEnhGraphicField);
end;

{ TEnhBlobField }

procedure TEnhBlobField.AssignTo(Dest: TPersistent);
begin
  if Dest is TStrings then
    SaveToStrings(TStrings(Dest))
  else
  if Dest is TBitmap then
  begin
    if not (GetGraphicClass = TJPEGImage) then
      SaveToBitmap(TBitmap(Dest))
    else
      SaveJPEGToBitmap(TBitmap(Dest));
  end else
  if Dest is TPicture then
    SaveToPicture(TPicture(Dest))
  else
  if Dest is TGraphic then
    SaveToAnyImage(TGraphic(Dest))
  else
  inherited AssignTo(Dest);
end;

function TEnhBlobField.GetHeader: Word;
var
  BlobStream: TStream;
begin
  Result := $FFFF;
  if not IsNull then
  begin
    BlobStream := DataSet.CreateBlobStream(Self, bmRead);
    try
      if BlobStream.Size >= SizeOf(Result) then
        BlobStream.Read(Result, SizeOf(Result));
    finally
      BlobStream.Free;
    end;
  end;
end;

procedure TEnhBlobField.SaveJPEGToBitmap(Bitmap: TBitmap);
var
  tmpImage : TImage;
  BlobStream: TStream;
  Graphic: TJPEGImage;
begin
  Assert(Bitmap <> nil);
  tmpImage := TImage.Create(nil);
  Graphic := TJPEGImage.Create;
  BlobStream := DataSet.CreateBlobStream(Self, bmRead);
  try
    Graphic.LoadFromStream(BlobStream);
    tmpImage.Picture.Graphic := Graphic;
    Bitmap.Canvas.Draw(0,0,tmpImage.Picture.Graphic); //may be stretched elsewhere
  finally
    BlobStream.Free;
    Graphic.Free;
    tmpImage.Free;
  end;
end;

{ SaveToBitmap is a 100% copy from the Borland sources, with respect to their
  copyright: (c) 1995,99 Borland Corporation }
procedure TEnhBlobField.SaveToBitmap(Bitmap: TBitmap);
var
  BlobStream: TStream;
  Size: Longint;
  Header: TBGraphicHeader;
begin
  Assert(Bitmap <> nil);
  BlobStream := DataSet.CreateBlobStream(Self, bmRead);
  try
    Size := BlobStream.Size;
    if Size >= SizeOf(TBGraphicHeader) then
    begin
      BlobStream.Read(Header, SizeOf(Header));
      if (Header.Count <> 1) or (Header.HType <> $0100) or
        (Header.Size <> Size - SizeOf(Header)) then
        BlobStream.Position := 0;
    end;
    Bitmap.LoadFromStream(BlobStream);
  finally
    BlobStream.Free;
  end;
end;

procedure TEnhBlobField.SaveToAnyImage(aGraphic: TGraphic);
var
  BlobStream: TStream;
begin
  Assert(aGraphic <> nil);
  BlobStream := DataSet.CreateBlobStream(Self, bmRead);
  try
    if BlobStream.Size > 0 then
      aGraphic.LoadFromStream(BlobStream);
  finally
    BlobStream.Free;
  end;
end;

procedure TEnhBlobField.SaveToPicture(Picture: TPicture);
var
  GraphicClass : TGraphicClass;
  Graphic: TGraphic;
begin
  Assert(Picture <> nil);
  GraphicClass := GetGraphicClass;
  if assigned(GraphicClass) then
  begin
    Graphic := GraphicClass.Create;
    try
      SaveToAnyImage(Graphic);
      Picture.Graphic := Graphic;
    finally
      Graphic.Free;
    end;
  end
  else
    Picture.Assign(Nil);
end;

{ SaveToStrings is a 100% copy from the Borland sources, with respect to their
  copyright:
       Copyright (c) 1995,99 Borland Corporation }
procedure TEnhBlobField.SaveToStrings(Strings: TStrings);
var
  BlobStream: TStream;
begin
  BlobStream := DataSet.CreateBlobStream(Self, bmRead);
  try
    Strings.LoadFromStream(BlobStream);
  finally
    BlobStream.Free;
  end;
end;

function TEnhBlobField.GetGraphicClass : TGraphicClass;
begin
  case GetHeader of
    $0000 : Result := TIcon;
    $4D42 : Result := TBitmap;
    $CDD7 : Result := TMetaFile;
    $D8FF : Result := TJPEGImage;
  else
    Result := nil; //unknown header
  end;
end;

constructor TEnhBlobField.Create(AOwner: TComponent);
begin
  inherited;

end;

{ TEnhGraphicField }

constructor TEnhGraphicField.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SetDataType(ftGraphic);
end;

initialization
  TFieldClass(Pointer(@DefaultFieldClasses[ftBlob])^) := TEnhBlobField;
  TFieldClass(Pointer(@DefaultFieldClasses[ftGraphic])^) := TEnhGraphicField;
finalization
  TFieldClass(Pointer(@DefaultFieldClasses[ftBlob])^) := TBlobField;
  TFieldClass(Pointer(@DefaultFieldClasses[ftGraphic])^) := TGraphicField;
end.

