
{++

  Copyright (c) 1998 by Golden Software of Belarus

  Module

    xEnvelopePrinter.pas

  Abstract

    This component provides ability to choose style, font, size and other
    parameters for printing of letter cards and printing them.

  Author

    Romanovski Denis (22-Oct-98)

  Contact address

  Revisions history

    Initial  22-Oct-98  Dennis  Initial version.

--}

unit xEnvelopePrinter;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Printers, StdCtrls;

type
  TPrintingAlign = (paHorzLeft, paHorzCenter, paHorzRight, paVertLeft,
    paVertCenter, paVertRight);

// Структура стиля конверта
type
  TEnvelope = record
    sWidth: Double;
    sHeight: Double;
  end;

// Виды стилей конвертов
type
  TEnvelopeStyle = (esSize10, esSize6, esMonarch, esSize9, esSize11,
    esSize12, esDL, esC4, esC5, esC6, esC65, esCustom);

// Значния стилей конвертов
const
  EnvelopeStyles: array[TEnvelopeStyle] of TEnvelope =
    (
      (sWidth: 22.86;    sHeight: 10.4775),
      (sWidth: 15.24;    sHeight: 9.2075),
      (sWidth: 17.78;    sHeight: 9.8425),
      (sWidth: 22.5425;  sHeight: 9.8425),
      (sWidth: 26.3525;  sHeight: 10.16),
      (sWidth: 27.94;    sHeight: 10.16),
      (sWidth: 22;       sHeight: 11),
      (sWidth: 32.4;     sHeight: 22.9),
      (sWidth: 22.9;     sHeight: 16.2),
      (sWidth: 16.2;     sHeight: 11.4),
      (sWidth: 22.9;     sHeight: 11.4),
      (sWidth: 22.86;    sHeight: 10.4775)
    );

  EnvelopeStyleByIndex: array[0..11] of TEnvelopeStyle =
    (
      esSize10, esSize6, esMonarch, esSize9, esSize11,
      esSize12, esDL, esC4, esC5, esC6, esC65, esCustom
    );

  EnvelopeIndexByStyle: array[TEnvelopeStyle] of Integer = (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11);

// Начальные значения
const
  defEnvelopeWidth = 24.13;
  defEnvelopeHeight = 10.48;
  defReturnFromLeft = 1.5;
  defReturnFromTop = 0.8;
  defDeliveryFromLeft = 10;
  defDeliveryFromTop = 5;
  deFPrintingAlign = paHorzLeft;
  defEnvelopeStyle = esSize10;
  defSaveToRegistry = False;

type
  TxEnvelopePrinter = class(TComponent)
  private
    // Свойства конверта
    FStyle: TEnvelopeStyle; // Стиль конверта
    FEnvelopeWidth: Double; // Ширина конверта
    FEnvelopeHeight: Double; // Высота конверта

    FReturnAddress: String; // Адрес отправителя
    FReturnFromLeft: Double; // Отступ отправителя слева
    FReturnFromTop: Double; // Отступ отправителя сверху
    FReturnFont: TFont; // Шрифт отправителя
    FReturnAuto: Boolean; // Автоматический расчет координат для отправителя

    FDeliveryAddress: TStringList; // Адреса получателей
    FDeliveryFromLeft: Double; // Отступ получателя слева
    FDeliveryFromTop: Double; // Отступ получателя сверху
    FDeliveryFont: TFont; // Шрифт получателя
    FDeliveryAuto: Boolean; // Автоматический расчет координат для получателя

    FNote: TStringList; // Дополнительная строка

    // Свойства печати
    FPrintingAlign: TPrintingAlign;
    FDialogColor: TColor;

    FSaveToRegistry: Boolean; // Сохранять ли настройки в регистр

    FFromPage, FToPage, FMaxPage, FMinPage: Integer;
    FIsAllPage: Boolean;

    procedure SetReturnFont(const Value: TFont);
    procedure SetDeliveryFont(const Value: TFont);
    procedure SetDeliveryAdress(const Value: TStringList);
    procedure SetStyle(const Value: TEnvelopeStyle);
    procedure SetEnvelopeWidth(const Value: Double);
    procedure SetEnvelopeHeight(const Value: Double);
    procedure SetNote(Value: TStringList);

  protected
    procedure Loaded; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    property AllPage: Boolean read FIsAllPage;
    property FromPage: Integer read FFromPage;
    property ToPage: Integer read FToPage;
    property MaxPage: Integer write FMaxPage;
    property MinPage: Integer write FMinPage;

    function ShowDialog: Boolean;
    procedure Print;
    procedure DrawPage(Canvas: TCanvas; StartLine: Integer);

  published

    // Ширина конверта
    property EnvelopeWidth: Double read FEnvelopeWidth write SetEnvelopeWidth;
    // Высота конверта
    property EnvelopeHeight: Double read FEnvelopeHeight write SetEnvelopeHeight;
    // Адрес отправителя
    property ReturnAddress: String read FReturnAddress write FReturnAddress;
    // Отступ отправителя слева
    property ReturnFromLeft: Double read FReturnFromLeft write FReturnFromLeft;
    // Отступ отправителя сверху
    property ReturnFromTop: Double read FReturnFromTop write FReturnFromTop;
    // Шрифт отправителя
    property ReturnFont: TFont read FReturnFont write SetReturnFont;

    // Адреса получателей
    property DeliveryAddress: TStringList read FDeliveryAddress write SetDeliveryAdress;
    // Отступ получателя слева
    property DeliveryFromLeft: Double read FDeliveryFromLeft write FDeliveryFromLeft;
    // Отступ получателя сверху
    property DeliveryFromTop: Double read FDeliveryFromTop write FDeliveryFromTop;
    // Шрифт получателя
    property DeliveryFont: TFont read FDeliveryFont write SetDeliveryFont;

    // Дополнительная строка
    property Note: TStringList read FNote write SetNote;

    // Стиль конверта
    property Style: TEnvelopeStyle read FStyle write SetStyle;
    // Автоматический расчет координат для отправителя
    property ReturnAuto: Boolean read FReturnAuto write FReturnAuto;
    // Автоматический расчет координат для получателя
    property DeliveryAuto: Boolean read FDeliveryAuto write FDeliveryAuto;
    // Цвет диалога
    property DialogColor: TColor read FDialogColor write FDialogColor default clBtnFace;
    // Сохранять ли настройки в регистр
    property SaveToRegistry: Boolean read FSaveToRegistry write FSaveToRegistry default DefSaveToRegistry; 
  end;

