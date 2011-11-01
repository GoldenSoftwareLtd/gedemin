unit gd_dlgReg_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls;

type
  Tgd_dlgReg = class(TForm)
    eCipher: TEdit;
    Label2: TLabel;                   
    btnClose: TButton;
    btnReg: TButton;
    Bevel1: TBevel;
    pc: TPageControl;
    tsReg: TTabSheet;
    tsUnReg: TTabSheet;
    mUnreg: TMemo;
    mReg: TMemo;
    lblRegNumber: TLabel;
    lblRegNumber2: TLabel;
    procedure btnRegClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gd_dlgReg: Tgd_dlgReg;
                    
implementation

uses
  gd_registration, Clipbrd
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R *.DFM}

procedure Tgd_dlgReg.btnRegClick(Sender: TObject);
begin
  if not IsRegisteredCopy or
     (IsRegisteredCopy and
     (MessageBox(HANDLE, 'Выша копия программы уже зарегистрирована. '#13#10 +
       'Вы действительно хотите выполнить регистрацию?', 'Внимание', mb_YesNo or MB_ICONQUESTION) = mrYes)) then
  try
    DoRegister(StrToInt64(eCipher.Text));
    IsRegisteredCopy := CheckRegistration;

    if IsRegisteredCopy then
    begin
      MessageBox(Handle,
        'Регистрация программы прошла успешно.',
        'Регистрация',
        MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
    end;

    Close;
  except 
    on EConvertError do
      MessageBox(HANDLE, 'Возникла ошибка при обработке кода разблокировки. Проверьте, пожалуйста, введенное значение.', 'Внимание', MB_OK or MB_ICONERROR);
    else                                                                     
      MessageBox(HANDLE, 'Возникла неизвестная ошибка при обработке кода разблокировки.', 'Внимание', MB_OK or MB_ICONERROR);
  end;
end;

procedure Tgd_dlgReg.FormCreate(Sender: TObject);
var
  S1, S2: String;
begin
  lblRegNumber.Caption := GetVisRegNumber;

  if RegParams.Period > 0 then
    S1 := FormatDateTime('dd.mm.yy', IncMonth(regInitialDate, RegParams.Period * 3))
  else
    S1 := 'не ограничено';

  if RegParams.UserCount > 0 then
    S2 := IntToStr(RegParams.UserCount)
  else
    S2 := 'не ограничено';

  mReg.Lines.Text := Format(mReg.Lines.Text, [S2, S1]);
  lblRegNumber2.Caption := GetVisRegNumber;

  if IsRegisteredCopy then
  begin
    pc.ActivePage := tsReg;
    Clipboard.AsText := lblRegNumber2.Caption;
  end else
  begin
    pc.ActivePage := tsUnReg;
    Clipboard.AsText := lblRegNumber.Caption;
  end;
end;


procedure Tgd_dlgReg.btnCloseClick(Sender: TObject);
begin
  if eCipher.Text > '' then
  begin
    btnReg.OnClick(nil);
  end;
end;

end.
