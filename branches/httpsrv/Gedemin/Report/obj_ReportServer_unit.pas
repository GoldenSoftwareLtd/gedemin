unit obj_ReportServer_unit;

interface

uses
  ComObj, ActiveX, Gedemin_TLB, StdVcl, Classes, Windows, gd_SetDatabase,
  Messages, rp_report_const;

type
  TgdReportServer = class(TAutoObject, IgdReportServer)
  protected
    function GetReportResult(ReportKey: Integer; var Param: OleVariant;
      out ReportResult: OleVariant): WordBool; safecall;
    function  GetServerName: WideString; safecall;
    function  GetServerKey: Integer; safecall;
    procedure ShowProperty; safecall;
    procedure Close; safecall;
    { Protected declarations }
  end;

implementation

uses ComServ, rp_MainForm_unit, rp_BaseReport_unit;

function TgdReportServer.GetReportResult(ReportKey: Integer;
  var Param: OleVariant; out ReportResult: OleVariant): WordBool;
var
  LocReportResult: TReportResult;
  MStr: TMemoryStream;
begin
  LocReportResult := TReportResult.Create(nil);
  try
    MStr := TMemoryStream.Create;
    try
      Result := UnvisibleForm.ServerReport1.GetReportResult(ReportKey, Param, LocReportResult);
      if Result then
      begin
        LocReportResult.SaveToStream(MStr);
        ReportResult := VarArrayCreate([0, MStr.Size - 1], varByte);
        CopyMemory(VarArrayLock(ReportResult), MStr.Memory, MStr.Size);
        VarArrayUnLock(ReportResult);
      end;
    finally
      MStr.Free;
    end;
  finally
    LocReportResult.Free;
  end;
end;

function TgdReportServer.GetServerName: WideString;
begin
  Result := rpGetComputerName;
end;

function TgdReportServer.GetServerKey: Integer;
begin
  Result := UnvisibleForm.ServerReport1.ServerKey;
end;

procedure TgdReportServer.ShowProperty;
begin
  UnvisibleForm.ServerReport1.ServerOptions;
end;

procedure TgdReportServer.Close;
begin
  SendMessage(UnvisibleForm.Handle, WM_USER, WM_USER_CLOSE, 0);
end;

initialization
  TAutoObjectFactory.Create(ComServer, TgdReportServer, Class_gdReportServer,
    ciMultiInstance, tmApartment);
end.

