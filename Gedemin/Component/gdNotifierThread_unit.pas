
unit gdNotifierThread_unit;

interface

uses
  Classes, Windows, Messages, SyncObjs, gdMessagedThread, idThreadSafe;

type
  TgdNotifierItem = class(TCollectionItem)
  private
    FText: String;
    FShowTime: DWORD;
    FContext: Integer;
    FTimer: Boolean;
    FCreated: TDateTime;
    FWasShownOn: TDateTime;
    FWasFirstShownOn: TDateTime;

    function GetShownInMS: DWORD;
    function GetExpired: Boolean;
    procedure SetWasShownOn(const Value: TDateTime);

  public
    constructor Create(Collection: TCollection); override;

    property Text: String read FText write FText;
    property Context: Integer read FContext write FContext;
    property ShowTime: DWORD read FShowTime write FShowTime;
    property Timer: Boolean read FTimer write FTimer;
    property Created: TDateTime read FCreated;
    property WasShownOn: TDateTime read FWasShownOn write SetWasShownOn;
    property ShownInMS: DWORD read GetShownInMS;
    property Expired: Boolean read GetExpired;
  end;

  TgdNotifierQueue = class(TCollection)
  private
    FCurrContext: Integer;
    FCurr: Integer;

    function GetEOF: Boolean;

  public
    constructor Create;

    function GetNextContext: Integer;
    function GetCurrItem: TgdNotifierItem;
    function GetNextItem: TgdNotifierItem;
    procedure MoveNext;
    function HasUrgent: Boolean;
    procedure DeleteCurrItem;
    function DeleteContext(const AContext: Integer): Boolean;
    function DeleteNotification(const AnID: Integer): Boolean;

    property Curr: Integer read FCurr;
    property EOF: Boolean read GetEOF;
  end;

  TgdNotifierThread = class(TgdMessagedThread)
  private
    FQueue: TgdNotifierQueue;
    FNotification: TidThreadSafeString;
    FNotifierWindow: hWnd;
    FNotifierWindowCS, FQueueCS: TCriticalSection;

    function GetMin(const A, B: DWORD): DWORD;
    function GetNotifierWindow: hWnd;
    procedure SetNotifierWindow(const Value: hWnd);
    function GetNotification: String;

  protected
    function ProcessMessage(var Msg: TMsg): Boolean; override;
    procedure Timeout; override;

  public
    constructor Create;
    destructor Destroy; override;

    function GetNextContext: Integer;
    function Add(const AText: String; const AContext: Integer = 0;
      const AShowTime: DWORD = INFINITE): Integer;
    procedure DeleteContext(const AContext: Integer);
    procedure DeleteNotification(const AnID: Integer);

    property NotifierWindow: hWnd read GetNotifierWindow
      write SetNotifierWindow;
    property Notification: String read GetNotification;  
  end;

var
  gdNotifierThread: TgdNotifierThread;

implementation

uses
  SysUtils, gd_messages_const;

const
  MinShowTime    = 2000;
  MaxShowTime    = 7000;
  TimerInterval  = 1000;

  MSecPerDay     = 24 * 60 * 60 * 1000;

{ TgdNotifierThread }

function TgdNotifierThread.Add(const AText: String; const AContext: Integer = 0;
  const AShowTime: DWORD = INFINITE): Integer;
var
  Item: TgdNotifierItem;
begin
  FQueueCS.Enter;
  try
    Item := FQueue.Add as TgdNotifierItem;
    Item.Text := AText;
    Item.Context := AContext;
    Item.ShowTime := AShowTime;
    Item.Timer := Pos('<tmr>', AText) > 0;
    Result := Item.ID;
  finally
    FQueueCS.Leave;
  end;
  
  PostMsg(WM_GD_UPDATE_NOTIFIER, Result);
end;

