unit rp_StreamGRD;

interface

uses
  rp_i_ReportBuilder_unit, rp_BaseReport_unit, SysUtils, rp_dlgViewResultEx_unit,
  Forms, Classes, Windows;

type
  TGRDReportInterface = class(TCustomReportBuilder)
  private
    FReportStream: TReportResult;
    FReportTemplate: TReportTemplate;
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

{ TNoneReportInterface }

  {$IFDEF LOCALIZATION}
uses
  {must be placed after Windows unit!}
  gd_localization_stub
  ;
  {$ENDIF}

constructor TGRDReportInterface.Create;
begin
  inherited Create;

  FReportStream := TReportResult.Create;
  FReportTemplate := TReportTemplate.Create;
end;

destructor TGRDReportInterface.Destroy;
begin
  FreeAndNil(FReportStream);
  FreeAndNil(FReportTemplate);

  inherited Destroy;
end;

function TGRDReportInterface.Get_ReportResult: TReportResult;
begin
  Result := FReportStream;
end;

function TGRDReportInterface.Get_ReportTemplate: TReportTemplate;
begin
  Result := FReportTemplate;
end;

procedure TGRDReportInterface.BuildReport;
//var
//  I: Integer;
begin
  inherited BuildReport;

  if Assigned(FPreviewForm) and not TdlgViewResultEx(FPreviewForm).ExecuteView(FReportStream, FReportTemplate) then
{  for I := 0 to FReportStream.Count - 1 do
    TdlgViewResultEx(FPreviewForm).AddPage(FReportStream.DataSet[I]);

  if TdlgViewResultEx(FPreviewForm).PageCount > 0 then
  begin
    TdlgViewResultEx(FPreviewForm).pcDataSet.ActivePageIndex :=
     TdlgViewResultEx(FPreviewForm).pcDataSet.PageCount - 1;
    TdlgViewResultEx(FPreviewForm).Show;
  end else}
    FreeOldForm;
end;

procedure TGRDReportInterface.Set_ReportResult(
  const AnReportResult: TReportResult);
begin
  if Assigned(AnReportResult) then
    FReportStream.Assign(AnReportResult)
  else
    AnReportResult.Clear;
end;

procedure TGRDReportInterface.Set_ReportTemplate(
  const AnReportTemplate: TReportTemplate);
begin
  FReportTemplate.Clear;
  FReportTemplate.LoadFromStream(AnReportTemplate);
end;

procedure TGRDReportInterface.AddParam(const AnName: String; const AnValue: Variant);
begin
  // Don't used.
end;

procedure TGRDReportInterface.CreatePreviewForm;
begin
  FPreviewForm := TdlgViewResultEx.Create(Application);
end;

procedure TGRDReportInterface.PrintReport;
begin
  MessageBox(Application.Handle, 'Данный тип отчета не может быть распечатан.',
   'Ошибка', MB_OK or MB_ICONERROR);
  SysUtils.Beep;
end;

end.

