unit dlgImportOperation;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, DBGrids, mmDBGrid, mmDBGridCheck, ExtCtrls, ToolWin, ComCtrls,
  xSmartToolBar, StdCtrls, Buttons, mBitButton, Db, DBTables, xDBLookU,
  Menus, xLabel, MakeReg, FrmPlSvr;

type
  TfrmImportOperation = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    mdbcgrRegister: TmmDBGridCheck;
    Label1: TLabel;
    dtpDateBegin: TDateTimePicker;
    Label2: TLabel;
    dtpDateEnd: TDateTimePicker;
    qryRegister: TQuery;
    dsRegister: TDataSource;
    qryRegisterDate: TDateField;
    qryRegisterNomPP: TStringField;
    qryRegisterDebet: TStringField;
    qryRegisterKredit: TStringField;
    qryRegisterSumma: TCurrencyField;
    qryRegisterKAUdebet: TStringField;
    qryRegisterKAUkredit: TStringField;
    qryRegisterNameoperation: TStringField;
    qryRegisterNumberpayment: TStringField;
    qryRegisterSummaincurrency: TCurrencyField;
    qryRegisterCurrency: TStringField;
    qryRegisterDateMake: TDateField;
    qryRegisterCodeSubSystem: TSmallintField;
    qryRegisterCodeDocument: TStringField;
    qryRegisterChangeCurCost: TCurrencyField;
    qryEntry: TQuery;
    qryEntryDEBIT: TStringField;
    qryEntryCREDIT: TStringField;
    qryEntryDEBITKEY: TIntegerField;
    qryEntryCREDITKEY: TIntegerField;
    qryEntryEntryName: TStringField;
    dsEntry: TDataSource;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    qryEntryOPTYPE: TIntegerField;
    xLabel1: TxLabel;
    Panel3: TPanel;
    mBitButton1: TmBitButton;
    mBitButton2: TmBitButton;
    dbgEntry: TmmDBGrid;
    Splitter1: TSplitter;
    qryEntryID: TIntegerField;
    mBitButton3: TmBitButton;
    qryRegisterAnalyzeDebet: TStringField;
    qryRegisterAnalyzeKredit: TStringField;
    xMakeRegister: TxMakeRegister;
    qryRegisterKey: TStringField;
    FormPlaceSaver1: TFormPlaceSaver;
    procedure SpeedButton1Click(Sender: TObject);
    procedure qryEntryCalcFields(DataSet: TDataSet);
    procedure qryRegisterNameoperationGetText(Sender: TField;
      var Text: String; DisplayText: Boolean);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure qryRegisterCalcFields(DataSet: TDataSet);
    procedure FormDestroy(Sender: TObject);
    procedure mBitButton2Click(Sender: TObject);
  private
    FOpType: Integer;
  public
//    TestCalc: Boolean;
    procedure ShowEntryList;
    constructor Create(aOwner: TComponent; aOpType: Integer);
      reintroduce;
  end;

var
  frmImportOperation: TfrmImportOperation;

implementation

uses
  mmOptions;

{$R *.DFM}

procedure TfrmImportOperation.ShowEntryList;
var
  First: Boolean;
begin
  qryRegister.Close;
  qryRegister.SQL.Text :=
   ' SELECT * FROM register WHERE ' +
   ' (register."Date" >= :DateBegin) and ' +
   ' (register."Date" <= :DateEnd) ';

  First := True;
  qryEntry.First;
  while not qryEntry.Eof do
  begin
    if dbgEntry.ShowChecksByName['entryname'].IndexOf(qryEntry.FieldByName('id').AsString) <> -1 then
    begin
      if First then
      begin
        qryRegister.SQL.ADD('and ((register."debet" = "' +
          qryEntry.FieldByName('Debit').AsString + '"');
        qryRegister.SQL.ADD('and register."kredit" = "' +
          qryEntry.FieldByName('Credit').AsString + '")');
        First := False;
      end
      else
      begin
        qryRegister.SQL.ADD('or (register."debet" = "' +
          qryEntry.FieldByName('Debit').AsString + '"');
        qryRegister.SQL.ADD('and register."kredit" = "' +
          qryEntry.FieldByName('Credit').AsString + '")');
      end;

    end;
    qryEntry.Next;
  end;
  if not First then
  begin
    qryRegister.SQL.ADD(')');
    qryRegister.ParamByName('DateBegin').AsDateTime :=
      dtpDateBegin.Date;
    qryRegister.ParamByName('DateEnd').AsDateTime :=
      dtpDateEnd.Date;
    qryRegister.Open;
  end;
