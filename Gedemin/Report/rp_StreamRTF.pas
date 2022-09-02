// ShlTanya, 27.02.2019

unit rp_StreamRTF;

interface

uses
  xReport, rp_BaseReport_unit, Dialogs, gsMultilingualSupport, Classes, DB, SysUtils,
  Forms, xRepPrvF, rp_i_ReportBuilder_unit;

type
  TxReportStream = class(TxReport)
  private
    FReportResult: TReportResult;
    FReportTemplate: TReportTemplate;

    procedure SetReportResult(const AnValue: TReportResult);
    procedure SetReportTemplate(const AnValue: TReportTemplate);
  protected
    function CreateOutputFile: Boolean; override;
    procedure SendTable(Index: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property ReportResult: TReportResult read FReportResult write SetReportResult;
    property ReportTemplate: TReportTemplate read FReportTemplate write SetReportTemplate;
  end;

type
  PxReportPreviewForm = ^TxReportPreviewForm;

  TxReportStreamThread = class(TxReportStream)
  private
    FPreviewForm: PxReportPreviewForm;
  protected
    procedure PreviewReport; override;
  end;

  TRTFReportInterface = class(TCustomReportBuilder)
  private
    FReportStream: TxReportStreamThread;
  protected
    procedure CreatePreviewForm; override;
    procedure AddParam(const AnName: String; const AnValue: Variant); override;

    procedure BuildReport; override;
    procedure PrintReport; override;
    procedure Set_ReportResult(const AnReportResult: TReportResult); override;
    function Get_ReportResult: TReportResult; override;
    procedure Set_ReportTemplate(const AnReportTemplate: TReportTemplate); override;
    function Get_ReportTemplate: TReportTemplate; override;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  xRTF, Windows;

constructor TxReportStream.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FCheckFileExsist := False;

  FReportResult := TReportResult.Create;
  FReportTemplate := TReportTemplate.Create;
end;

destructor TxReportStream.Destroy;
begin
  FReportResult.Free;
  FReportTemplate.Free;

  inherited Destroy;
end;

procedure TxReportStream.SetReportResult(const AnValue: TReportResult);
begin
  if AnValue <> nil then
    FReportResult.Assign(AnValue)
  else
    FReportResult.Clear;
end;

procedure TxReportStream.SetReportTemplate(const AnValue: TReportTemplate);
begin
  if AnValue <> nil then
    FReportTemplate.Assign(AnValue)
  else
    FReportTemplate.Clear;
end;

function TxReportStream.CreateOutputFile: Boolean;
var
  TI: Integer;
  i: Integer;
begin
  Result := false; { was not created }

  if FReportTemplate = nil then
  begin
    MessageDlg(TranslateText('Не задан поток шаблона.'), mtWarning, [mbOk], 0);
    exit;
  end;

  if not RTFFile.LoadRTFFromStream(FReportTemplate) then
   begin
     if frMsgIfTerminated in FOptions then  {Здесь использовалось Phrases[lnNotCreated]}
       MessageDlg(TranslateText('Отчет не был создан вероятно из-за прерывания пользователем.'), mtInformation, [mbOk], 0);
     exit;
   end;

  for TI := 0 to RTFFile.LocDefs.Count - 1 do
   begin
     if TxDef(RTFFile.LocDefs[TI]).TableHeader <> nil then
      begin
        for i := 0 to TxDef(RTFFile.LocDefs[TI]).TableHeader.Count - 1 do
          if TxDef(RTFFile.LocDefs[TI]).TableHeader.Items[i] is TxRTFTableRow then
            (TxDef(RTFFile.LocDefs[TI]).TableHeader.Items[i] as TxRTFTableRow).IsHeader := true;
      end;
   end;

  RTFOut.AssignFormat(RTFFile);
  RTFOut.CopyHeaderFooter(RTFFile);

  if Destination = dsFile then
    RTFOut.WriteRTFHeader(RTFOutputFile);

  Result := true;
end;

procedure TxReportStream.SendTable(Index: Integer);
var
  BookMark: TBookmark;
  TheTableIndex: Integer;
begin
  if FReportResult = nil then
  begin
    MessageDlg(TranslateText('Не задан поток данных.'), mtWarning, [mbOk], 0);
    exit;
  end;

  Bookmark := nil; // Delphi is fucker

  { fix current table }
  TableIndex := Index;
  CurrentTableDef := TxDef(RTFFile.LocDefs[TableIndex]);

  PrepareSummedFields;

  TheTableIndex := FReportResult.IndexOf(AnsiUpperCase(TxDef(RTFFile.LocDefs[Index]).TableName));

  try
    { find data source for current table }
    if TheTableIndex <> -1 then
    begin
      FDataSource := TDataSource.Create(Self);
      FDataSource.DataSet := FReportResult.DataSet[TheTableIndex];
      if frAlwaysOpenDataSet in FOptions then
        FDataSource.DataSet.Open;

       { proceed with the data }
      Bookmark := FDataSource.DataSet.GetBookmark;
      FDataSource.DataSet.DisableControls;
    end else
      if FDataSource <> nil then
        FreeAndNil(FDataSource);

    try
      if (FDataSource <> nil) and not(frSingleRecord in FOptions) then
        FDataSource.DataSet.First;

      AddTableStart;

      if (FDataSource = nil) or
         ((FDataSource <> nil) and not(FDataSource.DataSet.EOF)) then
       begin
         if CurrentTableDef.Groups <> nil then
           AddGroupHeader(-1);

         AddTableHeader;

         SendData;

         if CurrentTableDef.Groups <> nil then
           AddGroupEnd(-1);
       end;

      AddTableEnd;

    finally
      if FDataSource <> nil then
       begin
         FDataSource.DataSet.GotoBookmark(Bookmark);
         FDataSource.DataSet.EnableControls;
         FDataSource.DataSet.FreeBookmark(Bookmark);
       end;
    end;
  finally
    if FDataSource <> nil then
      FreeAndNil(FDataSource);
  end;
  TableIndex := -1;
end;

// TxReportStreamThread

procedure TxReportStreamThread.PreviewReport;
begin
  Assert((FPreviewForm <> nil) and (FPreviewForm^ <> nil), 'FPreviewForm not assigned.');
  FPreviewForm^.Viewer.ExchangeData(RTFOut);
  if Caption > '' then
    FPreviewForm^.Caption := Format(Caption, [RealFormFileName])
  else
    FPreviewForm^.Caption := TranslateText('Отчет по файлу ') + RealFormFileName;
  FPreviewForm^.SourceFileName := RealFormFileName;
  FPreviewForm^.Show;
end;

// TRTFReportInterface

constructor TRTFReportInterface.Create;
begin
  inherited Create;

  FReportStream := TxReportStreamThread.Create(nil);
  FReportStream.FPreviewForm := @FPreviewForm;
end;

destructor TRTFReportInterface.Destroy;
begin
  FreeAndNil(FReportStream);

  inherited Destroy;
end;

procedure TRTFReportInterface.BuildReport;
begin
  inherited BuildReport;

  FReportStream.Destination := xReport.dsScreen;
  FReportStream.Execute;
  if not FPreviewForm.Visible then
    FreeOldForm;
end;

procedure TRTFReportInterface.Set_ReportResult(const AnReportResult: TReportResult);
begin
  if Assigned(AnReportResult) then
    FReportStream.ReportResult.Assign(AnReportResult)
  else
    FReportStream.ReportResult.Clear;
end;

function TRTFReportInterface.Get_ReportResult: TReportResult;
begin
  Result := FReportStream.ReportResult;
end;

procedure TRTFReportInterface.Set_ReportTemplate(const AnReportTemplate: TReportTemplate);
begin
  if Assigned(AnReportTemplate) then
    FReportStream.ReportTemplate.Assign(AnReportTemplate)
  else
    FReportStream.ReportTemplate.Clear;
end;

function TRTFReportInterface.Get_ReportTemplate: TReportTemplate;
begin
  Result := FReportStream.ReportTemplate;
end;

procedure TRTFReportInterface.AddParam(const AnName: String; const AnValue: Variant);
begin
  try
    FReportStream.Vars.Add(AnName + '=' + VarAsType(AnValue, varString));
  except
  end;
end;

procedure TRTFReportInterface.CreatePreviewForm;
begin
  FPreviewForm := TxReportPreviewForm.Create(Application);
end;

procedure TRTFReportInterface.PrintReport;
begin
  inherited BuildReport;

  FReportStream.Destination := xReport.dsPrinter;
  FReportStream.Execute;
  if Assigned(FPreviewForm) and not FPreviewForm.Visible then
    FreeOldForm;
end;

end.
