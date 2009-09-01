unit rp_dlgEditReport_unit;

interface

uses
  Windows, Forms, Dialogs, IBQuery, gd_security, Classes, ActnList, Db,
  IBCustomDataSet, ExtCtrls, DBCtrls, StdCtrls, Controls, Mask, Buttons,
  ComCtrls, SysUtils, ShellApi, rp_BaseReport_unit, IBDatabase;

type
  TdlgEditReport = class(TForm)
    pcReport: TPageControl;
    tsMain: TTabSheet;
    pnlButton: TPanel;
    pnlRBtn: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    dbeName: TDBEdit;
    dbeFrqRefresh: TDBEdit;
    ibdsReport: TIBDataSet;
    dsReport: TDataSource;
    dbcbSaveResult: TDBCheckBox;
    ActionList1: TActionList;
    actCompile_M: TAction;
    actLoad_M: TAction;
    actSave_M: TAction;
    actFind_M: TAction;
    actHelp_M: TAction;
    actLoad_E: TAction;
    actSave_E: TAction;
    actCompile_E: TAction;
    actFind_E: TAction;
    actHelp_E: TAction;
    btnHelp: TButton;
    btnAccess: TButton;
    actRigth: TAction;
    Label7: TLabel;
    Label8: TLabel;
    btnSelMain: TButton;
    btnSelEvent: TButton;
    actSelectMainFunc: TAction;
    actSelectEventFunc: TAction;
    ibqryMainFormula: TIBQuery;
    ibqryEventFormula: TIBQuery;
    dsMainFormula: TDataSource;
    dsEventFormula: TDataSource;
    dblcbMainFormula: TDBLookupComboBox;
    dblcbEventFormula: TDBLookupComboBox;
    dsParamFormula: TDataSource;
    ibqryParamFormula: TIBQuery;
    Label9: TLabel;
    actSelectParamFunc: TAction;
    btnSelParam: TButton;
    dblcbParamFormula: TDBLookupComboBox;
    Label10: TLabel;
    btnSelTemplate: TButton;
    OpenDialog1: TOpenDialog;
    Label5: TLabel;
    dbcbReportServer: TDBLookupComboBox;
    ibqryReportServer: TIBQuery;
    dsReportServer: TDataSource;
    dbmDescription: TDBMemo;
    dblcbTemplate: TDBLookupComboBox;
    dsTemplate: TDataSource;
    ibqryTemplate: TIBQuery;
    actSelectTemplate: TAction;
    dbcbIsLocalExecute: TDBCheckBox;
    dbcbPreview: TDBCheckBox;
    Label4: TLabel;
    DBText1: TDBText;
    ibtrReport: TIBTransaction;
    procedure btnOkClick(Sender: TObject);
    procedure actSelectMainFuncExecute(Sender: TObject);
    procedure actSelectEventFuncExecute(Sender: TObject);
    procedure actSelectParamFuncExecute(Sender: TObject);
    procedure dblcbParamFormulaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dblcbMainFormulaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dblcbEventFormulaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbcbReportServerKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbcbTemplateTypeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dblcbTemplateKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure actSelectTemplateExecute(Sender: TObject);
    procedure ibqryMainFormulaAfterOpen(DataSet: TDataSet);
  private
    FExecuteFunction: TExecuteFunction;
    procedure CheckDatabase;

    function EditFunction(var AnReportKey: Integer; const AnModule: String): Boolean;
  public
    property ExecuteFunction: TExecuteFunction read FExecuteFunction write FExecuteFunction;

    function AddReport(const AnGroupKey: Integer): Boolean;
    function EditReport(const AnReportKey: Integer): Boolean;
    function DeleteReport(const AnReportKey: Integer): Boolean;
    function PrepareReport(const AnReportKey: Integer): Boolean;
    procedure UnPrepareReport;
  end;

var
  dlgEditReport: TdlgEditReport;

implementation

uses
  rp_dlgEditFunction_unit, gd_SetDatabase, rp_report_const, tmp_dlgEditTemplate_unit;

{$R *.DFM}

procedure TdlgEditReport.CheckDatabase;
begin
  ibqryEventFormula.Close;
  ibqryEventFormula.Params[0].AsString := EventModuleName;
  ibqryEventFormula.Open;
  ibqryMainFormula.Close;
  ibqryMainFormula.Params[0].AsString := MainModuleName;
  ibqryMainFormula.Open;
  ibqryParamFormula.Close;
  ibqryParamFormula.Params[0].AsString := ParamModuleName;
  ibqryParamFormula.Open;
  ibqryReportServer.Close;
  ibqryReportServer.Open;
  ibqryTemplate.Close;
  ibqryTemplate.Open;

{  ibdsReport.Database := FDatabase;
  ibdsReport.Transaction := FTransaction;

  ibsqlNewId.Database := FDatabase;
  ibsqlNewId.Transaction := FTransaction;}
end;

