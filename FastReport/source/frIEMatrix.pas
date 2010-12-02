
{******************************************}
{                                          }
{             FastReport v2.55             }
{        Intermediate Export Matrix        }
{         Copyright (c) 1998-2005          }
{           Alexander Fediachov            }
{                                          }
{******************************************}

unit frIEMatrix;

{$I fr.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, graphics, fr_Class, fr_utils, frProgr, Printers;

type
  TfrIEMObject = class;
  TfrIEMObjectList = class;
  TfrIEMStyle = class;

  TfrIEMatrix = class(TObject)
  private
    FIEMObjectList: TList;
    FIEMStyleList:  TList;
    FXPos: TList;
    FYPos: TList;
    FPages: TList;
    FWidth:     Integer;
    FHeight:    Integer;
    FMaxWidth:  Extended;
    FMaxHeight: Extended;
    FMinLeft:  Extended;
    FMinTop: Extended;
    FMatrix:    array of integer;
    FDeltaY: Extended;
    FShowProgress: Boolean;
    FMaxCellHeight: Extended;
    FMaxCellWidth: Extended;
    FInaccuracy: Extended;
    FProgress: TfrProgress;
    FRotatedImage: Boolean;
    FPlainRich: Boolean;
    FRichText: Boolean;
    FCropFillArea: Boolean;
    FFillArea: Boolean;
    FOptFrames: Boolean;
    FLeft: Extended;
    FTop: Extended;
    FDeleteHTMLTags: Boolean;
    FBackImage: Boolean;
    FBackground: Boolean;
    FReport: TfrReport;
    FPrintable: Boolean;
    function AddStyleInternal(Style: TfrIEMStyle): integer;
    function AddStyle(Obj: TfrView): integer;
    function AddInternalObject(Obj: TfrIEMObject; x, y, dx, dy: integer): integer;
    function IsMemo(Obj: TfrView): boolean;
    function IsLine(Obj: TfrView): boolean;
    function IsRect(Obj: TfrView): boolean;
    function QuickFind(aList: TList; aPosition: Extended; var Index: Integer): Boolean;
    procedure SetCell(x, y: integer; Value: integer);
    procedure FillArea(x, y, dx, dy: integer; Value: integer);
    procedure ReplaceArea(ObjIndex:integer; x, y, dx, dy: integer; Value: integer);
    procedure FindRectArea(x, y: integer; var dx, dy: integer);
    procedure CutObject(ObjIndex: Integer; x, y, dx, dy: integer);
    procedure CloneFrames(Obj1, Obj2: Integer);
    procedure AddPos(List: TList; Value: Extended);
    procedure OrderPosArray(List: TList; Vert: boolean);
    procedure OrderByCells;
    procedure Render;
    procedure Analyse;
    procedure OptimizeFrames;
  public
    constructor Create;
    destructor Destroy; override;
    function GetCell(x, y: integer): integer;
    function GetObjectById(ObjIndex: integer): TfrIEMObject;
    function GetStyleById(StyleIndex: integer): TfrIEMStyle;
    function GetXPosById(PosIndex: integer): Extended;
    function GetYPosById(PosIndex: integer): Extended;
    function GetObject(x, y: integer): TfrIEMObject;
    function GetStyle(x, y: integer): TfrIEMStyle;
    function GetCellXPos(x: integer): Extended;
    function GetCellYPos(y: integer): Extended;
    function GetStylesCount: Integer;
    function GetPagesCount: Integer;
    function GetObjectsCount: Integer;
    procedure Clear;
    procedure AddObject(Obj: TfrView);
    procedure AddPage(Orientation: TPrinterOrientation; Width: Extended;
              Height: Extended; LeftMargin: Extended; TopMargin: Extended;
              RightMargin: Extended; BottomMargin: Extended);
    procedure Prepare;
    procedure GetObjectPos(ObjIndex: integer; var x, y, dx, dy: integer);
    function GetPageBreak(Page: integer): Extended;
    function GetPageWidth(Page: integer): Extended;
    function GetPageHeight(Page: integer): Extended;
    function GetPageLMargin(Page: integer): Extended;
    function GetPageTMargin(Page: integer): Extended;
    function GetPageRMargin(Page: integer): Extended;
    function GetPageBMargin(Page: integer): Extended;
    function GetPageOrientation(Page: integer): TPrinterOrientation;
  published
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
    property MaxWidth: Extended read FMaxWidth;
    property MaxHeight: Extended read FMaxHeight;
    property MinLeft: Extended read FMinLeft;
    property MinTop: Extended read FMinTop;
    property ShowProgress: Boolean read FShowProgress write FShowProgress;
    property MaxCellHeight: Extended read FMaxCellHeight write FMaxCellHeight;
    property MaxCellWidth: Extended read FMaxCellWidth write FMaxCellWidth;
    property PagesCount: Integer read GetPagesCount;
    property StylesCount: Integer read GetStylesCount;
    property ObjectsCount: Integer read GetObjectsCount;
    property Inaccuracy: Extended read FInaccuracy write FInaccuracy;
    property RotatedAsImage: boolean read FRotatedImage write FRotatedImage;
    property RichText: boolean read FRichText write FRichText;
    property PlainRich: boolean read FPlainRich write FPlainRich;
    property AreaFill: boolean read FFillArea write FFillArea;
    property CropAreaFill: boolean read FCropFillArea write FCropFillArea;
    property FramesOptimization: boolean read FOptFrames write FOptFrames;
    property DeleteHTMLTags: Boolean read FDeleteHTMLTags write FDeleteHTMLTags;
    property Left: Extended read FLeft;
    property Top: Extended read FTop;
    property BackgroundImage: Boolean read FBackImage write FBackImage;
    property Background: Boolean read FBackground write FBackground;
    property Report: TfrReport read FReport write FReport;
    property Printable: Boolean read FPrintable write FPrintable;
  end;

  TfrIEMObject = class(TObject)
  private
    FMemo: TStrings;
    FURL: String;
    FStyleIndex: Integer;
    FStyle: TfrIEMStyle;
    FIsText: Boolean;
    FIsRichText: Boolean;
    FIsDialogObject: Boolean;
    FLeft: Extended;
    FTop: Extended;
    FWidth: Extended;
    FHeight: Extended;
    FImage: TBitmap;
    FParent: TfrIEMObject;
    FCounter: Integer;
    FLink: TObject;
    FDisplayFormat: String;
    FRTL: Boolean;
    FAnchor: String;
    procedure SetMemo(const Value: TStrings);
    procedure SetDisplayFormat(const Value: String);
  public
    constructor Create;
    destructor Destroy; override;
  published
    property Memo: TStrings read FMemo write SetMemo;
    property URL: String read FURL write FURL;
    property StyleIndex: Integer read FStyleIndex write FStyleIndex;
    property IsText: Boolean read FIsText write FIsText;
    property IsRichText: Boolean read FIsRichText write FIsRichText;
    property IsDialogObject: Boolean read FIsDialogObject write FIsDialogObject;
    property Left: Extended read FLeft write FLeft;
    property Top: Extended read FTop write FTop;
    property Width: Extended read FWidth write FWidth;
    property Height: Extended read FHeight write FHeight;
    property Image: TBitmap read FImage write FImage;
    property Parent: TfrIEMObject read FParent write FParent;
    property Style: TfrIEMStyle read FStyle write FStyle;
    property Counter: Integer read FCounter write FCounter;
    property Link: TObject read FLink write FLink;
    property DisplayFormat: String read FDisplayFormat write SetDisplayFormat;
    property RTL: Boolean read FRTL write FRTL;
    property Anchor: String read FAnchor write FAnchor;
  end;

  TfrIEMObjectList = class(TObject)
  public
    Obj: TfrIEMObject;
    x, y, dx, dy : Integer;
    Exist: Boolean;
    constructor Create;
    destructor Destroy; override;
  end;

  TfrIEMPos = class(TObject)
  public
    Value: Extended;
  end;

  TfrIEMPage = class(TObject)
  public
    Value: Extended;
    Orientation: TPrinterOrientation;
    Width: Extended;
    Height: Extended;
    LeftMargin: Extended;
    TopMargin:Extended;
    BottomMargin: Extended;
    RightMargin:Extended;
  end;
  TfrIEMStyle = class(TObject)
  public
    Font:       TFont;
    LineSpacing: Extended;
    Align:      Integer;
    FrameTyp:   Integer;
    FrameWidth: Single;
    FrameColor: TColor;
    FrameStyle: Integer;
    Color:      TColor;
    Rotation:   Integer;
    BrushStyle: TBrushStyle;
    GapX: Extended;
    GapY: Extended;
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Style: TfrIEMStyle);
  end;

