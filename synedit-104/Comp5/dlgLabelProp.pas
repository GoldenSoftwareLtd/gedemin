
// 1.01

unit dlgLabelProp;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, xCalculatorEdit, xSpin, xBulbBtn, Printers, //BelfProcs,
  xMsgBox, gsMultilingualSupport;

type
  TLabelProp = record
    Name: String;
    TopMargin, SideMargin: Double;
    VertStep, HorzStep: Double;
    Width, Height: Double;
    VertCount, HorzCount: Integer;
  end;

const
  PresetLabels: array[0..6] of TLabelProp =
  (
    (Name: 'ESSELTE 83548 (2 x 4; 99.1 x 67.7 mm)'; TopMargin: 1.00; SideMargin: 0.50; VertStep: 6.77; HorzStep: 9.91; Width: 9.91; Height: 6.77; VertCount: 4; HorzCount: 2),
    (Name: 'ESSELTE 83552 (3 x 4; 63.5 x 72.0 mm)'; TopMargin: 0.50; SideMargin: 1.00; VertStep: 6.35; HorzStep: 7.2; Width: 6.35; Height: 7.2; VertCount: 4; HorzCount: 3),
    (Name: 'ESSELTE 83554 (2 x 7; 99.1 x 38.1 mm)'; TopMargin: 1.50; SideMargin: 0.50; VertStep: 3.81; HorzStep: 9.91; Width: 9.91; Height: 3.81; VertCount: 7; HorzCount: 2),
    (Name: 'ESSELTE 83556 (2 x 8; 99.1 x 33.9 mm)'; TopMargin: 1.50; SideMargin: 0.50; VertStep: 3.39; HorzStep: 9.91; Width: 9.91; Height: 3.39; VertCount: 8; HorzCount: 2),
    (Name: 'ESSELTE 83558 (3 x 6; 63.5 x 46.6 mm)'; TopMargin: 1.00; SideMargin: 1.00; VertStep: 4.66; HorzStep: 6.35; Width: 6.35; Height: 4.66; VertCount: 6; HorzCount: 3),
    (Name: 'ESSELTE 83561 (3 x 7; 63.5 x 38.1 mm)'; TopMargin: 1.50; SideMargin: 1.00; VertStep: 3.81; HorzStep: 6.60; Width: 6.35; Height: 3.81; VertCount: 7; HorzCount: 3),
    (Name: '(3 x 7; 70 x 40 mm)'; TopMargin: 1.00; SideMargin: 0.00; VertStep: 4.00; HorzStep: 7.00; Width: 7.00; Height: 4.00; VertCount: 7; HorzCount: 3)
  );

type
  TdlgLabelProperties = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Bevel1: TBevel;
    Shape1: TShape;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label13: TLabel;
    xbbOk: TxBulbButton;
    xbbCancel: TxBulbButton;
    xseTopMargin: TxSpinEdit;
    xseSideMargin: TxSpinEdit;
    xseVertStep: TxSpinEdit;
    xseHorzStep: TxSpinEdit;
    xseLabelWidth: TxSpinEdit;
    xseHorzCount: TxSpinEdit;
    xseVertCount: TxSpinEdit;
    xseLabelHeight: TxSpinEdit;
    Edit1: TEdit;
    Label11: TLabel;
    Calculator: TxCalculatorEdit;
    Label12: TLabel;
    edPrinter: TEdit;
    xbbPrinter: TxBulbButton;
    Bevel2: TBevel;
    cbName: TComboBox;
    gsMultilingualSupport1: TgsMultilingualSupport;
    edTo: TEdit;
    edFrom: TEdit;
    Label14: TLabel;
    Label15: TLabel;
    cbAllPage: TCheckBox;
    procedure xbbPrinterClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbNameChange(Sender: TObject);
    procedure xbbOkClick(Sender: TObject);
    procedure cbAllPageClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dlgLabelProperties: TdlgLabelProperties;

implementation

{$R *.DFM}

function StripStr(const S: String): String;
var
  B, E: Integer;
begin
  B := 1;
  while (B < Length(S)) and (S[B] in [#32, #9]) do Inc(B);
  E := Length(S);
  while (E >= B) and (S[E] in [#32, #9]) do Dec(E);
  Result := Copy(S, B, E - B + 1);
end;

procedure TdlgLabelProperties.xbbPrinterClick(Sender: TObject);
begin
  with TPrinterSetupDialog.Create(Owner) do
  try
    Execute;
    edPrinter.Text := Printer.Printers[Printer.PrinterIndex];
  finally
    Free;
  end;
end;

procedure TdlgLabelProperties.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  cbName.Items.Add('Формат устанавливается пользователем...');
  for I := Low(PresetLabels) to High(PresetLabels) do
    cbName.Items.Add(PresetLabels[I].Name);
  cbName.ItemIndex := 0;
  cbName.Text := 'Формат устанавливается пользователем...';
end;

procedure TdlgLabelProperties.cbNameChange(Sender: TObject);
var
  I: Integer;
begin
  for I := Low(PresetLabels) to High(PresetLabels) do
    if StripStr(cbName.Text) = PresetLabels[I].Name then
    begin
      xseTopMargin.Value := PresetLabels[I].TopMargin;
      xseSideMargin.Value := PresetLabels[I].SideMargin;
      xseVertStep.Value := PresetLabels[I].VertStep;
      xseHorzStep.Value := PresetLabels[I].HorzStep;
      xseLabelWidth.Value := PresetLabels[I].Width;
      xseLabelHeight.Value := PresetLabels[I].Height;
      xseVertCount.Value := PresetLabels[I].VertCount;
      xseHorzCount.Value := PresetLabels[I].HorzCount;

      break;
    end;
end;

procedure TdlgLabelProperties.xbbOkClick(Sender: TObject);
begin
  if not cbAllPage.Checked then
  try
    StrToInt(edFrom.Text);
    StrToInt(edTo.Text);
  except
    MessageBoxEx(Handle, 'Неверно задан диапозон.', 'Внимание', MB_OK or MB_ICONEXCLAMATION,
      xbbOk);
    ModalResult := mrNone;
    Exit;
  end;

  if (xseLabelWidth.Value > xseHorzStep.Value) or (xseLabelHeight.Value > xseVertStep.Value)
    or (xseLabelWidth.Value = 0) or (xseLabelHeight.Value = 0)
    or (xseVertCount.Value * xseVertStep.Value > 29.7) or (xseHorzCount.Value * xseHorzStep.Value > 21.0) then
  begin
    MessageBoxEx(Handle, 'Установлены неверные значения.', 'Внимание', MB_OK or MB_ICONEXCLAMATION,
      xbbOk);
    ModalResult := mrNone;
  end else
    ModalResult := mrOk;
end;

procedure TdlgLabelProperties.cbAllPageClick(Sender: TObject);
begin
  edFrom.Enabled := not cbAllPage.Checked;
  edTo.Enabled := not cbAllPage.Checked;
end;

end.
