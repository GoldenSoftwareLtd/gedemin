unit rp_StreamFR;

interface

uses
  Classes, SysUtils, FR_Class, rp_BaseReport_unit, DB, DBClient, FR_DBSet,
  FR_DBRel, Forms, Printers, rp_i_ReportBuilder_unit, FR_View, FR_DSet,
  rp_ErrorMsgFactory, rp_fr_view_unit;

type
  Tfr_ReportResult = class(TReportResult)
  private
    FfrDataSetList: TStringList;

    function GetfrDataSet(AnIndex: Integer): TfrDBDataSet;
  public
    constructor Create;
    destructor Destroy; override;

    function AddDataSet(const AnName: String): Integer; override;
    procedure DeleteDataSet(const AnIndex: Integer); override;
    property frDataSet[AnIndex: Integer]: TfrDBDataSet read GetfrDataSet;
    function frDataSetByName(const AnName: String): TfrDBDataSet;
    procedure AddDataSetList(const AnBaseQueryList: Variant); override;
  end;

type
  Tgs_frDataDictionary = class(TfrDataDictionary)
  private
    FReportResult: Tfr_ReportResult;

    procedure SetReportResult(Value: Tfr_ReportResult);
    procedure GetDataSetAndField(ComplexName: String;
      var DataSet: TfrTDataSet; var Field: String);
  public
    procedure GetDatasetList(List: TStrings); override;
    procedure GetFieldList(DSName: String; List: TStrings); override;
    procedure GetBandDatasourceList(List: TStrings); override;
    function IsVariable(VarName: String): Boolean; override;
    procedure LoadFromStream(Stream: TStream); override;
    function gsGetDataSet(ComplexName: String): TfrTDataSet; override;

    constructor Create;
    destructor Destroy; override;

    property ReportResult: Tfr_ReportResult read FReportResult write SetReportResult;
  end;

type
  PfrPreviewForm = ^TfrPreviewForm;

  Tgs_frReport = class(TfrReport)
  private
    function GetReportDictionary: Tgs_frDataDictionary;
  protected
    FfrPreviewForm: PfrPreviewForm;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure ShowPreparedReport; override;
    property UpdateDictionary: Tgs_frDataDictionary read GetReportDictionary;
  end;

type
  Tgs_frSingleReport = class(Tgs_frReport)
  public
    procedure ShowPreparedReport; override;
  end;

type
  Tgs_frBand = class(TfrBand)
  private
    FfrReport: Tgs_frReport;
  protected
    procedure InitDataSet(Desc: String); override;
  public
    constructor Create(ATyp: TfrBandType; AParent: TfrPage; AReport: Tgs_frReport);
  end;

  Tgs_frPage = class(TfrPage)
  private
    FfrReport: Tgs_frReport;
  protected
    function CreateBand(ATyp: TfrBandType; AParent: TfrPage): TfrBand; override;
    procedure gsGetDataSetandField(ComplexName: String; var DataSet: TfrTDataSet;
     var Field: String); override;
    procedure SelfCreateDS(Desc: String; var DataSet: TfrDataSet; var IsVirtualDS: Boolean); override;
  public
    property frReport: Tgs_frReport read FfrReport write FfrReport;
  end;

  Tgs_frPages = class(TfrPages)
  public
    procedure Add; override;
  end;

  Tgs_frEMFPages = class(TfrEMFPages)
  protected
    function CreateNewPage(ASize, AWidth, AHeight, ABin: Integer;
      AOr: TPrinterOrientation): TfrPage; override;
  end;

  Tgs_frPreviewForm = class(Trp_fr_view)
  public
    procedure Connect(ADoc: Pointer); override;
  end;

  TFRReportInterface = class(TCustomReportBuilder)
  private
    FfrReport: Tgs_frReport;
    FErMsg: TClientEventThread;
    FTempParam: Variant;

    procedure DoTerminate(Sender: TObject);
    procedure SelfReportEvent(View: TfrView);
    function FindReportComponent(const AnReport: Tgs_frReport): Boolean;
  protected
    procedure CreatePreviewForm; override;
    procedure AddParam(const AnName: String; const AnValue: Variant); override;

    function IsProcessed: Boolean; override;
    procedure BuildReport; override;
    procedure PrintReport; override;
    procedure Set_ReportResult(const AnReportResult: TReportResult); override;
    function Get_ReportResult: TReportResult; override;
    procedure Set_ReportTemplate(const AnReportTemplate: TReportTemplate); override;
    function Get_ReportTemplate: TReportTemplate; override;
    procedure Set_Params(const AnParams: Variant); override;
    function Get_Params: Variant; override;
  public
    constructor Create;
    destructor Destroy; override;
  end;

