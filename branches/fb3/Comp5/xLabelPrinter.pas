
unit xLabelPrinter;

interface

uses
  Windows,  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Printers;

// все значени€ (пол€, отступы и пр.) у нас в сантиметрах и дол€х сантиметра

const
  DefTopMargin = 0.00;
  DefSideMargin = 0.00;
  DefVertStep = 4.00;
  DefHorzStep = 7.00;
  DefLabelHeight = 4.00;
  DefLabelWidth = 7.00;
  DefHorzCount = 3;
  DefVertCount = 7;
  DefDialogColor = clBtnFace;

type
  PArFont = ^TArFont;
  TArFont = array[0..3] of TFont;

type
  TxLabelPrinter = class(TComponent)
  private
    FLabelName: String;
    FLines: TStringList;
    FSideMargin: Double;
    FTopMargin: Double;
    FHorzStep: Double;
    FLabelHeight: Double;
    FLabelWidth: Double;
    FVertStep: Double;
    FVertCount: Word;
    FHorzCount: Word;
    FFont: TFont;
    FFontA: TArFont;
    FDialogColor: TColor;
    FFromPage, FToPage: Integer;
    FIsAllPage: Boolean;

    procedure SetHorzCount(const Value: Word);
    procedure SetHorzStep(const Value: Double);
    procedure SetLabelHeight(const Value: Double);
    procedure SetLabelWidth(const Value: Double);
    procedure SetLines(const Value: TStringList);
    procedure SetSideMargin(const Value: Double);
    procedure SetTopMargin(const Value: Double);
    procedure SetVertCount(const Value: Word);
    procedure SetVertStep(const Value: Double);
    procedure SetFont(const Value: TFont);
    procedure SetFont0(const Value: TFont);
    procedure SetFont1(const Value: TFont);
    procedure SetFont2(const Value: TFont);
    procedure SetFont3(const Value: TFont);

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    function ShowDialog: Boolean;
    procedure Print;
    procedure DrawPage(const xCanvas: TCanvas; var StartLine: Integer; const Rct: TRect);

  published
    property TopMargin: Double read FTopMargin write SetTopMargin;
    property SideMargin: Double read FSideMargin write SetSideMargin;
    property VertStep: Double read FVertStep write SetVertStep;
    property HorzStep: Double read FHorzStep write SetHorzStep;
    property LabelWidth: Double read FLabelWidth write SetLabelWidth;
    property LabelHeight: Double read FLabelHeight write SetLabelHeight;
    property HorzCount: Word read FHorzCount write SetHorzCount
      default DefHorzCount;
    property VertCount: Word read FVertCount write SetVertCount
      default DefVertCount;
    property Lines: TStringList read FLines write SetLines;
    property LabelName: String read FLabelName write FLabelName;
    property Font: TFont read FFont write SetFont;
    property Font0: TFont read FFontA[0] write SetFont0;
    property Font1: TFont read FFontA[1] write SetFont1;
    property Font2: TFont read FFontA[2] write SetFont2;
    property Font3: TFont read FFontA[3] write SetFont3;
    property DialogColor: TColor read FDialogColor write FDialogColor
      default DefDialogColor;
  end;

procedure Register;

implementation

uses
  dlgLabelProp, Rect;

// TxLabelPrinter

constructor TxLabelPrinter.Create(AnOwner: TComponent);
var
  I: Integer;
begin
  inherited Create(AnOwner);

  // присваиваем значени€ по умолчанию
  FTopMargin := DefTopMargin;
  FSideMargin := DefSideMargin;
  FVertStep := DefVertStep;
  FHorzStep := DefHorzStep;
  FLabelWidth := DefLabelWidth;
  FLabelHeight := DefLabelHeight;
  FVertCount := DefVertCount;
  FHorzCount := DefHorzCount;
  FDialogColor := DefDialogColor;

  FLines := TStringList.Create;
  FFont := TFont.Create;
  for I := 0 to 3 do
    FFontA[I] := TFont.Create;
  FFont.Name := 'Arial';
  FFont.Size := 8;
  FFont.Style := [];
  FFont.Color := clBlack;
  FFont.CharSet := RUSSIAN_CHARSET;
  for I := 0 to 3 do
    FFontA[I].Assign(FFont);
  FIsAllPage := True;
  FFromPage := 0;
  FToPage := 2200;
end;

destructor TxLabelPrinter.Destroy;
var
  I: Integer;
begin
  inherited Destroy;
  FLines.Free;
  FFont.Free;
  for I := 0 to 3 do
    FFontA[I].Free;
end;

