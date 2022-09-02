// ShlTanya, 27.02.2019

unit rp_dlgViewResultEx_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  rp_dlgViewResult_unit, StdCtrls, ExtCtrls, ComCtrls, DB, rp_BaseReport_unit,
  TB2Item, TB2Dock, TB2Toolbar, ActnList, gd_MultiStringList;

type
  TGridOptionsList = class(TStringList)
  private
    function GetOptions(AnIndex: Integer): TStream;
    function GetGridName(AnIndex: Integer): String;
  public
    destructor Destroy; override;

    procedure Delete(AnIndex: Integer); override;
    procedure Clear; override;

    function AddGridOptiops(AnGridName: String; AnOptions: TStream): Integer;
    procedure LoadFromStream(AnStream: TStream); override;
    procedure SaveToStream(AnStream: TStream); override;

    property GridOptions[AnIndex: Integer]: TStream read GetOptions;
    property GridName[AnIndex: Integer]: String read GetGridName;
  end;

type
  TdlgViewResultEx = class(TdlgViewResult)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FGridOptionsList: TGridOptionsList;
    FMasterDetail: TFourStringList;
    FReportForm: Boolean;
    procedure FillGridList(AnReportResult: TReportResult; AnGridOptions: TStream);
  public
    procedure AddPage(const AnDataSet: TDataSet); override;
    procedure SaveOptions;
    function ExecuteDialog(AnReportResult: TReportResult; AnGridOptions: TStream): Boolean;
    function ExecuteView(AnReportResult: TReportResult; AnGridOptions: TStream): Boolean;
    property ReportForm: Boolean read FReportForm write FReportForm default False;
  end;

var
  dlgViewResultEx: TdlgViewResultEx;

implementation

uses
  {$IFDEF QEXPORT}
  VExportDlg,
  {$ENDIF}
  rp_frmGridEx_unit
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R *.DFM}

{ TdlgViewResultEx }

procedure TdlgViewResultEx.AddPage(const AnDataSet: TDataSet);
var
  I, J, K: Integer;
  MDInd: Integer;
  MDFlag: Boolean;
  LSplitter: TSplitter;