function TdlgEditReport.AddReport(const AnGroupKey: Integer): Boolean;
begin
  Result := False;
  if not ibtrReport.InTransaction then
    ibtrReport.StartTransaction;
  try
    ibdsReport.Close;
    CheckDatabase;
    ibdsReport.Open;
    ibdsReport.Insert;
    ibdsReport.FieldByName('isrebuild').AsInteger := 0;
    ibdsReport.FieldByName('preview').AsInteger := 1;
    ibdsReport.FieldByName('frqrefresh').AsInteger := 1;
    ibdsReport.FieldByName('islocalexecute').AsInteger := 0;
    ibdsReport.FieldByName('reportgroupkey').AsInteger := AnGroupKey;
    ibdsReport.FieldByName('afull').AsInteger := -1;
    ibdsReport.FieldByName('achag').AsInteger := -1;
    ibdsReport.FieldByName('aview').AsInteger := -1;
    if ShowModal = mrOk then
    try
      ibdsReport.FieldByName('id').AsInteger := GetUniqueKey(ibdsReport.Database, ibdsReport.Transaction);
      ibdsReport.Post;
      Result := True;
    except
      on E: Exception do
      begin
        ibdsReport.Cancel;
        MessageBox(Self.Handle, PChar('Произошла ошибка при создании отчета: ' +
         E.Message), 'Ошибка', MB_OK or MB_ICONERROR);
      end;
    end else
      ibdsReport.Cancel;
  finally
    ibtrReport.Commit;
  end;
end;

function TdlgEditReport.EditReport(const AnReportKey: Integer): Boolean;
begin
  Result := False;
  if not ibtrReport.InTransaction then
    ibtrReport.StartTransaction;
  try
    ibdsReport.Close;
    CheckDatabase;
    ibdsReport.ParamByName('id').AsInteger := AnReportKey;
    ibdsReport.Open;
    if ibdsReport.Eof then
    begin
      MessageBox(Self.Handle, 'Запись отчета не найдена.', 'Внимание', MB_OK or MB_ICONWARNING);
      Exit;
    end;
    ibdsReport.Edit;
    if ShowModal = mrOk then
    try
      ibdsReport.Post;
      Result := True;
    except
      on E: Exception do
      begin
        ibdsReport.Cancel;
        MessageBox(Self.Handle, PChar('Произошла ошибка при редактировании отчета: ' +
         E.Message), 'Ошибка', MB_OK or MB_ICONERROR);
      end;
    end else
      ibdsReport.Cancel;
  finally
    ibtrReport.Commit;
  end;
end;

function TdlgEditReport.DeleteReport(const AnReportKey: Integer): Boolean;
begin
  Result := False;
  if not ibtrReport.InTransaction then
    ibtrReport.StartTransaction;
  try
    ibdsReport.Close;
    CheckDatabase;
    ibdsReport.ParamByName('id').AsInteger := AnReportKey;
    ibdsReport.Open;
    if ibdsReport.Eof then
    begin
      MessageBox(Self.Handle, 'Запись отчета не найдена.', 'Внимание', MB_OK or MB_ICONWARNING);
      Exit;
    end;
    if MessageBox(Self.Handle, PChar(Format('Вы действительно хотите удалить отчет ''%s''?', [ibdsReport.FieldByName('name').AsString])),
      'Внимание',
     MB_YESNO or MB_ICONQUESTION) = ID_YES then
    try
      ibdsReport.Delete;
      Result := True;
    except
      on E: Exception do
      begin
        MessageBox(Self.Handle, PChar('Произошла ошибка при попытке удаления отчета: ' +
         E.Message), 'Ошибка', MB_OK or MB_ICONERROR);
      end;
    end;
  finally
    ibtrReport.Commit;
  end;
end;

procedure TdlgEditReport.btnOkClick(Sender: TObject);
begin
  if Trim(dbeName.Text) = '' then
  begin
    MessageBox(Self.Handle, 'Не задано наименование отчета.', 'Внимание', MB_OK or MB_ICONWARNING);
    dbeName.SetFocus;
    Exit;
  end;

  if (dblcbMainFormula.KeyValue = 0) or (dblcbMainFormula.KeyValue <> ibdsReport.FieldByName('mainformulakey').AsInteger) then
  begin
    MessageBox(Self.Handle, 'Не выбрана функция для построения отчета.', 'Внимание', MB_OK or MB_ICONWARNING);
    dblcbMainFormula.SetFocus;
    Exit;
  end;

  if dbeFrqRefresh.Text = '' then
  begin
    MessageBox(Self.Handle, 'Не введена частота обновления.', 'Внимание', MB_OK or MB_ICONWARNING);
    dbeFrqRefresh.SetFocus;
    Exit;
  end;

  ModalResult := mrOk;
end;

function TdlgEditReport.EditFunction(var AnReportKey: Integer; const AnModule: String): Boolean;
var
  F: TdlgEditFunction;
