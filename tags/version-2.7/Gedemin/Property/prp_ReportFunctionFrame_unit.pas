{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    prp_ReportFunctionFrame_Unit.pas

  Abstract

    Gedemin project. TReportFunctionFrame.
    Фрайм для редактирования функции отчета.

  Author

    Karpuk Alexander

  Revisions history

    1.00    17.10.02    tiptop        Initial version.
--}
unit prp_ReportFunctionFrame_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  PRP_FUNCTIONFRAME_UNIT, Db, IBCustomDataSet, gdcBase, gdcFunction, gdcBaseInterface,
  ExtCtrls, SynEdit, SynDBEdit, gsFunctionSyncEdit, StdCtrls, DBCtrls,
  Mask, ComCtrls, gdcReport, Menus, ImgList, SynCompletionProposal,
  SynHighlighterJScript, SynEditHighlighter, SynHighlighterVBScript,
  gdcTree, gdcDelphiObject, ActnList, SuperPageControl, prpDBComboBox,
  SynEditExport, SynExportRTF, gdcCustomFunction, StdActns, TB2Dock,
  TB2Item, TB2Toolbar;

type
  TReportFunctionType = (rftMain, rftParam, rftEvent);
type
  TReportFunctionFrame = class(TFunctionFrame)
    actDeleteFunction: TAction;
    TBItem2: TTBItem;
    TBItem3: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    actNewFunction: TAction;
    pnlReport: TPanel;
    Splitter2: TSplitter;
    Panel1: TPanel;
    lbReport: TListBox;
    pmReport: TPopupMenu;
    actRefreshReport: TAction;
    procedure gdcFunctionAfterOpen(DataSet: TDataSet);
    procedure actDeleteFunctionUpdate(Sender: TObject);
    procedure actNewFunctionUpdate(Sender: TObject);
    procedure lbReportDblClick(Sender: TObject);
    procedure actRefreshReportExecute(Sender: TObject);
    procedure actClosePageExecute(Sender: TObject);
  private
    FNeedSave: Boolean;
    { Private declarations }
  protected
    function GetModule: string; override;
    function GetCanRun: Boolean; override;
    function GetCanPrepare: Boolean; override;
    procedure DoOnCreate; override;
    procedure GetNamesList(const SL: TStrings); override;
    function GetReportId: Integer;

    procedure SetUseInReport;

  public
    { Public declarations }
    procedure Cancel; override;
    function GetMasterObject: TgdcBase;override;

    property NeedSave: Boolean read FNeedSave write FNeedSave;
  end;

var
  ReportFunctionFrame: TReportFunctionFrame;

implementation
uses rp_report_const, gdcConstants, prp_MessageConst, IBSQL, prp_frmGedeminProperty_Unit, prp_BaseFrame_unit;
{$R *.DFM}

{ TReportFunctionFrame }

procedure TReportFunctionFrame.Cancel;
begin
  if gdcFunction.State in [dsEdit, dsInsert] then
    gdcFunction.Cancel;
end;

procedure TReportFunctionFrame.DoOnCreate;
begin
  inherited;
  FShowDeleteQuestion := False;
end;

function TReportFunctionFrame.GetCanPrepare: Boolean;
begin
  Result := True;
end;

function TReportFunctionFrame.GetCanRun: Boolean;
begin
  Result := not dbeName.Focused;
end;

function TReportFunctionFrame.GetMasterObject: TgdcBase;
begin
  Result := gdcFunction;
end;

function TReportFunctionFrame.GetModule: string;
begin
  if UpperCase(gdcFunction.MasterField) = 'MAINFORMULAKEY' then
    Result := MainModuleName
  else if UpperCase(gdcFunction.MasterField) = 'PARAMFORMULAKEY' then
    Result := ParamModuleName
  else if UpperCase(gdcFunction.MasterField) = 'EVENTFORMULAKEY' then
    Result := EventModuleName
  else
    Result := '';
end;

procedure TReportFunctionFrame.GetNamesList(const SL: TStrings);
var
  SQL: TIBSQL;
begin

  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcFunction.ReadTransaction;
    SQL.SQl.Text := 'SELECT ' + fnName + ', ' + fnId + ' FROM gd_function WHERE module = :module and ' +
      ' modulecode = :modulecode';
    SQL.Params[0].AsString := GetModule;
    SQL.Params[1].AsInteger := gdcFunction.FieldByName(fnModuleCode).AsInteger;
    SQL.ExecQuery;
    while not SQl.Eof do
    begin
      SL.AddObject(SQL.FieldByName(fnName).AsString,
        Pointer(SQL.FieldByName(fnId).AsInteger));
      SQL.Next;
    end;
  finally
    SQL.Free;
  end;
end;

function TReportFunctionFrame.GetReportId: Integer;
begin
  Result := - 1;
  if gdcFunction.MasterSource <> nil then
    Result := gdcFunction.MasterSource.DataSet.FieldByName(fnId).AsInteger;
end;

procedure TReportFunctionFrame.gdcFunctionAfterOpen(DataSet: TDataSet);
begin
  inherited;
  MasterObject.BaseState := MasterObject.BaseState + [sDialog];
  SetUseInReport;
end;

procedure TReportFunctionFrame.actDeleteFunctionUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := gdcFunction.State = dsEdit
end;

procedure TReportFunctionFrame.actNewFunctionUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := gdcFunction.State = dsEdit
end;
resourcestring
//Вместо названия текущего отчета
  cst_prp_current = 'Текущий';

procedure TReportFunctionFrame.SetUseInReport;
var
  ibsql: TIBSQL;
begin
  lbReport.Items.Clear;

  if gdcFunction.ID <= 0 then Exit;

  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := gdcBaseManager.ReadTransaction;
    ibsql.SQL.Text := 'SELECT * ' +
      ' FROM rp_reportlist ' +
      ' WHERE ' +
      '   mainformulakey = :fk ' +
      '   or paramformulakey = :fk ' +
      '   or eventformulakey = :fk ';

    ibsql.ParamByName('fk').AsInteger := gdcFunction.ID;
    ibsql.ExecQuery;

    lbReport.Sorted := False;
    while not ibsql.EOF do
    begin
      if ibsql.FieldByName('id').AsInteger = GetReportID then
        lbReport.Items.AddObject(cst_prp_Current,
          Pointer(ibsql.FieldByName('id').AsInteger))
      else
        lbReport.Items.AddObject(ibsql.FieldByName('name').AsString,
          Pointer(ibsql.FieldByName('id').AsInteger));
      ibsql.Next;
    end;
    lbReport.Sorted := True;
  finally
    ibsql.Free;
  end;
end;

procedure TReportFunctionFrame.lbReportDblClick(Sender: TObject);
begin
  if lbReport.Items.Count > 0 then
  begin
    if Integer(lbReport.Items.Objects[lbReport.ItemIndex]) = GetReportId then Exit;
    TfrmGedeminProperty(GetParentForm(Self)).EditReport(
      Integer(lbReport.Items.Objects[lbReport.ItemIndex]));
  end;
end;

procedure TReportFunctionFrame.actRefreshReportExecute(Sender: TObject);
begin
  SetUseInReport;
end;

procedure TReportFunctionFrame.actClosePageExecute(Sender: TObject);
begin
  (Owner as TBaseFrame).Close;

end;

initialization
  RegisterClass(TReportFunctionFrame);
finalization
  UnRegisterClass(TReportFunctionFrame);

end.
