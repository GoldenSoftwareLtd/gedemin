
unit dlgEnvelopeProperties;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, xSpin, xBulbBtn, ExtCtrls, xCalculatorEdit, xPanel, xMsgBox,
  xYellabl, Buttons, gsMultilingualSupport;

type
  TfrmEnvelopeProperties = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edHeight: TxSpinEdit;
    edWidth: TxSpinEdit;
    groupReturn: TGroupBox;
    edEnvelopeStyle: TComboBox;
    Label4: TLabel;
    edReturnFromLeft: TxSpinEdit;
    edReturnFromTop: TxSpinEdit;
    Label5: TLabel;
    GroupPrintParameters: TGroupBox;
    pnlReturnFont: TPanel;
    groupDelivery: TGroupBox;
    Label6: TLabel;
    Label7: TLabel;
    edDeliveryFromLeft: TxSpinEdit;
    edDeliveryFromTop: TxSpinEdit;
    pnlDeliveryFont: TPanel;
    imgEnvelope: TImage;
    pnlButtons: TPanel;
    btnOk: TxBulbButton;
    btnCancel: TxBulbButton;
    Label9: TLabel;
    edCalculator: TxCalculatorEdit;
    dlgFont: TFontDialog;
    pnlPrinterParameters: TxPanel;
    PH1: TxPanel;
    imgH1: TImage;
    PH2: TxPanel;
    imgH2: TImage;
    PH3: TxPanel;
    imgH3: TImage;
    PV1: TxPanel;
    imgV1: TImage;
    PV2: TxPanel;
    imgV2: TImage;
    PV3: TxPanel;
    imgV3: TImage;
    btnCancelFunction: TButton;
    dlgPrinterSetup: TPrinterSetupDialog;
    Label8: TLabel;
    lblPrinter: TLabel;
    cbReturnAuto: TCheckBox;
    cbDeliveryAuto: TCheckBox;
    btnDeliveryFont: TSpeedButton;
    btnReturnFont: TSpeedButton;
    Shape1: TShape;
    Shape2: TShape;
    btnPrinter: TxBulbButton;
    btnReturnAddress: TxBulbButton;
    gsMultilingualSupport1: TgsMultilingualSupport;
    Label14: TLabel;
    Label15: TLabel;
    edTo: TEdit;
    edFrom: TEdit;
    cbAllPage: TCheckBox;

    procedure DoOnClickPage(Sender: TObject);
    procedure DoOnPageEnter(Sender: TObject);
    procedure DoOnPageExit(Sender: TObject);
    procedure DoOnParamKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DoOnClickFont(Sender: TObject);
    procedure CWMDialogKey(var Message: TCMDialogKey);
      message CM_DIALOGKEY;
    procedure DoWidthHeightChange(Sender: TObject);
    procedure DoOnChangeStyle(Sender: TObject);
    procedure btnPrinterClick(Sender: TObject);
    procedure cbReturnAutoClick(Sender: TObject);
    procedure cbDeliveryAutoClick(Sender: TObject);
    procedure btnReturnAddressClick(Sender: TObject);
    procedure cbAllPageClick(Sender: TObject);

  public
    Selected: TPanel; 
    Address: String; // Обратный адрес
  end;

var
  frmEnvelopeProperties: TfrmEnvelopeProperties;

implementation

{$R *.DFM}

uses
  dlgEnvelopeAddress, xEnvelopePrinter, Printers;

//
//  По нажатию на рисунок вида печати производим его активацию
//

procedure TfrmEnvelopeProperties.DoOnClickPage(Sender: TObject);
begin
  if ((Sender as TImage).Parent as TPanel).Color <> clHighlight then
  begin
    PH1.Color := Color;
    PH2.Color := Color;
    PH3.Color := Color;
    PV1.Color := Color;
    PV2.Color := Color;
    PV3.Color := Color;

    ((Sender as TImage).Parent as TPanel).Color := clHighlight;
  end;

  Selected.BevelOuter := bvLowered;
  Selected := (Sender as TImage).Parent as TPanel;

  if pnlPrinterParameters.Focused then
    Selected.BevelOuter := bvRaised
  else
    pnlPrinterParameters.SetFocus;
