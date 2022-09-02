// ShlTanya, 27.02.2019

unit rp_StreamXFR;

interface

uses
  xFReport, rp_BaseReport_unit, Dialogs, {gsMultilingualSupport, }Classes, DB, SysUtils,
  Forms, rp_i_ReportBuilder_unit, Printers,
  {$IFDEF GEDEMIN}
  xFRepView_unit,
  {$ELSE}
  xFRepVw,
  {$ENDIF}
  rp_ErrorMsgFactory;

type
  TxFastReportStream = class(TxFastReport)
  private
    FReportResult: TReportResult;
    FReportTemplate: TReportTemplate;
    FDS: TDataSource;

    procedure SetReportResult(const AnValue: TReportResult);
    procedure SetReportTemplate(const AnValue: TReportTemplate);
  protected
    procedure LoadFromStream(Stream: TStream); override;
    procedure Prepare; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property ReportResult: TReportResult read FReportResult write SetReportResult;
    property ReportTemplate: TReportTemplate read FReportTemplate write SetReportTemplate;
  end;

type
  {$IFDEF GEDEMIN}
  PxReportView = ^TxFRepView;
  {$ELSE}
  PxReportView = ^TxReportView;
  {$ENDIF}

  TxFastReportStreamThread = class(TxFastReportStream)
  private
    FPreviewForm: PxReportView;
  protected
    procedure PreviewReport; override;
  end;

  TXFRReportInterface = class(TCustomReportBuilder)
  private
    FReportStream: TxFastReportStreamThread;
    FErMsg: TClientEventThread;

    procedure DoTerminate(Sender: TObject);
    procedure PassThroughFile(const FileName: String);
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
  Windows;

const
  cTempFileName = 'temp.xfr';

constructor TxFastReportStream.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FDS := TDataSource.Create(Self);
  DataSource := FDS;
  FReportResult := TReportResult.Create;
  FReportResult.Sorted := False;
  FReportTemplate := TReportTemplate.Create;
  LinesOnPage := 10000;
end;

destructor TxFastReportStream.Destroy;
begin
  FReportResult.Free;
  FReportTemplate.Free;
  FDS.Free;

  inherited Destroy;
end;

procedure TxFastReportStream.Prepare;
begin
  if FReportResult.Count <> 0 then
    FDS.DataSet := FReportResult.DataSet[0]
  else
    FDS.DataSet := nil;
end;

procedure TxFastReportStream.LoadFromStream(Stream: TStream);
begin
  Stream.CopyFrom(FReportTemplate, 0);
  Stream.Position := 0;
end;

procedure TxFastReportStream.SetReportResult(const AnValue: TReportResult);
begin
  if AnValue <> nil then
  begin
    FReportResult.Assign(AnValue);
    if FReportResult.Count <> 0 then
      FDS.DataSet := FReportResult.DataSet[0];
  end
  else
  begin
    FReportResult.Clear;
    FDS.DataSet := nil;
  end;
end;

procedure TxFastReportStream.SetReportTemplate(const AnValue: TReportTemplate);
begin
  if AnValue <> nil then
    FReportTemplate.Assign(AnValue)
  else
    FReportTemplate.Clear;
end;

// TxFastReportStreamThread

procedure TxFastReportStreamThread.PreviewReport;
begin
  Preview(FPreviewForm^);
  FPreviewForm^.Show;
end;

// TXFRReportInterface

constructor TXFRReportInterface.Create;
begin
  inherited Create;

  FReportStream := TxFastReportStreamThread.Create(nil);
  FReportStream.FPreviewForm := @FPreviewForm;
end;

destructor TXFRReportInterface.Destroy;
begin
  FreeAndNil(FReportStream);

  inherited Destroy;
end;

procedure TXFRReportInterface.BuildReport;
begin
  inherited BuildReport;

  {if FReportStream.DataSource = nil then
  begin
    MessageBox(0,
      'Не подключен DataSource.',
      'Ошибка',
      MB_OK or MB_ICONHAND or MB_TASKMODAL);
    exit;
  end;

  if FReportStream.DataSource.DataSet = nil then
  begin
    MessageBox(0,
      'Не подключен DataSet.',
      'Ошибка',
      MB_OK or MB_ICONHAND or MB_TASKMODAL);
    exit;
  end;  }

  try
    FReportStream.Options := FReportStream.Options + [frShowPreview];
    FReportStream.Execute;
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

procedure TXFRReportInterface.Set_ReportResult(const AnReportResult: TReportResult);
begin
  if Assigned(AnReportResult) then
    FReportStream.ReportResult.Assign(AnReportResult)
  else
    FReportStream.ReportResult.Clear;