procedure Register;

implementation

uses dlgEnvelopeProperties, xAppReg;

// **********************
// **   Private Part   **
// **********************

//
//  Устанавливаем шрифт отправителя
//

procedure TxEnvelopePrinter.SetReturnFont(const Value: TFont);
begin
  FReturnFont.Assign(Value);
end;

//
//  Устанавливаем шрифт получателя
//

procedure TxEnvelopePrinter.SetDeliveryFont(const Value: TFont);
begin
  FDeliveryFont.Assign(Value);
end;

//
//  Устанавливаем адреса получателей
//

procedure TxEnvelopePrinter.SetDeliveryAdress(const Value: TStringList);
begin
  FDeliveryAddress.Assign(Value);
end;

//
//  Устанавливает стиль конверта
//

procedure TxEnvelopePrinter.SetStyle(const Value: TEnvelopeStyle);
begin
  FStyle := Value;

  if FStyle <> esCustom then
  begin
    EnvelopeWidth := EnvelopeStyles[FStyle].sWidth;
    EnvelopeHeight := EnvelopeStyles[FStyle].sHeight;
  end;
end;

//
//  Устнанавливает ширину конверта
//

procedure TxEnvelopePrinter.SetEnvelopeWidth(const Value: Double);
begin
  if Value <> EnvelopeStyles[FStyle].sWidth then Style := esCustom;
  FEnvelopeWidth := Value;
end;

//
//  Устанавливает высоту конверта
//

procedure TxEnvelopePrinter.SetEnvelopeHeight(const Value: Double);
begin
  if Value <> EnvelopeStyles[FStyle].sHeight then Style := esCustom;
  FEnvelopeHeight := Value;
end;

procedure TxEnvelopePrinter.SetNote(Value: TStringList);
begin
  FNote.Assign(Value);
end;

// *************************
// **   Protected  Part   **
// *************************