procedure rpCreateDS(Desc: String; var DataSet: TfrDataSet; var IsVirtualDS: Boolean;
 AnReport: Tgs_frReport);

implementation

uses
  FR_Utils, FR_Prntr, FR_Const, FR_Pars, Windows, Gedemin_TLB, prp_methods;

constructor Tgs_frDataDictionary.Create;
begin
  inherited Create;

  FReportResult := Tfr_ReportResult.Create;
end;

destructor Tgs_frDataDictionary.Destroy;
begin
  FreeAndNil(FReportResult);

  inherited Destroy;
end;

procedure Tgs_frDataDictionary.GetBandDatasourceList(List: TStrings);
var
  I: Integer;
begin
  List.Clear;
  for I := 0 to FReportResult.Count - 1 do
    List.Add(FReportResult.frDataSet[I].Name);
end;

procedure Tgs_frDataDictionary.GetDatasetList(List: TStrings);
var
  I: Integer;
begin
  List.Clear;
  for I := 0 to FReportResult.Count - 1 do
    List.Add(FReportResult.DataSet[I].Name);
end;
                                          
procedure Tgs_frDataDictionary.GetFieldList(DSName: String; List: TStrings);
var
  DS: TDataSet;
  I: Integer;
begin
  List.Clear;
  DS := FReportResult.DataSetByName(DSName);
  if DS <> nil then
    for I := 0 to DS.FieldCount - 1 do
    List.Add(DS.Fields[I].FieldName);
end;

procedure Tgs_frDataDictionary.GetDataSetAndField(ComplexName: String; var DataSet: TfrTDataSet;
  var Field: String);
var
  i, j, n: Integer;
  sl: TStringList;
  s: String;
  c: Char;

  function FindField(ds: TfrTDataSet; FName: String): String;
  var
    sl: TStringList;
  begin
    Result := '';
    if ds <> nil then
    begin
      sl := TStringList.Create;
      frGetFieldNames(ds, sl);
      if sl.IndexOf(FName) <> -1 then
        Result := FName;
      sl.Free;
    end;
  end;

begin
  Field := '';
  sl := TStringList.Create;
  try

    n := 0; j := 1;
    for i := 1 to Length(ComplexName) do
    begin
      c := ComplexName[i];
      if c = '"' then
      begin
        sl.Add(Copy(ComplexName, i, 255));
        j := i;
        break;
      end
      else if c = '.' then
      begin
        sl.Add(Copy(ComplexName, j, i - j));
        j := i + 1;
        Inc(n);
      end;
    end;
    if j <> i then
      sl.Add(Copy(ComplexName, j, 255));

    if n = sl.Count then
      Exit;

    case n of
      0: // field name only
        begin
          if DataSet <> nil then
          begin
            s := frRemoveQuotes(ComplexName);
            Field := FindField(DataSet, s);
          end;
        end;
      1, 2, 3: // DatasetName.FieldName
        begin
          DataSet := TfrTDataSet(FReportResult.DataSetByName(sl[n - 1]));
          s := frRemoveQuotes(sl[n]);
          Field := FindField(DataSet, s);
        end;
    end;

  finally
    sl.Free;
  end;
end;

