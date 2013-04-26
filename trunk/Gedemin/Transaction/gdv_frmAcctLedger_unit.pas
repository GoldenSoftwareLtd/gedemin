unit gdv_frmAcctLedger_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdv_frmAcctBaseForm_unit, Db, IBCustomDataSet, flt_sqlFilter,
  gd_ReportMenu, Menus, gd_MacrosMenu, ActnList, gdv_frAcctCompany_unit,
  gdv_frAcctAnalytics_unit, gdv_frAcctSum_unit, gdv_frAcctQuantity_unit,
  StdCtrls, Grids, DBGrids, gsDBGrid, gsIBGrid, Mask, xDateEdits, Buttons,
  ExtCtrls, TB2Item, TB2Dock, TB2Toolbar, gdv_frAcctAnalyticsGroup_unit,
  gd_ClassList, IBSQL, at_classes, gdcBaseInterface, Storages, gsStorage_CompPath,
  AcctStrings, AcctUtils, gd_security, Contnrs, IBDataBase, gdv_AcctConfig_unit,
  gsIBLookupComboBox, gdv_frAcctBaseAnalyticGroup, gdvParamPanel, gdcConstants,
  gd_createable_form, gdv_frAcctTreeAnalytic_unit, gdv_frAcctTreeAnalyticLine_unit,
  gdvAcctBase, gdvAcctLedger, gsPeriodEdit;

type
  Tgdv_ValueList = class;

  Tgdv_SaldoValue = class
  private
    FSaldoName: string;
    FSaldoValue: Currency;
    procedure SetSaldoName(const Value: string);
    procedure SetSaldoValue(const Value: Currency);
  public
    property SaldoName: string read FSaldoName write SetSaldoName;
    property SaldoValue: Currency read FSaldoValue write SetSaldoValue;
  end;

  Tgdv_SaldoValues = class(TObjectList)
  private
    function GetSaldoList(Index: Integer): Tgdv_SaldoValue;
  public
    constructor Create;
    function IndexOf(FieldName: string): Integer;
    function AddSaldoValue(SaldoName: string; SaldoValue: Currency): Integer;
    property SaldoList[Index: Integer]: Tgdv_SaldoValue read GetSaldoList; default;
  end;

  Tgdv_Value = class
  private
    FValues: Tgdv_ValueList;
    FValue: string;
    FSaldoValues: Tgdv_SaldoValues;
    function GetValues: Tgdv_ValueList;
    procedure SetValue(const Value: string);
    function GetSaldoValues: Tgdv_SaldoValues;

  public
    destructor Destroy; override;

    property Value: string read FValue write SetValue;
    property Values: Tgdv_ValueList read GetValues;
    property SaldoValues: Tgdv_SaldoValues read GetSaldoValues;
  end;

  Tgdv_ValueList = class
  private
    FValues: TStringList;
    function GetItems(Index: Integer): Tgdv_Value;
  public
    destructor Destroy; override;
    procedure Clear;
    function IndexOf(Value: string): Integer;
    function Add(Value: string): Tgdv_Value;
    function Add2(Value: string): Integer;

    property Items[Index: Integer]: Tgdv_Value read GetItems; default;
  end;

  Tgdv_frmAcctLedger = class(Tgdv_frmAcctBaseForm)
    cbShowDebit: TCheckBox;
    cbShowCredit: TCheckBox;
    cbShowCorrSubAccount: TCheckBox;
    frAcctAnalyticsGroup: TfrAcctAnalyticsGroup;
    cbEnchancedSaldo: TCheckBox;
    cbSumNull: TCheckBox;
    frAcctTreeAnalytic: Tgdv_frAcctTreeAnalytic;
    ibdsMain: TgdvAcctLedger;
    procedure actSaveConfigUpdate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actRunUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ibdsMainAfterOpen(DataSet: TDataSet);
    procedure ibdsMainCalcAggregates(DataSet: TDataSet;
      var Accept: Boolean);
    procedure actSaveGridSettingUpdate(Sender: TObject);
    procedure actClearGridSettingUpdate(Sender: TObject);
    
  private
    FEntryDateIsFirst: Boolean;
    FEntryDateInFields: Boolean;

    FSortFieldIndex: Integer;
    FSaldoValueList: Tgdv_ValueList;

    FTotals: TgdvLedgerTotals;

    FNeedUpdateControls: boolean;
    procedure OnAnalyticGroupSelect(Sender: TObject);

    procedure UpdateEntryDateIsFirst;
  protected
    function GetGdvObject: TgdvAcctBase; override;
    procedure SetParams; override;

    function GetSaldoBeginSQL: string;
    procedure FillBeginSaldoStructire;
    procedure CalcBeginSaldo;

    procedure InitColumns; override;
    procedure UpdateControls; override;
    procedure DoBeforeBuildReport; override;

    procedure DoLoadConfig(const Config: TBaseAcctConfig);override;
    procedure DoSaveConfig(Config: TBaseAcctConfig);override;
    procedure DoAfterBuildReport; override;
    class function ConfigClassName: string; override;
    procedure Go_to(NewWindow: Boolean = false); override;
    function CanGo_to: boolean; override;
    function CompareParams(WithDate: Boolean = True): boolean; override;
  public
    { Public declarations }
    procedure BuildAcctReport; override;

    procedure LoadSettings; override;
    procedure SaveSettings; override;
  end;

var
  gdv_frmAcctLedger: Tgdv_frmAcctLedger;

implementation

uses
  gdv_frmAcctAccCard_Unit, IBHeader
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  , gd_KeyAssoc;

{$R *.DFM}
{ Tgdv_frmAcctLedger }

procedure Tgdv_frmAcctLedger.FormCreate(Sender: TObject);
begin
  FTotals := TgdvLedgerTotals.Create;
  TgdvAcctLedger(gdvObject).Totals := FTotals;
  
  FNeedUpdateControls:= False;
  inherited;
  FNeedUpdateControls:= True;
  UpdateControls;
  frAcctAnalyticsGroup.OnSelect := OnAnalyticGroupSelect;
  OnAnalyticGroupSelect(frAcctAnalyticsGroup);
end;

procedure Tgdv_frmAcctLedger.DoBeforeBuildReport;
var
  I, Index: Integer;
  FieldName: string;
begin
  inherited;

  FTotals.Clear;

  UpdateEntryDateIsFirst;

  FSortFieldIndex := - 1;
  //Если дата первая аналитика, то итого по начальному и конечному сальдо не
  //подсчитываем
  if FEntryDateInFields then
  begin
    for I := 0 to BaseAcctFieldCount - 1 do
    begin
      if not (I in [baNCU_Debit_Index, baNCU_Credit_Index, baCurr_Debit_Index,
        baCurr_Credit_Index]) then
      begin
        FieldName := BaseAcctFieldList[I].FieldName;
        Index := FFieldInfos.IndexByFieldName(FieldName);
        if Index >= - 1 then
        begin
          FFieldInfos[Index].Total := False;
        end;
      end;
    end;
  end;

end;

