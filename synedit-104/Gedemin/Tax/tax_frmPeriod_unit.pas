{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    tax_frmAnalytics_unit.pas

  Abstract

    Form for job period and financial reports of calculation.

  Author

    Dubrovnik Alexander (DAlex)

  Revisions history

    1.00    07.02.03    DAlex      Initial version.

--}

unit tax_frmPeriod_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ExtCtrls, gsIBLookupComboBox, Db, Grids, DBGrids,
  gsDBGrid, gsIBGrid, IBCustomDataSet, gdcBase, gd_Createable_Form,
  Spin, Mask, xDateEdits, gdcTaxFunction, ActnList, Menus;

type
  TPeriodType = (txMonth, txQuarter, txArbitrary);

type
  TfrmPeriod = class(TCreateableForm)
    pnlMain: TPanel;
    dsTaxName: TDataSource;
    gdcTaxName: TgdcTaxName;
    pnlButton: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    pcSelDate: TPageControl;
    tsMonth: TTabSheet;
    tsQuarter: TTabSheet;
    tsArbitrary: TTabSheet;
    pmPeriod: TPopupMenu;
    alPeriod: TActionList;
    actSelectAll: TAction;
    actDiscardSelect: TAction;
    N1: TMenuItem;
    N2: TMenuItem;
    Panel1: TPanel;
    GridMonth: TgsIBGrid;
    Panel2: TPanel;
    GridQuarter: TgsIBGrid;
    Panel3: TPanel;
    GridPeriod: TgsIBGrid;
    Button1: TButton;
    actHelp: TAction;
    Panel4: TPanel;
    lblM1: TLabel;
    cbMonth: TComboBox;
    lblY1: TLabel;
    spMYear: TSpinEdit;
    Panel5: TPanel;
    lblQuart: TLabel;
    cbQuarter: TComboBox;
    lnlY2: TLabel;
    spQYear: TSpinEdit;
    Panel6: TPanel;
    xdeEPeriod: TxDateEdit;
    lblEndPeriod: TLabel;
    xdeBPeriod: TxDateEdit;
    lblBeginPeriod: TLabel;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure actSelectAllExecute(Sender: TObject);
    procedure actDiscardSelectExecute(Sender: TObject);
    procedure pcSelDateChange(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure gdcTaxNameGetOrderClause(Sender: TObject;
      var Clause: String);
  private
    function GetBPeriod: TDate;
    function GetEPeriod: TDate;
    function GetPeriodType: TPeriodType;

  public
    constructor Create(AOwner: TComponent); override;
    function ibgrTax: TgsIBGrid;

    property BPeriod: TDate read GetBPeriod;
    property EPeriod: TDate read GetEPeriod;
    property PeriodType: TPeriodType read GetPeriodType;
    procedure SaveSettings; override;

  end;

var
  frmPeriod: TfrmPeriod;

implementation

uses
  Storages, gdc_frmTaxDesignTime_unit, gd_directories_const, gsStorage_CompPath
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R *.DFM}

procedure TfrmPeriod.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if (ModalResult = mrOk) then
  begin
    if ibgrTax.CheckBox.CheckCount = 0 then
    begin
      MessageBox(Self.Handle,
        PChar('Необходимо выбрать налоги для расчета.'),
        PChar('Ошибка'),
        MB_OK or MB_ICONERROR or MB_TASKMODAL or MB_TOPMOST);
      ModalResult := mrNone;
    end;
    try
      GetBPeriod;
      GetEPeriod;
      SaveSettings;
    except
      ModalResult := mrNone;
      raise;
    end;
  end;
end;

procedure TfrmPeriod.FormDestroy(Sender: TObject);
begin
  UserStorage.SaveComponent(GridMonth, GridMonth.SaveToStream);
  UserStorage.SaveComponent(GridQuarter, GridQuarter.SaveToStream);
  UserStorage.SaveComponent(GridPeriod, GridPeriod.SaveToStream);
end;

function TfrmPeriod.GetBPeriod: TDate;
begin
  Result := 0;
  case GetPeriodType of
    txMonth:
      Result := IncMonth(GetEPeriod + 1, - 1);
    txQuarter:
    begin
      case cbQuarter.ItemIndex of
        0: Result := EncodeDate(spQYear.Value, 1, 1);
        1: Result := EncodeDate(spQYear.Value, 4, 1);
        2: Result := EncodeDate(spQYear.Value, 7, 1);
        3: Result := EncodeDate(spQYear.Value, 10, 1);
      end;
    end;
    txArbitrary:
      Result := xdeBPeriod.Date;
  end;
  if Result = 0 then
    raise Exception.Create('Не задан период.');
end;

function TfrmPeriod.GetEPeriod: TDate;
begin
  Result := 0;
  case GetPeriodType of
    txMonth:
      Result :=
        IncMonth(EncodeDate(spMYear.Value, cbMonth.ItemIndex + 1, 1), 1) - 1;
    txQuarter:
    begin
      case cbQuarter.ItemIndex of
        0: Result := EncodeDate(spQYear.Value, 4, 1) - 1;
        1: Result := EncodeDate(spQYear.Value, 7, 1) - 1;
        2: Result := EncodeDate(spQYear.Value, 10, 1) - 1;
        3: Result := EncodeDate(spQYear.Value + 1, 1, 1) - 1;
      end;
    end;
    txArbitrary:
      Result := xdeEPeriod.Date;
  end;
  if Result = 0 then
    raise Exception.Create('Не задан период.');