end;

//
//  По получению "фокуса" активируем выбранный вид печати
//

procedure TfrmEnvelopeProperties.DoOnPageEnter(Sender: TObject);
begin
  Selected.BevelOuter := bvRaised;
  pnlPrinterParameters.OnKeyDown := DoOnParamKeyDown;
end;

//
//  По потере "фокуса" деактивируем выбранный вид печати
//

procedure TfrmEnvelopeProperties.DoOnPageExit(Sender: TObject);
begin
  Selected.BevelOuter := bvLowered;
end;

procedure TfrmEnvelopeProperties.DoOnParamKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  NewControl: TControl;
begin
  if Key in [VK_LEFT, VK_RIGHT] then
  begin
    Selected.BevelOuter := bvLowered;
    Selected.Color := Color;

    case Key of
      VK_LEFT:
      begin
        NewControl := FindNextControl(Selected, False, False, False);
        if (NewControl <> nil) and (NewControl is TxPanel) and
          (NewControl <> pnlPrinterParameters)
        then
          Selected := NewControl as TPanel
        else
          Selected := PV3;
      end;
      VK_RIGHT:
      begin
        NewControl := FindNextControl(Selected, True, False, False);
        if (NewControl <> nil) and (NewControl is TxPanel) and
          (NewControl <> pnlPrinterParameters)
        then
          Selected := NewControl as TPanel
        else
          Selected := PH1;
      end;
    end;

    Selected.Color := clHighlight;
    Selected.BevelOuter := bvRaised;
  end;
end;

//
//  По нажатию кнопки выбора шрифта показываем соответствующий диалог
//

procedure TfrmEnvelopeProperties.DoOnClickFont(Sender: TObject);
begin
  dlgFont := TFontDialog.Create(Owner);

  try
    if Sender = btnReturnFont then
      dlgFont.Font.Assign(pnlReturnFont.Font)
    else
      dlgFont.Font.Assign(pnlDeliveryFont.Font);

    if dlgFont.Execute then
      if Sender = btnReturnFont then
        pnlReturnFont.Font.Assign(dlgFont.Font)
      else
        pnlDeliveryFont.Font.Assign(dlgFont.Font);
  finally
    dlgFont.Free;
  end;
end;

//
//  Получаем нажатия кнопок <- и ->
//

procedure TfrmEnvelopeProperties.CWMDialogKey(var Message: TCMDialogKey);
begin
  inherited;

  if pnlPrinterParameters.Focused and
    (Message.CharCode in [VK_LEFT, VK_RIGHT])
  then
    DoOnParamKeyDown(pnlPrinterParameters, Message.CharCode, []);
end;

procedure TfrmEnvelopeProperties.DoWidthHeightChange(Sender: TObject);
begin
  try
    // Если изменены стандартные размеры конверта, то переходим к соотв. стилю - esCustom
    if (edWidth.Value <> EnvelopeStyles[EnvelopeStyleByIndex[edEnvelopeStyle.ItemIndex]].sWidth) or
      (edHeight.Value <> EnvelopeStyles[EnvelopeStyleByIndex[edEnvelopeStyle.ItemIndex]].sHeight)
    then
      edEnvelopeStyle.ItemIndex := 11;
  except
    on Exception do
      edEnvelopeStyle.ItemIndex := 11;
  end;

  edReturnFromLeft.MaxValue := edWidth.Value;
  edReturnFromLeft.Value := edReturnFromLeft.Value;

  edReturnFromTop.MaxValue := edHeight.Value;
  edReturnFromTop.Value := edReturnFromTop.Value;

  if cbReturnAuto.Checked then
  begin
    edReturnFromLeft.Value := edWidth.Value * 0.18;
    edReturnFromTop.Value := edHeight.Value * 0.1;
  end;

  edDeliveryFromLeft.MaxValue := edWidth.Value;
  edDeliveryFromLeft.Value := edDeliveryFromLeft.Value;

  edDeliveryFromTop.MaxValue := edHeight.Value;
  edDeliveryFromTop.Value := edDeliveryFromTop.Value;

  if cbDeliveryAuto.Checked then
  begin
    edDeliveryFromLeft.Value := edWidth.Value * 0.5;
    edDeliveryFromTop.Value := edHeight.Value * 0.6;
  end;