procedure Tgdv_frmAcctLedger.LoadSettings;
{@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
{M}VAR
{M}  Params, LResult: Variant;
{M}  tmpStrings: TStackStrings;
{END MACRO}
var
  ComponentPath: string;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDV_FRMACCTLEDGER', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDV_FRMACCTLEDGER', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDV_FRMACCTLEDGER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDV_FRMACCTLEDGER',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDV_FRMACCTLEDGER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if UserStorage <> nil then
  begin
    ComponentPath := BuildComponentPath(Self);
    frAcctAnalyticsGroup.ppMain.Unwraped := UserStorage.ReadBoolean(ComponentPath, 'AnalyticGroupUnwraped', True);
    frAcctTreeAnalytic.ppMain.Unwraped := UserStorage.ReadBoolean(ComponentPath, 'TreeAnalyticUnwraped', True);
    cbShowDebit.Checked := UserStorage.ReadBoolean(ComponentPath, 'ShowDebit', True);
    cbShowCredit.Checked := UserStorage.ReadBoolean(ComponentPath, 'ShowCredit', True);
    cbShowCorrSubAccount.Checked := UserStorage.ReadBoolean(ComponentPath, 'ShowCorrSubAccount', True);

//    Panel2.Height := UserStorage.ReadInteger(BuildComponentPath(Self), 'PanelHeight', 159);
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDV_FRMACCTLEDGER', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDV_FRMACCTLEDGER', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdv_frmAcctLedger.SaveSettings;
{@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
{M}VAR
{M}  Params, LResult: Variant;
{M}  tmpStrings: TStackStrings;
{END MACRO}
var
  ComponentPath: string;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDV_FRMACCTLEDGER', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDV_FRMACCTLEDGER', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDV_FRMACCTLEDGER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDV_FRMACCTLEDGER',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDV_FRMACCTLEDGER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  if UserStorage <> nil then
  begin
    ComponentPath := BuildComponentPath(Self);
    UserStorage.WriteBoolean(ComponentPath, 'AnalyticGroupUnwraped', frAcctAnalyticsGroup.ppMain.Unwraped);
    UserStorage.WriteBoolean(ComponentPath, 'TreeAnalyticUnwraped', frAcctTreeAnalytic.ppMain.Unwraped);
    UserStorage.WriteBoolean(ComponentPath, 'ShowDebit', cbShowDebit.Checked);
    UserStorage.WriteBoolean(ComponentPath, 'ShowCredit', cbShowCredit.Checked);
    UserStorage.WriteBoolean(ComponentPath, 'ShowCorrSubAccount', cbShowCorrSubAccount.Checked);

//    UserStorage.WriteInteger(BuildComponentPath(Self), 'PanelHeight', Panel2.Height);
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDV_FRMACCTLEDGER', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDV_FRMACCTLEDGER', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdv_frmAcctLedger.UpdateControls;
begin
  if not FNeedUpdateControls then Exit;
  inherited;
  frAcctAnalyticsGroup.UpdateAnalyticsList(FAccountIDs);
end;

procedure Tgdv_frmAcctLedger.DoLoadConfig(const Config: TBaseAcctConfig);
var
  C: TAccLedgerConfig;
begin
  inherited;
  if Config is TAccLedgerConfig then
  begin
    C := Config as TAccLedgerConfig;
    cbShowDebit.Checked := C.ShowDebit;
    cbShowCredit.Checked := C.ShowCredit;
    cbShowCorrSubAccount.Checked := C.ShowCorrSubAccounts;
    C.AnalyticsGroup.Position := 0;
    frAcctAnalyticsGroup.UpdateAnalyticsList(FAccountIDs);
    frAcctAnalyticsGroup.LoadFromStream(C.AnalyticsGroup);
    frAcctAnalyticsGroup.AnalyticListFields := C.AnalyticListField;
    cbSumNull.Checked := C.SumNull;
    cbEnchancedSaldo.Checked := C.EnchancedSaldo;
    frAcctTreeAnalytic.TreeAnalitic := C.TreeAnalytic;
  end;
end;

procedure Tgdv_frmAcctLedger.DoSaveConfig(Config: TBaseAcctConfig);
var
  C: TAccLedgerConfig;
begin
  inherited;
  if Config is TAccLedgerConfig then
  begin
    C := Config as TAccLedgerConfig;
    C.ShowDebit := cbShowDebit.Checked;
    C.ShowCredit := cbShowCredit.Checked;
    C.ShowCorrSubAccounts := cbShowCorrSubAccount.Checked;
    C.AnalyticsGroup.Size := 0;
    frAcctAnalyticsGroup.SaveToStream(C.AnalyticsGroup);
    C.AnalyticListField := frAcctAnalyticsGroup.AnalyticListFields;
    C.SumNull := cbSumNull.Checked;
    C.EnchancedSaldo := cbEnchancedSaldo.Checked;
    C.TreeAnalytic := frAcctTreeAnalytic.TreeAnalitic;
  end;
end;

procedure Tgdv_frmAcctLedger.DoAfterBuildReport;
begin
  if cbShowDebit.Checked or cbShowCredit.Checked then
  begin
    InitColumns;
    ibgrMain.ResizeColumns;
    ibgrMain.Columns.EndUpdate;
  end else
    inherited;
end;

class function Tgdv_frmAcctLedger.ConfigClassName: string;
begin
  Result := 'TAccLedgerConfig'
end;

procedure Tgdv_frmAcctLedger.InitColumns;
var
  I, J: Integer;
  FI: TgdvFieldInfo;
  DisplayFields: string;
  FIndex, DIndex: Integer;
  C: TgsColumn;
  P: Integer;
begin
  inherited;
  
  if (FFieldInfos <> nil) and (ibgrMain.Conditions.Count > 0) then
  begin
    for I := 0 to ibgrMain.Conditions.Count - 1 do
    begin
      C := FindColumn(UpperCase(ibgrMain.Conditions[I].FieldName));
      if (C <> nil) and (C.Field <> nil) then
      begin
        FIndex := C.Field.Index;

        DisplayFields := ibgrMain.Conditions[I].DisplayFields;
        for J := 0 to FFieldInfos.Count - 1 do
        begin
          FI := FFieldInfos[J];
          if FI.Condition then
          begin
            P := Pos(FI.FieldName + ';', DisplayFields);
            if P > 0 then
              Delete(DisplayFields, P, Length(FI.FieldName + ';'));
            C := FindColumn(FI.FieldName);
            if (C <> nil) and (C.Field <> nil) then
            begin
              DIndex := C.Field.Index;
              if DIndex >= FIndex then
              begin
                if (DisplayFields > '') and (DisplayFields[Length(DisplayFields)] <> ';') then
                  DisplayFields := DisplayFields + ';';
                DisplayFields := DisplayFields + FI.FieldName + ';';
              end;
            end;
          end;
        end;
        ibgrMain.Conditions[I].DisplayFields := DisplayFields;
      end;
    end;
  end;
end;

procedure Tgdv_frmAcctLedger.Go_to(NewWindow: Boolean = false);
var
  F: TField;
  C: TAccCardConfig;
  FI: TgdvFieldInfo;
  A: String;
  I, iTmp: Integer;
  wY, wQ, wM, wBY, wBM, wBD, wEY, wEM, wED, wQBM, WQEM: word;
  FieldName, sDName, sMName, sQName, sYName, sTmp: string;
  Form: TCreateableForm;
  dtBegin, dtEnd: TDateTime;

  function GetMonthLastDay(const AMonth, AYear: word): word;
  begin
    Result:= 28;
    case AMonth of
      1, 3, 5, 7, 8, 10, 12:
        Result:= 31;
      4, 6, 9, 11:
        Result:= 30;
      2:
        if IsLeapYear(AYear) then
          Result:= 29
        else
          Result:= 28;
    end;
  end;

  procedure GetQuarterMonths(const AQuarter: word; var ABegin, AEnd: word);
  begin
    case AQuarter of
      1:begin
          ABegin:= 1;
          AEnd:= 3;
        end;
      2:begin
          ABegin:= 4;
          AEnd:= 6;
        end;
      3:begin
          ABegin:= 7;
          AEnd:= 9;
        end;
      4:begin
          ABegin:= 10;
          AEnd:= 12;
        end;
    end;
  end;

begin
  Form := gd_createable_form.FindForm(Tgdv_frmAcctAccCard);

  F := ibgrMain.SelectedField;
  if F <> nil then
  begin
    C := TAccCardConfig.Create;
    try
      DoSaveConfig(C);
      // Закомментировано - поля заполняются в Tgdv_frmAcctBaseForm.DoSaveConfig
      //C.CompanyKey := frAcctCompany.iblCompany.CurrentKeyInt;
      //C.AllHoldingCompanies := frAcctCompany.cbAllCompanies.Checked;
      C.IncCorrSubAccounts := False;
      C.CorrAccounts := '';

      FI := FFieldInfos.FindInfo(F.FieldName);
      if (FI <> nil) and (FI is TgdvLedgerFieldInfo) then
      begin
        C.CorrAccounts := GetAlias(TgdvLedgerFieldInfo(FI).AccountKey);
        C.AccountPart := TgdvLedgerFieldInfo(FI).AccountPart;
      end;

      iTmp:= 0;
      A := '';
      sDName:= ''; sMName:= ''; sQName:= ''; sYName:= '';
      for I := 0 to frAcctAnalyticsGroup.Selected.Count - 1 do
      begin
        if frAcctAnalyticsGroup.Selected[I].FieldName = ENTRYDATE then begin
          iTmp:= 1;
          sDName:= 'NAME' + IntToStr(I);
        end
        else if frAcctAnalyticsGroup.Selected[I].FieldName = MONTH then begin
          iTmp:= iTmp + 2;
          sMName:= 'NAME' + IntToStr(I);
        end
        else if frAcctAnalyticsGroup.Selected[I].FieldName = 'QUARTER' then begin
          iTmp:= iTmp + 4;
          sQName:= 'NAME' + IntToStr(I);
        end
        else if frAcctAnalyticsGroup.Selected[I].FieldName = 'YEAR' then begin
          iTmp:= iTmp + 8;
          sYName:= 'NAME' + IntToStr(I);
        end;

        if (frAcctAnalyticsGroup.Selected[I].Field <> nil) and
          (frAcctAnalyticsGroup.Selected[I].FieldName <> ENTRYDATE) then
        begin
          FieldName := Format('c%d', [I]);
          F := gdvObject.FindField(FieldName);
          if (F <> nil) and not F.IsNull then
          begin
            if A > '' then A := A + #13#10;

            A := A + frAcctAnalyticsGroup.Selected[I].FieldName + '=' + Trim(F.AsString);
          end;
        end;
      end;

      dtBegin:= DateBegin;
      dtEnd:= DateEnd;
      case iTmp of
        1, 3, 5, 7, 9, 11, 13, 15:begin   //   EntryDate и не важно что еще
            sTmp:= gdvObject.FieldByName(sDName).AsString;
            dtBegin:= EncodeDate(StrToInt(Copy(sTmp, 1, 4)), StrToInt(Copy(sTmp, 6, 2)), StrToInt(Copy(sTmp, 9, 2)));
            dtEnd:= dtBegin;
          end;
        2, 6:begin    //   только месяц
            wM:= StrToInt(gdvObject.FieldByName(sMName).AsString);
            DecodeDate(dtBegin, wBY, wBM, wBD);
            DecodeDate(dtEnd, wEY, wEM, wED);
            if wBY = wEY then begin
              if wBM = wM then
                dtBegin:= EncodeDate(wBY, wM, wBD)
              else
                dtBegin:= EncodeDate(wBY, wM, 1);
              if wEM = wM then
                dtEnd:= EncodeDate(wBY, wM, wED)
              else
                dtEnd:= EncodeDate(wBY, wM, GetMonthLastDay(wM, wBY));
            end
            else if (wEY - wBY = 1) and (wBM > wEM) then begin
              if wM >= wBM then begin
                if wM = wBM then
                  dtBegin:= EncodeDate(wBY, wM, wBD)
                else
                  dtBegin:= EncodeDate(wBY, wM, 1);
                dtEnd:= EncodeDate(wBY, wM, GetMonthLastDay(wM, wBY))
              end
              else begin
                dtBegin:= EncodeDate(wEY, wM, 1);
                if wM = wEM then
                  dtEnd:= EncodeDate(wEY, wM, wED)
                else
                  dtEnd:= EncodeDate(wEY, wM, GetMonthLastDay(wM, wEY));
              end;
            end
            else if (wEY - wBY = 2) and (wM > wEM) and (wM < wBM) then begin
              dtBegin:= EncodeDate(wBY + 1, wM, 1);
              dtEnd:= EncodeDate(wBY + 1, wM, GetMonthLastDay(wM, wBY + 1));
            end;
          end;
        4:begin  //   только квартал
            wQ:= StrToInt(gdvObject.FieldByName(sQName).AsString);
            DecodeDate(dtBegin, wBY, wBM, wBD);
            DecodeDate(dtEnd, wEY, wEM, wED);
            GetQuarterMonths(wQ, wQBM, wQEM);
            if wBY = wEY then begin
              if (wQBM <= wBM) and (wQEM >= wEM) then begin
                dtBegin:= EncodeDate(wBY, wBM, wBD);
                dtEnd:= EncodeDate(wBY, wEM, wED);
              end
              else if (wQBM <= wBM) and (wQEM >= wBM) then begin
                dtBegin:= EncodeDate(wBY, wBM, wBD);
                dtEnd:= EncodeDate(wBY, wQEM, GetMonthLastDay(wQEM, wBY));
              end
              else if (wQBM <= wEM) and (wQEM >= wEM) then begin
                dtBegin:= EncodeDate(wBY, wQBM, 1);
                dtEnd:= EncodeDate(wBY, wEM, wED);
              end
              else begin
                dtBegin:= EncodeDate(wBY, wQBM, 1);
                dtEnd:= EncodeDate(wBY, wQEM, GetMonthLastDay(wQEM, wBY));
              end;
            end
            else if (wEY - wBY = 1) and (wBM > wEM) then begin
              if (wQBM <= wBM) and (wQEM >= wBM) then begin
                dtBegin:= EncodeDate(wBY, wBM, wBD);
                dtEnd:= EncodeDate(wBY, wQEM, GetMonthLastDay(wQEM, wBY));
              end
              else if (wQBM <= wEM) and (wQEM >= wEM) then begin
                dtBegin:= EncodeDate(wEY, wQBM, 1);
                dtEnd:= EncodeDate(wEY, wEM, wED);
              end
              else begin
                if wBM < wQBM then begin
                  dtBegin:= EncodeDate(wBY, wQBM, 1);
                  dtEnd:= EncodeDate(wBY, wQEM, GetMonthLastDay(wQEM, wBY));
                end
                else begin
                  dtBegin:= EncodeDate(wEY, wQBM, 1);
                  dtEnd:= EncodeDate(wEY, wQEM, GetMonthLastDay(wQEM, wEY));
                end;
              end;
            end
            else if (wEY - wBY = 2) and (wQBM > wEM) and (wQEM < wBM) then begin
              dtBegin:= EncodeDate(wBY + 1, wQBM, 1);
              dtEnd:= EncodeDate(wBY + 1, wQEM, GetMonthLastDay(wQEM, wBY + 1));
            end;
          end;
        8:begin  //   только год
            wY:= StrToInt(gdvObject.FieldByName(sYName).AsString);
            DecodeDate(dtBegin, wBY, wBM, wBD);
            DecodeDate(dtEnd, wEY, wEM, wED);
            if wY = wBY then
              dtBegin:= EncodeDate(wY, wBM, wBD)
            else
              dtBegin:= EncodeDate(wY, 1, 1);
            if wY = wEY then
              dtEnd:= EncodeDate(wY, wEM, wED)
            else
              dtEnd:= EncodeDate(wY, 12, 31);
          end;
        10, 14:begin   //  месяц и год
            wY:= StrToInt(gdvObject.FieldByName(sYName).AsString);
            wM:= StrToInt(gdvObject.FieldByName(sMName).AsString);
            DecodeDate(dtBegin, wBY, wBM, wBD);
            DecodeDate(dtEnd, wEY, wEM, wED);
            if (wBY = wY) and (wBM = wM) then
              dtBegin:= EncodeDate(wY, wM, wBD)
            else
              dtBegin:= EncodeDate(wY, wM, 1);
            if (wEY = wY) and (wEM = wM) then
              dtEnd:= EncodeDate(wY, wM, wED)
            else
              dtEnd:= EncodeDate(wY, wM, GetMonthLastDay(wM, wY));
          end;
        12:begin    // год и квартал
            wQ:= StrToInt(gdvObject.FieldByName(sQName).AsString);
            wY:= StrToInt(gdvObject.FieldByName(sYName).AsString);
            DecodeDate(dtBegin, wBY, wBM, wBD);
            DecodeDate(dtEnd, wEY, wEM, wED);
            GetQuarterMonths(wQ, wQBM, wQEM);
            if (wEY = wBY) and (wQBM <= wBM) and (wQEM >= wEM) then begin
              dtBegin:= EncodeDate(wY, wBM, wBD);
              dtEnd:= EncodeDate(wY, wEM, wED);
            end
            else if (wY = wBY) and (wQBM <= wBM) and (wQEM >= wBM) then begin
              dtBegin:= EncodeDate(wY, wBM, wBD);
              dtEnd:= EncodeDate(wY, wQEM, GetMonthLastDay(wQEM, wY));
            end
            else if (wY = wEY) and (wQBM <= wEM) and (wQEM >= wEM) then begin
              dtBegin:= EncodeDate(wY, wQBM, 1);
              dtEnd:= EncodeDate(wY, wEM, wED);
            end
            else begin
              dtBegin:= EncodeDate(wY, wQBM, 1);
              dtEnd:= EncodeDate(wY, wQEM, GetMonthLastDay(wQEM, wY));
            end;
          end;
      end;

      // Добавим ограничение по аналитикам из "Группировки по аналитикам"
      if A > '' then
      begin
        if C.Analytics > '' then
          C.Analytics := C.Analytics + #13#10 + A
        else
          C.Analytics := A;
      end;

      if not NewWindow or (Form = nil) then
      begin
        with Tgdv_frmAcctAccCard(Tgdv_frmAcctAccCard.CreateAndAssign(Application)) do
        begin
          DateBegin := dtBegin;
          DateEnd := dtEnd;

          Show;
          Execute(C);
        end;
      end else
      begin
        with Tgdv_frmAcctAccCard(Tgdv_frmAcctAccCard.Create(Application)) do
        begin
          DateBegin := dtBegin;
          DateEnd := dtEnd;

          Show;
          Execute(C);
        end;
      end;
    finally
      C.Free;
    end;
  end;
end;

procedure Tgdv_frmAcctLedger.BuildAcctReport;
begin
  if (frAcctAnalyticsGroup.Selected.Count = 0) and not gdvObject.MakeEmpty then
  begin
    MessageBox(0,
      PChar(MSG_INPUTANGROUPANALYTIC),
      'Внимание',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
    if not actShowParamPanel.Checked then
      actShowParamPanel.Execute;  
  end
  else
    inherited;
end;

function Tgdv_frmAcctLedger.GetSaldoBeginSQL: string;
var
  I: Integer;
  DebitCreditSQL: string;
  F: TatRelationField;
  SelectClause, FromClause, FromClause1, GroupClause, OrderClause: string;
  IDSelect, NameSelect, WhereClause, QuantityGroup: String;
  Alias, Name: string;
  CurrId, HavingClause: string;
  NcuDecDig, CurrDecDig: String;
  AnalyticFilter: string;
  K: Integer;
  ValueAlias, QuantityAlias: String;
  Strings: TgdvCorrFieldInfoList;
  SortName, SortSelect: string;
  VKeyAlias: string;
  NcuBegin, CurrBegin: string;
begin
  Result := '';
  Strings := TgdvCorrFieldInfoList.Create;
  try
    DebitCreditSQL := '';
    FromClause := '';
    FromClause1 := '';
    GroupClause := '';
    OrderClause := '';
    IDSelect := '';
    NameSelect := '';
    WhereClause := '';

    frAcctAnalytics.Alias := 'e';
    AnalyticFilter := frAcctAnalytics.Condition;
    if AnalyticFilter > '' then
      AnalyticFilter := ' AND '#13#10 + AnalyticFilter + #13#10;

    if frAcctSum.InCurr and (frAcctSum.CurrKey > 0) then
      CurrId := Format('  AND e.currkey = %d'#13#10, [frAcctSum.CurrKey])
    else
      CurrId := '';

    NcuDecDig := Format('NUMERIC(15, %d)', [frAcctSum.NcuDecDigits]);
    CurrDecDig := Format('NUMERIC(15, %d)', [frAcctSum.CurrDecDigits]);

    SelectClause := '';
    for I := 0 to frAcctAnalyticsGroup.Selected.Count - 1 do
    begin
      F := frAcctAnalyticsGroup.Selected[I].Field;

      if (F = nil) or (F.FieldName = ENTRYDATE) then Break;
      Alias := Format('c%d', [I]);
      Name := Format('NAME%d', [I]);
      SortName := Format('s%d', [I]);

      //GetDebitSumSelectClause;
      //GetCreditSumSelectClause;

      if IDSelect > '' then IDSelect := IDSelect + ', '#13#10;

      if F <> nil then
      begin
        if F.ReferencesField <> nil then
          IDSelect := IDSelect + Format('  SUBSTRING(%s.%s from 1 for 180) AS %s', [Alias,
            F.ReferencesField.FieldName, Alias])
        else
        begin
          IDSelect := IDSelect + Format('  SUBSTRING(e.%s from 1 for 180) AS %s', [F.FieldName, Alias]);
        end;
      end else
      begin
        IDSelect := IDSelect + Format(' SUBSTRING(g_d_getdateparam(e.entrydate, %s) from 1 for 180)AS %s',
          [frAcctAnalyticsGroup.Selected[I].Additional, Alias])
      end;

      if NameSelect > '' then  NameSelect := NameSelect + ', '#13#10;

      if F <> nil then
      begin
        if F.ReferencesField <> nil then
        begin
          if F.Field.RefListFieldName = '' then
            NameSelect := NameSelect + Format('  SUBSTRING(%s.%s from 1 for 180) AS %s', [Alias,
              F.References.ListField.FieldName, Name])
          else
            NameSelect := NameSelect + Format('  SUBSTRING(%s.%s from 1 for 180) AS %s', [Alias,
              F.Field.RefListFieldName, Name]);
        end else
        begin
          NameSelect := NameSelect + Format('  SUBSTRING(e.%s from 1 for 180) AS %s',
            [F.FieldName, Name]);
        end;
      end else
      begin
        NameSelect := NameSelect + Format(' SUBSTRING(g_d_getdateparam(e.entrydate, %s) from 1 for 180)AS %s',
          [frAcctAnalyticsGroup.Selected[I].Additional, Name])
      end;

      if SortSelect > '' then SortSelect := SortSelect + ', '#13#10;

      if F <> nil then
      begin
        if F.ReferencesField <> nil then
        begin
          if F.Field.RefListFieldName = '' then
            SortSelect := SortSelect + Format('  SUBSTRING(%s.%s from 1 for 180) AS %s', [Alias,
              F.References.ListField.FieldName, SortName])
          else
            SortSelect := SortSelect + Format('  SUBSTRING(%s.%s from 1 for 180) AS %s', [Alias,
              F.Field.RefListFieldName, SortName])
        end else
        begin
          SortSelect := SortSelect + Format('  SUBSTRING(e.%s from 1 for 180) AS %s',
            [F.FieldName, SortName]);
        end
      end else
      begin
        SortSelect := SortSelect + Format(' SUBSTRING(g_d_getdateparam(e.entrydate, %s) from 1 for 180)AS %s',
          [frAcctAnalyticsGroup.Selected[I].Additional, SortName])
      end;

      SelectClause :=  SortSelect + ', '#13#10 + IDSelect + ', '#13#10 + NameSelect;

      if (F <> nil) and  (F.ReferencesField <> nil) then
      begin
        FromClause := FromClause + Format('  LEFT JOIN %s %s ON %s.%s = e.%s'#13#10,
          [F.References.RelationName, Alias, Alias, F.ReferencesField.FieldName,
          F.FieldName]);
      end;

      if GroupClause > '' then  GroupClause := GroupClause + ', ';

      if F <> nil then
      begin
        if F.ReferencesField <> nil then
        begin
          if F.Field.RefListFieldName = '' then
            GroupClause := GroupClause + Format('%s.%s, %s.%s', [Alias,
              F.References.ListField.FieldName, Alias, F.ReferencesField.FieldName])
          else
            GroupClause := GroupClause + Format('%s.%s, %s.%s', [Alias,
              F.Field.RefListFieldName, Alias, F.ReferencesField.FieldName]);
        end else
        begin
          GroupClause := GroupClause + Format('e.%s', [F.FieldName])
        end;
      end else
      begin
        GroupClause := GroupClause + Format('g_d_getdateparam(e.entrydate, %s)',
          [frAcctAnalyticsGroup.Selected[I].Additional])
      end;
      //****
      if OrderClause > '' then  OrderClause := OrderClause + ', ';

      if F <> nil then
      begin
        if F.ReferencesField <> nil then
        begin
          if F.Field.RefListFieldName = '' then
            OrderClause := OrderClause + Format('%s.%s, %s.%s', [Alias,
              F.References.ListField.FieldName, Alias, F.ReferencesField.FieldName])
          else
            OrderClause := OrderClause + Format('%s.%s, %s.%s', [Alias,
              F.Field.RefListFieldName, Alias, F.ReferencesField.FieldName])
        end else
        begin
          OrderClause := OrderClause + Format('e.%s', [F.FieldName])
        end;
      end else
      begin
        OrderClause := OrderClause + Format('g_d_getdateparam(e.entrydate, %s)',
          [frAcctAnalyticsGroup.Selected[I].Additional])
      end;
      //****
      QuantityGroup := '';
      if FValueList.Count > 0 then
      begin
        for K := 0 to FValueList.Count - 1 do
        begin
          VKeyAlias := gdvObject.GetKeyAlias(FValueList.Names[K]);
          ValueAlias := 'v_' + gdvObject.GetKeyAlias(FValueList.Names[K]);
          QuantityAlias := 'q_' + gdvObject.GetKeyAlias(FValueList.Names[K]);

          if not FEntryDateIsFirst then
          begin
            SelectClause := SelectClause + ','#13#10 +
              Format('    SUM(IIF(e.accountpart = ''D'', %s.quantity, 0)) - '#13#10 +
                '    SUM(IIF(e.accountpart = ''C'', %s.quantity, 0)) AS Q_B_S_%s'#13#10,
                [QuantityAlias, QuantityAlias, VKeyAlias]);
            if I = 0 then
            begin
              FromClause := FromClause + #13#10 +
                Format('  LEFT JOIN ac_quantity %s ON %s.entrykey = e.id AND '#13#10 +
                  '     %s.valuekey = %s ', [QuantityAlias,  QuantityAlias,
                  QuantityAlias, FValueList.Names[K]]);
            end;
          end;
        end;
      end;
    end;

    if not FEntryDateIsFirst  then
    begin
      NcuBegin :=
        Format('  CAST(SUM(e.debitncu - e.creditncu) / %d AS %s) AS NCU_BEGIN_SALDO '#13#10,
        [frAcctSum.NcuScale, NcuDecDig]);
      if frAcctSum.InCurr then
      begin
        CurrBegin :=
          Format('  CAST(SUM(e.debitcurr - e.creditcurr) / %d AS %s) AS CURR_BEGIN_SALDO '#13#10,
          [frAcctSum.CurrScale, CurrDecDig]);
      end else
      begin
        CurrBegin :=
          Format('  CAST(0 AS %s) AS CURR_BEGIN_SALDO '#13#10, [CurrDecDig]);
      end;

      HavingClause := {GetHavingClause}'';
      if HavingClause > '' then HavingClause := HavingClause + ' OR '#13#10 ;
      HavingClause := HavingClause + '  SUM(e.debitncu - e.creditncu) <> 0 '#13#10 ;

      if frAcctSum.InCurr then
      begin
        HavingClause := HavingClause +
          '  OR SUM(e.debitcurr) <> 0 OR SUM(e.creditcurr) <> 0 ';
      end;

      HavingClause := 'HAVING ' + HavingClause;

      DebitCreditSQL := Format(cBeginSaldoSQLTemplate, [SelectClause, NcuBegin,
        CurrBegin, FromClause, Format('e.accountkey IN(%s) AND ', [IDList(FAccountIDs)]), frAcctCompany.CompanyList,
        CurrId, gdvObject.InternalMovementClause + AnalyticFilter, GroupClause, HavingClause]);
    end;

    DebitCreditSQL := DebitCreditSQL + #13#10'ORDER BY ' + OrderClause;

    Result := DebitCreditSQL;
  finally
    Strings.Free;
  end;
end;

procedure Tgdv_frmAcctLedger.FillBeginSaldoStructire;
var
  SQL: TIBSQL;
  Name: string;
  Index: Integer;
  I, J: Integer;
  F: TatRelationField;
  V: Tgdv_Value;
  VKeyAlias: string;
begin
  if FEntryDateInFields and not FEntryDateIsFirst then
  begin
    if FSaldoValueList = nil then
      FSaldoValueList := Tgdv_ValueList.Create
    else
      FSaldoValueList.Clear;

    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcBaseManager.ReadTransaction;
      SQL.SQL.Text := GetSaldoBeginSQL;
      SQL.ParamByName('begindate').AsDateTime := Self.DateBegin;
      SQL.ExecQuery;
      while not SQL.Eof do
      begin
        V := nil;
        for I := 0 to frAcctAnalyticsGroup.Selected.Count - 1 do
        begin
          F := frAcctAnalyticsGroup.Selected[I].Field;

          if (F = nil) or (F.FieldName = ENTRYDATE) then Break;
          Name := Format('c%d', [I]);

          if V = nil then
          begin
            Index := FSaldoValueList.IndexOf(SQL.FieldByName(Name).AsString);
            if Index = - 1 then
            begin
              Index := FSaldoValueList.Add2(SQL.FieldByName(Name).AsString);
            end;
            V := FSaldoValueList.Items[Index];
          end else
          begin
            Index := V.Values.IndexOf(SQL.FieldByName(Name).AsString);
            if Index = - 1 then
            begin
              Index := V.Values.Add2(SQL.FieldByName(Name).AsString);
            end;

            V := V.Values.Items[Index];
          end;
        end;

        if V <> nil then
        begin
          V.SaldoValues.AddSaldoValue('NCU_BEGIN_SALDO',
            SQL.FieldByName('NCU_BEGIN_SALDO').AsCurrency);
          V.SaldoValues.AddSaldoValue('CURR_BEGIN_SALDO',
            SQL.FieldByName('CURR_BEGIN_SALDO').AsCurrency);
          for J := 0 to FValueList.Count - 1 do
          begin
            VKeyAlias := gdvObject.GetKeyAlias(FValueList.Names[J]);
            Name := Format('Q_B_S_%s', [VKeyAlias]);
            V.SaldoValues.AddSaldoValue(Name, SQL.FieldByName(Name).AsCurrency);
          end;
        end;

        SQL.Next;
      end;
    finally
      SQL.Free;
    end;
  end;
end;

procedure Tgdv_frmAcctLedger.CalcBeginSaldo;
var
  I, J: Integer;
  V: Tgdv_Value;
  F: TatRelationField;
  Name, VKeyAlias: string;
  Index: Integer;
  C: Currency;
  Values, OldValues: TStringList;
  B: Boolean;
  SV: Tgdv_SaldoValues;

  procedure SetSaldo(SV: Tgdv_SaldoValues);
  var
    Index, J: Integer;
    C: Currency;
  begin
    Index := SV.IndexOf('NCU_BEGIN_SALDO');
    if Index > - 1 then
    begin
      C := SV[Index].SaldoValue;
      if C > 0 then
      begin
        gdvObject.FieldByName('NCU_BEGIN_DEBIT').AsCurrency := C;
        gdvObject.FieldByName('NCU_BEGIN_CREDIT').AsCurrency := 0;
      end else
      begin
        gdvObject.FieldByName('NCU_BEGIN_DEBIT').AsCurrency := 0;
        gdvObject.FieldByName('NCU_BEGIN_CREDIT').AsCurrency := - C;
      end;
    end;

    Index := SV.IndexOf('CURR_BEGIN_SALDO');
    if Index > - 1 then
    begin
      C := SV[Index].SaldoValue;
      if C > 0 then
      begin
        gdvObject.FieldByName('CURR_BEGIN_DEBIT').AsCurrency := C;
        gdvObject.FieldByName('CURR_BEGIN_CREDIT').AsCurrency := 0;
      end else
      begin
        gdvObject.FieldByName('CURR_BEGIN_DEBIT').AsCurrency := 0;
        gdvObject.FieldByName('CURR_BEGIN_CREDIT').AsCurrency := - C;
      end;
    end;

    for J := 0 to FValueList.Count - 1 do
    begin
      VKeyAlias := gdvObject.GetKeyAlias(FValueList.Names[J]);
      Name := Format('Q_B_S_%s', [VKeyAlias]);
      Index := SV.IndexOf(Name);

      if Index > - 1 then
      begin
        C := SV[Index].SaldoValue;
        if C > 0 then
        begin
          gdvObject.FieldByName(Format('Q_B_D_%s', [VKeyAlias])).AsCurrency := C;
          gdvObject.FieldByName(Format('Q_B_C_%s', [VKeyAlias])).AsCurrency := 0;
        end else
        begin
          gdvObject.FieldByName(Format('Q_B_D_%s', [VKeyAlias])).AsCurrency := 0;
          gdvObject.FieldByName(Format('Q_B_C_%s', [VKeyAlias])).AsCurrency := - C;
        end;
      end;
    end;
  end;

  function Changed: boolean;
  var
    J: Integer;
  begin
    Result := False;
    //Проверяем изменилось ли значение аналитик
    for J := 0 to FTotals.Count - 1 do
    begin
      F := FTotals[J].atRelationField;
      if (F = nil) or (F.FieldName = ENTRYDATE) then Break;

      Result := FTotals[J].Field.AsString <> Values[J];
    end;
  end;

  function Get_gdvValue: Tgdv_Value;
  var
    I, Index: Integer;
    Name: string;
  begin
    Result := nil;
    for I := 0 to FTotals.Count - 1 do
    begin
      F := FTotals[I].atRelationField;

      if (F = nil) or (F.FieldName = ENTRYDATE) then Break;
      Name := Format('c%d', [I]);

      if Result = nil then
      begin
        Index := FSaldoValueList.IndexOf(gdvObject.FieldByName(Name).AsString);
        if Index = - 1 then
        begin
          Result := nil;
          Break;
        end;
        Result := FSaldoValueList.Items[Index];
      end else
      begin
        Index := Result.Values.IndexOf(gdvObject.FieldByName(Name).AsString);
        if Index = - 1 then
        begin
          Result := nil;
          Break;
        end;

        Result := Result.Values.Items[Index];
      end;
    end;
  end;

begin
  gdvObject.DisableControls;
  try
    gdvObject.First;
    Values := TStringList.Create;
    OldValues := TStringList.Create;
    try
      for I := 0 to FTotals.Count - 1 do
      begin
        F := FTotals[I].atRelationField;
        if (F = nil) or (F.FieldName = ENTRYDATE) then Break;

        Values.Add('####2@##!@#@#$#$'{FTotals[I].Field.AsString});
      end;

      SV := Tgdv_SaldoValues.Create;
      try
        SV.AddSaldoValue('NCU_BEGIN_SALDO', 0);
        SV.AddSaldoValue('CURR_BEGIN_SALDO', 0);
        for J := 0 to FValueList.Count - 1 do
        begin
          VKeyAlias := gdvObject.GetKeyAlias(FValueList.Names[J]);
          Name := Format('Q_B_S_%s', [VKeyAlias]);
          SV.AddSaldoValue(Name, 0);
        end;

        while not gdvObject.Eof do
        begin
          gdvObject.Edit;
          //Проверяем изменилось ли значение аналитик
          B := Changed;

          if B then
          begin
            //Запоминаем новое значение аналитики
            for J := 0 to FTotals.Count - 1 do
            begin
              F := FTotals[J].atRelationField;

              if (F = nil) or (F.FieldName = ENTRYDATE) then Break;

              Values[J] := FTotals[J].Field.AsString;
            end;

            V := Get_gdvValue;

            if V <> nil then
            begin
              //Присваиваем значение начального сальдо
              SetSaldo(V.SaldoValues);
            end else
            begin
              gdvObject.FieldByName('NCU_BEGIN_DEBIT').AsCurrency := 0;
              gdvObject.FieldByName('NCU_BEGIN_CREDIT').AsCurrency := 0;
              gdvObject.FieldByName('CURR_BEGIN_DEBIT').AsCurrency := 0;
              gdvObject.FieldByName('CURR_BEGIN_CREDIT').AsCurrency := 0;
              for J := 0 to FValueList.Count - 1 do
              begin
                VKeyAlias := gdvObject.GetKeyAlias(FValueList.Names[J]);

                gdvObject.FieldByName(Format('Q_B_D_%s', [VKeyAlias])).AsCurrency := 0;
                gdvObject.FieldByName(Format('Q_B_C_%s', [VKeyAlias])).AsCurrency := 0;
              end;
            end;
          end else
          begin
            SetSaldo(SV);
          end;

          //Вычисляем конечное сальдо
          C := gdvObject.FieldByName('NCU_BEGIN_DEBIT').AsCurrency -
            gdvObject.FieldByName('NCU_BEGIN_CREDIT').AsCurrency +
            gdvObject.FieldByName('NCU_DEBIT').AsCurrency -
            gdvObject.FieldByName('NCU_CREDIT').AsCurrency;

          if C > 0 then
          begin
            gdvObject.FieldByName('NCU_END_DEBIT').AsCurrency := C;
            gdvObject.FieldByName('NCU_END_CREDIT').AsCurrency := 0;
          end else
          begin
            gdvObject.FieldByName('NCU_END_DEBIT').AsCurrency := 0;
            gdvObject.FieldByName('NCU_END_CREDIT').AsCurrency := - C;
          end;

          Index := SV.IndexOf('NCU_BEGIN_SALDO');
          SV[Index].SaldoValue := C;

          C := gdvObject.FieldByName('CURR_BEGIN_DEBIT').AsCurrency -
            gdvObject.FieldByName('CURR_BEGIN_CREDIT').AsCurrency +
            gdvObject.FieldByName('CURR_DEBIT').AsCurrency -
            gdvObject.FieldByName('CURR_CREDIT').AsCurrency;

          if C > 0 then
          begin
            gdvObject.FieldByName('CURR_END_DEBIT').AsCurrency := C;
            gdvObject.FieldByName('CURR_END_CREDIT').AsCurrency := 0;
          end else
          begin
            gdvObject.FieldByName('CURR_END_DEBIT').AsCurrency := 0;
            gdvObject.FieldByName('CURR_END_CREDIT').AsCurrency := - C;
          end;

          Index := SV.IndexOf('CURR_BEGIN_SALDO');
          SV[Index].SaldoValue := C;

          for J := 0 to FValueList.Count - 1 do
          begin
            VKeyAlias := gdvObject.GetKeyAlias(FValueList.Names[J]);

            C := gdvObject.FieldByName(Format('Q_B_D_%s', [VKeyAlias])).AsCurrency -
              gdvObject.FieldByName(Format('Q_B_C_%s', [VKeyAlias])).AsCurrency +
              gdvObject.FieldByName(Format('Q_D_%s', [VKeyAlias])).AsCurrency -
              gdvObject.FieldByName(Format('Q_C_%s', [VKeyAlias])).AsCurrency;

            if C > 0 then
            begin
              gdvObject.FieldByName(Format('Q_E_D_%s', [VKeyAlias])).AsCurrency := C;
              gdvObject.FieldByName(Format('Q_E_C_%s', [VKeyAlias])).AsCurrency := 0;
            end else
            begin
              gdvObject.FieldByName(Format('Q_E_D_%s', [VKeyAlias])).AsCurrency := 0;
              gdvObject.FieldByName(Format('Q_E_C_%s', [VKeyAlias])).AsCurrency := - C;
            end;
            Index := SV.IndexOf(Format('Q_B_S_%s', [VKeyAlias]));
            SV[Index].SaldoValue := C;
          end;
          gdvObject.Post;
          gdvObject.Next;
        end;
      finally
        SV.Free;
      end;
    finally
      Values.Free;
      OldValues.Free;
    end;
  finally
    gdvObject.EnableControls;
  end;
end;

procedure Tgdv_frmAcctLedger.OnAnalyticGroupSelect(Sender: TObject);
begin
  frAcctTreeAnalytic.UpdateAnalyticsList(frAcctAnalyticsGroup.Selected);
end;

function Tgdv_frmAcctLedger.CanGo_to: boolean;
const
  cTotal = 'Итого:';
var
  i: integer;
begin
  if gdvObject.Active then
  begin
    Result:= True;
    for i := 0 to ibgrMain.Columns.Count - 1 do
      if Assigned(gdvObject.FindField(ibgrMain.Columns[i].FieldName))
         and (gdvObject.FieldByName(ibgrMain.Columns[i].FieldName).AsString = cTotal) then
      begin
        Result:= False;
        Exit;
      end;
  end
  else
    Result := False;    
end;

function Tgdv_frmAcctLedger.CompareParams(WithDate: Boolean = True): Boolean;
var
  Stream: TMemoryStream;
begin
  Result := inherited CompareParams(WithDate)
    and ((FConfig as TAccLedgerConfig).ShowDebit = cbShowDebit.Checked)
    and ((FConfig as TAccLedgerConfig).ShowCredit = cbShowCredit.Checked)
    and ((FConfig as TAccLedgerConfig).ShowCorrSubAccounts = cbShowCorrSubAccount.Checked)
    and ((FConfig as TAccLedgerConfig).AnalyticListField = frAcctAnalyticsGroup.AnalyticListFields)
    and ((FConfig as TAccLedgerConfig).SumNull = cbSumNull.Checked)
    and ((FConfig as TAccLedgerConfig).EnchancedSaldo = cbEnchancedSaldo.Checked)
    and ((FConfig as TAccLedgerConfig).TreeAnalytic = frAcctTreeAnalytic.TreeAnalitic);

  if Result then
  begin
    Stream := TMemoryStream.Create;
    try
      Stream.Size := 0;
      frAcctAnalyticsGroup.SaveToStream(Stream);
      Result := ((FConfig as TAccLedgerConfig).AnalyticsGroup.Size = Stream.Size)
        and (CompareMem(((FConfig as TAccLedgerConfig).AnalyticsGroup as TMemoryStream).Memory, Stream.Memory, Stream.Size));
    finally
      FreeAndNil(Stream);
    end;
  end;
end;

procedure Tgdv_frmAcctLedger.actSaveConfigUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := frAcctAnalyticsGroup.Selected.Count > 0;
end;

procedure Tgdv_frmAcctLedger.FormDestroy(Sender: TObject);
begin
  inherited;
  FTotals.Free;
  FSaldoValueList.Free;
end;

procedure Tgdv_frmAcctLedger.actRunUpdate(Sender: TObject);
begin
  inherited;
  UpdateEntryDateIsFirst;

  cbEnchancedSaldo.Enabled := not FEntryDateIsFirst;
end;

procedure Tgdv_frmAcctLedger.UpdateEntryDateIsFirst;
var
  I: Integer;
begin
  FEntryDateIsFirst := False;
  FEntryDateInFields := False;
  for I := 0 to frAcctAnalyticsGroup.Selected.Count - 1 do
  begin
    FEntryDateInFields := (frAcctAnalyticsGroup.Selected[I].FieldName = ENTRYDATE) or
      (not Assigned(frAcctAnalyticsGroup.Selected[I].Field));
    if FEntryDateInFields then
    begin
      FEntryDateIsFirst := I = 0;
      Break;
    end;
  end;
end;

procedure Tgdv_frmAcctLedger.SetParams;
var
  I: Integer;
begin
  inherited;

  if not gdvObject.MakeEmpty then
  begin
    for I := 0 to frAcctAnalyticsGroup.Selected.Count - 1 do
      TgdvAcctLedger(gdvObject).AddGroupBy(frAcctAnalyticsGroup.Selected[I]);

    for I := 0 to frAcctTreeAnalytic.Count - 1 do
      TgdvAcctLedger(gdvObject).AddAnalyticLevel(frAcctTreeAnalytic.Lines[I].Field.FieldName, frAcctTreeAnalytic.Lines[I].Levels.Text);

    TgdvAcctLedger(gdvObject).ShowDebit := cbShowDebit.Checked;
    TgdvAcctLedger(gdvObject).ShowCredit := cbShowCredit.Checked;
    TgdvAcctLedger(gdvObject).ShowCorrSubAccounts := cbShowCorrSubAccount.Checked;
    TgdvAcctLedger(gdvObject).EnchancedSaldo := cbEnchancedSaldo.Checked;
    TgdvAcctLedger(gdvObject).SumNull := cbSumNull.Checked;
  end;  
end;

function Tgdv_frmAcctLedger.GetGdvObject: TgdvAcctBase;
begin
  Result := ibdsMain;
end;

{ Tgdv_ValueList }

function Tgdv_ValueList.Add(Value: string): Tgdv_Value;
begin
  Result := Tgdv_Value.Create;
  Result.Value := Value;
  if FValues = nil then
    FValues := TStringList.Create;

  FValues.AddObject(Value, Result);
end;

function Tgdv_ValueList.Add2(Value: string): Integer;
var
  V: Tgdv_Value;
begin
  V := Tgdv_Value.Create;
  V.Value := Value;
  if FValues = nil then
    FValues := TStringList.Create;

  Result := FValues.AddObject(Value, V);
end;

procedure Tgdv_ValueList.Clear;
var
  I: Integer;
begin
  if FValues <> nil then
  begin
    for I := 0 to FValues.Count - 1 do
    begin
      Tgdv_Value(FValues.Objects[I]).Free;
      FValues.Objects[I] := nil;
    end;
    FValues.Clear;
  end;
end;

destructor Tgdv_ValueList.Destroy;
begin
  Clear;
  
  inherited;
end;

function Tgdv_ValueList.GetItems(Index: Integer): Tgdv_Value;
begin
  if FValues = nil then
    FValues := TStringList.Create;

  Result := Tgdv_Value(FValues.Objects[Index]);
end;

function Tgdv_ValueList.IndexOf(Value: string): Integer;
begin
  Result := -1 ;
  if FValues <> nil then
  begin
    FValues.Sorted := True;
    Result := FValues.IndexOf(Value);
  end;
end;

{ Tgdv_Value }

destructor Tgdv_Value.Destroy;
begin
  FValues.Free;
  FSaldoValues.Free;
  
  inherited;
end;

function Tgdv_Value.GetSaldoValues: Tgdv_SaldoValues;
begin
  if FSaldoValues = nil then
    FSaldoValues := Tgdv_SaldoValues.Create;
  Result := FSaldoValues;
end;

function Tgdv_Value.GetValues: Tgdv_ValueList;
begin
  if FValues = nil then
    FValues := Tgdv_ValueList.Create;
  Result := FValues;
end;

procedure Tgdv_Value.SetValue(const Value: string);
begin
  FValue := Value;
end;

{ Tgdv_FieldValue }

procedure Tgdv_SaldoValue.SetSaldoName(const Value: string);
begin
  FSaldoName := Value;
end;

procedure Tgdv_SaldoValue.SetSaldoValue(const Value: Currency);
begin
  FSaldoValue := Value;
end;

{ Tgdv_FieldValues }

function Tgdv_SaldoValues.AddSaldoValue(SaldoName: string;
  SaldoValue: Currency): integer;
var
  V: Tgdv_SaldoValue;
begin
  V := Tgdv_SaldoValue.Create;
  V.SaldoName := SaldoName;
  V.SaldoValue := SaldoValue;
  Result := Add(V);
end;

constructor Tgdv_SaldoValues.Create;
begin
  OwnsObjects := True;
end;

function Tgdv_SaldoValues.GetSaldoList(Index: Integer): Tgdv_SaldoValue;
begin
  Result := Tgdv_SaldoValue(inherited Items[Index])
end;

function Tgdv_SaldoValues.IndexOf(FieldName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    if SaldoList[I].SaldoName = FieldName then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

procedure Tgdv_frmAcctLedger.ibdsMainAfterOpen(DataSet: TDataSet);
var
  Values, OldValues: TStringList;
  I, J, K: Integer;
  Insert: Boolean;
  //Индекс изменившейся аналитики
  Count: Integer;
const
  cTotal = 'Итого:'; //  если меняется здесь, то надо поменять в CanGo_to
begin
  inherited;
  if not FMakeEmpty then
  begin

    gdvObject.DisableControls;
    try
      for I := 0 to gdvObject.Fields.Count - 1 do
        gdvObject.Fields[I].Required := False;

      Values := TStringList.Create;
      OldValues := TStringList.Create;
      try
        //инициализируем поля
        FTotals.InitField(gdvObject);
        //Инициализируем список значений
        for I := 0 to FTotals.Count - 1 do
        begin
          Values.Add(FTotals[I].Field.AsString);
        end;

        if (not gdvObject.UseEntryBalance) and FEntryDateInFields and not FEntryDateIsFirst then
        begin
          FillBeginSaldoStructire;
          CalcBeginSaldo;
        end;

        Count := 0;
        gdvObject.First;
        while not gdvObject.Eof do
        begin
          //Проверяем изменилось ли значение аналитик
          for I := 0 to FTotals.Count - 1 do
          begin
            Insert := FTotals[i].Field.AsString <> Values[I];
            if Insert then
            begin
              //Сохраняем старые значения
              OldValues.Assign(Values);

              //Запоминаем новое значение аналитики
              for J := 0 to FTotals.Count - 1 do
              begin
                Values[J] := FTotals[J].Field.AsString;
              end;

              for J := FTotals.Count - 2 downto I do
              begin
                if (cbSumNull.Checked or (OldValues[J] > '')) and FTotals[J].Total then
                begin
                  gdvObject.Insert;
                  FTotals[J].ValueField.AsString := cTotal;
                  FTotals[J].SetValues;

                  for K := 0 to I do
                  begin
                    FTotals[K].Field.AsString := OldValues[K];
                  end;
                  gdvObject.FieldByName('sortfield').AsInteger := J + 2;
                  gdvObject.Post;
                  gdvObject.Next;
                end;
                FTotals[J].DropValues;
              end;

              Break;
            end;
          end;


          FTotals.Calc;

          gdvObject.Next;
          Inc(Count);
        end;
        if Count > 1 then
        begin
          for J := FTotals.Count - 2 downto 0 do
          begin
            if (cbSumNull.Checked or (OldValues[J] > '')) and FTotals[J].Total then
            begin
              gdvObject.Append;
              FTotals[J].ValueField.AsString := cTotal;
              FTotals[J].SetValues;

              gdvObject.Post;
              gdvObject.Next;
            end;
            FTotals[J].DropValues;
          end;
        end;
      finally
        Values.Free;
        OldValues.Free;
      end;
    finally
      gdvObject.First;
      gdvObject.EnableControls;
    end;
  end;
end;

procedure Tgdv_frmAcctLedger.ibdsMainCalcAggregates(DataSet: TDataSet;
  var Accept: Boolean);
var
  F: TField;
begin
  inherited;
  if FSortFieldIndex = - 1 then
  begin
    F := gdvObject.FindField('sortfield');
    if F <> nil then
      FSortFieldIndex := F.Index;
  end;

  Accept := (FSortFieldIndex > -1) and (gdvObject.Fields[FSortFieldIndex].AsInteger = 1);
end;

procedure Tgdv_frmAcctLedger.actSaveGridSettingUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (iblConfiguratior.CurrentKey > '') and (not cbShowDebit.Checked) and (not cbShowCredit.Checked);
  FSaveGridSetting := (iblConfiguratior.CurrentKey > '') and (not cbShowDebit.Checked) and (not cbShowCredit.Checked);
end;

procedure Tgdv_frmAcctLedger.actClearGridSettingUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := iblConfiguratior.CurrentKey > '';
end;

initialization
  RegisterFrmClass(Tgdv_frmAcctLedger);
finalization
  UnRegisterFrmClass(Tgdv_frmAcctLedger);
end.
