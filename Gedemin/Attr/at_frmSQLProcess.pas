unit at_frmSQLProcess;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ActnList, TB2Dock, TB2Toolbar, TB2Item, ExtCtrls,
  at_Log, ImgList;

type
  TfrmSQLProcess = class(TForm)
    alSQLProcess: TActionList;
    actSaveToFile: TAction;
    pnlTop: TPanel;
    tbProcessSQL: TTBToolbar;
    tbiSaveToFile: TTBItem;
    stbSQLProcess: TStatusBar;
    actClose: TAction;
    tbiClose: TTBItem;
    pb: TProgressBar;
    Panel1: TPanel;
    tbiClear: TTBItem;
    actClear: TAction;
    lv: TListView;
    il: TImageList;
    actShowErrors: TAction;
    tbiShowErrors: TTBItem;

    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actSaveToFileExecute(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure actClearUpdate(Sender: TObject);
    procedure lvData(Sender: TObject; Item: TListItem);
    procedure lvDataHint(Sender: TObject; StartIndex, EndIndex: Integer);
    procedure lvInfoTip(Sender: TObject; Item: TListItem;
      var InfoTip: String);
    procedure actSaveToFileUpdate(Sender: TObject);
    procedure actShowErrorsExecute(Sender: TObject);
    procedure actShowErrorsUpdate(Sender: TObject);
  private
    FSilent: Boolean;
    FLog: TatLog;

    function GetIsError: Boolean;
    procedure PrepareItem(LI: TListItem);
    procedure SetSilent(const Value: Boolean);
    procedure CleanUp;
    procedure ProcessMessageFilter;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure AddRecord(const S: String; const ALogType: TatLogType);

    property IsError: Boolean read GetIsError;
    property Silent: Boolean read FSilent write SetSilent;
  end;

var
  frmSQLProcess: TfrmSQLProcess;

function TranslateText(const T: String): String;

procedure AddText(const T: String; const C: TColor = clBlack);
procedure AddMistake(const T: String; const C: TColor = clRed);
procedure AddWarning(const T: String; const C: TColor = clBlack);

implementation

uses
  at_dlgLoadPackages_unit, at_Classes, gd_CmdLineParams_unit
  {$IFDEF WITH_INDY}
    , gd_WebClientControl_unit
  {$ENDIF}
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

const
  cstWasMistakes = 'В ходе процесса возникли ошибки';
  cstNeedReConnection = 'Необходимо переподключение к базе';

{$R *.DFM}

function TranslateText(const T: String): String;
var
  S: String;

  procedure WhatMetaData(Const FromAdd: Boolean = False);
  var
    I: Integer;
  begin
    if AnsiPos('TABLE', S) = 1 then
    begin
      Result := Result + 'таблицы ';
      S := Trim(Copy(S, 6, Length(S) - 5));
    end

    else if AnsiPos('INDEX', S) = 1 then
    begin
      Result := Result + 'индекса ';
      S := Trim(Copy(S, 6, Length(S) - 5));
    end

    else if AnsiPos('TRIGGER', S) = 1 then
    begin
      Result := Result + 'триггера ';
      S := Trim(Copy(S, 8, Length(S) - 7));
    end

    else if AnsiPos('EXCEPTION', S) = 1 then
    begin
      Result := Result + 'исключения ';
      S := Trim(Copy(S, 10, Length(S) - 9));
    end

    else if AnsiPos('VIEW', S) = 1 then
    begin
      Result := Result + 'представления ';
      S := Trim(Copy(S, 5, Length(S) - 4));
    end

    else if AnsiPos('DOMAIN', S) = 1 then
    begin
      Result := Result + 'домена ';
      S := Trim(Copy(S, 7, Length(S) - 6));
    end

    else if AnsiPos('PROCEDURE', S) = 1 then
    begin
      Result := Result + 'процедуры ';
      S := Trim(Copy(S, 10, Length(S) - 9));
    end

    else if AnsiPos('CONSTRAINT', S) = 1 then
    begin
      Result := Result + 'ограничения ';
      S := Trim(Copy(S, 11, Length(S) - 10));
    end

    else if AnsiPos('COLUMN', S) = 1 then
    begin
      Result := Result + 'поля ';
      S := Trim(Copy(S, 7, Length(S) - 6));
    end

    else if AnsiPos('UNIQUE', S) = 1 then
    begin
      S := Trim(Copy(S, 8, Length(S) - 7));
      WhatMetaData;
      Exit;
    end

    else if AnsiPos('ASC', S) = 1 then
    begin
      S := Trim(Copy(S, 4, Length(S) - 3));
      WhatMetaData;
      Exit;
    end

    else if AnsiPos('ASCENDING', S) = 1 then
    begin
      S := Trim(Copy(S, 10, Length(S) - 9));
      WhatMetaData;
      Exit;
    end

    else if AnsiPos('DESC', S) = 1 then
    begin
      S := Trim(Copy(S, 5, Length(S) - 4));
      WhatMetaData;
      Exit;
    end

    else if AnsiPos('DESCENDING', S) = 1 then
    begin
      S := Trim(Copy(S, 11, Length(S) - 10));
      WhatMetaData;
      Exit;
    end

    else if FromAdd then
      Result := Result + 'поля '

    else
      Exit;

    for I := 1 to Length(S) do
    begin
      if S[I] in [' ', #0, #13, #10] then
        Break;
    end;

    if I < Length(S) then
    begin
      Result := Result + Copy(S, 1, I - 1);
      S := Trim(Copy(S, I + 1, Length(S) - I));
    end

    else begin
      Result := Result + S;
      S := '';
    end;

  end;

  var
    AddS: String;

begin

  S := Trim(AnsiUpperCase(T));

  while AnsiPos('/*', S) = 1 do
  begin
    if AnsiPos('*/', S) > 0 then
    begin
      Delete(S, 1, AnsiPos('*/', S) + 1);
      S := Trim(S);
    end
    else
      Break;
  end;

  if AnsiPos('CREATE', S) = 1 then
  begin
    Result := 'Создание ';
    S := Trim(Copy(S, 7, Length(S) - 6));
    WhatMetaData;
  end

  else if AnsiPos('DROP', S) = 1 then
  begin
    Result := 'Удаление ';
    S := Trim(Copy(S, 5, Length(S) - 4));
    WhatMetaData(True);
  end

  else if AnsiPos('ADD', S) = 1 then
  begin
    Result := 'Добавление ';
    S := Trim(Copy(S, 4, Length(S) - 3));
    WhatMetaData(True);
  end

  else if AnsiPos('ALTER', S) = 1 then
  begin
    Result := 'Изменение ';
    S := Trim(Copy(S, 6, Length(S) - 5));
    WhatMetaData;
    if AnsiPos('ТАБЛИЦЫ', AnsiUpperCase(Result)) > 0 then
    begin
      AddS := TranslateText(S);
      Result := Result + ' ' + AnsiLowerCase(Copy(AddS, 1, 1)) + Copy(AddS, 2, Length(AddS) - 1);
    end;
  end

  else
    Result := '';

end;

procedure AddMistake(const T: String; const C: TColor = clRed);
begin
  if Windows.GetCurrentThreadId <> System.MainThreadID then
    exit;

  if frmSQLProcess = nil then
    TfrmSQLProcess.Create(Application);

  frmSQLProcess.AddRecord(T, atltError);
end;

procedure AddWarning(const T: String; const C: TColor = clBlack);
begin
  if Windows.GetCurrentThreadId <> System.MainThreadID then
    exit;

  if frmSQLProcess = nil then
    TfrmSQLProcess.Create(Application);

  frmSQLProcess.AddRecord(T, atltWarning);
end;

procedure AddText(const T: String; const C: TColor = clBlack);
begin
  if Windows.GetCurrentThreadId <> System.MainThreadID then
    exit;

  if frmSQLProcess = nil then
    TfrmSQLProcess.Create(Application);

  frmSQLProcess.AddRecord(T, atltInfo);
end;

constructor TfrmSQLProcess.Create;
begin
  inherited;

  FSilent := gd_CmdLineParams.QuietMode;
  FLog := TatLog.Create;

  frmSQLProcess.Free;
  frmSQLProcess := Self;
end;

procedure TfrmSQLProcess.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if (not Visible) and ((frmSQLProcess = nil) or (frmSQLProcess = Self)) then
    Action := caFree;
end;

procedure TfrmSQLProcess.actSaveToFileExecute(Sender: TObject);
var
  SD: TSaveDialog;
begin
  SD := TSaveDialog.Create(Self);
  try
    SD.Title := 'Сохранить лог в файл ';
    SD.DefaultExt := 'txt';
    SD.Filter := 'Текстовые файлы (*.txt)|*.txt|Все файлы (*.*)|*.*';
    SD.FileName := 'log.txt';
    SD.Options := [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofNoReadOnlyReturn, ofEnableSizing];
    if SD.Execute then FLog.SaveToFile(SD.FileName);
  finally
    SD.Free;
  end;
end;

procedure TfrmSQLProcess.actClearUpdate(Sender: TObject);
begin
  actClear.Enabled := FLog.Count > 0;
end;

procedure TfrmSQLProcess.actClearExecute(Sender: TObject);
begin
  CleanUp;
  actShowErrors.Checked := False;
  lv.Visible := False;
  lv.Visible := True;
end;

function TfrmSQLProcess.GetIsError: Boolean;
begin
  Result := FLog.WasError;
end;

procedure TfrmSQLProcess.actCloseExecute(Sender: TObject);
begin
  Close;
end;

destructor TfrmSQLProcess.Destroy;
var
  TempPath: array[0..1023] of Char;
begin
  frmSQLProcess := nil;
  if FSilent and (FLog.Count > 0) and (GetTempPath(SizeOf(TempPath), TempPath) > 0) then
    FLog.SaveToFile(IncludeTrailingBackslash(TempPath) + 'gedemin.log');
  FLog.Free;
  inherited;
end;

procedure TfrmSQLProcess.AddRecord(const S: String; const ALogType: TatLogType);
const
  PrevTime: DWORD = 0;
var  
  h: THandle;
  ss: array [0..0] of PChar;
  LogType: Integer;
begin
  FLog.AddRecord(TrimRight(S), ALogType);
  lv.Items.Count := FLog.Count;

  if lv.Items.Count > 0 then
    lv.Items[lv.Items.Count - 1].MakeVisible(False);

  if FSilent then
  begin
    if ALogType <> atltInfo then
    begin
      if ALogType = atltWarning then
        LogType := EVENTLOG_WARNING_TYPE
      else
        LogType := EVENTLOG_ERROR_TYPE;
      ss[0] := PChar(S);
      h := RegisterEventSource(nil, 'Gedemin');
      try
        if h <> 0 then
          ReportEvent(h,          // event log handle
            LogType,              // event type
            0,                    // category zero
            0,                    // event identifier
            nil,                  // no user security identifier
            1,                    // one substitution string
            0,                    // no data
            @ss,                  // pointer to string array
            nil);                 // pointer to data
        // code from http://stackoverflow.com/questions/397934/writing-to-the-event-log-in-delphi
      finally
        DeregisterEventSource(h);
      end;
    end;
  end else
  begin
    if not Visible then
    begin
      Show;
      PrevTime := 0;
    end;

    if (GetTickCount - PrevTime) > 2000 then
    begin
      BringToFront;
      UpdateWindow(Handle);
      PrevTime := GetTickCount;
    end;
  end;

  if Assigned(atDatabase) and atDatabase.InMultiConnection then
    stbSQLProcess.Panels[1].Text := cstNeedReConnection
  else
    stbSQLProcess.Panels[1].Text := '';

  if ALogType = atltError then
  begin
    stbSQLProcess.Panels[0].Text := cstWasMistakes;

    {$IFDEF WITH_INDY}
    if gdWebClientThread <> nil then
      gdWebClientThread.SendError('Log: ' + S);
    {$ENDIF}
  end;
end;

procedure TfrmSQLProcess.lvData(Sender: TObject; Item: TListItem);
begin
  PrepareItem(Item);
end;

procedure TfrmSQLProcess.lvDataHint(Sender: TObject; StartIndex,
  EndIndex: Integer);
var
  I: Integer;
begin
  for I := StartIndex to EndIndex do
    PrepareItem(lv.Items[I]);
end;

procedure TfrmSQLProcess.lvInfoTip(Sender: TObject; Item: TListItem;
  var InfoTip: String);
var
  LogRecordIndex: Integer;
begin
  // Если выбрано показывать только ошибки, то сначала надо получить настоящий индекс записи в логе
  //  т.к. кол-во отображаемых записей уже не равно кол-ву записей в логе
  if actShowErrors.Checked then
    LogRecordIndex := FLog.GetRealErrorRecIndex(Item.Index)
  else
    LogRecordIndex := Item.Index;

  InfoTip := FLog.LogText[LogRecordIndex];
  if (Length(InfoTip) < 92) and (Pos(#13, InfoTip) = 0) then
    InfoTip := '';
end;

procedure TfrmSQLProcess.PrepareItem(LI: TListItem);
var
  S: String;
  B, E: Integer;
  LogRecordIndex: Integer;
  LogRec: TatLogRec;
begin
  // Если выбрано показывать только ошибки, то сначала надо получить настоящий индекс записи в логе
  //  т.к. кол-во отображаемых записей уже не равно кол-ву записей в логе
  if actShowErrors.Checked then
    LogRecordIndex := FLog.GetRealErrorRecIndex(LI.Index) 
  else
    LogRecordIndex := LI.Index;

  LogRec := FLog.LogRec[LogRecordIndex];
  // Отобразим данные записи
  with LogRec do
  begin
    LI.Caption := FormatDateTime('hh:nn:ss', Logged);

    S := FLog.LogText[LogRecordIndex];

    B := 1;
    while (B <= Length(S)) and (S[B] <= ' ') do
      Inc(B);
    E := B;
    while (E - B < 120) and (E <= Length(S)) and (S[E] >= ' ') do
      Inc(E);

    if E < Length(S) then
      LI.SubItems.Add(Copy(S, B, E - B) + '...')
    else
      LI.SubItems.Add(Copy(S, B, E - B));

    case LogType of
      atltError: LI.StateIndex := 0;
      atltWarning: LI.StateIndex := 1;
    else
      LI.StateIndex := 2;
    end;
  end;
end;

procedure TfrmSQLProcess.actSaveToFileUpdate(Sender: TObject);
begin
  actSaveToFile.Enabled := FLog.Count > 0;
end;

procedure TfrmSQLProcess.SetSilent(const Value: Boolean);
begin
  FSilent := Value;
  if Visible and FSilent then
    Hide;
end;

procedure TfrmSQLProcess.CleanUp;
begin
  FLog.Clear;
  lv.Items.Count := 0;

  stbSQLProcess.Panels[0].Text := '';
  stbSQLProcess.Panels[1].Text := '';
  pb.Min := 0;
  pb.Max := 0;
  pb.Position := 0;
end;

procedure TfrmSQLProcess.actShowErrorsExecute(Sender: TObject);
begin
  actShowErrors.Checked := not actShowErrors.Checked;
  ProcessMessageFilter;
end;

procedure TfrmSQLProcess.ProcessMessageFilter;
begin
  lv.Items.BeginUpdate;
  if actShowErrors.Checked then
    lv.Items.Count := FLog.ErrorCount
  else
    lv.Items.Count := FLog.Count;

  // Перейдем на первую запись
  if lv.Items.Count > 0 then
    lv.Items[0].MakeVisible(False);
  lv.Items.EndUpdate;
end;

procedure TfrmSQLProcess.actShowErrorsUpdate(Sender: TObject);
begin
  actShowErrors.Enabled := FLog.WasError;
end;

end.

