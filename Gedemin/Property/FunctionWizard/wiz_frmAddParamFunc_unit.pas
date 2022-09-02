// ShlTanya, 09.03.2019

{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    prp_BaseFrame_unit.pas

  Abstract

    Gedemin project.

  Author

    Karpuk Alexander

  Revisions history

    1.00    30.05.03    tiptop        Initial version.
--}
unit wiz_frmAddParamFunc_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  tax_frmAddParamsFunc_unit, ImgList, ActnList, Menus, StdCtrls, BtnEdit,
  ExtCtrls, wiz_FunctionBlock_unit, at_Classes, gdc_frmAnalyticsSel_unit,
  wiz_Strings_unit, gdcConstants, gdcBaseInterface, tax_frmAnalytics_unit;

type
  TwizfrmAddParamsFunc = class(TfrmAddParamsFunc)
    actAddVar: TAction;
    miVar: TMenuItem;
    N2: TMenuItem;
    actExpression: TAction;
    procedure actAddFunctionExecute(Sender: TObject);
    procedure actAddVarExecute(Sender: TObject);
    procedure pmAddPopup(Sender: TObject);
    procedure actExpressionExecute(Sender: TObject);
    procedure actAddAnalyticsExecute(Sender: TObject);
  private
    FBlock: TVisualBlock;
    procedure SetBlock(const Value: TVisualBlock);
    { Private declarations }
    procedure ClickAccount(Sender: TObject);
    procedure ClickAccountCicle(Sender: TObject);

    procedure ClickAnal(Sender: TObject);
    procedure ClickCustomAnal(Sender: TObject);
    procedure ClickAnalCycle(Sender: TObject);
  public
    { Public declarations }
    property Block: TVisualBlock read FBlock write SetBlock;
  end;

var
  wizfrmAddParamsFunc: TwizfrmAddParamsFunc;

implementation
uses wiz_frmAvailableTaxFunc_unit, wiz_dlgVarSelect_unit, wiz_dlgCustumAnalytic_unit;
{$R *.DFM}

procedure TwizfrmAddParamsFunc.actAddFunctionExecute(Sender: TObject);
begin
  with TwizfrmAvailableTaxFunc.CreateWithParams(Self, FActualTaxKey, '') do
  try
    if ShowModal = idOk then
    begin
      FActiveEdit.SelText := SelectedFunction;
    end;
  finally
    Free;
  end;
end;

procedure TwizfrmAddParamsFunc.actAddVarExecute(Sender: TObject);
var
  F: TdlgVarSelect;
  Strings: TStrings;
begin
  F := TdlgVarSelect.Create(nil);
  try
    Strings := TStringList.Create;
    try
      VarsList(Strings, FBlock);
      F.VarsList := Strings;
      if F.ShowModal = mrOK then
      begin
        FActiveEdit.SelText := F.VarName;
      end;
    finally
      Strings.Free;
    end;
  finally
    F.Free;
  end;
end;

procedure TwizfrmAddParamsFunc.SetBlock(const Value: TVisualBlock);
begin
  FBlock := Value;
end;

procedure TwizfrmAddParamsFunc.pmAddPopup(Sender: TObject);
begin
  miAccount.Clear;
  FillAccountMenuItem(pmAdd, miAccount, ClickAccount, ClickAccountCicle);
  miAnalitics.Clear;
  FillAnaliticMenuItem(pmAdd, miAnalitics, ClickAnal, ClickCustomAnal, ClickAnalCycle, nil);
end;

procedure TwizfrmAddParamsFunc.ClickAccount(Sender: TObject);
begin
  actAccount.Execute;
end;

procedure TwizfrmAddParamsFunc.ClickAccountCicle(Sender: TObject);
begin
  FActiveEdit.SelText := Format('GS.GetAnalyticValue(%s, "%s")',
    [TVisualBlock(TMenuItem(Sender).Tag).BlockName, 'alias'])
end;

procedure TwizfrmAddParamsFunc.ClickAnal(Sender: TObject);
begin
  actAddAnalytics.Execute
end;

procedure TwizfrmAddParamsFunc.ClickAnalCycle(Sender: TObject);
begin
  if (FActiveEdit.Text > '') then
  begin
    FActiveEdit.Text := FActiveEdit.Text + ' + "; " + ';
  end;

  FActiveEdit.Text := FActiveEdit.Text + Format('GS.GetAnalytics(%s, "%s")',
    [TVisualBlock(TMenuItem(Sender).Tag).BlockName,
    TMenuItem(Sender).Caption])
end;

procedure TwizfrmAddParamsFunc.actExpressionExecute(Sender: TObject);
begin
  if (MainFunction <> nil) and (FActiveEdit <> nil) then
  begin
    FactiveEdit.Text := MainFunction.EditExpression(FActiveEdit.Text, MainFunction);
  end;
end;

procedure TwizfrmAddParamsFunc.ClickCustomAnal(Sender: TObject);
begin
  if CustomAnalyticForm.ShowModal = mrOk then
  begin
    FActiveEdit.SelText := CustomAnalyticForm.Value;
  end;
end;

procedure TwizfrmAddParamsFunc.actAddAnalyticsExecute(Sender: TObject);
var
  D: TfrmAnalytics;
begin
  D := TfrmAnalytics.Create(nil);
  try
    D.Block := Block;
    if D.ShowModal = idOk then
    begin
      if (FActiveEdit.Text > '') then
      begin
        FActiveEdit.Text := FActiveEdit.Text + ' + "; " + ';
      end;

      FActiveEdit.Text := FActiveEdit.Text +  D.Analytics;
    end;
  finally
    D.Free
  end;
end;

end.
