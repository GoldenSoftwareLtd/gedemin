unit SubDevision;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  BaseAddInformation;

type

  { TSubDevision }

  TSubDevision = class(TBaseAddInformation)
    lInfoMsg: TLabel;
    procedure eInfoEnter(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  protected
    procedure Enter; override;
    function CheckCode(const ACode: String): boolean; override;
  public
    { public declarations }
  end; 

var
  Form1: TSubDevision;

implementation

{$R *.lfm}
uses
  JcfStringUtils, MessageForm;
const
  DigitsSubDivision = 3;

procedure TSubDevision.FormCreate(Sender: TObject);
begin
  inherited;
  lInfo.Caption := 'Код подразделения: ';
  lInfoMsg.Caption := 'Введите код ' + #13#10 + 'подразделения на ' + #13#10 +
    'которое идет отгрузка';
end;

procedure TSubDevision.eInfoEnter(Sender: TObject);
begin
  inherited;
end;


procedure TSubDevision.Enter;

begin
  if CheckCode(Trim(eInfo.Text)) then
    ModalResult := mrOk;
end;

function TSubDevision.CheckCode(const ACode: String): Boolean;
var
  F: TextFile;
  Line: String;
  Temp: String;
begin
  Result := False;
  if (ACode <> '') and (Length(ACode) <= DigitsSubDivision) then
  begin
    Temp := StrFillChar('0', DigitsSubDivision - Length(ACode)) + ACode;
    AssignFile(F, ExtractFilePath(Application.ExeName) + '\cl\SHCODE_DEPART.TXT');
    Reset(F);
    try
      while not(eof(F)) do
      begin
        Readln(F, Line);
        if StrIPos(Temp + ';', Line) = 1 then
        begin
          Data := Temp;
          Result := True;
          Break;
        end;
      end;
    finally
      CloseFile(F);
    end;
  end;

  if not Result then
    MessageForm.MessageDlg('Неверно введен код подразделения ',
      'Внимание!',
      mtInformation, [mbOk]);
end;
end.

