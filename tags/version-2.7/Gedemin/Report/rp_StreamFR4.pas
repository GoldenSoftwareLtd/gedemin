unit rp_StreamFR4;

interface

uses
  Classes, SysUtils, controls, FR_Class, rp_BaseReport_unit, DB,
  Forms, Printers, rp_i_ReportBuilder_unit, rp_StreamFR, frxVariables,
  rp_ErrorMsgFactory, frxDesgn, frxClass, frxDCtrl, frxChart,
  frxRich, frxBarcode, ImgList, ComCtrls, ExtCtrls, frxOLE,
  frxCross, frxDMPExport, frxExportImage, frxExportRTF, frxExportTXT,
  frxExportXML, frxExportXLS, frxExportHTML, frxGZip, frxExportPDF,
  frxChBox, frxExportText, frxExportCSV, frxExportMail,
  frxADOComponents, frxIBXComponents, frxCrypt, frxExportODF, frxPrinter,
  frxDBSet, frxPreview,
  gd_MultiStringList;

type
  Tfr4_ReportResult = class(TReportResult)
  private
    FMasterDetail: TFourStringList;
    FfrDataSetList: TStringList;
    FReportForm: TfrxReport;

    function GetfrDataSet(AnIndex: Integer): TfrxDBDataSet;
  public
    constructor Create;
    destructor Destroy; override;

    function AddDataSet(const AnName: String): Integer; override;
    procedure DeleteDataSet(const AnIndex: Integer); override;
    function frDataSetByName(const AnName: String): TfrxDBDataSet;
    procedure LoadFromStream(AnStream: TStream); override;
    procedure AddDataSetList(const AnBaseQueryList: Variant); override;

    property frDataSet[AnIndex: Integer]: TfrxDBDataSet read GetfrDataSet;
    property ReportForm: TfrxReport read FReportForm write FReportForm;
  end;

type

  Tgs_fr4Report = class(TfrxReport)
  private
    FReportResult: Tfr4_ReportResult;

    //Фильтры экспорта
    FrxPDFExport:  TfrxPDFExport;
    FrxHTMLExport: TfrxHTMLExport;
    FrxXLSExport:  TfrxXLSExport;
    FrxXMLExport:  TfrxXMLExport;
    FrxRTFExport:  TfrxRTFExport;
    FrxBMPExport:  TfrxBMPExport;
    FrxODSExport:  TfrxODSExport;
    FrxJPEGExport: TfrxJPEGExport;
    FrxGIFExport:  TfrxGIFExport;
    FrxTIFFExport: TfrxTIFFExport;
    FrxSimpleTextExport: TfrxSimpleTextExport;
    FrxCSVExport:  TfrxCSVExport;
    FrxMailExport: TfrxMailExport;
    FrxTXTExport:  TfrxTXTExport;
    FrxODTExport:  TfrxODTExport;
    FrxDMPExport:  TfrxDotMatrixExport;
    //

    procedure SetReportResult(Value: Tfr4_ReportResult);
    function GetReportDictionary: Tgs_frDataDictionary;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

//    procedure ShowPreparedReport; override;
    property UpdateDictionary: Tgs_frDataDictionary read GetReportDictionary;
    property ReportResult: Tfr4_ReportResult read FReportResult write SetReportResult;
  end;

type

  Tgs_fr4SingleReport = class(Tgs_fr4Report)
  public
//    procedure ShowPreparedReport; override;
  end;

  TFR4ReportInterface = class(TCustomReportBuilder)
  private
    Ffr4Report: Tgs_fr4Report;
    FErMsg: TClientEventThread;
    FTempParam: Variant;

    procedure DoTerminate(Sender: TObject);

    procedure SelfReportEvent(View: TfrxView; Button: TMouseButton; Shift: TShiftState; var Modified: Boolean);
    function FindReportComponent(const AnReport: Tgs_fr4Report): Boolean;
  protected
    procedure CreatePreviewForm; override;
    procedure AddParam(const AnName: String; const AnValue: Variant); override;

    function IsProcessed: Boolean; override;
    procedure BuildReport; override;
    procedure PrintReport; override;
    procedure ExportReport(const AnExportType: TExportType; const AnFileName: String); override;
    procedure Set_ReportResult(const AnReportResult: TReportResult); override;
    function Get_ReportResult: TReportResult; override;
    procedure Set_ReportTemplate(const AnReportTemplate: TReportTemplate); override;
    function Get_ReportTemplate: TReportTemplate; override;
    procedure Set_Params(const AnParams: Variant); override;
    function Get_Params: Variant; override;
    function Get_ModalPreview: Boolean; override;
    procedure Set_ModalPreview(const AnValue: Boolean); override;

  public
    constructor Create;
    destructor Destroy; override;
  end;