procedure TxEnvelopePrinter.Loaded;
begin
  inherited Loaded;

  if not (csDesigning in ComponentState) and FSaveToRegistry then
  begin
    FEnvelopeWidth := AppRegistry.ReadFloat('Envelopes', 'EnvelopeWidth', defEnvelopeWidth);
    FEnvelopeHeight := AppRegistry.ReadFloat('Envelopes', 'EnvelopeHeight', defEnvelopeHeight);

    FReturnFromLeft := AppRegistry.ReadFloat('Envelopes', 'ReturnFromLeft', defReturnFromLeft);
    FReturnFromTop := AppRegistry.ReadFloat('Envelopes', 'ReturnFromTop', defReturnFromTop);
    AppRegistry.ReadFont('Envelopes', 'ReturnFont', FReturnFont);
    FReturnAuto := AppRegistry.ReadBoolean('Envelopes', 'ReturnAuto', True);

    FDeliveryFromLeft := AppRegistry.ReadFloat('Envelopes', 'DeliveryFromLeft', defDeliveryFromLeft);
    FDeliveryFromTop := AppRegistry.ReadFloat('Envelopes', 'DeliveryFromTop', defDeliveryFromTop);
    AppRegistry.ReadFont('Envelopes', 'DeliveryFont', FDeliveryFont);
    FDeliveryAuto := AppRegistry.ReadBoolean('Envelopes', 'DeliveryAuto', True);

    FDialogColor := AppRegistry.ReadColor('Envelopes', 'FDialogColor', clBtnFace);
    FPrintingAlign := TPrintingAlign(AppRegistry.ReadInteger('Envelopes', 'PrintingAlign', Integer(defPrintingAlign)));
  end;
end;


// **********************
// **   Public  Part   **
// **********************

//
//  Устанавливаем начальные значения
//

constructor TxEnvelopePrinter.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  // Свойства конверта
  FEnvelopeWidth := defEnvelopeWidth;
  FEnvelopeHeight := defEnvelopeHeight;

  FReturnAddress := '';
  FReturnFromLeft := defReturnFromLeft;
  FReturnFromTop := defReturnFromTop;
  FReturnFont := TFont.Create;
  FReturnFont.Name := 'Arial';
  FReturnFont.Size := 8;
  FReturnFont.Style := [];
  FReturnFont.Color := clBlack;
  FReturnFont.CharSet := RUSSIAN_CHARSET;
  FReturnAuto := True;

  FMinPage := 1;
  FMaxPage := 1;

  FDeliveryAddress := TStringList.Create;

  FDeliveryFromLeft := defDeliveryFromLeft;
  FDeliveryFromTop := defDeliveryFromTop;
  FDeliveryFont := TFont.Create;
  FDeliveryFont.Name := 'Arial';
  FDeliveryFont.Size := 8;
  FDeliveryFont.Style := [];
  FDeliveryFont.Color := clBlack;
  FDeliveryFont.CharSet := RUSSIAN_CHARSET;
  FDeliveryAuto := True;

  FNote := TStringList.Create;

  FDialogColor := clBtnFace;
  FSaveToRegistry := defSaveToRegistry;

  // Свойства печати
  FPrintingAlign := deFPrintingAlign;

  // Загружаем обратный адрес из реестра
  FReturnAddress := AppRegistry.ReadString('Envelopes', 'ReturnAddress', '');
end;

//
//  Высвобождаем память
//

destructor TxEnvelopePrinter.Destroy;
begin
  // Сохраняем обратный адрес
  AppRegistry.WriteString('Envelopes', 'ReturnAddress', FReturnAddress);

  if not (csDesigning in ComponentState) and FSaveToRegistry then
  begin
    AppRegistry.WriteFloat('Envelopes', 'EnvelopeWidth', FEnvelopeWidth);
    AppRegistry.WriteFloat('Envelopes', 'EnvelopeHeight', FEnvelopeHeight);

    AppRegistry.WriteFloat('Envelopes', 'ReturnFromLeft', FReturnFromLeft);
    AppRegistry.WriteFloat('Envelopes', 'ReturnFromTop', FReturnFromTop);
    AppRegistry.WriteFont('Envelopes', 'ReturnFont', FReturnFont);
    AppRegistry.WriteBoolean('Envelopes', 'ReturnAuto', FReturnAuto);

    AppRegistry.WriteFloat('Envelopes', 'DeliveryFromLeft', FDeliveryFromLeft);
    AppRegistry.WriteFloat('Envelopes', 'DeliveryFromTop', FDeliveryFromTop);
    AppRegistry.WriteFont('Envelopes', 'DeliveryFont', FDeliveryFont);
    AppRegistry.WriteBoolean('Envelopes', 'DeliveryAuto', FDeliveryAuto);

    AppRegistry.WriteColor('Envelopes', 'FDialogColor', FDialogColor);
    AppRegistry.WriteInteger('Envelopes', 'PrintingAlign', Integer(FPrintingAlign));
  end;

  // Высвобождаем память
  FReturnFont.Free;
  FDeliveryAddress.Free;
  FDeliveryFont.Free;

  FNote.Free;

  inherited Destroy;
end;

//
//  Активирует диалог, в котором пользователь задает параметры
//  печати конверта.
//

