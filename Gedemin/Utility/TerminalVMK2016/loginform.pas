unit LoginForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Windows, LCLType, ExtCtrls, LCLProc, BaseAddInformation;

type

  { TLoginForm }

  TLoginForm = class(TBaseAddInformation)
    lInfoMsg: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  protected
   // function CheckUser: Boolean; virtual;
    //procedure EnterUser; virtual;
    procedure Enter; override;
    function CheckCode(const ACode: String): boolean; override;
  public
    { public declarations }
    class function Execute2: boolean;
  end;

implementation

{$R *.lfm}

uses
  mainform, JcfStringUtils, MessageForm;

const
  DigitsUser = 3;

function Translate(Name,Value: AnsiString; Hash: Longint; arg:pointer): AnsiString;
begin
  case StringCase(Value,['&Yes','&No','Cancel']) of
    0: Result := Trim('&Да');
    1: Result :=Trim('&Нет');
    2: Result := Trim('Отмена');
    else Result := Value;
  end;
end;


procedure TLoginForm.FormCreate(Sender: TObject);
begin
  inherited;

  lInfo.Caption := 'Код: ';
  lInfoMSG.Caption := 'Введите код' + #13#10 + 'пользователя для ' + #13#10 +
    'работы с терминалом';
end;

class function TLoginForm.Execute2: Boolean;
begin
  with TLoginForm.Create(nil) do
  try
    Result := ShowModal = mrOk;
  finally
    Free;
  end;
end;

procedure TLoginForm.Enter;
begin
  if CheckCode(Trim(eInfo.Text)) then
    ModalResult := mrOk;
end;

function TLoginForm.CheckCode(const ACode: String): Boolean;
var
  F: TextFile;
  Line, Temp: String;
begin
  Result := False;
  if (ACode <> '') and (Length(ACode) <= DigitsUser) then
  begin
    Temp := StrFillChar('0', DigitsUser - Length(ACode)) + ACode;
    AssignFile(F, ExtractFilePath(Application.ExeName) + '\cl\SHCODE_USERS.TXT');
    Reset(F);
    try
      while not(eof(F)) do
      begin
        Readln(F, Line);
        if StrIPos(Temp + ';', Line) = 1 then
        begin
          UserId := Temp;
          Result := True;
          Break;
        end;
      end;
    finally
      CloseFile(F);
    end;
  end;

  if not Result then
    MessageForm.MessageDlg('Неверно введен код пользователя ' +
      'или пользоветель с таким кодом не существует!',
      'Внимание!',
      mtInformation, [mbOk]);
end;

initialization
  SetResourceStrings(@Translate,nil);
end.

