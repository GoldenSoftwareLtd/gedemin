unit Operation;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Windows, commctrl, ExtCtrls, BaseOperation;

type

  { TOperationTP }

  TOperationTP = class(TBaseOperation)
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { private declarations }
  protected
    procedure SetBarCode(const AKey: String); override;
    procedure SaveToFile; override;
    procedure DeleteLastItem; override;
  public
    { public declarations }
  end;


implementation

{$R *.lfm}

uses
  JcfStringUtils, MessageForm, BaseAddInformation, terminal_common, ProjectCommon;

{ TOperationTP }

procedure TOperationTP.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F1 then
  begin
    eWeight.Text := '0';
    FTotalWeight := 0;
  end else
  if Key = VK_F3 then
  begin
    inherited;
    NewMemo;
  end else
    inherited;
end;

procedure TOperationTP.SaveToFile;
var
  Temps: String;
  I: Integer;
begin
  Temps := '';

  for I := 0 to DocumentLine - 1 do
    Temps := Temps + FPosition[I];
  FPosition.SaveToFile(ExtractFilePath(Application.ExeName) + '\ov\' + StringReplace(Temps, Separator, '', [rfReplaceAll]) + '.txt');
end;


procedure TOperationTP.SetBarCode(const AKey: String);
var
  Weight, ProductCode, Number: Integer;
  WeightInKg: Double;
  Date: TDateTime;
  NameGoods, Code: String;
  BarCode: String;
  TempS: String;
  Count: Integer;
begin
  FSetBarCode := True;
  try
    BarCode := Trim(AKey);
    if CheckBarCode(BarCode) then
    begin
      GetInfoGoods(BarCode, Code, NameGoods, Weight, Date, Number);
      if not FEnterCount and
        (Weight > weight_for_checking_sites) and
        (Length(BarCode) = length_code_for_checking_sites) then
      begin
        TempS := Trim(TBaseAddInformation.Execute('Введите кол-во мест: '));
        if (TempS > '')
          and (Length(TempS) <= 3)
          and TryStrToInt(TempS, Count)
        then
          BarCode := CreateBarCode(Weight, Date, Code, Count);
        {$IFNDEF SKORPIOX3}
        registerLabelMessage(Handle, AM_DCD_SCAN);
        {$ENDIF}
      end;
      WeightInKg := Weight/1000;
      AddPosition(Trim(BarCode));
      FMemoPositions.Add(NameGoods + '=' + FloatToStrF(WeightInKg, ffFixed, 6, 3));
      FTotalWeight := FTotalWeight + WeightInKg;
      eWeight.Text := FloatToStrF(FTotalWeight, ffFixed, 6, 3);
     // eGoods.Text := IntToStr(FPosition.Count - DocumentLine);
      mTP.Lines.Add(NameGoods + '=' + FloatToStrF(WeightInKg, ffFixed, 6, 3) + 'кг');
    end;

  finally
    FSetBarCode := False;
  end;
end;

procedure TOperationTP.DeleteLastItem;
var
  Weight: Integer;
  Date: TDateTime;
  ProductCode: String;
  NameGood: String;
  Number: Integer;
  Temps: String;
begin
  TempS := FPosition[FPosition.Count - 1];
  Setlength(TempS, Length(TempS) - 1);

  GetInfoGoods(TempS, ProductCode, NameGood, Weight, Date, Number);
  FPosition.Delete(FPosition.Count - 1);
  FTotalWeight := FTotalWeight - StrToFloat(FMemoPositions.ValueFromIndex[FMemoPositions.Count - 1]);
  FMemoPositions.Delete(FMemoPositions.Count - 1);
  if (Weight > weight_for_checking_sites)
    and (Length(TempS) = length_code_for_checking_sites) then
    Dec(FGoodsCount, Number)
  else
    Dec(FGoodsCount);
  eWeight.Text := FloatToStrF(FTotalWeight, ffFixed, 6, 3);
  eGoods.Text := IntToStr(FGoodsCount);
end;

end.