function Tgs_frDataDictionary.IsVariable(VarName: String): Boolean;
var
  i: Integer;
  s, s1, s2: String;
  F: String;
  DSet: TfrTDataSet;
  v: Variant;

  function RealFieldName(DataSetName, FieldName: String): String;
  var
    i: Integer;
    s: String;
  begin
    Result := FieldName;
    for i := 0 to FieldAliases.Count - 1 do
      if AnsiCompareText(FieldAliases.Value[i], FieldName) = 0 then
        if Pos(DataSetName, FieldAliases.Name[i]) = 1 then
        begin
          Result := FieldAliases.Name[i];
          ExtractFieldName(Result, s, Result);
          break;
        end;
  end;

begin
  if Cache.Find(VarName, i) then
    Result := True
  else
  begin
    Result := Variables.IndexOf(VarName) <> -1;
    if Result then
    begin
      v := Variables[VarName];
      if v <> Null then
      begin
        s := v;
        if Pos('.', s) <> 0 then
        begin
          DSet := GetDefaultDataset;
          GetDatasetAndField(s, DSet, F);
          if F > '' then
          begin
            AddCacheItem(VarName, DSet, F);
            Cache.Sort;
          end;
        end;
      end;
    end;
  end;

  if not Result then
  begin
    if Pos('.', VarName) <> 0 then
    begin
      ExtractFieldName(VarName, s1, s2);
      s := RealDataSetName[s1];
      if s <> s1 then
        s1 := s;
      s := s1 + '."' + RealFieldName(s1, s2) + '"';
    end
    else
      s := VarName;
    DSet := GetDefaultDataset;
    GetDatasetAndField(s, DSet, F);
    if F > '' then
    begin
      AddCacheItem(VarName, DSet, F);
      Cache.Sort;
      Result := True;
    end;
  end;
end;

procedure Tgs_frDataDictionary.SetReportResult(Value: Tfr_ReportResult);
begin
  if Value <> nil then
    FReportResult.Assign(Value)
  else
    FReportResult.Clear;
end;

{ Tgs_frReport }

constructor Tgs_frReport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  if Assigned(Dictionary) then
    Dictionary.Free;
  Dictionary := Tgs_frDataDictionary.Create;

  if Assigned(Pages) then
    Pages.Free;
  Pages := Tgs_frPages.Create(Self);

  if Assigned(EMFPages) then
    EMFPages.Free;
  EMFPages := Tgs_frEMFPages.Create(Self);
end;

destructor Tgs_frReport.Destroy;
begin

  inherited Destroy;
end;

function Tgs_frReport.GetReportDictionary: Tgs_frDataDictionary;
begin
  Result := Dictionary as Tgs_frDataDictionary;
end;

procedure Tgs_frReport.ShowPreparedReport;
var
  s: String;
begin
  if Application.Terminated then
    exit;
  Assert((FfrPreviewForm <> nil) and (FfrPreviewForm^ <> nil),
    'FfrForm not assigned');
  CurReport := Self;
  MasterReport := Self;
  DocMode := dmPrinting;
  CurBand := nil;
  if EMFPages.Count = 0 then Exit;
  s := frLoadStr(SPreview);
  if Title > '' then s := s + ' - ' + Title;
  if not (csDesigning in ComponentState) and Assigned(Preview) then
    Preview.Connect(Self)
  else
  begin
    if MDIPreview then
    begin
      FfrPreviewForm^.WindowState := Forms.wsNormal;
      FfrPreviewForm^.FormStyle := Forms.fsMDIChild;
    end;
    FfrPreviewForm^.Show_Modal(Self);
    Application.ProcessMessages;
  end;
end;

function Tgs_frDataDictionary.gsGetDataSet(ComplexName: String): TfrTDataSet;
var
  n: Integer;
  s1, s2: String;
begin
  n := Pos('.', ComplexName);
  try
    if n = 0 then
      Result := TfrTDataSet(FReportResult.DataSetByName(ComplexName))
    else
    begin
      s1 := Copy(ComplexName, 1, n - 1);        // module name
      s2 := Copy(ComplexName, n + 1, 255);      // component name
      n := Pos('.', s2);
      if n <> 0 then        // frame name - Delphi5
      begin
        s1 := Copy(s2, 1, n - 1);
        s2 := Copy(s2, n + 1, 255);
        Result := TfrTDataSet(FReportResult.DataSetByName(s2));
      end
      else
        Result := TfrTDataSet(FReportResult.DataSetByName(s2));
    end;
  except
    on Exception do
    begin
      raise EClassNotFound.Create('Missing ' + ComplexName);
      Result := nil;
    end;
  end;