constructor TgdNotifierThread.Create;
begin
  inherited Create(True);
  Priority := tpLowest;
  FQueue := TgdNotifierQueue.Create;
  FNotifierWindowCS := TCriticalSection.Create;
  FQueueCS := TCriticalSection.Create;
  FNotification := TidThreadSafeString.Create;
end;

procedure TgdNotifierThread.DeleteNotification(const AnID: Integer);
begin
  FQueueCS.Enter;
  try
    if FQueue.DeleteNotification(AnID) then
      PostMsg(WM_GD_UPDATE_NOTIFIER);
  finally
    FQUeueCS.Leave;
  end;
end;

procedure TgdNotifierThread.DeleteContext(const AContext: Integer);
begin
  FQueueCS.Enter;
  try
    if FQueue.DeleteContext(AContext) then
      PostMsg(WM_GD_UPDATE_NOTIFIER);
  finally
    FQueueCS.Leave;
  end;
end;

destructor TgdNotifierThread.Destroy;
begin
  inherited;
  FQueue.Free;
  FNotifierWindowCS.Free;
  FQueueCS.Free;
  FNotification.Free;
end;

function TgdNotifierThread.GetMin(const A, B: DWORD): DWORD;
begin
  if A < B then
    Result := A
  else
    Result := B;  
end;

function TgdNotifierThread.GetNextContext: Integer;
begin
  FQueueCS.Enter;
  try
    Result := FQueue.GetNextContext;
  finally
    FQueueCS.Leave;
  end;
end;

function TgdNotifierThread.ProcessMessage(var Msg: TMsg): Boolean;
begin
  if Msg.Message = WM_GD_UPDATE_NOTIFIER then
  begin
    Timeout;
    Result := True;
  end else
    Result := False;
end;

procedure TgdNotifierThread.Timeout;
var
  CurrItem: TgdNotifierItem;
  S: String;
begin
  FQueueCS.Enter;
  try
    CurrItem := FQueue.GetCurrItem;

    if (CurrItem <> nil) and (CurrItem.WasShownOn > 0) then
    begin
      if CurrItem.Expired then
        FQueue.DeleteCurrItem
      else
      begin
        if (FQueue.HasUrgent and (CurrItem.ShownInMS >= MinShowTime))
          or (CurrItem.ShownInMS >= MaxShowTime) then
        begin
          CurrItem.WasShownOn := 0;
          FQueue.MoveNext;
        end;
      end;
      CurrItem := FQueue.GetCurrItem;
    end;

    if CurrItem <> nil then
    begin
      S := CurrItem.Text;
      if CurrItem.Timer then
        S := StringReplace(S, '<tmr>', FormatDateTime('hh:nn:ss', Now - CurrItem.Created), []);
      if CurrItem.WasShownOn = 0 then
        CurrItem.WasShownOn := Now;

      if CurrItem.Timer then
        SetTimeout(TimerInterval)
      else
      begin
        if FQueue.Count = 1 then
          SetTimeout(CurrItem.ShowTime)
        else
        begin
          if FQueue.HasUrgent then
            SetTimeout(GetMin(MinShowTime, CurrItem.ShowTime))
          else
            SetTimeout(GetMin(MaxShowTime, CurrItem.ShowTime));
        end;
      end;
    end else
    begin
      S := '';
      SetTimeout(INFINITE);
    end;

    if S <> FNotification.Value then
    begin
      FNotification.Value := S;
      if NotifierWindow <> 0 then
        PostMessage(NotifierWindow, WM_GD_UPDATE_NOTIFICATION, 0, 0);
    end;
  finally
    FQueueCS.Leave;
  end;
end;

function TgdNotifierThread.GetNotifierWindow: hWnd;
begin
  FNotifierWindowCS.Enter;
  try
    Result := FNotifierWindow;
  finally
    FNotifierWindowCS.Leave;
  end;
end;

procedure TgdNotifierThread.SetNotifierWindow(
  const Value: hWnd);