procedure TxLabelPrinter.DrawPage(const xCanvas: TCanvas; var StartLine: Integer; const Rct: TRect);
var
  X, Y: Double;
  I, J, K{, L}, Position: Integer;
  R, R1: TRect;
  PointsX, PointsY: Double;
  Ch: array[0..511] of Char;
  S, S1: String;
  OldY: Integer;
//  SP, EP, SP1: Integer;
//  SCount: Integer;
//  STR: Boolean;
begin
  //
  SetTextAlign(xCanvas.Handle, TA_LEFT or TA_TOP or TA_NOUPDATECP);

  // сколько точек принтер печатает в одном сантиметре
  PointsX := GetDeviceCaps(xCanvas.Handle, LOGPIXELSX) / 2.54;
  PointsY := GetDeviceCaps(xCanvas.Handle, LOGPIXELSY) / 2.54;

  if (PointsX = 0) or (PointsY = 0) then
  begin
    ShowMessage('¬озможно Ќеправильный указатель окна');
    StartLine := StartLine + 10000;
    Exit;
  end;

  //
  SetBkMode(xCanvas.Handle, TRANSPARENT);

  // присваиваем шрифт
  xCanvas.Font.Assign(FFont);
  xCanvas.Font.PixelsPerInch := GetDeviceCaps(xCanvas.Handle, LOGPIXELSY);

  Y := FTopMargin;
  for J := 1 to FVertCount do
  begin
    if StartLine >= FLines.Count then
      break;

    X := FSideMargin;

    R.Top := Round(Y * PointsY);
    R.Bottom := R.Top + Round(FLabelHeight * PointsY);


    for I := 1 to FHorzCount do
    begin
      if StartLine >= FLines.Count then
        break;

      R.Left := Round(X * PointsX);
      R.Right := R.Left + Round(FLabelWidth * PointsX);
      K := 0;
      S := FLines[StartLine];
      //Position := 1;
      OldY := R.Top;

      while K <> 4 do
      begin
        Position := Pos(#10#13, S) + 2;
        if Position = 2 then Position := Length(S) + 3;
        xCanvas.Font.Assign(FFontA[K]);
        S1 := Copy(S, 1, Position - 3);
        DrawText(xCanvas.Handle, StrPCopy(Ch, S1{Copy(S, 1, Position)}), -1, R,
          DT_NOPREFIX or DT_WORDBREAK {or DT_CALCRECT});
       { SP := 1;
        EP := 1;
        SP1 := 2;//Length(S1);
        SCount := 0;
        STR := True;
        while (Pos(' ', copy(S1, EP, Length(S1) - EP + 1)) <> 0)
         or (SP < Length(S1)) do
        begin
          while (xCanvas.TextWidth(copy(S1, SP, SP1 - SP)) < (R.Right - R.Left))
           and (EP < SP1) do
          begin
            if not STR then
              EP := SP1;
            SP1 := EP + Pos(' ', copy(S1, EP, Length(S1) - EP + 1));
            STR := False;
            if SP1 = EP then
            begin
             // STR := True;
              SP1 := Length(S1);
            end;
          end;
          STR := True;
          SP := EP;
          SP1 := EP + 1;
          Inc(SCount);
        end; }
       (* for L := 0 to SCount - 1 do
          R.Top := R.Top + xCanvas.TextHeight(S1{Copy(S, 1, Position)});*)
        R1 := R;
        DrawText(xCanvas.Handle, StrPCopy(Ch, S1), -1, R1,
          DT_NOPREFIX or DT_WORDBREAK or DT_CALCRECT);
        R.Top := R1.Bottom;// + xCanvas.TextHeight(Copy(S, 1, Position));

{        DrawText(xCanvas.Handle, StrPCopy(Ch, FLines[StartLine]), -1, R,
          DT_NOPREFIX or DT_WORDBREAK);}
    //    R.Top := R.Top + xCanvas.TextHeight(S1{Copy(S, 1, Position)});
        S := Copy(S, Position, Length(S) - Position + 1);
        Inc(K);
      end;
      R.Top := OldY;
      Inc(StartLine);

      X := X + FHorzStep;
    end;

    Y := Y + FVertStep;
  end;
end;

procedure TxLabelPrinter.Print;
var
  K: Integer;
  LocCanvas: TCanvas;
  PageNum: Integer;
  LastState: Boolean;
  Hn: HDC;
begin
  // начинаем печать
  Printer.Title := ExtractFileName(Application.ExeName) + '-печать наклеек';
  Printer.BeginDoc;

  // „тобы было куда печатать не печатающиес€ страницы
  // ћы не можем точно определить сколько наклее влазит на страницу пока не напечатаем
  // ≈сли считать примерно, то получитс€ как в RTF.
  LocCanvas := TCanvas.Create;
  LocCanvas.Handle := CreateCompatibleDC(Printer.Canvas.Handle);
  try
    K := 0;
    PageNum := 0;
    LastState := False;
    while (K < FLines.Count) and (not Printer.Aborted) do
    begin
      Inc(PageNum);
      // „тобы лишнее не печатало
      if not FIsAllPage and (PageNum > FToPage) then
        Break;
      if {(K > 0) and }(FIsAllPage or ((PageNum >= FFromPage)
       and (PageNum <= FToPage))) and LastState then
        Printer.NewPage;

      if FIsAllPage or ((PageNum >= FFromPage) and (PageNum <= FToPage)) then
      begin
        // ¬ыводим на канвас принтера
        DrawPage(Printer.Canvas, K, Rect.NullRect);
        LastState := True;
      end else
      begin
        // ¬ыводи на копию канваса
        DrawPage(LocCanvas, K, Rect.NullRect);
        LastState := False;
      end;
    end;
  finally
    // ќсвобождать надо именно так, иначе под Win 95 кидает ошибку
    Hn := LocCanvas.Handle;
    LocCanvas.Handle := 0;
    DeleteDC(Hn);
    LocCanvas.Free;
  end;
  Printer.EndDoc;
end;

procedure TxLabelPrinter.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TxLabelPrinter.SetFont0(const Value: TFont);
begin
  FFontA[0].Assign(Value);
end;

procedure TxLabelPrinter.SetFont1(const Value: TFont);
begin
  FFontA[1].Assign(Value);
end;

procedure TxLabelPrinter.SetFont2(const Value: TFont);
begin
  FFontA[2].Assign(Value);
end;

procedure TxLabelPrinter.SetFont3(const Value: TFont);
begin
  FFontA[3].Assign(Value);
end;

procedure TxLabelPrinter.SetHorzCount(const Value: Word);
begin
  FHorzCount := Value;
end;

procedure TxLabelPrinter.SetHorzStep(const Value: Double);
begin
  FHorzStep := Value;
end;

procedure TxLabelPrinter.SetLabelHeight(const Value: Double);
begin
  FLabelHeight := Value;
end;

procedure TxLabelPrinter.SetLabelWidth(const Value: Double);
begin
  FLabelWidth := Value;
end;

procedure TxLabelPrinter.SetLines(const Value: TStringList);
begin
  FLines.Assign(Value);
end;

procedure TxLabelPrinter.SetSideMargin(const Value: Double);
begin
  FSideMargin := Value;
end;

procedure TxLabelPrinter.SetTopMargin(const Value: Double);
begin
  FTopMargin := Value;
end;

procedure TxLabelPrinter.SetVertCount(const Value: Word);
begin
  FVertCount := Value;
end;

procedure TxLabelPrinter.SetVertStep(const Value: Double);
begin
  FVertStep := Value;
end;

function TxLabelPrinter.ShowDialog: Boolean;
begin
  with TdlgLabelProperties.Create(Application) do
  try
    Color := DialogColor;
    xbbOk.Color := DialogColor;
    xbbCancel.Color := DialogColor;
    xbbPrinter.Color := DialogColor;

    xseTopMargin.Value := FTopMargin;
    xseSideMargin.Value := FSideMargin;
    xseVertStep.Value := FVertStep;
    xseHorzStep.Value := FHorzStep;
    xseLabelWidth.Value := FLabelWidth;
    xseLabelHeight.Value := FLabelHeight;
    xseVertCount.Value := FVertCount;
    xseHorzCount.Value := FHorzCount;

    cbName.Text := FLabelName;
    edPrinter.Text := Printer.Printers[Printer.PrinterIndex];
    cbAllPage.Checked := True;

    if ShowModal = mrOk then
    begin
      FTopMargin := xseTopMargin.Value;
      FSideMargin := xseSideMargin.Value;
      FVertStep := xseVertStep.Value;
      FHorzStep := xseHorzStep.Value;
      FLabelWidth := xseLabelWidth.Value;
      FLabelHeight := xseLabelHeight.Value;
      FVertCount := xseVertCount.IntValue;
      FHorzCount := xseHorzCount.IntValue;
      FLabelName := cbName.Text;
      FIsAllPage := cbAllPage.Checked;
      if not FIsAllPage then
      begin
        FFromPage := StrToInt(edFrom.Text);
        FToPage := StrToInt(edTo.Text);
      end;

      Result := True;
    end else
      Result := False;
  finally
    Free;
  end;
end;

//

procedure Register;
begin
  RegisterComponents('x-Report', [TxLabelPrinter]);
end;

end.