end;

//
//  По выбору нового стиля производим установки
//

procedure TfrmEnvelopeProperties.DoOnChangeStyle(Sender: TObject);
begin
  if EnvelopeStyleByIndex[edEnvelopeStyle.ItemIndex] <> esCustom then
  begin
    edWidth.OnChange := nil;
    edHeight.OnChange := nil;

    edWidth.Value := EnvelopeStyles[EnvelopeStyleByIndex[edEnvelopeStyle.ItemIndex]].sWidth;
    edHeight.Value := EnvelopeStyles[EnvelopeStyleByIndex[edEnvelopeStyle.ItemIndex]].sHeight;

    if cbReturnAuto.Checked then
    begin
      edReturnFromLeft.Value := edWidth.Value * 0.18;
      edReturnFromTop.Value := edHeight.Value * 0.1;
    end;

    if cbDeliveryAuto.Checked then
    begin
      edDeliveryFromLeft.Value := edWidth.Value * 0.5;
      edDeliveryFromTop.Value := edHeight.Value * 0.6;
    end;

    edWidth.OnChange := DoWidthHeightChange;
    edHeight.OnChange := DoWidthHeightChange;
  end;
end;

procedure TfrmEnvelopeProperties.btnPrinterClick(Sender: TObject);
begin
  with TPrinterSetupDialog.Create(Owner) do
  try
    Execute;
    lblPrinter.Caption := Printer.Printers[Printer.PrinterIndex];
  finally
    Free;
  end;
end;

//
//  Устанавливаем автоматическое определение размеров для отправителя
//

procedure TfrmEnvelopeProperties.cbReturnAutoClick(Sender: TObject);
begin
  if cbReturnAuto.Checked then
  begin
    edReturnFromLeft.Value := edWidth.Value * 0.18;
    edReturnFromTop.Value := edHeight.Value * 0.1;

    edReturnFromLeft.Visible := False;
    edReturnFromTop.Visible := False;

    Label4.Visible := False;
    Label5.Visible := False;
  end else
  begin
    edReturnFromLeft.Visible := True;
    edReturnFromTop.Visible := True;

    Label4.Visible := True;
    Label5.Visible := True;
  end;
end;

//
//  Устанавливаем автоматическое определение размеров для получателя
//

procedure TfrmEnvelopeProperties.cbDeliveryAutoClick(Sender: TObject);
begin
  if cbDeliveryAuto.Checked then
  begin
    edDeliveryFromLeft.Value := edWidth.Value * 0.5;
    edDeliveryFromTop.Value := edHeight.Value * 0.6;

    edDeliveryFromLeft.Visible := False;
    edDeliveryFromTop.Visible := False;

    Label6.Visible := False;
    Label7.Visible := False;
  end else
  begin
    edDeliveryFromLeft.Visible := True;
    edDeliveryFromTop.Visible := True;

    Label6.Visible := True;
    Label7.Visible := True;
  end;
end;

//
//  Позволяем ручной ввод обратного адреса отправителя
//

procedure TfrmEnvelopeProperties.btnReturnAddressClick(Sender: TObject);
begin
  with TfrmReturnAddress.Create(Owner) do
  try
    memReturnAddress.Lines.Text := Address;
    if ShowModal = mrOk then
      Address := memReturnAddress.Lines.Text;
  finally
    Free;  
  end;
end;

procedure TfrmEnvelopeProperties.cbAllPageClick(Sender: TObject);
begin
  edFrom.Enabled := not (Sender as TCheckBox).Checked;
  edTo.Enabled := edFrom.Enabled;
end;

end.