end;

procedure Tgs_frDataDictionary.LoadFromStream(Stream: TStream);
var
  w: Word;
  NewVersion: Boolean;

  procedure LoadFRVariables(Value: TfrVariables);
  var
    i, n:  Integer;
    s: String;
    V: string;
    Vl: Variant;
    VT: byte;
    T: Word;
  begin
    Stream.Read(n, 4);
    for i := 0 to n - 1 do
    begin
      s := frReadString(Stream);
      V := frReadString(Stream);
      {!!!}
      if (Pos(LoadVarStreamLabel, V) = 1) and (Length(V) >= VarStreamLabelSize) then
      begin
        try
          VT := Byte(V[VarStreamLabelSize]);
          T := VT shl 8;
          VT := Byte(V[VarStreamLabelSize - 1]);
          T := T + VT;
          V := Copy(V, VarStreamLabelSize + 1, Length(V) - VarStreamLabelSize);
          Vl := VarAsType(V, T)
        except
          Vl := '';
        end;
      end else
        Vl := V;
      {!!!}
      Value[s] := Vl;
    end;
  end;

  procedure LoadOldVariables;
  var
    i, n, d: Integer;
    b: Byte;
    s, s1, s2: String;

    function ReadStr: String;
    var
      n: Byte;
    begin
      Stream.ReadBuffer(n, 1);
      SetLength(Result, n);
      if n > 0 then
        Stream.ReadBuffer(Result[1], n);
    end;

  begin
    with Stream do
    begin
      ReadBuffer(n, SizeOf(n));
      for i := 0 to n - 1 do
      begin
        Read(b, 1); // typ
        Read(d, 4); // otherkind
        s1 := ReadStr; // dataset
        s2 := ReadStr; // field
        s := ReadStr;  // var name
        if b = 2 then      // it's system variable or expression
          if d = 1 then
            s1 := s2 else
            s1 := frSpecFuncs[d]
        else if b = 1 then // it's data field
          s1 := s1 + '."' + s2 + '"'
        else
          s1 := '';
        FieldAliases[' ' + s] := s1;
      end;
    end;

    if frVersion >= 23 then
      frReadMemo(Stream, SMemo)
    else
      frReadMemo22(Stream, SMemo);

    for i := 0 to SMemo.Count - 1 do
    begin
      s := SMemo[i];
      if (s > '') and (s[1] <> ' ') then
        Variables[s] := '' else
        Variables[s] := FieldAliases[s];
    end;
    FieldAliases.Clear;
  end;

  procedure ConvertToNewFormat;
  var
    i: Integer;
    s: String;
  begin
    for i := 0 to Variables.Count - 1 do
    begin
      s := Variables.Name[i];
      if s > '' then
        if s[1] = ' ' then
          s := Copy(s, 2, 255) else
          s := ' ' + s;
      Variables.Name[i] := s;
    end;
  end;

  procedure ConvertAliases;
  var
    i: Integer;
    DSet: TfrTDataSet;
    F: String;
  begin
    i := 0;
    while i < FieldAliases.Count do
    begin
      if FieldAliases.Value[i] = '' then
      begin
        GetDatasetAndField(FieldAliases.Name[i], DSet, F);
        if F = '' then
        begin
          FieldAliases.Delete(i);
          Dec(i);
        end;
      end;
      Inc(i);
    end;

    i := 0;
    while i < BandDataSources.Count do
      if BandDataSources.Value[i] = '' then
        BandDataSources.Delete(i) else
        Inc(i);
  end;

begin
  Clear;
  w := frReadWord(Stream);
  NewVersion := (w = $FFFF) or (w = $FFFE);
  if NewVersion then
  begin
    LoadFRVariables(Variables);
    LoadFRVariables(FieldAliases);
    LoadFRVariables(BandDatasources);
  end
  else
  begin
    Stream.Seek(-2, soFromCurrent);
    LoadOldVariables;
  end;
  if (Variables.Count > 0) and (Variables.Name[0] > '') and (Variables.Name[0][1] <> ' ') then
    ConvertToNewFormat;
  if w = $FFFF then
    ConvertAliases;