implementation

uses FR_Rich, fr_shape
{$IFDEF RX}
, fr_rxrtf
{$ENDIF};

{ TfrIEMatrix }

const
  MAX_POS_SEARCH_DEPTH = 100;

constructor TfrIEMatrix.Create;
begin
  FIEMObjectList := TList.Create;
  FIEMStyleList := TList.Create;
  FXPos := TList.Create;
  FYPos := TList.Create;
  FPages := TList.Create;
  FMaxWidth := 0;
  FMaxHeight := 0;
  FMinLeft := 99999;
  FMinTop := 99999;
  FDeltaY := 0;
  FMaxCellHeight := 0;
  FShowProgress := true;
  FInaccuracy := 0;
  FRotatedImage := false;
  FPlainRich := true;
  FRichText := false;
  FFillArea := false;
  FCropFillArea := false;
  FOptFrames := false;
  FTop := 0;
  FLeft := 0;
  FBackImage := False;
  FBackground := False;
  FReport := nil;
  FPrintable := True;
end;

destructor TfrIEMatrix.Destroy;
begin
  Clear;
  FXPos.Free;
  FYPos.Free;
  FIEMObjectList.Free;
  FIEMStyleList.Free;
  FPages.Free;
  inherited;
end;

function TfrIEMatrix.AddInternalObject(Obj: TfrIEMObject; x, y, dx, dy: integer): integer;
var
  FObjItem: TfrIEMObjectList;
begin
  FObjItem := TfrIEMObjectList.Create;
  FObjItem.x := x;
  FObjItem.y := y;
  FObjItem.dx := dx;
  FObjItem.dy := dy;
  FObjItem.Obj := Obj;
  FIEMObjectList.Add(FObjItem);
  Result := FIEMObjectList.Count - 1;
end;

procedure TfrIEMatrix.AddObject(Obj: TfrView);
var
  dx, dy: Extended;
  FObj: TfrIEMObject;
  Memo: TfrMemoView;
  Line: TfrLineView;
  OldFrameWidth: Integer;
  MemStream: TMemoryStream;