end;

{
SELECT * FROM register WHERE
(register."Date" >= :DateBegin) and
(register."Date" <= :DateEnd) and
((register."debet" = "51" and register."kredit" = "76.01")
or (register."debet" = "51" and register."kredit" = "76.02")
or (register."debet" = "51" and register."kredit" = "94")
or (register."debet" = "08" and register."kredit" = "76"))
}

procedure TfrmImportOperation.SpeedButton1Click(Sender: TObject);
begin
  ShowEntryList;
end;

procedure TfrmImportOperation.qryEntryCalcFields(DataSet: TDataSet);
begin
  qryEntryEntryName.Value := qryEntryDebit.Value + ' - ' +
    qryEntryCredit.Value;
end;

procedure TfrmImportOperation.qryRegisterNameoperationGetText(
  Sender: TField; var Text: String; DisplayText: Boolean);
var
  Temp: array[0..255] of Char;
begin
  StrPCopy(Temp, Sender.AsString);
  OemToANSI(Temp, Temp);
  Text := StrPas(Temp);
end;

procedure TfrmImportOperation.N1Click(Sender: TObject);
var
  Bookmark: TBookmark;
begin
  Bookmark := qryRegister.GetBookmark;
  qryRegister.DisableControls;
  try
    qryRegister.First;
    while not qryRegister.EOF do
    begin
      mdbcgrRegister.AddCheck(qryRegister.FieldByName('key').AsString);
      qryRegister.Next;
    end;
  finally
    qryRegister.GotoBookmark(Bookmark);
    qryRegister.FreeBookmark(Bookmark);
    qryRegister.EnableControls;
    mdbcgrRegister.Invalidate;
  end;
end;

procedure TfrmImportOperation.N2Click(Sender: TObject);
begin
  mdbcgrRegister.CheckList.Clear;
  mdbcgrRegister.Invalidate;
end;

procedure TfrmImportOperation.FormCreate(Sender: TObject);
var
  D: TDate;
begin
//  TestCalc := True;
  qryEntry.ParamByName('OpType').AsInteger := FOpType;
  qryEntry.Open;
  qryEntry.First;
  while not qryEntry.EOF do
  begin
    dbgEntry.ShowChecksByName['entryname'].Add(qryEntry.FieldByName('id').AsString);
    qryEntry.Next;
  end;
  if Options.GetDate('dlgimportoperation_datebegin', D) then
    dtpDateBegin.Date := D;
  if Options.GetDate('dlgimportoperation_dateend', D) then
    dtpDateEnd.Date := D;
end;

constructor TfrmImportOperation.Create(aOwner: TComponent;
  aOpType: Integer);
begin
  inherited Create(aOwner);
  FOpType := aOpType;
end;

procedure TfrmImportOperation.qryRegisterCalcFields(DataSet: TDataSet);
begin
  DataSet.FieldByName('AnalyzeDebet').AsString :=
    xMakeRegister.MakeKAU(DataSet.FieldByName('Debet').AsString,
      DataSet.FieldByName('KAU Debet').AsString, False);
  DataSet.FieldByName('AnalyzeKredit').AsString :=
    xMakeRegister.MakeKAU(DataSet.FieldByName('Kredit').AsString,
      DataSet.FieldByName('KAU Kredit').AsString, False);
  DataSet.FieldByName('Key').AsString :=
    DataSet.FieldByName('NomPP').AsString + '|' +
    DataSet.FieldByName('Date').AsString
end;

procedure TfrmImportOperation.FormDestroy(Sender: TObject);
begin
  Options.SetDate('dlgimportoperation_datebegin', True, dtpDateBegin.Date);
  Options.SetDate('dlgimportoperation_dateend', True, dtpDateEnd.Date);
end;

procedure TfrmImportOperation.mBitButton2Click(Sender: TObject);
begin
  dtpDateBegin.Date := dtpDateBegin.Date; 
end;

end.