end;

{ Tfr_ReportResult }

constructor Tfr_ReportResult.Create;
begin
  inherited Create;

  FfrDataSetList := TStringList.Create;
  FfrDataSetList.Sorted := True;
end;

destructor Tfr_ReportResult.Destroy;
begin
  Clear;

  inherited Destroy;

  FreeAndNil(FfrDataSetList);
end;

function Tfr_ReportResult.AddDataSet(const AnName: String): Integer;
{$IFOPT C+}
var
  I: Integer;
{$ENDIF}
begin
  Result := inherited AddDataSet(AnName);
  {$IFOPT C+}I := {$ENDIF}FfrDataSetList.AddObject(AnsiUpperCase(AnName), TfrDBDataSet.Create(nil));
  {$IFOPT C+}Assert(Result = I);{$ENDIF}
  TfrDBDataSet(FfrDataSetList.Objects[Result]).Name := FfrDataSetList.Strings[Result];
  TfrDBDataSet(FfrDataSetList.Objects[Result]).DataSet := DataSet[Result];
end;

procedure Tfr_ReportResult.DeleteDataSet(const AnIndex: Integer);
begin
  inherited;

  Assert((AnIndex >= 0) and (AnIndex < FfrDataSetList.Count));
  TfrDBDataSet(FfrDataSetList.Objects[AnIndex]).Free;
  FfrDataSetList.Delete(AnIndex);
  Assert(FfrDataSetList.Count = Count);
end;

function Tfr_ReportResult.frDataSetByName(const AnName: String): TfrDBDataSet;
var
  I: Integer;
begin
  Result := nil;
  if FfrDataSetList.Find(AnName, I) then
    Result := frDataSet[I];
end;

function Tfr_ReportResult.GetfrDataSet(AnIndex: Integer): TfrDBDataSet;
begin
  Assert((AnIndex >= 0) and (AnIndex < FfrDataSetList.Count));
  Result := TfrDBDataSet(FfrDataSetList.Objects[AnIndex]);
end;

procedure Tfr_ReportResult.AddDataSetList(const AnBaseQueryList: Variant);
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
    I := FfrDataSetList.AddObject(AnsiUpperCase(DS.Name), TfrDBDataSet.Create(nil));
    Assert(K = I);
    TfrDBDataSet(FfrDataSetList.Objects[I]).Name := FfrDataSetList.Strings[I];
    TfrDBDataSet(FfrDataSetList.Objects[I]).DataSet := DS;
  end;
end;

{ Tgs_frBand }

constructor Tgs_frBand.Create(ATyp: TfrBandType; AParent: TfrPage;
  AReport: Tgs_frReport);
begin
  Assert(AReport <> nil);
  inherited Create(ATyp, AParent);

  FfrReport := AReport;
end;

procedure Tgs_frBand.InitDataSet(Desc: String);
begin
  if Typ = btGroupHeader then
    GroupCondition := frParser.Str2OPZ(Desc)
  else
    if Pos(';', Desc) = 0 then
    begin
      rpCreateDS(Desc, DataSet, IsVirtualDS, FfrReport);
    end;

  if (Typ = btMasterData) and (Dataset = nil) and
     (CurReport.ReportType = rtSimple) then
    DataSet := CurReport.Dataset;
end;

{ Tgs_frPage }

function Tgs_frPage.CreateBand(ATyp: TfrBandType;
  AParent: TfrPage): TfrBand;
begin
  Result := Tgs_frBand.Create(ATyp, AParent, FfrReport);
end;

procedure Tgs_frPage.gsGetDataSetandField(ComplexName: String;
  var DataSet: TfrTDataSet; var Field: String);
