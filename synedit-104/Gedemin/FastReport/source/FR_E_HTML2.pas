{******************************************}
{                                          }
{             FastReport v2.53             }
{            HTML export filter            }
{                                          }
{  Copyright (c) 2003 by Kirichenko V.A.   }
{ http://fr2html.narod.ru, fr2html@mail.ru }
{                                          }
{******************************************}

unit FR_E_HTML2;


interface

{$I Fr.inc}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Forms, StdCtrls,
  FR_Class, Controls {$IFDEF Delphi5}, Contnrs {$ENDIF};

type
  THStyle = class;
  THPage = class;
  THAlign = (haLeft, haCenter, haRight);
  THAligns = set of THAlign;
  TViewType = (vtFrame, vtText, vtFramedText);

  THFrame = class
  public
    Top    : integer;
    Left   : integer;
    //Width  : integer;
    //Height : integer;
    Style  : THStyle;
    function GetHTML(const BaseTop, BaseLeft: integer): string; virtual;
    function GetContent: string; virtual;
    function GetWidth: integer; virtual;
    function GetHeight: integer; virtual;
  end;

  TGraphicType = (gtBmp, gtJpg);

  THGraphic = class(THFrame)
  public
    FID          : integer;
    FPage        : THPage;
    FStream      : TMemoryStream;
    FGraphicType : TGraphicType;
    constructor Create;
    destructor Destroy; override;
    function GetHTML(const BaseTop, BaseLeft: integer): string; override;
  end;

  THText = class(THFrame)
  public
    FText   : string;
    FWidth  : integer;
    FHeight : integer;
    function GetContent: string; override;
    function GetHTML(const BaseTop, BaseLeft: integer): string; override;
    function GetWidth: integer; override;
    function GetHeight: integer; override;
  end;

  THFramedText = class(THFrame)
  private
    FStrings : TStringList;
  public
    FWordWrap : boolean;
    constructor Create;
    destructor Destroy; override;
    function GetContent: string; override;
    procedure AddString(Str: string);
  end;

  TfrHTML2Export = class;

  THPage = class
  private
    ID             : integer;
    Owner          : TfrHTML2Export;
    Width          : integer;
    FHeight        : integer;
    LeftMargin     : integer;
    RightMargin    : integer;
    BottomMargin   : integer;
    TopMargin      : integer;
    FTextList      : TList;
    FShowMargins   : boolean;
    FLastGraphicID : integer;
    procedure UpdateSize(const ABottom, ARight: integer);
    function GetHeight: integer;
  public
    constructor Create(const AOwner: TfrHTML2Export; const FRPage: TfrPage;
      const AID: integer);
    destructor Destroy; override;
    procedure AddItem(const HFrame: THFrame);
    function GetHTML(BaseTop, BaseLeft: integer): string;
    function GetName: string;
    property Height: integer read GetHeight;
  end;

  TNavigatorPosition = (npTop, npBottom);
  TNavigatorPositions = set of TNavigatorPosition;

  TNavigatorItem = class
  public
    MinPage    : integer;
    MaxPage    : integer;
    LeftArrow  : boolean;
    RightArrow : boolean;
  end;

  THNavigator = class(TPersistent)
  private
    FPosition    : TNavigatorPositions;
    FAlign       : THAlign;
    FFillColor   : TColor;
    FFont        : TFont;
    FFilter      : TfrHTML2Export;
    FInFrame     : boolean;
    FBorder      : TColor;
    FItems       : TList;
    FTextBitmap  : TBitmap;
    FWideInFrame : boolean;
    procedure SetFont(const Value: TFont);
    function TextWidth(const Text: string): integer;
  protected
    procedure Loaded;
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create(AFilter: TfrHTML2Export);
    destructor Destroy; override;
    function GetHTML(const PageID: integer;
      const BaseTop, BaseLeft, Width: integer; const ForFrame: boolean): string;
    function GetStyleHTML(ForPrinting: boolean): string;
    function GetStyleName: string;
    function GetHeight: integer;
    procedure BuildItems(AWidth: integer);
  published
    property Position    : TNavigatorPositions read FPosition write FPosition;
    property Font        : TFont read FFont write SetFont;
    property Align       : THAlign read FAlign write FAlign default haCenter;
    property FillColor   : TColor read FFillColor write FFillColor default $F5F5F5;
    property InFrame     : boolean read FInFrame write FInFrame;
    property Border      : TColor read FBorder write FBorder default $A3A3A3;
    property WideInFrame : boolean read FWideInFrame write FWideInFrame;
  end;

  TfrHTML2Export = class(TfrExportFilter)
  private
    FExportPictures  : boolean;
    FStyles          : TList;
    FMultiPage       : boolean;
    FScale           : double;
    {$IFDEF JPEG}
    FAllJPEG         : boolean;
    {$ENDIF}
    FCurrPage        : THPage;
    FPages           : TList;
    FImageFolder     : string;
    FImageFolderFull : string;
    FTextBitmap      : TBitmap;
    FNavigator       : THNavigator;
    FLastFramedText  : THFramedText;
    FLastView        : TfrView;
    function GetStyle(const ViewType: TViewType; const View: TfrView): THStyle;
    function GetImageFolderFull: string;
    function GetImageFolder: string;
    procedure SetNavigator(const Value: THNavigator);
    procedure SaveStringToFile(const AFileName, Str: string);
    procedure CheckFolder;
  protected
    procedure ClearLines; override;
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ShowModal: Word; override;
    procedure OnData(x, y: integer; View: TfrView); override;
    procedure OnText(DrawRect: TRect; x, y: Integer;
      const text: String; FrameTyp: Integer; View: TfrView); override;
    procedure OnBeginDoc; override;
    procedure OnEndDoc; override;
    procedure OnBeginPage; override;
  published
    property ExportPictures  : boolean read FExportPictures
      write FExportPictures default true;
    property MultiPage       : boolean read FMultiPage write FMultiPage default false;
    property Scale           : double read FScale write FScale;
    {$IFDEF JPEG}
    property AllJPEG         : boolean read FAllJPEG write FAllJPEG default false;
    {$ENDIF}
    property ImageFolderFull : string read GetImageFolderFull;
    property ImageFolder     : string read GetImageFolder;
    property Navigator       : THNavigator read FNavigator write SetNavigator;
  end;

  THTMLBorder = (hbRight, hbBottom, hbLeft, hbTop);
  THTMLBorders = set of THTMLBorder;

  {TFrameSize = class
  public
    Width  : integer;
    Height : integer;
    function Equals(const AFrameSize: TFrameSize): boolean;
  end;}

  THStyle = class
  protected
    FID         : integer;
    FCount      : integer;
    FDefault    : boolean;
    FTextBitmap : TBitmap;
    FWidth      : integer;
    FHeight     : integer;
    FSizes      : TList;
    function GetName(Clear: boolean): string;
  public
    class function TextDecorName(const AFont: TFont): string;
    class function FontStyleName(const AFont: TFont): string;
    class function FontWeightName(const AFont: TFont): string;
    class function TextAlignName(const AAlign: THAlign): string;
    class function GetHtmlColor(const AColor: TColor): string;
    class function CorrectColor(AColor: TColor): TColor;
    constructor Create(const View: TfrView; const AID: integer;
      const Scale: double);
    destructor Destroy; override;
    function Equals(const AStyle: THStyle): boolean; virtual;
    function GetHtml: string; virtual; abstract;
    procedure IncrementCount;
    procedure SetDefault;
    function TextWidth(const Text: string): integer;
  end;

  THStyleFrame = class(THStyle)
  protected
    FBorders     : THTMLBorders;
    FBorderWidth : integer;
    FBorderColor : integer;
    FBorderStyle : integer;
    FFillColor   : integer;
    function BorderStyle(const AFrameStyle: integer;
      const ABorder: THTMLBorder): string;
  public
    constructor Create(const View: TfrView; const AID: integer;
      const Scale: double);
    function Equals(const AStyle: THStyle): boolean; override;
    function GetHtml: string; override;
  end;

  THStyleText = class(THStyle)
  private
    FFont        : TFont;
    FFontHeight  : integer;
    FGapX        : integer;
    FGapY        : integer;
    FLineSpacing : integer;
    function GetPaddings: string;
  public
    constructor Create(const View: TfrView; const AID: integer;
      const Scale: double);
    destructor Destroy; override;
    function Equals(const AStyle: THStyle): boolean; override;
    function GetHtml: string; override;
  end;

  THStyleFramedText = class(THStyleFrame)
  private
    FFont        : TFont;
    FGapX        : integer;
    FGapY        : integer;
    FTextAlign   : integer;
    FFontHeight  : integer;
    FLineSpacing : integer;
    FWordWrap    : boolean;
    //FWordBreak   : boolean;
    function HorAlignName: string;
    function GetPaddings: string;
    //function WhiteSpaceName: string;
    //function OverflowName: string;
  public
    constructor Create(const View: TfrView; const AID: integer;
      const Scale: double);
    destructor Destroy; override;
    function Equals(const AStyle: THStyle): boolean; override;
    function GetHtml: string; override;
    function IsTextJustify: boolean;
  end;

  TfrHTML2ExportForm = class(TForm)
    GroupBox1 : TGroupBox;
    Label1    : TLabel;
    Button1   : TButton;
    Button2   : TButton;
    E2        : TEdit;
    cbImages  : TCheckBox;
    cbMultiPage: TCheckBox;
    cbJPEG: TCheckBox;
    cbNavigatorTop: TCheckBox;
    cbNavigatorBottom: TCheckBox;
    cbNavigatorInFrame: TCheckBox;
    cbNavigatorWide: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure cbImagesClick(Sender: TObject);
    procedure cbMultiPageClick(Sender: TObject);
  private
    procedure UpdateControls;
    procedure Localize;
  end;

const
  LF = #13#10;                                               //Strict
  HTMLHeader =  '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">' + LF +
    '<HTML>' + LF + '<HEAD>' + LF + '<TITLE>%s</TITLE>' + LF +
    '<META NAME="Generator" CONTENT="FastReport 2.4"/>' + LF +
    '<META NAME="Author" CONTENT=""/>' + LF +
    '<META NAME="Keywords" CONTENT="FastReport"/>' + LF +
    '<META NAME="Description" CONTENT="The FastReport report"/>' + LF +
    '<LINK href="%s" rel="stylesheet" type="text/css" media="all">' + LF +
    '<LINK href="%s" rel="stylesheet" type="text/css" media="print">' + LF +
    '<HEAD>' + LF;
  HTMLFooter = LF + '</BODY></HTML>';
  PageFrame = 'PAGEFRAME';
  NavigatorFilePostfix = 'NAV';
  sLeftArrow = '<< ';
  sRightArrow = '>>';

implementation

uses
  FR_Utils, FR_Const {$IFDEF JPEG}, JPEG {$ENDIF}, FR_Shape;

{$R *.DFM}

function Scaling(const Value: integer; const Scale: double): integer;
begin
  Result := Round(Value * Scale);
end;

{function Scaling(const Value: single; const Scale: double): single; overload;
begin
  Result := Value * Scale;
end;}

function ScalingFont(const AFont: TFont; Scale: double): integer;
begin
  Result := Scaling(integer(Trunc(Abs(AFont.Height) * 96 / Screen.PixelsPerInch)),
    Scale);
end;

procedure ClearListWithFree(List: TList);
var
  i: integer;

begin
  for i := 0 to List.Count - 1 do
    TObject(List[i]).Free;
  List.Clear;
end;

{$IFNDEF Delphi5}
procedure FreeAndNil(var Obj);
var
  P: TObject;

begin
  P := TObject(Obj);
  TObject(Obj) := nil;
  P.Free;
end;
{$ENDIF}

{ TfrHTML2Export }

constructor TfrHTML2Export.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  frRegisterExportFilter(Self, 'HTML File advanced (*.html)', '*.html');
  ShowDialog := true;
  FExportPictures := true;
  FStyles := TList.Create;
  FScale := 1.0;
  FPages := TList.Create;
  FTextBitmap := TBitmap.Create;
  FNavigator := THNavigator.Create(self);
end;

procedure TfrHTML2Export.OnBeginDoc;
begin
  ClearListWithFree(FStyles);
  ClearListWithFree(FPages);
  ClearListWithFree(FNavigator.FItems);
  FCurrPage := nil;
  FImageFolder := ChangeFileExt(ExtractFileName(FileName), '.files');
  FImageFolderFull := ChangeFileExt(FileName, '.files');
  if FileExists(FImageFolderFull) then
    DeleteFile(PChar(FImageFolderFull));
  if FileExists(FileName) then
    DeleteFile(PChar(FileName));
end;

procedure TfrHTML2Export.OnEndDoc;
var
  s             : string;
  i, j          : integer;
  Page          : THPage;
  LastBottom    : integer;
  CSSFile       : string;
  CSSFilePrint  : string;
  NavFile       : string;
//  DefaultStyle : THStyle;
//  Style        : THStyle;
  h1, h2        : string;
  MaxWidth      : integer;
  MinLeftMargin : integer;

begin
  if Navigator = nil then Exit;
  if FPages.Count = 0 then Exit;

  if FStyles.Count > 0 then
  begin
    s := '';
    CSSFilePrint := ChangeFileExt(ExtractFileName(FileName), '_print.css');

    if Navigator.Position <> [] then
      s := s + Navigator.GetStyleHTML(true);

    if s <> '' then
      SaveStringToFile(ImageFolderFull + '\' + CSSFilePrint, s);
    {----------------------------}

    CSSFile := ChangeFileExt(ExtractFileName(FileName), '.css');

    {DefaultStyle := nil;
    for i := 0 to FStyles.Count - 1 do
    begin
      Style := THStyle(FStyles[i]);
      if not (Style is THStyleFrame) or
        (THStyleFrame(Style).FFillColor = $1FFFFFFF) then
        if (DefaultStyle = nil) or (Style.FCount > DefaultStyle.FCount) then
          DefaultStyle := THStyle(FStyles[i]);
    end;

    if DefaultStyle <> nil then
      DefaultStyle.SetDefault;}

    //s := 'img' + LF + '{' + LF + 'border: 0px solid #000000;' + LF + '}' + LF;

    s := 'span' + LF + '{' + LF + 'position: absolute;' + LF + '}' + LF +
      'img' + LF + '{' + LF + 'position: absolute;' + LF + '}' + LF +
      '.page_break' + LF + '{' + LF + 'page-break-before: always;' + LF + '}' + LF;

    for i := 0 to FStyles.Count - 1 do
      s := s + THStyle(FStyles[i]).GetHtml + LF;

    if {(FPages.Count > 1) and} (Navigator.Position <> []) then
      s := s + Navigator.GetStyleHTML(false);

    SaveStringToFile(ImageFolderFull + '\' + CSSFile, s);
    {----------------------------}
  end;

  if FMultiPage and (FNavigator.Position <> []) then
  begin
    if Navigator.InFrame and Navigator.WideInFrame then
    begin
      MaxWidth := Screen.Width - 20;
      MinLeftMargin := 0;
    end
    else begin
      MaxWidth := 0;
      MinLeftMargin := High(integer);
      for j := 0 to FPages.Count - 1 do
      begin
        Page := THPage(FPages[j]);
        if Page.Width - Page.RightMargin > MaxWidth then
          MaxWidth := Page.Width - Page.RightMargin;
        if Page.LeftMargin < MinLeftMargin then
          MinLeftMargin := Page.LeftMargin;
      end;
      if MaxWidth + MinLeftMargin > Screen.Width then
        MaxWidth := Screen.Width - MinLeftMargin;
    end;

    FNavigator.BuildItems(MaxWidth);

    if FNavigator.InFrame then
    begin
      NavFile := ChangeFileExt(ExtractFileName(FileName), '') + '_' +
        NavigatorFilePostfix + '_0.html';
      if npTop in Navigator.Position then
        h1 := Format('%dpx,', [Navigator.GetHeight])
      else
        h1 := '';

      if npBottom in Navigator.Position then
        h2 := Format(', %dpx', [Navigator.GetHeight])
      else
        h2 := '';

      s := Format(HTMLHeader, [CurReport.Title, CSSFile, CSSFilePrint]) +
        Format('<frameset rows="%s *%s" framespacing="0" frameborder="0" border="0">',
          [h1, h2]) + LF;

      if npTop in Navigator.FPosition then
        s := s + Format('<frame src="%s" name="NAVIGATOR_TOP" scrolling="no" ' +
          'marginwidth="0" marginheight="0">', [ImageFolder + '/' + NavFile]) + LF;

      s := s + Format('<frame src="%s" name="%s" scrolling="yes" marginwidth="0" ' +
        'marginheight="0">', [ImageFolder + '/' + THPage(FPages[0]).GetName,
        PageFrame]) + LF;

      if npBottom in Navigator.FPosition then
        s := s + Format('<frame src="%s" name="NAVIGATOR_BOTTOM" scrolling="no" ' +
          'marginwidth="0" marginheight="0">', [ImageFolder + '/' + NavFile]) + LF;

      s := s + '</frameset>' + LF + HTMLFooter;
      Stream.Write(s[1], Length(s));

      for j := 0 to FNavigator.FItems.Count - 1 do
      begin
        s := Format(HTMLHeader, [CurReport.Title, CSSFile, CSSFilePrint]);
        s := s + Navigator.GetHTML(TNavigatorItem(FNavigator.FItems[j]).MinPage,
          0, MinLeftMargin, MaxWidth, true) + HTMLFooter;
        NavFile := ChangeFileExt(ExtractFileName(FileName), '') + '_' +
          NavigatorFilePostfix + '_' + IntToStr(j) + '.html';
        SaveStringToFile(ImageFolderFull + '\' + NavFile, s);
      end;
    end;
  end;

  LastBottom := 5;
  for j := 0 to FPages.Count - 1 do
  begin
    Page := THPage(FPages[j]);

    if FMultiPage then
    begin
      if (j = 0) and (not Navigator.InFrame or (Navigator.Position = [])) then
        s := Format(HTMLHeader, [CurReport.Title, ImageFolder + '/' + CSSFile,
          ImageFolder + '/' + CSSFilePrint])
      else
        s := Format(HTMLHeader, [CurReport.Title, CSSFile, CSSFilePrint]);

      LastBottom := 5;
      if (FNavigator.Position <> []) and FNavigator.InFrame then
      begin
        s := s + Page.GetHTML(LastBottom, 0) + HTMLFooter;  //!!!!!!!!!!!!!!!!!!!!
        SaveStringToFile(ImageFolderFull + '\' + Page.GetName, s);
      end
      else begin
        if (FPages.Count > 1) and (npTop in Navigator.Position) then
        begin
          s := s + Navigator.GetHTML(Page.ID, LastBottom, Page.LeftMargin,
            Page.Width - Page.RightMargin, false);
          Inc(LastBottom, Navigator.GetHeight + 15);
        end;

        s := s + Page.GetHTML(LastBottom, 0);

        if (FPages.Count > 1) and (npBottom in Navigator.Position) then
          s := s + Navigator.GetHTML(Page.ID, Page.Height + LastBottom +
            {Page.BottomMargin} + 5, Page.LeftMargin, Page.Width - Page.RightMargin, false);

        s := s + HTMLFooter;

        if j = 0 then
          Stream.Write(s[1], Length(s))
        else
          SaveStringToFile(ImageFolderFull + '\' + Page.GetName, s);
      end;
    end
    else begin
      s := Page.GetHTML(LastBottom, 0);
      if j = 0 then
        s := Format(HTMLHeader, [CurReport.Title, ImageFolder + '/' + CSSFile,
          ImageFolder + '/' + CSSFilePrint]) + s;
      Stream.Write(s[1], Length(s));
      Inc(LastBottom, Page.Height);
    end;
  end;

  if not FMultiPage then
  begin
    s := HTMLFooter;
    Stream.Write(s[1], Length(s));
  end;

  ClearListWithFree(FNavigator.FItems);
  ClearListWithFree(FStyles);
  ClearListWithFree(FPages);
end;

function TfrHTML2Export.ShowModal: Word;
begin
  Result := mrOK;
  if Navigator = nil then Exit;
  if not ShowDialog then
    Result := mrOk
  else with TfrHTML2ExportForm.Create(nil) do
    try
      cbMultiPage.Checked := FMultiPage;
      cbNavigatorTop.Checked := npTop in Navigator.Position;
      cbNavigatorBottom.Checked := npBottom in Navigator.Position;
      cbImages.Checked := ExportPictures;
      E2.Text := FloatToStr(FScale);
      {$IFDEF JPEG}
      cbJPEG.Checked := FAllJPEG;
      {$ENDIF}
      cbNavigatorInFrame.Checked := FNavigator.InFrame;
      cbNavigatorWide.Checked := FNavigator.WideInFrame;
      UpdateControls;
      Result := ShowModal;
      try
        FScale := frStrToFloat(E2.Text);
      except
        FScale := 1;
      end;
      FMultiPage := cbMultiPage.Checked;
      Navigator.Position := [];
      if cbNavigatorTop.Checked then
        Navigator.Position := Navigator.Position + [npTop];
      if cbNavigatorBottom.Checked then
        Navigator.Position := Navigator.Position + [npBottom];
      ExportPictures := cbImages.Checked;
      {$IFDEF JPEG}
      FAllJPEG := cbJPEG.Checked;
      {$ENDIF}
      FNavigator.InFrame := cbNavigatorInFrame.Checked;
      FNavigator.WideInFrame := cbNavigatorWide.Checked;
    finally
      Free;
    end;
end;

procedure TfrHTML2Export.OnData(x, y: integer; View: TfrView);
var
//  Str         : TStream;
  Graphic     : TGraphic;
  Bitmap      : TBitmap;
  sBitmap     : TBitmap;
  {$IFDEF JPEG}
  ImJpeg      : TJpegImage;
  {$ENDIF}
//  FrameW      : integer;
  HFramedText : THFramedText;
  HFrame      : THFrame;
  HGraphic    : THGraphic;
//  k           : integer;
  GraphicType : TGraphicType;

begin
  if (View = nil) or not View.Visible then Exit;

  if View.Typ = gtMemo then
  begin
    if ((TfrMemoView(View).Alignment and frtaMiddle) = 0) and
       ((TfrMemoView(View).Alignment and frtaDown) = 0) then
    begin
      HFramedText := THFramedText.Create;
      try
        HFramedText.Left := Scaling(X, FScale);
        HFramedText.Top := Scaling(Y, FScale);
        //HFramedText.Width := Scaling(View.dx, FScale) + 1;
        //HFramedText.Height := Scaling(View.dy, FScale) + 1;
        HFramedText.Style := GetStyle(vtFramedText, View);
        HFramedText.FWordWrap := (View.Flags and flWordWrap = flWordWrap);
        FLastView := View;
        FLastFramedText := HFramedText;
      finally
        FCurrPage.AddItem(HFramedText);
      end;
    end
    else begin
      HFrame := THFrame.Create;
      try
        HFrame.Left := Scaling(X, FScale);
        HFrame.Top := Scaling(Y, FScale);
        //HFrame.Width := Scaling(View.dx, FScale) + 1;
        //HFrame.Height := Scaling(View.dy, FScale) + 1;
        HFrame.Style := GetStyle(vtFrame, View);
        FLastView := nil;
        FLastFramedText := nil;
      finally
        FCurrPage.AddItem(HFrame);
      end;
    end;
  end
  //изображения
  else if ExportPictures then
  begin
    GraphicType := gtBmp;
    Graphic := nil;
    Bitmap := TBitmap.Create;
    sBitmap := TBitmap.Create;
    {$IFDEF JPEG}
    if FAllJPEG then
      ImJpeg := TJpegImage.Create
    else
      ImJpeg := nil;
    {$ENDIF}
    try
      {$IFDEF JPEG}
      if (FScale = 1.0) and (View.Typ = gtPicture) then
      begin
        Graphic := TfrPictureView(View).Picture.Graphic;
        if (Graphic is TJPEGImage) and (Graphic.Width = View.dx) and
          (Graphic.Height = View.dy) then
          GraphicType := gtJpg
        else
          Graphic := nil;
      end;
      {$ENDIF}

      if (Graphic = nil) and ((View is TfrLineView) or ((View is TfrShapeView) and
        (TfrShapeView(View).ShapeType = skRectangle))) then
      begin
        HFrame := THFrame.Create;
        try
          HFrame.Left := Scaling(x, FScale);
          HFrame.Top := Scaling(y, FScale);
          //HFrame.Width := Scaling(View.dx, FScale);  !!!!!!!!!!!!!!!!!
          //HFrame.Height := Scaling(View.dy, FScale);

          if View is TfrShapeView then
            View.FrameTyp := 15;

          HFrame.Style := GetStyle(vtFrame, View);
        finally
          FCurrPage.AddItem(HFrame);
        end;
      end
      else begin
        Bitmap.Width := View.dx + 1;
        Bitmap.Height := View.dy + 1;
        View.x := 0;
        View.y := 0;
        View.Draw(Bitmap.Canvas);
        sBitmap.Width := Scaling(Bitmap.Width, FScale);
        sBitmap.Height := Scaling(Bitmap.Height, FScale);
        sBitmap.Canvas.StretchDraw(
          Rect(0, 0, sBitmap.Width, sBitmap.Height), Bitmap);
        {$IFDEF JPEG}
        if FAllJPEG then
        begin
          ImJpeg.Assign(sBitmap);
          Graphic := ImJpeg;
          GraphicType := gtJpg;
        end;
        {$ENDIF}
        if Graphic = nil then
          Graphic := sBitmap;
      end;

      if (Graphic <> nil) and not Graphic.Empty then
      begin
        //Str := TMemoryStream.Create;
        HGraphic := THGraphic.Create;
        try
          HGraphic.Left := Scaling(x, FScale);
          HGraphic.Top := Scaling(y, FScale);
          //HGraphic.Width := Graphic.Width;
          //HGraphic.Height := Graphic.Height;
          HGraphic.FGraphicType := GraphicType;
          if View is TfrShapeView then
            View.FrameWidth := 0;
          Graphic.SaveToStream(HGraphic.FStream);
          View.dx := Graphic.Width - 1;
          View.dy := Graphic.Height - 1;
          HGraphic.Style := GetStyle(vtFrame, View);
          FCurrPage.AddItem(HGraphic);
        except
          FreeAndNil(HGraphic);
        end;
      end;
    finally
      {$IFDEF JPEG}
      ImJpeg.Free;
      {$ENDIF}
      Bitmap.Free;
      sBitmap.Free;
    end;
  end;
end;

procedure TfrHTML2ExportForm.Localize;
begin
  Caption := frLoadStr(frRes + 1830);
  //not implement
  {CB1.Caption := frLoadStr(frRes + 1801);}
  cbImages.Caption := frLoadStr(frRes + 1821);
  Label1.Caption := frLoadStr(frRes + 1806);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);
end;

procedure TfrHTML2ExportForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

procedure TfrHTML2Export.ClearLines;
begin
end;

procedure TfrHTML2Export.OnBeginPage;
begin
  FCurrPage := THPage.Create(self, CurPage, FPages.Count);
  FPages.Add(FCurrPage);
  FLastFramedText := nil;
  FLastView := nil;
end;

procedure THPage.UpdateSize(const ABottom, ARight: integer);
begin
  if ABottom > FHeight then
    FHeight := ABottom;
  if ARight > Width then
    Width := ARight;
end;

function THPage.GetHTML(BaseTop, BaseLeft: integer): string;
var
  sl : TStringList;
  i  : integer;

begin
  if not FShowMargins then
    Dec(BaseTop, TopMargin);

  sl := TStringList.Create;
  try
    sl.Add('<div class = "page_break"></div>' + LF);

    for i := 0 to FTextList.Count - 1 do
      sl.Add(THFrame(FTextList[i]).GetHTML(BaseTop, BaseLeft));

    Result := sl.Text;
  finally
    sl.Free;
  end;
end;

destructor TfrHTML2Export.Destroy;
begin
  frUnRegisterExportFilter(Self);

  ClearListWithFree(FStyles);
  FStyles.Free;

  ClearListWithFree(FPages);
  FPages.Free;

  FTextBitmap.Free;
  FNavigator.Free;
  inherited;
end;

{ THTMLStyle }

class function THStyle.CorrectColor(AColor: TColor): TColor;
var
  c1, c2: integer;

begin
  //Transporent
  if AColor = $1FFFFFFF then
  begin
    Result := AColor;
    Exit;
  end;
  AColor := AColor and $00FFFFFF;
  c1 := (AColor and $00FF0000) shr 16;
  c2 := (AColor and $000000FF) shl 16;
  AColor := AColor and $0000FF00;
  AColor := AColor or c1;
  AColor := AColor or c2;
  Result := AColor;
end;

constructor THStyle.Create(const View: TfrView; const AID: integer;
  const Scale: double);
begin
  FID := AID;
  FWidth := Scaling(View.dx, Scale);
  FHeight := Scaling(View.dy, Scale);

  FTextBitmap := TBitmap.Create;
  FSizes := TList.Create;
end;

destructor THStyle.Destroy;
begin
  ClearListWithFree(FSizes);
  FSizes.Free;
  FTextBitmap.Free;
  inherited;
end;

function THStyle.Equals(const AStyle: THStyle): boolean;
begin
  Result := (self.ClassType = AStyle.ClassType) and
            (self.FWidth = AStyle.FWidth) and
            (self.FHeight = AStyle.FHeight); 
end;

class function THStyle.FontStyleName(const AFont: TFont): string;
begin
  Result := 'none';
  if fsItalic in AFont.Style then Result := 'italic';
end;

class function THStyle.FontWeightName(const AFont: TFont): string;
begin
  Result := 'none';
  if fsBold in AFont.Style then Result := 'bold';
end;

class function THStyle.GetHtmlColor(const AColor: TColor): string;
begin
  //Transparent
  if AColor = $1FFFFFFF then
    Result := 'none'
  else
    Result := '#' + IntToHex(AColor, 6);
end;

function THStyle.GetName(Clear: boolean): string;
begin
  if FDefault then
    Result := 'span'
  else
    if not Clear then
      Result := '.STL' + IntToStr(FID)
    else
      Result := 'STL' + IntToStr(FID);
end;

procedure TfrHTML2ExportForm.cbImagesClick(Sender: TObject);
begin
  UpdateControls;
end;

procedure TfrHTML2ExportForm.UpdateControls;
begin
  {$IFDEF JPEG}
  cbJPEG.Enabled := cbImages.Checked;
  {$ENDIF}
  cbNavigatorTop.Enabled := cbMultiPage.Checked;
  cbNavigatorBottom.Enabled := cbMultiPage.Checked;
  cbNavigatorInFrame.Enabled := cbMultiPage.Checked;
  cbNavigatorWide.Enabled := cbMultiPage.Checked;
end;

function TfrHTML2Export.GetStyle(const ViewType: TViewType;
  const View: TfrView): THStyle;
var
  j      : integer;
  Style  : THStyle;
  Style1 : THStyle;

begin
  Result := nil;

  case ViewType of
    vtText       : Style := THStyleText.Create(View, FStyles.Count, FScale);
    vtFramedText : Style := THStyleFramedText.Create(View, FStyles.Count, FScale);
    vtFrame      : Style := THStyleFrame.Create(View, FStyles.Count, FScale);
  else
    Exit;
  end;

  Style1 := Style;
  for j := 0 to FStyles.Count-1 do
    if THStyle(FStyles[j]).Equals(Style) then
    begin
      Style := THStyle(FStyles[j]);
      Style.IncrementCount;
      break;
    end;
  if Style1 <> Style then
    FreeAndNil(Style1)
  else
    FStyles.Add(Style);

  Result := Style;
end;

function TfrHTML2Export.GetImageFolderFull: string;
begin
  CheckFolder;
  Result := FImageFolderFull;
end;

function TfrHTML2Export.GetImageFolder: string;
begin
  CheckFolder;
  Result := FImageFolder;
end;

procedure TfrHTML2Export.SetNavigator(const Value: THNavigator);
begin
  FNavigator.Assign(Value);
end;

{ THItem }

function THFrame.GetContent: string;
begin
  Result := '';
end;

function THFrame.GetHeight: integer;
begin
  if Style <> nil then
    Result := Style.FHeight
  else
    Result := 0;
end;

function THFrame.GetHTML(const BaseTop, BaseLeft: integer): string;
begin
  if Style.FDefault then
    Result := '<span '
  else
    Result := Format('<span class = "%s" ', [Style.GetName(true)]);

  Result := Result + Format('style = "left: %dpx; ' +
                            'top: %dpx;">' +
//                            'width: %dpx; ' +
//                            'height: %dpx;">' +
                            '%s</span>',
                            [BaseLeft + Left,
                             BaseTop + Top,
//                             Width,
//                             Height,
                             GetContent]);
end;

procedure TfrHTML2Export.OnText(DrawRect: TRect; x, y: Integer;
  const text: String; FrameTyp: Integer; View: TfrView);
var
  HText      : THText;
  HStyleText : THStyleText;

begin
  if View = FLastView then
    FLastFramedText.AddString(Text)
  else begin
    HText := THText.Create;
    try
      HText.Style := GetStyle(vtText, View);
      HText.FText := Text;
      HText.Left := Scaling(X, FScale);
      HText.Top := Scaling(Y, FScale);
      HText.FWidth := Scaling(HText.Style.TextWidth(Text), FScale);
      HStyleText := THStyleText(HText.Style);
      if fsBold in HStyleText.FFont.Style then
        Inc(HText.FWidth, HStyleText.FFontHeight div 2);
      if fsItalic in HStyleText.FFont.Style then
        Inc(HText.FWidth, HStyleText.FFontHeight div 2);
      HText.FHeight := Scaling(View.dy, FScale);
    finally
      FCurrPage.AddItem(HText);
    end;
  end;
end;

procedure TfrHTML2Export.SaveStringToFile(const AFileName, Str: string);
var
  fs : TFileStream;

begin
  fs := TFileStream.Create(AFileName, fmCreate);
  try
    fs.Write(Str[1], Length(Str));
  finally
    FreeAndNil(fs);
  end;
end;

procedure TfrHTML2Export.Loaded;
begin
  inherited;
  FNavigator.Loaded;
end;

procedure TfrHTML2Export.CheckFolder;
begin
  CreateDir(FImageFolderFull);
end;

{ THStyleFrame }

function THStyleFrame.BorderStyle(const AFrameStyle: integer;
  const ABorder: THTMLBorder): string;
begin
  begin
    if not (ABorder in FBorders) then
      Result := 'none'
    else begin
      case AFrameStyle of
        integer(psSolid),
        psDouble              : Result:='solid';
        integer(psDash),
        integer(psDashDot),
        integer(psDashDotDot) : Result:='dashed';
        integer(psDot)        : Result:='dotted';
      else
        Result := 'none';
      end;

      Result := Result + Format(' %dpx #%s', [FBorderWidth, IntToHex(FBorderColor, 6)]);
    end;
  end;
end;

constructor THStyleFrame.Create(const View: TfrView; const AID: integer;
  const Scale: double);
begin
  inherited Create(View, AID, Scale);
  Inc(FWidth);
  Inc(FHeight);
  if View.FrameTyp and $1 <> 0 then FBorders := FBorders + [hbRight];
  if View.FrameTyp and $2 <> 0 then FBorders := FBorders + [hbBottom];
  if View.FrameTyp and $4 <> 0 then FBorders := FBorders + [hbLeft];
  if View.FrameTyp and $8 <> 0 then FBorders := FBorders + [hbTop];
  FBorderWidth := Scaling(Round(View.FrameWidth), Scale);
  if (FBorderWidth = 0) and (View.FrameWidth <> 0) then
    FBorderWidth := 1;
  FBorderColor := CorrectColor(View.FrameColor);
  FBorderStyle := View.FrameStyle;
  FFillColor := CorrectColor(View.FillColor);
end;

function THStyleFrame.Equals(const AStyle: THStyle): boolean;
var
  Style: THStyleFrame;

begin
  Result := inherited Equals(AStyle);
  if not Result then Exit;
  Style := THStyleFrame(AStyle);
  Result := (FBorders = Style.FBorders) and
            (FBorderWidth = Style.FBorderWidth) and
            (FBorderColor = Style.FBorderColor) and
            (FBorderStyle = Style.FBorderStyle) and
            (FFillColor = Style.FFillColor);
end;

function THStyleFrame.GetHtml: string;
begin
  Result := Format('%s' + LF + '{' + LF +
                   'background-color : %s;' + LF +
                   'border-left      : %s;' + LF +
                   'border-right     : %s;' + LF +
                   'border-top       : %s;' + LF +
                   'border-bottom    : %s;' + LF +
                   'font-size        : 0px;' + LF +
                   'width            : %dpx;' + LF +
                   'height           : %dpx;' + LF +
                   '}',
                   [GetName(false),
                    GetHTMLColor(FFillColor),
                    BorderStyle(FBorderStyle, hbLeft),
                    BorderStyle(FBorderStyle, hbRight),
                    BorderStyle(FBorderStyle, hbTop),
                    BorderStyle(FBorderStyle, hbBottom),
                    FWidth,
                    FHeight
                   ]);
end;

{ THPage }

procedure THPage.AddItem(const HFrame: THFrame);
begin
  UpdateSize(HFrame.Top + HFrame.GetHeight, HFrame.Left + HFrame.GetWidth);
  if HFrame is THGraphic then
  begin
    THGraphic(HFrame).FPage := self;
    THGraphic(HFrame).FID := FLastGraphicID;
    Inc(FLastGraphicID);
  end;

  FTextList.Add(HFrame);
end;

constructor THPage.Create(const AOwner: TfrHTML2Export; const FRPage: TfrPage;
  const AID: integer);
begin
  Owner := AOwner;
  ID := AID;
  if Owner <> nil then
  begin
    LeftMargin := Scaling(FRPage.pgMargins.Left, Owner.FScale);
    RightMargin := Scaling(FRPage.pgMargins.Right, Owner.FScale);
    BottomMargin := Scaling(FRPage.pgMargins.Bottom, Owner.FScale);
    TopMargin := Scaling(FRPage.pgMargins.Top, Owner.FScale);
  end;
  FTextList := TList.Create;
end;

destructor THPage.Destroy;
begin
  ClearListWithFree(FTextList);
  FTextList.Free;
  inherited;
end;

function THPage.GetName: string;
begin
  Result := ExtractFileName(Owner.FileName);
  if Owner.Navigator.InFrame or (ID > 0) then
    Result := ChangeFileExt(Result, Format('_%d.html', [ID]));
end;

{ THGavigator }

function THNavigator.GetHTML(const PageID: integer;
  const BaseTop, BaseLeft, Width: integer; const ForFrame: boolean): string;
var
  s        : string;
  i        : integer;
  Page     : THPage;
  FrameS   : string;
  PageName : string;
  NavItem  : TNavigatorItem;
  NavID    : integer;
  sWidth   : string;

begin
  if FFilter = nil then Exit;
  if FItems.Count = 0 then Exit;
  NavItem := nil;
  NavID := 0;
  for i := 0 to FItems.Count - 1 do
    if (TNavigatorItem(FItems[i]).MinPage <= PageID) and
      (TNavigatorItem(FItems[i]).MaxPage >= PageID) then
    begin
      NavItem := TNavigatorItem(FItems[i]);
      NavID := i;
      break;
    end;

  if NavItem = nil then Exit;

  if ForFrame and WideInFrame then
    sWidth := '100%'
  else
    sWidth := Format('%dpx', [Width]);

  s := Format('<span class = "%s" style = "left: %dpx; top: %dpx;' +
    'width: %s;">', [GetStyleName, BaseLeft, BaseTop, sWidth]);

  if ForFrame then
    FrameS := Format('target = "%s"', [PageFrame])
  else
    FrameS := '';

  if NavItem.LeftArrow then
  begin
    if InFrame then
      s := s + Format('<a href = "%s_%s_%d.html">' + sLeftArrow + '</a>',
        [ChangeFileExt(ExtractFileName(FFilter.FileName), ''), NavigatorFilePostfix, NavID - 1])
    else begin
      PageName := THPage(FFilter.FPages[NavItem.MinPage - 1]).GetName;
      if PageID = 0 then
        PageName := FFilter.ImageFolder + '/' + PageName
      else if NavItem.MinPage - 1 = 0 then
        PageName := '../' + PageName;

      s := s + Format('<a href = "%s">' + sLeftArrow + '</a>', [PageName]);
    end;
  end;

  for i := NavItem.MinPage to NavItem.MaxPage do
  begin
    Page := THPage(FFilter.FPages[i]);
    if (Page.ID <> PageID) or InFrame then
    begin
      PageName := Page.GetName;
      if not InFrame then
      begin
        if PageID = 0 then
          PageName := FFilter.ImageFolder + '/' + PageName
        else if i = 0 then
          PageName := '../' + PageName;
      end;

      s := s + Format('<a href = "%s" %s>%d</a> ', [PageName, FrameS, i + 1]);
    end
    else
      s := s + Format('<font color = "#990000">%d </font>', [i + 1]);
  end;

  //ссылка на следующий навигатор
  if NavItem.RightArrow then
  begin
    if InFrame then
      s := s + Format('<a href = "%s_%s_%d.html">' + sRightArrow + '</a>',
        [ChangeFileExt(ExtractFileName(FFilter.FileName), ''), NavigatorFilePostfix, NavID + 1])
    else begin
      PageName := THPage(FFilter.FPages[NavItem.MaxPage + 1]).GetName;
      if PageID = 0 then
        PageName := FFilter.ImageFolder + '/' + PageName
      else if NavItem.MaxPage + 1 = 0 then
        PageName := '../' + PageName;

      s := s + Format('<a href = "%s">' + sRightArrow + '</a>', [PageName]);
    end;
  end;

  Result := s + '</span>' + LF;
end;

procedure TfrHTML2ExportForm.cbMultiPageClick(Sender: TObject);
begin
  UpdateControls;
end;

function THNavigator.GetStyleHTML(ForPrinting: boolean): string;
  function GetBorder: string;
  begin
    if FBorder <> $1FFFFFFF then
      Result := Format('1px solid %s', [THStyle.GetHtmlColor(FBorder)])
    else
      Result := 'none';
  end;

begin
  if FFilter = nil then Exit;

  if ForPrinting then
    Result := Format('.%s' + LF + '{' + LF +
                     'visibility       : hidden;'  + LF +
                     '}',
                     [GetStyleName])
  else begin
    Result := Format('.%s' + LF + '{' + LF +
                     'text-align       : %s; '  + LF +
                     'font-family      : %s; ' + LF +
                     'font-size        : %dpx;' + LF +
                     'font-style       : %s;' + LF +
                     'text-decoration  : %s;' + LF +
                     'font-weight      : %s;' + LF +
                     'background-color : %s;' + LF +
                     'line-height      : 100%%' + LF +
                     'padding-left     : 2px;' + LF +
                     'padding-right    : 2px;' + LF +
                     'padding-top      : 2px;' + LF +
                     'padding-bottom   : 2px;' + LF +
                     'height           : %dpx;' + LF +
                     'border-left      : none;' + LF +
                     'border-right     : none;' + LF +
                     'border-top       : %s;' + LF +
                     'border-bottom    : %s;' + LF +
                     '}',
                     [GetStyleName,
                      THStyle.TextAlignName(Align),
                      Font.Name,
                      Trunc(Abs(Font.Height)),
                      THStyle.FontStyleName(Font),
                      THStyle.TextDecorName(Font),
                      THStyle.FontWeightName(Font),
                      THStyle.GetHtmlColor(THStyle.CorrectColor(FillColor)),
                      GetHeight,
                      GetBorder,
                      GetBorder
                      ]);
    //ссылки
    Result := Result + Format(LF + 'a' + LF + '{' + LF +
                              'text-decoration: none;' + LF +
                              'color: %s;' + LF + '}' +
                              LF + 'a:hover' + LF + '{' + LF +
                              'text-decoration: underline;' + LF +
                              {'color: #00CC66;' + LF +} '}',
                              [THStyle.GetHtmlColor(
                                 THStyle.CorrectColor(Font.Color))]);
  end;
end;

procedure THStyle.IncrementCount;
begin
  Inc(FCount);
end;

procedure THStyle.SetDefault;
begin
  FDefault := true;
end;

class function THStyle.TextAlignName(const AAlign: THAlign): string;
begin
  case AAlign of
    haLeft   : Result := 'left';
    haCenter : Result := 'center';
    haRight  : Result := 'right';
  else
    Result := '';
  end;
end;

class function THStyle.TextDecorName(const AFont: TFont): string;
begin
  Result := 'none';
    if fsUnderline in AFont.Style then Result := 'underline';
end;

function THNavigator.GetStyleName: string;
begin
  Result := 'STL_NAV';
end;

function THNavigator.GetHeight: integer;
begin
  //Result := 40;
  //Result := ScalingFont(Font, FFilter.FScale) + 8;
  Result := Round(Abs(Font.Height) * 96 / Font.PixelsPerInch) + 10;
end;

constructor THNavigator.Create(AFilter: TfrHTML2Export);
begin
  FPosition := [];
  FAlign := haCenter;
  FFillColor := $F5F5F5;
  FBorder := $A3A3A3;
  FFilter := AFilter;
  FFont := TFont.Create;
  FItems := TList.Create;
  FTextBitmap := TBitmap.Create;
end;

destructor THNavigator.Destroy;
begin
  FTextBitmap.Free;
  ClearListWithFree(FItems);
  FItems.Free;
  FFont.Free;
  inherited;
end;

procedure THNavigator.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
  FTextBitmap.Canvas.Font.Assign(FFont);
end;

function THPage.GetHeight: integer;
begin
  Result := FHeight;
  if not FShowMargins then
    Result := Result - TopMargin + 1;// - BottomMargin;
end;

{ TTest }

{ THFramedText }

procedure THFramedText.AddString(Str: string);
var
  TextWidth : integer;
  n         : integer;
  MaxWidth  : integer;

begin
{  n := Length(Str);
  while (Length(Str) > 0) and (n > 0) do
  begin
    s := Str;
    n := Length(Str);
    len := THStyleFramedText(Style).TextWidth(Str);
    while (n > 0) and (len > Width + 2 * THStyleFramedText(Style).FGapX) do
    begin
      Dec(n);
      s := Copy(Str, 1, n);
      len := THStyleFramedText(Style).TextWidth(Str);
    end;
    if n > 0 then
    begin
      FStrings.Add(s);
      Str := Copy(Str, n + 1, Length(Str));
    end;
  end;}

  //if Trim(Text) <> '' then
  Str := Trim(Str);
  if FWordWrap then
    FStrings.Add(Trim(Str))
  else begin
    MaxWidth := THStyleFramedText(Style).FGapX * 2 + GetWidth - 2;
    n := Length(Str);
    TextWidth := Style.TextWidth(Str);
    while (n >= 0) and (TextWidth > MaxWidth) do
    begin
      Dec(n);
      Str := Copy(Str, 1, n);
      TextWidth := Style.TextWidth(Str);
    end;
    FStrings.Add(Str);
  end;
end;

constructor THFramedText.Create;
begin
  FStrings := TStringList.Create;
end;

destructor THFramedText.Destroy;
begin
  FStrings.Free;
  inherited;
end;

function THFramedText.GetContent: string;
var
  i         : integer;
  IsJustify : boolean;
  s         : string;

begin
  Result := '';
  IsJustify := THStyleFramedText(Style).IsTextJustify;
  for i := 0 to FStrings.Count - 1 do
  begin
    s := Trim(FStrings[i]);
    Result := Result + s;
    if i < FStrings.Count - 1 then
      if IsJustify then
      begin
        if s = '' then
          Result := Result + '<br><br>'
        else
          Result := Result + ' ';
      end
      else
        Result := Result + '<br>';
  end;
end;

{ THStyleFramedText }

constructor THStyleFramedText.Create(const View: TfrView; const AID: integer;
  const Scale: double);
begin
  inherited Create(View, AID, Scale);
  FFont := TFont.Create;

  if View.Typ = gtMemo then
  begin
    FFont.Assign(TfrMemoView(View).Font);
    FFont.Color := CorrectColor(FFont.Color);
    FTextAlign := TfrMemoView(View).Alignment;
    FFontHeight := ScalingFont(FFont, Scale);
    FLineSpacing := Scaling(TfrMemoView(View).LineSpacing, Scale);
  end;

  FWordWrap := (View.Flags and flWordWrap = flWordWrap);
  //FWordBreak := (View.Flags and flWordBreak = flWordBreak);

  FGapX := Scaling(View.GapX, Scale);
  FGapY := Scaling(View.GapY, Scale);

  FTextBitmap.Canvas.Font.Assign(FFont);
end;

destructor THStyleFramedText.Destroy;
begin
  FFont.Free;
  inherited;
end;

function THStyleFramedText.Equals(const AStyle: THStyle): boolean;
var
  Style: THStyleFramedText;

begin
  Result := inherited Equals(AStyle);
  //разные классы
  if not Result then Exit;
  Style := THStyleFramedText(AStyle);
  Result := (FFont.Name = Style.FFont.Name) and
            (FFontHeight = Style.FFontHeight) and
            (FFont.Color = Style.FFont.Color) and
            (FFont.Style = Style.FFont.Style) and
            (FGapX = Style.FGapX) and
            (FGapY = Style.FGapY) and
            (FTextAlign = Style.FTextAlign);
end;

function THStyleFramedText.GetHtml: string;
begin
  Result := Format('%s' + LF + '{' + LF +
                   'background-color : %s;' + LF +
                   'border-left      : %s;' + LF +
                   'border-right     : %s;' + LF +
                   'border-top       : %s;' + LF +
                   'border-bottom    : %s;' + LF +
                   'font-family      : %s; ' + LF +
                   'font-size        : %dpx; ' + LF +
                   'color            : %s; ' + LF +
                   'text-decoration  : %s;' + LF +
                   'font-style       : %s;' + LF +
                   'font-weight      : %s;' + LF +
                   'text-align       : %s;' + LF +
                   '%s' + LF +
                   'line-height      : %dpx;' + LF +
                   'width            : %dpx;' + LF +
                   'height           : %dpx;' + LF +
                   'white-space      : nowrap;' + LF +
                   'overflow         : hidden;' + LF +
                   '}',
                   [GetName(false),
                    GetHTMLColor(FFillColor),
                    BorderStyle(FBorderStyle, hbLeft),
                    BorderStyle(FBorderStyle, hbRight),
                    BorderStyle(FBorderStyle, hbTop),
                    BorderStyle(FBorderStyle, hbBottom),
                    FFont.Name,
                    FFontHeight,
                    GetHTMLColor(FFont.Color),
                    TextDecorName(FFont),
                    FontStyleName(FFont),
                    FontWeightName(FFont),
                    HorAlignName,
                    GetPaddings,
                    FFontHeight + FLineSpacing,
                    FWidth,
                    FHeight
                    //WhiteSpaceName,
                    //OverflowName
                    ]);
end;

function THStyleFramedText.GetPaddings: string;
begin
  Result := '';
  if FGapX > 0 then
    Result := Result + Format('padding-left     : %dpx;' + LF +
                              'padding-right    : %dpx;',
      [FGapX - 1, FGapX]);
  if FGapY > 0 then
    Result := Result + Format(LF + 'padding-top      : %dpx;' + LF +
                                   'padding-bottom   : %dpx;',
      [FGapY, 0 {, FGapY}]);
end;

function THStyleFramedText.HorAlignName: string;
begin
  Result := 'left';
  if ((FTextAlign and frtaRight) = frtaRight) and
     ((FTextAlign and frtaCenter) = frtaCenter) then
    Result := 'justify'
  else if ((FTextAlign and frtaRight) = frtaRight) then
    Result := 'right'
  else if ((FTextAlign and frtaCenter) = frtaCenter) then
    Result := 'center';
end;

function THStyle.TextWidth(const Text: string): integer;
begin
  Result := Round(FTextBitmap.Canvas.TextWidth(Text) * 96 / Screen.PixelsPerInch);
end;

function THStyleFramedText.IsTextJustify: boolean;
begin
  Result := ((FTextAlign and frtaRight) = frtaRight) and
     ((FTextAlign and frtaCenter) = frtaCenter);
end;

{function THStyleFramedText.OverflowName: string;
begin
  if FWordWrap then  //!!!!!
    Result := 'visible'
  else
    Result := 'hidden';
end;

function THStyleFramedText.WhiteSpaceName: string;
begin
  if FWordWrap then
    Result := 'normal'
  else
    Result := 'nowrap';
end;}

{ THText }

function THText.GetContent: string;
begin
  Result := FText;
end;

function THText.GetHeight: integer;
begin
  Result := FHeight;
end;

function THText.GetHTML(const BaseTop, BaseLeft: integer): string;
begin
  Result := Format('<span class = "%s" ', [Style.GetName(true)]);
  Result := Result + Format('style = "left: %dpx; ' +
                            'top: %dpx; ' +
                            'width: %dpx; ' +
                            'height: %dpx;">' +
                            '%s</span>',
                            [BaseLeft + Left,
                             BaseTop + Top,
                             FWidth,
                             FHeight,
                             GetContent]);
end;

function THText.GetWidth: integer;
begin
  Result := FWidth;
end;

{ THStyleText }

constructor THStyleText.Create(const View: TfrView; const AID: integer;
  const Scale: double);
var
  Memo : TfrMemoView;

begin
  inherited Create(View, AID, Scale);
  Memo := TfrMemoView(View);
  FFont := TFont.Create;

  if View.Typ = gtMemo then
  begin
    FFont.Assign(Memo.Font);
    FFont.Color := CorrectColor(FFont.Color);
    FFontHeight := ScalingFont(FFont, Scale);
    FLineSpacing := Scaling(Memo.LineSpacing, Scale);
  end;

  FGapX := Scaling(View.GapX, Scale);
  FGapY := Scaling(View.GapY, Scale);

  FTextBitmap.Canvas.Font.Assign(FFont);
end;

destructor THStyleText.Destroy;
begin
  FFont.Free;
  inherited;
end;

function THStyleText.Equals(const AStyle: THStyle): boolean;
var
  Style: THStyleText;

begin
  Result := inherited Equals(AStyle);
  //разные классы
  if not Result then Exit;
  Style := THStyleText(AStyle);
  Result := (FFont.Name = Style.FFont.Name) and
            (FFontHeight = Style.FFontHeight) and
            (FFont.Color = Style.FFont.Color) and
            (FFont.Style = Style.FFont.Style);
end;

function THStyleText.GetHtml: string;
begin
  Result := Format('%s' + LF + '{' + LF +
                   'font-family      : %s; ' + LF +
                   'font-size        : %dpx; ' + LF +
                   'color            : %s; ' + LF +
                   'text-decoration  : %s;' + LF +
                   'font-style       : %s;' + LF +
                   'font-weight      : %s;' + LF +
                   'text-align       : left;' + LF +
                   'line-height      : 100%%;' + LF +
                   'background-color : none;' + LF +
                   'border           : none;' + LF +
                   '%s;' + LF +
                   '}',
                   [GetName(false),
                    FFont.Name,
                    FFontHeight,
                    GetHTMLColor(FFont.Color),
                    TextDecorName(FFont),
                    FontStyleName(FFont),
                    FontWeightName(FFont),
                    GetPaddings
                   ]);
end;

function THStyleText.GetPaddings: string;
begin
  Result := '';
  if FGapX > 0 then
    Result := Result + Format('padding-left     : %dpx;' + LF +
                              'padding-right    : %dpx;',
      [0, 0]);
  if FGapY > 0 then
    Result := Result + Format(LF + 'padding-top      : %dpx;' + LF +
                                   'padding-bottom   : %dpx;',
      [FGapY, 0 {, FGapY}]);
end;

{ THGraphic }

constructor THGraphic.Create;
begin
  FStream := TMemoryStream.Create;
end;

destructor THGraphic.Destroy;
begin
  FStream.Free;
  inherited;
end;

function THGraphic.GetHTML(const BaseTop, BaseLeft: integer): string;
var
  ImFileName : string;
  ImHrefName : string;

begin
  ImFileName := Format('im_%d_%d', [FPage.ID, FID]);

  case FGraphicType of
    gtBmp: ImFileName := ImFileName + '.bmp';
    {$IFDEF JPEG}
    gtJpg: ImFileName := ImFileName + '.jpg';
    {$ENDIF}
  end;

  ImHrefName := ImFileName;

  if not FPage.Owner.MultiPage or
    (FPage.Owner.MultiPage and not FPage.Owner.Navigator.InFrame and
    (FPage.ID = 0)) then
    ImHrefName := FPage.Owner.ImageFolder + '/' + ImFileName;

  FStream.SaveToFile(FPage.Owner.ImageFolderFull + '\' + ImFileName);
  Result := Format('<img class = "%s" style = "top: %d; left: %d; z-index: 1;" ' +
                   'src = "%s" border = "0">',
                   [Style.GetName(true),
                   BaseTop + Top,
                   BaseLeft + Left,
                   ImHrefName
                   ]);

{  Result := Format('<img src = "%s" class = "%s" ' +
                   'style = "top: %d; left: %d; z-index: 1;">',
                  [FPage.Owner.ImageFolder + '/' + ImFileName,
                  Style.GetName(true),
                  BaseTop + Top, BaseLeft + Left
                  ]);}
end;

procedure THNavigator.BuildItems(AWidth: integer);
var
  i         : integer;
  PageCount : integer;
  Item      : TNavigatorItem;
  s         : string;

begin
  ClearListWithFree(FItems);
  PageCount := FFilter.FPages.Count;
  Dec(AWidth, 20);
  if PageCount = 0 then Exit;
  i := 0;
  repeat
    Item := TNavigatorItem.Create;
    try
      Item.MinPage := i;
      s := '';
      if i > 0 then
      begin
        s := sLeftArrow;
        Item.LeftArrow := true;
      end;
      s := s + Format('%d ', [Item.MinPage + 1]);
      while (i < PageCount) and (TextWidth(s + sRightArrow) < AWidth) do
      begin
        Inc(i);
        s := s + Format('%d ', [i + 1]);
      end;
      if TextWidth(s + sRightArrow) > AWidth then
        Dec(i);
      //не последний навигатор
      if i < PageCount - 1 then
      begin
        //s := s + sRightArrow;
        Item.RightArrow := true;
      end;
      Item.MaxPage := i;
      if Item.MaxPage >= PageCount then
        Item.MaxPage := PageCount - 1;
      Inc(i);
    finally
      FItems.Add(Item);
    end;
  until i >= PageCount;
end;

function THNavigator.TextWidth(const Text: string): integer;
begin
  Result := Round(FTextBitmap.Canvas.TextWidth(Text)); // * 96 / Screen.PixelsPerInch);
end;

procedure THNavigator.Loaded;
begin
  FTextBitmap.Canvas.Font.Assign(FFont);
end;

function THFrame.GetWidth: integer;
begin
  if Style <> nil then
    Result := Style.FWidth
  else
    Result := 0;
end;

procedure THNavigator.AssignTo(Dest: TPersistent);
var
  DNav: THNavigator;

begin
  DNav := THNavigator(Dest);
  DNav.Font.Assign(Font);
  DNav.Position := Position;
  DNav.Align := Align;
  DNav.FillColor := FillColor;
  DNav.InFrame := InFrame;
  DNav.Border := Border;
  DNav.WideInFrame := WideInFrame;
end;

{ TFrameSize }

{function TFrameSize.Equals(const AFrameSize: TFrameSize): boolean;
begin
  Result := (Width = AFrameSize.Width) and (Height = AFrameSize.Height);
end;}

end.