const
  cCategoryName = 'Входные параметры';

implementation

uses
  Gedemin_TLB, DBClient;

{ Tgs_fr4Report }

constructor Tgs_fr4Report.Create(AOwner: TComponent);
begin
  inherited;

  FReportResult := Tfr4_ReportResult.Create;
  FReportResult.ReportForm := Self;

  FrxPDFExport  := TfrxPDFExport.Create(Self);
  FrxHTMLExport := TfrxHTMLExport.Create(Self);
  FrxXLSExport  := TfrxXLSExport.Create(Self);
  FrxXMLExport  := TfrxXMLExport.Create(Self);
  FrxRTFExport  := TfrxRTFExport.Create(Self);
  FrxBMPExport  := TfrxBMPExport.Create(Self);
  FrxODSExport  := TfrxODSExport.Create(Self);
  FrxJPEGExport := TfrxJPEGExport.Create(Self);
  FrxGIFExport  := TfrxGIFExport.Create(Self);
  FrxTIFFExport := TfrxTIFFExport.Create(Self);
  FrxSimpleTextExport := TfrxSimpleTextExport.Create(Self);
  FrxCSVExport  := TfrxCSVExport.Create(Self);
  FrxMailExport := TfrxMailExport.Create(Self);
  FrxTXTExport  := TfrxTXTExport.Create(Self);
  FrxODTExport  := TfrxODTExport.Create(Self);
  FrxDMPExport  := TfrxDotMatrixExport.Create(Self);
end;

destructor Tgs_fr4Report.Destroy;
begin
  FReportResult.Free;

  FrxPDFExport.Free;
  FrxHTMLExport.Free;
  FrxXLSExport.Free;
  FrxXMLExport.Free;
  FrxRTFExport.Free;
  FrxBMPExport.Free;
  FrxODSExport.Free;
  FrxJPEGExport.Free;
  FrxGIFExport.Free;
  FrxTIFFExport.Free;
  FrxSimpleTextExport.Free;
  FrxCSVExport.Free;
  FrxMailExport.Free;
  FrxTXTExport.Free;
  FrxODTExport.Free;
  FrxDMPExport.Free;

  inherited;
end;

function Tgs_fr4Report.GetReportDictionary: Tgs_frDataDictionary;
begin
  Result := nil;
end;

procedure Tgs_fr4Report.SetReportResult(Value: Tfr4_ReportResult);
begin
  if Value <> nil then
    FReportResult.Assign(Value)
  else
    FReportResult.Clear;
end;

{ TFR4ReportInterface }

procedure TFR4ReportInterface.AddParam(const AnName: String;
  const AnValue: Variant);