end;

function TXFRReportInterface.Get_ReportResult: TReportResult;
begin
  Result := FReportStream.ReportResult;
end;

procedure TXFRReportInterface.Set_ReportTemplate(const AnReportTemplate: TReportTemplate);
begin
  if Assigned(AnReportTemplate) then
    FReportStream.ReportTemplate.Assign(AnReportTemplate)
  else
    FReportStream.ReportTemplate.Clear;
end;

function TXFRReportInterface.Get_ReportTemplate: TReportTemplate;
begin
  Result := FReportStream.ReportTemplate;
end;

procedure TXFRReportInterface.AddParam(const AnName: String; const AnValue: Variant);
begin
  try
    FReportStream.Vars.Add(AnName + '=' + VarAsType(AnValue, varString));
  except
  end;
end;

procedure TXFRReportInterface.CreatePreviewForm;
begin
  {$IFDEF GEDEMIN}
  FPreviewForm := TxFRepView.Create(Application);
  TxFRepView(FPreviewForm).isPrint := True;
  {$ELSE}
  FPreviewForm := TxReportView.Create(Application);
  TxReportView(FPreviewForm).isPrint := True;
  {$ENDIF}
  inherited;
end;

procedure TXFRReportInterface.DoTerminate(Sender: TObject);
begin
  try
    FErMsg := nil;
  except
  end;
end;


procedure TXFRReportInterface.PrintReport;
begin
  try
    FReportStream.Options := FReportStream.Options - [frShowPreview];
    if PrinterName > '' then begin
      if Assigned(Printer.Printers) then begin
        if Printer.Printers.IndexOf(PrinterName) < 0 then
          raise Exception.Create('Принтер "' + PrinterName + '" не доступен.');
        Printer.PrinterIndex := Printer.Printers.IndexOf(PrinterName);
      end;
    end;
    FReportStream.Destination:= dsFile;
    FReportStream.OutputFile:= ExtractFilePath(Application.ExeName)+ cTempFileName;
    FReportStream.Execute;
    PassThroughFile(cTempFileName);
{    if FileExists(cTempFileName) then
      DeleteFile(cTempFileName);}
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

procedure TXFRReportInterface.PassThroughFile(const FileName: String);
type
  PR = ^TR;
  TR = record
    Size: Word;
    Data: array[0..0] of Char;
  end;

var
  F: File;
  F1, F2: Text;
  P: PR;
  S, S1: String;
  FileCount: Integer;
  Flag : Boolean;
  I, LastPos: Integer;
  tp: String;

begin
  tp := ExtractFilePath(Application.ExeName);

  AssignFile(F1, tp + FileName);

  Reset(F1);
  FileCount := 1;
  AssignFile(F2, tp + 'Page' + IntToStr(FileCount) + '.xfr');
  Rewrite(F2);
  LastPos := 1;
  while not EOF(F1) do
  begin
    ReadLn(F1, S);
    S1 := '';
    Flag := False;

    I := 1;
    while (I <= Length(S)) and (not Flag) do
    begin
      if S[I] <> Chr(12) then
        S1 := S1 + S[I]
      else
      begin
        Flag := true;
        LastPos := I;
      end;
      Inc(I);
    end;

    if Flag then
    begin
      WriteLn(F2, S1);
      CloseFile(F2);
      Inc(FileCount);
      AssignFile(F2, tp + 'Page' + IntToStr(FileCount) + '.xfr');
      Rewrite(F2);
      for I := LastPos to Length(S) do
      begin
        if S[I] <> Chr(12) then
          S1 := S1 + S[I] ;
      end;
      WriteLn(F2, S1);
    end
    else
      WriteLn(F2, S1);
  end;
  CloseFile(F2);
  CloseFile(F1);

  For I := 1 to FileCount do
  begin
    AssignFile(F, tp + 'Page' + IntToStr(I) + '.xfr');
    Reset(F, 1);
    try
      GetMem(P, FileSize(F) + SizeOf(Word));
      try
        P^.Size := FileSize(F);
        BlockRead(F, P^.Data, P^.Size);
        AnsiToOemBuff(@(P^.Data), @(P^.Data), P^.Size);
        Printer.BeginDoc;
        Escape(Printer.Handle, PASSTHROUGH, 0, Pointer(P), nil);
        Printer.EndDoc;
      finally
        FreeMem(P, P^.Size + SizeOf(Word));
      end;
    finally
      CloseFile(F);
    end;
    if I < FileCount then
      Application.MessageBox('Вставте следующую страницу', 'Внимание', MB_OK + MB_SYSTEMMODAL);
  end
end; 

end.
