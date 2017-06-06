unit gdv_dlgInvCardParams_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Mask, xDateEdits, ExtCtrls, frFieldVlues_unit,
  ActnList, frFieldValuesLine_unit, Db, IBCustomDataSet, gdcBase,
  gdcInvMovement, gdcBaseInterface, frFieldValuesLineConfig_unit, contnrs,
  at_Classes, gd_ClassList, gdc_createable_form, gdv_InvCardConfig_unit,
  gsPeriodEdit;

type
  Tgdv_dlgInvCardParams = class(TgdcCreateableForm)
    btnOK: TButton;
    btnCancel: TButton;
    ActionList1: TActionList;
    actOk: TAction;
    actCancel: TAction;
    actPrepare: TAction;
    Panel1: TPanel;
    pnlDate: TPanel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Label8: TLabel;
    gsPeriodEdit: TgsPeriodEdit;
    frMainValues: TfrFieldValues;
    frDebitDocsValues: TfrFieldValues;
    frCreditDocsValues: TfrFieldValues;
    pcValues: TPageControl;
    tsCardValues: TTabSheet;
    frCardValues: TfrFieldValues;
    tsGoodValues: TTabSheet;
    frGoodValues: TfrFieldValues;
    procedure FormCreate(Sender: TObject);
    procedure actPrepareExecute(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure frMainValuesResize(Sender: TObject);
    procedure frDebitDocsValuesResize(Sender: TObject);
    procedure frCreditDocsValuesResize(Sender: TObject);
  private
    function Validate: boolean;
  public
    procedure PrepareDialog;
    procedure UpdateFormHeight;

    procedure SaveSettings; override;
  end;

var
  gdv_dlgInvCardParams: Tgdv_dlgInvCardParams;

implementation

{$R *.DFM}

uses Storages, gsStorage_CompPath;

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

    if Assigned(UserStorage) then
    begin
      frMainValues.Values := UserStorage.ReadString(BuildComponentPath(frMainValues), 'MainValues', '');
      gsPeriodEdit.AssignPeriod(UserStorage.ReadString(BuildComponentPath(gsPeriodEdit), 'Period', ''));
      frDebitDocsValues.Values := UserStorage.ReadString(BuildComponentPath(frDebitDocsValues), 'DebitDocsValues', '');
      frCreditDocsValues.Values := UserStorage.ReadString(BuildComponentPath(frCreditDocsValues), 'CreditDocsValues', '');
      frCardValues.Values := UserStorage.ReadString(BuildComponentPath(frCardValues), 'CardValues', '');
      frGoodValues.Values := UserStorage.ReadString(BuildComponentPath(frGoodValues), 'GoodValues', '');
    end;  

  finally
    S.Free;
    FieldList.Free;
  end;

  UpdateFormHeight;
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
      gdcConfig.Config.BeginDate:= gsPeriodEdit.Date;
      gdcConfig.Config.EndDate:= gsPeriodEdit.EndDate;
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

procedure Tgdv_dlgInvCardParams.UpdateFormHeight;
var H: integer;
begin
    H := 0;
    H := H + ord(frMainValues.Visible) * frMainValues.Height;
    H := H + ord(pnlDate.Visible) * pnlDate.Height;
    H := H + ord(frDebitDocsValues.Visible) * frDebitDocsValues.Height;
    H := H + ord(frCreditDocsValues.Visible) * frCreditDocsValues.Height;
    H := H + ord(pcValues.Visible) * pcValues.Height;

    Panel1.Height := H;
    self.Height := H + 70;
end;

procedure Tgdv_dlgInvCardParams.frMainValuesResize(Sender: TObject);
begin
  UpdateFormHeight;
end;

procedure Tgdv_dlgInvCardParams.frDebitDocsValuesResize(Sender: TObject);
begin
  UpdateFormHeight;
end;

procedure Tgdv_dlgInvCardParams.frCreditDocsValuesResize(Sender: TObject);
begin
  UpdateFormHeight;
end;

procedure Tgdv_dlgInvCardParams.SaveSettings;
begin
  inherited;
  UserStorage.WriteString(BuildComponentPath(frMainValues), 'MainValues', frMainValues.Values);
  UserStorage.WriteString(BuildComponentPath(gsPeriodEdit), 'Period', gsPeriodEdit.Text);
  UserStorage.WriteString(BuildComponentPath(frDebitDocsValues), 'DebitDocsValues', frDebitDocsValues.Values);
  UserStorage.WriteString(BuildComponentPath(frCreditDocsValues), 'CreditDocsValues', frCreditDocsValues.Values);
  UserStorage.WriteString(BuildComponentPath(frCardValues), 'CardValues', frCardValues.Values);
  UserStorage.WriteString(BuildComponentPath(frGoodValues), 'GoodValues', frGoodValues.Values);
end;

initialization
  RegisterFrmClass(Tgdv_dlgInvCardParams);

finalization
  UnRegisterFrmClass(Tgdv_dlgInvCardParams);

end.
