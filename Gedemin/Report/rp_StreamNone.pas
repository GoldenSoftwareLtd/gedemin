// ShlTanya, 27.02.2019

unit rp_StreamNone;

interface

uses
  rp_i_ReportBuilder_unit, rp_BaseReport_unit, SysUtils, rp_dlgViewResult_unit,
  Forms, Classes;

type
  TNoneReportInterface = class(TCustomReportBuilder)
  private
    FReportStream: TReportResult;
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

constructor TNoneReportInterface.Create;
begin
  inherited Create;

  FReportStream := TReportResult.Create;
end;

destructor TNoneReportInterface.Destroy;
begin
  FreeAndNil(FReportStream);

  inherited Destroy;
end;

function TNoneReportInterface.Get_ReportResult: TReportResult;
begin
  Result := FReportStream;
end;

function TNoneReportInterface.Get_ReportTemplate: TReportTemplate;
begin
  Result := nil;
end;

procedure TNoneReportInterface.BuildReport;
var
  I: Integer;
begin
  inherited BuildReport;

  for I := 0 to FReportStream.Count - 1 do
    TdlgViewResult(FPreviewForm).AddPage(FReportStream.DataSet[I]);

  if TdlgViewResult(FPreviewForm).PageCount > 0 then
  begin
    TdlgViewResult(FPreviewForm).pcDataSet.ActivePageIndex :=
     TdlgViewResult(FPreviewForm).pcDataSet.PageCount - 1;
    TdlgViewResult(FPreviewForm).Show;
  end else
    FreeOldForm;
end;

procedure TNoneReportInterface.Set_ReportResult(
  const AnReportResult: TReportResult);
begin
  if Assigned(AnReportResult) then
    FReportStream.Assign(AnReportResult)
  else
    AnReportResult.Clear;
end;

procedure TNoneReportInterface.Set_ReportTemplate(
  const AnReportTemplate: TReportTemplate);
begin
  // Don't used.
end;

procedure TNoneReportInterface.AddParam(const AnName: String; const AnValue: Variant);
begin
  // Don't used.
end;

procedure TNoneReportInterface.CreatePreviewForm;
begin
  FPreviewForm := TdlgViewResult.Create(nil);
end;

procedure TNoneReportInterface.PrintReport;
begin
  Beep;
end;

end.
