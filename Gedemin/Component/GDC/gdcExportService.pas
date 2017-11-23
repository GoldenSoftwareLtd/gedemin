unit gdcExportService;

interface

uses
  DB, Windows, Classes,  IBCustomDataSet, gdcBase, Forms, ClipBrd, sysutils, Dialogs,
  gdcBaseInterface, Graphics, gd_WebClientControl_unit, gsDBGrid;

type

  TExportProcessCallback = procedure(RecordsCount: integer; var Terminate: boolean);

  TExportScope = (escAll, escSelection, escCurrent);
  TExportFormater = (efmCSV, efmTabText, efmXmlXls, efmOneField, efmHTML, efmSQLSel, efmSQLIns);
  TExportWriter = (ewrClipboard, ewrFile, ewrEMail);
  TFieldsTitle = (ftFieldName, ftLName, ftTitleGrid);

  TSrcField = record
    Field: TField;
    FieldNo: integer;
    ColumnGridTitle: string;
    ColumnGridDisplayFormat: string;
    Visible: boolean;
    Title: string;
    DisplayFormat: string;
  end;

  TSrcFields = array of TSrcField;

  TExportField = record
    FieldName: string;
    Title: string;
    IsUnique: boolean;
    DisplayFormat: string;
  end;

  TExportFields = array of TExportField;

  //************* Connectors  ************

  ISrcConnector = interface
    procedure StartProcess;
    procedure EndProcess;
    procedure Reset;
    procedure Next;
    function EOF: boolean;
    procedure SetScope(AScope: TExportScope);
    procedure SetUniqueFields(AExportFields: TExportFields);

    function GetSrcDataset: TDataset;
    function GetSrcFields: TSrcFields;
    function GetSelectedCount: integer;
    function GetExportFields: TExportFields;

    property SrcDataset: TDataset read GetSrcDataset;
  end;

  TSrcConnectorFactory = class
    class function CreateConnector(ASender: TObject): ISrcConnector;
  end;

  TSrcConnectorBase = class(TInterfacedObject, ISrcConnector)
  protected
    FDataset: TDataset;
    FScope: TExportScope;
    FUniqueFields: TStringList;
    FUniqueList: TStringList;
    FLocalEOF: boolean;
    FStartBookmark: TBookmark;
    function IsUniqueRecord: boolean;
    procedure LocalNext; virtual; abstract;
    function StrCrc32(str: string): string;
  public
    destructor Destroy; override;
    procedure SetScope(AScope: TExportScope);
    procedure SetUniqueFields(AExportFields: TExportFields);
    function GetSrcDataset: TDataset; virtual;
    function GetSrcFields: TSrcFields; virtual; abstract;
    function GetExportFields: TExportFields;
    procedure Reset; virtual; abstract;
    procedure Next; virtual;
    function EOF: boolean; virtual; abstract;
    function GetSelectedCount: integer; virtual;

    procedure StartProcess;
    procedure EndProcess;
  end;

  TSrcConnectorDataset = class(TSrcConnectorBase, ISrcConnector)
  protected
    procedure LocalNext; override;
  public
    constructor Create(ADataset: TDataset);

    procedure Reset; override;
    function EOF: boolean; override;
    function GetSrcFields: TSrcFields; override;
  end;

  TSrcConnectorDBGrid = class(TSrcConnectorBase, ISrcConnector)
  protected
    procedure LocalNext; override;
  private
    FDBGrid: TgsCustomDBGrid;
    FLocalBookmarkIndex: integer;
  public
    constructor Create(ADBGrid: TgsCustomDBGrid);
    destructor Destroy; override;
    procedure Reset; override;
    function EOF: boolean; override;
    function GetSelectedCount: integer; override;
    function GetSrcFields: TSrcFields; override;
    procedure GetColumnFromGrid(AField: TField; var ColumnTitle: string; var ColumnNo: integer;
                                var ColumnVisible: boolean; var ColumnDisplayFormat: string);

  end;

  //************* Writers  ************

  IExportWriter = interface
    procedure SetBulkWriteMode(ABulkMode: boolean);
    procedure WriteString(AString: String);
    procedure Open();
    procedure Close();
  end;

  TExportWriterFactory = class
    class function CreateWriter(AWriter: TExportWriter;
      AFilename: string = '';
      ASMTPKey: integer = -1;
      ARecipients: string = '';
      ASubject: string = '';
      ABody: string = '';
      AShowSendForm: boolean = false): IExportWriter;
  end;

  TExportWriterClipboard = class(TInterfacedObject, IExportWriter)
    constructor Create();
  private
    procedure SetBulkWriteMode(ABulkWriteMode: boolean);
    procedure WriteString(AString: String);
    procedure Open();
    procedure Close();
  end;

  TExportWriterTextFile = class(TInterfacedObject, IExportWriter)
    constructor Create(AFilename: TFileName);
    destructor Destroy(); override;
    procedure SetBulkWriteMode(ABulkWriteMode: boolean);
    procedure WriteString(AString: String);
    procedure Open();
    procedure Close();
  private
    FFileName: TFilename;
    FFileHandler: TextFile;
  end;

  TExportWriterEMail = class(TInterfacedObject, IExportWriter)
    constructor Create(AFilename: TFileName; ASMTPKey: integer; ARecipients, ASubject, ABody: string;
      AShowSendForm: boolean = false);
    destructor Destroy(); override;
    procedure SetBulkWriteMode(ABulkWriteMode: boolean);
    procedure WriteString(AString: String);
    procedure Open();
    procedure Close();
  private
    FFileName: TFilename;
    FSMTPKey: integer;
    FRecipients: string;
    FSubject: string;
    FBody: string;
    FFileHandler: TextFile;
    FShowSendForm: boolean;
  end;

  //************* Formaters  ************

  IExportFormater = interface
    procedure FormatInit(AExportFields: TExportFields; ADataSet: TDataSet);
    function FormatHeader(AExportFields: TExportFields; ADataSet: TDataset): string;
    function FormatData(AExportFields: TExportFields; ADataSet: TDataset): string;
    function FormatFooter(AExportFields: TExportFields): string;
    function PostProcess(AText: string): string;  // обработка готового блока текста с данными перед записью
  end;

  TExportFormaterFactory = class
    class function CreateFormater(format: TExportFormater): IExportFormater ;
  end;

  TExportFormaterBase = class(TInterfacedObject, IExportFormater)
  private
    function ImplodeFieldsData(AExportFields: TExportFields; ADataSet: TDataset;
      AFieldsSeparator: string; AQuoteChar: char): string;
    function ImplodeFieldsHeaders(AExportFields: TExportFields; AFieldsSeparator: string; AQuoteChar: char): string;
    function FormatHeader(AExportFields: TExportFields; ADataSet: TDataset): string; virtual;
    function FormatData(AExportFields: TExportFields; ADataSet: TDataset): string; virtual; abstract;
    function FormatFooter(AExportFields: TExportFields): string; virtual;
    function PostProcess(AText: string): string; virtual;
    procedure FormatInit(AExportFields: TExportFields; ADataSet: TDataSet); virtual;
  public
    destructor Destroy();override;
  end;

  TExportFormaterCSV = class(TExportFormaterBase)
  private
    function FormatHeader(AExportFields: TExportFields; ADataSet: TDataset): string; override;
    function FormatData(AExportFields: TExportFields; ADataSet: TDataset): string; override;
  end;

  TExportFormaterTabbed = class(TExportFormaterBase)
  private
    function FormatHeader(AExportFields: TExportFields; ADataSet: TDataset): string; override;
    function FormatData(AExportFields: TExportFields; ADataSet: TDataset): string; override;
  end;

  TExportFormaterOneField = class(TExportFormaterBase)
  private
    function FormatData(AExportFields: TExportFields; ADataSet: TDataset): string; override;
    function PostProcess(AText: string): string; override;
  end;

  TExportFormaterHTML = class(TExportFormaterBase)
  private
    function FormatHeader(AExportFields: TExportFields; ADataSet: TDataset): string; override;
    function FormatData(AExportFields: TExportFields; ADataSet: TDataset): string; override;
    function FormatFooter(AExportFields: TExportFields): string; override;
  end;

  TExportFormaterSQLSelect = class(TExportFormaterBase)
  private
    function FormatHeader(AExportFields: TExportFields; ADataSet: TDataset): string; override;
    function FormatData(AExportFields: TExportFields; ADataSet: TDataset): string; override;
    function FormatFooter(AExportFields: TExportFields): string; override;
    function PostProcess(AText: string): string; override;
  end;

  TExportFormaterSQLInsert = class(TExportFormaterBase)
  private
    FInsertSQLStr: string;
    procedure FormatInit(AExportFields: TExportFields; ADataSet: TDataSet); override;
    function FormatData(AExportFields: TExportFields; ADataSet: TDataset): string; override;
  end;

  TExportFormaterXmlXls = class(TExportFormaterBase)
  private
    function FormatHeader(AExportFields: TExportFields; ADataSet: TDataset): string; override;
    function FormatData(AExportFields: TExportFields; ADataSet: TDataset): string; override;
    function FormatFooter(AExportFields: TExportFields): string; override;
  end;

  //************* Export class  ************

  TExportService = class
  private
    FiConnector: ISrcConnector;
  public
    class function ShowSettingsForm(
                    ASrcFields: TSrcFields;
                    var AExportFields: TExportFields;
                    var AFieldsTitle: TFieldsTitle;
                    var AScope: TExportScope;
                    var AFormater: TExportFormater;
                    var AWriter: TExportWriter;
                    var AFilename: TFilename): boolean;

    class function DoExportWithSettingsForm(Sender: TObject): boolean;

    class function DoExportWithParams(
                    ASender: TObject;
                    AExportFields: TExportFields;
                    AFormater: TExportFormater;
                    AWriter: TExportWriter;
                    AScope : TExportScope;
                    AFilename: TFileName = '';
                    ARecipients:string = '';
                    ASubject: string = 'Экспорт данных';
                    ABody: string = '';
                    ASMTPKey: integer = -1;
                    ACallback: TExportProcessCallback = nil): boolean;

    constructor Create(const ASrcConnector: ISrcConnector);
    destructor Destroy;override;
    function DoExport (
                const AExportFields: TExportFields;
                const iFormater: IExportFormater;
                const iWriter: IExportWriter;
                const ACallback: TExportProcessCallback = nil): boolean;
  end;

