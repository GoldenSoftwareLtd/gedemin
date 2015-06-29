unit Main;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, Menus,
  xMemo, xWorld;

type
  TMainForm = class(TForm)
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    xWorld: TxWorld;
    xMemo1: TxMemo;
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

procedure TMainForm.RadioButton1Click(Sender: TObject);
begin
 xWorld.Language := 'English';
end;

procedure TMainForm.RadioButton2Click(Sender: TObject);
begin
 xWorld.Language := 'Russian';
end;

end.
