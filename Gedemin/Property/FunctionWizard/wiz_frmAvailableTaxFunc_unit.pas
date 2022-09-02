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
unit wiz_frmAvailableTaxFunc_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  tax_frmAvailableTaxFunc_unit, StdCtrls, ComCtrls, ExtCtrls, wiz_FunctionBlock_unit,
  gdcBaseInterface;

type
  TwizfrmAvailableTaxFunc = class(TfrmAvailableTaxFunc)
  private
    FBlock: TVisualBlock;
    procedure SetBlock(const Value: TVisualBlock);
    { Private declarations }
  protected
    FLocalFuncArray: TTaxFuncArray;
    function GetAddParamsFuncForm: TFormClass; override;
    procedure InitAddParamsFuncForm(F: TForm); override;

    procedure CreateLocalFuncBlock;
    procedure AddCFFunctions; override;
  public
    { Public declarations }
    constructor CreateWithParams(const Owner: TComponent;
      const ActualTaxKey: TID = 0 ; const CurrentFunctionName: String = ''); override;

    property Block: TVisualBlock read FBlock write SetBlock;
  end;

var
  wizfrmAvailableTaxFunc: TwizfrmAvailableTaxFunc;

implementation
uses wiz_frmAddParamFunc_unit, wiz_FunctionsParams_unit;
{$R *.DFM}

{ TwizfrmAvailableTaxFunc }

procedure TwizfrmAvailableTaxFunc.AddCFFunctions;
begin
  AddFunctions(FLocalFuncArray);
end;

procedure TwizfrmAvailableTaxFunc.CreateLocalFuncBlock;
var
  L: TList;
  I, J: Integer;
  P: string;
begin
  L := TList.Create;
  try
    FunctionList(L);
    SetLength(FLocalFuncArray, L.Count);
    for I := 0 to L.Count - 1 do
    begin
      FLocalFuncArray[I].Name := TFunctionBlock(L[I]).BlockName;
      FLocalFuncArray[I].ShHelp := TFunctionBlock(L[I]).Description;
      FLocalFuncArray[I].FType := ftCF;
      SetLength(FLocalFuncArray[I].ParamArray, TFunctionBlock(L[I]).FunctionParams.Count);
      P := '';
      for J := 0 to TFunctionBlock(L[I]).FunctionParams.Count - 1 do
      begin
        if P > '' then P := P + ', ';
        FLocalFuncArray[I].ParamArray[J] :=
          TwizParamData(TFunctionBlock(L[I]).FunctionParams[J]).RealName;
        P := P + FLocalFuncArray[I].ParamArray[J];
      end;
      FLocalFuncArray[I].Descr := FLocalFuncArray[I].Name + '(' + P + ')';
    end;
  finally
    L.Free;
  end;
end;

constructor TwizfrmAvailableTaxFunc.CreateWithParams(
  const Owner: TComponent; const ActualTaxKey: TID;
  const CurrentFunctionName: String);
var
  Root, Node: TTreeNode;
begin
  inherited;

  Root := tvTypeFunction.Items.GetFirstNode;

  Node := tvTypeFunction.Items.AddChild(Root, '(CF) Текущей автоматической операции');
  Node.Data := Pointer(ftCF);
  Node.ImageIndex := 0;
  Node.SelectedIndex := 0;

  CreateLocalFuncBlock;
end;

function TwizfrmAvailableTaxFunc.GetAddParamsFuncForm: TFormClass;
begin
  Result := TwizfrmAddParamsFunc;
end;

procedure TwizfrmAvailableTaxFunc.InitAddParamsFuncForm(F: TForm);
begin
  TwizfrmAddParamsFunc(F).Block := FBlock;
end;

procedure TwizfrmAvailableTaxFunc.SetBlock(const Value: TVisualBlock);
begin
  FBlock := Value;
end;

end.
