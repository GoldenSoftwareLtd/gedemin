
{******************************************}
{                                          }
{             FastReport v2.53             }
{             Report preview               }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_View;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Buttons, StdCtrls, Menus, FR_Ctrls, FR_Dock, FR_Const
  {$IFDEF GEDEMIN}//!!!
  ,gd_createable_form
  {$ENDIF}//!!!
  ;

type
  TfrPreviewForm = class;
  TfrPreview = class;
  TfrPreviewZoom = (pzDefault, pzPageWidth, pzOnePage, pzTwoPages);
  TfrPreviewButton = (pbZoom, pbLoad, pbSave, pbPrint, pbFind, pbHelp, pbExit, pbPageSetup);
  TfrPreviewButtons = set of TfrPreviewButton;

  TfrPageChangedEvent = procedure(Sender: TfrPreview; PageNo: Integer) of object;

  TfrPreview = class(TPanel)
  private
    FWindow: TfrPreviewForm;
    FScrollBars: TScrollStyle;
    FShowToolbar: Boolean;
    FOnPageChanged: TfrPageChangedEvent;
    procedure WMSize(var Message: TMessage); message WM_WINDOWPOSCHANGED;
    function GetPage: Integer;
    procedure SetPage(Value: Integer);
    function GetZoom: Double;
    procedure SetZoom(Value: Double);
    function GetAllPages: Integer;
    procedure SetScrollBars(Value: TScrollStyle);
    procedure SetShowToolbar(Value: Boolean);
    procedure OnInternalPageChanged(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Connect(Doc: Pointer);
    procedure Disconnect;
    procedure OnePage;
    procedure TwoPages;
    procedure PageWidth;
    procedure First;
    procedure Next;
    procedure Prev;
    procedure Last;
    procedure SaveToFile;
    procedure LoadFromFile;
    procedure Print;
    procedure PageSetupDlg;
    procedure Edit;
    procedure Find;
    procedure Clear;
    procedure LoadFile(Name: String);
    property AllPages: Integer read GetAllPages;
    property Page: Integer read GetPage write SetPage;
    property Zoom: Double read GetZoom write SetZoom;
    property Window: TfrPreviewForm read FWindow write FWindow;
  published
    property ScrollBars: TScrollStyle read FScrollBars write SetScrollBars;
    property ShowToolbar: Boolean read FShowToolbar write SetShowToolbar default False;
    property OnPageChanged: TfrPageChangedEvent read FOnPageChanged write FOnPageChanged;
  end;

  TfrPBox = class(TPanel)
  private
    Down, DFlag: Boolean;
    LastX, LastY: Integer;
    LastClick: Integer;
  public
    Preview: TfrPreviewForm;
    procedure WMEraseBackground(var Message: TMessage); message WM_ERASEBKGND;
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure DblClick; override;
  end;

  TfrScaleMode = (mdNone, mdPageWidth, mdOnePage, mdTwoPages);
{$IFDEF GEDEMIN}
  TfrPreviewForm = class(TCreateableForm)
    TPanel: TPanel;
    ProcMenu: TPopupMenu;
    N2001: TMenuItem;
    N1501: TMenuItem;
    N1001: TMenuItem;
    N751: TMenuItem;
    N501: TMenuItem;
    N251: TMenuItem;
    N101: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    Bevel2: TBevel;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    PreviewPanel: TPanel;
    ScrollBox1: TScrollBox;
    RPanel: TPanel;
    PgUp: TfrSpeedButton;
    PgDown: TfrSpeedButton;
    VScrollBar: TScrollBar;
    BPanel: TPanel;
    Bevel1: TBevel;
    Label1: TLabel;
    HScrollBar: TScrollBar;
    Panel1: TPanel;
    ZoomBtn: TfrTBButton;
    frTBSeparator1: TfrTBSeparator;
    LoadBtn: TfrTBButton;
    SaveBtn: TfrTBButton;
    PrintBtn: TfrTBButton;
    frTBSeparator2: TfrTBSeparator;
    FindBtn: TfrTBButton;
    HelpBtn: TfrTBButton;
    frTBSeparator3: TfrTBSeparator;
    ExitBtn: TfrTBButton;
    PageSetupBtn: TfrTBButton;
    Bevel3: TBevel;
    Label2: TLabel;

    procedure FormResize(Sender: TObject);
    procedure VScrollBarChange(Sender: TObject);
    procedure HScrollBarChange(Sender: TObject);
    procedure PgUpClick(Sender: TObject);
    procedure PgDownClick(Sender: TObject);
    procedure ZoomBtnClick(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure ExitBtnClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure LoadBtnClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FindBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditBtnClick(Sender: TObject);
    procedure DelPageBtnClick(Sender: TObject);
    procedure NewPageBtnClick(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormActivate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure HScrollBarEnter(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PageSetupBtnClick(Sender: TObject);
  private
    { Private declarations }
    PBox: TfrPBox;
    CurPage: Integer;
    ofx, ofy, OldV, OldH: Integer;
    per: Double;
    mode: TfrScaleMode;
    PaintAllowed: Boolean;
    FindStr: String;
    CaseSensitive: Boolean;
    StrFound: Boolean;
    StrBounds: TRect;
    LastFoundPage, LastFoundObject: Integer;
    HF: String;
    FOnPageChanged: TNotifyEvent;
    KWheel: Integer;

    FMinimize: Boolean;

    procedure ShowPageNum;
    procedure SetToCurPage;
    procedure RedrawAll(ResetPage: Boolean);
    procedure LoadFromFile(name: String);
    procedure SaveToFile(name: String);
    procedure FindInEMF(emf: TMetafile);
    procedure FindText;
    procedure SetGrayedButtons(Value: Boolean);
    procedure InitButtons;
    procedure Localize;
    property OnPageChanged: TNotifyEvent read FOnPageChanged write FOnPageChanged;
    procedure CMDialogKey(var Message: TCMDialogKey); message CM_DIALOGKEY;
    procedure WMSysCommand(var Message: TMessage);
      message WM_SYSCOMMAND;

{$IFDEF Delphi4}
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
{$ENDIF}

    function TestUserRights: Boolean;

  public
    { Public declarations }
    Doc: Pointer;
    EMFPages: Pointer;
    procedure Connect(ADoc: Pointer); virtual; {!!!}
    procedure ConnectBack;
    procedure Show_Modal(ADoc: Pointer);
  end;
{$ELSE}
  TfrPreviewForm = class(TForm)
    TPanel: TPanel;
    ProcMenu: TPopupMenu;
    N2001: TMenuItem;
    N1501: TMenuItem;
    N1001: TMenuItem;
    N751: TMenuItem;
    N501: TMenuItem;
    N251: TMenuItem;
    N101: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    Bevel2: TBevel;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    PreviewPanel: TPanel;
    ScrollBox1: TScrollBox;
    RPanel: TPanel;
    PgUp: TfrSpeedButton;
    PgDown: TfrSpeedButton;
    VScrollBar: TScrollBar;
    BPanel: TPanel;
    Bevel1: TBevel;
    Label1: TLabel;
    HScrollBar: TScrollBar;
    Panel1: TPanel;
    ZoomBtn: TfrTBButton;
    frTBSeparator1: TfrTBSeparator;
    LoadBtn: TfrTBButton;
    SaveBtn: TfrTBButton;
    PrintBtn: TfrTBButton;
    frTBSeparator2: TfrTBSeparator;
    FindBtn: TfrTBButton;
    HelpBtn: TfrTBButton;
    frTBSeparator3: TfrTBSeparator;
    ExitBtn: TfrTBButton;
    PageSetupBtn: TfrTBButton;
    Bevel3: TBevel;
    Label2: TLabel;
    procedure FormResize(Sender: TObject);
    procedure VScrollBarChange(Sender: TObject);
    procedure HScrollBarChange(Sender: TObject);
    procedure PgUpClick(Sender: TObject);
    procedure PgDownClick(Sender: TObject);
    procedure ZoomBtnClick(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure ExitBtnClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure LoadBtnClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FindBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditBtnClick(Sender: TObject);
    procedure DelPageBtnClick(Sender: TObject);
    procedure NewPageBtnClick(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormActivate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure HScrollBarEnter(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PageSetupBtnClick(Sender: TObject);
  private
    { Private declarations }
    PBox: TfrPBox;
    CurPage: Integer;
    ofx, ofy, OldV, OldH: Integer;
    per: Double;
    mode: TfrScaleMode;
    PaintAllowed: Boolean;
    FindStr: String;
    CaseSensitive: Boolean;
    StrFound: Boolean;
    StrBounds: TRect;
    LastFoundPage, LastFoundObject: Integer;
    HF: String;
    FOnPageChanged: TNotifyEvent;
    KWheel: Integer;
    procedure ShowPageNum;
    procedure SetToCurPage;
    procedure RedrawAll(ResetPage: Boolean);
    procedure LoadFromFile(name: String);
    procedure SaveToFile(name: String);
    procedure FindInEMF(emf: TMetafile);
    procedure FindText;
    procedure SetGrayedButtons(Value: Boolean);
    procedure InitButtons;
    procedure Localize;
    property OnPageChanged: TNotifyEvent read FOnPageChanged write FOnPageChanged;
    procedure CMDialogKey(var Message: TCMDialogKey); message CM_DIALOGKEY;
{$IFDEF Delphi4}
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    //procedure WMSysCommand(var Message: TMessage);
{$ENDIF}
  public
    { Public declarations }
    Doc: Pointer;
    EMFPages: Pointer;
    procedure Connect(ADoc: Pointer); virtual; {!!!}
    procedure ConnectBack;
    procedure Show_Modal(ADoc: Pointer);
  end;

{$ENDIF}


implementation

{$R *.DFM}

uses
  FR_Class, Printers, FR_Prntr, FR_Srch, Registry, FR_PrDlg, FR_Utils, CommDlg
  //!!!b
  {$IFDEF GEDEMIN_LOCK}
  , gd_registration
  {$ENDIF}
  {$IFDEF GEDEMIN}
  , Storages, gd_security
  {$ENDIF}
  //!!!e
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

type
  THackControl = class(TControl)
  end;

var
  LastScale: Double = 1;
  LastScaleMode: TfrScaleMode = mdNone;
  CurPreview: TfrPreviewForm;
  RecordNum: Integer;


{----------------------------------------------------------------------------}
constructor TfrPreview.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FWindow := TfrPreviewForm.Create(nil);
  FWindow.OnPageChanged := OnInternalPageChanged;
  FWindow.Localize;
  BevelInner := bvNone;
  BevelOuter := bvLowered;
  ScrollBars := ssBoth;
end;

destructor TfrPreview.Destroy;
begin
  FWindow.Free;
  inherited Destroy;
end;

procedure TfrPreview.WMSize(var Message: TMessage);
begin
  inherited;
  FWindow.FormResize(nil);
end;

{$HINTS OFF}
procedure TfrPreview.Connect(Doc: Pointer);
var
  f: TForm;
begin
  FWindow.PreviewPanel.Parent := Self;
  if FShowToolbar then
    FWindow.TPanel.Parent := Self;
  FWindow.PreviewPanel.Show;
  FWindow.Connect(Doc);
  FWindow.InitButtons;
  FWindow.RedrawAll(True);
  if PopupMenu <> nil then
    FWindow.PopupMenu := PopupMenu;
{$IFDEF Delphi4}
  f := TForm(GetParentForm(Self));
  if f <> nil then
  begin
    f.OnMouseWheelUp := FWindow.FormMouseWheelUp;
    f.OnMouseWheelDown := FWindow.FormMouseWheelDown;
    FWindow.KWheel := 3;
  end;
{$ENDIF}
end;
{$HINTS ON}

procedure TfrPreview.Disconnect;
begin
  FWindow.ConnectBack;
end;

function TfrPreview.GetPage: Integer;
begin
  Result := FWindow.CurPage;
end;

procedure TfrPreview.SetPage(Value: Integer);
begin
  if (Value < 1) or (Value > AllPages) then Exit;
  FWindow.CurPage := Value;
  FWindow.SetToCurPage;
end;

function TfrPreview.GetZoom: Double;
begin
  Result := FWindow.Per * 100;
end;

procedure TfrPreview.SetZoom(Value: Double);
begin
  FWindow.Per := Value / 100;
  FWindow.Mode := mdNone;
  LastScale := FWindow.Per;
  LastScaleMode := FWindow.Mode;
  FWindow.FormResize(nil);
  FWindow.PBox.Paint;
end;

function TfrPreview.GetAllPages: Integer;
begin
  Result := 0;
  if TfrEMFPages(FWindow.EMFPages) <> nil then
    Result := TfrEMFPages(FWindow.EMFPages).Count;
end;

procedure TfrPreview.SetScrollBars(Value: TScrollStyle);
begin
  FScrollBars := Value;
  FWindow.RPanel.Visible := (Value = ssBoth) or (Value = ssVertical);
  FWindow.BPanel.Visible := (Value = ssBoth) or (Value = ssHorizontal);
end;

procedure TfrPreview.SetShowToolbar(Value: Boolean);
begin
  FShowToolbar := Value;
  if FShowToolbar then
    FWindow.TPanel.Parent := Self else
    FWindow.TPanel.Parent := FWindow;
end;

procedure TfrPreview.OnePage;
begin
  FWindow.Mode := mdOnePage;
  LastScaleMode := FWindow.Mode;
  FWindow.FormResize(nil);
  FWindow.PBox.Paint;
end;

procedure TfrPreview.TwoPages;
begin
  FWindow.Mode := mdTwoPages;
  LastScaleMode := FWindow.Mode;
  FWindow.FormResize(nil);
  FWindow.PBox.Paint;
end;

procedure TfrPreview.PageWidth;
begin
  FWindow.Mode := mdPageWidth;
  LastScaleMode := FWindow.Mode;
  FWindow.FormResize(nil);
  FWindow.PBox.Paint;
end;

procedure TfrPreview.First;
begin
  Page := 1;
end;

procedure TfrPreview.Next;
begin
  Page := Page + 1;
end;

procedure TfrPreview.Prev;
begin
  Page := Page - 1;
end;

procedure TfrPreview.Last;
begin
  Page := AllPages;
end;

procedure TfrPreview.SaveToFile;
begin
  FWindow.SaveBtnClick(nil);
end;

procedure TfrPreview.LoadFromFile;
begin
  FWindow.LoadBtnClick(nil);
end;

procedure TfrPreview.Print;
begin
  FWindow.PrintBtnClick(nil);
end;

procedure TfrPreview.PageSetupDlg;
begin
  FWindow.PageSetupBtnClick(nil);
end;

procedure TfrPreview.Edit;
begin
  FWindow.EditBtnClick(nil);
end;

procedure TfrPreview.Find;
begin
  FWindow.FindBtnClick(nil);
end;

procedure TfrPreview.Clear;
begin
  if FWindow.EMFPages <> nil then
  begin
    TfrEMFPages(FWindow.EMFPages).Free;
    FWindow.EMFPages := nil;
    FWindow.PreviewPanel.Hide;
    FWindow.RedrawAll(True);
  end;
end;

procedure TfrPreview.LoadFile(Name: String);
begin
  if FileExists(Name) then
    FWindow.LoadFromFile(Name) else
    Clear;
end;

procedure TfrPreview.OnInternalPageChanged(Sender: TObject);
begin
  if Assigned(FOnPageChanged) then
    FOnPageChanged(Self, Page);
end;

{----------------------------------------------------------------------------}
procedure TfrPBox.WMEraseBackground(var Message: TMessage);
begin
end;

procedure TfrPBox.Paint;
var
  i: Integer;
  r, r1: TRect;
  Pages: TfrEMFPages;
  h: HRGN;
begin
  if not Preview.PaintAllowed then Exit;
  if Preview.EMFPages = nil then
  begin
    Canvas.Brush.Color := clBtnFace;
    Canvas.FillRect(ClientRect);
    Exit;
  end;
  Pages := TfrEMFPages(Preview.EMFPages);
  h := CreateRectRgn(0, 0, Width, Height);
  GetClipRgn(Canvas.Handle, h);

  for i := 0 to Pages.Count - 1 do            // drawing window background
  begin
    r := Pages[i].r;
    OffsetRect(r, Preview.ofx, Preview.ofy);
    if (r.Top > 2000) or (r.Bottom < 0) then
      Pages[i].Visible := False else
      Pages[i].Visible := RectVisible(Canvas.Handle, r);
    if Pages[i].Visible then
      ExcludeClipRect(Canvas.Handle, r.Left + 1, r.Top + 1, r.Right - 1, r.Bottom - 1);
  end;
  with Canvas do
  begin
    Brush.Color := clGray;
    FillRect(Rect(0, 0, Width, Height));
    Pen.Color := clBlack;
    Pen.Width := 1;
    Pen.Mode := pmCopy;
    Pen.Style := psSolid;
    Brush.Color := clWhite;
  end;

  SelectClipRgn(Canvas.Handle, h);
  for i := 0 to Pages.Count - 1 do            // drawing page background
    if Pages[i].Visible then
    begin
      r := Pages[i].r;
      OffsetRect(r, Preview.ofx, Preview.ofy);
      Canvas.Rectangle(r.Left, r.Top, r.Right, r.Bottom);
      Canvas.Polyline([Point(r.Left + 1, r.Bottom),
                       Point(r.Right, r.Bottom),
                       Point(r.Right, r.Top + 1)]);
    end;

  for i := 0 to Pages.Count - 1 do           // drawing page content
  begin
    if Pages[i].Visible then
    begin
      r := Pages[i].r;
      OffsetRect(r, Preview.ofx, Preview.ofy);
      if Pages[i].UseMargins then
        Pages.Draw(i, Canvas, r)
      else
      begin
        with Preview, Pages[i].PrnInfo, Pages[i].pgMargins do
        begin
          r1.Left := Round((Ofx + Left) * per);
          r1.Top := Round((Ofy + Top) * per);
          r1.Right := r1.Left + Round((Pw - (Left + Right)) * per);
          r1.Bottom := r1.Top + Round((Ph - (Top + Bottom)) * per);
          Inc(r1.Left, r.Left); Inc(r1.Right, r.Left);
          Inc(r1.Top, r.Top); Inc(r1.Bottom, r.Top);
        end;
        Pages.Draw(i, Canvas, r1);
      end;
    end
    else
      Pages.Draw(i, Canvas, Rect(0, 0, 0, 0)); // remove it from cache
  end;
  DeleteObject(h);
end;

procedure TfrPBox.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i, j: Integer;
  pt: TPoint;
  r: TRect;
  C: TCursor;
  mess: string;
begin
  if Preview.EMFPages = nil then Exit;
  if DFlag then
  begin
    DFlag := False;
    Exit;
  end;

  with Preview do
  if Button = mbLeft then
  begin
//    LastClick := 0;
    LastClick := CurPage;
    pt := Point(x - ofx, y - ofy);
    for i := 0 to TfrEMFPages(EMFPages).Count - 1 do
    begin
      r := TfrEMFPages(EMFPages)[i].r;
      if PtInRect(r, pt) then
      begin
        LastClick := i + 1;
        if TfrEMFPages(EMFPages).DoClick(i, Point(Round((pt.X - r.Left) / per), Round((pt.Y - r.Top) / per)), True, C, mess) then
        begin
          j := Pos ('@', mess);
          if (j > 0) and (j < Length(mess)) then
          begin
            j := StrToInt(Copy(mess, j+1, Length(mess)-j));
            if j < 1 then
              j := 1;
            if j <= TfrEMFPages(EMFPages).Count then
            begin
              CurPage := j;
              ShowPageNum;
              SetToCurPage;
            end;
          end;
          Exit;
        end;
      end;
    end;
    Down := True;
    LastX := X; LastY := Y;
    CurPage := LastClick;
    ShowPageNum;
  end
  else if Button = mbRight then
  begin
    pt := Self.ClientToScreen(Point(X, Y));
    if (frDesignerClass <> nil) and TfrReport(Doc).ModifyPrepared then
    begin
      N4.Visible := True;
      N5.Visible := True;
      N6.Visible := True;
      N7.Visible := True;
    end;
    if THackControl(Preview.PreviewPanel.Parent).PopupMenu = nil then
      ProcMenu.Popup(pt.x, pt.y) else
      THackControl(Preview.PreviewPanel.Parent).PopupMenu.Popup(pt.x, pt.y);
  end;
end;

procedure TfrPBox.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  i, j: Integer;
  pt: TPoint;
  r: TRect;
  C: TCursor;
  mess: string;
begin
  if Preview.EMFPages = nil then Exit;
  if Down then
  begin
    Preview.HScrollBar.Position := Preview.HScrollBar.Position - (X - LastX);
    Preview.VScrollBar.Position := Preview.VScrollBar.Position - (Y - LastY);
    LastX := X; LastY := Y;
  end
  else
  with Preview do
  if (Doc <> nil) {and Assigned(TfrReport(Doc).OnMouseOverObject }then
  begin
    pt := Point(x - ofx, y - ofy);
    for i := 0 to TfrEMFPages(EMFPages).Count - 1 do
    begin
      r := TfrEMFPages(EMFPages)[i].r;
      if PtInRect(r, pt) then
      begin
        C := crDefault;
        pt := Point(Round((pt.X - r.Left) / per), Round((pt.Y - r.Top) / per));
        mess := '';
        if TfrEMFPages(EMFPages).DoClick(i, pt, False, C, mess) then
          Self.Cursor := C
        else
          Self.Cursor := crDefault;
        j := Pos ('@', mess);
        if (j > 0) and (j < Length(mess)) then
        begin
          j := StrToInt(Copy(mess, j+1, Length(mess)-j));
          mess := frLoadStr(SPg) + ' ' + IntToStr(j);
        end;
        Label2.Caption := mess;
        break;
      end;
    end;
  end;
end;


procedure TfrPBox.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  Down := False;
end;

procedure TfrPBox.DblClick;
begin
  Down := False;
  DFlag := True;
  if (Preview.EMFPages = nil) or (LastClick = 0) then Exit;
  with Preview do
  begin
    CurPage := LastClick;
    if N5.Visible then EditBtnClick(nil);
  end;
end;


{----------------------------------------------------------------------------}
procedure TfrPreviewForm.Localize;
begin
  N1.Caption := frLoadStr(frRes + 020);
  N2.Caption := frLoadStr(frRes + 021);
  N3.Caption := frLoadStr(frRes + 022);
  N5.Caption := frLoadStr(frRes + 029);
  N6.Caption := frLoadStr(frRes + 030);
  N7.Caption := frLoadStr(frRes + 031);

  ZoomBtn.Hint := frLoadStr(frRes + 024);
  LoadBtn.Hint := frLoadStr(frRes + 025);
  SaveBtn.Hint := frLoadStr(frRes + 026);
  PrintBtn.Hint := frLoadStr(frRes + 027);
  FindBtn.Hint := frLoadStr(frRes + 028);
  HelpBtn.Hint := frLoadStr(frRes + 032);
  ExitBtn.Hint := frLoadStr(frRes + 023);
end;

procedure TfrPreviewForm.FormCreate(Sender: TObject);
begin
{$IFDEF GEDEMIN}  //!!!
  ShowSpeedButton := True;
  UseDesigner := False;

  Printer.Refresh;
{$ENDIF}  //!!
  
  PBox := TfrPBox.Create(Self);
  with PBox do
  begin
    Parent := ScrollBox1;
    Align := alClient;
    BevelInner := bvNone;
    BevelOuter := bvNone;
    Color := clGray;
    Preview := Self;
    Tag := 207;
  end;

{$IFDEF Delphi4}
  ScrollBox1.OnMouseWheelUp := FormMouseWheelUp;
  ScrollBox1.OnMouseWheelDown := FormMouseWheelDown;
{$ENDIF}
  KWheel := 1;
end;

procedure TfrPreviewForm.FormDestroy(Sender: TObject);
begin
  if EMFPages <> nil then
    TfrEMFPages(EMFPages).Free;
  EMFPages := nil;
  PBox.Free;
  //Application.ProcessMessages;
end;

procedure TfrPreviewForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if FormStyle <> fsMDIChild then
    SaveFormPosition(Self);
  {$IFDEF GEDEMIN}
  if FMinimize then
  begin
    Action := caHide;
    FMinimize := False;
  end else
    Action := caFree;
  {$ELSE}
  Action := caFree;
  {$ENDIF}
end;

procedure TfrPreviewForm.FormShow(Sender: TObject);
begin
  {$IFDEF GEDEMIN}
  Caption := Caption;
  {$ENDIF}
  Localize;
  if FormStyle <> fsMDIChild then
  begin
    RestoreFormPosition(Self);
{$IFDEF Delphi9}
    FormResize(nil);
{$ENDIF}
  end else
    WindowState := wsNormal;
end;

procedure TfrPreviewForm.FormActivate(Sender: TObject);
begin
  Application.HelpFile := 'FRuser.hlp';
  ActiveControl := ScrollBox1;
end;

procedure TfrPreviewForm.FormDeactivate(Sender: TObject);
begin
  Application.HelpFile := HF;
end;

procedure TfrPreviewForm.InitButtons;
var
  Ini: TRegIniFile;
  GrayedButtons: Boolean;
begin
  if not (csDesigning in TfrReport(Doc).ComponentState) then
  begin
    ZoomBtn.Visible := pbZoom in TfrReport(Doc).PreviewButtons;
    LoadBtn.Visible := pbLoad in TfrReport(Doc).PreviewButtons;
    SaveBtn.Visible := pbSave in TfrReport(Doc).PreviewButtons;
    PrintBtn.Visible := pbPrint in TfrReport(Doc).PreviewButtons;
    FindBtn.Visible := pbFind in TfrReport(Doc).PreviewButtons;
    HelpBtn.Visible := (pbHelp in TfrReport(Doc).PreviewButtons) and
      (TPanel.Parent = Self);
    ExitBtn.Visible := (pbExit in TfrReport(Doc).PreviewButtons) and
      (TPanel.Parent = Self);
    PageSetupBtn.Visible := (pbPageSetup in TfrReport(Doc).PreviewButtons);
    if not ZoomBtn.Visible then
      frTBSeparator1.Hide;
    frTBSeparator3.Visible := FindBtn.Visible or HelpBtn.Visible;
  end;

  PrintBtn.Enabled := Printer.Printers.Count > 0;
  PageSetupBtn.Enabled := PrintBtn.Enabled;
  if (frDesignerClass = nil) or not TfrReport(Doc).ModifyPrepared then
  begin
    N4.Visible := False;
    N5.Visible := False;
    N6.Visible := False;
    N7.Visible := False;
  end;

  case TfrReport(Doc).InitialZoom of
    pzPageWidth: LastScaleMode := mdPageWidth;
    pzOnePage: LastScaleMode := mdOnePage;
    pzTwoPages:  LastScaleMode := mdTwoPages;
  end;

  Ini := TRegIniFile.Create('Software\FastReport\' + Application.Title);
  GrayedButtons := TfrReport(Doc).GrayedButtons;
  if frDesignerClass <> nil then
    GrayedButtons := Ini.ReadBool('Form\TfrDesignerForm', 'GrayButtons', False);
  SetGrayedButtons(GrayedButtons);
  Ini.Free;
end;

procedure TfrPreviewForm.Show_Modal(ADoc: Pointer);
begin
  Connect(ADoc);
  InitButtons;
  RedrawAll(True);
  HScrollBar.Position := 0;
  VScrollBar.Position := 0;

  HF := Application.HelpFile;
  if TfrReport(Doc).ModalPreview then
    ShowModal else
    Show;
end;

procedure TfrPreviewForm.Connect(ADoc: Pointer);
begin
  Doc := ADoc;
  if EMFPages <> nil then
    TfrEMFPages(EMFPages).Free;
  EMFPages := TfrReport(Doc).EMFPages;
  TfrReport(Doc).EMFPages := TfrEMFPages.Create(Doc);
end;

procedure TfrPreviewForm.ConnectBack;
begin
  TfrReport(Doc).EMFPages.Free;
  TfrReport(Doc).EMFPages := TfrEMFPages(EMFPages);
  EMFPages := nil;
end;

procedure TfrPreviewForm.SetGrayedButtons(Value: Boolean);
var
  i: Integer;
  c: TControl;
begin
  for i := 0 to Panel1.ControlCount - 1 do
  begin
    c := Panel1.Controls[i];
    if c is TfrTBButton then
      TfrTBButton(c).GrayedInactive := Value;
  end;
end;

procedure TfrPreviewForm.RedrawAll(ResetPage: Boolean);
var
  i: Integer;
begin
  per := LastScale;
  mode := LastScaleMode;
  if mode = mdPageWidth then
    N1.Checked := True
  else if mode = mdOnePage then
    N2.Checked := True
  else if mode = mdTwoPages then
    N3.Checked := True
  else
    for i := 0 to ProcMenu.Items.Count - 1 do
      if ProcMenu.Items[i].Tag = per * 100 then
        ProcMenu.Items[i].Checked := True;

  if ResetPage then
  begin
    CurPage := 1;
    ofx := 0; ofy := 0; OldH := 0; OldV := 0;
    HScrollBar.Position := 0;
    VScrollBar.Position := 0;
  end;
  ShowPageNum;
  FormResize(nil);
  if EMFPages <> nil then
  begin
    for i := 0 to TfrEMFPages(EMFPages).Count - 1 do
    begin
      TfrEMFPages(EMFPages)[i].Visible := False;
      TfrEMFPages(EMFPages).Draw(i, Canvas, Rect(0, 0, 0, 0));
    end;
    N7.Enabled := TfrEMFPages(EMFPages).Count > 1;
  end;
  PBox.Repaint;
end;

procedure TfrPreviewForm.FormResize(Sender: TObject);
var
  i, j, y, d, nx, dwx, dwy, maxx, maxy, maxdy, curx: Integer;
  Pages: TfrEMFPages;
begin
  if EMFPages = nil then Exit;
  Pages := TfrEMFPages(EMFPages);
  PaintAllowed := False;
  with Pages[CurPage - 1].PrnInfo do
  begin
    dwx := Pgw; dwy := Pgh;
  end;
  case mode of
    mdNone:
      begin
        for i := 0 to ProcMenu.Items.Count - 1 do
          if ProcMenu.Items[i].Tag = Round(per * 100) then
            ProcMenu.Items[i].Checked := True;
      end;
    mdPageWidth:
      begin
        per := (PBox.Width - 20) / dwx;
        N1.Checked := True;
      end;
    mdOnePage:
      begin
        per := (PBox.Height - 20) / dwy;
        N2.Checked := True;
      end;
    mdTwoPages:
      begin
        per := (PBox.Width - 30) / (2 * dwx);
        N3.Checked := True;
      end;
  end;
  ZoomBtn.Caption := IntToStr(Round(per * 100)) + '%';
  nx := 0; maxx := 10; j := 0;
  for i := 0 to Pages.Count - 1 do
  begin
    d := maxx + 10 + Round(Pages[i].PrnInfo.Pgw * per);
    if d > PBox.Width then
    begin
      if nx < j then nx := j;
      j := 0;
      maxx := 10;
    end
    else
    begin
      maxx := d;
      Inc(j);
      if i = Pages.Count - 1 then
        if nx < j then nx := j;
    end;
  end;
  if nx = 0 then nx := 1;
  if mode = mdOnePage then nx := 1;
  if mode = mdTwoPages then nx := 2;
  y := 10;
  i := 0;
  maxx := 0; maxy := 0;
  while i < Pages.Count do
  begin
    j := 0; maxdy := 0; curx := 10;
    while (j < nx) and (i + j < Pages.Count) do
    begin
      dwx := Round(Pages[i + j].PrnInfo.Pgw * per);
      dwy := Round(Pages[i + j].PrnInfo.Pgh * per);
      if (nx = 1) and (dwx < PBox.Width) then
      begin
        d := (PBox.Width - dwx) div 2;
        Pages[i + j].r := Rect(d, y, d + dwx, y + dwy);
      end
      else
        Pages[i + j].r := Rect(curx, y, curx + dwx, y + dwy);
      if maxx < Pages[i + j].r.Right then
        maxx := Pages[i + j].r.Right;
      if maxy < Pages[i + j].r.Bottom then
        maxy := Pages[i + j].r.Bottom;
      Inc(j);
      if maxdy < dwy then maxdy := dwy;
      Inc(curx, dwx + 10);
    end;
    Inc(y, maxdy + 10);
    Inc(i, nx);
  end;
  PgDown.Top := RPanel.Height - 16;
  PgUp.Top := PgDown.Top - 16;
  VScrollBar.Height := PgUp.Top - 1;
  if RPanel.Visible then
    HScrollBar.Width := BPanel.Width - HScrollBar.Left - VScrollBar.Width else
    HScrollBar.Width := BPanel.Width - HScrollBar.Left;
  maxx := maxx - PBox.Width;
  maxy := maxy - PBox.Height;
  if maxx < 0 then maxx := 0 else Inc(maxx, 10);
  if maxy < 0 then maxy := 0 else Inc(maxy, 10);
  HScrollBar.Max := maxx; VScrollBar.Max := maxy;
  HScrollBar.Enabled := maxx <> 0;
  VScrollBar.Enabled := maxy <> 0;
  if Visible then
    ActiveControl := ScrollBox1;
  SetToCurPage;
  PaintAllowed := True;
end;

procedure TfrPreviewForm.SetToCurPage;
begin
  if EMFPages = nil then Exit;
  if ofy <> TfrEMFPages(EMFPages)[CurPage - 1].r.Top - 10 then
    VScrollBar.Position := TfrEMFPages(EMFPages)[CurPage - 1].r.Top - 10;
end;

procedure TfrPreviewForm.ShowPageNum;
begin
  if EMFPages = nil then
    Label1.Caption := ''
  else
  begin
    if Assigned(FOnPageChanged) then
      FOnPageChanged(Self);
    Label1.Caption := frLoadStr(SPg) + ' ' + IntToStr(CurPage) + '/' +
      IntToStr(TfrEMFPages(EMFPages).Count);
  end;
end;

procedure TfrPreviewForm.VScrollBarChange(Sender: TObject);
var
  i, p, pp: Integer;
  r: TRect;
  Pages: TfrEMFPages;
begin
  if EMFPages = nil then Exit;
  Pages := TfrEMFPages(EMFPages);
  p := VScrollBar.Position;
  pp := OldV - p;
  OldV := p;
  ofy := -p;
  r := Rect(0, 0, PBox.Width, PBox.Height);
  ScrollWindow(PBox.Handle, 0, pp, @r, @r);

  for i := 0 to Pages.Count-1 do
    if (Pages[i].r.Top < -ofy + 11) and
      (Pages[i].r.Bottom > -ofy + 11) then
    begin
      CurPage := i + 1;
      ShowPageNum;
      break;
    end;
end;

procedure TfrPreviewForm.HScrollBarChange(Sender: TObject);
var
  p, pp: Integer;
  r: TRect;
begin
  if EMFPages = nil then Exit;
  p := HScrollBar.Position;
  pp := OldH - p;
  OldH := p;
  ofx := -p;
  r := Rect(0, 0, PBox.Width, PBox.Height);
  ScrollWindow(PBox.Handle, pp, 0, @r, @r);
end;

procedure TfrPreviewForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if EMFPages = nil then Exit;
  if Key = vk_Up then
    VScrollBar.Position := VScrollBar.Position - VScrollBar.SmallChange
  else if Key = vk_Down then
    VScrollBar.Position := VScrollBar.Position + VScrollBar.SmallChange
  else if Key = vk_Left then
    HScrollBar.Position := HScrollBar.Position - HScrollBar.SmallChange
  else if Key = vk_Right then
    HScrollBar.Position := HScrollBar.Position + HScrollBar.SmallChange
  else if Key = vk_Prior then
    if ssCtrl in Shift then
      PgUpClick(nil) else
      VScrollBar.Position := VScrollBar.Position - VScrollBar.LargeChange
  else if Key = vk_Next then
    if ssCtrl in Shift then
      PgDownClick(nil) else
      VScrollBar.Position := VScrollBar.Position + VScrollBar.LargeChange
  else if Key = vk_Space then
    ZoomBtnClick(nil)
  //!!!b
{  else if Key = vk_Escape then
    ExitBtnClick(nil)}
  //!!!e  
  else if Key = vk_Home then
    if ssCtrl in Shift then
      VScrollBar.Position := 0 else
      Exit
  else if Key = vk_End then
    if ssCtrl in Shift then
    begin
      CurPage := TfrEMFPages(EMFPages).Count;
      SetToCurPage;
    end
    else Exit
  else if ssCtrl in Shift then
  begin
    if Chr(Key) = 'O' then LoadBtnClick(nil)
    else if Chr(Key) = 'S' then SaveBtnClick(nil)
    else if (Chr(Key) = 'P') and PrintBtn.Enabled then PrintBtnClick(nil)
    else if Chr(Key) = 'F' then FindBtnClick(nil)
    else if (Chr(Key) = 'E') and N5.Visible then EditBtnClick(nil)
  end
  else if Key = vk_F3 then
  begin
    if FindStr <> '' then
    begin
      if LastFoundPage <> CurPage - 1 then
      begin
        LastFoundPage := CurPage - 1;
        LastFoundObject := 0;
      end;
      FindText;
    end;
  end
  else Exit;
  Key := 0;
end;

procedure TfrPreviewForm.PgUpClick(Sender: TObject);
begin
  if CurPage > 1 then Dec(CurPage);
  ShowPageNum;
  SetToCurPage;
end;

procedure TfrPreviewForm.PgDownClick(Sender: TObject);
begin
  if EMFPages = nil then Exit;
  if CurPage < TfrEMFPages(EMFPages).Count then Inc(CurPage);
  ShowPageNum;
  SetToCurPage;
end;

procedure TfrPreviewForm.ZoomBtnClick(Sender: TObject);
var
  pt: TPoint;
begin
  pt := ZoomBtn.ClientToScreen(Point(ZoomBtn.Left, ZoomBtn.Top + ZoomBtn.Height));
  N4.Visible := False;
  N5.Visible := False;
  N6.Visible := False;
  N7.Visible := False;
  ProcMenu.Popup(pt.x, pt.y);
end;

procedure TfrPreviewForm.N3Click(Sender: TObject);
begin
  if EMFPages = nil then Exit;
  ofx := 0;
  with Sender as TMenuItem do
  begin
    case Tag of
      1: mode := mdPageWidth;
      2: mode := mdOnePage;
      3: mode := mdTwoPages;
    else
      begin
        mode := mdNone;
        per := Tag / 100;
      end;
    end;
    Checked := True;
  end;
  HScrollBar.Position := 0;
  FormResize(nil);
  LastScale := per;
  LastScaleMode := mode;
  PBox.Repaint;
end;

procedure TfrPreviewForm.LoadBtnClick(Sender: TObject);
begin
  if EMFPages = nil then Exit;
  OpenDialog.Filter := frLoadStr(SRepFile) + ' (*.frp)|*.frp';
  with OpenDialog do
   if Execute then
     LoadFromFile(FileName);
end;

procedure TfrPreviewForm.SaveBtnClick(Sender: TObject);
var
  i, n: Integer;
  s: String;
begin
  if EMFPages = nil then Exit;

  {$IFDEF GEDEMIN}
  if not TestUserRights then
    exit;
  {$ENDIF}

  s := frLoadStr(SRepFile) + ' (*.frp)|*.frp';
  for i := 0 to frFiltersCount - 1 do
    s := s + '|' + frFilters[i].FilterDesc + '|' + frFilters[i].FilterExt;
  n := 1;
  for i := 0 to frFiltersCount - 1 do
    if frFilters[i].Filter.Default then
    begin
      n := i + 2;
      break;
    end;
  with SaveDialog do
  begin
    Filter := s;
    FilterIndex := n;
    if Execute then
      if FilterIndex = 1 then
        SaveToFile(FileName)
      else
      begin
        ConnectBack;
        TfrReport(Doc).ExportTo(frFilters[FilterIndex - 2].Filter,
          ChangeFileExt(FileName, Copy(frFilters[FilterIndex - 2].FilterExt, 2, 255)));
        Connect(Doc);
        RedrawAll(False);
      end;
  end;
end;

procedure TfrPreviewForm.PrintBtnClick(Sender: TObject);
var
  Pages: String;
  ind: integer;
begin
  if (EMFPages = nil) or (Printer.Printers.Count = 0) then Exit;

  //!!!b
  {$IFDEF GEDEMIN}
  if not TestUserRights then
    exit;
  {$ENDIF}
  //!!!e

  with TfrPrintForm.Create(nil) do
  begin
    {$IFDEF GEDEMIN}
      if Assigned(UserStorage) then begin
      //  E1.Text:= IntToStr(UserStorage.ReadInteger('Options\PrinterSettings', 'Copies', 1, False));
        CollateCB.Checked:= UserStorage.ReadBoolean('Options\PrinterSettings', 'Collate', True, False);
      end;
    {$ENDIF}
    ind := Printer.PrinterIndex;
    if not TfrReport(Doc).ShowPrintDialog or (ShowModal = mrOk) then
    begin
     if CurReport.RebuildPrinter then
      if Printer.PrinterIndex <> ind then
        if TfrReport(Doc).CanRebuild then
          if TfrReport(Doc).ChangePrinter(ind, Printer.PrinterIndex) then
          begin
            TfrEMFPages(EMFPages).Free;
            EMFPages := nil;
            TfrReport(Doc).PrepareReport;
            Connect(Doc);
          end
          else
          begin
            Free;
            Exit;
          end;

      if RB1.Checked then
        Pages := ''
      else if RB2.Checked then
        Pages := IntToStr(CurPage)
      else
        Pages := E2.Text;
      ConnectBack;
      TfrReport(Doc).PrintPreparedReport(Pages, StrToInt(E1.Text),
        CollateCB.Checked, TfrPrintPages(CB2.ItemIndex));
      Connect(Doc);
      RedrawAll(False);
    end;
    Free;
  end;
end;

procedure TfrPreviewForm.ExitBtnClick(Sender: TObject);
begin
  if Doc = nil then Exit;
  if TfrReport(Doc).ModalPreview then
    ModalResult := mrOk else
    Close;
end;

procedure TfrPreviewForm.LoadFromFile(name: String);
begin
  if Doc = nil then Exit;
  TfrEMFPages(EMFPages).Free;
  EMFPages := nil;
  TfrReport(Doc).LoadPreparedReport(name);
  Connect(Doc);
  CurPage := 1;
  FormResize(nil);
  PaintAllowed := False;
  ShowPageNum;
  SetToCurPage;
  PaintAllowed := True;
  PBox.Repaint;
end;

procedure TfrPreviewForm.SaveToFile(name:String);
begin
  if Doc = nil then Exit;
  name := ChangeFileExt(name, '.frp');
  ConnectBack;
  TfrReport(Doc).SavePreparedReport(name);
  Connect(Doc);
end;


function EnumEMFRecordsProc(DC: HDC; HandleTable: PHandleTable;
  EMFRecord: PEnhMetaRecord; nObj: Integer; OptData: Pointer): Bool; stdcall;
var
  Typ: Byte;
  s: String;
  t: TEMRExtTextOut;
begin
  Result := True;
  Typ := EMFRecord^.iType;
  if Typ in [83, 84] then
  begin
    t := PEMRExtTextOut(EMFRecord)^;
    s := WideCharLenToString(PWideChar(PChar(EMFRecord) + t.EMRText.offString),
      t.EMRText.nChars);
    if not CurPreview.CaseSensitive then s := AnsiUpperCase(s);
    CurPreview.StrFound := Pos(CurPreview.FindStr, s) <> 0;
    if CurPreview.StrFound and (RecordNum >= CurPreview.LastFoundObject) then
    begin
      CurPreview.StrBounds := t.rclBounds;
      Result := False;
    end;
  end;
  Inc(RecordNum);
end;

procedure TfrPreviewForm.FindInEMF(emf: TMetafile);
begin
  CurPreview := Self;
  RecordNum := 0;
  EnumEnhMetafile(0, emf.Handle, @EnumEMFRecordsProc, nil, Rect(0, 0, 0, 0));
end;

procedure TfrPreviewForm.FindText;
var
  EMF: TMetafile;
  EMFCanvas: TMetafileCanvas;
  PageInfo: PfrPageInfo;
  i, nx, ny, ndx, ndy: Integer;
begin
  PaintAllowed := False;
  StrFound := False;
  while LastFoundPage < TfrEMFPages(EMFPages).Count do
  begin
    PageInfo := TfrEMFPages(EMFPages)[LastFoundPage];
    EMF := TMetafile.Create;
    EMF.Width := PageInfo.PrnInfo.PgW;
    EMF.Height := PageInfo.PrnInfo.PgH;
    EMFCanvas := TMetafileCanvas.Create(EMF, 0);
    PageInfo.Visible := True;
    TfrEMFPages(EMFPages).Draw(LastFoundPage, EMFCanvas,
      Rect(0, 0, PageInfo.PrnInfo.PgW, PageInfo.PrnInfo.PgH));
    EMFCanvas.Free;

    FindInEMF(EMF);
    EMF.Free;
    if StrFound then
    begin
      CurPage := LastFoundPage + 1;
      ShowPageNum;
      nx := PageInfo.r.Left + Round(StrBounds.Left * per);
      ny := Round(StrBounds.Top * per) + 10;
      ndx := Round((StrBounds.Right - StrBounds.Left) * per);
      ndy := Round((StrBounds.Bottom - StrBounds.Top) * per);

      if ny > PBox.Height - ndy then
      begin
        VScrollBar.Position := PageInfo.r.Top + ny - PBox.Height - 10 + ndy;
        ny := PBox.Height - ndy;
      end
      else
        VScrollBar.Position := PageInfo.r.Top - 10;

      if nx > PBox.Width - ndx then
      begin
        HScrollBar.Position := PageInfo.r.Left + nx - PBox.Width - 10 + ndx;
        nx := PBox.Width - ndx;
      end
      else
        HScrollBar.Position := PageInfo.r.Left - 10;

      LastFoundObject := RecordNum;
      Application.ProcessMessages;

      PaintAllowed := True;
      PBox.Paint;
      with PBox.Canvas do
      begin
        Pen.Width := 1;
        Pen.Mode := pmXor;
        Pen.Color := clWhite;
        for i := 0 to ndy do
        begin
          MoveTo(nx, ny + i);
          LineTo(nx + ndx, ny + i);
        end;
        Pen.Mode := pmCopy;
      end;
      break;
    end
    else
    begin
      PageInfo.Visible := False;
      TfrEMFPages(EMFPages).Draw(LastFoundPage, EMFCanvas,
        Rect(0, 0, PageInfo.PrnInfo.PgW, PageInfo.PrnInfo.PgH));
    end;
    LastFoundObject := 0;
    Inc(LastFoundPage);
  end;
  PaintAllowed := True;
end;

procedure TfrPreviewForm.FindBtnClick(Sender: TObject);
var
  p: TfrPreviewSearchForm;
begin
  if Doc = nil then Exit;
  p := TfrPreviewSearchForm.Create(nil);
  with p do
  if ShowModal = mrOk then
  begin
    FindStr := Edit1.Text;
    CaseSensitive := CB1.Checked;
    if not CaseSensitive then FindStr := AnsiUpperCase(FindStr);
    if RB1.Checked then
    begin
      LastFoundPage := 0;
      LastFoundObject := 0;
    end
    else if LastFoundPage <> CurPage - 1 then
    begin
      LastFoundPage := CurPage - 1;
      LastFoundObject := 0;
    end;
    FindText;
  end;
  p.Free;
end;

//
{
procedure TfrPreviewForm.FindBtnClick(Sender: TObject);
var
   p: TfrPreviewSearchForm;
begin
   if Doc = nil then Exit;
   p := TfrPreviewSearchForm.Create(Self);
   with p do
   if ShowModal = mrOk then
   begin
     FindStr := Edit1.Text;
     CaseSensitive := CB1.Checked;
     if not CaseSensitive then FindStr := AnsiUpperCase(FindStr);
     if RB1.Checked then
     begin
       LastFoundPage := 0;
       LastFoundObject := 0;
     end
     else if LastFoundPage <> CurPage - 1 then
     begin
       LastFoundPage := CurPage - 1;
       LastFoundObject := 0;
     end;
     Free;
     FindText;
   end
   else
     Free;
end;
}
//

procedure TfrPreviewForm.EditBtnClick(Sender: TObject);
begin
  if (Doc = nil) or not TfrReport(Doc).ModifyPrepared then Exit;

  //!!!b
  {$IFDEF GEDEMIN}
  if Assigned(IBLogin) and ((IBLogin.InGroup and
    (GD_UG_ADMINISTRATORS or GD_UG_POWERUSERS or GD_UG_PRINTOPERATORS)) = 0) then
  begin
    MessageBox(Handle,
      'Только пользователи входящие в группы "Администраторы",'#13#10 +
      '"Опытные пользователи" или "Операторы печати" имеют право'#13#10 +
      'изменять текст отчета перед отправкой на печать.',
      'Внимание',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
    exit;  
  end;
  {$ENDIF}
  //!!!e

  ConnectBack;
  TfrReport(Doc).EditPreparedReport(CurPage - 1);
  Connect(Doc);
  RedrawAll(False);
end;

procedure TfrPreviewForm.DelPageBtnClick(Sender: TObject);
begin
  if Doc = nil then Exit;
  if TfrEMFPages(EMFPages).Count > 1 then
    if MessageBox(Handle, PChar(frLoadStr(SRemovePg)), PChar(frLoadStr(SConfirm)),
      mb_YesNo or MB_IconQuestion) = mrYes then
    begin
      TfrEMFPages(EMFPages).Delete(CurPage - 1);
      RedrawAll(True);
    end;
end;

procedure TfrPreviewForm.NewPageBtnClick(Sender: TObject);
begin
  if Doc = nil then Exit;
  TfrEMFPages(EMFPages).Insert(CurPage - 1, TfrReport(Doc).Pages[0]);
  RedrawAll(False);
end;

procedure TfrPreviewForm.PageSetupBtnClick(Sender: TObject);
var
  psd: TPageSetupDlg;
  pg: PfrPageInfo;
  pg1: TfrPage;
  i: Integer;

  procedure SetPrinter(DeviceMode, DeviceNames: THandle);
  var
    DevNames: PDevNames;
  begin
    DevNames := PDevNames(GlobalLock(DeviceNames));
    try
      with DevNames^ do
        Printer.SetPrinter(PChar(DevNames) + wDeviceOffset,
          PChar(DevNames) + wDriverOffset,
          PChar(DevNames) + wOutputOffset, DeviceMode);
    finally
      GlobalUnlock(DeviceNames);
      GlobalFree(DeviceNames);
    end;
  end;

begin
  if EMFPages = nil then Exit;
  psd.lStructSize := SizeOf(TPageSetupDlg);
  psd.hwndOwner := ScrollBox1.Handle;
  psd.hDevMode := prn.DevMode;
  psd.hDevNames := 0;
  psd.Flags := PSD_DEFAULTMINMARGINS or PSD_MARGINS or PSD_INHUNDREDTHSOFMILLIMETERS;

  pg := TfrEMFPages(EMFPages)[0];
  psd.rtMargin.Left := pg^.pgMargins.Left * 500 div 18;
  psd.rtMargin.Top := pg^.pgMargins.Top * 500 div 18;
  psd.rtMargin.Right := pg^.pgMargins.Right * 500 div 18;
  psd.rtMargin.Bottom := pg^.pgMargins.Bottom * 500 div 18;

  if PageSetupDlg(psd) then
  begin
    SetPrinter(psd.hDevMode, psd.hDevNames);
    Prn.Update;

    for i := 0 to TfrReport(Doc).Pages.Count - 1 do
    begin
      pg1 := TfrReport(Doc).Pages[i];
      if pg1.PageType = ptReport then
      begin
        pg1.pgMargins.Left := psd.rtMargin.Left * 18 div 500;
        pg1.pgMargins.Top := psd.rtMargin.Top * 18 div 500;
        pg1.pgMargins.Right := psd.rtMargin.Right * 18 div 500;
        pg1.pgMargins.Bottom := psd.rtMargin.Bottom * 18 div 500;
        pg1.ChangePaper(Prn.PaperSize, 0, 0, Prn.Bin, Prn.Orientation);
      end;
    end;

    TfrReport(Doc).PrepareReport;
    TfrEMFPages(EMFPages).Free;
    EMFPages := nil;
    Connect(Doc);
    RedrawAll(True);
  end;
end;

type
  THackBtn = class(TfrSpeedButton)
  end;

procedure TfrPreviewForm.HelpBtnClick(Sender: TObject);
begin
  Screen.Cursor := crHelp;
  SetCapture(Handle);
  THackBtn(HelpBtn).FMouseInControl := False;
  HelpBtn.Invalidate;
end;

procedure TfrPreviewForm.FormMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  c: TControl;
begin
  HelpBtn.Down := False;
  Screen.Cursor := crDefault;
  c := frControlAtPos(Self, Point(X, Y));
  if (c <> nil) and (c <> HelpBtn) then
    Application.HelpCommand(HELP_CONTEXTPOPUP, {c.Tag}163); //!!! andreik
end;

{$IFDEF Delphi4}
procedure TfrPreviewForm.FormMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  VScrollBar.Position := VScrollBar.Position - VScrollBar.SmallChange * KWheel;
end;

procedure TfrPreviewForm.FormMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  VScrollBar.Position := VScrollBar.Position + VScrollBar.SmallChange * KWheel;
end;
{$ENDIF}

procedure TfrPreviewForm.HScrollBarEnter(Sender: TObject);
begin
  ActiveControl := ScrollBox1;
end;

procedure TfrPreviewForm.CMDialogKey(var Message: TCMDialogKey);
begin
// empty method
end;

{$IFDEF GEDEMIN}
procedure TfrPreviewForm.WMSysCommand(var Message: TMessage);
begin
  case Message.WParam and $FFF0 of
    SC_MINIMIZE: FMinimize := True;
  end;
  inherited;
end;

function TfrPreviewForm.TestUserRights: Boolean;
begin
  Result := False;

{$IFDEF GEDEMIN_LOCK}
  if not RegParams.CheckRegistration(True, 'Печать и сохранение документа в файл невозможны.') then
    exit;
{$ENDIF}

  if Assigned(GlobalStorage) and Assigned(IBLogin)
    and ((GlobalStorage.ReadInteger('Options\Policy',
      GD_POL_PRINT_ID, GD_POL_PRINT_MASK, False) and IBLogin.InGroup) = 0) then
  begin
    MessageBox(Handle,
      'Печать и сохранение документов в файл запрещены'#13#10 +
      'текущими настройками политики безопасности.',
      'Отказано в доступе',
      MB_OK or MB_ICONHAND or MB_TASKMODAL);
    exit;
  end;

  Result := True;
end;

{$ENDIF}
end.