begin
  F := TdlgEditFunction.Create(Self);
  try
    SetDatabase(F, ibdsReport.Database);
    F.ExecuteFunction := FExecuteFunction;
    if AnReportKey = 0 then
      Result := F.AddFunction(AnModule, AnReportKey)
    else
      Result := F.EditFunction(AnReportKey);
  finally
    F.Free;
  end;
end;

procedure TdlgEditReport.actSelectMainFuncExecute(Sender: TObject);
var
  I: Integer;
begin
  I := 0;
  if not VarIsNull(dblcbMainFormula.KeyValue) then
    I := dblcbMainFormula.KeyValue;
  if EditFunction(I, MainModuleName) then
  begin
    ibqryMainFormula.Close;
    ibqryMainFormula.Open;
    ibdsReport.FieldByName('mainformulakey').AsInteger := I;
  end;
end;

procedure TdlgEditReport.actSelectEventFuncExecute(Sender: TObject);
var
  I: Integer;
begin
  I := 0;
  if not VarIsNull(dblcbEventFormula.KeyValue) then
    I := dblcbEventFormula.KeyValue;
  if EditFunction(I, EventModuleName) then
  begin
    ibqryEventFormula.Close;
    ibqryEventFormula.Open;
    ibdsReport.FieldByName('eventformulakey').AsInteger := I;
  end;
end;

procedure TdlgEditReport.actSelectParamFuncExecute(Sender: TObject);
var
  I: Integer;
begin
  I := 0;
  if not VarIsNull(dblcbParamFormula.KeyValue) then
    I := dblcbParamFormula.KeyValue;
  if EditFunction(I, ParamModuleName) then
  begin
    ibqryParamFormula.Close;
    ibqryParamFormula.Open;
    ibdsReport.FieldByName('paramformulakey').AsInteger := I;
  end;
end;

procedure TdlgEditReport.dblcbParamFormulaKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
    ibdsReport.FieldByName('paramformulakey').AsVariant := NULL;
end;

procedure TdlgEditReport.dblcbMainFormulaKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
    ibdsReport.FieldByName('mainformulakey').AsVariant := NULL;
end;

procedure TdlgEditReport.dblcbEventFormulaKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
    ibdsReport.FieldByName('eventformulakey').AsVariant := NULL;
end;

procedure TdlgEditReport.dbcbReportServerKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
    ibdsReport.FieldByName('serverkey').AsVariant := NULL;
end;

procedure TdlgEditReport.dbcbTemplateTypeKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
    ibdsReport.FieldByName('templatetype').AsVariant := NULL;
end;

procedure TdlgEditReport.dblcbTemplateKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
    ibdsReport.FieldByName('templatekey').AsVariant := NULL;
end;

procedure TdlgEditReport.actSelectTemplateExecute(Sender: TObject);
var
  F: TdlgEditTemplate;
  ResultValue: Integer;
  LocReportResult: TReportResult;
  Str: TStream;
begin
  F := TdlgEditTemplate.Create(nil);
  try
    SetDatabase(F, ibdsReport.Database);
    LocReportResult := TReportResult.Create;
    try
      if not ibdsReport.FieldByName('mainformulakey').IsNull then
      begin
        Str := ibqryMainFormula.CreateBlobStream(ibqryMainFormula.FieldByName('testresult'), bmRead);
        try
          LocReportResult.LoadFromStream(Str);
        finally
          Str.Free;
        end;
      end;

      if ibdsReport.FieldByName('templatekey').IsNull then
      begin
        if F.AddTemplate(ResultValue, LocReportResult) then
        begin
          ibqryTemplate.Close;
          ibqryTemplate.Open;
          ibdsReport.FieldByName('templatekey').AsInteger := ResultValue;
        end
      end else
        F.EditTemplate(ibdsReport.FieldByName('templatekey').AsInteger, LocReportResult);
    finally
      LocReportResult.Free;
    end;
  finally
    F.Free;
  end;
end;

procedure TdlgEditReport.ibqryMainFormulaAfterOpen(DataSet: TDataSet);
begin
  with (DataSet as TDataset) do
  begin
    MoveBy(20);
    First;
  end;
end;

function TdlgEditReport.PrepareReport(const AnReportKey: Integer): Boolean;
begin
  Result := False;
  if not ibtrReport.InTransaction then
    ibtrReport.StartTransaction;
  ibdsReport.Close;
  CheckDatabase;
  ibdsReport.ParamByName('id').AsInteger := AnReportKey;
  ibdsReport.Open;
  if ibdsReport.Eof then
  begin
    MessageBox(Self.Handle, 'Запись отчета не найдена.', 'Внимание', MB_OK or MB_ICONWARNING);
    Exit;
  end;
  ibdsReport.Edit;
  Result := True;
end;

procedure TdlgEditReport.UnPrepareReport;
begin
  if ibdsReport.State = dsEdit then
  begin
    if ibdsReport.Modified then
      ibdsReport.Post
    else
      ibdsReport.Cancel;
  end;
  ibtrReport.Commit; 
end;

end.