begin
  MDFlag := False;

  I := -1;
  LSplitter := nil;

  // Проверяем если таблица является детаил
  MDInd := FMasterDetail.IndexOfDetailTable(AnDataSet.Name);
  if MDInd >= 0 then
  begin
    for J := 0 to FGridList.Count - 1 do
    begin
      MDFlag := TfrmGridEx(FGridList.Items[J]).dsSource.DataSet.Name = AnsiUpperCase(FMasterDetail.MasterTable[MDInd]);
      if MDFlag then Break;
    end;
    if MDFlag then
    begin
      // Добавляем сплитер
      LSplitter := TSplitter.Create(TfrmGridEx(FGridList.Items[J]).Parent);
      LSplitter.Parent := TfrmGridEx(FGridList.Items[J]).Parent;
      LSplitter.Align := alBottom;
      LSplitter.Name := 'spl' + AnDataSet.Name;
      // Создаем новый грид
      I := FGridList.Add(TfrmGridEx.Create(nil));
      TfrmGridEx(FGridList.Items[I]).dsSource.DataSet := AnDataSet;
      TfrmGridEx(FGridList.Items[I]).Align := alBottom;
      TfrmGridEx(FGridList.Items[I]).Parent := TfrmGridEx(FGridList.Items[J]).Parent;
      // Устанавливаем высоту
      TfrmGridEx(FGridList.Items[I]).Height := TfrmGridEx(FGridList.Items[J]).Height div 2;
      // Меняем название закладки
      TTabSheet(TfrmGridEx(FGridList.Items[J]).Parent).Caption :=
        TTabSheet(TfrmGridEx(FGridList.Items[J]).Parent).Caption + '/' + AnDataSet.Name;
    end;
  end;

  // Проверяем если таблица является мастером
  MDInd := FMasterDetail.IndexOfMasterTable(AnDataSet.Name);
  if (MDInd >= 0) and not MDFlag then
  begin
    for J := 0 to FGridList.Count - 1 do
    begin
      MDFlag := TfrmGridEx(FGridList.Items[J]).dsSource.DataSet.Name = AnsiUpperCase(FMasterDetail.DetailTable[MDInd]);
      if MDFlag then Break;
    end;
    if MDFlag then
    begin
      // Добавляем сплитер
      LSplitter := TSplitter.Create(TfrmGridEx(FGridList.Items[J]).Parent);
      LSplitter.Parent := TfrmGridEx(FGridList.Items[J]).Parent;
      LSplitter.Align := alBottom;
      LSplitter.Name := 'spl' + AnDataSet.Name;
      // Создаем новый грид
      I := FGridList.Add(TfrmGridEx.Create(nil));
      TfrmGridEx(FGridList.Items[I]).dsSource.DataSet := AnDataSet;
      TfrmGridEx(FGridList.Items[J]).Align := alBottom;
      TfrmGridEx(FGridList.Items[I]).Parent := TfrmGridEx(FGridList.Items[J]).Parent;
      // Устанавливаем высоту
      TfrmGridEx(FGridList.Items[J]).Height := TfrmGridEx(FGridList.Items[J]).Height div 2;
      // Меняем название закладки
      TTabSheet(TfrmGridEx(FGridList.Items[J]).Parent).Caption :=
        AnDataSet.Name + '/' + TTabSheet(TfrmGridEx(FGridList.Items[J]).Parent).Caption;
    end;
  end;

  if not MDFlag then
  begin
    J := FPageList.Add(TTabSheet.Create(nil));
    TTabSheet(FPageList.Items[J]).Caption := AnDataSet.Name;
    TTabSheet(FPageList.Items[J]).PageControl := pcDataSet;
    TTabSheet(FPageList.Items[J]).Visible := True;
    TTabSheet(FPageList.Items[J]).TabVisible := True;

    I := FGridList.Add(TfrmGridEx.Create(nil));
    TfrmGridEx(FGridList.Items[I]).dsSource.DataSet := AnDataSet;
    TfrmGridEx(FGridList.Items[I]).Parent := TTabSheet(FPageList.Items[J]);
  end;

  K := FGridOptionsList.IndexOf(AnDataSet.Name);
  if K > -1 then
  begin
    FGridOptionsList.GridOptions[K].Position := 0;
    TfrmGridEx(FGridList.Items[I]).dbgSource.LoadFromStream(FGridOptionsList.GridOptions[K]);
    if Assigned(LSplitter) then
      LSplitter.Top := TfrmGridEx(FGridList.Items[I]).Top;
  end;
end;

function TdlgViewResultEx.ExecuteDialog(AnReportResult: TReportResult;
  AnGridOptions: TStream): Boolean;
begin
  Result := True;
  try
    FillGridList(AnReportResult, AnGridOptions);

    if PageCount > 0 then
    begin
      pcDataSet.ActivePageIndex := pcDataSet.PageCount - 1;
      ShowModal;
      if Result and Assigned(AnGridOptions) then
      begin
        AnGridOptions.Position := 0;
        SaveOptions;
        FGridOptionsList.SaveToStream(AnGridOptions);
        AnGridOptions.Size := AnGridOptions.Position;
      end;
    end;
  except
    on E: Exception do
    begin
      MessageBox(Handle,
        PChar('Произошла ошибка при построении отчета. ' + E.Message),
       'Ошибка',
       MB_OK or MB_ICONERROR or MB_TASKMODAL);
    end;
  end;
end;

procedure TdlgViewResultEx.SaveOptions;
var
  I: Integer;
begin
  FGridOptionsList.Clear;
  for I := 0 to FGridList.Count - 1 do
  begin
    FGridOptionsList.AddGridOptiops(TfrmGridEx(FGridList.Items[I]).dsSource.DataSet.Name, nil);
    TfrmGridEx(FGridList.Items[I]).dbgSource.SaveToStream(FGridOptionsList.GridOptions[I]);
  end;
end;

function TdlgViewResultEx.ExecuteView(AnReportResult: TReportResult;
  AnGridOptions: TStream): Boolean;
begin
  Result := False;
  FillGridList(AnReportResult, AnGridOptions);
  if PageCount > 0 then
  begin
    pcDataSet.ActivePageIndex := pcDataSet.PageCount - 1;
    Show;
    Result := True;
  end;