var
  i, j, n: Integer;
  sl: TStringList;
  s: String;
  c: Char;

  function FindField(ds: TfrTDataSet; FName: String): String;
  var
    sl: TStringList;
  begin
    Result := '';
    if ds <> nil then
    begin
      sl := TStringList.Create;
      frGetFieldNames(ds, sl);
      if sl.IndexOf(FName) <> -1 then
        Result := FName;
      sl.Free;
    end;
  end;

begin
  Field := '';
  sl := TStringList.Create;
  try

    n := 0; j := 1;
    for i := 1 to Length(ComplexName) do
    begin
      c := ComplexName[i];
      if c = '"' then
      begin
        sl.Add(Copy(ComplexName, i, 255));
        j := i;
        break;
      end
      else if c = '.' then
      begin
        sl.Add(Copy(ComplexName, j, i - j));
        j := i + 1;
        Inc(n);
      end;
    end;
    if j <> i then
      sl.Add(Copy(ComplexName, j, 255));

    case n of
      0: // field name only
        begin
          if DataSet <> nil then
          begin
            s := frRemoveQuotes(ComplexName);
            Field := FindField(DataSet, s);
          end;
        end;
      1, 2, 3: // DatasetName.FieldName
        begin
          DataSet := TfrTDataSet(FfrReport.UpdateDictionary.ReportResult.DataSetByName(sl[n - 1]));
          s := frRemoveQuotes(sl[n]);
          Field := FindField(DataSet, s);
        end;
    end;

  finally
    sl.Free;
  end;
end;

procedure Tgs_frPage.SelfCreateDS(Desc: String; var DataSet: TfrDataSet;
  var IsVirtualDS: Boolean);
begin
  rpCreateDS(Desc, DataSet, IsVirtualDS, FfrReport);
end;

{ Tgs_frPages }

procedure Tgs_frPages.Add;
var
  TempPage: Tgs_frPage;
begin
  TempPage := Tgs_frPage.Create(frDefaultPaper, 0, 0, -1, Printers.poPortrait);
  TempPage.frReport := Tgs_frReport(Parent);
  TempPage.pgMargins:= Rect(36, 36, 36, 36);
  FPages.Add(TempPage);
end;

{ Tgs_frEMFPages }

function Tgs_frEMFPages.CreateNewPage(ASize, AWidth, AHeight,
  ABin: Integer; AOr: TPrinterOrientation): TfrPage;
begin
  Result := Tgs_frPage.Create(ASize, AWidth, AHeight, ABin, AOr);
end;

{ TFRReportInterface }

constructor TFRReportInterface.Create;
begin
  inherited Create;

  FfrReport := Tgs_frReport.Create(Application);
  FfrReport.ModalPreview := False;
  FfrReport.FfrPreviewForm := @FPreviewForm;
  FfrReport.ShowProgress := False;
  FfrReport.OnObjectClick := SelfReportEvent;
end;

destructor TFRReportInterface.Destroy;
begin
  // Это из-за гребаного FastReport с его CrossTable
  // Если при создании FfrReport указывать nil,
  // то CrossTable будет Exception кидать.
  if FindReportComponent(FfrReport) then
    FreeAndNil(FfrReport);

  if Assigned(FErMsg) then
  begin
    FErMsg.FreeOnTerminate := False;
    FErMsg.ClearTerminate;
    FErMsg.WaitFor;
    FErMsg.Free;
  end;

  inherited Destroy;
end;

procedure TFRReportInterface.BuildReport;
begin
  inherited BuildReport;

  try
    FfrReport.ShowReport;
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

function TFRReportInterface.Get_ReportTemplate: TReportTemplate;
begin
  Result := nil;
end;

procedure TFRReportInterface.Set_ReportTemplate(
  const AnReportTemplate: TReportTemplate);
var
  OldPosition: Integer;
begin
  OldPosition := AnReportTemplate.Position;
  FfrReport.LoadFromStream(AnReportTemplate);
  AnReportTemplate.Position := OldPosition;
end;

function TFRReportInterface.Get_ReportResult: TReportResult;
begin
  Result := FfrReport.UpdateDictionary.ReportResult;
end;

procedure TFRReportInterface.Set_ReportResult(
  const AnReportResult: TReportResult);
