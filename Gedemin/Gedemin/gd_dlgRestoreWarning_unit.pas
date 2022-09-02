// ShlTanya, 09.03.2019

unit gd_dlgRestoreWarning_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  Tgd_dlgRestoreWarning = class(TForm)
    Memo: TMemo;
    Timer: TTimer;
    btnCancel: TButton;
    lbl: TLabel;
    procedure TimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    FCounter: Integer;
  end;

var
  gd_dlgRestoreWarning: Tgd_dlgRestoreWarning;

implementation

{$R *.DFM}

procedure Tgd_dlgRestoreWarning.TimerTimer(Sender: TObject);
begin
  Dec(FCounter);
  if FCounter <= 0 then
    ModalResult := mrOk
  else if FCounter > 4 then
    lbl.Caption := 'Повторная попытка через ' + IntToStr(FCounter) + ' секунд.';
end;

procedure Tgd_dlgRestoreWarning.FormCreate(Sender: TObject);
begin
  FCounter := 10;
end;

end.