end;

procedure TdlgViewResultEx.FillGridList(AnReportResult: TReportResult;
  AnGridOptions: TStream);
var
  I: Integer;
begin
  Clear;

  try
    if Assigned(AnGridOptions) then
      FGridOptionsList.LoadFromStream(AnGridOptions);
  except
    on E: Exception do
      MessageBox(Handle, PChar('Произошла ошибка при считывании шаблона. ' + E.Message),
       'Ошибка', MB_OK or MB_ICONERROR);
  end;

  FMasterDetail := AnReportResult._MasterDetail;

  for I := 0 to AnReportResult.Count - 1 do
    AddPage(AnReportResult.DataSet[I]);
end;

{ TGridOptionsList }

const
  cGridOptionsPrefix = 'GOL^';

function TGridOptionsList.AddGridOptiops(AnGridName: String;
  AnOptions: TStream): Integer;
begin
  Result := AddObject(AnGridName, TMemoryStream.Create);
  if Assigned(AnOptions) then
    GridOptions[Result].CopyFrom(AnOptions, AnOptions.Size);
end;

procedure TGridOptionsList.Clear;
begin
  while Count > 0 do
    Delete(0);
  inherited;
end;

procedure TGridOptionsList.Delete(AnIndex: Integer);
begin
  Objects[AnIndex].Free;
  Objects[AnIndex] := nil;
  inherited Delete(AnIndex);
end;

destructor TGridOptionsList.Destroy;
begin
  Clear;

  inherited;
end;

function TGridOptionsList.GetGridName(AnIndex: Integer): String;
begin
  Result := Strings[AnIndex];
end;

function TGridOptionsList.GetOptions(AnIndex: Integer): TStream;
begin
  Result := TStream(Objects[AnIndex]);
end;

procedure TGridOptionsList.LoadFromStream(AnStream: TStream);
var
  I: Integer;
  LSize, LCount: Integer;
  LPrefix: String[SizeOf(cGridOptionsPrefix)];
  LName: String;
begin
  Clear;
  if AnStream.Size <= AnStream.Position then
    Exit;

  SetLength(LPrefix, SizeOf(cGridOptionsPrefix));
  AnStream.ReadBuffer(LPrefix[1], SizeOf(cGridOptionsPrefix));
  if cGridOptionsPrefix <> LPrefix then
    raise Exception.Create('TGridOptionsList: Wrong stream format.');
  AnStream.ReadBuffer(LCount, SizeOf(LSize));
  for I := 0 to LCount - 1 do
  begin
    AnStream.ReadBuffer(LSize, SizeOf(LSize));
    AddGridOptiops('', nil);
    SetLength(LName, LSize);
    AnStream.ReadBuffer(LName[1], LSize);
    Strings[I] := LName;
    AnStream.ReadBuffer(LSize, SizeOf(LSize));
    GridOptions[I].CopyFrom(AnStream, LSize);
  end;
end;

procedure TGridOptionsList.SaveToStream(AnStream: TStream);
var
  I: Integer;
  LSize: Integer;
begin
  AnStream.Write(cGridOptionsPrefix, SizeOf(cGridOptionsPrefix));
  LSize := Count;
  AnStream.Write(LSize, SizeOf(LSize));
  for I := 0 to Count - 1 do
  begin
    LSize := Length(GridName[I]);
    AnStream.Write(LSize, SizeOf(LSize));
    AnStream.Write(GridName[I][1], LSize);
    LSize := GridOptions[I].Size;
    AnStream.Write(LSize, SizeOf(LSize));
    GridOptions[I].Position := 0;
    AnStream.CopyFrom(GridOptions[I], LSize);
  end;
end;

procedure TdlgViewResultEx.FormCreate(Sender: TObject);
begin
  inherited;
  FGridOptionsList := TGridOptionsList.Create;
  FReportForm := False;
end;

procedure TdlgViewResultEx.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FGridOptionsList);
  inherited;
end;

procedure TdlgViewResultEx.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  // для корректного освобождения в отчётах
  inherited;
  if FReportForm then
    Action := caFree;
end;

end.
