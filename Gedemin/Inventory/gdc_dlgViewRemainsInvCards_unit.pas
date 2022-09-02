unit gdc_dlgViewRemainsInvCards_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, DBGrids, gsDBGrid, gsIBGrid, ActnList, Db, IBCustomDataSet,
  ExtCtrls, StdCtrls, gdc_createable_form, gdcBaseInterface, gdcInvDocument_unit;

type
  Tgdc_dlgViewRemainsInvCards = class(TgdcCreateableForm)
    pnlBottom: TPanel;
    Button2: TButton;
    pnlMain: TPanel;
    lHeader: TLabel;
    Panel2: TPanel;
    Bevel1: TBevel;
    ibdsInvCardList: TIBDataSet;
    dsInvCardList: TDataSource;
    ActionList1: TActionList;
    actOk: TAction;
    actCancel: TAction;
    ibgrInvCardList: TgsIBGrid;
    Button1: TButton;
    procedure actCancelExecute(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
  private
    FInvDocLine: TgdcInvDocumentLine;
    procedure SetInvDocLine(const Value: TgdcInvDocumentLine);
  public
    procedure OpenDataSet(ADocLine: TgdcInvDocumentLine; AContactKey: TID; const ABalance: integer = 0);

    procedure LoadSettings; override;
    procedure SaveSettings; override;

    property InvDocumentLine: TgdcInvDocumentLine read FInvDocLine write SetInvDocLine;
  end;

var
  gdc_dlgViewRemainsInvCards: Tgdc_dlgViewRemainsInvCards;

implementation

uses
  Storages, gd_ClassList;

{$R *.DFM}

procedure Tgdc_dlgViewRemainsInvCards.actOkExecute(Sender: TObject);
begin
  ModalResult:= mrOk;
end;

procedure Tgdc_dlgViewRemainsInvCards.actCancelExecute(Sender: TObject);
begin
  ModalResult:= mrCancel;
end;

procedure Tgdc_dlgViewRemainsInvCards.LoadSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGVIEWREMAINSINVCARDS', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGVIEWREMAINSINVCARDS', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGVIEWREMAINSINVCARDS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGVIEWREMAINSINVCARDS',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGVIEWREMAINSINVCARDS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  UserStorage.LoadComponent(ibgrInvCardList, ibgrInvCardList.LoadFromStream);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGVIEWREMAINSINVCARDS', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGVIEWREMAINSINVCARDS', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgViewRemainsInvCards.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGVIEWREMAINSINVCARDS', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGVIEWREMAINSINVCARDS', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGVIEWREMAINSINVCARDS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGVIEWREMAINSINVCARDS',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGVIEWREMAINSINVCARDS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  UserStorage.SaveComponent(ibgrInvCardList, ibgrInvCardList.SaveToStream);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGVIEWREMAINSINVCARDS', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGVIEWREMAINSINVCARDS', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgViewRemainsInvCards.SetInvDocLine(
  const Value: TgdcInvDocumentLine);
var
  sFN: string;
  i: integer;
begin
  FInvDocLine:= Value;
  ibdsInvCardList.Transaction:= FInvDocLine.Transaction;

  if High(FInvDocLine.SourceFeatures) > -1 then
    ibdsInvCardList.SelectSQL.Add(' WHERE ');

//  Признаки существующей карточки
  for i:= Low(FInvDocLine.SourceFeatures) to High(FInvDocLine.SourceFeatures) do begin
    if i > 0 then
      ibdsInvCardList.SelectSQL.Add(' AND ');
    sFN:= FInvDocLine.SourceFeatures[i];
    if FInvDocLine.FieldByName('FROM_' + sFN).IsNull then
      ibdsInvCardList.SelectSQL.Add('c.' + sFN + ' is null')
    else
      ibdsInvCardList.SelectSQL.Add('c.' + sFN + '=:' + sFN);
  end;
  ibdsInvCardList.Prepare;
  for i:= Low(FInvDocLine.SourceFeatures) to High(FInvDocLine.SourceFeatures) do begin
    sFN:= FInvDocLine.SourceFeatures[i];
    if not FInvDocLine.FieldByName('FROM_' + sFN).IsNull then
      ibdsInvCardList.ParamByName(sFN).Value:= FInvDocLine.FieldByName('FROM_' + sFN).Value;
  end;
end;

procedure Tgdc_dlgViewRemainsInvCards.OpenDataSet(
  ADocLine: TgdcInvDocumentLine; AContactKey: TID; const ABalance: integer);
begin
  InvDocumentLine:= ADocLine;
  SetTID(ibdsInvCardList.ParamByName('contactkey'), AContactKey);
  ibdsInvCardList.ParamByName('count').AsInteger:= ABalance;
  SetTID(ibdsInvCardList.ParamByName('cardkey'), GetTID(ADocLine.FieldByName('fromcardkey')));
  SetTID(ibdsInvCardList.ParamByName('gid'), GetTID(ADocLine.FieldByName('goodkey')));
  ibgrInvCardList.CheckBox.FieldName:= 'id';
  ibdsInvCardList.Open;
end;

end.
