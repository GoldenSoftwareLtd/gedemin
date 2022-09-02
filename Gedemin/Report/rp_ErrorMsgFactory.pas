// ShlTanya, 27.02.2019

unit rp_ErrorMsgFactory;

interface

uses
  Classes, Forms, Windows, SysUtils, rp_prgReportCount_unit, rp_msgErrorReport_unit,
  JclDebug;

type
  TClientEventThread = class(TJclDebugThread)
  private
    FProgressForm: TprgReportCount;
    FIsAddRef: Boolean;
    FIsShowMsg: Boolean;
    FMsgText: String;
    FIsProccess: Boolean;

    FPreviewForm: TmsgErrorReport;
    FOldClose: TCloseEvent;
    FOldDestroy: TNotifyEvent;
    procedure DoClose(Sender: TObject; var Action: TCloseAction);
    procedure DoDestroy(Sender: TObject);

    procedure IsProccess;
    procedure CreateForm;
    procedure FreeOldForm;

    procedure DoIt;
    procedure DoClearTerminate;
    procedure SelfSleep;
  public
    constructor Create(AnProgressForm: TprgReportCount; AnIsAddRef: Boolean;
     AnIsShowMsg: Boolean; AnMsgText: String);
    destructor Destroy; override;

    procedure Execute; override;

    procedure ClearTerminate;
  end;

type
  TClientEventFactory = class
  private
    FThreadList: TList;

    procedure DoTerminate(Sender: TObject);
    procedure TerminateChildThreads;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddThread(AnClientEventThread: TClientEventThread);

    procedure Clear;
  end;

implementation

{ TClientEventThread }

procedure TClientEventThread.ClearTerminate;
begin
  Synchronize(DoClearTerminate);
end;

procedure TClientEventThread.DoClearTerminate;
begin
  Synchronize(FreeOldForm);

  {!!!} // Были проблемы
//  OnTerminate := nil;
//  Terminate;
end;

constructor TClientEventThread.Create(AnProgressForm: TprgReportCount; AnIsAddRef: Boolean;
 AnIsShowMsg: Boolean; AnMsgText: String);
begin
  FProgressForm := AnProgressForm;
  FIsAddRef := AnIsAddRef;
  FIsShowMsg := AnIsShowMsg;
  FMsgText := AnMsgText;
  FreeOnTerminate := True;
  FIsProccess := False;

  inherited Create(True);
end;

procedure TClientEventThread.CreateForm;
begin
  FreeOldForm;

  FPreviewForm := TmsgErrorReport.Create(nil);

  FOldClose := FPreviewForm.OnClose;
  FOldDestroy := FPreviewForm.OnDestroy;

  FPreviewForm.OnClose := DoClose;
  FPreviewForm.OnDestroy := DoDestroy;

  FPreviewForm.MessageBox('Ошибка', FMsgText);
end;

procedure TClientEventThread.DoClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if Assigned(FOldClose) then
    FOldClose(Sender, Action);
  Action := caFree;
end;

procedure TClientEventThread.DoDestroy(Sender: TObject);
begin
  if Assigned(FOldDestroy) then
    FOldDestroy(Sender);
  FPreviewForm := nil;
end;

procedure TClientEventThread.DoIt;
begin
  if FProgressForm <> nil then
  begin
    if FIsAddRef then
      FProgressForm.AddRef
    else
      FProgressForm.Release;
  end;
end;

procedure TClientEventThread.Execute;
begin
  Synchronize(DoIt);

  if not FIsShowMsg then
  begin
    Synchronize(CreateForm);
    Synchronize(IsProccess);
  end;

  while FIsProccess and not Terminated do
  begin
    Synchronize(SelfSleep);
    Synchronize(IsProccess);
  end;

  Synchronize(FreeOldForm);
end;

procedure TClientEventThread.FreeOldForm;
begin
  if Assigned(FPreviewForm) then
  begin
    FPreviewForm.OnClose := FOldClose;
    FPreviewForm.OnDestroy := FOldDestroy;
    FreeAndNil(FPreviewForm);
  end;
end;

procedure TClientEventThread.IsProccess;
begin
  FIsProccess := FPreviewForm <> nil;
end;

procedure TClientEventThread.SelfSleep;
begin
  {!!!} // Можно поставить проверку
  if not Terminated then
  begin
    Sleep(10);
    Application.ProcessMessages;
  end;
end;

destructor TClientEventThread.Destroy;
begin
  inherited;

end;

{ TClientEventFactory }

procedure TClientEventFactory.AddThread(AnClientEventThread: TClientEventThread);
var
  I: Integer;
begin
  I := FThreadList.Add(AnClientEventThread);
  TThread(FThreadList.Items[I]).OnTerminate := DoTerminate;
  TThread(FThreadList.Items[I]).Resume;
end;

procedure TClientEventFactory.Clear;
begin
  TerminateChildThreads;
end;

constructor TClientEventFactory.Create;
begin
  inherited Create;

  FThreadList := TList.Create;
end;

destructor TClientEventFactory.Destroy;
begin
  if Assigned(FThreadList) then
  begin
    TerminateChildThreads;
    FreeAndNil(FThreadList);
  end;

  inherited Destroy;
end;

procedure TClientEventFactory.DoTerminate(Sender: TObject);
var
  I: Integer;
begin
  if Assigned(FThreadList) then
  begin
    I := FThreadList.IndexOf(Sender);
    if I > -1 then
      FThreadList.Delete(I);
  end;
end;

procedure TClientEventFactory.TerminateChildThreads;
var
  I: Integer;
begin
  for I := FThreadList.Count - 1 downto 0 do
  begin
  {!!!} // Были проблемы
//    TClientEventThread(FThreadList.Items[I]).FreeOnTerminate := False;
    TClientEventThread(FThreadList.Items[I]).ClearTerminate;
//    TClientEventThread(FThreadList.Items[I]).WaitFor;
//    TClientEventThread(FThreadList.Items[I]).Free;
  end;
  FThreadList.Clear;
end;

end.