function TxEnvelopePrinter.ShowDialog: Boolean;
begin
  Result := False;

  with TfrmEnvelopeProperties.Create(Owner) do
  try
    Color := FDialogColor;

    edFrom.Text := IntToStr(FMinPage);
    edTo.Text := IntToStr(FMaxPage);

    edWidth.Value := FEnvelopeWidth;
    edHeight.Value := FEnvelopeHeight;

    edEnvelopeStyle.ItemIndex := EnvelopeIndexByStyle[FStyle];

    pnlReturnFont.Font.Assign(FReturnFont);

    edReturnFromLeft.Value := FReturnFromLeft;
    edReturnFromTop.Value := FReturnFromTop;
    cbReturnAuto.Checked := FReturnAuto;

    pnlDeliveryFont.Font.Assign(FDeliveryFont);

    edDeliveryFromLeft.Value := FDeliveryFromLeft;
    edDeliveryFromTop.Value := FDeliveryFromTop;
    cbDeliveryAuto.Checked := FDeliveryAuto;

    case FPrintingAlign of
      paHorzLeft: Selected := PH1;
      paHorzCenter: Selected := PH2;
      paHorzRight: Selected := PH3;
      paVertLeft: Selected := PV1;
      paVertCenter: Selected := PV2;
      paVertRight: Selected := PV3;
    end;

    Selected.Color := clHighlight;
    lblPrinter.Caption := Printer.Printers[Printer.PrinterIndex];

    Address := FReturnAddress;

    if ShowModal = mrOk then
    begin
      Result := True;

      FEnvelopeWidth := edWidth.Value;
      FEnvelopeHeight := edHeight.Value;

      FReturnFont.Assign(pnlReturnFont.Font);

      FReturnFromLeft := edReturnFromLeft.Value;
      FReturnFromTop := edReturnFromTop.Value;
      FReturnAuto := cbReturnAuto.Checked;

      FDeliveryFont.Assign(pnlDeliveryFont.Font);

      FDeliveryFromLeft := edDeliveryFromLeft.Value;
      FDeliveryFromTop := edDeliveryFromTop.Value;
      FDeliveryAuto := cbDeliveryAuto.Checked;

      FIsAllPage := cbAllPage.Checked;
      try
        FFromPage := StrToInt(edFrom.Text);
        FToPage := StrToInt(edTo.Text);
      except
        FIsAllPage :=  True;
      end;

      if PH1.Color = clHighlight then
        FPrintingAlign := paHorzLeft
      else if PH2.Color = clHighlight then
        FPrintingAlign := paHorzCenter
      else if PH3.Color = clHighlight then
        FPrintingAlign := paHorzRight
      else if PV1.Color = clHighlight then
        FPrintingAlign := paVertLeft
      else if PV2.Color = clHighlight then
        FPrintingAlign := paVertCenter
      else if PV3.Color = clHighlight then
        FPrintingAlign := paVertRight;

      FStyle := EnvelopeStyleByIndex[edEnvelopeStyle.ItemIndex];
      FReturnAddress := Address;
    end;
  finally
    Free;
  end;
end;

//
//  Производит подготовку печати конвертов
//

procedure TxEnvelopePrinter.Print;
var
  I: Integer; // Индекс адреса
begin
  case FPrintingAlign of
    paHorzLeft, paHorzCenter, paHorzRight:
      Printer.Orientation := poPortrait;
    paVertLeft, paVertCenter, paVertRight:
      Printer.Orientation := poLandscape;
  end;

  // Подготовка печати
  Printer.Title := ExtractFileName(Application.ExeName) + '-печать конвертов';
  Printer.BeginDoc;

  I := 0;
  while (I < FDeliveryAddress.Count) and (not Printer.Aborted) do
  begin
    if I > 0 then Printer.NewPage; // Создаем новую страницу
    DrawPage(Printer.Canvas, I); // Рисуем
    Inc(I);
  end;

  // Заканчиваем подготовку к печати
  Printer.EndDoc;
end;

//
//  Рисует конверт на листе для печати
//

procedure TxEnvelopePrinter.DrawPage(Canvas: TCanvas; StartLine: Integer);
var
  R: TRect;
  X, Y: Integer;
  PointsX, PointsY: Double; // кол-во точек на 1 см для принтера
  Ch: array[0..511] of Char;
  pgWidth, pgHeight: Integer;
