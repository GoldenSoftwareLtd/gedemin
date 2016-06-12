unit gdcc_frmProgress_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ActnList, gdccGlobal, ExtCtrls;

const
  WM_GDCC_PROGRESS_UPDATE   = WM_USER + 1;
  WM_GDCC_PROGRESS_RELEASE  = WM_USER + 2;

type
  Tgdcc_frmProgress = class(TForm)
    pb: TProgressBar;
    btnCancel: TButton;
    al: TActionList;
    actCancel: TAction;
    lblName: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    lblEstimFinishCapt: TLabel;
    lblEstimLeftCapt: TLabel;
    lblStep: TLabel;
    lblStarted: TLabel;
    lblElapsed: TLabel;
    lblEstimLeft: TLabel;
    lblEstimFinish: TLabel;
    lblDone: TLabel;
    Timer: TTimer;
    actClose: TAction;
    procedure TimerTimer(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure actCancelUpdate(Sender: TObject);

  private
    FConnectionID: Integer;
    FForegrounded: Boolean;

    procedure WMGDCCProgressUpdate(var Msg: TMessage);
      message WM_GDCC_PROGRESS_UPDATE;
    procedure WMGDCCProgressRelease(var Msg: TMessage);
      message WM_GDCC_PROGRESS_RELEASE;

  public
    property ConnectionID: Integer read FConnectionID write FConnectionID;
  end;

implementation

{$R *.DFM}

uses
  gd_common_functions, gdccServer_unit;

{ Tgdcc_frmProgress }

procedure Tgdcc_frmProgress.TimerTimer(Sender: TObject);
begin
  PostMessage(Handle, WM_GDCC_PROGRESS_UPDATE, 0, 0);
end;

procedure Tgdcc_frmProgress.WMGDCCProgressRelease(var Msg: TMessage);
begin
  Release;
end;

procedure Tgdcc_frmProgress.WMGDCCProgressUpdate(var Msg: TMessage);
var
  C: TgdccConnection;
  P, D: Integer;
begin
  if gdccServer.Connections.FindAndLock(ConnectionID, C) then
  try
    if not FForegrounded then
    begin
      //ForceForegroundWindow(Handle);
      SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
      FForegrounded := True;
    end;
    if C.Progress.Done then
      Timer.Enabled := False;
    Caption := C.Progress.Caption;
    lblName.Caption := C.Progress.Name;
    lblStarted.Caption := FormatDateTime('hh:nn:ss', C.Progress.Started);
    pb.Min := 0;
    pb.Max := C.Progress.StepTotal;
    pb.Position := C.Progress.StepDone;
    lblElapsed.Caption := FormatDateTime('hh:nn:ss', C.Progress.Elapsed);
    if C.Progress.Done then
    begin
      lblDone.Caption := '100%';
      lblEstimFinishCapt.Caption := 'Завершено в:';
      lblEstimFinish.Caption := FormatDateTime('hh:nn:ss', C.Progress.Finished);
      lblEstimLeftCapt.Caption := '';
      lblEstimLeft.Caption := '';
      lblStep.Caption := C.Progress.FinishMessage;
      btnCancel.Action := actClose;
    end else
    begin
      P := Round(100 * C.Progress.StepDone / C.Progress.StepTotal);
      if P = 100 then P := 99;
      if C.Progress.StepDone = C.Progress.StepTotal then
      begin
        D := C.Progress.StepTotal - 1;
        if D < 0 then D := 0;
      end else
        D := C.Progress.StepDone;
      lblDone.Caption := IntToStr(P) + '% (' + IntToStr(D) + ' из ' + IntToStr(C.Progress.StepTotal) + ')';
      if C.Progress.EstimFinish <> 0 then
        lblEstimFinish.Caption := FormatDateTime('hh:nn:ss', C.Progress.EstimFinish)
      else
        lblEstimFinish.Caption := '';
      if C.Progress.EstimLeft <> 0 then
        lblEstimLeft.Caption := FormatDateTime('hh:nn:ss', C.Progress.EstimLeft)
      else
        lblEstimLeft.Caption := '';
      lblStep.Caption := C.Progress.StepName;
    end;
    actCancel.Enabled := C.Progress.CanCancel;
  finally
    gdccServer.Connections.Unlock;
  end;
end;

procedure Tgdcc_frmProgress.actCancelExecute(Sender: TObject);
var
  C: TgdccConnection;
begin
  if gdccServer.Connections.FindAndLock(ConnectionID, C) then
  try
    C.ProgressCanceled := True;
  finally
    gdccServer.Connections.Unlock;
  end;
end;

procedure Tgdcc_frmProgress.actCloseExecute(Sender: TObject);
var
  C: TgdccConnection;
begin
  if gdccServer.Connections.FindAndLock(ConnectionID, C) then
  try
    C.ProgressHandle := 0;
  finally
    gdccServer.Connections.Unlock;
  end;
  Release;
end;

procedure Tgdcc_frmProgress.actCancelUpdate(Sender: TObject);
var
  C: TgdccConnection;
begin
  if gdccServer.Connections.FindAndLock(ConnectionID, C) then
  try
    actCancel.Enabled := (not C.ProgressCanceled)
      and (not C.Progress.Done);
  finally
    gdccServer.Connections.Unlock;
  end;
end;

end.
