unit mainform;

{$mode objfpc}{$H+}

interface


uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Operation, Windows, LCLType, Buttons, ActnList, rq, SubDevision,
  rqoperation;

type
  { TMainForm }

  TMainForm = class(TForm)
    bSend: TButton;
    lIN: TLabel;
    lFRFree: TLabel;
    lID: TLabel;
    lVT: TLabel;
    lSOFP: TLabel;
    lSOFPE: TLabel;
    lFR: TLabel;
    lSOFPEFree: TLabel;
    lSWP: TLabel;
    lExit: TLabel;
    lTitle: TLabel;
    pMenu: TPanel;
    Timer: TTimer;

    procedure bSendClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
  private
    { private declarations }
    function GetDocumentType(AKey: Word): String;
    function GetDocumentTypeInt(AKey: Word): Integer;
  protected
   //
  public
    { public declarations }
  end;

  {$IFNDEF SKORPIOX3}
  function IsInCradle: Boolean;
    stdcall; external 'scaner_dll.dll' name 'IsInCradle';
  {$ENDIF}

var
  FMainForm: TMainForm;
  UserId: String;

implementation

{$R *.lfm}

uses
  JcfStringUtils, MessageForm;

const
  PrefixLoad = 'cl';
  PrefixSave = 'ov';

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
begin
  BorderStyle := bsNone;
  WindowState := wsNormal;

  bSend.Visible := False;
  lTitle.Caption := 'Выберите операцию:';
  lSWP.Caption := '1-Отгр. с произ-ва';
  lID.Caption := '2-Внутр. перемещение';
  lSOFP.Caption := '3-Сфор-ая заявка';
  lFRFree.Caption := '4-Произ-ая заявка';
  lSOFPE.Caption := '5-Сфор-ая заявка(вал-ая)';
  lSOFPEFree.Caption := '6-Произ-ая заявка(вал-ая)';
 // lR.Caption := '7-Разукомплектация';
  lFR.Caption := '7-На исследование';
  lIN.Caption := '8-Инвентаризация';
  lVT.Caption := '9-Сверка отгрузки';
  lExit.Caption := 'ESC-выход их программы';
  Timer.Enabled := False;
  Timer.Interval := 600;
end;



procedure TMainForm.bSendClick(Sender: TObject);
begin
  {$IFNDEF SKORPIOX3}
  if IsInCradle then
  begin
    bSend.Enabled := False;
    SysUtils.DeleteFile(ExtractFilePath(Application.ExeName) + '\cl\ALLTRANSFER.TXT');
    Timer.Enabled := True;
  end else
  begin
    MessageForm.MessageDlg('Нет подключения по сети!', 'Внимание',
      mtInformation, [mbOk]);
    Application.ProcessMessages;
  end;
  {$ENDIF}
end;



procedure TMainForm.FormDestroy(Sender: TObject);
var
  hTaskBar: THandle;
begin
  hTaskBar := FindWindow('HHTaskBar','');
  ShowWindow(hTaskBar, SW_SHOW);
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Temps: String;
  RQ: TRQParams;