begin
  FNotifierWindowCS.Enter;
  try
    FNotifierWindow := Value;
  finally
    FNotifierWindowCS.Leave;
  end;
end;

function TgdNotifierThread.GetNotification: String;
begin
  Result := FNotification.Value;
end;

{ TgdNotifierQueue }

constructor TgdNotifierQueue.Create;
begin
  inherited Create(TgdNotifierItem);
end;

function TgdNotifierQueue.DeleteContext(const AContext: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Count - 1 downto 0 do
  begin
    if (Items[I] as TgdNotifierItem).Context = AContext then
    begin
      Delete(I);
      if I < FCurr then
        Dec(FCurr);
      Result := True;
    end;
  end;

  if Result and (FCurr >= Count) then
  begin
    if Count > 0 then
      FCurr := Count - 1
    else
      FCurr := 0;  
  end;
end;

procedure TgdNotifierQueue.DeleteCurrItem;
begin
  if not EOF then
  begin
    Delete(FCurr);
    if FCurr >= Count then
      FCurr := 0;
  end;
end;

function TgdNotifierQueue.DeleteNotification(const AnID: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Count - 1 downto 0 do
  begin
    if (Items[I] as TgdNotifierItem).ID = AnID then
    begin
      Delete(I);
      if I < FCurr then Dec(FCurr);
      Result := True;
      break;
    end;
  end;
end;

function TgdNotifierQueue.GetCurrItem: TgdNotifierItem;
begin
  if not EOF then
    Result := Items[FCurr] as TgdNotifierItem
  else
    Result := nil;
end;

function TgdNotifierQueue.GetEOF: Boolean;
begin
  Result := FCurr >= Count;
end;

function TgdNotifierQueue.GetNextContext: Integer;
begin
  if FCurrContext = MAXINT then
    FCurrContext := 1
  else
    Inc(FCurrContext);
  Result := FCurrContext;
end;

function TgdNotifierQueue.GetNextItem: TgdNotifierItem;
begin
  if not EOF then
  begin
    if FCurr = Count - 1 then
      Result := Items[0] as TgdNotifierItem
    else
      Result := Items[FCurr + 1] as TgdNotifierItem;  
  end else
    Result := nil;
end;

function TgdNotifierQueue.HasUrgent: Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Count - 1 do
  begin
    if (I <> FCurr) and ((Items[I] as TgdNotifierItem).ShowTime <> INFINITE) then
    begin
      Result := True;
      break;
    end;
  end;
end;

procedure TgdNotifierQueue.MoveNext;
begin
  Inc(FCurr);
  if FCurr >= Count then
    FCurr := 0;
end;

{ TgdNotifierItem }

constructor TgdNotifierItem.Create(Collection: TCollection);
begin
  inherited;
  FCreated := Now;
  FShowTime := INFINITE;  
end;

function TgdNotifierItem.GetExpired: Boolean;
var
  MS: DWORD;
begin
  if FWasFirstShownOn = 0 then
    FWasFirstShownOn := FWasShownOn;

  if FWasFirstShownOn = 0 then
    MS := 0
  else
    MS := Trunc((Now - FWasFirstShownOn) * 24 * 60 * 60 * 1000) + 1;

  Result := (ShowTime <> INFINITE) and (ShowTime < MS);
end;

function TgdNotifierItem.GetShownInMS: DWORD;
begin
  if FWasShownOn = 0 then
    Result := 0
  else
    Result := Trunc((Now - FWasShownOn) * 24 * 60 * 60 * 1000) + 1;
end;

procedure TgdNotifierItem.SetWasShownOn(const Value: TDateTime);
begin
  FWasShownOn := Value;
  if FWasFirstShownOn = 0 then
    FWasFirstShownOn := FWasShownOn;
end;

initialization
  gdNotifierThread := TgdNotifierThread.Create;
  gdNotifierThread.Resume;

finalization
  FreeAndNil(gdNotifierThread);
end.