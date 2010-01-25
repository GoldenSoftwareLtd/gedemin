unit gdv_dlgInvCardParams_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Mask, xDateEdits, ExtCtrls, frFieldVlues_unit,
  ActnList, frFieldValuesLine_unit, Db, IBCustomDataSet, gdcBase,
  gdcInvMovement, gdcBaseInterface, frFieldValuesLineConfig_unit, contnrs,
  at_Classes, gd_ClassList, gdc_createable_form, gdv_InvCardConfig_unit;

type
  Tgdv_dlgInvCardParams = class(TgdcCreateableForm)
    Panel1: TPanel;
    pnlDate: TPanel;
    Bevel1: TBevel;
    pcValues: TPageControl;
    tsCardValues: TTabSheet;
    tsGoodValues: TTabSheet;
    btnOK: TButton;
    btnCancel: TButton;
    ActionList1: TActionList;
    actOk: TAction;
    actCancel: TAction;
    actPrepare: TAction;
    frMainValues: TfrFieldValues;
    frCardValues: TfrFieldValues;
    frGoodValues: TfrFieldValues;
    Bevel2: TBevel;
    Label8: TLabel;
    Label6: TLabel;
    xdeStart: TxDateEdit;
    Label7: TLabel;
    xdeFinish: TxDateEdit;
    frDebitDocsValues: TfrFieldValues;
    frCreditDocsValues: TfrFieldValues;
    procedure FormCreate(Sender: TObject);
    procedure actPrepareExecute(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
  private
    function Validate: boolean;
  public
    procedure PrepareDialog;
  end;

var
  gdv_dlgInvCardParams: Tgdv_dlgInvCardParams;

implementation

{$R *.DFM}

procedure Tgdv_dlgInvCardParams.FormCreate(Sender: TObject);
begin
  frCardValues.ViewKind:= vkSimple;
  frGoodValues.ViewKind:= vkSimple;
  frCardValues.sbMain.BorderStyle:= bsSingle;
  frGoodValues.sbMain.BorderStyle:= bsSingle;
  frMainValues.ViewKind:= vkSimple;
  frDebitDocsValues.ViewKind:= vkSimple;
  frCreditDocsValues.ViewKind:= vkSimple;
end;

procedure Tgdv_dlgInvCardParams.PrepareDialog;
var
  FieldList: TObjectList;
  S: TStrings;
  I: Integer;
  gdcConfig: TgdcInvCardConfig;
begin
  gdcConfig:= gdcObject as TgdcInvCardConfig;
  if not Assigned(gdcConfig) then Exit;
  FieldList:= TObjectList.Create;
  FieldList.OwnsObjects:= False;
  S := TStringList.Create;
  try
    if gdcConfig.Config.GoodValue = cInputParam then
      FieldList.Add(atDataBase.Relations.ByRelationName('INV_CARD').RelationFields.ByFieldName('GOODKEY'));
    if gdcConfig.Config.DeptValue = cInputParam then
      FieldList.Add(atDataBase.Relations.ByRelationName('INV_MOVEMENT').RelationFields.ByFieldName('CONTACTKEY'));
    frMainValues.UpdateFieldList(FieldList);
    if frMainValues.IndexOf('GOODKEY') > -1 then
      frMainValues.Lines[frMainValues.IndexOf('GOODKEY')].lblName.Caption:= 'ТМЦ:';
    if frMainValues.IndexOf('CONTACTKEY') > -1 then
      frMainValues.Lines[frMainValues.IndexOf('CONTACTKEY')].lblName.Caption:= 'Подразделение:';
    frMainValues.UpdateLines;
    frMainValues.UpdateFrameHeight;
    frMainValues.Visible:= frMainValues.LinesCount > 0;
    FieldList.Clear;
    FieldList.Add(atDataBase.Relations.ByRelationName('GD_DOCUMENT').RelationFields.ByFieldName('DOCUMENTTYPEKEY'));
    frDebitDocsValues.Visible:= Pos(cInputParam, gdcConfig.Config.DebitDocsValue) > 0;
    frCreditDocsValues.Visible:= Pos(cInputParam, gdcConfig.Config.CreditDocsValue) > 0;
    if frDebitDocsValues.Visible then begin
      frDebitDocsValues.UpdateFieldList(FieldList);
      frDebitDocsValues.Lines[0].lblName.Caption:= 'Документы прихода:';
      frDebitDocsValues.UpdateFrameHeight;
      frDebitDocsValues.UpdateLines;
    end;
    if frCreditDocsValues.Visible then begin
      frCreditDocsValues.UpdateFieldList(FieldList);
      frCreditDocsValues.Lines[0].lblName.Caption:= 'Документы расхода:';
      frCreditDocsValues.UpdateFrameHeight;
      frCreditDocsValues.UpdateLines;
    end;

    pnlDate.Visible:= not gdcConfig.Config.AllInterval;
    if pnlDate.Visible then
      pnlDate.Visible:= gdcConfig.Config.InputInterval;

    FieldList.Clear;
    S.Text := gdcConfig.Config.CardValues;
    for I := 0 to S.Count - 1 do begin
      if S.Values[S.Names[I]] = cInputParam then
        FieldList.Add(atDataBase.Relations.ByRelationName('INV_CARD').RelationFields.ByFieldName(S.Names[I]));
    end;
    frCardValues.UpdateFieldList(FieldList);
    tsCardValues.TabVisible:= frCardValues.LinesCount > 0;

    FieldList.Clear;
    S.Text := gdcConfig.Config.GoodValues;
    for I := 0 to S.Count - 1 do begin
      if S.Values[S.Names[I]] = cInputParam then
        FieldList.Add(atDataBase.Relations.ByRelationName('GD_GOOD').RelationFields.ByFieldName(S.Names[I]));
    end;
    frGoodValues.UpdateFieldList(FieldList);
    tsGoodValues.TabVisible:= frGoodValues.LinesCount > 0;

    pcValues.Visible:= tsGoodValues.TabVisible or tsCardValues.TabVisible;
  finally
    S.Free;
    FieldList.Free;
  end;
end;

procedure Tgdv_dlgInvCardParams.actPrepareExecute(Sender: TObject);
begin
  PrepareDialog;
end;

procedure Tgdv_dlgInvCardParams.actOkExecute(Sender: TObject);
begin
  if Validate then
    ModalResult:= mrOk;
end;

procedure Tgdv_dlgInvCardParams.actCancelExecute(Sender: TObject);
begin
  ModalResult:= mrCancel;
end;

function Tgdv_dlgInvCardParams.Validate: boolean;
var
  S: TStrings;
  I: Integer;
  gdcConfig: TgdcInvCardConfig;
  GoodV: string;
begin
  Result:= False;
  gdcConfig:= gdcObject as TgdcInvCardConfig;
  if not Assigned(gdcConfig) then Exit;
  S := TStringList.Create;
  try
    if pnlDate.Visible then begin
      gdcConfig.Config.BeginDate:= xdeStart.Date;
      gdcConfig.Config.EndDate:= xdeFinish.Date;
      if xdeStart.Date > xdeFinish.Date then
        raise Exception.Create('Дата начала должна быть меньше либо равна дате окончания!');
    end;

    if gdcConfig.Config.GoodValue = cInputParam then
      GoodV:= frMainValues.Lines[frMainValues.IndexOf('GOODKEY')].Value;

    S.Text := gdcConfig.Config.GoodValues;
    for I := 0 to S.Count - 1 do begin
      if S.Values[S.Names[I]] = cInputParam then
        S.Values[S.Names[I]]:= frGoodValues.Lines[frGoodValues.IndexOf(S.Names[I])].Value;
    end;
    for I := S.Count - 1 downto 0 do begin
      if S.Values[S.Names[I]] = '' then
        S.Delete(I);
    end;

    if (GoodV = '') and (S.Count = 0) then
      raise Exception.Create('Необходимо выбрать ТМЦ или задать признаки товара!');

    Result:= True;
  finally
    S.Free;
  end;
end;

initialization
  RegisterFrmClass(Tgdv_dlgInvCardParams);

finalization
  UnRegisterFrmClass(Tgdv_dlgInvCardParams);

end.