begin
  OldFrameWidth := 0;

  FObj := TfrIEMObject.Create;
  FObj.StyleIndex := AddStyle(Obj);
  if FObj.StyleIndex <> -1 then
    FObj.Style := TfrIEMStyle(FIEMStyleList[FObj.StyleIndex]);
  FObj.URL :=Obj.Tag;
  if Obj.x >= 0 then
    FObj.Left := Obj.x
  else FObj.Left := 0;
  if Obj.y >= 0 then
    FObj.Top := FDeltaY + Obj.y
  else FObj.Top := FDeltaY;
  FObj.Width := Obj.dx;
  FObj.Height := Obj.dy;
  if IsMemo(Obj) then
  begin
    // Memo
    FObj.Memo := TfrMemoView(Obj).Memo;
    FObj.IsText := True;
    FObj.IsRichText := False;
    FObj.DisplayFormat := TfrMemoView(Obj).FormatStr;
  end
  else if ((Obj is TfrRichView) and (FRichText))
{$IFDEF RX}
 or ((Obj is TfrrxRichView) and (FRichText))
{$ENDIF}
   then
  begin
    FObj.IsText := True;
    FObj.IsRichText := True;
    if FPlainRich then
      TfrRichView(Obj).RichEdit.PlainText :=  True
    else
      TfrRichView(Obj).RichEdit.PlainText :=  False;
    MemStream := TMemoryStream.Create;
    TfrRichView(Obj).RichEdit.Lines.SaveToStream(MemStream);
    MemStream.Seek(0, soFromBeginning);
    FObj.Memo.LoadFromStream(MemStream);
    MemStream.Free;
  end
  else if IsLine(Obj) then
  begin
    // Line
    FObj.IsText := True;
    FObj.IsRichText := False;
    if FObj.Left > (FObj.Left + FObj.Width) then
    begin
      FObj.Left := FObj.Left + FObj.Width;
      FObj.Width := -FObj.Width;
    end;
    if FObj.Top > (FObj.Top + Obj.dy) then
    begin
      FObj.Top := FObj.Top + FObj.Height;
      FObj.Height := -FObj.Height;
    end;
    if FObj.Width = 0 then
      if FInaccuracy < 1 then FObj.Width := 1
      else FObj.Width := FInaccuracy;
    if FObj.Height = 0 then
      if FInaccuracy < 1 then FObj.Height := 1
      else FObj.Height := FInaccuracy;
  end
  else if IsRect(Obj) then
  begin
    if Obj.FillColor = clNone then
    begin
      // Rect as lines
      Line := TfrLineView.Create;
      Line.Name := 'Line';
      Line.FrameWidth := Obj.FrameWidth;
      Line.FrameColor := Obj.FrameColor;
      Line.FrameStyle := Obj.FrameStyle;
      Line.x := Obj.x;
      Line.y := Obj.y;
      Line.dx := Obj.dx;
      Line.dy := 0;
      AddObject(Line);
      Line.x := Obj.x;
      Line.y := Obj.y;
      Line.dx := 0;
      Line.dy := Obj.dy;
      AddObject(Line);
      Line.x := Obj.x;
      Line.y := Obj.y + Obj.dy;
      Line.dx := Obj.dx;
      Line.dy := 0;
      AddObject(Line);
      Line.x := Obj.x + Obj.dx;
      Line.y := Obj.y;
      Line.dx := 0;
      Line.dy := Obj.dy;
      AddObject(Line);
      Line.Free;
    end else
    begin
      // Rect as memo
      Memo := TfrMemoView.Create;
      Memo.FrameTyp := Obj.FrameTyp;
      Memo.Name := 'Rect';
      Memo.FillColor := Obj.FillColor;
      Memo.x := Obj.x;
      Memo.y := Obj.y;
      Memo.dx := Obj.dx;
      Memo.dy := Obj.dy;
      Memo.FrameTyp := frftTop + frftLeft + frftRight + frftBottom;
      Memo.Font.Size := 1;
      AddObject(Memo);
      Memo.Free;
    end;
    FObj.Free;
    Exit;
  end
  else begin
    // Bitmap
    if (Obj.FrameTyp <> 0) and (Obj.FrameWidth > 0) then
    begin
      OldFrameWidth := Obj.FrameTyp;
      Obj.FrameTyp := 0;
    end;
    FObj.IsText := False;
    FObj.IsRichText := False;
    dx := Obj.dx;
    dy := Obj.dy;
    if Round(dx) = 0 then
      dx := 1;
    if dx < 0 then
    begin
      dx := -dx;
      FObj.Left := FObj.Left - dx;
    end;
    if Round(dy) = 0 then
      dy := 1;
    if dy < 0 then
    begin
      dy := -dy;
      FObj.Top := FObj.Top - dy;
    end;
    FObj.Width := dx;
    FObj.Height := dy;
    FObj.Image := TBitmap.Create;
    FObj.Image.PixelFormat := pf24bit;
    FObj.Image.Height := Round(dy) + 1;
    FObj.Image.Width := Round(dx) + 1;
    Obj.x := 0;
    Obj.y := 0;
    TfrView(Obj).Draw(FObj.Image.Canvas);
    Obj.x := Round(FObj.Left);
    Obj.y := Round(FObj.Top - FDeltaY);
    if OldFrameWidth > 0 then
      Obj.FrameTyp := OldFrameWidth;
  end;
  if FObj.Top + FObj.Height > FMaxHeight then
    FMaxHeight := FObj.Top + FObj.Height;
  if FObj.Left + FObj.Width > FMaxWidth then
    FMaxWidth := FObj.Left + FObj.Width;
  if FObj.Left < FMinLeft then
    FMinLeft := FObj.Left;
  if FObj.Top < FMinTop then
    FMinTop := FObj.Top;
  if (FObj.Left < FLeft) or (FLeft = 0) then
    FLeft := FObj.Left;
  if (FObj.Top < FTop) or (FTop = 0) then
    FTop := FObj.Top;
  AddPos(FXPos, FObj.Left);
  AddPos(FXPos, FObj.Left + FObj.Width);
  AddPos(FYPos, FObj.Top);
  AddPos(FYPos, FObj.Top + FObj.Height);
  AddInternalObject(FObj, 0, 0, 1, 1);