begin
  //  Устанавливаем параметры рисования текста
  SetTextAlign(Canvas.Handle, TA_LEFT or TA_TOP or TA_NOUPDATECP);

  // сколько точек принтер печатает в одном сантиметре
  PointsX := GetDeviceCaps(Canvas.Handle, LOGPIXELSX) / 2.54;
  PointsY := GetDeviceCaps(Canvas.Handle, LOGPIXELSY) / 2.54;

  // Размеры страницы с принтера
  try
    pgWidth := GetDeviceCaps(Printer.Canvas.Handle, HORZRES);
    pgHeight := GetDeviceCaps(Printer.Canvas.Handle, VERTRES);
  except
    on Exception do
    begin
      if FPrintingAlign in [paHorzLeft, paHorzCenter, paHorzRight] then
      begin
        pgWidth := Round(21 * PointsX);
        pgHeight := Round(29.7 * PointsY);
      end else begin
        pgWidth := Round(29.7 * PointsY);
        pgHeight := Round(21 * PointsX);
      end;
    end;
  end;

  // Делаем прозрачный фон
  SetBkMode(Canvas.Handle, TRANSPARENT);

  // РИСОВАНИЕ данных на ОТПРАВИТЕЛЯ

  // присваиваем шрифт
  Canvas.Font.Assign(FReturnFont);
  Canvas.Font.PixelsPerInch := GetDeviceCaps(Canvas.Handle, LOGPIXELSY);

  // Производим установки координаты X для печати согласно выбранному параметру
  case FPrintingAlign of
    paHorzLeft:
    begin
      X := 0;
      Y := 0;
    end;
    paVertLeft:
    begin
      X := pgWidth - Round(FEnvelopeWidth * PointsX);
      Y := 0;
    end;
    paHorzCenter:
    begin
      X := (pgWidth - Round(FEnvelopeWidth * PointsX)) div 2;
      Y := 0;
    end;
    paVertCenter:
    begin
      X := pgWidth - Round(FEnvelopeWidth * PointsX);
      Y := (pgHeight - Round(FEnvelopeHeight * PointsY)) div 2;
    end;
    paHorzRight:
    begin
      X := pgWidth - Round(FEnvelopeWidth * PointsX);
      Y := 0;
    end;
    paVertRight:
    begin
      X := pgWidth - Round(FEnvelopeWidth * PointsX);
      Y := pgHeight - Round(FEnvelopeHeight * PointsY);
    end else begin
      X := 0;
      Y := 0;
    end;
  end;

  R.Left := Round(X + FReturnFromLeft * PointsX);
  R.Top := Round(Y + FReturnFromTop * PointsY);
  R.Right := Round(X + FEnvelopeWidth * PointsX);
  R.Bottom := Round(Y + FEnvelopeHeight * PointsY);

  DrawText(Canvas.Handle, StrPCopy(Ch, FReturnAddress), -1, R,
    DT_NOPREFIX or DT_WORDBREAK);

  if FNote.Count > StartLine then
  begin
    // Высчитываем размер
    DrawText(Canvas.Handle, StrPCopy(Ch, FReturnAddress), -1, R,
      DT_NOPREFIX or DT_WORDBREAK or DT_CALCRECT);

    R.Left := Round(X + FReturnFromLeft * PointsX);
    R.Right := Round(X + FEnvelopeWidth * PointsX);
    R.Top := Round(Y + FReturnFromTop * PointsY) + R.Bottom - R.Top + Round(PointsY);
    R.Bottom := Round(Y + FEnvelopeHeight * PointsY);

    DrawText(Canvas.Handle, StrPCopy(Ch, FNote[StartLine]), -1, R,
      DT_NOPREFIX or DT_WORDBREAK);
  end;

    // Эти две нежеидущие строки используются для проверки печати конверта на странице
//  Canvas.DrawFocusRect(Rect(Round(X), Round(Y), Round(X + FEnvelopeWidth * PointsX),
//    Round(Y + FEnvelopeHeight * PointsX)));

  // РИСОВАНИЕ данных на ПОЛУЧАТЕЛЯ

  // присваиваем шрифт
  Canvas.Font.Assign(FDeliveryFont);
  Canvas.Font.PixelsPerInch := GetDeviceCaps(Canvas.Handle, LOGPIXELSY);

  R.Left := Round(X + FDeliveryFromLeft * PointsX);
  R.Top := Round(Y + FDeliveryFromTop * PointsY);
  R.Right := Round(X + FEnvelopeWidth * PointsX);
  R.Bottom := Round(Y + FEnvelopeHeight * PointsY);

  DrawText(Canvas.Handle, StrPCopy(Ch, FDeliveryAddress[StartLine]), -1, R,
    DT_NOPREFIX or DT_WORDBREAK);
end;

//
//  Регистрация компоненты
//

procedure Register;
begin
  RegisterComponents('x-Report', [TxEnvelopePrinter]);
end;

end.