const
  FileExtentions: array[efmCSV..efmSQLIns] of String =
    ('csv', 'txt', 'xls', 'txt', 'html', 'sql', 'sql');

  EOL = #13#10;

implementation

uses gdc_dlgExportService_unit, JclMath, gd_common_functions, gd_dlgSendMessage_unit;

{ Export ProcessCallback }
procedure ShowExportProgress(RecordsCount: integer; var Terminate: boolean);
begin
  Terminate := (MessageDlg('Экспортировано записей: '+ IntToStr(RecordsCount)+#13#10+ ' Продолжить?', mtConfirmation, mbOKCancel, 0) <> 1);
end;

procedure SendEmailWithAttachment(AFilename: TFileName; ASMTPKey: integer; ARecipients, ASubject, ABody: string;
  AShowSendForm: boolean = false);
begin
  if AShowSendForm then
    with Tgd_dlgSendMessage.Create(nil) do
    try
      Init(ASMTPKey, ARecipients, ASubject, ABody, AFilename);
      ShowModal;
    finally
      Free;
    end
  else
  // функция, возвращает, emailID. Но нам пока не нужно
  gdWebClientControl.SendEmail(ASMTPKey, ARecipients, ASubject,
      ABody, AFilename);
end;

{ TSrcConnectorFactory }

class function TSrcConnectorFactory.CreateConnector(
  ASender: TObject): ISrcConnector;
begin
  if (ASender is TDataset) then
    Result:= TSrcConnectorDataset.Create(ASender as TDataset)
  else if (ASender is TgsCustomDBGrid) then
    Result:= TSrcConnectorDBGrid.Create(ASender as TgsCustomDBGrid)
  else
    Raise Exception.Create('Connector not found');
end;

{ TSrcConnectorBase }

function TSrcConnectorBase.GetSelectedCount: integer;
begin
  Result := 1;
end;

function TSrcConnectorBase.GetSrcDataset: TDataset;
begin
  Result := FDataset;
end;

procedure TSrcConnectorBase.SetScope(AScope: TExportScope);
begin
  FScope := AScope;
end;

procedure TSrcConnectorBase.StartProcess;
begin
  FStartBookmark := FDataset.GetBookmark;
  FDataset.DisableControls;
  Reset;
end;

procedure TSrcConnectorBase.EndProcess;
begin
  FDataset.EnableControls;
  if Assigned(FStartBookmark) then
  begin
    FDataset.GotoBookmark(FStartBookmark);
  end;
end;

function TSrcConnectorBase.IsUniqueRecord: boolean;
var i: integer;
  str: string;
//  crc: cardinal;
  FoundedIndex: integer;
begin
  // нет уникальных полей
  if FUniqueFields.Count = 0 then begin
    Result := true;
    Exit;
  end;
  // заданы уникальные поля
  str := '';
  for i := 0 to FUniqueFields.Count - 1 do begin
    str := str + FDataset.FieldByName(FUniqueFields[i]).AsString+'|';
  end;
// не работет, crc например от 4 и 7 дает одинаковый результат
//  str:= self.StrCrc32(str);

  Result:= not FUniqueList.Find(str, FoundedIndex);
  if Result then begin
    FUniqueList.add(str);
    FUniqueList.Sort;
  end;
end;


procedure TSrcConnectorBase.SetUniqueFields(AExportFields: TExportFields);
var i: integer;
begin
  FUniqueFields.Clear;
  if not Assigned(AExportFields) then
    Exit;
  for i :=0 to High(AExportFields) do
    if AExportFields[i].IsUnique then
      FUniqueFields.Add(AExportFields[i].FieldName);
end;

procedure TSrcConnectorBase.Next;
begin
  case FScope of
    escAll: LocalNext;
    escSelection: LocalNext;
    escCurrent: FLocalEOF := true;
  end;
end;

function TSrcConnectorBase.StrCrc32(str: string): string;
var a: array of byte;
  i: integer;
  crc: cardinal;
begin
  SetLength(a, Length(str));
  for i:= 0 to Length(str) - 1 do
    a[i] := ord(str[i]);

  crc := Crc32(a, High(a));
  Result := intToStr(crc);
end;

function TSrcConnectorBase.GetExportFields: TExportFields;
var EF: TExportFields;
    i: integer;
begin
  with FDataSet do
  begin
    SetLength(EF, Fields.Count);
    for i := 0  to Fields.Count - 1 do
    begin
      EF[i].FieldName := Fields[i].FieldName;
      EF[i].Title := Fields[i].DisplayLabel;
      EF[i].IsUnique := False;
    end;
  end;
  Result := EF;
  SetLength(EF, 0);
end;

destructor TSrcConnectorBase.Destroy;
begin
  FUniqueList.Free;
  FUniqueFields.Free;
  inherited;
end;

{ TSrcConnectorDataset }

constructor TSrcConnectorDataset.Create(ADataset: Tdataset);
begin
  FDataset := ADataset;
  FLocalEOF := False;
  FUniqueList := TStringList.Create;
  FUniqueFields := TStringList.Create;
  FUniqueList.Sorted := true;
end;

procedure TSrcConnectorDataset.Reset;
begin
  case FScope of
    escAll, escSelection: FDataSet.First;
    escCurrent: FLocalEOF := false;
  end;

  FUniqueList.Clear;
  if (FUniqueFields.Count > 0) then
    IsUniqueRecord;
end;

procedure TSrcConnectorDataset.LocalNext;
begin
  case FScope of
    escAll, escSelection:
      if (FUniqueFields.Count) = 0 then
        FDataSet.Next;
      else
      begin
        // уникальные
        repeat
          FDataSet.Next;
        until((FDataSet.EOF) or (IsUniqueRecord))
      end;
  end;
end;

function TSrcConnectorDataset.EOF: boolean;
begin
  Result := false;
  case FScope of
    escAll, escSelection: Result := FDataset.Eof;
    escCurrent: Result := FLocalEOF;
  end;
end;

function TSrcConnectorDataset.GetSrcFields: TSrcFields;
var SF: TSrcFields;
    i: integer;
begin
  with FDataSet do
  begin
    SetLength(SF, Fields.Count);
    for i := 0  to Fields.Count - 1 do
    begin
      SF[i].Field := Fields[i];
      SF[i].FieldNo := Fields[i].Index;
      SF[i].Visible := Fields[i].Visible;
      SF[i].Title := Fields[i].FieldName;
    end;
  end;
  Result := SF;
  SetLength(SF, 0);
end;

{ TSrcConnectorDBGrid }

constructor TSrcConnectorDBGrid.Create(ADBGrid: TgsCustomDBGrid);
begin
  FDBGrid := ADBGrid;
  FLocalEOF := False;
  FDataset := ADBGrid.DataSource.DataSet;
  FUniqueList := TStringList.Create;
  FUniqueFields := TStringList.Create;
end;

procedure TSrcConnectorDBGrid.Reset;
begin
  case FScope of
    escAll: FDataSet.First;
    escSelection:
    begin
      FDataSet.GotoBookmark(Pointer(TgsDBGrid(FDBGrid).SelectedRows.Items[0]));
      FLocalBookmarkIndex := 0;
      FLocalEOF := false;
    end;
    escCurrent: FLocalEOF := false;
  end;

  FUniqueList.Clear;
  if (FUniqueFields.Count > 0) then
    IsUniqueRecord;

end;

function TSrcConnectorDBGrid.EOF: boolean;
begin
  Result := false;
  case FScope of
    escAll: Result := FDataSet.EOF;
    escSelection:
    begin
      if (FLocalBookmarkIndex > TgsDBGrid(FDBGrid).SelectedRows.Count - 1) then
        FLocalEOF := true
      else
        FLocalEOF := false;
      Result := FLocalEOF;
    end;
    escCurrent: Result := FLocalEOF;
  end;
end;

function TSrcConnectorDBGrid.GetSrcFields: TSrcFields;
var SF: TSrcFields;
    i: integer;
    ColumnTitle: string;
    ColumnNo: integer;
    ColumnVisible: boolean;
    ColumnDisplayFormat: string;
begin
  with FDBGrid.DataSource.DataSet do
  begin
    SetLength(SF, Fields.Count);
    for i := 0  to Fields.Count - 1 do
    begin
      SF[i].Field := Fields[i];
      SF[i].Title := Fields[i].FieldName;
      GetColumnFromGrid(Fields[i], ColumnTitle, ColumnNo, ColumnVisible, ColumnDisplayFormat);

      SF[i].ColumnGridTitle := ColumnTitle;
      SF[i].FieldNo := ColumnNo;
      SF[i].Visible := ColumnVisible;
      SF[i].ColumnGridDisplayFormat := ColumnDisplayFormat;
    end;
  end;
  Result := SF;
  SetLength(SF, 0);
end;

procedure TSrcConnectorDBGrid.GetColumnFromGrid(AField: TField;
  var ColumnTitle: string; var ColumnNo: integer;
  var ColumnVisible: boolean; var ColumnDisplayFormat: string);
var i: integer;
begin
  for i := 0 to FDBGrid.Columns.Count - 1 do
  begin
    if FDBGrid.Columns[i].Field = AField then
    begin
      ColumnTitle := FDBGrid.Columns[i].Title.Caption;
      ColumnVisible := FDBGrid.Columns[i].Visible;
      ColumnDisplayFormat := TgsColumn(FDBGrid.Columns[i]).DisplayFormat;
      ColumnNo := TgsColumn(FDBGrid.Columns[i]).ID;
      break;
    end;
  end;
end;

function TSrcConnectorDBGrid.GetSelectedCount: integer;
begin
  Result := TgsDBGrid(FDBGrid).SelectedRows.Count;
end;

procedure TSrcConnectorDBGrid.LocalNext;
begin
  case FScope of
    escAll:
    begin
      repeat
        FDataSet.Next;
      until (FDataSet.EOF or IsUniqueRecord)
    end;
    escSelection:
    begin
      if (not Self.EOF) then
      begin
        repeat
          FLocalBookmarkIndex := FLocalBookmarkIndex + 1;
          if (not Self.EOF) then
            FDataSet.GotoBookmark(Pointer(TgsDBGrid(FDBGrid).SelectedRows.Items[FLocalBookmarkIndex]));
        until (Self.EOF or IsUniqueRecord)
      end;
    end;
  end;
end;

destructor TSrcConnectorDBGrid.Destroy;
begin
  FDBGrid:= nil;
  inherited;
end;

{ TExportService }

constructor TExportService.Create(const ASrcConnector: ISrcConnector);
begin
  FiConnector := ASrcConnector;
end;

destructor TExportService.Destroy;
begin
  FiConnector:= nil;
  inherited;
end;

function TExportService.DoExport(const AExportFields: TExportFields;
                        const iFormater: IExportFormater;
                        const iWriter: IExportWriter;
                        const ACallback: TExportProcessCallback = nil): boolean;
var
  ExportText: string;
  RecordsCount: integer;
  Terminate: boolean;
  SkipRecordsBeforeQuestion: integer;
begin
  try
    SkipRecordsBeforeQuestion := 10000;
    RecordsCount := 0;
    Terminate := false;

    FiConnector.StartProcess;
    iFormater.FormatInit(AExportFields, FiConnector.SrcDataset);

    ExportText:= '';
    while not(FiConnector.EOF or Terminate) do
    begin
      ExportText:= ExportText + iFormater.FormatData(AExportFields, FiConnector.SrcDataset);
      FiConnector.Next;
      inc(RecordsCount);
      if((RecordsCount mod SkipRecordsBeforeQuestion) = 0) then begin
        if Assigned(ACallback) then ACallback(RecordsCount, Terminate);
      end;
    end;
    FiConnector.EndProcess;

    try
      iWriter.Open;
      iWriter.WriteString(IFormater.FormatHeader(AExportFields, FiConnector.SrcDataset));
      iWriter.WriteString(IFormater.PostProcess(ExportText)); // обрабатываем блок с данными перед сохранением
      iWriter.WriteString(IFormater.FormatFooter(AExportFields));
    finally
      iWriter.Close;
    end;

  finally
    Result := True;
  end;
end;

class function TExportService.DoExportWithParams(
                ASender: TObject;
                AExportFields: TExportFields;
                AFormater: TExportFormater;
                AWriter: TExportWriter;
                AScope : TExportScope;
                AFilename: TFileName = '';
                ARecipients:string = '';
                ASubject: string = 'Экспорт данных';
                ABody: string = '';
                ASMTPKey: integer = -1;
                ACallback: TExportProcessCallback = nil): boolean;

var
  ExportService: TExportService;
  iConnector: ISrcConnector;
  iFormater: IExportFormater;
  iWriter: IExportWriter;
begin
  iConnector:= TSrcConnectorFactory.CreateConnector(ASender);
  iConnector.SetScope(AScope);

  iConnector.SetUniqueFields(AExportFields);

  if not Assigned(AExportFields) or (High(AExportFields) = 0) then
    AExportFields := iConnector.GetExportFields;

  iFormater:= TExportFormaterFactory.CreateFormater(TExportFormater(AFormater));

  if (AWriter = ewrEmail) and (AFilename = '') then begin
    AFilename := GetEmailTempFileName(FileExtentions[AFormater]);
  end;

  iWriter:= TExportWriterFactory.CreateWriter(TExportWriter(AWriter), AFilename, ASMTPKey, ARecipients, ASubject, ABody, false);

  ExportService:= TExportService.Create(iConnector);
  Result := ExportService.DoExport(AExportFields, iFormater, iWriter);

  FreeAndNil(ExportService);  // так освобождаем объектный тип
  iConnector := nil;          // так освобождаем интерфейсные типы
  iFormater := nil;
  iWriter := nil;
  SetLength(AExportFields, 0);
end;

class function TExportService.DoExportWithSettingsForm(Sender: TObject): boolean;
var SrcFields: TSrcFields;
    ExportFields: TExportFields;
    FieldsTitle: TFieldsTitle;
    Scope: TExportScope;
    Formater: TExportFormater;
    Writer: TExportWriter;
    Filename: TFileName;
    Recipients, Subject, Body: string;
    SMTPKey: integer;
    iFormater: IExportFormater;     // обязательно объявляем как интерфейсные типы
    iWriter: IExportWriter;
    ExportService : TExportService;
    iConnector: ISrcConnector;
begin
  iConnector:= TSrcConnectorFactory.CreateConnector(Sender);
  SrcFields := iConnector.GetSrcFields;
  FieldsTitle := ftLName;
  Writer := ewrClipboard;
  Formater := efmTabText;
  Filename := 'd:\export.txt';
  Scope := escAll;

  if iConnector.GetSelectedCount > 1 then
    Scope := escSelection;
  if not TExportService.ShowSettingsForm(
            SrcFields,
            ExportFields,
            FieldsTitle,
            Scope,
            Formater,
            Writer,
            Filename)
  then begin
    Result := false;
    Exit;
  end;

  iConnector.SetScope(Scope);
  iConnector.SetUniqueFields(ExportFields);

  iFormater:= TExportFormaterFactory.CreateFormater(TExportFormater(Formater));

  if (Writer = ewrEmail) then begin
    Filename := GetEmailTempFileName(FileExtentions[Formater]);
    SMTPKey := -1;
    Subject := 'Экспорт данных'
  end else begin
    SMTPKey := -1;
    Subject := ''
  end;

  iWriter:= TExportWriterFactory.CreateWriter(TExportWriter(Writer), Filename, SMTPKey, Recipients, Subject, Body, true);

  ExportService:= TExportService.Create(iConnector);

  Result := ExportService.DoExport(ExportFields, iFormater, iWriter, @ShowExportProgress);

  FreeAndNil(ExportService);  // так освобождаем объектный тип
  iConnector := nil;          // так освобождаем интерфейсные типы
  iFormater := nil;
  iWriter := nil;
  SetLength(SrcFields, 0);
  SetLength(ExportFields, 0);

  if Result then
    MessageBox(0, 'Данные скопированы', 'Экспорт данных', mb_Ok)
  else
    MessageBox(0, 'Во время копирования данных произошла ошибка', 'Экспорт данных', mb_Ok)
end;

class function TExportService.ShowSettingsForm(ASrcFields: TSrcFields; var AExportFields: TExportFields;
  var AFieldsTitle: TFieldsTitle; var AScope: TExportScope; var AFormater: TExportFormater; var AWriter: TExportWriter;
  var AFilename: TFilename): boolean;
begin
  if not Tgdc_dlgExportService.CreateAndAssigned(ASrcFields, AExportFields, AFieldsTitle, AScope, AFormater, AWriter, AFilename) then begin
    Result := false;
    Exit;
  end;
  Result:= true;
end;

{ TExportFormaterFactory }

class function TExportFormaterFactory.CreateFormater(
  format: TExportFormater): IExportFormater;
begin
  case format of
    efmCSV: begin
      result := TExportFormaterCSV.Create();
    end;
    efmTabText: begin
      result := TExportFormaterTabbed.Create();
    end;
    efmOneField: begin
      result := TExportFormaterOneField.Create();
    end;
    efmHTML: begin
      result := TExportFormaterHTML.Create();
    end;
    efmSQLSel: begin
      result := TExportFormaterSQLSelect.Create();
    end;
    efmSQLIns: begin
      result := TExportFormaterSQLInsert.Create();
    end;
    efmXmlXls: begin
      result := TExportFormaterXmlXls.Create();
    end;
    else begin
      Raise Exception.Create('Formater not found');
    end;
  end;

end;

{ TExportFormaterBase }

function TExportFormaterBase.FormatFooter(AExportFields: TExportFields): string;
begin
  Result := '';
end;

function TExportFormaterBase.FormatHeader(AExportFields: TExportFields; ADataSet: TDataset): string;
begin
  Result := '';
end;

function TExportFormaterBase.ImplodeFieldsHeaders(AExportFields: TExportFields;
  AFieldsSeparator: string; AQuoteChar: char): string;
var i: integer;
begin
  result := '';
  for i := 0 to High(AExportFields) do begin
    result:= result + AnsiQuotedStr(AExportFields[i].Title, AQuoteChar) + AFieldsSeparator;
  end;
  // удалим последний разделитель
  SetLength(Result, Length(Result) - Length(AFieldsSeparator));
end;


function TExportFormaterBase.ImplodeFieldsData(AExportFields: TExportFields; ADataSet: TDataset;
  AFieldsSeparator: string; AQuoteChar: char): string;
var i: integer;
begin
  result := '';
  for i := 0 to High(AExportFields) do begin
    case ADataSet.fieldbyname(AExportFields[i].FieldName).DataType of
      ftFloat, ftCurrency, ftBCD: begin
        result:= result
          + trim(FormatFloat(AExportFields[i].DisplayFormat , ADataSet.fieldbyname(AExportFields[i].FieldName).AsFloat))
          + AFieldsSeparator;
      end;
      ftWord, ftInteger, ftSmallint: begin
        result:= result
          + trim(ADataSet.fieldbyname(AExportFields[i].FieldName).AsString)
          + AFieldsSeparator;
      end;
      ftDate, ftDateTime: begin
        if ADataSet.fieldbyname(AExportFields[i].FieldName).IsNull then
          result:= result + AFieldsSeparator
        else
            result:= result
            + trim(AnsiQuotedStr(FormatDateTime(AExportFields[i].DisplayFormat, ADataSet.fieldbyname(AExportFields[i].FieldName).AsDateTime), AQuoteChar))
            + AFieldsSeparator;
      end;
      else begin
        result:= result
          + trim(AnsiQuotedStr(ADataSet.fieldbyname(AExportFields[i].FieldName).AsString, AQuoteChar))
          + AFieldsSeparator;
      end;
    end;

  end;
  // удалим последний разделитель
  SetLength(Result, Length(Result) - Length(AFieldsSeparator));
end;

function TExportFormaterBase.PostProcess(AText: string): string;
begin
  Result := AText;
end;

procedure TExportFormaterBase.FormatInit(AExportFields: TExportFields; ADataSet: TDataSet);
begin
  //
end;

destructor TExportFormaterBase.Destroy;
begin
  inherited;
end;

{ TExportFormaterTabbed }

function TExportFormaterTabbed.FormatData(AExportFields: TExportFields;
  ADataSet: TDataSet): string;
begin
  Result := ImplodeFieldsData(AExportFields, ADataSet, #9, '"') + EOL;
end;

function TExportFormaterTabbed.FormatHeader(AExportFields: TExportFields;
  ADataSet: TDataSet): string;
begin
  Result := ImplodeFieldsHeaders(AExportFields, #9, '"') + EOL;
end;

{ TExportFormaterCSV }

function TExportFormaterCSV.FormatData(AExportFields: TExportFields;
  ADataSet: TDataSet): string;
begin
  Result := ImplodeFieldsData(AExportFields, ADataSet, ',', '"') + EOL;
end;

function TExportFormaterCSV.FormatHeader(AExportFields: TExportFields;
  ADataSet: TDataSet): string;
begin
  Result := ImplodeFieldsHeaders(AExportFields, ',', ' ') + EOL;
end;

{ TExportFormaterXmlXls }

function TExportFormaterXmlXls.FormatData(AExportFields: TExportFields;
  ADataSet: TDataset): string;
var i: integer;
begin
  result := '<Row ss:AutoFitHeight="1">' + EOL;
  for i:= 0 to High(AExportFields) do begin
    result := result + ' <Cell ss:StyleID="Column' + inttostr(i) + '">';
    case ADataSet.fieldbyname(AExportFields[i].FieldName).DataType of
      ftFloat, ftCurrency, ftBCD, ftWord, ftInteger, ftSmallint: begin
        result := result + '<Data ss:Type="Number">' + ADataSet.fieldbyname(AExportFields[i].FieldName).Asstring
      end;
      ftDate, ftDateTime: begin
        if ADataSet.fieldbyname(AExportFields[i].FieldName).IsNull then
          result := result + '<Data ss:Type="String">'
        else
          result := result + '<Data ss:Type="DateTime">' + FormatDateTime('yyyy-mm-dd"T"hh:nn:ss"Z"', ADataSet.fieldbyname(AExportFields[i].FieldName).Asdatetime)
      end;
      else begin
        result := result + '<Data ss:Type="String">' + ADataSet.fieldbyname(AExportFields[i].FieldName).AsString
      end;
    end;
    result := result + '</Data></Cell>' + EOL;
  end;
  result := result + '</Row>' + EOL;
end;

function TExportFormaterXmlXls.FormatHeader(AExportFields: TExportFields;
  ADataSet: TDataSet): string;
var i: integer;
    DisplayFormat: string;
    StrColumnsStyle, StrTitle: string;
begin
  Result := '<?xml version="1.0" encoding="Windows-1251" standalone="yes"?>' + EOL
            + '<?mso-application progid="Excel.Sheet"?>' + EOL
            + '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"' + EOL
            +' xmlns:o="urn:schemas-microsoft-com:office:office"' + EOL
            +' xmlns:x="urn:schemas-microsoft-com:office:excel"' + EOL
            +' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"' + EOL
            +' xmlns:html="http://www.w3.org/TR/REC-html40">' + EOL;
  // Стили
  StrColumnsStyle := '<Styles>' + EOL
            + ' <Style ss:ID="Default" ss:Name="Normal">' + EOL
            + '  <Alignment ss:Horizontal="Left" ss:Vertical="Top" ss:WrapText="0"/>' + EOL
            + '  <Borders/>' + EOL
            + '  <Font ss:FontName="Tahoma" ss:Size="10" ss:Color="#000000"/>' + EOL
            + '  <Interior/>' + EOL
            + '  <NumberFormat/>' + EOL
            + '  <Protection/>' + EOL
            + ' </Style>' + EOL
            + ' <Style ss:ID="Title">' + EOL
            + '  <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>' + EOL
            + '  <Font ss:FontName="Tahoma" ss:Size="10" ss:Color="#000000" ss:Bold="1"/>' + EOL
            + '  <Interior ss:Color="#CCFFCC" ss:Pattern="Gray125" ss:PatternColor="#00FF00"/>' + EOL
            + '  </Style>' + EOL;

  StrTitle := '<Row ss:AutoFitHeight="1">' + EOL;

  for i := 0 to High(AExportFields) do
  begin
    DisplayFormat := AExportFields[i].DisplayFormat;
    StrColumnsStyle := StrColumnsStyle + ' <Style ss:ID="Column' + inttostr(i) + '">' + EOL;
    case ADataset.FieldByName(AExportFields[i].FieldName).DataType of
      ftFloat, ftCurrency, ftBCD, ftWord, ftInteger, ftSmallint: begin
        StrColumnsStyle := StrColumnsStyle
                          + '  <Alignment ss:Horizontal="Right" ss:Vertical="Top" ss:WrapText="0"/>' + EOL
      end;
      ftDate, ftDateTime: begin
        StrColumnsStyle := StrColumnsStyle
                          + '  <Alignment ss:Horizontal="Center" ss:Vertical="Top" ss:WrapText="0"/>'+ EOL;
        if (DisplayFormat = '') then
          DisplayFormat := 'dd.mm.yyyy'
      end;
      else begin
        StrColumnsStyle := StrColumnsStyle
                          + '  <Alignment ss:Horizontal="Left" ss:Vertical="Top" ss:WrapText="0"/>'+ EOL
      end;
    end;

    if DisplayFormat <> '' then
      StrColumnsStyle := StrColumnsStyle + '  <NumberFormat ss:Format="'
                        + StringReplace(DisplayFormat, 'hh:nn','hh:mm',[rfReplaceAll, rfIgnoreCase])
                        + '"/>' + EOL;

    StrColumnsStyle := StrColumnsStyle + '  </Style>' + EOL;

    //формируем сам заголовок
    StrTitle := StrTitle + ' <Cell ss:StyleID="Title"><Data ss:Type="String">'
          + AExportFields[i].Title
          + '</Data></Cell>' + EOL;
  end;

  StrColumnsStyle := StrColumnsStyle + '</Styles>' + EOL;
  Result := Result + StrColumnsStyle + EOL;

  Result := Result + '<Worksheet ss:Name="Export">' + EOL;
  Result := Result + '<Table>' + EOL;

  Result := Result + '<Column ss:AutoFitWidth="1"/>' + EOL;

  StrTitle := StrTitle + '</Row>' + EOL;
  Result := Result + StrTitle;

end;

function TExportFormaterXmlXls.FormatFooter(
  AExportFields: TExportFields): string;
begin
  Result := '</Table>' + EOL
            + '<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + EOL
            + '<PageSetup>' + EOL
            + '<Header x:Margin="0.3"/>' + EOL
            + '<Footer x:Margin="0.3"/>' + EOL
            + '<PageMargins x:Bottom="0.75" x:Left="0.7" x:Right="0.7" x:Top="0.75"/>' + EOL
            + '</PageSetup>' + EOL
            + '<Selected/>' + EOL
            + '<ProtectObjects>False</ProtectObjects>' + EOL
            + '<ProtectScenarios>False</ProtectScenarios>' + EOL
            + '</WorksheetOptions>' + EOL
            + '</Worksheet>' + EOL
            + '</Workbook>' + EOL;
end;

{ TExportFormaterOneField }

function TExportFormaterOneField.FormatData(AExportFields: TExportFields;
  ADataSet: TDataset): string;
begin
  Result := ImplodeFieldsData(AExportFields, ADataset, ',', ' ') + ',';
end;

function TExportFormaterOneField.PostProcess(AText: string): string;
begin
  Result := AText;
  SetLength(Result, Length(Result) - Length(','));
end;

{ TExportFormaterHTML }

function TExportFormaterHTML.FormatHeader(AExportFields: TExportFields;
  ADataSet: TDataSet): string;
var
  FieldsSeparator: string;
begin
  FieldsSeparator := '</th><th>';

  Result  := '<html>'
    + '<head>' + EOL
    + '<meta http-equiv="Content-Type" Content="text/html; Charset=Windows-1251">' + EOL
    + '</head>' + EOL
    + '<body>' + EOL;

  Result := Result + '<table>' + EOL
    + '<tr>' + '<th>';

  Result := Result + ImplodeFieldsHeaders(AExportFields, FieldsSeparator, ' ') ;

  Result := Result + '</th>' + '</tr>' +EOL;
end;


function TExportFormaterHTML.FormatData(AExportFields: TExportFields; ADataSet: TDataset): string;
var
  FieldsSeparator: string;
begin
  FieldsSeparator := '</td><td>';

  result := '<tr>' + '<td>';

  Result := Result + ImplodeFieldsData(AExportFields, ADataset, FieldsSeparator, ' ');

  Result := Result + '</td>' + '</tr>' + EOL;
end;

function TExportFormaterHTML.FormatFooter(AExportFields: TExportFields): string;
begin
  Result := '</table>' + EOL
    + '</body>' + EOL
    + '</html>';
end;

{ TExportFormaterSQLSelect }

function TExportFormaterSQLSelect.FormatHeader(AExportFields: TExportFields;
  ADataSet: TDataSet): string;
begin
  Result := '';
end;

function TExportFormaterSQLSelect.FormatData(AExportFields: TExportFields;
  ADataSet: TDataset): string;
begin
  Result := 'SELECT ' + ImplodeFieldsData(AExportFields, ADataset, ', ', char('''')) + ' from RDB$DATABASE ' + ' union' + EOL;
end;

function TExportFormaterSQLSelect.FormatFooter(AExportFields: TExportFields): string;
begin
  Result := '';
end;

function TExportFormaterSQLSelect.PostProcess(AText: string): string;
begin
  Result := AText;
  SetLength(Result, Length(Result) - Length(' union' + EOL));
end;

{ TExportFormaterSQLInsert }

function TExportFormaterSQLInsert.FormatData(AExportFields: TExportFields;
  ADataSet: TDataset): string;
begin
  Result := FInsertSQLStr + 'values(' + ImplodeFieldsData(AExportFields, ADataset, ', ', char('''')) + ')' + EOL;
end;

procedure TExportFormaterSQLInsert.FormatInit(AExportFields: TExportFields; ADataSet: TDataSet);
var i: integer;
    RN, RN1, FN, FNList: string;
begin
  FInsertSQLStr := '';
  RN := '';
  FNList := '';
  for i := 0 to High(AExportFields) do
  begin
    FN := '';
    ParseFieldOrigin(ADataset.FieldByName(AExportFields[i].FieldName).Origin, RN1, FN);
    if FNList = '' then
      FNList := FN
    else
      FNList := FNList + ', ' + FN;

    if (RN <> '') and (RN1 <> RN) then
      RN := '<Неизвестная таблица>'
    else
      RN := RN1;
  end;
  FInsertSQLStr := 'insert into ' + RN + ' (' + FNList + ') ';
end;

{ TExportWriterFactory }

class function TExportWriterFactory.CreateWriter(AWriter: TExportWriter; AFilename: string = '';
  ASMTPKey: integer = -1; ARecipients: string = ''; ASubject: string = ''; ABody: string = '';
  AShowSendForm: boolean = false): IExportWriter;
begin
  case AWriter of
    ewrClipboard: begin
      result := TExportWriterClipboard.Create();
    end;
    ewrFile: begin
      result := TExportWriterTextFile.Create(AFilename);
    end;
    ewrEmail: begin
      result := TExportWriterEmail.Create(AFilename, ASMTPKey, ARecipients, ASubject, ABody, true);
    end;
    else begin
      Raise Exception.Create('Writer not found');
    end;
  end;

end;

{ TExportWriterClipboard }

constructor TExportWriterClipboard.Create();
begin
  Clipboard.Clear;
end;

procedure TExportWriterClipboard.Open;
begin
  Clipboard.Open;
end;

procedure TExportWriterClipboard.Close;
begin
  Clipboard.Close;
end;

procedure TExportWriterClipboard.SetBulkWriteMode(ABulkWriteMode: boolean);
begin
  //TODO: режим пакетной записи/сохранения
end;

procedure TExportWriterClipboard.WriteString(AString: String);
var
  txt: string;
  h:THandle;
begin
  txt := Clipboard.AsText;
  Clipboard.AsText := txt + AString;
  // помогает при проблемах с копированием русского текста из нерусской раскладки клавиатуры
  h := Clipboard.GetAsHandle(CF_TEXT);
  SetClipboardData(CF_LOCALE, h);
end;

{ TExportWriterTextFile }

constructor TExportWriterTextFile.Create(AFilename: TFileName);
begin
  FFileName := AFilename;
end;

procedure TExportWriterTextFile.Open;
begin
  AssignFile(FFileHandler, FFilename);
  try
    Rewrite(FFileHandler);
  except on E:EInOutError do begin
      MessageBox(0, PChar('Невозможно сохранить файл: ''' + FFilename + ''''), 'Экспорт данных', mb_Ok);
    end;
  end;
end;

procedure TExportWriterTextFile.Close;
begin
  if (TTextRec(FFileHandler).Mode <> fmClosed) then
    CloseFile(FFileHandler);
end;

destructor TExportWriterTextFile.Destroy;
begin
  Close;
  inherited Destroy;
end;

procedure TExportWriterTextFile.SetBulkWriteMode(ABulkWriteMode: boolean);
begin
//
end;

procedure TExportWriterTextFile.WriteString(AString: String);
begin
  Writeln(FFileHandler, AString);
end;

{ TExportWriterEMail }

constructor TExportWriterEMail.Create(AFilename: TFileName; ASMTPKey: integer;
  ARecipients, ASubject, ABody: string; AShowSendForm: boolean = false);
begin
  FFileName := AFilename;
  FSMTPKey := ASMTPKey;
  FRecipients := ARecipients;
  FSubject := ASubject;
  FBody := ABody;
  FShowSendForm := AShowSendForm;
end;


procedure TExportWriterEMail.Close;
begin
  if (TTextRec(FFileHandler).Mode <> fmClosed) then
    CloseFile(FFileHandler);

  SendEmailWithAttachment(FFilename,FSMTPKey, FRecipients, FSubject, FBody, FShowSendForm);
end;


destructor TExportWriterEMail.Destroy;
begin
  if (TTextRec(FFileHandler).Mode <> fmClosed) then
    CloseFile(FFileHandler);

  inherited destroy;
end;

procedure TExportWriterEMail.Open;
begin
  AssignFile(FFileHandler, FFilename);
  try
    Rewrite(FFileHandler);
  except on E:EInOutError do begin
      MessageBox(0, PChar('Невозможно сохранить файл: ''' + FFilename + ''''), 'Экспорт данных', mb_Ok);
    end;
  end;
end;

procedure TExportWriterEMail.WriteString(AString: String);
begin
  Writeln(FFileHandler, AString);
end;

procedure TExportWriterEMail.SetBulkWriteMode(ABulkWriteMode: boolean);
begin
//
end;

end.