begin
  case Key of
    VK_3, VK_5:
    begin
      if FileExists(ExtractFilePath(Application.ExeName) + '\cl\ENDTRANSFER.TXT') then
      begin
        RQ := TRQ.ExecuteWithParams;
        if RQ.Data <> '' then
        begin
          with TOperationRQ.Create(self) do
          try
            AddPositionToMemo('Код пользователя: ' + UserId);
            AddPositionToMemo('Операция: ' + GetDocumentType(Key));
            AddPositionToMemo('Документ: ' + Copy(Temps, 12, Length(RQ.Data)));
            LoadRequest(PrefixLoad + RQ.Data, RQ.RQname);
            if RQ.RQName = '' then
            begin
              AddPosition(Chr(Key) + Copy(RQ.Data, 12, Length(RQ.Data)));
              AddPosition('');
              AddPosition(UserId);
              AddPosition(FormatDateTime('ddmmyyyyhhmmss', Now));
              AddPosition(Copy(RQ.Data, 1, 8));
              AddPosition(Copy(RQ.Data, 9, 3));
            end;
            ShowModal;
          finally
            free;
          end;
        end;
      end else
        MessageForm.MessageDlg('Загружены не все файлы заявок! Загрузите файлы заявок на устройство!', 'Внимание',
          mtInformation, [mbOk]);
    end;
    VK_1, VK_2, VK_4, VK_6, VK_7, VK_8, VK_9:
    begin
      if not (Key in [VK_4, VK_6, VK_7, VK_8, VK_9]) then
        Temps :=  TSubDevision.Execute('Код подразделения: ')
      else
        Temps := '';

      if (Temps <> '') or (Key in [VK_4, VK_6, VK_7, VK_8, VK_9]) then
      begin

        with TOperationTP.Create(self) do
        try
          AddPositionToMemo('Код подразделения: ' + Temps);
          AddPositionToMemo('Код пользователя: ' + UserId);
          AddPositionToMemo('Операция: ' + GetDocumentType(Key));
          AddPositionToMemo('Date: ' + FormatDateTime('c', Now));
          AddPosition(chr(Key));
          AddPosition(Temps);
          AddPosition(UserId);
          AddPosition(FormatDateTime('ddmmyyyyhhmmss', Now));
          AddPosition('');
          AddPosition('');
          DocType := GetDocumentTypeInt(Key);
          ShowModal;
        finally
          Free;
        end;
      end;

    end;
    VK_ESCAPE: Close;
  end;
end;

procedure TMainForm.FormShow(Sender: TObject);
var
  ScreenWidth, ScreenHeight: Integer;
  TaskBarWnd: THandle;
begin
  ScreenWidth := GetSystemMetrics(SM_CXSCREEN);
  ScreenHeight := GetSystemMetrics(SM_CYSCREEN);
  SetWindowPos(Handle, HWND_TOPMOST, 0, 0, ScreenWidth, ScreenHeight, 0);
  TaskBarWnd := FindWindow('HHTaskBar', '');
  if (TaskBarWnd <> 0) then
    SetWindowPos(TaskBarWnd, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOSIZE or SWP_NOMOVE);
end;


procedure TMainForm.TimerTimer(Sender: TObject);
begin
  {$IFNDEF SKORPIOX3}
  if not IsInCradle then
  begin
    Timer.Enabled := False;
    bSend.Enabled := True;
  end else
  begin
    if FileExists(ExtractFilePath(Application.ExeName) + '\cl\ALLTRANSFER.TXT')
      and (not bSend.Enabled) then
    begin
      bSend.Enabled := True;
      Timer.Enabled := False;
      MessageForm.MessageDlg('Файлы переданы!', 'Внимание',
        mtInformation, [mbOk]);
      Application.ProcessMessages;
    end;
  end;
  {$ENDIF}
end;

function TMainForm.GetDocumentType(AKey: Word): String;
begin
  case AKey of
    VK_1: Result := 'Отгрузка с производства';
    VK_2: Result := 'Внутреннее перемещение';
    VK_3: Result := 'Отгрузка готовой продукции, сформированная заявка';
    VK_4: Result := 'Отгрузка готовой продукции, произвольная заявка';
    VK_5: Result := 'Отгрузка готовой продукции, сформированная заявка(валютная)';
    VK_6: Result := 'Отгрузка готовой продукции, произвольная заявка(валютная)';
   // VK_7: Result := 'Разукомплектация';
    VK_7: Result := 'На исследование';
    VK_8: Result := 'Инвентаризация';
    VK_9: Result := 'Сверка отгрузки';
  end;
end;

function TMainForm.GetDocumentTypeInt(AKey: Word): Integer;
begin
  case AKey of
    VK_1: Result := 1;
    VK_2: Result := 2;
    VK_3: Result := 3;
    VK_4: Result := 4;
    VK_5: Result := 5;
    VK_6: Result := 6;
    VK_7: Result := 7;
    VK_8: Result := 8;
    VK_9: Result := 9;
  end;
end;
end.

