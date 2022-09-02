// ShlTanya, 12.03.2019

{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gdc_frmTaxDesignTime_unit.pas

  Abstract

    Dialog form of TgdcTaxDesignDate business class.
    Calculation of fiscal functions.

  Author

    Dubrovnik Alexander (DAlex)

  Revisions history

    1.00    07.02.03    DAlex      Initial version.

--}

unit gdc_frmTaxDesignTime_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDHGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcTaxFunction, rp_BaseReport_unit,
  contnrs, gdcFunction, Gedemin_TLB, gsIBLookupComboBox, dmDataBase_unit,
  MSScriptControl_TLB, gdcTree, gdcClasses, DBCtrls, IBQuery;

//const
  // тип бух. отчета, соответсвует данным таблицы gd_taxtype
  //txReportType:
  //array[0..2] of integer = (cst_txMonthID, cst_txQuarterID, cst_txArbitraryID);


type
  ErrorRec = record
    ErrorMsg: String;
    Pos: Integer;
    Name: String
  end;

type
  Tgdc_frmTaxDesignTime = class(Tgdc_frmMDHGR)
    gdcTaxResult: TgdcTaxResult;
    gdcTaxDesignDate: TgdcTaxDesignDate;
    actCalculate: TAction;
    gdcTaxActual: TgdcTaxActual;
    actActualPrint: TAction;
    Label1: TLabel;
    TBSeparatorItem2: TTBSeparatorItem;
    TBItem1: TTBItem;
    procedure FormCreate(Sender: TObject);
    procedure actCalculateExecute(Sender: TObject);
  private
    FActDate: TDate;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
  end;

var
  gdc_frmTaxDesignTime: Tgdc_frmTaxDesignTime;

implementation

uses
  gd_ClassList, tax_frmPeriod_unit, IBSQL, IBDatabase, gdcDelphiObject,
  gd_i_ScriptFactory, gdcConstants, obj_i_Debugger, gdcBaseInterface,
  gd_security, gdcCustomFunction, gd_directories_const
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

const
  dtScriptError = 'Отчет бухгалтерии: %s'#13#10 +
                  'Дата ввода:          %s'#13#10 +
                  'Функция:                %s'#13#10#13#10 +
                  'Сообщение об ошибке:'#13#10'%s';

{$R *.DFM}

procedure Tgdc_frmTaxDesignTime.FormCreate(Sender: TObject);
begin
  gdcObject := gdcTaxDesignDate;
  gdcDetailObject := gdcTaxResult;
  inherited;
  gdcTaxActual.Open;
  gdcTaxActual.QueryFiltered := False;
end;

procedure Tgdc_frmTaxDesignTime.actCalculateExecute(Sender: TObject);
var
//  EDate: TDate;
  IBSQL: TIBSQL;
  TaxNameKey: TID;
  ResultExist: Boolean;
  TaxIndex: Integer;
  TypeKey, TaxActualKey: TID;
  Params, Results: Variant;
begin
  if ScriptFactory = nil then
    Exit;

  ResultExist := False;

  with TfrmPeriod.Create(Self) do
  try
    ShowModal;
    if not (ModalResult = mrOk) then
      Exit;

    Close;

    case PeriodType of
      txMonth:
        TypeKey := cst_txMonthID;
      txQuarter:
        TypeKey := cst_txQuarterID;
      txArbitrary:
        TypeKey := cst_txArbitraryID;
      else
        TypeKey := -1;
    end;

    IBSQL := TIBSQL.Create(nil);
    try
      IBSQL.Transaction := gdcObject.ReadTransaction;
      gdcTaxName.First;
      for TaxIndex := 0 to ibgrTax.CheckBox.CheckList.Count - 1 do
      begin
        TaxNameKey := GetTID(ibgrTax.CheckBox.CheckList[TaxIndex]);

        IBSQL.Close;
        IBSQL.SQL.Text :=
          'SELECT FIRST(1) ta.* FROM gd_taxactual ta ' +
          'WHERE ' +
          '  ta.actualdate < :eperiod AND ' +
          '  ta.taxnamekey = :taxnameid ' +
          'ORDER BY ' +
          '  ta.actualdate  DESC';
        IBSQL.ParamByName('eperiod').AsDate := EPeriod;
        SetTID(IBSQL.ParamByName('taxnameid'), TaxNameKey);

        IBSQL.ExecQuery;
        if IBSQL.Eof or (GetTID(IBSQL.FieldByName('typekey')) <> TypeKey) then
          Continue;

        FActDate := IBSQL.FieldByName('actualdate').AsDateTime;
        TaxActualKey := GetTID(IBSQL.FieldByName('id'));
        IBSQL.Close;
        IBSQL.SQL.Text :=
          'SELECT tr.functionkey ' +
          'FROM gd_taxactual ta LEFT JOIN ac_trrecord tr ON tr.id = ta.trrecordkey ' +
          'WHERE ta.id = :taxactualkey ';
        SetTID(IBSQL.ParamByName('taxactualkey'), TaxActualKey);
        IBSQL.ExecQuery;
        if IBSQL.RecordCount > 0 then
        begin
          if (Double(FActDate) > Double(BPeriod)) and (FActDate < EPeriod) then
            Params := VarArrayOf([VarAsType(FActDate, varDate), VarAsType(EPeriod, varDate)])
          else
            Params := VarArrayOf([VarAsType(BPeriod, varDate), VarAsType(EPeriod, varDate)]);
          Results := VarArrayOf([]);
          try
            ScriptFactory.ExecuteFunction(GetTID(IBSQL.FieldByName('functionkey')), Params, Results);
            ResultExist := True;
          except
            ResultExist := False;
            Exit;
          end;
        end;
      end;
    finally
      IBSQL.Free;
    end;
  finally
    Free;
  end;

  if ResultExist then
  begin
    if MessageBox(Self.Handle,
      PChar('Функции успешно рассчитаны. Обновить данные?'),
      PChar('Результат расчета'),
      MB_YESNO or MB_ICONINFORMATION or MB_TASKMODAL or MB_TOPMOST) = IDYES then
    begin
      gdcObject.CloseOpen;
      gdcDetailObject.CloseOpen;
    end;
  end else
    MessageBox(Self.Handle,
      PChar('Функции на указанный период не найдены.'),
      PChar('Результат расчета'),
      MB_OK or MB_ICONINFORMATION or MB_TASKMODAL or MB_TOPMOST)
end;

destructor Tgdc_frmTaxDesignTime.Destroy;
begin
  inherited;
  gdc_frmTaxDesignTime := nil;
end;

constructor Tgdc_frmTaxDesignTime.Create(AOwner: TComponent);
begin
  inherited;

  if gdc_frmTaxDesignTime <> nil then
    raise Exception.Create('Форму отчетов бухгалтерии можно открыть только одну.');

  gdc_frmTaxDesignTime := Self;
end;

initialization
  RegisterFrmClass(Tgdc_frmTaxDesignTime);

finalization
  UnRegisterFrmClass(Tgdc_frmTaxDesignTime);

end.
