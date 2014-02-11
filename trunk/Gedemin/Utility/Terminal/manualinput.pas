unit ManualInput;

{$mode objfpc}{$H+}

interface

uses
  Windows, Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  BaseAddInformation;

type

  { TManualInput }

  TManualInput = class(TBaseAddInformation)
    procedure FormCreate(Sender: TObject);
    //procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { private declarations }
  protected
    //function CheckCode(const ACode: String): boolean; override;
  public
    { public declarations }
    class function Execute: String; override;
  end;

implementation

{$R *.lfm}
uses
  MessageForm;

{ TManualInput }

procedure TManualInput.FormCreate(Sender: TObject);
begin
  inherited;
  lInfo.Caption := 'Введите код товара: ';
end;

{procedure TManualInput.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    if CheckCode(Trim(eInfo.Text)) then
      inherited
    else
      MessageForm.MessageDlg('Неверно введен штрих-код',
        'Внимание!',
        mtInformation, [mbOk]);
  end else
    inherited;
end; }

{function TManualInput.CheckCode(const ACode: String): boolean;
var
  StrDate: string;
  Fmt: TFormatSettings;
  dt: TDateTime;
begin
  Result := True;

  fmt.ShortDateFormat:= 'dd/mm/yyyy';
  fmt.DateSeparator  := '/';
  fmt.LongTimeFormat := 'hh:nn:ss';
  fmt.TimeSeparator  := ':';

  StrDate:= Copy(ACode, 7, 2) + '/' + Copy(ACode, 9, 2) + '/20' +
    Copy(ACode, 11, 2) + ' ' + Copy(ACode, 13, 2) + ':' + Copy(ACode, 15, 2);

  if not TryStrToDateTime (StrDate, dt, fmt) then
    Result := False;
end;  }

class function TManualInput.Execute: String;
begin
  Result := '';
  with TManualInput.Create(nil) do
  try
    ShowModal;
    Result := Data;
  finally
    Free;
  end;
end;

end.