begin
  Ffr4Report.Variables.AddVariable(cCategoryName, AnName, '''' + VarToStr(AnValue) + '''');
end;

procedure TFR4ReportInterface.BuildReport;
begin
  inherited BuildReport;

  try
    Ffr4Report.ShowReport;
    //Для поддержки потоков
    Application.ProcessMessages;
  except
    on E: Exception do
    begin
      FErMsg := TClientEventThread.Create(nil, True, False,
       'Произошла ошибка при построении отчета: ' + E.Message);
      FErMsg.OnTerminate := DoTerminate;
      FErMsg.Resume;
    end;
  end;

  if Assigned(FPreviewForm) and not FPreviewForm.Visible then
    FreeOldForm;
end;

constructor TFR4ReportInterface.Create;
begin
  inherited Create;

  Ffr4Report := Tgs_fr4Report.Create(Application);
  Ffr4Report.ShowProgress := False;
  Ffr4Report.PreviewOptions.Modal := False;
  //Для поддержки потоков
  Ffr4Report.EngineOptions.UseGlobalDataSetList := False;
  Ffr4Report.EnabledDataSets.Clear;

  Ffr4Report.OnClickObject := SelfReportEvent;
end;

procedure TFR4ReportInterface.CreatePreviewForm;
begin
  //Форма просмотра
  FPreviewForm := TfrxPreviewForm.Create(Application);
  {$IFDEF GEDEMIN}
  Ffr4Report.gsPreviewForm := FPreviewForm;
  {$ENDIF}

  inherited;
end;

destructor TFR4ReportInterface.Destroy;
begin
  if FindReportComponent(Ffr4Report) then
    FreeAndNil(Ffr4Report);

  if Assigned(FErMsg) then
  begin
    FErMsg.FreeOnTerminate := False;
    FErMsg.ClearTerminate;
    FErMsg.WaitFor;
    FErMsg.Free;
  end;

  inherited Destroy;
end;

procedure TFR4ReportInterface.DoTerminate(Sender: TObject);
begin
  FErMsg := nil;
end;

procedure TFR4ReportInterface.ExportReport(const AnExportType: TExportType;
  const AnFileName: String);
var
  FExportFilter: TfrxCustomExportFilter;
begin
  case AnExportType of
    etWord:
      FExportFilter := Ffr4Report.FrxRTFExport;

    etExcel:
      FExportFilter := Ffr4Report.FrxXLSExport;

    etXML:
      FExportFilter := Ffr4Report.FrxXMLExport;

    etPdf:
      FExportFilter := Ffr4Report.FrxPDFExport;
  else
    FExportFilter := nil;
  end;

  if Assigned(FExportFilter) then
  begin
    FExportFilter.FileName := AnFileName;
    FExportFilter.ShowDialog := False;
    try
      Ffr4Report.PrepareReport;
      //
//      Application.ProcessMessages;
      //
      try
        Ffr4Report.Export(FExportFilter);
      except
        raise; 
      end;
    finally
      FExportFilter.ShowDialog := True;
      FreeAndNil(FExportFilter);
    end;
  end;
end;

function TFR4ReportInterface.FindReportComponent(
  const AnReport: Tgs_fr4Report): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Application.ComponentCount - 1 do
  begin
    Result := Application.Components[I] = AnReport;
    if Result then
      Break;
  end;
end;

function TFR4ReportInterface.Get_Params: Variant;
begin
  Result := FTempParam;
end;

function TFR4ReportInterface.Get_ReportResult: TReportResult;
begin
  Result := Ffr4Report.ReportResult;
end;

function TFR4ReportInterface.Get_ReportTemplate: TReportTemplate;
begin
  Result := nil;
end;

function TFR4ReportInterface.IsProcessed: Boolean;
begin
  Result := inherited IsProcessed or Assigned(FErMsg);
end;

procedure TFR4ReportInterface.PrintReport;
begin
  try
    Ffr4Report.PrepareReport;
    if Preview then
      Ffr4Report.ShowPreparedReport
    else begin
      if PrinterName > '' then
        Ffr4Report.PrintOptions.Printer := PrinterName;
      Ffr4Report.PrintOptions.ShowDialog := False;
      Ffr4Report.PrintOptions.PageNumbers := '';
      Ffr4Report.PrintOptions.Copies := 1;
      Ffr4Report.PrintOptions.Collate := True;
      Ffr4Report.PrintOptions.PrintPages := ppAll;
      Ffr4Report.Print;
    end;
  except
    on E: Exception do
    begin
      FErMsg := TClientEventThread.Create(nil, True, False,
       'Произошла ошибка при построении отчета: ' + E.Message);
      FErMsg.OnTerminate := DoTerminate;
      FErMsg.Resume;
    end;
  end;
end;

procedure TFR4ReportInterface.SelfReportEvent(View: TfrxView; Button: TMouseButton; Shift: TShiftState; var Modified: Boolean);
var
  VarArray: Variant;
  LocResult: Boolean;
  TempVar: Variant;
begin
  if Assigned(FReportEvent) and (View is TfrxCustomMemoView) then
  begin
    VarArray := VarArrayCreate([0, 2], varVariant);
    VarArray[0] := FTempParam;
    TempVar := VarArrayCreate([0, 1], varVariant);
    TempVar[0] := (View as TfrxCustomMemoView).Memo.Text;
    TempVar[1] := View.TagStr;
    VarArray[1] := TempVar;
    VarArray[2] := View.Name;
    FReportEvent(VarArray, FEventFunction, LocResult);
    if LocResult then
      FreeAndNil(FPreviewForm);
  end;
end;

procedure TFR4ReportInterface.Set_Params(const AnParams: Variant);
begin
  inherited Set_Params(AnParams);

  FTempParam := AnParams;
end;

procedure TFR4ReportInterface.Set_ReportResult(
  const AnReportResult: TReportResult);
begin
  inherited;

end;

procedure TFR4ReportInterface.Set_ReportTemplate(
  const AnReportTemplate: TReportTemplate);
var
  OldPosition: Integer;
begin
  OldPosition := AnReportTemplate.Position;
  Ffr4Report.LoadFromStream(AnReportTemplate);
  AnReportTemplate.Position := OldPosition;

  Ffr4Report.Variables.Clear;
  Ffr4Report.Variables[' ' + cCategoryName] := Null;
end;

procedure TFR4ReportInterface.Set_ModalPreview(const AnValue: Boolean);
begin
  Ffr4Report.PreviewOptions.Modal := AnValue;
end;

function TFR4ReportInterface.Get_ModalPreview: Boolean;
begin
  Result := Ffr4Report.PreviewOptions.Modal;
end;

{ Tfr4_ReportResult }

function Tfr4_ReportResult.AddDataSet(const AnName: String): Integer;
var
  I: Integer;
begin
  Result := inherited AddDataSet(AnName);
  I := FfrDataSetList.AddObject(AnsiUpperCase(AnName), TfrxDBDataSet.Create(nil));
  Assert(Result = I);
  TfrxDBDataSet(FfrDataSetList.Objects[Result]).Name := FfrDataSetList.Strings[Result];
  TfrxDBDataSet(FfrDataSetList.Objects[Result]).DataSet := DataSet[Result];
end;

procedure Tfr4_ReportResult.AddDataSetList(const AnBaseQueryList: Variant);
var
  LocDispatch: IDispatch;
  LocReportResult: IgsQueryList;
  I, J, K: Integer;
  DS: TDataSet;
begin
  //Разбираем BaseQueryList и добавляем его в Fast Report
  LocDispatch := AnBaseQueryList;
  LocReportResult := LocDispatch as IgsQueryList;
  QueryList := LocReportResult;
  for J := 0 to LocReportResult.Count - 1 do
  begin
    DS := TDataSet(LocReportResult.Query[J].Get_Self);
    K := inherited AddDataSet(DS.Name, DS);
    I := FfrDataSetList.AddObject(AnsiUpperCase(DS.Name), TfrxDBDataSet.Create(nil));
    Assert(K = I);
    TfrxDBDataSet(FfrDataSetList.Objects[K]).Name := FfrDataSetList.Strings[K];
    TfrxDBDataSet(FfrDataSetList.Objects[K]).DataSet := DS;
  end;

  for I := 0 to FfrDataSetList.Count - 1 do
  begin
    ReportForm.DataSets.Add(TfrxDBDataSet(FfrDataSetList.Objects[I]));
    ReportForm.EnabledDataSets.Add(TfrxDBDataSet(FfrDataSetList.Objects[I]));
  end;  
end;

constructor Tfr4_ReportResult.Create;
begin
  inherited Create;

  FfrDataSetList := TStringList.Create;
  FfrDataSetList.Sorted := True;
  FMasterDetail := TFourStringList.Create;
end;

procedure Tfr4_ReportResult.DeleteDataSet(const AnIndex: Integer);
begin
  inherited;

  Assert((AnIndex >= 0) and (AnIndex < FfrDataSetList.Count));
  TfrxDBDataSet(FfrDataSetList.Objects[AnIndex]).Free;
  FfrDataSetList.Delete(AnIndex);
  Assert(FfrDataSetList.Count = Count);
end;

destructor Tfr4_ReportResult.Destroy;
begin
  Clear;

  inherited Destroy;

  FreeAndNil(FfrDataSetList);
  FreeAndNil(FMasterDetail);  
end;

function Tfr4_ReportResult.frDataSetByName(
  const AnName: String): TfrxDBDataSet;
var
  I: Integer;
begin
  Result := nil;
  if FfrDataSetList.Find(AnName, I) then
    Result := frDataSet[I];
end;

function Tfr4_ReportResult.GetfrDataSet(AnIndex: Integer): TfrxDBDataSet;
begin
  Assert((AnIndex >= 0) and (AnIndex < FfrDataSetList.Count));
  Result := TfrxDBDataSet(FfrDataSetList.Objects[AnIndex]);
end;

procedure Tfr4_ReportResult.LoadFromStream(AnStream: TStream);
var
  I, J, LocCount, LocSize: Integer;
  SName: String;
  TempStream: TMemoryStream;
  LocMasterDetail: TFourStringList;
  PrefixData: array[0..2] of Char;
  IndexSL: TStringList;
  TempDataSet: TClientDataSet;
begin
  Clear;
  AnStream.Position := 0;
  if AnStream.Position >= AnStream.Size then
    Exit;
  AnStream.ReadBuffer(LocCount, SizeOf(LocCount));
  TempStream := TMemoryStream.Create;
  try
    for I := 0 to LocCount - 1 do
    begin
      AnStream.ReadBuffer(LocSize, SizeOf(LocSize));
      SetLength(SName, LocSize);
      AnStream.ReadBuffer(SName[1], LocSize);
      J := AddDataSet(SName);
      AnStream.ReadBuffer(LocSize, SizeOf(LocSize));
      TempStream.Clear;
      TempStream.Size := LocSize;
      AnStream.ReadBuffer(TempStream.Memory^, LocSize);
      if TempStream.Size <> 0 then
        TClientDataSet(DataSet[J]).LoadFromStream(TempStream);
    end;
  finally
    TempStream.Free;
  end;

  FMasterDetail.Clear;
  if AnStream.Position < AnStream.Size then
  begin
    AnStream.ReadBuffer(PrefixData, SizeOf(MDPrefix));
    if PrefixData = MDPrefix then
    begin
      LocMasterDetail := TFourStringList.Create;
      try
        LocMasterDetail.LoadFromStream(AnStream);
        for I := 0 to LocMasterDetail.Count - 1 do
          AddMasterDetail(LocMasterDetail.MasterTable[I], LocMasterDetail.MasterField[I],
           LocMasterDetail.DetailTable[I], LocMasterDetail.DetailField[I]);
      finally
        LocMasterDetail.Free;
      end;
      if AnStream.Position < AnStream.Size then
        AnStream.ReadBuffer(PrefixData, SizeOf(IndexPrefix));
    end;

    if PrefixData = IndexPrefix then
    begin
      IndexSL := TStringList.Create;
      try
        IndexSL.LoadFromStream(AnStream);
        for I := 0 to IndexSL.Count - 1 do
        begin
          TempDataSet := (DataSetByName(IndexSL.Names[I]) as TClientDataSet);
          if TempDataSet <> nil then
            TempDataSet.IndexFieldNames := IndexSL.Values[IndexSL.Names[I]];
        end;
      finally
        IndexSL.Free;
      end;
    end;
  end;

  for I := 0 to FfrDataSetList.Count - 1 do
  begin
    ReportForm.DataSets.Add(TfrxDBDataSet(FfrDataSetList.Objects[I]));
    ReportForm.EnabledDataSets.Add(TfrxDBDataSet(FfrDataSetList.Objects[I]));
  end;
end;

initialization
  RegisterClass(Tgs_fr4SingleReport);

finalization
  UnRegisterClass(Tgs_fr4SingleReport);

end.