end;

procedure TfrIEMatrix.AddPage(Orientation: TPrinterOrientation;
Width: Extended; Height: Extended; LeftMargin: Extended; TopMargin: Extended;
RightMargin: Extended; BottomMargin: Extended);
var
  Page: TfrIEMPage;
begin
  FDeltaY := FMaxHeight;
  Page := TfrIEMPage.Create;
  Page.Value := FMaxHeight;
  Page.Orientation := Orientation;
  Page.Width := Width;
  Page.Height := Height;
  Page.LeftMargin := LeftMargin;
  page.TopMargin := TopMargin;
  Page.RightMargin := LeftMargin;
  page.BottomMargin := TopMargin;
  FPages.Add(Page);
end;

procedure TfrIEMatrix.AddPos(List: TList; Value: Extended);
var
  Pos: TfrIEMPos;
  i, cnt: integer;
  Exist: Boolean;
begin
  Exist := False;
  if List.Count > MAX_POS_SEARCH_DEPTH then
    cnt := List.Count - MAX_POS_SEARCH_DEPTH
  else
    cnt := 0;
  for i := List.Count - 1 downto cnt do
    if TfrIEMPos(List[i]).Value = Value then
    begin
      Exist := True;
      break;
    end;
  if not Exist then
  begin
    Pos := TfrIEMPos.Create;
    Pos.Value := Value;
    List.Add(Pos);
  end;
end;

function TfrIEMatrix.AddStyle(Obj: TfrView): integer;
var
  Style: TfrIEMStyle;
begin
  Style := TfrIEMStyle.Create;
  if IsMemo(Obj) then
  begin
    Style.Font.Assign(TfrMemoView(Obj).Font);
    Style.Color := TfrMemoView(Obj).FillColor;
    Style.Align := TfrMemoView(Obj).Alignment;
    Style.LineSpacing := TfrMemoView(Obj).LineSpacing;
    Style.GapX := TfrMemoView(Obj).GapX;
    Style.GapY := TfrMemoView(Obj).GapY;
    Style.FrameTyp := TfrMemoView(Obj).FrameTyp;
    Style.FrameWidth := TfrMemoView(Obj).FrameWidth;
    Style.FrameColor := TfrMemoView(Obj).FrameColor;
    Style.FrameStyle := TfrMemoView(Obj).FrameStyle;
  end
  else if IsLine(Obj) then
  begin
    Style.Color := Obj.FillColor;
    if Obj.dx = 0 then
      Style.FrameTyp := frftLeft
    else if Obj.dy = 0 then
      Style.FrameTyp := frftTop
    else  Style.FrameTyp := 0;
    Style.FrameWidth := Obj.FrameWidth;
    Style.FrameColor := Obj.FrameColor;
    Style.FrameStyle := Obj.FrameStyle;
    Style.Font.Name := 'Arial';
    Style.Font.Size := 1;
  end
  else if IsRect(Obj) then
  begin
    Style.Free;
    Result := -1;
    Exit;
  end
  else begin
    Style.FrameTyp := 0;
    Style.Color := Obj.FillColor;
    Style.FrameWidth := Obj.FrameWidth;
    Style.FrameColor := Obj.FrameColor;
    Style.FrameStyle := Obj.FrameStyle;
    Style.FrameTyp := Obj.FrameTyp;
  end;
  Result := AddStyleInternal(Style);
end;

function TfrIEMatrix.AddStyleInternal(Style: TfrIEMStyle): integer;
var
  i: integer;
  Style2: TfrIEMStyle;
begin
  Result := -1;
  for i := 0 to FIEMStyleList.Count - 1 do
  begin
    Style2 := TfrIEMStyle(FIEMStyleList[i]);
    if (Style.Font.Color = Style2.Font.Color) and
       (Style.Font.Name = Style2.Font.Name) and
       (Style.Font.Size = Style2.Font.Size) and
       (Style.Font.Style = Style2.Font.Style) and
       (Style.LineSpacing = Style2.LineSpacing) and
       (Style.GapX = Style2.GapX) and
       (Style.GapY = Style2.GapY) and
       (Style.Align = Style2.Align) and
       (Style.FrameTyp = Style2.FrameTyp) and
       (Style.FrameWidth = Style2.FrameWidth) and
       (Style.FrameColor = Style2.FrameColor) and
       (Style.FrameStyle = Style2.FrameStyle) and
       (Style.Rotation = Style2.Rotation) and
       (Style.Color = Style2.Color) then
    begin
      Result := i;
      break;
    end;
  end;
  if Result = -1 then
  begin
    FIEMStyleList.Add(Style);
    Result := FIEMStyleList.Count - 1;
  end else
    Style.Free;
end;

procedure TfrIEMatrix.Analyse;
var
  i, j, k: integer;
  dx, dy: integer;
  obj: TfrIEMObjectList;
begin
  for i := 0 to FHeight - 1 do
    for j := 0 to FWidth - 1 do
    begin
      k := GetCell(j, i);
      if k <> -1 then
      begin
        obj := TfrIEMObjectList(FIEMObjectList[k]);
        if not obj.Exist then
        begin
          FindRectArea(j, i, dx, dy);
          if (obj.x <> j) or (obj.y <> i) or
             (obj.dx <> dx) or (obj.dy <> dy) then
          begin
            if not Obj.Exist then
              CutObject(k, j, i, dx, dy)
          end else
            Obj.Exist := true;
        end;
      end;
    end;
  if FShowProgress then
    FProgress.Tick;