begin
  FfrReport.UpdateDictionary.ReportResult.Assign(AnReportResult);
end;

procedure TFRReportInterface.AddParam(const AnName: String; const AnValue: Variant);
begin
  try
    FfrReport.UpdateDictionary.Variables.Insert(0, AnName);
    FfrReport.UpdateDictionary.Variables.Variable[AnName] := AnValue;
  except
  end;
end;

procedure TFRReportInterface.CreatePreviewForm;
begin
  FPreviewForm := Tgs_frPreviewForm.Create(Application);

  inherited;
end;

function TFRReportInterface.IsProcessed: Boolean;
begin
  Result := inherited IsProcessed or Assigned(FErMsg);
end;

procedure TFRReportInterface.DoTerminate(Sender: TObject);
begin
  FErMsg := nil;
end;

procedure TFRReportInterface.PrintReport;
begin
  try
    FfrReport.PrepareReport;
    if Preview then
      FfrReport.PrintPreparedReportDlg
    else begin
      if Assigned(Printer.Printers) then
      begin
        if PrinterName > '' then
        begin
          if Printer.Printers.IndexOf(PrinterName) < 0 then
            raise Exception.Create('Принтер "' + PrinterName + '" не доступен.');
          Printer.PrinterIndex := Printer.Printers.IndexOf(PrinterName);
        end;  
        FfrReport.PrintPreparedReport('', 1, True, frAll);
      end;  
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

procedure TFRReportInterface.SelfReportEvent(View: TfrView);
var
  VarArray: Variant;
  LocResult: Boolean;
  TempVar: Variant;
begin
  if Assigned(FReportEvent) then
  begin
    VarArray := VarArrayCreate([0, 2], varVariant);
    VarArray[0] := FTempParam;
    TempVar := VarArrayCreate([0, 1], varVariant);
    TempVar[0] := View.Memo.Text;
    TempVar[1] := View.Tag;
    VarArray[1] := TempVar;
    VarArray[2] := View.Name;
    FReportEvent(VarArray, FEventFunction, LocResult);
    if LocResult then
      FreeAndNil(FPreviewForm);
//      FPreviewForm.Close;
  end;
end;

function TFRReportInterface.Get_Params: Variant;
begin
  Result := FTempParam;
end;

procedure TFRReportInterface.Set_Params(const AnParams: Variant);
begin
  inherited Set_Params(AnParams);

  FTempParam := AnParams;
end;

function TFRReportInterface.FindReportComponent(
  const AnReport: Tgs_frReport): Boolean;
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

{ Tgs_frPreviewForm }

procedure Tgs_frPreviewForm.Connect(ADoc: Pointer);
begin
  Doc := ADoc;
  if EMFPages <> nil then
    Tgs_frEMFPages(EMFPages).Free;
  EMFPages := TfrReport(Doc).EMFPages;
  TfrReport(Doc).EMFPages := Tgs_frEMFPages.Create(Doc);
end;

{ Tgs_frSingleReport }

procedure Tgs_frSingleReport.ShowPreparedReport;
var
  F: TfrPreviewForm;
begin
  F := TfrPreviewForm.Create(nil);
  try
    FfrPreviewForm := @F;

    inherited ShowPreparedReport;

  finally
    FfrPreviewForm := nil;
    F := nil;
  end;
end;

procedure rpCreateDS(Desc: String; var DataSet: TfrDataSet; var IsVirtualDS: Boolean;
  AnReport: Tgs_frReport);
begin
  if (Desc > '') and (Desc[1] in ['1'..'9']) then
  begin
    DataSet := TfrUserDataSet.Create(nil);
    DataSet.RangeEnd := reCount;
    DataSet.RangeEndCount := StrToInt(Desc);
    IsVirtualDS := True;
  end
  else
  begin
    DataSet := AnReport.UpdateDictionary.ReportResult.frDataSetByName(Desc);
    if not Assigned(DataSet) then
      DataSet := frFindComponent(CurReport.Owner, Desc) as TfrDataSet;
  end;
  if DataSet <> nil then
    DataSet.Init;
end;

end.

