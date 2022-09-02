// ShlTanya, 27.02.2019

unit rp_RemoteManager_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ReportManager_TLB, rp_SvrMngTemplate_unit, ActnList, StdCtrls, ActiveX,
  obj_ObjectEvent, IBDatabase, Db, IBCustomDataSet, IBQuery;

type
  TRemoteManager = class(TSvrMngTemplate)
    ibqryServerKey: TIBQuery;
    ibtrServerKey: TIBTransaction;
    procedure btnDisconnectClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnRebuildClick(Sender: TObject);
    procedure btnRunClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnPropertyClick(Sender: TObject);
  private
    FRemoteServer: ISvrMng;
    FEvent: TEventSink;
    FDisp: IDispatch;
    FServerName: String;

    procedure InvokeEvent(DispID: TDispID; var Params: TgsVariantArray);
  public
    procedure ShowReportManager(const AnServerName: String);
  end;

var
  RemoteManager: TRemoteManager;

implementation

uses
  ComObj, rp_dlgReportOptions_unit, gd_SetDatabase, CheckServerLoad_unit;

{$R *.DFM}

{ TSvrMngTemplate2 }

procedure TRemoteManager.ShowReportManager(const AnServerName: String);
var
  I: Integer;
{  CPC: IConnectionPointContainer;
  CP: IConnectionPoint;}
begin
  FServerName := AnServerName;
  try
    Caption := Format('Сервер отчетов %s', [FServerName]);
    FRemoteServer := CoSvrMng.CreateRemote(AnServerName);
    FEvent := TEventSink.Create(Self, DIID_ISvrMngEvents);
    FEvent.OnInvokeEvent := InvokeEvent;
    FDisp := FEvent;
{    if Succeeded(FRemoteServer.QueryInterface(IConnectionPointContainer, CPC)) then
      if Succeeded(CPC.FindConnectionPoint(DIID_ISvrMngEvents, CP)) then
        CP.Advise(FDisp, I);}
    ComObj.InterfaceConnect(FRemoteServer, DIID_ISvrMngEvents, FDisp, I);
    ShowModal;
  except
    on E: Exception do
      MessageBox(Handle, PChar('Произошла ошибка при управлении сервером отчетом ' +
       FServerName + ':'#13#10 + E.Message), 'Ошибка', MB_OK or MB_ICONERROR);
  end;
end;

procedure TRemoteManager.btnDisconnectClick(Sender: TObject);
begin
  FRemoteServer.Close;
end;

procedure TRemoteManager.btnRefreshClick(Sender: TObject);
begin
  FRemoteServer.Refresh;
end;

procedure TRemoteManager.btnRebuildClick(Sender: TObject);
begin
  FRemoteServer.Rebuild;
end;

procedure TRemoteManager.btnRunClick(Sender: TObject);
begin
  FRemoteServer.Run;
end;

procedure TRemoteManager.InvokeEvent(DispID: TDispID;
  var Params: TgsVariantArray);
begin
  case DispID of
    1:
    begin
      btnDisconnect.Enabled := Params[0] = Long_True;
      btnRefresh.Enabled := btnDisconnect.Enabled;
      btnRebuild.Enabled := btnDisconnect.Enabled;
      btnClear.Enabled := btnDisconnect.Enabled;
      btnRun.Enabled := Params[0] < Long_True;
      if btnRun.Enabled and btnDisconnect.Enabled then
        Caption := Format('Сервер отчетов %s: %s', [FServerName, 'не определен'])
      else if btnRun.Enabled then
          Caption := Format('Сервер отчетов %s: %s', [FServerName, 'не загружен'])
        else if btnDisconnect.Enabled then
            Caption := Format('Сервер отчетов %s: %s', [FServerName, 'загружен'])
          else if not (btnRun.Enabled or btnDisconnect.Enabled) then
              Caption := Format('Сервер отчетов %s: %s', [FServerName, 'нет доступа']);
      Hint := Caption;        
    end;
  else
    raise Exception.Create(Format('Event interface method %d not supported', [DispID]));
  end;
end;

procedure TRemoteManager.FormDestroy(Sender: TObject);
begin
  FEvent := nil;
end;

procedure TRemoteManager.btnPropertyClick(Sender: TObject);
var
  F: TdlgReportOptions;
begin
  F := TdlgReportOptions.Create(nil);
  try
    if not ibtrServerKey.InTransaction then
      ibtrServerKey.StartTransaction;
    try
      ibqryServerKey.Close;
      ibqryServerKey.Params[0].AsString := FServerName;
      ibqryServerKey.Open;

      SetDatabaseAndTransaction(F, ibqryServerKey.Database, ibqryServerKey.Transaction);
      F.ViewOptions(GetTID(ibqryServerKey.Fields[0]));
    finally
      if ibtrServerKey.InTransaction then
        ibtrServerKey.Commit;
    end;
  finally
    F.Free;
  end;
end;

end.