end;

procedure TfrIEMatrix.Clear;
var
  i : Integer;
begin
  for i := 0 to FIEMObjectList.Count - 1 do
    TfrIEMObjectList(FIEMObjectList[i]).Free;
  FIEMObjectList.Clear;
  for i := 0 to FIEMStyleList.Count - 1 do
    TfrIEMStyle(FIEMStyleList[i]).Free;
  FIEMStyleList.Clear;
  for i := 0 to FXPos.Count - 1 do
    TfrIEMPos(FXPos[i]).Free;
  FXPos.Clear;
  for i := 0 to FYPos.Count - 1 do
    TfrIEMPos(FYPos[i]).Free;
  FYPos.Clear;
  for i := 0 to FPages.Count - 1 do
    TfrIEMPage(FPages[i]).Free;
  FPages.Clear;
  SetLength(FMatrix, 0);
  FDeltaY := 0;
end;

procedure TfrIEMatrix.CloneFrames(Obj1, Obj2: Integer);
var
  FOld, FNew: TfrIEMObject;
  FrameTyp: Integer;
  NewStyle: TfrIEMStyle;
begin
  FOld := TfrIEMObjectList(FIEMObjectList[Obj1]).Obj;
  FNew := TfrIEMObjectList(FIEMObjectList[Obj2]).Obj;
  if (FOld.Style <> nil) and (FNew.Style <> nil) then
  begin
  FrameTyp := 0;
  if ((frftTop and FOld.Style.FrameTyp) > 0) and (FOld.Top = FNew.Top) then
    FrameTyp := FrameTyp + frftTop;
  if ((frftLeft and FOld.Style.FrameTyp) > 0) and (FOld.Left = FNew.Left) then
    FrameTyp := FrameTyp + frftLeft;
  if ((frftBottom and FOld.Style.FrameTyp) > 0) and
     ((FOld.Top + FOld.Height) = (FNew.Top + FNew.Height)) then
    FrameTyp := FrameTyp + frftBottom;
  if ((frftRight and FOld.Style.FrameTyp) > 0) and
     ((FOld.Left + FOld.Width) = (FNew.Left + FNew.Width)) then
    FrameTyp := FrameTyp + frftRight;
  if FrameTyp <> FNew.Style.FrameTyp then
  begin
    NewStyle := TfrIEMStyle.Create;
    NewStyle.FrameTyp := FrameTyp;
    NewStyle.FrameWidth := FOld.Style.FrameWidth;
    NewStyle.FrameColor := FOld.Style.FrameColor;
    NewStyle.FrameStyle := FOld.Style.FrameStyle;
    NewStyle.Font.Assign(FOld.Style.Font);
    NewStyle.LineSpacing := FOld.Style.LineSpacing;
    NewStyle.GapX := FOld.Style.GapX;
    NewStyle.GapY := FOld.Style.GapY;
    NewStyle.Align := FOld.Style.Align;
    NewStyle.Color := FOld.Style.Color;
    NewStyle.Rotation := FOld.Style.Rotation;
    NewStyle.BrushStyle := FOld.Style.BrushStyle;
    FNew.StyleIndex := AddStyleInternal(NewStyle);
    FNew.Style := TfrIEMStyle(FIEMStyleList[FNew.StyleIndex]);
  end;
end;
end;

procedure TfrIEMatrix.CutObject(ObjIndex, x, y, dx, dy: integer);
var
  Obj: TfrIEMObject;
  NewObject: TfrIEMObject;
  NewIndex: Integer;
  fdx, fdy: Extended;
begin
  Obj := TfrIEMObjectList(FIEMObjectList[ObjIndex]).Obj;
  NewObject := TfrIEMObject.Create;
  NewObject.StyleIndex := Obj.StyleIndex;
  NewObject.Style := Obj.Style;
  NewObject.Left := TfrIEMPos(FXPos[x]).Value;
  NewObject.Top := TfrIEMPos(FYPos[y]).Value;
  NewObject.Width := TfrIEMPos(FXPos[x + dx]).Value - TfrIEMPos(FXPos[x]).Value;
  NewObject.Height := TfrIEMPos(FYPos[y + dy]).Value - TfrIEMPos(FYPos[y]).Value;
  NewObject.Parent := Obj;
  fdy := Obj.Top + Obj.Height - NewObject.Top;
  fdx := Obj.Left + Obj.Width - NewObject.Left;
  if (fdy > Obj.Height / 3) and (fdx > Obj.Width / 3) then
  begin
    NewObject.Image := Obj.Image;
    NewObject.Link := Obj.Link;
    NewObject.IsText := Obj.IsText;
    NewObject.Memo := Obj.Memo;
    Obj.Memo.Clear;
    Obj.IsText := True;
    Obj.Link := nil;
    Obj.Image := nil;
  end;
  NewIndex := AddInternalObject(NewObject, x, y, dx, dy);
  ReplaceArea(ObjIndex, x, y, dx, dy, NewIndex);
  CloneFrames(ObjIndex, NewIndex);
  TfrIEMObjectList(FIEMObjectList[NewIndex]).Exist := True;
end;


procedure TfrIEMatrix.FillArea(x, y, dx, dy, Value: integer);
var
  i, j: integer;
begin
  for i := y to y + dy - 1 do
    for j := x to x + dx - 1 do
      SetCell(j, i, Value);
end;

procedure TfrIEMatrix.FindRectArea(x, y: integer; var dx, dy: integer);
var
  px, py: integer;
  Obj: integer;