end;

function TfrmPeriod.GetPeriodType: TPeriodType;
begin
  if pcSelDate.ActivePage = tsMonth then
    Result := txMonth
  else
  if pcSelDate.ActivePage = tsQuarter then
    Result := txQuarter
  else
  if pcSelDate.ActivePage = tsArbitrary then
    Result := txArbitrary
  else
    raise Exception.Create('Неизвестный тип периода.');
end;

constructor TfrmPeriod.Create(AOwner: TComponent);
var
  day, month, year: Word;
  MonthIndex, QuarterIndex: Integer;
  i: Integer;
  d: TDate;
begin
  inherited;

  gdcTaxName.Open;
  UserStorage.LoadComponent(GridMonth, GridMonth.LoadFromStream);
  UserStorage.LoadComponent(GridPeriod, GridPeriod.LoadFromStream);
  UserStorage.LoadComponent(GridQuarter, GridQuarter.LoadFromStream);

  DecodeDate(Now, Year, Month, Day);

  for I := 1 to 12 do
  begin
    d := EncodeDate(Year, I, 1);
    cbMonth.Items.Add(FormatDateTime('mmmm', d));
  end;
  if Month > 1 then
    d := EncodeDate(year, month - 1, 1)
  else
    d := EncodeDate(year - 1, 12, 1);
  DecodeDate(d, Year, Month, Day);
  if Month > 1 then
    MonthIndex := month - 1
  else
    MonthIndex := 11;
  cbMonth.ItemIndex := UserStorage.ReadInteger(BuildComponentPath(Self), 'MonthIndex', MonthIndex);

  QuarterIndex := 0;
  spMYear.Value := UserStorage.ReadInteger(BuildComponentPath(Self), 'MYear', year);
  spQYear.Value := UserStorage.ReadInteger(BuildComponentPath(Self), 'QYear', year);
  case month of
    1..3:   QuarterIndex := 0;
    4..6:   QuarterIndex := 1;
    7..9:   QuarterIndex := 2;
    10..12: QuarterIndex := 3;
  end;
  cbQuarter.ItemIndex := UserStorage.ReadInteger(BuildComponentPath(Self), 'QuarterIndex', QuarterIndex);


  xdeBPeriod.Date := UserStorage.ReadDateTime(BuildComponentPath(Self), 'BeginDate', d);
  DecodeDate(Now, Year, Month, Day);
  d := EncodeDate(year, month, 1) - 1;
  xdeEPeriod.Date := UserStorage.ReadDateTime(BuildComponentPath(Self), 'EndDate', d);
  pcSelDateChange(pcSelDate);
end;

procedure TfrmPeriod.actSelectAllExecute(Sender: TObject);
var
  BM: Pointer;
begin
  BM := gdcTaxName.GetBookmark;
  gdcTaxName.DisableControls;
  gdcTaxName.First;
  while not gdcTaxName.Eof do
  begin
    ibgrTax.CheckBox.AddCheck(gdcTaxName.FieldByName('id').AsInteger);
    gdcTaxName.Next;
  end;
  gdcTaxName.GotoBookmark(BM);
  gdcTaxName.EnableControls;
end;

procedure TfrmPeriod.actDiscardSelectExecute(Sender: TObject);
begin
  ibgrTax.CheckBox.CheckList.Clear;
end;

procedure TfrmPeriod.pcSelDateChange(Sender: TObject);
const
  extCond =
    ' z.id in (SELECT ta.taxnamekey FROM gd_taxactual ta WHERE ta.typekey = %s)';

begin
  case pcSelDate.ActivePageIndex of
    0: gdcTaxName.ExtraConditions.Text := Format(extCond, [IntToStr(cst_txMonthID)]);
    1: gdcTaxName.ExtraConditions.Text := Format(extCond, [IntToStr(cst_txQuarterID)]);
    2: gdcTaxName.ExtraConditions.Text := Format(extCond, [IntToStr(cst_txArbitraryID)]);
  end;
end;

function TfrmPeriod.ibgrTax: TgsIBGrid;
begin
  Result := nil;
  case pcSelDate.ActivePageIndex of
    0: Result := GridMonth;
    1: Result := GridQuarter;
    2: Result := GridPeriod;
  end;
end;

procedure TfrmPeriod.actHelpExecute(Sender: TObject);
begin
  Application.HelpContext(HelpContext)
end;

procedure TfrmPeriod.gdcTaxNameGetOrderClause(Sender: TObject;
  var Clause: String);
begin
  Clause := ' ORDER BY z.Name ';
end;

procedure TfrmPeriod.SaveSettings;
begin
  inherited;
  UserStorage.WriteInteger(BuildComponentPath(Self), 'MonthIndex', cbMonth.ItemIndex);
  UserStorage.WriteInteger(BuildComponentPath(Self), 'QuarterIndex', cbQuarter.ItemIndex);
  UserStorage.WriteDateTime(BuildComponentPath(Self), 'BeginDate', xdeBPeriod.Date);
  UserStorage.WriteDateTime(BuildComponentPath(Self), 'EndDate', xdeEPeriod.Date);

  UserStorage.WriteInteger(BuildComponentPath(Self), 'MYear', spMYear.Value);
  UserStorage.WriteInteger(BuildComponentPath(Self), 'QYear', spQYear.Value);

end;

end.
