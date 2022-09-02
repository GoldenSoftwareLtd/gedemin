// ShlTanya, 27.02.2019

unit rp_prgReportCount_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls;

type
  TprgReportCount = class(TForm)
    lblMsg: TLabel;
    Animate1: TAnimate;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    FReportCountMsg: String;
    FInternalCounter: Integer;
    procedure WMUser(var Message: TMessage); message WM_USER;
    function CountString(AnCount: Integer): String;
  public
    function AddRef(const AShow: boolean = True): Integer;
    function Release: Integer;
    procedure Clear;
    property ReportCountMsg: String read FReportCountMsg write FReportCountMsg;
  end;

var
  prgReportCount: TprgReportCount;

implementation

uses
  gd_messages_const;

{$R *.DFM}

function TprgReportCount.AddRef(const AShow: boolean = True): Integer;
begin
  Inc(FInternalCounter);
  if FInternalCounter = 1 then
    lblMsg.Caption := 'Идет построение отчета...'
  else
    lblMsg.Caption := Format(ReportCountMsg, [FInternalCounter, CountString(FInternalCounter)]);
  if (FInternalCounter > 0) and AShow then
    Show;
  Result := FInternalCounter;
  if AShow then
    Repaint;
end;

procedure TprgReportCount.Clear;
begin
  FInternalCounter := 1;
  Release;
end;

function TprgReportCount.CountString(AnCount: Integer): String;
begin
  if (AnCount >= 5) and (AnCount < 21) then
  begin
    Result := 'отчетов';
    Exit;
  end;
  case AnCount mod 10 of
    1: Result := 'отчета';
  else
    Result := 'отчетов';
  end;
end;

procedure TprgReportCount.FormCreate(Sender: TObject);
begin
  FInternalCounter := 0;
  FReportCountMsg := 'В данный момент ожидается результат %d %s.';
end;

function TprgReportCount.Release: Integer;
begin
  Application.ProcessMessages;
  Dec(FInternalCounter);
  if not Application.Terminated then
  begin
    if FInternalCounter = 0 then
      lblMsg.Caption := 'Завершено построение отчета.'
    else
      lblMsg.Caption := Format(ReportCountMsg, [FInternalCounter, CountString(FInternalCounter)]);
    if (FInternalCounter <= 0) and Visible and
      (not IsIconic(Application.Handle)) then
      Hide;
  end;
  Result := FInternalCounter;
end;

procedure TprgReportCount.WMUser(var Message: TMessage);
begin
  case Message.WParam of
    WM_USER_PRMSG_ADDREF:
      AddRef;
    WM_USER_PRMSG_RELEASE:
      Release;
  end;
end;

procedure TprgReportCount.FormActivate(Sender: TObject);
begin
  if FInternalCounter = 0 then
    Hide;
end;

end.