begin
  Obj := GetCell(x, y);
  px := x;
  py := y;
  dx := 0;
  while GetCell(px, py) = Obj do
  begin
    while GetCell(px, py) = Obj do
      Inc(px);
    if dx = 0 then
      dx := px - x
    else if px - x < dx then
        break;
    Inc(py);
    px := x;
  end;
  dy := py - y;
end;

function TfrIEMatrix.GetCell(x, y: integer): integer;
begin
  if (x < FWidth) and (y < FHeight) and (x >= 0) and (y >= 0) then
    Result := FMatrix[FWidth * y + x]
  else Result := -1;
end;

function TfrIEMatrix.GetCellXPos(x: integer): Extended;
begin
  Result := TfrIEMPos(FXPos[x]).Value;
end;

function TfrIEMatrix.GetCellYPos(y: integer): Extended;
begin
  Result := TfrIEMPos(FYPos[y]).Value;
end;

function TfrIEMatrix.GetObject(x, y: integer): TfrIEMObject;
var
  i: integer;
begin
  i := GetCell(x, y);
  if i = -1 then
    Result := nil
  else
    Result := TfrIEMObjectList(FIEMObjectList[i]).Obj;
end;

function TfrIEMatrix.GetObjectById(ObjIndex: integer): TfrIEMObject;
begin
  if ObjIndex < FIEMObjectList.Count then
    Result := TfrIEMObjectList(FIEMObjectList[ObjIndex]).Obj
  else
    Result := nil;
end;

procedure TfrIEMatrix.GetObjectPos(ObjIndex: integer; var x, y, dx,
  dy: integer);
begin
  x := TfrIEMObjectList(FIEMObjectList[ObjIndex]).x;
  y := TfrIEMObjectList(FIEMObjectList[ObjIndex]).y;
  dx := TfrIEMObjectList(FIEMObjectList[ObjIndex]).dx;
  dy := TfrIEMObjectList(FIEMObjectList[ObjIndex]).dy;
end;

function TfrIEMatrix.GetObjectsCount: Integer;
begin
  Result := FIEMObjectList.Count;
end;

function TfrIEMatrix.GetPageBreak(Page: integer): Extended;
begin
  if Page < FPages.Count then
    Result := TfrIEMPage(FPages[Page]).Value
  else
    Result := 0;
end;

function TfrIEMatrix.GetPageHeight(Page: integer): Extended;
begin
  if Page < FPages.Count then
    Result := TfrIEMPage(FPages[Page]).Height
  else
    Result := 0;
end;

function TfrIEMatrix.GetPageLMargin(Page: integer): Extended;
begin
  if Page < FPages.Count then
    Result := TfrIEMPage(FPages[Page]).LeftMargin
  else
    Result := 0;
end;

function TfrIEMatrix.GetPageTMargin(Page: integer): Extended;
begin
  if Page < FPages.Count then
    Result := TfrIEMPage(FPages[Page]).TopMargin
  else
    Result := 0;
end;

function TfrIEMatrix.GetPageWidth(Page: integer): Extended;
begin
  if Page < FPages.Count then
    Result := TfrIEMPage(FPages[Page]).Width
  else
    Result := 0;
end;

function TfrIEMatrix.GetPageBMargin(Page: integer): Extended;
begin
  if Page < FPages.Count then
    Result := TfrIEMPage(FPages[Page]).BottomMargin
  else
    Result := 0;
end;

function TfrIEMatrix.GetPageRMargin(Page: integer): Extended;
begin
  if Page < FPages.Count then
    Result := TfrIEMPage(FPages[Page]).RightMargin
  else
    Result := 0;
end;

function TfrIEMatrix.GetPageOrientation(Page: integer): TPrinterOrientation;
begin
  if Page < FPages.Count then
    Result := TfrIEMPage(FPages[Page]).Orientation
  else
    Result := poPortrait;
end;
function TfrIEMatrix.GetPagesCount: Integer;
begin
  Result := FPages.Count;
end;

function TfrIEMatrix.GetStyle(x, y: integer): TfrIEMStyle;
var
  Obj: TfrIEMObject;
begin
  Obj := GetObject(x, y);
  if Obj <> nil then
    Result := TfrIEMStyle(FIEMStyleList[Obj.StyleIndex])
  else
    Result := nil;
end;

function TfrIEMatrix.GetStyleById(StyleIndex: integer): TfrIEMStyle;
begin
  Result := TfrIEMStyle(FIEMStyleList[StyleIndex]);
end;

function TfrIEMatrix.GetStylesCount: Integer;
begin
  Result := FIEMStyleList.Count;
end;

function TfrIEMatrix.GetXPosById(PosIndex: integer): Extended;
begin
  Result := TfrIEMPos(FXPos[PosIndex]).Value;
end;

function TfrIEMatrix.GetYPosById(PosIndex: integer): Extended;
begin
  Result := TfrIEMPos(FYPos[PosIndex]).Value;
end;

function TfrIEMatrix.IsMemo(Obj: TfrView): boolean;
begin
  Result := (Obj is TfrMemoView);
end;

function TfrIEMatrix.IsLine(Obj: TfrView): boolean;
begin
  Result := (Obj is TfrLineView) and ((Obj.dx = 0) or (Obj.dy = 0));
end;

function TfrIEMatrix.IsRect(Obj: TfrView): boolean;
begin
  Result := (Obj is TfrShapeView) and (TfrShapeView(Obj).ShapeType = skRectangle);
end;
procedure TfrIEMatrix.OptimizeFrames;
var
  x, y: Integer;
  Obj, PrevObj: TfrIEMObject;
  FrameTyp: Integer;
  Style: TfrIEMStyle;
begin
  for y := 0 to Height - 1 do
    for x := 0 to Width - 1 do
    begin
      Obj := GetObject(x, y);
      if Obj = nil then continue;
      FrameTyp := Obj.Style.FrameTyp;
      if ((frftTop and FrameTyp) <> 0) and (y > 0) then
      begin
        PrevObj := GetObject(x, y - 1);
        if (PrevObj <> nil) and (PrevObj <> Obj) then
          if ((frftBottom and PrevObj.Style.FrameTyp) <> 0) and
            (PrevObj.Style.FrameWidth = Obj.Style.FrameWidth) and
            (PrevObj.Style.FrameColor = Obj.Style.FrameColor) then
            FrameTyp := FrameTyp - frftTop;
      end;
      if ((frftLeft and FrameTyp) <> 0) and (x > 0) then
      begin
        PrevObj := GetObject(x - 1, y);
        if (PrevObj <> nil) and (PrevObj <> Obj) then
          if ((frftRight and PrevObj.Style.FrameTyp) <> 0) and
            (PrevObj.Style.FrameWidth = Obj.Style.FrameWidth) and
            (PrevObj.Style.FrameColor = Obj.Style.FrameColor) then
            FrameTyp := FrameTyp - frftLeft;
      end;
      if FrameTyp <> Obj.Style.FrameTyp then
      begin
        Style := TfrIEMStyle.Create;
        Style.Assign(Obj.Style);
        Style.FrameTyp := FrameTyp;
        Obj.StyleIndex := AddStyleInternal(Style);
        Obj.Style := TfrIEMStyle(FIEMStyleList[Obj.StyleIndex]);
      end;
    end;
end;

function TfrIEMatrix.QuickFind(aList: TList; aPosition: Extended; var Index: Integer): Boolean;
var
  L, H, I: Integer;
  C: Extended;
begin
  Result := False;
  L := 0;
  H := aList.Count - 1;
  while L <= H do begin
    I := (L + H) shr 1;
    C := TfrIEMPos(aList[I]).Value - aPosition;
    if C < 0 then
      L := I + 1
    else begin
      H := I - 1;
      if C = 0 then begin
        Result := True;
        L := I
      end
    end
  end;
  Index := L
end;
procedure TfrIEMatrix.OrderByCells;
var
  i, j, k, dx, dy: integer;
  curx, cury: Extended;
  obj: TfrIEMObject;
begin
  OrderPosArray(FXPos, false);
  OrderPosArray(FYPos, true);
  for i := 0 to FIEMObjectList.Count - 1 do
  begin
    dx := 0; dy := 0;
    obj := TfrIEMObjectList(FIEMObjectList[i]).Obj;
    QuickFind(FXPos, Obj.Left, j);
    if j < FXPos.Count then
      begin
        TfrIEMObjectList(FIEMObjectList[i]).x := j;
        curx := Obj.Left;
        k := j;
        while (Obj.Left + Obj.Width > curx) and (k < FXPos.Count - 1) do
        begin
          Inc(k);
          curx := TfrIEMPos(FXPos[k]).Value;
          Inc(dx);
        end;
        TfrIEMObjectList(FIEMObjectList[i]).dx := dx;
      end;
    QuickFind(FYPos, Obj.Top, j);
    if j < FYPos.Count then
      begin
        TfrIEMObjectList(FIEMObjectList[i]).y := j;
        cury := Obj.Top;
        k := j;
        while (Obj.Top + Obj.Height > cury) and (k < FYPos.Count - 1) do
        begin
          Inc(k);
          cury := TfrIEMPos(FYPos[k]).Value;
          Inc(dy);
        end;
        TfrIEMObjectList(FIEMObjectList[i]).dy := dy;
      end;
  end;
  if FShowProgress then
    FProgress.Tick;
end;

function SortPosCompare(Item1, Item2: Pointer): Integer;
begin
  if TfrIEMPos(Item1).Value < TfrIEMPos(Item2).Value then
    Result := -1
  else if TfrIEMPos(Item1).Value > TfrIEMPos(Item2).Value then
    Result := 1
  else
    Result := 0;
end;

procedure TfrIEMatrix.OrderPosArray(List: TList; Vert: boolean);
var
  i, j, Cnt: integer;
  pos1, pos2: Extended;
  Reorder: Boolean;
begin
  List.Sort(SortPosCompare);
  if FShowProgress then
    FProgress.Tick;
  i := 0;
  while i <= List.Count - 2 do
  begin
    pos1 := TfrIEMPos(List[i]).Value;
    pos2 := TfrIEMPos(List[i + 1]).Value;
    if pos2 - pos1 < FInaccuracy then
    begin
      TfrIEMPos(List[i]).Free;
      List.Delete(i);
    end else Inc(i);
  end;
  if FShowProgress then
    FProgress.Tick;
  Reorder := False;
  if Vert and (FMaxCellHeight > 0) then
    for i := 0 to List.Count - 2 do
    begin
      pos1 := TfrIEMPos(List[i]).Value;
      pos2 := TfrIEMPos(List[i + 1]).Value;
      if pos2 - pos1 > FMaxCellHeight then
      begin
        Cnt := Round(Int((pos2 - pos1) / FMaxCellHeight));
        for j := 1 to Cnt do
          AddPos(List, pos1 + FMaxCellHeight * j);
        Reorder := True;
      end;
    end;
  if FShowProgress then
    FProgress.Tick;
  if (not Vert) and (FMaxCellWidth > 0) then
    for i := 0 to List.Count - 2 do
    begin
      pos1 := TfrIEMPos(List[i]).Value;
      pos2 := TfrIEMPos(List[i + 1]).Value;
      if pos2 - pos1 > FMaxCellWidth then
      begin
        Cnt := Round(Int((pos2 - pos1) / FMaxCellWidth));
        for j := 1 to Cnt do
          AddPos(List, pos1 + FMaxCellWidth * j);
        Reorder := True;
      end;
    end;
  if Reorder then
    List.Sort(SortPosCompare);
  if FShowProgress then
    FProgress.Tick;
end;

procedure TfrIEMatrix.Prepare;
var
  Style: TfrIEMStyle;
  FObj: TfrIEMObject;
  FObjItem: TfrIEMObjectList;

begin
  if FShowProgress then
  begin
    FProgress := TfrProgress.Create(nil);
    FProgress.Execute(11, 'Prepare export', false, true);
  end;
  if FFillArea then
  begin
    Style := TfrIEMStyle.Create;
    Style.FrameTyp := 0;
    Style.Color := clWhite;
    FObj := TfrIEMObject.Create;
    FObj.StyleIndex := AddStyleInternal(Style);
    FObj.Style := Style;
    if FCropFillArea then
    begin
      FObj.Left := FMinLeft;
      FObj.Top := FMinTop;
    end
    else
    begin
      FObj.Left := 0;
      FObj.Top := 0;
    end;
    FObj.Width := MaxWidth;
    FObj.Height := MaxHeight;
    FObj.IsText := True;
    AddPos(FXPos, 0);
    AddPos(FYPos, 0);
    FObjItem := TfrIEMObjectList.Create;
    FObjItem.x := 0;
    FObjItem.y := 0;
    FObjItem.dx := 1;
    FObjItem.dy := 1;
    FObjItem.Obj := FObj;
    FIEMObjectList.Insert(0, FObjItem);
  end;
  OrderByCells;
  FWidth := FXPos.Count;
  FHeight := FYPos.Count;
  Render;
  Analyse;
  if FOptFrames then
    OptimizeFrames;
  if FShowProgress then
    FProgress.Free;
end;

procedure TfrIEMatrix.Render;
var
  i, old: integer;
  obj: TfrIEMObjectList;
  Style: TfrIEMStyle;
  OldColor: TColor;
begin
  SetLength(FMatrix, FWidth * FHeight);
  FillArea(0, 0, FWidth, FHeight, -1);
  for i := 0 to FIEMObjectList.Count - 1 do
  begin
    obj := TfrIEMObjectList(FIEMObjectList[i]);
    if (Obj.Obj.Style <> nil) and (Obj.Obj.Style.Color = clNone) then
    begin
      old := GetCell(obj.x, obj.y);
      if old <> -1 then
      begin
        OldColor := TfrIEMObjectList(FIEMObjectList[Old]).Obj.Style.Color;
        if (OldColor <> Obj.Obj.Style.Color) and (OldColor <> Obj.Obj.Style.Font.Color) then
        begin
          Style := TfrIEMStyle.Create;
          Style.Assign(Obj.Obj.Style);
          Style.Color := OldColor;
          Obj.Obj.StyleIndex := AddStyleInternal(Style);
          Obj.Obj.Style := TfrIEMStyle(FIEMStyleList[Obj.Obj.StyleIndex]);
        end;
      end;
    end;
    FillArea(obj.x, obj.y, obj.dx, obj.dy, i);
  end;
  if FShowProgress then
    FProgress.Tick;
end;

procedure TfrIEMatrix.ReplaceArea(ObjIndex, x, y, dx, dy,
  Value: integer);
var
  i, j: integer;
begin
  for i := y to y + dy - 1 do
    for j := x to x + dx - 1 do
      if GetCell(j, i) = ObjIndex then
        SetCell(j, i, Value);
end;

procedure TfrIEMatrix.SetCell(x, y, Value: integer);
begin
  if (x < FWidth) and (y < FHeight) and (x >= 0) and (y >= 0) then
    FMatrix[FWidth * y + x] := Value;
end;

{ TfrIEMObjectList }

constructor TfrIEMObjectList.Create;
begin
  Exist := False;
end;

destructor TfrIEMObjectList.Destroy;
begin
  Obj.Free;
  inherited;
end;

{ TfrIEMStyle }

procedure TfrIEMStyle.Assign(Style: TfrIEMStyle);
begin
  Font.Assign(Style.Font);
  LineSpacing := Style.LineSpacing;
  GapX := Style.GapX;
  GapY := Style.GapY;
  Align := Style.Align;
  FrameTyp := Style.FrameTyp;
  FrameWidth := Style.FrameWidth;
  FrameColor := Style.FrameColor;
  FrameStyle := Style.FrameStyle;
  Color := Style.Color;
  Rotation := Style.Rotation;
  BrushStyle := Style.BrushStyle;
end;

constructor TfrIEMStyle.Create;
begin
  Font := TFont.Create;
end;

destructor TfrIEMStyle.Destroy;
begin
  Font.Free;
  inherited;
end;

{ TfrIEMObject }

constructor TfrIEMObject.Create;
begin
  FMemo := TStringList.Create;
  FDisplayFormat := '';
  Left := 0;
  Top := 0;
  Image := nil;
  FParent := nil;
  FCounter := 0;
  FIsText := true;
  FIsRichText := false;
  FIsDialogObject := False;
  FLink := nil;
end;

destructor TfrIEMObject.Destroy;
begin
  FMemo.Free;
  if Assigned(FImage) then
    FImage.Free;
  inherited;
end;

procedure TfrIEMObject.SetDisplayFormat(const Value: String);
begin
  FDisplayFormat := Value;
end;
procedure TfrIEMObject.SetMemo(const Value: TStrings);
begin
  FMemo.Assign(Value);
end;

end.
